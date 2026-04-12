<!-- PATCH:knowledge-compiler for gsd-code-reviewer.md -->
<!-- Insert INSIDE: <project_context> block, BEFORE </project_context> -->

<!-- PATCH:knowledge-compiler — reapply after GSD updates -->

**Project knowledge:** Check if `.knowledge/knowledge/` exists in the working directory.

**Skip condition:** If `.knowledge/knowledge/` does not exist or `index.md` is missing, skip this step.

**If knowledge/ exists:**

1. Read `.knowledge/knowledge/index.md` to get the "Quick Reference" table and keyword index.
2. Selectively read relevant files:
   - `anti-patterns.md` — Flag code that matches a known anti-pattern. Reference the "Instead" recommendation in your finding.
   - `guardrails.md` — Treat entries as hard constraints. Code violating a guardrail is a HIGH severity finding regardless of other context.
   - `decisions.md` — Check `[rejected]` entries. Code using a rejected approach is a finding: note the documented alternative.
   - `troubleshooting.md` — If a known issue applies to code being reviewed, note it as a risk even if not yet triggered.

3. Reference knowledge sources in findings: `"per knowledge/guardrails.md: [rule]"` or `"known anti-pattern per knowledge/anti-patterns.md"`.

**Lookup order:** Always read `index.md` first. Only load individual files when their Quick Reference entry is relevant to the code under review.
