# Requirements: Knowledge Compiler

**Defined:** 2026-04-07
**Milestone:** v1.1 Positive Prompt Refactor
**Core Value:** GSD 서브에이전트가 과거 세션의 시도와 결정에 접근하여 같은 실수를 반복하지 않는 것.

## v1.1 Requirements

### COMPILE — 컴파일러 프롬프트

- [ ] **COMPILE-01**: researcher가 incremental 컴파일 시 긍정형 지시로 knowledge 파일을 생성한다
- [ ] **COMPILE-02**: verifier가 full reconcile 시 긍정형 지시로 knowledge 파일을 재구성한다
- [x] **COMPILE-03**: 컴파일러가 guardrails.md를 신규 생성하고, 기존 anti-patterns.md가 존재하면 읽어서 변환 후 반영한다
- [x] **COMPILE-04**: guardrails.md는 절대적/대안 있는 케이스를 긍정형 액션("~경유 필수", "~사용")으로 기술한다
- [x] **COMPILE-05**: anti-patterns.md는 맥락 의존적 케이스를 원인-결과형(관찰 → 이유 → 대신)으로 기술한다

### COLLECT — 수집 지시

- [x] **COLLECT-01**: CLAUDE.md 턴 수집 지시의 부정형 규칙("포함하지 않을 것")을 긍정형으로 전환한다

### RELEVANCE — 지식 관련성 접근

- [ ] **RELEVANCE-01**: 컴파일러 지시에 raw 항목 선별 기준(포함/건너뛰기)이 명시되어 일회성 항목이 knowledge에서 제외된다
- [ ] **RELEVANCE-02**: index.md 형식 지시에 Quick Reference 테이블(주제 → 파일 → 핵심 항목)이 포함되어 쿼리 안내 역할을 한다
- [ ] **RELEVANCE-03**: 에이전트 접근 지시가 index-first 패턴(index.md 먼저 읽고 관련 파일만 선택 Read)을 명시한다
- [ ] **RELEVANCE-04**: researcher 패치와 verifier 패치의 선별 기준 및 index.md 형식 블록이 동일하다 (D-08 패턴)

### WORKFLOW — GSD 워크플로 단계별 knowledge 활동

- [x] **WORKFLOW-01**: researcher는 compile 없이 Step 3 lookup만 수행한다 — researcher Step 0 compile 블록이 패치 파일에서 제거된다 (D-01)
- [x] **WORKFLOW-02**: planner는 fallback compile을 수행한다 — /gsd-clear 없이 세션이 종료된 경우 compile-manifest.json 기반 증분 컴파일을 실행한다 (D-03, D-06)
- [x] **WORKFLOW-03**: discuss는 knowledge lookup만 수행한다 — compile 없이 decisions.md와 guardrails.md를 조회한다 (D-08)
- [x] **WORKFLOW-04**: /gsd-clear 스킬이 구현된다 — compile + /clear를 단일 명령으로 수행하는 7단계 프로세스 (D-02)
- [x] **WORKFLOW-05**: /gsd-knowledge-compile 스킬이 구현된다 — compile만 수행하고 컨텍스트를 유지하는 on-demand 커맨드 (D-14)
- [x] **WORKFLOW-06**: compile 소스가 raw/ + .planning/** 전체를 포함한다 — 파일 유형 제한 없이 GSD 생성 아티팩트 전체 포함 (D-05)
- [x] **WORKFLOW-07**: 모든 패치와 스킬이 install.sh를 통해 단일 명령으로 배포된다 — patch_workflow 함수와 install_skill 함수로 처리 (D-15)

## v2 Requirements

### LINT — 자동 검증

- **LINT-01**: 컴파일 후 knowledge 파일에 부정형 패턴 잔존 시 경고 출력
- **LINT-02**: guardrails.md와 anti-patterns.md 간 중복 항목 감지

### BRIEF — 브리핑 생성

- **BRIEF-01**: Phase 시작 시 해당 Phase 관련 knowledge만 추출해 planning guardrail brief 생성
- **BRIEF-02**: brief는 MUST/MUST NOT이 아닌 긍정형 제약으로 표현

## Out of Scope

| Feature | Reason |
|---------|--------|
| MCP 벡터DB semantic search | 추가 인프라 부담, 마크다운으로 충분 |
| Exploration Phase 타입 도입 | v1.1 범위 초과 |
| 점진적 컴파일 최적화 | 성능 문제 발생 시 고려 |
| anti-patterns.md 완전 제거 | 맥락 의존적 케이스는 유지 필요 |
| BM25/TF-IDF 완전 구현 | Read/Grep 제약 위반 (D-05) |
| 벡터 임베딩 검색 | 명시적 Out of Scope (D-05) |
| 수동 중요도 마킹 | 저장 시점 마킹 금지 (D-03) |
| PageIndex MCP 연동 | Backlog Phase 999.1 — v1.x 이후 검토 |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| COMPILE-01 | Phase 1 | Pending |
| COMPILE-02 | Phase 1 | Pending |
| COMPILE-03 | Phase 2 | Complete |
| COMPILE-04 | Phase 2 | Complete |
| COMPILE-05 | Phase 2 | Complete |
| COLLECT-01 | Phase 3 | Complete |
| RELEVANCE-01 | Phase 4 | Pending |
| RELEVANCE-02 | Phase 4 | Pending |
| RELEVANCE-03 | Phase 4 | Pending |
| RELEVANCE-04 | Phase 4 | Pending |
| WORKFLOW-01 | Phase 5 | Complete |
| WORKFLOW-02 | Phase 5 | Complete |
| WORKFLOW-03 | Phase 5 | Complete |
| WORKFLOW-04 | Phase 5 | Complete |
| WORKFLOW-05 | Phase 5 | Complete |
| WORKFLOW-06 | Phase 5 | Complete |
| WORKFLOW-07 | Phase 5 | Complete |

**Coverage:**
- v1.1 requirements: 17 total
- Mapped to phases: 17
- Unmapped: 0

---
*Requirements defined: 2026-04-07*
*Last updated: 2026-04-12 — WORKFLOW requirements added for Phase 5*
