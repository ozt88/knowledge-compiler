# Knowledge Compiler

## What This Is

GSD 워크플로 확장으로, 세션 간 지식 유실을 방지하는 자동 수집·컴파일·참조 파이프라인이다.
매 턴 `.knowledge/raw/`에 자동 수집하고, Phase 전환 시 researcher/verifier가 구조화된 `knowledge/`로 컴파일하여 다음 Phase의 planner가 과거 시도·실패·결정을 참조할 수 있게 한다.

## Core Value

GSD 서브에이전트(planner, researcher)가 과거 세션의 시도와 결정에 접근하여 같은 실수를 반복하지 않는 것.

## Current Milestone: v1.1 Positive Prompt Refactor

**Goal:** 수집·컴파일·knowledge 파일 생성 전반의 프롬프트를 부정형에서 긍정형으로 전환해 준수율과 knowledge 품질 향상

**Target features:**
- researcher/verifier 패치의 컴파일러 프롬프트 긍정형 전환
- CLAUDE.md 턴 수집 지시 긍정형 전환
- knowledge/ 파일 형식을 긍정형으로 생성되도록 컴파일러 프롬프트에 반영

## Requirements

### Validated

- ✓ CLAUDE.md 행동 지시로 매 턴 `.knowledge/raw/`에 자동 수집 — v1.0
- ✓ gsd-phase-researcher Step 0: raw/ → knowledge/ incremental 컴파일 — v1.0
- ✓ gsd-verifier Step 10b: knowledge/ full reconcile — v1.0
- ✓ planner/researcher가 knowledge/ 직접 참조 — v1.0

### Active

- [x] researcher/verifier 컴파일러 프롬프트 긍정형 전환 (Pink Elephant Problem 대응) — Validated in Phase 01: compiler-prompt-refactor
- [x] knowledge/ 파일 형식 재구성 — guardrails.md(긍정형 절대 케이스) + anti-patterns.md(관찰-이유-대신 맥락 케이스) 이중 구조 도입 — Validated in Phase 02: knowledge-format-system
- [x] CLAUDE.md 턴 수집 규칙 긍정형 전환 (규칙 4 "포함하지 않을 것" → 긍정형) — Validated in Phase 03: collection-instruction-refactor
- [ ] 변경 전후 품질 검증 방법 정의

### Out of Scope

- MCP 벡터DB 기반 semantic search — 추가 인프라 부담, 마크다운으로 충분
- lint 단계 자동화 — v1.1 범위 초과, 이후 확장
- planning brief 자동 생성 — v1.1 범위 초과, 이후 확장
- Exploration Phase 타입 도입 — v1.1 범위 초과

## Context

- **MVP 완료 (v1.0):** raw 수집 → 컴파일 → planner 연동 파이프라인 동작 확인
- **실험 근거 (exp-kjkim-notes/prompt-brevity-test):**
  - 긍정형 vs 부정형 프롬프트 비교, n=10, Sonnet 4.6
  - Original(부정형) vs Improved(긍정형): t=3.09, p<0.05 유의미
  - Brevity Constraints (arxiv:2604.00025): 31개 모델, 대형 모델 26%p 정확도 향상
  - 수치보다 방향성 기반 적용 (n=10 한계 인지)
- **설치 방식:** GSD 에이전트 파일에 patch 적용 (patches/ 디렉토리)
- **지원 GSD 버전:** 1.32.0+

## Constraints

- **호환성**: GSD 업데이트 시 패치 재적용 필요 — install.sh가 처리
- **접근성**: knowledge/는 파일시스템 Read/Grep만으로 접근 (MCP 불필요)
- **범위**: CLAUDE.md 글로벌 지시와 GSD 에이전트 패치만 수정 (GSD 내부 변경 없음)

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| CLAUDE.md 행동 지시로 수집 | Hook 방식은 턴 컨텍스트 접근 불가, prompt hook은 생성 불가 | ✓ Good |
| 파일시스템 기반 knowledge (MCP 아님) | 서브에이전트가 Read/Grep으로 접근 가능, 추가 인프라 불필요 | ✓ Good |
| Patch 방식 배포 | GSD 포크 없이 업데이트 추적 가능 | ✓ Good |
| anti-patterns.md "하지 마라" 형식 | MVP 빠른 구현 우선 | ⚠️ Revisit — 긍정형 전환 예정 |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd:transition`):
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `/gsd:complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-04-08 — Phase 03 complete (CLAUDE.md 턴 수집 규칙 4 삭제, 규칙 3 긍정형 세밀화, CLAUDE.md 동기화)*
