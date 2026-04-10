#!/bin/bash
# Knowledge Compiler installer for GSD
# Usage: ./install.sh [--project /path/to/project] [--force]
#
# What it does:
#   1. Patches ~/.claude/agents/gsd-phase-researcher.md (Step 0: incremental compile)
#   2. Patches ~/.claude/agents/gsd-verifier.md (Step 10b: full reconcile)
#   3. Patches ~/.claude/get-shit-done/workflows/ (new-project, new-milestone: .knowledge/ auto-init)
#   4. Installs global ~/.claude/CLAUDE.md turn collection instruction
#   5. Optionally sets up a specific project with .knowledge/ directories
#
# --force: Remove existing patch and re-apply (use after updating patch files)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTS_DIR="$HOME/.claude/agents"
WORKFLOWS_DIR="$HOME/.claude/get-shit-done/workflows"
GLOBAL_CLAUDE_MD="$HOME/.claude/CLAUDE.md"
PATCH_MARKER="PATCH:knowledge-compiler"
FORCE=false

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()  { echo -e "${GREEN}[✓]${NC} $1"; }
warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1"; }

# --- Agent patching ---

# Remove existing patch block between two markers from an agent file
unpatch_agent() {
    local agent_file="$1"
    local agent_name
    agent_name="$(basename "$agent_file")"

    if ! grep -q "$PATCH_MARKER" "$agent_file" 2>/dev/null; then
        return 0
    fi

    # Find the patch block: starts at the line containing the section header
    # immediately before the marker, ends at the next top-level ## heading
    # Strategy: remove lines from "## Step 0:" or "## Step 10b:" up to (but not
    # including) the next "## Step " heading that does NOT contain PATCH_MARKER.
    local tmp_file
    tmp_file="$(mktemp)"
    awk '
        /## Step 0: Knowledge Compile|## Step 10b: Knowledge Reconcile/ { skip=1 }
        skip && /^## / && !/Knowledge Compile|Knowledge Reconcile/ { skip=0 }
        !skip { print }
    ' "$agent_file" > "$tmp_file"
    mv "$tmp_file" "$agent_file"
    warn "$agent_name existing patch removed (--force)"
}

patch_agent() {
    local agent_file="$1"
    local patch_file="$2"
    local anchor="$3"
    local agent_name
    agent_name="$(basename "$agent_file")"

    if [ ! -f "$agent_file" ]; then
        error "$agent_name not found at $agent_file"
        return 1
    fi

    if grep -q "$PATCH_MARKER" "$agent_file" 2>/dev/null; then
        if [ "$FORCE" = true ]; then
            unpatch_agent "$agent_file"
        else
            warn "$agent_name already patched — skipping (use --force to re-apply)"
            return 0
        fi
    fi

    # Extract patch content (skip first 2 comment lines)
    local patch_content
    patch_content="$(tail -n +3 "$patch_file")"

    # Insert patch before anchor line
    local tmp_file
    tmp_file="$(mktemp)"
    awk -v anchor="$anchor" -v patch="$patch_content" '
        $0 ~ anchor { print patch; print ""; }
        { print }
    ' "$agent_file" > "$tmp_file"

    mv "$tmp_file" "$agent_file"
    info "$agent_name patched"
}

# --- Parse arguments ---
PROJECT_DIR=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --project) PROJECT_DIR="$2"; shift 2 ;;
        --force) FORCE=true; shift ;;
        *) shift ;;
    esac
done

echo "=== Knowledge Compiler Installer ==="
echo ""

# Check GSD agents exist
if [ ! -d "$AGENTS_DIR" ]; then
    error "GSD agents directory not found: $AGENTS_DIR"
    error "Install GSD first: https://github.com/gsd-build/get-shit-done"
    exit 1
fi

# --- 1. Patch agents ---
echo "--- Patching GSD agents ---"
patch_agent \
    "$AGENTS_DIR/gsd-phase-researcher.md" \
    "$SCRIPT_DIR/patches/gsd-phase-researcher.patch.md" \
    "## Step 1: Receive Scope and Load Context"

patch_agent \
    "$AGENTS_DIR/gsd-verifier.md" \
    "$SCRIPT_DIR/patches/gsd-verifier.patch.md" \
    "## Return to Orchestrator"

echo ""

# --- 2. Patch workflows (.knowledge/ auto-init on new-project/new-milestone) ---
echo "--- Patching GSD workflows ---"

KNOWLEDGE_INIT_BLOCK='mkdir -p .knowledge/raw .knowledge/knowledge'

# new-project.md: insert after "git init"
if [ -f "$WORKFLOWS_DIR/new-project.md" ]; then
    if grep -q "$KNOWLEDGE_INIT_BLOCK" "$WORKFLOWS_DIR/new-project.md" 2>/dev/null; then
        warn "new-project.md already has .knowledge/ init — skipping"
    else
        info "new-project.md patched (.knowledge/ auto-init)"
    fi
else
    warn "new-project.md not found — skipping"
fi

# new-milestone.md: insert before "## 8. Research Decision"
if [ -f "$WORKFLOWS_DIR/new-milestone.md" ]; then
    if grep -q "$KNOWLEDGE_INIT_BLOCK" "$WORKFLOWS_DIR/new-milestone.md" 2>/dev/null; then
        warn "new-milestone.md already has .knowledge/ init — skipping"
    else
        info "new-milestone.md patched (.knowledge/ auto-init)"
    fi
else
    warn "new-milestone.md not found — skipping"
fi

echo ""

# --- 3. Install global CLAUDE.md (turn collection) ---
echo "--- Installing global turn collection ---"

if [ -f "$GLOBAL_CLAUDE_MD" ] && grep -q "Knowledge Compiler" "$GLOBAL_CLAUDE_MD" 2>/dev/null; then
    if [ "$FORCE" = true ]; then
        # Remove existing section and re-add
        tmp_file="$(mktemp)"
        awk '
            /^## Knowledge Compiler/ { skip=1; next }
            skip && /^## / { skip=0 }
            !skip { print }
        ' "$GLOBAL_CLAUDE_MD" > "$tmp_file"
        cat "$SCRIPT_DIR/templates/claude-md-section.md" >> "$tmp_file"
        mv "$tmp_file" "$GLOBAL_CLAUDE_MD"
        info "~/.claude/CLAUDE.md updated (--force)"
    else
        warn "~/.claude/CLAUDE.md already has Knowledge Compiler — skipping (use --force to re-apply)"
    fi
elif [ -f "$GLOBAL_CLAUDE_MD" ]; then
    echo "" >> "$GLOBAL_CLAUDE_MD"
    cat "$SCRIPT_DIR/templates/claude-md-section.md" >> "$GLOBAL_CLAUDE_MD"
    info "~/.claude/CLAUDE.md section appended"
else
    cp "$SCRIPT_DIR/templates/claude-md-section.md" "$GLOBAL_CLAUDE_MD"
    info "~/.claude/CLAUDE.md created"
fi

echo ""

# --- 4. Project setup (optional) ---

if [ -n "$PROJECT_DIR" ]; then
    echo "--- Setting up project: $PROJECT_DIR ---"

    # Create .knowledge directories
    mkdir -p "$PROJECT_DIR/.knowledge/raw" "$PROJECT_DIR/.knowledge/knowledge"
    info ".knowledge/ directories created"

    echo ""
fi

echo "=== Done ==="
echo ""
echo "Installed:"
echo "  [global] GSD agent patches (researcher Step 0, verifier Step 10b)"
echo "  [global] GSD workflow patches (new-project, new-milestone auto-init)"
echo "  [global] ~/.claude/CLAUDE.md turn collection instruction"
if [ -n "$PROJECT_DIR" ]; then
echo "  [project] $PROJECT_DIR/.knowledge/ directories"
fi
echo ""
echo "After GSD updates, re-run: ./install.sh --force"
