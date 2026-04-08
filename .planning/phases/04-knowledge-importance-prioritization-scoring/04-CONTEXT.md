# Phase 4: Knowledge Importance Prioritization Scoring - Context

**Gathered:** 2026-04-09
**Status:** Ready for planning

<domain>
## Phase Boundary

`knowledge` 시스템에서 **쿼리 시점의 관련성 기반 접근 메커니즘**을 도입하는 것.

researcher/planner 서브에이전트가 knowledge를 조회할 때, 해당 쿼리에 가장 관련성 높은 항목을 효과적으로 찾을 수 있게 한다.

**범위 밖:**
- 새로운 수집 방식 추가
- 컴파일러 프롬프트 긍정형 전환 (Phase 1-3에서 완료)
- 벡터/MCP 인프라 도입 (Out of Scope)
- 사람이 수동으로 중요도를 마킹하는 방식

</domain>

<decisions>
## Implementation Decisions

### Phase 성격 및 접근 방식
- **D-01:** 이 Phase는 **리서치 우선 → 설계 → 구현** 순서로 진행한다.
  - Requirements가 TBD — RAG/IR 연구에서 접근법 학습 후 구체적 설계 결정
  - 리서치 없이 구현 방향을 확정하지 않는다
- **D-02:** 탐색과 구현 모두 이 Phase에서 완료한다 (별도 Phase 분리 없음).

### 중요도 철학
- **D-03:** "중요도는 쿼리 시점에 결정된다" — 정적 사전 스코어링이 아닌 **쿼리 기반 관련성** 모델을 채택한다.
  - raw 항목을 저장할 때 중요도를 마킹하지 않는다
  - researcher/planner가 지식을 조회할 때 현재 컨텍스트와의 관련성으로 필요한 항목을 식별한다
- **D-04:** 쿼리 주체는 **researcher/planner 서브에이전트**다 (사람이 직접 쿼리하는 시나리오는 1차 대상 아님).

### 구현 제약 (이전 결정 carry-forward)
- **D-05:** 파일시스템 기반 접근만 사용한다 — Read/Grep으로 접근, 벡터DB/MCP 불필요.
  - 벡터 없이 의미 기반 접근이 가능한 방식을 RAG/IR 연구에서 탐색
  - PageIndex 방식은 v1.x 이후 별도 검토 (Backlog Phase 999.1)
- **D-06:** GSD 에이전트 패치 방식으로 배포 (`patches/` 디렉토리), install.sh가 패치 재적용 처리.

### 성공 기준
- **D-07:** 구체적 성공 기준은 RAG/IR 리서치 후 researcher/planner가 정의한다.
  - 리서치 결과에 따라 측정 가능한 기준이 결정됨
  - 기준 예시 (확정 아님): "researcher agent가 N개 파일 중 관련 항목만 조회", "전체 파일 로드 없이 쿼리 가능"

### Claude's Discretion
- RAG/IR 연구 중 발견한 접근법 중 파일시스템 제약에 맞지 않는 것은 researcher가 판단하여 제외
- 구현 세부 방식 (파일 구조, 메타데이터 형식 등)은 리서치 결과 기반으로 결정

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### 프로젝트 핵심 문서
- `.planning/PROJECT.md` — Core Value, Constraints (파일시스템 기반 접근, MCP 불필요), Out of Scope 항목
- `.planning/ROADMAP.md` — Phase 4 목표 및 컨텍스트 (중요도 판별 기준 탐색: 빈도, 결과 영향도, 참조 횟수 등)
- `.planning/REQUIREMENTS.md` — Requirements TBD. Phase 4 완료 후 채울 것

### 현재 시스템 상태 (참조용)
- `.knowledge/raw/` — 매 턴 자동 수집된 원시 데이터 (날짜별 .md 파일)
- `patches/gsd-phase-researcher.patch.md` — researcher Step 0 컴파일 지시 (현재 상태 확인 필요)
- `patches/gsd-verifier.patch.md` — verifier Step 10b full reconcile 지시

### 이전 Phase 결과물 (패턴 참조)
- `.planning/phases/01-compiler-prompt-refactor/01-01-PLAN.md` — 긍정형 전환 패턴
- `.planning/phases/02-knowledge-format-system/02-CONTEXT.md` — guardrails/anti-patterns 분류 기준

### 리서치 초점 (researcher agent 가이드)
- RAG/IR 분야에서 **벡터 없이** 문서 관련성을 판단하는 접근법 탐색
- 예: BM25, TF-IDF, 구조적 메타데이터 기반 필터링, keyword-tagging, hierarchical organization
- 목표: researcher/planner agent가 Read/Grep만으로 관련 knowledge를 효과적으로 찾는 방법

</canonical_refs>

<code_context>
## Existing Code Insights

### 현재 knowledge 시스템 상태
- `.knowledge/raw/` — 수집 디렉토리 존재 (2026-04-07, 08, 09 파일 확인)
- `.knowledge/knowledge/` — 아직 없음 (컴파일 미실행 상태)
- 컴파일러 트리거: `/gsd:plan-phase` (researcher Step 0) 또는 `/gsd:verify-phase` (verifier Step 10b)

### 현재 raw 파일 구조 (문제 상황)
- 형식: `### HH:MM — 한줄 제목\n2-3줄 요약\n`
- 모든 항목이 동등하게 저장됨 (사소한 작업과 중요한 결정이 같은 포맷)
- 식별된 문제:
  1. 하찮은 공계 내용이 중요 지식과 동일 가중치
  2. 복잡한 작업도 일상어 수준으로 처리됨
  3. 오래된 항목을 컴파일 시 외부 불필요

### Established Patterns
- 파일시스템: Read/Grep 기반 접근 (MCP 불필요)
- 패치 방식: `patches/` 디렉토리 → install.sh 재적용
- 이중 파일 구조: guardrails.md (절대 케이스) + anti-patterns.md (맥락 의존적)

### Integration Points
- `patches/gsd-phase-researcher.patch.md` Step 0 — raw → knowledge 변환 지시에 중요도 로직 추가될 지점
- `patches/gsd-verifier.patch.md` Step 10b — full reconcile 시 동일하게 적용 필요
- `install.sh` — 패치 재적용 스크립트

</code_context>

<specifics>
## Specific Ideas

- 사용자 표현: "중요도는 지식을 쿼리하는 시점에 결정될 것 같다" — 정적 분류보다 동적 관련성 모델 선호
- "내가 찾는 지식에 유의미한 정보를 제공할 수 있는 방법" — 쿼리 컨텍스트에 맞는 knowledge 반환이 목표
- RAG/IR에서 벡터 없는 접근법 탐색 요청 — 파일시스템 제약 내에서 가능한 최선의 방법

</specifics>

<deferred>
## Deferred Ideas

- **구체적 구현 방식** — RAG/IR 리서치 후 researcher가 결정 (저장 형식, 메타데이터 구조 등)
- **정확한 UAT 기준** — 리서치 결과에 따라 측정 가능한 기준 정의
- **PageIndex 연동** — Backlog Phase 999.1로 이미 등록, v1.x 이후 검토
- **사람이 직접 쿼리하는 시나리오** — 1차 대상 아님, 향후 별도 검토 가능

</deferred>

---

*Phase: 04-knowledge-importance-prioritization-scoring*
*Context gathered: 2026-04-09*
