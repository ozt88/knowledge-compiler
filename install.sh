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
    local patch_file="$2"
    local agent_name
    agent_name="$(basename "$agent_file")"

    if ! grep -q "$PATCH_MARKER" "$agent_file" 2>/dev/null; then
        return 0
    fi

    # Remove ALL occurrences of the patch content from the agent file.
    # Strategy: remove every line that matches the patch marker comment,
    # plus the exact number of lines that follow each marker (patch body size).
    local patch_content
    patch_content="$(tail -n +3 "$patch_file")"
    local patch_line_count
    patch_line_count=$(echo "$patch_content" | wc -l)

    local tmp_file
    tmp_file="$(mktemp)"
    # Remove each patch block: detect marker line by index(), skip lines after it.
    # patch_content structure (tail -n +3): blank(line1), MARKER(line2), content(line3..N).
    # patch_agent inserts all block_size lines then adds one trailing blank (print "").
    # The MARKER line itself is consumed by next. After next, remaining lines to skip:
    #   (block_size - 2) content lines after marker + 1 trailing blank = block_size - 1.
    # When already skipping, ignore nested markers (patch content may contain the marker string).
    awk -v marker="<!-- ${PATCH_MARKER}" -v block_size="$patch_line_count" '
        skip == 0 && index($0, marker) > 0 { skip = block_size - 1; next }
        skip > 0 { skip--; next }
        { print }
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
        warn "$agent_name not found at $agent_file — skipping"
        return 0
    fi

    if grep -q "$PATCH_MARKER" "$agent_file" 2>/dev/null; then
        if [ "$FORCE" = true ]; then
            unpatch_agent "$agent_file" "$patch_file"
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

# --- Workflow patching ---
patch_workflow() {
    local workflow_file="$1"
    local patch_file="$2"
    local anchor="$3"
    local workflow_name
    workflow_name="$(basename "$workflow_file")"

    if [ ! -f "$workflow_file" ]; then
        warn "$workflow_name not found at $workflow_file — skipping"
        return 0
    fi

    if grep -q "$PATCH_MARKER" "$workflow_file" 2>/dev/null; then
        if [ "$FORCE" = true ]; then
            # Remove ALL occurrences of the patch content from the workflow file.
            local patch_content_rm
            patch_content_rm="$(tail -n +3 "$patch_file")"
            local patch_line_count_rm
            patch_line_count_rm=$(echo "$patch_content_rm" | wc -l)

            local tmp_file
            tmp_file="$(mktemp)"
            awk -v marker="<!-- ${PATCH_MARKER}" -v block_size="$patch_line_count_rm" '
                skip == 0 && index($0, marker) > 0 { skip = block_size - 1; next }
                skip > 0 { skip--; next }
                { print }
            ' "$workflow_file" > "$tmp_file"
            mv "$tmp_file" "$workflow_file"
            warn "$workflow_name existing patch removed (--force)"
        else
            warn "$workflow_name already patched — skipping (use --force to re-apply)"
            return 0
        fi
    fi

    local patch_content
    patch_content="$(tail -n +3 "$patch_file")"

    local tmp_file
    tmp_file="$(mktemp)"
    awk -v anchor="$anchor" -v patch="$patch_content" '
        $0 ~ anchor { print patch; print ""; }
        { print }
    ' "$workflow_file" > "$tmp_file"
    mv "$tmp_file" "$workflow_file"
    info "$workflow_name patched"
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
    "$AGENTS_DIR/gsd-planner.md" \
    "$SCRIPT_DIR/patches/gsd-planner.patch.md" \
    "</project_context>"

patch_agent \
    "$AGENTS_DIR/gsd-executor.md" \
    "$SCRIPT_DIR/patches/gsd-executor.patch.md" \
    "</project_context>"

patch_agent \
    "$AGENTS_DIR/gsd-code-reviewer.md" \
    "$SCRIPT_DIR/patches/gsd-code-reviewer.patch.md" \
    "</project_context>"

patch_agent \
    "$AGENTS_DIR/gsd-code-fixer.md" \
    "$SCRIPT_DIR/patches/gsd-code-fixer.patch.md" \
    "</project_context>"

patch_agent \
    "$AGENTS_DIR/gsd-plan-checker.md" \
    "$SCRIPT_DIR/patches/gsd-plan-checker.patch.md" \
    "</project_context>"

patch_agent \
    "$AGENTS_DIR/gsd-debugger.md" \
    "$SCRIPT_DIR/patches/gsd-debugger.patch.md" \
    "</philosophy>"

patch_agent \
    "$AGENTS_DIR/gsd-nyquist-auditor.md" \
    "$SCRIPT_DIR/patches/gsd-nyquist-auditor.patch.md" \
    "<step name=\"load_context\">"

echo ""

# --- 2. Patch workflows (.knowledge/ auto-init on new-project/new-milestone) ---
echo "--- Patching GSD workflows ---"

KNOWLEDGE_INIT_BLOCK='mkdir -p .knowledge/raw .knowledge/knowledge'

# discuss-phase.md: knowledge lookup before cross_reference_todos (after init/antipattern checks)
patch_workflow \
    "$WORKFLOWS_DIR/discuss-phase.md" \
    "$SCRIPT_DIR/patches/gsd-discuss-phase.patch.md" \
    "<step name=\"cross_reference_todos\">"

# new-project.md: insert after "git init"
if [ -f "$WORKFLOWS_DIR/new-project.md" ]; then
    if grep -q "$KNOWLEDGE_INIT_BLOCK" "$WORKFLOWS_DIR/new-project.md" 2>/dev/null; then
        warn "new-project.md already has .knowledge/ init — skipping"
    else
        local tmp_file
        tmp_file="$(mktemp)"
        awk -v block="$KNOWLEDGE_INIT_BLOCK" '
            /^git init$/ { print; print block; next }
            { print }
        ' "$WORKFLOWS_DIR/new-project.md" > "$tmp_file"
        mv "$tmp_file" "$WORKFLOWS_DIR/new-project.md"
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
        local tmp_file
        tmp_file="$(mktemp)"
        awk -v block="$KNOWLEDGE_INIT_BLOCK" '
            /^## 8\. Research Decision$/ { print block; print ""; }
            { print }
        ' "$WORKFLOWS_DIR/new-milestone.md" > "$tmp_file"
        mv "$tmp_file" "$WORKFLOWS_DIR/new-milestone.md"
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

# --- 4. Install GSD skills ---
echo "--- Installing GSD skills ---"

SKILLS_DIR="$HOME/.claude/skills"
mkdir -p "$SKILLS_DIR"

install_skill() {
    local skill_name="$1"
    local skill_src="$SCRIPT_DIR/skills/$skill_name/SKILL.md"
    local skill_dst="$SKILLS_DIR/$skill_name/SKILL.md"

    if [ ! -f "$skill_src" ]; then
        warn "Skill $skill_name not found at $skill_src — skipping"
        return 0
    fi

    mkdir -p "$SKILLS_DIR/$skill_name"
    if [ -f "$skill_dst" ] && [ "$FORCE" = false ]; then
        warn "$skill_name already installed — skipping (use --force to re-install)"
    else
        cp "$skill_src" "$skill_dst"
        info "$skill_name installed"
    fi
}

install_skill "gsd-knowledge-compile"
echo ""

# --- 5. Project setup (optional) ---

if [ -n "$PROJECT_DIR" ]; then
    echo "--- Setting up project: $PROJECT_DIR ---"

    # Create .knowledge directories
    mkdir -p "$PROJECT_DIR/.knowledge/raw" "$PROJECT_DIR/.knowledge/knowledge"
    info ".knowledge/ directories created"

    # Seed knowledge files (skip if already exist)
    SEED_DIR="$SCRIPT_DIR/templates/knowledge-seed"
    if [ -d "$SEED_DIR" ]; then
        seeded=0
        for seed_file in "$SEED_DIR"/*.md; do
            fname="$(basename "$seed_file")"
            dst="$PROJECT_DIR/.knowledge/knowledge/$fname"
            if [ ! -f "$dst" ]; then
                cp "$seed_file" "$dst"
                seeded=$((seeded + 1))
            fi
        done
        if [ "$seeded" -gt 0 ]; then
            info "knowledge seed files copied ($seeded files)"
        else
            warn "knowledge seed files already exist — skipping"
        fi
    fi

    echo ""
fi

echo "=== Done ==="
echo ""
echo "Installed:"
echo "  [global] GSD agent patches (researcher Step 3 lookup, verifier Step 10b, planner fallback compile + lookup)"
echo "  [global] GSD workflow patches (new-project, new-milestone auto-init)"
echo "  [global] discuss-phase knowledge lookup"
echo "  [global] GSD skills (gsd-knowledge-compile)"
echo "  [global] ~/.claude/CLAUDE.md turn collection instruction"
if [ -n "$PROJECT_DIR" ]; then
echo "  [project] $PROJECT_DIR/.knowledge/ directories + seed files"
fi
echo ""
echo "After GSD updates, re-run: ./install.sh --force"
