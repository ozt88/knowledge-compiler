<!-- PATCH:knowledge-compiler for gsd-verifier.md -->
<!-- Insert BEFORE: "## Return to Orchestrator" -->

## Step 10b: Knowledge Reconcile (after verification)

<!-- PATCH:knowledge-compiler — reapply after GSD updates -->

After writing VERIFICATION.md, reconcile project knowledge from this phase's learnings.

**Skip condition:** If `.knowledge/raw/` does not exist, skip.

**If raw/ exists:**

1. Read all `.knowledge/raw/*.md` files
2. Read existing `.knowledge/knowledge/` files (if any)
3. Full reconcile — reprocess ALL raw entries and rebuild knowledge/:
   - `decisions.md` — 모든 시도/결정 통합, 상태 태그 정합성 확인
   - `anti-patterns.md` — 새로 발견된 anti-pattern 추가
   - `troubleshooting.md` — 에러/해결 매핑 갱신
   - `index.md` — 전체 요약 재생성
4. 충돌하는 `[active]` decision이 있으면 `[uncertain]`으로 표시

**This is a FULL reconcile** (not incremental like Step 0 in researcher). Phase 완료 시점이므로 전체 일관성을 재검증.
