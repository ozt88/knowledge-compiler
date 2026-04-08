# Roadmap: Knowledge Compiler

## Milestones

- **v1.1 Positive Prompt Refactor** - Phases 1-3 (in progress)

## Phases

### v1.1 Positive Prompt Refactor (In Progress)

**Milestone Goal:** 수집·컴파일·knowledge 파일 생성 전반의 프롬프트를 긍정형으로 전환해 준수율과 knowledge 품질 향상

- [ ] **Phase 1: Compiler Prompt Refactor** - researcher/verifier 패치 파일의 컴파일러 프롬프트를 긍정형으로 전환
- [x] **Phase 2: Knowledge Format System** - guardrails.md 신규 도입 및 anti-patterns.md 형식을 원인-결과형으로 재정의 (completed 2026-04-08)
- [x] **Phase 3: Collection Instruction Refactor** - CLAUDE.md 턴 수집 지시의 부정형 규칙을 긍정형으로 전환 (completed 2026-04-08)

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

## Progress

| Phase | Milestone | Plans Complete | Status | Completed |
|-------|-----------|----------------|--------|-----------|
| 1. Compiler Prompt Refactor | v1.1 | 1/1 | Complete | 2026-04-07 |
| 2. Knowledge Format System | v1.1 | 1/1 | Complete   | 2026-04-08 |
| 3. Collection Instruction Refactor | v1.1 | 1/1 | Complete   | 2026-04-08 |
