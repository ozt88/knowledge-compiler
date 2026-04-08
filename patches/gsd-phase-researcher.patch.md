<!-- PATCH:knowledge-compiler for gsd-phase-researcher.md -->
<!-- Insert BEFORE: "## Step 1: Receive Scope and Load Context" -->

## Step 0: Knowledge Compile (before research)

<!-- PATCH:knowledge-compiler — reapply after GSD updates -->

Before researching, check if the project has accumulated knowledge from previous sessions.

**Skip condition:** If `.knowledge/raw/` does not exist or is empty, skip to Step 1.

**If raw/ has content:**

1. Read all `.knowledge/raw/*.md` files
2. Check if `.knowledge/knowledge/` exists. If not, create it.
3. Read existing knowledge files (if any): `decisions.md`, `anti-patterns.md`, `troubleshooting.md`, `index.md`
4. Compile new raw entries into knowledge/ structure:
   - `decisions.md` — 시도 → 결과 → 결정. 상태 태그: `[active]`, `[rejected]`, `[superseded]`, `[uncertain]`
   - `guardrails.md` — 대안이 하나로 확정되는 케이스를 긍정형 액션으로 기술한다
     - 형식: "## [주제]\n[긍정형 액션]" (예: "~경유 필수", "~방식 사용")
     - 예시 (절대적 케이스): "## raw/ 읽기\nraw/ 읽기는 knowledge/index.md 경유 필수"
     - 예시 (대안 확정 케이스): "## decisions.md 병합\ndecisions.md는 decisions/ 하위 파일 병합 방식 사용"
   - `anti-patterns.md` — 상황에 따라 달라질 수 있는 맥락 의존적 케이스를 관찰-이유-대신 구조로 기술한다
     - 형식: "## [주제]\n**관찰:** [현상]\n**이유:** [문제 원인]\n**대신:** [권장 접근]"
     - 예시 1: "## 컴파일러 부정형 지시\n**관찰:** knowledge 파일 생성 지시에 '하지 마라' 형식 사용\n**이유:** LLM은 부정형 지시 준수율이 낮아 원치 않는 패턴이 잔존\n**대신:** 긍정형 액션으로 재기술 (Phase 1 전환 원칙 적용)"
     - 예시 2: "## raw/ 파일 직접 쿼리\n**관찰:** index.md를 거치지 않고 raw/*.md를 직접 읽어 분석\n**이유:** 컨텍스트 비용이 높고 관련 없는 정보까지 로드됨\n**대신:** index.md에서 관련 날짜 파악 후 해당 raw 파일만 선택적으로 읽기"
   - `troubleshooting.md` — 에러 메시지 ↔ 해결책 매핑
   - `index.md` — 전체 요약 + 키워드 인덱스

   분류 기준: 대안이 하나로 확정되는가?
   - YES → `guardrails.md`에 긍정형 액션으로 기술
   - NO (상황에 따라 달라짐) → `anti-patterns.md`에 관찰-이유-대신 구조로 기술

   기존 `anti-patterns.md`가 존재하는 경우:
   - 모든 항목을 읽어 위 분류 기준 적용
     - 대안이 하나로 확정 → `guardrails.md`에 긍정형 액션으로 재기술
     - 상황에 따라 달라짐 → `anti-patterns.md`에 관찰-이유-대신 구조로 재형식화
   - 마이그레이션 완료 후 `guardrails.md`를 신규 생성하고 `anti-patterns.md`를 새 형식으로 덮어쓴다
5. 기존 knowledge 파일을 읽은 뒤 새 항목을 추가하거나 기존 항목을 업데이트하여 병합하라

**During research (Step 3):** Also search `.knowledge/knowledge/` for findings relevant to this phase. Especially check:
- `decisions.md` — `[rejected]` 항목을 확인하고 대안 접근법을 선택하라
- `anti-patterns.md` — 목록을 확인하고 연구 추천에서 검증된 패턴을 우선 적용하라
- `troubleshooting.md` — 이미 해결된 문제를 확인하고 새로운 미해결 문제에 집중하라
