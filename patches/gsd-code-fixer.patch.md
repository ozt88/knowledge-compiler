<!-- PATCH:knowledge-compiler for gsd-code-fixer.md -->
<!-- Insert INSIDE: <project_context> block, BEFORE </project_context> -->

<!-- PATCH:knowledge-compiler — reapply after GSD updates -->

**Project knowledge:** Check if `.knowledge/knowledge/` exists in the working directory.

**Skip condition:** If `.knowledge/knowledge/` does not exist or `index.md` is missing, skip this step.

**If knowledge/ exists:**

1. Read `.knowledge/knowledge/index.md` to get the "Quick Reference" table and keyword index.
2. Selectively read relevant files:
   - `anti-patterns.md` — When fixing, apply the "Instead" recommendation as the target pattern.
   - `guardrails.md` — Fixes must satisfy all guardrail constraints. A fix that violates a guardrail is worse than the original bug.
   - `decisions.md` — Check `[rejected]` entries before choosing a fix approach. Use the documented alternative.
   - `troubleshooting.md` — If a known workaround applies to the fix context, apply it preemptively.

3. Embed knowledge in fix rationale: `"Fixed using pattern from knowledge/anti-patterns.md"` or `"Avoided [X] per knowledge/decisions.md [rejected]"`.

**Lookup order:** Always read `index.md` first. Only load individual files when their Quick Reference entry is relevant to the fixes being applied.
