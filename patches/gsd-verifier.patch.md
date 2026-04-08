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
   - `guardrails.md` — 대안이 하나로 확정되는 케이스를 긍정형 액션으로 기술한다
     - 형식: "## [주제]\n[긍정형 액션]" (예: "~경유 필수", "~방식 사용")
     - 예시 (절대적 케이스): "## raw/ 읽기\nraw/ 읽기는 knowledge/index.md 경유 필수"
     - 예시 (대안 확정 케이스): "## decisions.md 병합\ndecisions.md는 decisions/ 하위 파일 병합 방식 사용"
   - `anti-patterns.md` — 상황에 따라 달라질 수 있는 맥락 의존적 케이스를 관찰-이유-대신 구조로 기술한다
     - 형식: "## [주제]\n**관찰:** [현상]\n**이유:** [문제 원인]\n**대신:** [권장 접근]"
     - 예시 1: "## 컴파일러 부정형 지시\n**관찰:** knowledge 파일 생성 지시에 '하지 마라' 형식 사용\n**이유:** LLM은 부정형 지시 준수율이 낮아 원치 않는 패턴이 잔존\n**대신:** 긍정형 액션으로 재기술 (Phase 1 전환 원칙 적용)"
     - 예시 2: "## raw/ 파일 직접 쿼리\n**관찰:** index.md를 거치지 않고 raw/*.md를 직접 읽어 분석\n**이유:** 컨텍스트 비용이 높고 관련 없는 정보까지 로드됨\n**대신:** index.md에서 관련 날짜 파악 후 해당 raw 파일만 선택적으로 읽기"
   - `troubleshooting.md` — 에러/해결 매핑 갱신
   - `index.md` — 전체 요약 재생성

   분류 기준: 대안이 하나로 확정되는가?
   - YES → `guardrails.md`에 긍정형 액션으로 기술
   - NO (상황에 따라 달라짐) → `anti-patterns.md`에 관찰-이유-대신 구조로 기술

   기존 `anti-patterns.md`가 존재하는 경우:
   - 모든 항목을 읽어 위 분류 기준 적용
     - 대안이 하나로 확정 → `guardrails.md`에 긍정형 액션으로 재기술
     - 상황에 따라 달라짐 → `anti-patterns.md`에 관찰-이유-대신 구조로 재형식화
   - 마이그레이션 완료 후 `guardrails.md`를 신규 생성하고 `anti-patterns.md`를 새 형식으로 덮어쓴다
4. 충돌하는 `[active]` decision이 있으면 `[uncertain]`으로 표시

**This is a FULL reconcile** (not incremental like Step 0 in researcher). Phase 완료 시점이므로 전체 일관성을 재검증.
