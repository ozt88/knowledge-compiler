# Phase 4: Knowledge Importance Prioritization - Research

**Researched:** 2026-04-09
**Domain:** Information Retrieval / RAG — 파일시스템 기반 관련성 접근 메커니즘
**Confidence:** HIGH (프로젝트 내부 구조 분석) / MEDIUM (IR/RAG 접근법 분야)

---

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

- **D-01:** 이 Phase는 리서치 우선 → 설계 → 구현 순서로 진행한다. Requirements가 TBD — RAG/IR 연구에서 접근법 학습 후 구체적 설계 결정. 리서치 없이 구현 방향을 확정하지 않는다.
- **D-02:** 탐색과 구현 모두 이 Phase에서 완료한다 (별도 Phase 분리 없음).
- **D-03:** "중요도는 쿼리 시점에 결정된다" — 정적 사전 스코어링이 아닌 **쿼리 기반 관련성** 모델을 채택한다. raw 항목을 저장할 때 중요도를 마킹하지 않는다. researcher/planner가 지식을 조회할 때 현재 컨텍스트와의 관련성으로 필요한 항목을 식별한다.
- **D-04:** 쿼리 주체는 **researcher/planner 서브에이전트**다 (사람이 직접 쿼리하는 시나리오는 1차 대상 아님).
- **D-05:** 파일시스템 기반 접근만 사용한다 — Read/Grep으로 접근, 벡터DB/MCP 불필요. 벡터 없이 의미 기반 접근이 가능한 방식을 RAG/IR 연구에서 탐색. PageIndex 방식은 v1.x 이후 별도 검토 (Backlog Phase 999.1).
- **D-06:** GSD 에이전트 패치 방식으로 배포 (`patches/` 디렉토리), install.sh가 패치 재적용 처리.
- **D-07:** 구체적 성공 기준은 RAG/IR 리서치 후 researcher/planner가 정의한다.

### Claude's Discretion

- RAG/IR 연구 중 발견한 접근법 중 파일시스템 제약에 맞지 않는 것은 researcher가 판단하여 제외
- 구현 세부 방식 (파일 구조, 메타데이터 형식 등)은 리서치 결과 기반으로 결정

### Deferred Ideas (OUT OF SCOPE)

- 구체적 구현 방식 — RAG/IR 리서치 후 researcher가 결정 (저장 형식, 메타데이터 구조 등)
- 정확한 UAT 기준 — 리서치 결과에 따라 측정 가능한 기준 정의
- PageIndex 연동 — Backlog Phase 999.1로 이미 등록, v1.x 이후 검토
- 사람이 직접 쿼리하는 시나리오 — 1차 대상 아님, 향후 별도 검토 가능

</user_constraints>

---

## Summary

Phase 4의 핵심 문제는 raw에 쌓인 205줄 31개 항목이 모두 동등하게 취급된다는 것이다. "논문 인용 검증" 같은 일회성 확인 작업과 "guardrails.md 도입" 같은 영구적 시스템 결정이 동일한 포맷으로 저장되며, 컴파일러(LLM)가 이 둘을 구분할 근거를 갖지 못한다.

해법의 방향은 D-03이 명확히 제시한다: "중요도는 쿼리 시점에 결정된다". 이는 정적 스코어링이 아니라 **쿼리 컨텍스트에 맞는 항목을 효율적으로 찾을 수 있는 구조**가 필요하다는 뜻이다. RAG/IR 분야의 벡터 없는 접근법을 검토한 결과, 이 시스템에 적합한 방식은 두 계층의 조합이다: (1) **컴파일 타임 신호 추가** — raw 항목에 타입/중요도 힌트를 붙여 컴파일러가 올바른 knowledge 파일에 배치하도록 돕고, (2) **index.md 구조 강화** — 쿼리 에이전트가 index.md 하나만 읽어도 어떤 파일에서 무엇을 찾아야 하는지 알 수 있도록 한다.

두 번째 전선은 컴파일 로직 자체다. 현재 컴파일러(Step 0 / Step 10b)는 raw 전체를 동등하게 처리한다. 이 Phase에서는 컴파일러 지시에 **선별 기준**을 추가한다 — 어떤 raw 항목이 knowledge 파일에 포함될 자격이 있는지, 그리고 어떤 항목을 건너뛰어도 되는지.

**Primary recommendation:** raw 수집 시 타입 힌트를 추가하고(수집 지시 강화), 컴파일러 지시에 선별 기준과 index.md 강화 지시를 추가하며, 에이전트가 knowledge를 조회하는 방식을 index-first 접근으로 표준화한다. 세 가지 모두 파일시스템 기반으로 동작하며 추가 인프라가 필요하지 않다.

---

## 현재 시스템 분석 (문제 진단)

### raw 파일 현황

| 항목 | 수치 |
|------|------|
| raw 파일 수 | 3개 (2026-04-07, 08, 09) |
| 총 라인 수 | 205줄 |
| 총 항목 수 | 31개 |
| 항목 형식 | `### HH:MM — 한줄 제목` + 2-3줄 요약 |

### 항목 유형 분류 (사후 분석)

raw 항목 31개를 직접 읽어 사후 분류한 결과:

| 유형 | 설명 | 예시 | 추정 비율 |
|------|------|------|-----------|
| **결정** | 시스템 설계 또는 접근법 결정 — 미래 세션에 영향 | "guardrails.md 도입", "CLAUDE.md 행동 지시 채택" | ~25% |
| **실행 완료** | Phase/Plan 완료 이벤트 — 상태 추적에 필요 | "Phase 1 검증 완료", "Phase 02-01 실행" | ~35% |
| **발견** | 중요한 기술적 발견 — 재발 방지에 필요 | "docs 커밋이 feat 변경사항 되돌림 발견", "gsd-tools 버그" | ~15% |
| **확인/상태 점검** | 진행 상황 확인 — 일회성 | "Phase 2 완료 확인", "프로젝트 진행 상황 확인" | ~15% |
| **일회성 작업** | 재사용 가치 없는 단순 작업 | "논문 인용 정확도 검증", "/gsd:add-phase 인수 없이 호출" | ~10% |

**핵심 관찰:** 컴파일러가 "결정"과 "일회성 작업"을 구분하지 못하면, 지식의 품질이 낮아진다. 현재 컴파일러에는 이 구분 기준이 없다.

### 현재 knowledge 접근 패턴의 문제

현재 패치(Step 0 / Step 10b)의 컴파일 지시:
1. raw 전체를 읽는다
2. decisions.md / guardrails.md / anti-patterns.md / troubleshooting.md / index.md로 분류한다
3. 기존 파일을 읽고 병합한다

**누락된 것:**
- "이 raw 항목이 knowledge에 포함될 가치가 있는가?" 판단 기준 없음
- index.md가 어떤 정보를 포함해야 하는지 형식 지시 없음
- 에이전트가 knowledge를 어떤 순서로 접근해야 하는지 표준이 없음

---

## IR/RAG 접근법 분석 (파일시스템 제약 내)

### Q1: 벡터 없이 문서 관련성을 판단하는 접근법

**A. BM25 / TF-IDF**

| 속성 | 내용 |
|------|------|
| 동작 방식 | 단어 빈도(TF)와 문서 집합 내 역빈도(IDF)로 문서-쿼리 관련성 점수 계산 |
| 파일시스템 적용 가능성 | 부분적 — 키워드 매칭(TF)은 Grep으로 가능. 전체 말뭉치 IDF 계산은 Python 라이브러리 필요 |
| 제약 충돌 | D-05: Read/Grep만 사용 → IDF 계산 불가. 완전한 BM25 구현은 제약 위반 |
| 결론 | **제외** — 부분 적용은 가능하나 BM25의 핵심 이점(IDF)을 활용할 수 없음 |

**B. 구조적 메타데이터 태깅 (Structural Metadata Tagging)**

| 속성 | 내용 |
|------|------|
| 동작 방식 | 문서/항목에 타입, 주제, 관련 컨텍스트 태그를 붙여 Grep 기반 필터링 가능하게 함 |
| 파일시스템 적용 가능성 | 완전 적용 가능 — Read/Grep으로 태그 기반 검색 |
| 이 시스템 적합성 | knowledge 파일 구조(guardrails/anti-patterns/decisions)가 이미 구조적 분류. raw 항목 타입 힌트 추가로 강화 가능 |
| 결론 | **채택 추천** — 파일시스템 제약 완전 충족, 구현 단순 |

**C. 계층적 인덱스 (Hierarchical Index)**

| 속성 | 내용 |
|------|------|
| 동작 방식 | 상위 인덱스(index.md)가 주제별 항목 위치를 안내 → 에이전트가 전체 파일 로드 없이 targeted 접근 |
| 파일시스템 적용 가능성 | 완전 적용 가능 — index.md 읽기 → 관련 파일만 선택적 Read |
| 현재 상태 | index.md는 존재하지만 "어떤 쿼리에 어떤 파일을 읽어야 하는가" 안내 기능 미흡 |
| 결론 | **채택 추천** — 현재 구조 확장으로 구현 가능 |

**D. 컴파일 타임 선별 (Compile-time Triage)**

| 속성 | 내용 |
|------|------|
| 동작 방식 | 컴파일러(LLM)가 raw 항목을 읽으며 "지식 가치" 판단 — 일회성 항목은 스킵하거나 가볍게 처리 |
| 파일시스템 적용 가능성 | 완전 적용 가능 — 컴파일러 프롬프트에 기준 추가 |
| 유사 시스템 사례 | MemGPT의 "working memory → archival memory" 승격 메커니즘과 유사 (컴파일러가 승격 판단) |
| 결론 | **채택 추천** — 컴파일러 지시 확장으로 구현 가능, 추가 인프라 없음 |

**E. MMR (Maximal Marginal Relevance) — 다양성 기반 재순위**

| 속성 | 내용 |
|------|------|
| 동작 방식 | 관련성과 중복성을 균형 잡아 결과 다양성 확보 |
| 파일시스템 적용 가능성 | 파일 수준에서 적용 어려움 — 벡터 유사도 없이 중복성 계산 복잡 |
| 결론 | **제외** — 구현 복잡성 대비 현 시스템 규모에서 이점 미미 |

### Q2: 유사 파일시스템 기반 knowledge 시스템의 패턴

**Karpathy의 "마크다운 + 인덱스" 통찰 (DESIGN.md에 기록됨)**

> "개인 규모에서는 마크다운 + 인덱스면 충분" — 벡터DB 없이 구조화된 마크다운 파일과 계층 인덱스로 충분한 접근성 달성.

이 통찰의 함의: 중요도 문제는 "더 복잡한 검색 알고리즘"이 아니라 **"컴파일 시 더 잘 구조화하기"**로 해결한다.

**CLAUDE.md / memory.md 패턴 (Claude Code 생태계)**

```
memory.md 200줄 제한 → 핵심 정보만 유지 → 키워드 매칭 기반 접근
```

이 패턴의 핵심은 저장 전 선별이다. 모든 것을 저장하지 않고, 재사용 가치가 있는 것만 유지한다. knowledge-compiler가 채택해야 할 원칙이다.

**GSD researcher Step 0 현재 패턴**

현재 패치는 index.md를 "전체 요약 + 키워드 인덱스"로 정의하지만, 어떤 키워드 인덱스인지 지정하지 않는다. 에이전트가 "relevant" 항목을 찾으려면 index.md가 더 구체적인 안내를 제공해야 한다.

### Q3: 에이전트가 relevant knowledge를 찾는 최소 메커니즘

**현재 접근 흐름 (문제)**:
```
에이전트 → raw/ 전체 읽기 OR knowledge/ 전체 읽기 → 관련 항목 찾기
```
컨텍스트 비용: 전체 로드 필요, 관련 없는 정보 포함.

**개선 접근 흐름 (목표)**:
```
에이전트 → index.md 읽기 → 관련 파일/섹션 식별 → 해당 파일만 선택적 읽기
```
컨텍스트 비용: index.md(소규모) + 관련 파일만.

**이를 위해 필요한 것:**
1. index.md가 "주제 → 파일" 매핑을 포함해야 함
2. 컴파일러가 index.md를 "쿼리 안내 문서"로 생성해야 함
3. 에이전트 접근 지시가 "index.md 먼저 읽고 필요한 파일만 읽어라"로 명시되어야 함

### Q4: 컴파일러 수정이 필요한 지점

**현재 패치 지시의 gap:**

| 현재 지시 | 누락된 내용 |
|----------|------------|
| "raw 전체를 읽어 knowledge로 컴파일하라" | "어떤 항목을 포함하고 어떤 것을 건너뛸지" 기준 없음 |
| "index.md — 전체 요약 + 키워드 인덱스" | index.md 형식이 없어 에이전트가 쿼리 안내로 활용 불가 |
| 없음 | "일회성 항목 vs. 영구적 지식" 구분 기준 없음 |

**수정이 필요한 위치:**
1. `patches/gsd-phase-researcher.patch.md` Step 0 — 컴파일 지시에 선별 기준 + index.md 형식 추가
2. `patches/gsd-verifier.patch.md` Step 10b — 동일 변경 (D-08 패턴: 양쪽에 독립적 중복)

**수정이 필요하지 않은 위치 (범위 밖):**
- `CLAUDE.md` 턴 수집 지시 — raw 수집 자체는 현행 유지. 타입 힌트 추가는 옵션으로 검토.
- `install.sh` — 배포 메커니즘 변경 불필요

### Q5: 성공 기준 (리서치 기반 정의)

RAG/IR 원칙과 현 시스템 분석을 기반으로 다음 측정 가능한 기준을 제안한다:

| 기준 | 측정 방법 |
|------|----------|
| 컴파일러가 일회성 항목을 knowledge 파일에서 제외한다 | 컴파일 후 knowledge 파일에 "논문 인용 확인", "진행 상황 확인" 류 항목이 없어야 함 |
| index.md가 "주제 → 파일" 매핑을 포함한다 | index.md에 파일별 관련 주제 목록이 있어야 함 |
| 에이전트 지시가 index-first 접근을 명시한다 | 패치 지시에 "index.md 먼저 읽어라" 지시 포함 여부 grep 확인 |
| 두 패치가 동일한 선별 기준을 포함한다 | D-08 패턴 — diff로 동일성 확인 |

---

## Standard Stack

### Core (파일시스템 기반, 추가 도구 없음)

| 구성 요소 | 역할 | 구현 방식 |
|----------|------|----------|
| `patches/gsd-phase-researcher.patch.md` Step 0 | 컴파일 타임 선별 기준 + index.md 형식 지시 추가 | 마크다운 편집 |
| `patches/gsd-verifier.patch.md` Step 10b | 동일 변경 (D-08: 독립적 중복) | 마크다운 편집 |

### 채택된 IR 접근법 조합

| 접근법 | 역할 | 구현 위치 |
|--------|------|----------|
| 컴파일 타임 선별 | raw 항목 중 knowledge 가치 있는 것만 포함 | 컴파일러 지시 (패치 파일) |
| 구조적 분류 | 항목 유형별 올바른 knowledge 파일 배치 | 기존 구조 유지 + 선별 기준 추가 |
| 계층적 인덱스 강화 | index.md를 쿼리 안내 문서로 만들기 | index.md 형식 지시 추가 |
| index-first 접근 표준화 | 에이전트가 전체 파일 로드 없이 targeted 접근 | Step 0 "During research" 지시 개선 |

### 제외된 접근법 (사유)

| 접근법 | 제외 이유 |
|--------|----------|
| BM25/TF-IDF 완전 구현 | D-05 위반 — Python 라이브러리 필요 |
| 벡터 임베딩 | D-05 위반 — 명시적 Out of Scope |
| PageIndex MCP 연동 | Backlog Phase 999.1 — 명시적 Deferred |
| 수동 중요도 마킹 | D-03 위반 — 저장 시점 마킹 금지 |
| MMR 재순위 | 현 시스템 규모에서 이점 미미, 구현 복잡성 과다 |

---

## Architecture Patterns

### 추천 구조: 3계층 접근

```
Layer 1: raw/ (수집) — 현행 유지
  └── HH:MM — 타입: 제목 형식 (옵션 강화)

Layer 2: knowledge/ (컴파일) — 컴파일러 선별 강화
  ├── index.md         — 쿼리 안내 문서 (주제→파일 매핑 포함)
  ├── decisions.md     — 영구적 결정 (active/rejected/superseded)
  ├── guardrails.md    — 절대적 케이스 긍정형 액션
  ├── anti-patterns.md — 맥락 의존적 케이스
  └── troubleshooting.md — 에러↔해결 매핑

Layer 3: 에이전트 접근 (조회) — index-first 표준화
  └── index.md 먼저 읽기 → 관련 파일만 선택 Read
```

### Pattern 1: 컴파일 타임 선별 기준

**What:** 컴파일러 지시에 "어떤 raw 항목을 knowledge에 포함하는가" 기준 추가

**선별 기준 (연구 기반 설계):**

```markdown
## raw 항목 선별 기준

knowledge에 포함하는 항목:
- 미래 세션에서 동일한 실수를 방지하는 결정 또는 발견
- 시스템 동작을 설명하는 구조적 지식 (guardrails, anti-patterns)
- 에러와 해결 방법 매핑 (재발 가능성 있는 문제)
- 프로젝트 상태 변화를 추적하는 완료 이벤트

knowledge에서 제외하는 항목:
- 일회성 확인 작업 (논문 인용 검증, 진행 상황 점검)
- 해결 없이 종료된 탐색 시도 (시도 → 포기)
- 프로세스 단계 보고 (단순 실행 완료 알림)
- 동일 항목의 중복 기록
```

### Pattern 2: index.md 쿼리 안내 형식

**What:** index.md가 "어떤 주제를 찾으려면 어떤 파일을 읽어라"를 명시

**목표 index.md 형식:**

```markdown
# Knowledge Index

**Last compiled:** YYYY-MM-DD
**Total entries:** N

## Quick Reference — 주제별 파일 안내

| 주제 | 파일 | 핵심 항목 |
|------|------|----------|
| 컴파일러 프롬프트 관련 | guardrails.md, anti-patterns.md | 긍정형 전환 원칙 |
| 설치/패치 관련 | troubleshooting.md | install.sh --force 옵션 |
| 프로젝트 결정 이력 | decisions.md | GSD 패치 방식, CLAUDE.md 수집 |
| 시스템 구조 | guardrails.md | raw→knowledge 파이프라인 |

## 전체 요약

[프로젝트 상태 요약]

## 키워드 인덱스

[키워드 → 파일#섹션 매핑]
```

### Pattern 3: index-first 에이전트 접근 표준

**What:** 에이전트가 knowledge를 조회할 때 index.md를 진입점으로 사용

**현재 지시 (개선 전):**
```markdown
**During research (Step 3):** Also search `.knowledge/knowledge/` for findings relevant to this phase.
```

**개선 지시:**
```markdown
**During research (Step 3):** knowledge/ 조회 순서:
1. `.knowledge/knowledge/index.md`를 읽어 관련 주제 파악
2. index.md의 "Quick Reference" 표에서 현재 Phase와 관련된 파일 식별
3. 식별된 파일만 선택적으로 Read — 전체 파일 로드 불필요
```

### Anti-Patterns to Avoid

- **raw 전체를 항상 재컴파일하면서 선별 기준 없이 모두 포함:** 지식의 희석 발생. 컴파일러 지시에 명시적 선별 기준 필수.
- **index.md를 단순 요약으로만 유지:** 에이전트가 관련 파일을 찾으려면 전체 파일을 다 읽어야 함. index.md는 쿼리 안내 역할을 해야 함.
- **researcher/verifier 패치 중 하나만 수정:** D-08 위반. 두 패치 모두 동일하게 수정 필수.
- **raw 수집 시 중요도 마킹 추가:** D-03 위반. 저장 시점 마킹은 채택되지 않은 방식.

---

## Don't Hand-Roll

| 문제 | 하지 말 것 | 대신 |
|------|-----------|------|
| 관련성 계산 | BM25/TF-IDF 구현 | 구조적 분류 + index.md 안내 (파일시스템 제약 내) |
| 중요도 스코어링 | 수치 점수 시스템 구축 | 컴파일 타임 선별 기준 (포함/제외 판단) |
| 벡터 검색 | 임베딩 생성 인프라 | 계층적 인덱스 + keyword Grep |
| 복잡한 태그 시스템 | 다중 메타데이터 스키마 | 단순 타입 힌트 (결정/발견/완료/일회성) |
| verifier만 수정 | researcher 패치 무시 | 두 패치 독립적 동일 수정 (D-08) |

**Key insight:** 이 시스템의 "중요도 판단"은 런타임이 아니라 **컴파일 타임에 LLM이 수행한다**. 복잡한 알고리즘이 아니라 잘 설계된 컴파일러 프롬프트가 핵심이다.

---

## Common Pitfalls

### Pitfall 1: 선별 기준이 너무 엄격해 knowledge가 비어버림
**What goes wrong:** 컴파일러가 "일회성 항목 제외" 기준을 과도하게 적용해 완료 이벤트, 중요한 상태 변화까지 제외
**Why it happens:** 선별 기준이 명확하지 않으면 LLM이 보수적으로 해석
**How to avoid:** 선별 기준을 "포함하는 항목" 중심으로 긍정형으로 기술 (Pink Elephant 원칙 적용). "제외"가 아니라 "포함 기준 충족 여부"로 판단.
**Warning signs:** 컴파일 후 knowledge/ 파일이 비거나 이전보다 적은 항목 포함

### Pitfall 2: index.md가 쿼리 안내 역할을 못함
**What goes wrong:** index.md가 단순 요약으로 생성되어 "어떤 파일에서 무엇을 찾아야 하는지" 안내 없음
**Why it happens:** 형식 지시 없으면 컴파일러가 자유형식 요약 생성
**How to avoid:** index.md에 "Quick Reference — 주제별 파일 안내" 테이블 형식 지시를 패치에 명시
**Warning signs:** index.md에 파일별 주제 매핑 없이 산문 형식만 있는 경우

### Pitfall 3: 컴파일 선별 기준이 두 패치에서 달라짐
**What goes wrong:** researcher 패치와 verifier 패치의 선별 기준이 미묘하게 달라져 incremental과 full reconcile 결과가 불일치
**Why it happens:** 각 패치를 별도로 편집하다가 표현 차이 발생
**How to avoid:** D-08 패턴 — 선별 기준 블록을 먼저 완성한 후 동일하게 복사. diff로 동일성 검증.
**Warning signs:** researcher와 verifier 컴파일 결과가 동일 raw에서 다른 항목을 포함하는 경우

### Pitfall 4: "쿼리 시점 중요도" 철학을 오해해 런타임 스코어링 구현
**What goes wrong:** D-03의 "쿼리 시점 결정"을 오해해 에이전트 조회 시 실시간 점수 계산 로직 추가 시도
**Why it happens:** "쿼리 시점"을 "쿼리 시 동적 계산"으로 해석
**How to avoid:** D-03의 실제 의미: 항목의 중요도는 어떤 쿼리를 받느냐에 따라 달라진다 → 따라서 정적 스코어링 불필요. index.md가 쿼리 컨텍스트에 맞는 파일을 안내하는 것이 구현.
**Warning signs:** Python 스크립트, 별도 실행 파일, 동적 점수 계산 코드 등장 시

### Pitfall 5: raw 수집 형식 변경으로 기존 파일과 호환성 파괴
**What goes wrong:** 타입 힌트 추가를 위해 raw 파일 형식을 변경하면 기존 2026-04-07, 08, 09 파일이 새 형식과 불일치
**Why it happens:** 수집 형식 변경의 하위 호환성을 고려하지 않음
**How to avoid:** raw 수집 형식 변경은 옵션으로만 검토. 컴파일러가 타입 힌트 없이도 항목을 분류할 수 있어야 한다 (타입 힌트는 있으면 좋고 없어도 동작).
**Warning signs:** 타입 힌트 없는 기존 항목을 컴파일러가 처리 못하거나 에러로 취급

---

## Code Examples

### 컴파일러 선별 기준 지시 (패치에 추가될 내용)

```markdown
   **raw 항목 선별 기준 — knowledge에 포함하는 항목:**
   - 미래 세션에서 동일한 실수를 방지하는 결정 또는 기술적 발견
   - 시스템 동작, 제약, 설계 원칙에 대한 구조적 지식
   - 재발 가능한 에러와 그 해결 방법
   - 프로젝트 상태를 변화시킨 주요 완료 이벤트 (Phase 완료, 설계 결정 등)

   **포함하지 않는 항목 (건너뛰기):**
   - 일회성 확인 작업 또는 상태 점검 (진행 상황 확인, 단순 조회)
   - 결과 없이 종료된 단순 탐색 시도
   - 이미 포함된 항목의 중복 기록
```

### index.md 형식 지시 (패치에 추가될 내용)

```markdown
   - `index.md` — 다음 형식으로 생성한다:
     - 맨 위에 "Last compiled", "Total entries" 메타 정보
     - "Quick Reference" 테이블: 주제 | 파일 | 핵심 항목 (에이전트가 index.md만 읽어도 어떤 파일로 갈지 알 수 있도록)
     - 전체 요약 단락
     - 키워드 인덱스 (키워드 → 파일#섹션)
```

### index-first 접근 지시 (패치 "During research" 섹션 개선)

```markdown
**During research (Step 3):** knowledge/ 조회 순서:
- `decisions.md` — `[rejected]` 항목을 확인하고 대안 접근법을 선택하라
- `anti-patterns.md` — 목록을 확인하고 연구 추천에서 검증된 패턴을 우선 적용하라
- `troubleshooting.md` — 이미 해결된 문제를 확인하고 새로운 미해결 문제에 집중하라

**조회 순서:** index.md를 먼저 읽어 현재 Phase와 관련된 파일을 파악한 후, 해당 파일만 선택적으로 Read하라.
```

---

## State of the Art

| 이전 방식 | 현재 방식 (Phase 4 후) | 변경 이유 |
|----------|----------------------|----------|
| raw 전체 동등 처리 | 컴파일 타임 선별 — 가치 있는 항목만 포함 | 사소한 항목과 중요한 결정이 동등 취급되면 지식 품질 저하 |
| index.md = 자유형식 요약 | index.md = 쿼리 안내 문서 (주제→파일 매핑) | 에이전트가 targeted 접근 가능하도록 |
| 에이전트가 knowledge/ 전체 읽기 | index.md 먼저 → 관련 파일만 선택 Read | 컨텍스트 비용 절감, 관련성 향상 |
| 선별 기준 없는 컴파일 | 명시적 포함/제외 기준 포함 | 컴파일러가 "지식 가치" 판단 기준을 가짐 |

**Deprecated:**
- raw 항목 전량 knowledge 포함 방식: Phase 4 이후 선별 기준 기반으로 대체
- index.md 단순 요약 역할: Phase 4 이후 쿼리 안내 문서로 확장

---

## Open Questions

1. **raw 수집 시 타입 힌트 추가 여부**
   - What we know: D-03에 따라 저장 시점 중요도 마킹은 채택 안 함. 그러나 타입 힌트(결정/발견/완료/일회성)는 마킹이 아니라 분류 힌트.
   - What's unclear: 타입 힌트가 CLAUDE.md 수집 지시를 복잡하게 만들어 준수율을 떨어뜨리는지
   - Recommendation: planner가 결정. 옵션 A: 타입 힌트 없이 컴파일러만 강화 (단순한 방향). 옵션 B: 제목에 `[결정]`, `[발견]` 태그 추가 (컴파일러 보조). 리스크 측면에서 옵션 A 우선 권장.

2. **기존 raw 파일과의 하위 호환성**
   - What we know: 현재 raw 파일 3개(205줄)에 타입 힌트 없음. 컴파일러 선별 기준이 타입 힌트 없이도 동작해야 함.
   - What's unclear: LLM이 타입 힌트 없이 "일회성 항목 vs. 지식 가치 있는 항목"을 얼마나 정확하게 구분하는지
   - Recommendation: 컴파일러 지시에 "타입 힌트가 없어도 항목 내용으로 판단하라" 명시. 선별 기준을 충분히 구체적으로 작성해 힌트 없이도 동작하도록.

3. **선별 기준 적용의 보수성 조정**
   - What we know: Phase 4 성공 기준 중 하나는 "컴파일러가 일회성 항목을 제외한다"
   - What's unclear: "너무 많이 제외"와 "너무 적게 제외"의 균형점
   - Recommendation: 검증 단계에서 실제 컴파일 결과를 확인하여 조정. 초기 기준은 "포함 기준 충족 여부"(긍정형)로 설계해 보수적 제외를 방지.

---

## Environment Availability

Step 2.6: SKIPPED — 순수 마크다운 패치 파일 편집, 외부 도구/서비스 의존성 없음. Read/Grep/Write 도구만 사용.

---

## Validation Architecture

`.planning/config.json` 미존재 → nyquist_validation 활성화로 처리. 이 프로젝트는 코드 없는 마크다운 패치 파일 편집이므로 자동화 테스트 프레임워크 해당 없음. 검증은 텍스트 패턴 매칭(grep)으로 수행한다.

### Phase Requirements → Test Map

Phase 4 요구사항은 TBD이나 리서치 기반으로 예상 요구사항을 정의한다:

| 예상 Req ID | Behavior | Test Type | Automated Command |
|------------|----------|-----------|-------------------|
| RELEVANCE-01 | 컴파일러 지시에 선별 기준 포함 | manual grep | `grep -c "포함하는 항목\|포함하지 않는 항목\|건너뛰기" patches/gsd-phase-researcher.patch.md` |
| RELEVANCE-02 | index.md 형식 지시에 "Quick Reference" 또는 주제→파일 매핑 포함 | manual grep | `grep -c "Quick Reference\|주제\|파일 안내" patches/gsd-phase-researcher.patch.md` |
| RELEVANCE-03 | index-first 접근 지시 포함 | manual grep | `grep -c "index.md.*먼저\|index.md 경유" patches/gsd-phase-researcher.patch.md` |
| RELEVANCE-04 | 두 패치의 선별 기준이 동일 | diff | `diff <(grep -A10 "선별 기준" patches/gsd-phase-researcher.patch.md) <(grep -A10 "선별 기준" patches/gsd-verifier.patch.md)` |

### Wave 0 Gaps

없음 — 기존 grep 검증 인프라가 Phase 요구사항을 커버함.

---

## Sources

### Primary (HIGH confidence)
- `/home/ozt88/knowledge-compiler/.planning/phases/04-knowledge-importance-prioritization-scoring/04-CONTEXT.md` — 잠긴 결정 D-01~D-07, 범위 정의
- `/home/ozt88/knowledge-compiler/.planning/phases/04-knowledge-importance-prioritization-scoring/04-DISCUSSION-LOG.md` — 사용자 선택 및 논의 기록
- `/home/ozt88/knowledge-compiler/.knowledge/raw/*.md` — 실제 raw 파일 구조 및 항목 유형 분석 (31개 항목 직접 읽기)
- `/home/ozt88/knowledge-compiler/patches/gsd-phase-researcher.patch.md` — 현재 컴파일러 지시 구조, 수정 위치 확인
- `/home/ozt88/knowledge-compiler/patches/gsd-verifier.patch.md` — 현재 full reconcile 지시 구조
- `/home/ozt88/knowledge-compiler/docs/DESIGN.md` — "마크다운 + 인덱스면 충분" 설계 원칙, 파이프라인 구조
- `/home/ozt88/knowledge-compiler/.planning/PROJECT.md` — 핵심 제약 (파일시스템 기반, MCP 불필요)

### Secondary (MEDIUM confidence)
- IR/RAG 도메인 지식 (훈련 데이터 기반) — BM25/TF-IDF/MMR 접근법 분석. WebSearch 도구 불가(모델 오류) — 훈련 데이터로 대체. 기본 원리는 안정적이나 최신 구현 세부사항은 추가 검증 권장.
- MemGPT 메모리 관리 패턴 — working memory → archival memory 승격 메커니즘 유사성 (훈련 데이터 기반)
- Karpathy "마크다운 + 인덱스" 통찰 — DESIGN.md에 기록된 내용 기반 (HIGH confidence for project context)

---

## Metadata

**Confidence breakdown:**
- 현재 시스템 분석: HIGH — 파일 직접 읽기, 31개 항목 사후 분류 완료
- 수정 위치 (두 패치 파일): HIGH — 파일 구조 확인 완료
- IR/RAG 접근법 분류: MEDIUM — 훈련 데이터 기반, WebSearch 불가로 외부 검증 없음
- 제안된 구현 방식 (컴파일러 지시): HIGH — 기존 패턴(D-08, 긍정형 지시) 기반, 프로젝트 패턴과 일치
- 선별 기준 효과: LOW — 실제 컴파일 실행 전 검증 불가, 플래너 단계에서 검증 시나리오 설계 필요

**Research date:** 2026-04-09
**Valid until:** 두 패치 파일 수정 전까지 (패치 구조 안정적). IR/RAG 분야 부분은 30일 이내 재검증 권장.
