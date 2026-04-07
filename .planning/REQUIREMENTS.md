# Requirements: Knowledge Compiler

**Defined:** 2026-04-07
**Milestone:** v1.1 Positive Prompt Refactor
**Core Value:** GSD 서브에이전트가 과거 세션의 시도와 결정에 접근하여 같은 실수를 반복하지 않는 것.

## v1.1 Requirements

### COMPILE — 컴파일러 프롬프트

- [ ] **COMPILE-01**: researcher가 incremental 컴파일 시 긍정형 지시로 knowledge 파일을 생성한다
- [ ] **COMPILE-02**: verifier가 full reconcile 시 긍정형 지시로 knowledge 파일을 재구성한다
- [ ] **COMPILE-03**: 컴파일러가 guardrails.md를 신규 생성하고, 기존 anti-patterns.md가 존재하면 읽어서 변환 후 반영한다
- [ ] **COMPILE-04**: guardrails.md는 절대적/대안 있는 케이스를 긍정형 액션("~경유 필수", "~사용")으로 기술한다
- [ ] **COMPILE-05**: anti-patterns.md는 맥락 의존적 케이스를 원인-결과형(관찰 → 이유 → 대신)으로 기술한다

### COLLECT — 수집 지시

- [ ] **COLLECT-01**: CLAUDE.md 턴 수집 지시의 부정형 규칙("포함하지 않을 것")을 긍정형으로 전환한다

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

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| COMPILE-01 | Phase 1 | Pending |
| COMPILE-02 | Phase 1 | Pending |
| COMPILE-03 | Phase 2 | Pending |
| COMPILE-04 | Phase 2 | Pending |
| COMPILE-05 | Phase 2 | Pending |
| COLLECT-01 | Phase 3 | Pending |

**Coverage:**
- v1.1 requirements: 6 total
- Mapped to phases: 6
- Unmapped: 0

---
*Requirements defined: 2026-04-07*
*Last updated: 2026-04-07 — traceability mapped after roadmap creation*
