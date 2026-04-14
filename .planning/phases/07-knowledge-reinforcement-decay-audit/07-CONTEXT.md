# Phase 7: Knowledge Reinforcement Decay Audit - Context

**Gathered:** 2026-04-14
**Status:** Ready for planning

<domain>
## Phase Boundary

유용한/참조된 지식의 증강(reinforcement)과 유용하지 않은 지식의 감쇄(decay) 메커니즘이
실제 knowledge compiler 운영에서 올바르게 동작하는지 감사(audit)한다. 감사 결과를 토대로
더 나은 메커니즘 방안을 리서치하여 권고안을 도출한다.

**이 Phase에서 수행:**
- 증강 메커니즘 (`Observed: N times` B+C fusion) 실제 동작 검증
- 감쇄 메커니즘 현황 분석 (수동 상태 변경 vs 자동화 필요 여부)
- 충돌 기반(conflict-triggered) decay + 시간 기반(time-based) decay 방안 리서치
- 감사 보고서 + 권고안 작성

**이 Phase에서 수행하지 않음:**
- 새로운 decay/reinforcement 메커니즘 구현 (다음 Phase)
- install.sh 수정 또는 패치 파일 변경

</domain>

<decisions>
## Implementation Decisions

### Phase 범위

- **D-01: Audit + 리서치 모드** — 현황 파악 + 문제 발견 시 즉시 수정하지 않고 리서치로 더 나은
  방안을 찾아 RESEARCH.md + 권고안으로 정리한다. 구현은 다음 Phase에서.

### 감쇄(decay) 정의

- **D-02: 두 가지 decay 방안 모두 리서치** — 수동 상태 변경([superseded]/[rejected])이 현재
  유일한 decay 방법. 다음 두 가지 방안의 가능성을 모두 조사한다:
  - **충돌 기반 decay**: 에이전트가 이전 결정과 충돌하는 증거를 마주칠 때 `[uncertain]` 상태
    전환 트리거 — 컴파일러가 자동 지원하는 형태 조사
  - **시간 기반 decay**: X일 이상 참조되지 않으면 `[stale]` 상태 자동 전환 — JSONL 참조 추적
    필요 여부 및 구현 비용 조사

### 증강(reinforcement) 검증 방법

- **D-03: 실제 컴파일 시뮬레이션** — raw/ 파일에 기존 decisions.md 항목과 동일한 결론을 담은
  새 항목을 추가한 후 `/gsd-knowledge-compile` 실행. 컴파일 후 `Observed: N times` 카운터가
  실제로 증가하는지 before/after 비교로 검증.

### 성공 기준

- **D-04: Audit 보고서 + 권고안** — 다음을 포함하는 RESEARCH.md를 완성하면 Phase 7 완료:
  1. 증강 메커니즘 동작 여부 (컴파일 시뮬레이션 결과)
  2. 현재 감쇄 메커니즘의 한계와 갭 명세
  3. 충돌 기반 decay 방안 — 구현 복잡도, 기대 효과, 권고 여부
  4. 시간 기반 decay 방안 — 구현 복잡도, 기대 효과, 권고 여부
  5. 최종 권고안 (다음 Phase에서 구현할 방향)

### Claude's Discretion

- 컴파일 시뮬레이션에 사용할 테스트 raw 항목의 내용
- decisions.md 항목 중 "Observed 없음"이 버그인지 정상인지 판단 기준
- 리서치 방법론 (현재 코드 분석 vs 설계 문서 검토 vs 기존 knowledge system 참고)

</decisions>

<specifics>
## Specific Ideas

- 증강 검증은 "before/after 비교" 방식 — 컴파일 전 decisions.md snapshot, 컴파일 후
  `Observed` 카운터 변화 확인
- decay 리서치 시 구현 비용이 중요한 고려 요소: JSONL 참조 추적이 필요한 시간 기반 방식은
  Phase 6 도구(analyze_knowledge_reads.js)를 참고할 것

</specifics>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### 현재 구현 상태

- `skills/gsd-knowledge-compile/SKILL.md` — 컴파일러 Step 5 B+C fusion 정책 (Observed counter,
  conflict blockquote) 정의
- `patches/gsd-phase-researcher.patch.md` — researcher lookup 패치 현재 상태
- `patches/gsd-planner.patch.md` — planner lookup 패치 현재 상태

### Knowledge 현재 상태

- `.knowledge/knowledge/decisions.md` — 현재 decisions.md 항목 및 Observed 카운터 분포
- `.knowledge/knowledge/guardrails.md` — 하드 제약 현황

### Phase 이력

- `.planning/phases/06-gsd-knowledge/06-CONTEXT.md` — D-22/D-23: JSONL 측정 도구 및
  Phase 6 참조율 측정 결과 (analyze_knowledge_reads.js 위치, 방법론)
- `.planning/STATE.md` — 현재 프로젝트 상태 및 Decisions 섹션

</canonical_refs>

<deferred>
## Deferred Ideas

- 자동 decay 메커니즘 실제 구현 — 이 Phase의 리서치 결과를 바탕으로 다음 Phase에서
- JSONL 참조 추적 강화 (참조 횟수 기반 가중치 시스템) — Phase 999.1 PageIndex 백로그와 연계
  검토 필요

</deferred>

---

*Phase: 07-knowledge-reinforcement-decay-audit*
*Context gathered: 2026-04-14*
