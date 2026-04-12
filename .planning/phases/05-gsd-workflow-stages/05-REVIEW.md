---
phase: 05-gsd-workflow-stages
reviewed: 2026-04-12T00:00:00Z
depth: standard
files_reviewed: 6
files_reviewed_list:
  - install.sh
  - patches/gsd-discuss-phase.patch.md
  - patches/gsd-phase-researcher.patch.md
  - patches/gsd-planner.patch.md
  - skills/gsd-clear/skill.md
  - skills/gsd-knowledge-compile/skill.md
findings:
  critical: 0
  warning: 4
  info: 3
  total: 7
status: issues_found
---

# Phase 05: Code Review Report

**Reviewed:** 2026-04-12
**Depth:** standard
**Files Reviewed:** 6
**Status:** issues_found

## Summary

Reviewed the install.sh installer script, three patch files (discuss-phase, phase-researcher, planner), and two skill definitions (gsd-clear, gsd-knowledge-compile).

The patch files and skill definitions are well-structured specification documents with no functional defects. The main issues are in `install.sh`: two stubs that log a success message without performing any actual file modification (new-project.md and new-milestone.md handlers), an awk multi-line variable injection that silently produces broken output on patch content containing special characters, and a minor indentation defect in the final echo block.

## Warnings

### WR-01: new-project.md and new-milestone.md handlers never actually patch the files

**File:** `install.sh:192-211`
**Issue:** Both `if` branches for new-project.md and new-milestone.md reach the `else` arm (file exists, block not yet present) and call `info "... patched"` — but no insertion is ever performed. There is no `awk` or `sed` invocation in these branches. The installer prints a success message while leaving the files unmodified.

The `KNOWLEDGE_INIT_BLOCK` variable (line 183) is defined but used only as a grep search string, never as content to insert.

**Fix:** Implement the actual insertion, mirroring the `patch_workflow` helper, e.g.:
```bash
# new-project.md: insert after "git init"
if [ -f "$WORKFLOWS_DIR/new-project.md" ]; then
    if grep -q "$KNOWLEDGE_INIT_BLOCK" "$WORKFLOWS_DIR/new-project.md" 2>/dev/null; then
        warn "new-project.md already has .knowledge/ init — skipping"
    else
        local tmp_file
        tmp_file="$(mktemp)"
        awk -v block="$KNOWLEDGE_INIT_BLOCK" '
            /git init/ { print; print block; next }
            { print }
        ' "$WORKFLOWS_DIR/new-project.md" > "$tmp_file"
        mv "$tmp_file" "$WORKFLOWS_DIR/new-project.md"
        info "new-project.md patched (.knowledge/ auto-init)"
    fi
fi
```
Apply the same pattern for new-milestone.md with the appropriate anchor.

---

### WR-02: awk `-v` does not preserve newlines in multi-line patch content

**File:** `install.sh:88-91` (also `install.sh:133-136`)
**Issue:** `patch_content` is a multi-line string captured via command substitution. Passing it as an awk `-v` variable collapses all newlines to spaces because awk `-v` does not support literal newlines in variable values. The inserted patch block will be rendered as a single long line rather than as structured multi-line Markdown.

```bash
# This silently flattens newlines:
awk -v patch="$patch_content" '...' file
```

**Fix:** Write the patch content to a temporary file and read it inside awk using `getline`, or use a here-doc approach:
```bash
local patch_tmp
patch_tmp="$(mktemp)"
printf '%s\n' "$patch_content" > "$patch_tmp"

awk -v anchor="$anchor" -v pfile="$patch_tmp" '
    $0 ~ anchor {
        while ((getline line < pfile) > 0) print line
        print ""
    }
    { print }
' "$agent_file" > "$tmp_file"
rm -f "$patch_tmp"
```
The same fix applies to `patch_workflow` at line 133.

---

### WR-03: `unpatch_agent` awk pattern can remove unrelated sections with matching headings

**File:** `install.sh:51-55`
**Issue:** The awk script in `unpatch_agent` starts removal on any line matching `## Step 0: Knowledge Compile|## Step 10b: Knowledge Reconcile` and stops at the next `## ` heading that does not contain those strings. If the agent file contains a heading like `## Step 0: Knowledge Compile (Deprecated)` or similar, the removal would still trigger correctly, but more importantly the stop condition `!/Knowledge Compile|Knowledge Reconcile/` means a heading containing either of those words would be consumed rather than restored, potentially eating a legitimate following section if headings are renamed in future GSD updates.

The `patch_workflow` force-remove at lines 115-120 uses a different (marker-line–based) strategy and does not have the same fragility, but neither approach validates the removed block length or echoes what was removed.

**Fix:** Use the `PATCH_MARKER` sentinel for `unpatch_agent` too, consistent with `patch_workflow`:
```bash
unpatch_agent() {
    local agent_file="$1"
    if ! grep -q "$PATCH_MARKER" "$agent_file" 2>/dev/null; then return 0; fi
    local tmp_file
    tmp_file="$(mktemp)"
    awk -v marker="$PATCH_MARKER" '
        $0 ~ marker { skip=1; next }
        skip && /^## / { skip=0 }
        !skip { print }
    ' "$agent_file" > "$tmp_file"
    mv "$tmp_file" "$agent_file"
    warn "$(basename "$agent_file") existing patch removed (--force)"
}
```
This requires the patch files to include the marker string in a comment on the first inserted line (which `gsd-phase-researcher.patch.md` and `gsd-planner.patch.md` already do on line 4).

---

### WR-04: `patch_agent` inserts the patch block BEFORE the anchor line, not AFTER, contradicting gsd-planner.patch.md intent

**File:** `install.sh:88-91`
**Issue:** The awk rule `$0 ~ anchor { print patch; print ""; }` followed by `{ print }` prints the patch content before printing the anchor line. For `gsd-phase-researcher.md` the anchor is `## Step 1:`, so the patch appears before Step 1 — which is intentional per the patch comment "Insert BEFORE".

However for `gsd-planner.md` the anchor is `</project_context>` and the patch comment reads "Insert INSIDE: `<project_context>` block, AFTER the 'Project skills' paragraph". With the current awk logic the content is inserted before `</project_context>` — the closing tag — which is actually correct positioning, but the patch file's own instruction says "Insert INSIDE… AFTER the Project skills paragraph", implying it should land somewhere in the middle of the block, not immediately before the closing tag. If the intent changes, the single shared insertion mechanism cannot accommodate both "before anchor" and "after anchor" semantics without a parameter.

**Fix:** Either document explicitly that the anchor is always the line that immediately follows the desired insertion point (making the behavior consistent), or add an `--after` flag to `patch_agent`/`patch_workflow` to support both modes:
```bash
patch_agent "$file" "$patch" "$anchor" "before"   # current default
patch_agent "$file" "$patch" "$anchor" "after"    # inserts after anchor
```

---

## Info

### IN-01: Final echo block has inconsistent indentation

**File:** `install.sh:293-295`
**Issue:** The conditional `echo` inside `if [ -n "$PROJECT_DIR" ]` is not indented:
```bash
if [ -n "$PROJECT_DIR" ]; then
echo "  [project] $PROJECT_DIR/.knowledge/ directories"
fi
```
All other echo statements in the script are consistently indented with two spaces inside conditionals.

**Fix:**
```bash
if [ -n "$PROJECT_DIR" ]; then
    echo "  [project] $PROJECT_DIR/.knowledge/ directories"
fi
```

---

### IN-02: `tail -n +3` to strip patch file header is fragile

**File:** `install.sh:83` and `install.sh:129`
**Issue:** The patch content extraction skips the first two lines assuming they are always HTML comment lines. If a patch file is ever edited and the header grows to 3 lines (or the comments are removed), the wrong content will be injected silently.

**Fix:** Strip lines matching the HTML comment pattern explicitly rather than relying on a fixed line count:
```bash
patch_content="$(grep -v '^<!-- ' "$patch_file")"
```
Or define a dedicated delimiter in the patch format (e.g., `---`) to mark where insertable content begins.

---

### IN-03: gsd-planner.patch.md — PATCH_MARKER comment is placed after the content, not before it

**File:** `patches/gsd-planner.patch.md:6`
**Issue:** The marker comment `<!-- PATCH:knowledge-compiler — reapply after GSD updates -->` appears on line 6, after two lines of actual content (lines 4-5). In `gsd-phase-researcher.patch.md` the marker is on line 4 (before content). This inconsistency means the `unpatch_agent` grep check (`grep -q "$PATCH_MARKER"`) will still find the marker in both files, but if the removal awk logic ever keys on the marker's position relative to content, the two patch files will behave differently.

**Fix:** Move the marker to the first inserted line in all patch files, consistent with `gsd-phase-researcher.patch.md`:
```markdown
<!-- PATCH:knowledge-compiler — reapply after GSD updates -->

**Knowledge compile (fallback):** ...
```

---

_Reviewed: 2026-04-12_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
