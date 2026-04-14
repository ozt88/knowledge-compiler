# Roadmap: Knowledge Compiler

## Milestones

- **v1.1 Positive Prompt Refactor** - Phases 1-7 (in progress)

## Phases

### v1.1 Positive Prompt Refactor (Complete)

**Milestone Goal:** 수집·컴파일·knowledge 파일 생성 전반의 프롬프트를 긍정형으로 전환해 준수율과 knowledge 품질 향상

- [ ] **Phase 1: Compiler Prompt Refactor** - researcher/verifier 패치 파일의 컴파일러 프롬프트를 긍정형으로 전환
- [x] **Phase 2: Knowledge Format System** - guardrails.md 신규 도입 및 anti-patterns.md 형식을 원인-결과형으로 재정의 (completed 2026-04-08)
- [x] **Phase 3: Collection Instruction Refactor** - CLAUDE.md 턴 수집 지시의 부정형 규칙을 긍정형으로 전환 (completed 2026-04-08)
- [x] **Phase 4: Knowledge Importance Prioritization** - 컴파일러 선별 기준 + index-first 접근 지시 (completed 2026-04-10)
- [x] **Phase 5: GSD Workflow Stages** - GSD 단계별 knowledge 활동 배분 패치 및 스킬 구현 (completed 2026-04-12)
- [x] **Phase 6: GSD Knowledge Reference Audit** - GSD 각 단계 knowledge 참조 검증 및 보완 (completed 2026-04-13)
- [ ] **Phase 7: Knowledge Reinforcement Decay Audit** - 유용한/참조된 지식 증강과 유용하지 않은 지식 감쇄가 잘 동작하고 있는지?

## Phase Details

### Phase 1: Compiler Prompt Refactor
**Goal**: researcher와 verifier가 긍정형 지시로 knowledge 파일을 생성한다
**Depends on**: Nothing (first phase)
**Requirements**: COMPILE-01, COMPILE-02
**Success Criteria** (what must be TRUE):
  1. gsd-phase-researcher.patch.md의 Step 0 컴파일러 프롬프트가 "~하지 마라" 형식 없이 긍정형 지시만 포함한다
  2. gsd-verifier.patch.md의 Step 10b 컴파일러 프롬프트가 "~하지 마라" 형식 없이 긍정형 지시만 포함한다
  3. 두 패치 모두 기존 컴파일 결과 구조(index.md, decisions.md, anti-patterns.md, troubleshooting.md)를 그대로 유지한다
**Plans:** 1 plan

Plans:
- [x] 01-01-PLAN.md — researcher/verifier 패치 파일 부정형 지시를 긍정형으로 전환

### Phase 2: Knowledge Format System
**Goal**: guardrails.md가 도입되고 anti-patterns.md가 맥락 의존형 형식으로 재정의된다
**Depends on**: Phase 1
**Requirements**: COMPILE-03, COMPILE-04, COMPILE-05
**Success Criteria** (what must be TRUE):
  1. 컴파일러 프롬프트가 guardrails.md를 신규 생성하며, 기존 anti-patterns.md가 있으면 읽고 변환하여 반영하는 절차를 명시한다
  2. guardrails.md 형식 지시가 절대적/대안 있는 케이스를 긍정형 액션("~경유 필수", "~사용")으로 기술하도록 규정한다
  3. anti-patterns.md 형식 지시가 맥락 의존적 케이스를 관찰-이유-대신 구조로 기술하도록 규정한다
  4. 두 파일(guardrails.md, anti-patterns.md)의 역할 경계가 컴파일러 프롬프트에 명확히 구분된다
**Plans:** 1/1 plans complete

Plans:
- [x] 02-01-PLAN.md — researcher/verifier 패치에 guardrails.md 도입 + anti-patterns.md 형식 재정의 + 마이그레이션 절차

### Phase 3: Collection Instruction Refactor
**Goal**: CLAUDE.md 턴 수집 지시가 전면 긍정형으로 전환되어 준수율이 향상된다
**Depends on**: Phase 2
**Requirements**: COLLECT-01
**Success Criteria** (what must be TRUE):
  1. templates/claude-md-section.md의 수집 규칙에서 "포함하지 않을 것" 항목이 제거되고 긍정형 지시로 대체된다
  2. 전환된 지시가 동일한 수집 의도(코드 전문/개인정보/도구 호출 세부사항 제외)를 긍정 표현으로 달성한다
  3. CLAUDE.md 글로벌 지시에도 동일한 긍정형 전환이 반영된다
**Plans:** 1/1 plans complete

Plans:
- [x] 03-01-PLAN.md — 턴 수집 규칙 부정형 삭제 및 규칙 3 긍정형 세밀화, CLAUDE.md 동기화

### Phase 4: Knowledge Importance Prioritization
**Goal**: 컴파일러가 raw 항목의 지식 가치를 판별하여 선별 포함하고, 에이전트가 index-first 접근으로 관련 knowledge를 효율적으로 조회한다
**Depends on**: Phase 3
**Requirements**: RELEVANCE-01, RELEVANCE-02, RELEVANCE-03, RELEVANCE-04
**Success Criteria** (what must be TRUE):
  1. 컴파일러 지시에 raw 항목 선별 기준(포함하는 항목 + 건너뛰는 항목)이 명시된다
  2. index.md 형식 지시에 Quick Reference 테이블(주제 → 파일 매핑)이 포함된다
  3. 에이전트 접근 지시가 index-first 패턴을 명시한다
  4. researcher 패치와 verifier 패치의 선별 기준 블록이 동일하다 (D-08)
**Plans:** 1 plan

Plans:
- [x] 04-01-PLAN.md — 두 패치에 선별 기준 + index.md 쿼리 안내 형식 + index-first 접근 지시 추가

### Phase 5: GSD Workflow Stages
**Goal:** GSD 워크플로 각 단계(discuss/plan/research/execute/verify/clear)에서 knowledge 활동(수집/컴파일/조회)을 배분하는 패치와 스킬을 구현한다
**Depends on:** Phase 4
**Requirements**: WORKFLOW-01, WORKFLOW-02, WORKFLOW-03, WORKFLOW-04, WORKFLOW-05, WORKFLOW-06, WORKFLOW-07
**Success Criteria** (what must be TRUE):
  1. discuss/plan/research 단계의 knowledge 활동(lookup/fallback-compile/lookup)이 각 패치 파일에 구현된다
  2. /gsd-clear 스킬이 compile → /clear의 완전한 실행 순서를 포함한다
  3. compile-manifest.json 기반 증분 컴파일 메커니즘이 planner 패치와 skill.md에 step-by-step으로 구현된다
  4. B+C fusion 중복 처리 정책(reinforcement counter + conflict blockquote)이 skills/gsd-clear/skill.md Step 5에 명시된다
  5. 모든 변경사항이 install.sh를 통해 단일 명령으로 배포된다
**Plans:** 1/1 plans complete

Plans:
- [x] 05-01-PLAN.md — researcher Step 0 compile 제거 + planner fallback compile + discuss-phase lookup + /gsd-clear + /gsd-knowledge-compile 스킬 생성 + install.sh 배포

### Phase 6: GSD Knowledge Reference Audit
**Goal:** GSD 각 단계(discuss/plan/research/execute/verify/clear)가 knowledge를 실제로 올바르게 참조하는지 검증하고 누락된 참조를 보완한다
**Requirements**: D-16, D-17, D-18, D-19, D-20, D-21, D-22, D-23
**Depends on:** Phase 5
**Plans:** 2 plans

Plans:
- [x] 06-01-PLAN.md — 중복 PATCH 블록 단일화(researcher×6, planner×6, verifier×8 → 각 1) + discuss-phase 앵커 수정 및 패치 적용
- [x] 06-02-PLAN.md — JSONL 측정 재실행(D-22) + analyze_knowledge_reads.js 처리 + 감사 SUMMARY 완성

## Backlog

### Phase 999.1: PageIndex Integration — Knowledge Search Layer (BACKLOG)

**Goal:** .knowledge/knowledge/*.md 파일을 PageIndex(Vectorless RAG)로 인덱싱해 researcher/verifier 에이전트가 전체 파일 로드 대신 targeted 쿼리로 관련 knowledge를 조회한다
**Requirements:** TBD
**Plans:** 0 plans

Context:

- PageIndex repo: [VectifyAI/PageIndex](https://github.com/VectifyAI/PageIndex)
- MCP 서버 연동으로 Claude Code 에이전트가 직접 쿼리 가능
- Markdown 모드: 헤딩(`##`, `###`) 기반 계층 트리 → knowledge 파일 구조와 호환
- 적용 시점: 지식이 충분히 축적된 v1.x 이후 검토

Plans:

- [ ] TBD (promote with /gsd:review-backlog when ready)

## Progress

| Phase | Milestone | Plans Complete | Status | Completed |
|-------|-----------|----------------|--------|-----------|
| 1. Compiler Prompt Refactor | v1.1 | 1/1 | Complete | 2026-04-07 |
| 2. Knowledge Format System | v1.1 | 1/1 | Complete   | 2026-04-08 |
| 3. Collection Instruction Refactor | v1.1 | 1/1 | Complete   | 2026-04-08 |
| 4. Knowledge Importance Prioritization | v1.1 | 1/1 | Complete | 2026-04-10 |
| 5. GSD Workflow Stages | v1.1 | 1/1 | Complete | 2026-04-12 |
| 6. GSD Knowledge Reference Audit | v1.1 | 2/2 | Complete | 2026-04-13 |
| 7. Knowledge Reinforcement Decay Audit | v1.1 | 0/2 | In progress | — |

### Phase 7: Knowledge Reinforcement Decay Audit

**Goal:** B+C fusion 증강 메커니즘의 실제 동작을 검증하고, 감쇄 메커니즘 현황을 분석하여 자동화 방안 권고안을 도출한다
**Requirements**: D-01, D-02, D-03, D-04
**Depends on:** Phase 6
**Plans:** 2 plans

Plans:
- [ ] 07-01-PLAN.md — D-03 컴파일 시뮬레이션 (Before/After snapshot + /gsd-knowledge-compile 실행 + B+C fusion 판정)
- [ ] 07-02-PLAN.md — D-02 감쇄 갭 분석 + D-04 최종 권고안 확정 (RESEARCH.md 완성)
