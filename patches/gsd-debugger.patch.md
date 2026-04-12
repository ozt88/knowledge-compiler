<!-- PATCH:knowledge-compiler for gsd-debugger.md -->
<!-- Insert AFTER: </philosophy> -->

<!-- PATCH:knowledge-compiler — reapply after GSD updates -->

<project_knowledge>
**Project knowledge:** Check if `.knowledge/knowledge/` exists in the working directory before starting investigation.

**Skip condition:** If `.knowledge/knowledge/` does not exist or `index.md` is missing, skip this step.

**If knowledge/ exists:**

1. Read `.knowledge/knowledge/index.md` to get the "Quick Reference" table and keyword index.
2. Prioritize reading:
   - `troubleshooting.md` — Check if the reported symptom matches a known issue. If it does, apply the documented solution directly instead of re-investigating from scratch.
   - `anti-patterns.md` — If the bug looks like a known anti-pattern, note it as the likely root cause hypothesis.
   - `decisions.md` — Check `[rejected]` entries. If the code uses a rejected approach, that may be the root cause.

3. If a troubleshooting entry matches: state it as Hypothesis H0 with HIGH confidence before forming other hypotheses.

**Lookup order:** Always read `index.md` first. `troubleshooting.md` is the highest-value file for debugging — check it before starting the investigation loop.
</project_knowledge>

