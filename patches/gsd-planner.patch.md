<!-- PATCH:knowledge-compiler for gsd-planner.md -->
<!-- Insert INSIDE: <project_context> block, AFTER the "Project skills" paragraph -->

<!-- PATCH:knowledge-compiler — reapply after GSD updates -->

**Project knowledge:** Check if `.knowledge/knowledge/` exists in the working directory.

**Skip condition:** If `.knowledge/knowledge/` does not exist or `index.md` is missing, skip this step.

**If knowledge/ exists:**

1. Read `.knowledge/knowledge/index.md` to get the "Quick Reference" table and keyword index.
2. Identify which knowledge files are relevant to the current phase (based on phase name, tech stack, and task keywords).
3. Selectively read only the relevant files from:
   - `decisions.md` — 조회 우선순위:
     - Observed 카운터가 높은 항목 우선 (여러 세션에서 재확인된 결정은 더 신뢰성 높음)
     - `[context: ...]` 태그가 현재 Phase와 일치하는 항목 우선
     - `[rejected]` entries: do NOT plan tasks using rejected approaches
     - `[uncertain]` entries: 이 결정은 불확실 상태 — task action에 "uncertain 결정이므로 구현 전 검증 필요" 명시
     - `[superseded]` entries: 참고 목적으로만 읽고 plan에 반영하지 않음
   - `guardrails.md` — Treat entries as hard constraints; plan tasks must comply
   - `anti-patterns.md` — Treat "Instead" recommendations as preferred patterns in task actions
   - `troubleshooting.md` — If a known problem applies to this phase, include the solution in task actions preemptively

4. Embed knowledge findings directly into task `<action>` blocks:
   - Reference the source: `"per knowledge/guardrails.md: [rule]"` or `"avoiding [anti-pattern] per knowledge/anti-patterns.md"`
   - For rejected decisions: note the alternative in the action — `"Use X (Y was rejected: [reason])"`
   - For uncertain decisions: note in the action — `"Decision Z is [uncertain] — verify before relying on it"`

**Lookup order:** Always read `index.md` first. Only load individual files when their Quick Reference entry is relevant. Never load all knowledge files unconditionally.
