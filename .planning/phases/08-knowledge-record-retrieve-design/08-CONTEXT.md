# Phase 8: Knowledge Record & Retrieve Design - Context

**Gathered:** 2026-04-14
**Status:** Ready for planning

<domain>
## Phase Boundary

기록(record) 메타데이터 설계, 증강/감쇄 구현, 조회(retrieve) 활용 개선을 하나의 통합 설계로 구현한다.

**핵심 인사이트:** 기록 메타데이터 형식이 조회 가능성의 상한선을 결정한다. 기록 방식과 조회 방식은 독립적으로 설계할 수 없고, 하나의 일관된 설계 아래 있어야 한다.

**이 Phase에서 수행:**
- 기록 메타데이터 설계 — 항목에 context 태그 등 구조 추가
- 증강/감쇄 구현 — Phase 7 RESEARCH.md 권고안 기반 (충돌 기반 decay 등)
- 조회 활용 개선 — 항목 필터링, 우선순위, `[uncertain]`/`[superseded]` 처리
- 신규 증강 방법론 리서치 — 현행 B+C fusion 외 대안 탐색

**이 Phase에서 수행하지 않음:**
- PageIndex semantic search 연동 (Phase 999.1 — 지식 규모 충분 시)

</domain>

<decisions>
## Implementation Decisions

### D-01: 기록과 조회의 통합 설계

기록 메타데이터 형식이 조회 가능성의 상한선을 결정한다. 기록 방식과 조회 방식을
독립적으로 설계하지 않고 하나의 일관된 설계 아래 둔다.

예시: 조회 시 "현재 작업과 관련된 항목만" 가져오려면, 기록 시점에 항목에
`context: [file-loading, agent-behavior]` 같은 태그가 있어야 한다.

### D-02: Phase 8 범위 (세 가지를 하나로)

Phase 7 권고안 구현에 더해 다음 세 가지를 하나의 Phase로 묶는다:
1. **기록 메타데이터 설계** — 항목에 context 태그 등 구조 추가
2. **증강/감쇄 구현** — Phase 7 RESEARCH.md 권고안 기반
3. **조회 활용 개선** — 항목 필터링, 우선순위, uncertain/superseded 처리

### D-03: 신규 증강 방법론 리서치 포함

현행 B+C fusion 검증(Phase 7 D-03 시뮬레이션 결과)을 바탕으로, 더 나은 증강 방법도
Phase 8 리서치 범위에 포함한다. 검토할 방향:
- **신뢰도 가중치** — Observed 횟수에 따라 항목 신뢰도 수치화
- **Cross-session 합산** — 여러 세션에서 독립적으로 같은 결론 도달 시 가중치 증가
- **사용 컨텍스트 태깅** — 어떤 Phase/task 유형에서 참조됐는지 메타데이터

### D-04: 조회 시점 활용 개선 방향

에이전트가 현재 작업 컨텍스트와 knowledge 항목을 더 정확히 매칭할 수 있도록:
- 기록 시 항목에 context 태그 추가 (기록 메타데이터 설계와 직결)
- `[uncertain]` 항목 조회 시 경고 표시
- `[superseded]` 항목 조회에서 제외 또는 별도 표시
- 조회 우선순위: Observed 높은 항목 > 최근 기록 항목 > 나머지

### Claude's Discretion

- context 태그 구체적 분류 체계 (어떤 카테고리로 나눌지)
- 조회 우선순위 구현 방식 (SKILL.md 지시 vs 별도 index 구조)
- Phase 7 시뮬레이션 결과에 따라 일부 결정 변경 가능 (D-03은 Phase 7 완료 후 확정)

</decisions>

<specifics>
## Specific Ideas

- decisions.md 항목 형태 변경 예시:
  ```
  ## index-first 접근 표준화
  [active] [context: file-loading, agent-lookup]
  index.md를 먼저 읽어 관련 파일만 선택적으로 로드
  Observed: 2 times (2026-04-12, 2026-04-12)
  ```
- `[uncertain]` 항목 처리: planner/researcher 패치에 "이 결정은 불확실 — raw/ 최근 항목 확인 후 사용" 경고 추가
- Phase 7 RESEARCH.md 충돌 기반 decay 권고안: SKILL.md Step 5 수정 (반대 결론 → `[uncertain]` 상태 전환 추가)

</specifics>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Phase 7 결과물 (Phase 8 시작 전 반드시 확인)

- `.planning/phases/07-knowledge-reinforcement-decay-audit/07-RESEARCH.md` — 증강/감쇄 현황 분석 + 권고안 (Phase 8 구현의 출발점, D-03 시뮬레이션 미실행 — Phase 8 구현 후 audit으로 대체)
- `.knowledge/knowledge/decisions.md` — 현재 항목 형태 (메타데이터 설계 기준선)

### 현재 컴파일러 구현

- `skills/gsd-knowledge-compile/SKILL.md` — B+C fusion 정책 (Step 5), 증강/감쇄 수정 대상
- `patches/gsd-phase-researcher.patch.md` — 조회 지침 수정 대상
- `patches/gsd-planner.patch.md` — 조회 지침 수정 대상

### 백로그 참고

- `.planning/ROADMAP.md` Backlog — Phase 999.1 PageIndex (이 Phase의 Deferred 사유)

</canonical_refs>

<deferred>
## Deferred Ideas

- PageIndex(Phase 999.1) semantic search 연동 — 지식 규모가 충분히 커진 v1.x 이후
- JSONL 참조 추적 강화 (항목 수준 참조율) — PageIndex 연동 이후 재고
- 시간 기반 decay — Phase 7 비권고, PageIndex 이후 재고

</deferred>

---

*Phase: 08-knowledge-record-retrieve-design*
*Context gathered: 2026-04-14 (대화 기반 — /gsd-discuss-phase 없이 직접 작성)*
