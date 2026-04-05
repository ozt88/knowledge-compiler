#!/bin/bash
# Knowledge Compiler installer for GSD
# Usage: ./install.sh [--project /path/to/project]
#
# What it does:
#   1. Patches ~/.claude/agents/gsd-phase-researcher.md (Step 0: incremental compile)
#   2. Patches ~/.claude/agents/gsd-verifier.md (Step 10b: full reconcile)
#   3. Optionally sets up a project with .knowledge/ and CLAUDE.md section

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTS_DIR="$HOME/.claude/agents"
PATCH_MARKER="PATCH:knowledge-compiler"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()  { echo -e "${GREEN}[✓]${NC} $1"; }
warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1"; }

# --- Agent patching ---

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
        warn "$agent_name already patched — skipping"
        return 0
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

echo "=== Knowledge Compiler Installer ==="
echo ""

# Check GSD agents exist
if [ ! -d "$AGENTS_DIR" ]; then
    error "GSD agents directory not found: $AGENTS_DIR"
    error "Install GSD first: https://github.com/gsd-build/get-shit-done"
    exit 1
fi

# Patch agents
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

# --- Project setup (optional) ---

PROJECT_DIR=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --project) PROJECT_DIR="$2"; shift 2 ;;
        *) shift ;;
    esac
done

if [ -n "$PROJECT_DIR" ]; then
    echo "--- Setting up project: $PROJECT_DIR ---"

    # Create .knowledge directories
    mkdir -p "$PROJECT_DIR/.knowledge/raw" "$PROJECT_DIR/.knowledge/knowledge"
    info ".knowledge/ directories created"

    # Check if CLAUDE.md section already exists
    if [ -f "$PROJECT_DIR/CLAUDE.md" ] && grep -q "Knowledge Compiler" "$PROJECT_DIR/CLAUDE.md" 2>/dev/null; then
        warn "CLAUDE.md already has Knowledge Compiler section — skipping"
    elif [ -f "$PROJECT_DIR/CLAUDE.md" ]; then
        echo "" >> "$PROJECT_DIR/CLAUDE.md"
        cat "$SCRIPT_DIR/templates/claude-md-section.md" >> "$PROJECT_DIR/CLAUDE.md"
        info "CLAUDE.md section appended"
    else
        cp "$SCRIPT_DIR/templates/claude-md-section.md" "$PROJECT_DIR/CLAUDE.md"
        info "CLAUDE.md created with Knowledge Compiler section"
    fi

    echo ""
fi

echo "=== Done ==="
echo ""
echo "Next steps:"
echo "  - If you didn't use --project, add the CLAUDE.md section manually"
echo "  - Copy templates/claude-md-section.md content into your project's CLAUDE.md"
echo "  - Create .knowledge/raw/ and .knowledge/knowledge/ in your project"
echo ""
echo "After GSD updates, re-run this script to reapply patches."
