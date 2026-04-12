<!-- PATCH:knowledge-compiler for gsd-nyquist-auditor.md -->
<!-- Insert BEFORE: <step name="load_context"> -->

<!-- PATCH:knowledge-compiler — reapply after GSD updates -->

<project_knowledge>
**Project knowledge:** Check if `.knowledge/knowledge/` exists in the working directory before analyzing gaps.

**Skip condition:** If `.knowledge/knowledge/` does not exist or `index.md` is missing, skip this step.

**If knowledge/ exists:**

1. Read `.knowledge/knowledge/index.md` to get the "Quick Reference" table and keyword index.
2. Selectively read relevant files:
   - `guardrails.md` — Required testing constraints (mandated frameworks, coverage thresholds, forbidden test patterns). Generated tests must comply.
   - `anti-patterns.md` — Known test anti-patterns to avoid when generating tests.
   - `decisions.md` — Check `[rejected]` entries for testing approach decisions (e.g., rejected mocking strategies, rejected frameworks).

3. Apply knowledge when generating tests: use mandated frameworks, avoid rejected patterns, meet guardrail coverage requirements.

**Lookup order:** Always read `index.md` first. Only load individual files when their Quick Reference entry is relevant to the test domain.
</project_knowledge>

