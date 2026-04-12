<!-- PATCH:knowledge-compiler for gsd-executor.md -->
<!-- Insert INSIDE: <project_context> block, BEFORE </project_context> -->

<!-- PATCH:knowledge-compiler — reapply after GSD updates -->

**Project knowledge:** Check if `.knowledge/knowledge/` exists in the working directory.

**Skip condition:** If `.knowledge/knowledge/` does not exist or `index.md` is missing, skip this step.

**If knowledge/ exists:**

1. Read `.knowledge/knowledge/index.md` to get the "Quick Reference" table and keyword index.
2. Identify which knowledge files are relevant to the current phase and task domain.
3. Selectively read only the relevant files from:
   - `troubleshooting.md` — If a known problem applies to this task, apply the documented solution preemptively. Do not rediscover known issues.
   - `guardrails.md` — Treat entries as hard constraints; task implementation must comply.
   - `anti-patterns.md` — Treat "Instead" recommendations as preferred implementation patterns.
   - `decisions.md` — Check `[rejected]` entries; do NOT implement using rejected approaches.

4. Embed knowledge findings directly into task execution:
   - If troubleshooting.md describes a workaround for a tool you're about to use, apply it immediately.
   - For rejected decisions: use the documented alternative.

**Lookup order:** Always read `index.md` first. Only load individual files when their Quick Reference entry is relevant to this phase or task.
