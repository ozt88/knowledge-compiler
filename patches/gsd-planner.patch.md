<!-- PATCH:knowledge-compiler for gsd-planner.md -->
<!-- Insert INSIDE: <project_context> block, AFTER the "Project skills" paragraph -->

**Project knowledge:** Check if `.knowledge/knowledge/` exists in the working directory.

**Skip condition:** If `.knowledge/knowledge/` does not exist or `index.md` is missing, skip this step.

**If knowledge/ exists:**

1. Read `.knowledge/knowledge/index.md` to get the "Quick Reference" table and keyword index.
2. Identify which knowledge files are relevant to the current phase (based on phase name, tech stack, and task keywords).
3. Selectively read only the relevant files from:
   - `decisions.md` — Check `[rejected]` entries; do NOT plan tasks using rejected approaches
   - `guardrails.md` — Treat entries as hard constraints; plan tasks must comply
   - `anti-patterns.md` — Treat "Instead" recommendations as preferred patterns in task actions
   - `troubleshooting.md` — If a known problem applies to this phase, include the solution in task actions preemptively

4. Embed knowledge findings directly into task `<action>` blocks:
   - Reference the source: `"per knowledge/guardrails.md: [rule]"` or `"avoiding [anti-pattern] per knowledge/anti-patterns.md"`
   - For rejected decisions: note the alternative in the action — `"Use X (Y was rejected: [reason])"`

**Lookup order:** Always read `index.md` first. Only load individual files when their Quick Reference entry is relevant. Never load all knowledge files unconditionally.
