<!-- PATCH:knowledge-compiler for gsd-plan-checker.md -->
<!-- Insert INSIDE: <project_context> block, BEFORE </project_context> -->

<!-- PATCH:knowledge-compiler — reapply after GSD updates -->

**Project knowledge:** Check if `.knowledge/knowledge/` exists in the working directory.

**Skip condition:** If `.knowledge/knowledge/` does not exist or `index.md` is missing, skip this step.

**If knowledge/ exists:**

1. Read `.knowledge/knowledge/index.md` to get the "Quick Reference" table and keyword index.
2. Selectively read relevant files:
   - `guardrails.md` — Hard constraints that plan tasks must satisfy. A plan that violates a guardrail should BLOCK regardless of other quality dimensions.
   - `decisions.md` — Check `[rejected]` entries. A plan whose tasks use a rejected approach is a blocking issue.
   - `anti-patterns.md` — Plan tasks prescribing known anti-patterns should be flagged for revision.

3. Add knowledge-derived checks to plan evaluation: `"BLOCK: plan uses [X] which is rejected per knowledge/decisions.md"`.

**Lookup order:** Always read `index.md` first. Only load individual files when their Quick Reference entry is relevant to the plan's domain.
