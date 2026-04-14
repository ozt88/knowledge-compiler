# Phase 7: Knowledge Reinforcement Decay Audit - Research

**Researched:** 2026-04-14
**Domain:** Knowledge compiler의 B+C fusion 메커니즘 — 증강(reinforcement)과 감쇄(decay) 동작 검증
**Confidence:** HIGH

---

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

- **D-01: Audit + 리서치 모드** — 현황 파악 + 문제 발견 시 즉시 수정하지 않고 리서치로 더 나은
  방안을 찾아 RESEARCH.md + 권고안으로 정리한다. 구현은 다음 Phase에서.

- **D-02: 두 가지 decay 방안 모두 리서치** — 수동 상태 변경([superseded]/[rejected])이 현재
  유일한 decay 방법. 다음 두 가지 방안의 가능성을 모두 조사한다:
  - **충돌 기반 decay**: 에이전트가 이전 결정과 충돌하는 증거를 마주칠 때 `[uncertain]` 상태
    전환 트리거 — 컴파일러가 자동 지원하는 형태 조사
  - **시간 기반 decay**: X일 이상 참조되지 않으면 `[stale]` 상태 자동 전환 — JSONL 참조 추적
    필요 여부 및 구현 비용 조사

- **D-03: 실제 컴파일 시뮬레이션** — raw/ 파일에 기존 decisions.md 항목과 동일한 결론을 담은
  새 항목을 추가한 후 `/gsd-knowledge-compile` 실행. 컴파일 후 `Observed: N times` 카운터가
  실제로 증가하는지 before/after 비교로 검증.

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

### Deferred Ideas (OUT OF SCOPE)

- 자동 decay 메커니즘 실제 구현 — 이 Phase의 리서치 결과를 바탕으로 다음 Phase에서
- JSONL 참조 추적 강화 (참조 횟수 기반 가중치 시스템) — Phase 999.1 PageIndex 백로그와 연계
  검토 필요
</user_constraints>

---

## Summary

Phase 7의 목표는 두 가지다: (1) 현재 knowledge compiler의 증강(reinforcement) 메커니즘이 실제로 동작하는지 검증하고, (2) 감쇄(decay) 메커니즘의 현황과 갭을 분석하여 자동화 방안을 리서치한다.

**증강 메커니즘 현황.** SKILL.md Step 5의 B+C fusion 정책은 명확히 정의되어 있다: 동일 결론 재확인 시 `**Observed:** N times (date1, date2, ...)` 카운터를 증가시키고, 반대 결론 시 `[conflict: YYYY-MM-DD]` 태그를 추가한다. 그러나 현재 decisions.md 15개 항목 중 Observed 카운터가 붙은 항목은 단 1개("Phase 5 spec-only → implementation 전환")뿐이다. 대부분 항목이 1회만 기록된 상태다. 이것이 (a) 중복 원인이 없어서 정상인지, (b) fusion 로직이 미동작하는 버그인지 시뮬레이션으로 확인해야 한다.

**감쇄 메커니즘 현황.** 현재 유일한 decay는 수동 상태 변경이다: `[active]` → `[superseded]` / `[rejected]`를 컴파일러 에이전트가 raw 항목 해석을 통해 수동으로 수행한다. 자동 decay는 존재하지 않는다. 15개 항목 중 1개만 `[superseded]` 상태이고 나머지는 모두 `[active]`다. 충돌 기반과 시간 기반 두 가지 자동화 방안의 구현 복잡도와 기대 효과를 평가해야 한다.

**Primary recommendation:** 컴파일 시뮬레이션으로 B+C fusion 동작 여부를 먼저 확인한 뒤, 두 decay 방안의 구현 비용을 JSONL 측정 인프라(analyze_knowledge_reads.js) 재활용 관점에서 평가하라.

---

## 현재 시스템 상태 분석

### 증강(Reinforcement) 메커니즘 코드 분석

**B+C fusion 정책 위치:** `skills/gsd-knowledge-compile/SKILL.md` Step 5
[VERIFIED: 직접 파일 읽기]

```
B+C fusion 정책:
- 동일 결론 재확인 → `**Observed:** N times (date1, date2, ...)` 줄 추가 또는 카운트 증가
- 반대 결론 → `[conflict: YYYY-MM-DD]` 태그 추가 + `> **New (YYYY-MM-DD):**` blockquote로 새 내용 보존
```

이 정책은 SKILL.md에 텍스트 지시로만 존재한다. 코드로 구현된 것이 아니라 LLM이 컴파일 시 해석·실행하는 프롬프트다. 따라서 fusion이 실제로 동작하려면 컴파일 에이전트가 (1) 새 raw 항목을 읽고, (2) 기존 decisions.md와 비교하고, (3) 동일 결론 여부를 판단하고, (4) Observed 카운터를 갱신하는 4단계를 올바르게 수행해야 한다.

**현재 Observed 카운터 분포:**
[VERIFIED: decisions.md grep]

| 항목 | Observed 카운터 | 상태 |
|------|-----------------|------|
| Phase 5 spec-only → implementation 전환 | `Observed: 2 times (2026-04-12, 2026-04-12)` | [active] |
| 나머지 14개 항목 | Observed 없음 | [active] 또는 [superseded] |

Observed 카운터가 있는 항목이 1개뿐인 것은 raw/2026-04-12.md에서 동일 날짜에 2회 언급된 내용이 fusion된 결과다. 나머지 항목은 단 1회씩만 raw에 기록된 것으로 보이며, 이는 정상 동작일 가능성이 높다. 하지만 **fusion 로직 자체가 동작하는지 여부**는 시뮬레이션으로 직접 확인해야 한다.

**[conflict:] 태그 현황:** decisions.md, guardrails.md, anti-patterns.md 전체에 단 1개도 없다.
[VERIFIED: grep]

이것 역시 정상(지금까지 반대 결론이 없었음)일 수 있지만, conflict 감지 로직이 동작하는지는 검증된 바 없다.

### 감쇄(Decay) 메커니즘 코드 분석

**현재 구현 상태:**
[VERIFIED: SKILL.md, decisions.md 직접 분석]

```
decisions.md 지원 상태값:
- [active]     — 현재 유효한 결정
- [rejected]   — 거부된 방향 (에이전트가 참고 시 피해야 할 패턴)
- [superseded] — 상위 결정으로 대체됨
- [uncertain]  — 정의되어 있으나 현재 사용된 사례 없음
```

**상태 전환 방식:** 오직 수동. 컴파일러 에이전트가 raw 항목에서 "이전 결정이 무효화됐다"는 서술을 발견했을 때 상태를 변경한다. 자동 트리거 메커니즘은 없다.

**현재 15개 항목 상태 분포:**
- `[active]`: 14개
- `[superseded]`: 1개 ("researcher compile 제거, /gsd-clear primary 트리거" — Phase 6에서 대체됨)
- `[rejected]`, `[uncertain]`, `[stale]`: 0개

**갭 분석:** `[superseded]` 항목이 여전히 decisions.md에 남아있다. 에이전트가 이를 읽을 때 `[rejected]` 항목과 마찬가지로 "이 방향을 피하라"는 신호로 활용하지만, 낡은 항목이 쌓이면 컨텍스트 비용이 증가하고 혼동 가능성이 생긴다.

---

## 증강 검증 계획 (D-03 시뮬레이션 방법론)

**목표:** `Observed` 카운터 증가 메커니즘이 실제로 동작하는지 확인.

**방법:**

1. **Before snapshot** — decisions.md의 현재 상태를 기록 (특히 Observed 카운터 없는 항목의 내용 확인)

2. **테스트 raw 항목 작성** — 기존 decisions.md 항목 중 하나와 동일한 결론을 담은 새 항목을 `.knowledge/raw/2026-04-14.md`에 추가.
   - 예시 대상: "index-first 접근 표준화" 항목 (`index.md를 먼저 읽어 관련 파일만 선택적 Read`)
   - 테스트 항목 내용: "에이전트 knowledge 조회: raw/ 전체 로드 시 컨텍스트 비용 높음 → index.md 먼저 읽고 관련 파일만 선택적으로 Read하는 방식이 효과적임을 재확인"

3. **컴파일 실행** — `/gsd-knowledge-compile` 호출

4. **After snapshot** — decisions.md에서 해당 항목의 Observed 카운터 변화 확인

**판정 기준:**
- Observed 카운터가 증가함 → fusion 로직 정상 동작
- Observed 카운터 변화 없음 → fusion 로직 미동작 또는 LLM이 동일 결론으로 판단하지 못함
- 신규 항목으로 추가됨 → 중복 감지 실패

**주의사항 (Claude's Discretion 적용):**
- "Observed 없음"이 버그인지 판단 기준: 지금까지 같은 결론이 raw에 2회 이상 기록된 적이 없었다면 Observed 없음은 정상이다. 즉, **시뮬레이션이 처음으로 fusion을 테스트하는 시나리오**다.
- 테스트 raw 항목은 실제 작업에서 발생한 것처럼 자연스러운 형식으로 작성해야 컴파일러 에이전트가 "포함 기준"에서 일회성으로 분류하지 않도록 해야 한다.

---

## Decay 방안 리서치

### 현재 유일한 decay: 수동 상태 변경

**메커니즘:** 컴파일 에이전트가 raw 항목을 해석하면서 기존 decisions.md 항목과 모순을 발견하면 상태를 `[superseded]` 또는 `[rejected]`로 변경한다.

**한계:**
1. **반응형 전용** — 반드시 "이 결정이 무효화됐다"는 명시적 raw 항목이 있어야 한다. 자연스럽게 쓸모가 없어진 항목은 감지 불가.
2. **시간 경과 미감지** — 오래됐지만 아직 반증이 없는 항목은 영원히 `[active]`로 남는다.
3. **에이전트 판단 의존** — 컴파일 에이전트의 해석에 따라 상태 변경 여부가 달라진다. 일관성 없음.

---

### 방안 A: 충돌 기반(conflict-triggered) decay

**개념:** 컴파일 에이전트가 새 raw 항목과 기존 decisions.md 항목이 충돌할 때 `[uncertain]` 상태로 자동 전환.

**SKILL.md Step 5의 현재 conflict 처리:**
```
반대 결론 → `[conflict: YYYY-MM-DD]` 태그 추가 + blockquote로 새 내용 보존
```
현재 구현은 항목 자체를 `[uncertain]`으로 전환하지 않고, 태그와 blockquote만 추가한다. `[uncertain]` 상태 전환은 정의만 있고 실제 사용 사례가 없다.

**구현 방향:**

```
B+C fusion 정책 수정안:
- 동일 결론 → Observed 카운터 증가 (현행 유지)
- 반대 결론 → [conflict: YYYY-MM-DD] 태그 추가 + blockquote + 상태를 [uncertain]으로 변경
- [uncertain] 항목은 다음 컴파일에서 에이전트가 재판단: 어느 쪽이 맞는지 raw에서 추가 증거 수집 → [active] 복귀 또는 [superseded] 확정
```

**구현 비용 평가:**
- SKILL.md Step 5의 B+C fusion 정책 텍스트 수정만 필요 → **낮음**
- 에이전트 프롬프트 변경 → patch 파일 수정 불필요 (SKILL.md만 변경)
- 테스트: 컴파일 시뮬레이션에서 conflict 시나리오 추가 (기존 결정과 반대 raw 항목 작성)

**기대 효과:**
- 모순된 결정이 `[active]`로 남아 에이전트를 오도하는 문제 해소
- `[uncertain]` 항목이 가시화됨 → 다음 세션에서 사용자/에이전트가 의식적으로 재검토 가능
- 충돌 감지는 이미 SKILL.md에 concept으로 존재하므로 확장이 자연스러움

**위험:**
- LLM이 "반대 결론"을 판단하는 기준이 애매함 — 다른 맥락의 유사 결론을 conflict로 잘못 판정할 수 있음
- `[uncertain]` 항목이 쌓이면 에이전트가 조회 시 어떻게 처리해야 하는지 지시가 필요 (planner/researcher 패치에 "uncertain 항목은 사용 전 사용자 확인" 추가 필요)

**권고 여부: 권고** — 구현 비용이 낮고 기존 conflict 개념의 자연스러운 확장이다.

---

### 방안 B: 시간 기반(time-based) decay

**개념:** X일 이상 참조되지 않은 decisions.md 항목을 `[stale]` 상태로 자동 전환.

**필요 인프라 분석:**

이 방안을 구현하려면 두 가지 데이터가 필요하다:
1. **항목별 마지막 참조 날짜** — 에이전트가 decisions.md를 Read한 날짜 추적
2. **항목별 마지막 추가/갱신 날짜** — 컴파일 시 기록

**Phase 6 분석 인프라 재활용 가능성:**
- `analyze_knowledge_reads.js`는 세션별 `.knowledge/knowledge/` 파일 Read 횟수를 집계한다
- 그러나 파일 수준만 추적한다. **항목 수준 추적은 불가능하다.** decisions.md가 읽혔다고 해서 어떤 항목이 실제로 활용됐는지 알 수 없다.
[VERIFIED: analyze_knowledge_reads.js 코드 직접 분석]

**구현 비용 평가:**

옵션 1 — 파일 수준 decay (모든 항목을 파일 단위로 처리):
- decisions.md를 X일 이상 아무 세션도 읽지 않으면 전체를 `[stale]` 검토 대상으로 표시
- 구현 비용: SKILL.md + compile-manifest.json에 `last_read_dates` 필드 추가 → **중간**
- 문제: 파일 자체가 읽혔어도 특정 항목이 실제 도움이 됐는지 모름 → 너무 조잡한 신호

옵션 2 — 항목별 날짜 추적 (compile-manifest.json에 항목 ID + 날짜 매핑):
- 컴파일러 에이전트가 decisions.md 항목에 `**Last cited:** YYYY-MM-DD` 메타를 추가
- 구현 비용: SKILL.md Step 5 대폭 수정 + planner/researcher 패치에 "읽을 때 Last cited 갱신" 지시 추가 → **높음**
- 문제: decisions.md가 읽히는 것과 항목이 실제로 "참조"되는 것은 다름. LLM은 index-first로 파일을 읽지만 어떤 항목을 실제 사용했는지 파악 불가.

**현재 참조 데이터 현황:**
[VERIFIED: analyze_knowledge_reads.js 실행 결과]

```
전체 18 세션 중 [KNOWLEDGE READ] 세션: 3개 (17%)
- b8cae8e7 (2026-04-10): anti-patterns.md 1회
- 93a75c7c (2026-04-10): index.md 1회
- ce03c7f1 (2026-04-14): decisions.md, guardrails.md, anti-patterns.md 각 1회
```

현재 참조율이 너무 낮아 시간 기반 decay를 적용하면 대부분 항목이 즉시 `[stale]`이 된다. Phase 6 이후 PATCH가 올바르게 적용된 세션이 아직 충분하지 않다.

**기대 효과:**
- 오래된 context-specific 결정이 자동으로 정리됨
- 프로젝트 초기 결정(Phase 1~2)이 나중에도 계속 `[active]`로 표시되는 문제 완화

**위험:**
- 현재 참조율이 매우 낮아 decay threshold 설정이 어려움 (30일? 90일?)
- "참조" 신호 품질이 낮음 — 파일을 읽은 것이 곧 항목을 활용한 것을 의미하지 않음
- 구현 비용 대비 신뢰성이 낮음

**권고 여부: 비권고** — 항목 수준 참조 추적이 현재 인프라로 불가능하고, 파일 수준 추적으로는 decay 신호 품질이 너무 낮다. Phase 999.1 PageIndex 연동 이후 semantic search가 도입되면 재고.

---

## 증강/감쇄 갭 요약

| 항목 | 현재 상태 | 갭 |
|------|-----------|-----|
| 증강 — Observed 카운터 | SKILL.md에 정의, 실제 동작 미검증 | 시뮬레이션 필요 |
| 증강 — conflict blockquote | SKILL.md에 정의, 사용 사례 0건 | 시뮬레이션 필요 |
| 감쇄 — 수동 상태 변경 | 동작 중 (1건 [superseded]) | 반응형 전용, 자동화 없음 |
| 감쇄 — [uncertain] 상태 | 정의됨, 사용 사례 0건 | 충돌 시 자동 전환 미구현 |
| 감쇄 — [stale] 상태 | 미정의 | 시간 기반 decay 구현 시 추가 필요 |
| 감쇄 — 자동 decay | 없음 | 충돌 기반 방안 권고 |

---

## 컴파일 시뮬레이션 실행 지침 (D-03)

Phase 7 Plan에서 실제 시뮬레이션을 수행하는 task를 위한 지침:

**테스트 raw 항목 예시 (Observed 카운터 증가 검증용):**

```markdown
### HH:MM — index-first 패턴 재확인
- knowledge 참조 시 index.md를 먼저 읽어 관련 파일만 선택적으로 로드하는 방식이 효율적임을 다시 확인
- 전체 파일을 순차적으로 읽으면 컨텍스트 비용이 높고 무관 정보가 포함됨
- 결정: index-first 접근을 표준으로 유지 (기존 결정 재확인)
```

이 항목을 `.knowledge/raw/2026-04-14.md`에 추가하면 컴파일러가 decisions.md의 "index-first 접근 표준화" 항목과 동일 결론으로 인식해야 Observed 카운터를 증가시켜야 한다.

**테스트 raw 항목 예시 (conflict 감지 검증용):**

```markdown
### HH:MM — planner fallback compile 재검토
- planner가 fallback compile을 수행하는 것이 knowledge 최신성 유지에 도움이 되는 것으로 재고
- /gsd-knowledge-compile 수동 전용보다 planner 자동 compile이 더 신뢰성 있을 수 있음
```

이 항목은 decisions.md의 "GSD 프로세스 knowledge 최소 부하 원칙 (Phase 6)" (`[active]`)과 충돌한다. 컴파일러가 `[conflict:]` 태그를 추가해야 한다.

**Before/After 비교 체크리스트:**
1. decisions.md에서 "index-first 접근 표준화" 항목의 Observed 줄 존재 여부
2. decisions.md에서 "GSD 최소 부하 원칙" 항목에 `[conflict:]` 태그 추가 여부
3. 신규 항목이 중복으로 추가됐는지 확인 (fusion 실패 케이스)

---

## Architecture Patterns

### 증강 메커니즘 아키텍처

```
raw/*.md (새 항목)
    ↓ [Step 4: 변경 파일 읽기]
컴파일러 에이전트
    ↓ [Step 5: B+C fusion]
    ├── 동일 결론 감지 → decisions.md 해당 항목에 Observed 카운터 추가/증가
    ├── 반대 결론 감지 → [conflict:] 태그 + blockquote 추가
    └── 신규 결론 → 신규 항목 추가
        ↓ [Step 6: manifest 업데이트]
.planning/compile-manifest.json (last_compiled 갱신)
```

### 권고하는 충돌 기반 decay 아키텍처

```
반대 결론 감지 (현재)
    → [conflict:] 태그 + blockquote 추가
    + 상태를 [uncertain]으로 변경 (추가 사항)

[uncertain] 항목 처리 지침 (패치 추가 필요):
    - planner/researcher 패치: "[uncertain] 항목은 사용 전 사용자에게 확인 요청"
    - 컴파일러: 다음 컴파일 시 raw에 추가 증거가 있으면 재판단 → [active] 복귀 또는 [superseded] 확정
```

### Don't Hand-Roll

| 문제 | 만들려 할 것 | 대신 | 이유 |
|------|-------------|------|------|
| 항목 수준 참조 추적 | JSONL 파서 확장 | 현재 파일 수준 집계 유지 | 항목 수준 추적은 신호 품질이 낮고 구현 비용 높음 |
| 시간 기반 decay | compile-manifest에 날짜 매핑 | 충돌 기반 decay 우선 구현 | 참조 신호 품질 문제 해결 전 시간 기반은 노이즈 |
| conflict 탐지 알고리즘 | 별도 스크립트 | SKILL.md 프롬프트 수정 | 컴파일러 에이전트(LLM)가 이미 충분한 의미론적 판단 가능 |

---

## Common Pitfalls

### Pitfall 1: Observed 없음 = 버그로 오해
**What goes wrong:** decisions.md 대부분 항목에 Observed 카운터가 없는 것을 fusion 버그로 판단
**Why it happens:** 지금까지 raw 파일에 동일 결론을 반복한 항목이 없었을 수 있음
**How to avoid:** 시뮬레이션 전에 raw 파일 내용을 분석해 실제 중복 결론이 있었는지 확인
**Warning signs:** 시뮬레이션에서 테스트 항목 추가 후에도 Observed 증가가 없으면 버그

### Pitfall 2: [conflict:] 태그와 [uncertain] 상태 혼동
**What goes wrong:** conflict 태그를 추가하면서 상태를 바꾸지 않거나, 상태만 바꾸고 태그를 안 붙임
**Why it happens:** 현재 SKILL.md에 conflict 처리와 [uncertain] 상태 전환이 별도로 정의됨
**How to avoid:** 충돌 기반 decay 구현 시 두 동작을 하나의 규칙으로 묶어 SKILL.md에 명시

### Pitfall 3: 시뮬레이션 raw 항목이 "건너뛰는 항목"으로 분류됨
**What goes wrong:** 테스트용 raw 항목이 컴파일러의 선별 기준에서 "일회성 확인 작업"으로 분류되어 건너뜀
**Why it happens:** SKILL.md Step 5 "건너뛰는 항목: 일회성 검증 작업, 결과 없는 탐색"
**How to avoid:** 테스트 항목을 "결정/발견" 형식으로 작성하고, 실제 작업처럼 충분한 컨텍스트 포함

### Pitfall 4: compile-manifest.json mtime 기준으로 raw 파일 스킵
**What goes wrong:** 테스트 raw 항목을 추가한 날짜가 last_compiled와 같으면 "변경 없음"으로 스킵될 수 있음
**Why it happens:** SKILL.md Step 3: `last_compiled`보다 최신이거나 같은 파일만 처리. manifest의 last_compiled가 2026-04-13이고 오늘이 2026-04-14이면 정상 처리됨
**How to avoid:** 오늘 날짜(2026-04-14) raw 파일에 항목 추가 → compile-manifest의 last_compiled(2026-04-13)보다 최신이므로 정상 처리됨. 단, manifest에 이미 2026-04-13 mtime이 기록된 경우 mtime이 바뀌어야 함

---

## 최종 권고안

### 다음 Phase(Phase 8)에서 구현할 방향

**1순위: B+C fusion 검증 및 conflict-based decay 도입**

```
SKILL.md Step 5 수정 내용:
- 기존: 반대 결론 → [conflict:] 태그 + blockquote
- 변경: 반대 결론 → [conflict:] 태그 + blockquote + 상태 [uncertain]으로 변경
- 추가: [uncertain] 처리 지침 — 다음 컴파일에서 추가 증거 기반 재판단
```

**2순위: planner/researcher 패치에 [uncertain] 항목 처리 지침 추가**

```
패치 수정 내용:
- decisions.md에서 [uncertain] 항목 발견 시: 
  "이 결정은 불확실 상태입니다 — 사용 전 raw/ 최근 항목에서 추가 컨텍스트 확인 필요"
```

**비권고: 시간 기반 decay**
- 항목 수준 참조 추적 불가 (현재 인프라)
- 낮은 참조율(18세션 중 3개만 knowledge 읽음)로 threshold 설정 불가
- PageIndex 연동(Phase 999.1) 이후 재고

---

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | decisions.md의 Observed 없음이 대부분 fusion 미동작이 아닌 중복 raw 없음으로 인한 정상 상태 | 증강 검증 계획 | 낮음 — 시뮬레이션으로 직접 확인 |
| A2 | compile-manifest last_compiled 2026-04-13 → 오늘(2026-04-14) raw 파일은 mtime 기준 처리됨 | Pitfall 4 | 낮음 — 날짜 기반 로직이므로 예측 가능 |
| A3 | analyze_knowledge_reads.js가 항목 수준 추적 불가 (파일 수준만) | 방안 B 분석 | 없음 — 코드 직접 분석으로 VERIFIED |

---

## Open Questions

1. **fusion 로직 실제 동작 여부**
   - What we know: SKILL.md에 B+C fusion 정책이 텍스트로 정의됨, Observed 카운터 1건
   - What's unclear: LLM이 컴파일 시 실제로 기존 decisions.md와 비교해 동일 결론을 감지하는지
   - Recommendation: D-03 시뮬레이션으로 직접 확인 필요

2. **[uncertain] 상태를 위한 에이전트 지침 필요성**
   - What we know: planner/researcher 패치가 [rejected] 항목 처리 지침은 있음
   - What's unclear: [uncertain] 항목을 에이전트가 어떻게 처리해야 하는지 지침 없음
   - Recommendation: 충돌 기반 decay 구현 시 패치에 [uncertain] 처리 지침 동시 추가 필요

---

## Environment Availability

Phase 7은 기존 인프라만 사용하므로 추가 의존성 없음.

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| `/gsd-knowledge-compile` skill | D-03 시뮬레이션 | ✓ | 설치됨 | — |
| `analyze_knowledge_reads.js` | JSONL 참조율 재측정 | ✓ | `.planning/tools/` | — |
| `.knowledge/raw/2026-04-14.md` | 테스트 항목 추가 | ✓ (신규 생성) | — | — |

---

## Validation Architecture

nyquist_validation 키가 config.json에 없으므로 활성화됨. 단, Phase 7은 audit + 리서치 모드이므로 자동화 가능한 테스트가 제한적이다.

### Test Framework

| Property | Value |
|----------|-------|
| Framework | bash script (grep 기반 검증) |
| Config file | 없음 |
| Quick run command | `grep "Observed" .knowledge/knowledge/decisions.md` |
| Full suite command | 아래 Phase Requirements → Test Map 참조 |

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| D-03-reinforcement | Observed 카운터가 시뮬레이션 후 증가 | smoke | `grep -c "Observed" .knowledge/knowledge/decisions.md` | ✅ (decisions.md) |
| D-03-conflict | conflict 태그가 시뮬레이션 후 추가 | smoke | `grep "\[conflict:" .knowledge/knowledge/decisions.md` | ✅ (decisions.md) |
| D-04-report | RESEARCH.md 완성 여부 | manual | 파일 존재 확인 | ✅ 이 파일 |

### Wave 0 Gaps

- [ ] 테스트 raw 항목 작성 (`2026-04-14.md` 신규 항목) — D-03 시뮬레이션 전제조건

---

## Sources

### Primary (HIGH confidence)
- `skills/gsd-knowledge-compile/SKILL.md` — B+C fusion 정책, Step 5 전체 구조
- `.knowledge/knowledge/decisions.md` — 현재 15개 항목 상태 및 Observed 분포 분석
- `patches/gsd-phase-researcher.patch.md`, `patches/gsd-planner.patch.md` — conflict/uncertainty 처리 지침 부재 확인
- `.planning/tools/analyze_knowledge_reads.js` — 참조 추적 가능 범위(파일 수준만) 확인

### Secondary (MEDIUM confidence)
- `.planning/phases/06-gsd-knowledge/06-CONTEXT.md` D-22/D-23 — JSONL 측정 결과 및 Phase 6 결론
- `.knowledge/knowledge/index.md` — 전체 knowledge 구조 및 49개 항목 현황

### Tertiary (LOW confidence)
- 없음

---

## Metadata

**Confidence breakdown:**
- 현재 시스템 상태 분석: HIGH — 모든 파일 직접 읽기로 검증
- 증강 메커니즘 동작 여부: LOW — 시뮬레이션 미실행 (이 리서치의 핵심 불확실성)
- 충돌 기반 decay 구현 비용: HIGH — SKILL.md 구조 분석 기반
- 시간 기반 decay 비권고 근거: HIGH — analyze_knowledge_reads.js 코드 분석 + 실제 참조율 데이터

**Research date:** 2026-04-14
**Valid until:** 2026-05-14 (stable domain — knowledge compiler 내부 메커니즘)
