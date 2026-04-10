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

   **raw 항목 선별 기준 — knowledge에 포함하는 항목:**
   - 미래 세션에서 동일한 실수를 방지하는 결정 또는 기술적 발견
   - 시스템 동작, 제약, 설계 원칙에 대한 구조적 지식
   - 재발 가능한 에러와 그 해결 방법
   - 프로젝트 상태를 변화시킨 주요 완료 이벤트 (Phase 완료, 설계 결정 등)

   **건너뛰는 항목:**
   - 일회성 확인 작업 또는 상태 점검 (진행 상황 확인, 단순 조회)
   - 결과 없이 종료된 단순 탐색 시도
   - 이미 포함된 항목의 중복 기록

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
   - `index.md` — 다음 형식으로 생성한다:
     - 맨 위에 "Last compiled", "Total entries" 메타 정보
     - "Quick Reference" 테이블: 주제 | 파일 | 핵심 항목
       (에이전트가 index.md만 읽어도 어떤 파일로 갈지 알 수 있도록)
     - 전체 요약 단락
     - 키워드 인덱스 (키워드 → 파일#섹션)

   분류 기준: 대안이 하나로 확정되는가?
   - YES → `guardrails.md`에 긍정형 액션으로 기술
   - NO (상황에 따라 달라짐) → `anti-patterns.md`에 관찰-이유-대신 구조로 기술

   기존 `anti-patterns.md`가 존재하는 경우:
   - 모든 항목을 읽어 위 분류 기준 적용
     - 대안이 하나로 확정 → `guardrails.md`에 긍정형 액션으로 재기술
     - 상황에 따라 달라짐 → `anti-patterns.md`에 관찰-이유-대신 구조로 재형식화
   - 마이그레이션 완료 후 `guardrails.md`를 신규 생성하고 `anti-patterns.md`를 새 형식으로 덮어쓴다
5. 기존 knowledge 파일을 읽은 뒤 새 항목을 추가하거나 기존 항목을 업데이트하여 병합하라

**During research (Step 3):** knowledge/ 조회 순서:
- `decisions.md` — `[rejected]` 항목을 확인하고 대안 접근법을 선택하라
- `anti-patterns.md` — 목록을 확인하고 연구 추천에서 검증된 패턴을 우선 적용하라
- `troubleshooting.md` — 이미 해결된 문제를 확인하고 새로운 미해결 문제에 집중하라

**조회 순서:** index.md를 먼저 읽어 현재 Phase와 관련된 파일을 파악한 후, 해당 파일만 선택적으로 Read하라.
