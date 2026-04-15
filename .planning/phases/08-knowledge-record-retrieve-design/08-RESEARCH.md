# Phase 8: Knowledge Record & Retrieve Design - Research

**Researched:** 2026-04-14
**Domain:** Knowledge compiler 기록 메타데이터 설계 + B+C fusion 증강/감쇄 구현 + 조회 활용 개선
**Confidence:** HIGH

---

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

- **D-01: 기록과 조회의 통합 설계** — 기록 메타데이터 형식이 조회 가능성의 상한선을 결정한다. 기록 방식과 조회 방식을 독립적으로 설계하지 않고 하나의 일관된 설계 아래 둔다.

- **D-02: Phase 8 범위 (세 가지를 하나로)** — Phase 7 권고안 구현에 더해 다음 세 가지를 하나의 Phase로 묶는다:
  1. 기록 메타데이터 설계 — 항목에 context 태그 등 구조 추가
  2. 증강/감쇄 구현 — Phase 7 RESEARCH.md 권고안 기반
  3. 조회 활용 개선 — 항목 필터링, 우선순위, uncertain/superseded 처리

- **D-03: 신규 증강 방법론 리서치 포함** — 현행 B+C fusion 검증 결과를 바탕으로, 더 나은 증강 방법도 Phase 8 리서치 범위에 포함:
  - 신뢰도 가중치 — Observed 횟수에 따라 항목 신뢰도 수치화
  - Cross-session 합산 — 여러 세션에서 독립적으로 같은 결론 도달 시 가중치 증가
  - 사용 컨텍스트 태깅 — 어떤 Phase/task 유형에서 참조됐는지 메타데이터

- **D-04: 조회 시점 활용 개선 방향** —
  - 기록 시 항목에 context 태그 추가 (기록 메타데이터 설계와 직결)
  - `[uncertain]` 항목 조회 시 경고 표시
  - `[superseded]` 항목 조회에서 제외 또는 별도 표시
  - 조회 우선순위: Observed 높은 항목 > 최근 기록 항목 > 나머지

### Claude's Discretion

- context 태그 구체적 분류 체계 (어떤 카테고리로 나눌지)
- 조회 우선순위 구현 방식 (SKILL.md 지시 vs 별도 index 구조)
- Phase 7 시뮬레이션 결과에 따라 일부 결정 변경 가능 (D-03은 Phase 7 완료 후 확정)

### Deferred Ideas (OUT OF SCOPE)

- PageIndex(Phase 999.1) semantic search 연동 — 지식 규모가 충분히 커진 v1.x 이후
- JSONL 참조 추적 강화 (항목 수준 참조율) — PageIndex 연동 이후 재고
- 시간 기반 decay — Phase 7 비권고, PageIndex 이후 재고

</user_constraints>

---

## Summary

Phase 8의 목표는 세 가지 서로 연결된 작업을 하나의 일관된 설계로 구현하는 것이다: (1) decisions.md 항목 메타데이터 구조 추가, (2) Phase 7 권고안(충돌 기반 decay) 구현, (3) 에이전트 패치에서 조회 품질 개선.

**현재 기반 상태.** decisions.md는 15개 항목이 `## 제목` + `시도/결과/결정/상태` 형식으로 저장되어 있다. Observed 카운터는 1개 항목에만 존재하며, context 태그나 신뢰도 메타데이터는 전혀 없다. SKILL.md Step 5의 B+C fusion 정책은 텍스트 지시로만 존재하고, 충돌 시 `[uncertain]` 상태 자동 전환이 없다. 패치 파일들은 `[rejected]` 항목 처리 지침은 있지만 `[uncertain]`/`[superseded]` 특별 처리 지침은 없다.

**Phase 7 핵심 권고안.** SKILL.md Step 5 수정(반대 결론 → `[uncertain]` 상태 전환 추가)이 1순위, 패치 파일에 `[uncertain]` 처리 지침 추가가 2순위다. 시간 기반 decay는 현재 인프라로 구현 불가하여 비권고.

**Primary recommendation:** SKILL.md Step 5 → 패치 파일 → decisions.md 항목 형태를 이 순서로 수정한다. 메타데이터 설계(context 태그)는 기록 형식을 먼저 확정한 뒤 SKILL.md 지시에 추가하고, 기존 항목에도 소급 적용한다.

---

## 현재 시스템 아키텍처

### decisions.md 항목 현재 형식
[VERIFIED: decisions.md 직접 읽기]

```markdown
## 설계 결정 — [제목]

**시도:** [...]
**결과:** [...]
**결정:** [...]
**상태:** [active|rejected|superseded|uncertain]
```

선택적으로:
```markdown
**Observed:** N times (date1, date2, ...)
```

**현재 메타데이터 부재 항목:**
- context 태그 (어느 Phase/task 유형에서 유효한지)
- 신뢰도 수치
- 기록 날짜 (항목별 추가일)

### B+C fusion 정책 현재 코드
[VERIFIED: SKILL.md Step 5 직접 읽기]

```
**B+C fusion 정책:**
- 동일 결론 재확인 → `**Observed:** N times (date1, date2, ...)` 줄 추가 또는 카운트 증가
- 반대 결론 → `[conflict: YYYY-MM-DD]` 태그 추가 + `> **New (YYYY-MM-DD):**` blockquote로 새 내용 보존
```

**갭:** 반대 결론 시 `[uncertain]` 상태 전환이 없다. conflict 태그만 추가하고 상태는 유지됨.

### 패치 파일 현재 조회 지침
[VERIFIED: 패치 파일 직접 읽기]

**gsd-phase-researcher.patch.md:**
```
decisions.md — Check [rejected] entries and choose an alternative approach
```

**gsd-planner.patch.md:**
```
decisions.md — Check [rejected] entries; do NOT plan tasks using rejected approaches
```

**갭:** `[uncertain]` 항목 처리 지침 없음. `[superseded]` 항목 처리 지침 없음. 조회 우선순위(Observed 높은 항목 우선) 지침 없음.

---

## Architecture Patterns

### 권고 decisions.md 항목 형태 (Phase 8 목표)
[ASSUMED — CONTEXT.md D-03, D-04 기반 설계안]

```markdown
## 설계 결정 — [제목]
[active] [context: phase-research, agent-lookup]

**시도:** [...]
**결과:** [...]
**결정:** [...]
**Observed:** 1 times (2026-04-14)
```

핵심 변경사항:
1. 상태 태그가 제목 줄 다음으로 이동 (읽기 용이성)
2. `[context: ...]` 태그 추가 — 조회 시 관련성 판단 기준
3. `**Observed:** N times (date1, ...)` 기본 포함 (최초 기록 시 1 times)

### context 태그 분류 체계 (Claude's Discretion)

현재 decisions.md 15개 항목을 분석한 결과, 다음 카테고리가 적합하다:
[ASSUMED — decisions.md 내용 분석 기반]

| 카테고리 | 설명 | 예시 항목 |
|----------|------|-----------|
| `file-loading` | 파일 로드 방식, index-first 패턴 | index-first 접근 표준화 |
| `agent-behavior` | 에이전트 행동 원칙, GSD 프로세스 | GSD 최소 부하 원칙, researcher compile 제거 |
| `knowledge-format` | knowledge 파일 형식, 구조 설계 | guardrails+anti-patterns 이중 구조, D-08 패턴 |
| `compile-logic` | 컴파일 로직, fusion 정책 | 컴파일 타임 선별 기준, B+C fusion |
| `install-deploy` | install.sh, 패치 배포 | install.sh --force, PATCH count 확인 |
| `scope-backlog` | 범위 결정, 백로그 항목 | PageIndex backlog, D-05 벡터 Out of Scope |

**설계 원칙:**
- 하나의 항목에 최대 3개 태그
- 태그는 소문자 kebab-case
- 에이전트가 현재 작업과 맞는 항목만 필터링할 때 사용

### 조회 우선순위 구현 방식 (Claude's Discretion)

두 가지 구현 방식이 가능하다:

**방식 A: SKILL.md 지시 방식 (권고)**
```
decisions.md 읽기 시 우선순위:
1. Observed 카운터가 높은 항목 (여러 세션에서 재확인됨)
2. context 태그가 현재 작업과 일치하는 항목
3. 최근 추가된 항목 (최신 결정 우선)
4. [uncertain] 항목 — 경고 표시 후 사용 전 검증 권고
5. [superseded] 항목 — 제외 (참고 목적으로만 표시)
```

**방식 B: index.md 구조 방식**
- index.md Quick Reference 테이블에 Observed 카운터와 context 태그 컬럼 추가
- 에이전트가 index.md만 읽어도 우선순위 파악 가능
- 단점: index.md가 비대해지고 컴파일 시 갱신 부담 증가

**권고: 방식 A** — 현재 구조(패치 파일 지시 방식)와 일관성 있음. 구현 변경이 SKILL.md + 패치 파일 텍스트 수정에 국한됨.

---

## Standard Stack

Phase 8은 외부 라이브러리 없이 마크다운 파일 + LLM 프롬프트 수정으로 구현된다.

### 수정 대상 파일
[VERIFIED: 직접 읽기 및 분석]

| 파일 | 위치 | 수정 내용 |
|------|------|-----------|
| SKILL.md | `~/.claude/skills/gsd-knowledge-compile/SKILL.md` | Step 5 B+C fusion 정책 수정 |
| gsd-phase-researcher.patch.md | `patches/gsd-phase-researcher.patch.md` | [uncertain]/[superseded] 처리 지침 추가, 우선순위 지침 추가 |
| gsd-planner.patch.md | `patches/gsd-planner.patch.md` | 동일 |
| gsd-discuss-phase.patch.md | `patches/gsd-discuss-phase.patch.md` (존재 여부 확인 필요) | 동일 |
| decisions.md | `.knowledge/knowledge/decisions.md` | 기존 15개 항목 메타데이터 소급 추가 |

---

## Don't Hand-Roll

| 문제 | 만들려 할 것 | 대신 사용 | 이유 |
|------|-------------|-----------|------|
| conflict 감지 로직 | 별도 스크립트/파서 | SKILL.md 프롬프트 수정 | LLM이 이미 의미론적 판단 가능, 별도 코드는 유지비용만 높임 |
| 항목 수준 참조 추적 | JSONL 파서 확장 | Observed 카운터 방식 유지 | 항목별 참조 추적은 신호 품질 낮고 인프라 비용 높음 (Phase 7 비권고) |
| 우선순위 랭킹 알고리즘 | 수치 계산 스크립트 | LLM 지시 방식 | Observed 카운터를 지시로 읽으면 충분, 별도 계산 불필요 |
| 시간 기반 decay | compile-manifest 날짜 매핑 | 충돌 기반 decay 우선 | 참조 신호 품질 문제 해결 전 시간 기반은 노이즈 (Phase 7 확정) |

---

## Phase 7 권고안 구현 계획

### 1순위: SKILL.md Step 5 B+C fusion 수정
[VERIFIED: Phase 7 RESEARCH.md 권고안 직접 참조]

현재:
```
- 반대 결론 → `[conflict: YYYY-MM-DD]` 태그 추가 + blockquote로 새 내용 보존
```

변경 후:
```
- 반대 결론 → `[conflict: YYYY-MM-DD]` 태그 추가 + blockquote로 새 내용 보존
              + 항목 상태를 `[uncertain]`으로 변경
- [uncertain] 항목 처리 — 다음 컴파일 시 raw에서 추가 증거 수집:
  - 동일 방향 증거 발견 → [active]로 복귀
  - 반대 방향 증거 확정 → [superseded] 또는 [rejected]로 확정
  - 증거 없음 → [uncertain] 유지
```

### 2순위: 패치 파일 [uncertain] 처리 지침 추가
[VERIFIED: Phase 7 RESEARCH.md 권고안 직접 참조]

researcher + planner + discuss 패치에 추가:
```
- `[uncertain]` 항목 발견 시: "이 결정은 불확실 상태 — 사용 전 raw/ 최근 항목에서 추가 컨텍스트 확인 필요"
- `[superseded]` 항목: 참고 목적으로만 읽고 실행 계획에 반영하지 않음
```

---

## Common Pitfalls

### Pitfall 1: context 태그 과도 세분화
**What goes wrong:** 태그 카테고리를 10개 이상 만들어 분류가 복잡해짐
**Why it happens:** 모든 항목에 정확한 태그를 붙이려는 완벽주의
**How to avoid:** 6개 이내 카테고리로 제한. 에이전트가 직관적으로 이해할 수 있는 수준 유지
**Warning signs:** 태그 중 사용 빈도가 1인 카테고리가 3개 이상이면 통합 검토

### Pitfall 2: SKILL.md 수정 후 패치 재배포 누락
**What goes wrong:** SKILL.md는 수정됐지만 설치된 스킬이 이전 버전으로 남음
**Why it happens:** SKILL.md는 프로젝트 내 `skills/gsd-knowledge-compile/SKILL.md`가 아닌 `~/.claude/skills/gsd-knowledge-compile/SKILL.md`가 실제 사용됨
**How to avoid:** install.sh 실행으로 재배포 확인. 파일 경로 주의: 프로젝트 내 수정 후 install.sh로 전역 설치
**Warning signs:** 컴파일 후 동작이 예상과 달리 변화 없을 때

### Pitfall 3: 기존 decisions.md 항목 소급 수정 시 형식 불일치
**What goes wrong:** 15개 항목에 context 태그를 추가하다가 형식이 항목마다 달라짐
**Why it happens:** 항목별로 서로 다른 편집 방식 적용
**How to avoid:** 단일 작업에서 모든 항목을 일괄 수정. 수정 전 형식 템플릿 확정 필수
**Warning signs:** `[active]`가 항목 본문 중간에 위치하는 항목이 혼재될 때

### Pitfall 4: [uncertain] 전환 과도 적용
**What goes wrong:** LLM이 약간 다른 맥락의 유사 결론도 conflict로 판단해 항목을 [uncertain]으로 잘못 전환
**Why it happens:** 반대 결론 판단 기준이 SKILL.md 지시 텍스트에 명시적이지 않음
**How to avoid:** SKILL.md Step 5 수정 시 "반대 결론"의 기준을 명시적으로 서술: "동일 주제에서 이전 결정과 **직접적으로 모순되는** 결론"으로 한정
**Warning signs:** 컴파일 후 [uncertain] 항목이 2개 이상 갑자기 생겼을 때

### Pitfall 5: patch 파일 수정 후 install.sh 재배포 시 PATCH count 검증 누락
**What goes wrong:** 패치 재배포 후 count가 1이 아닌 2 이상으로 증가하여 중복 지침이 삽입됨
**Why it happens:** Phase 6 교훈 — install.sh가 마커 있을 때 skip하지 않고 중복 삽입하는 버그 이력
**How to avoid:** install.sh --force 재실행 후 반드시 `grep -c "PATCH:knowledge-compiler" <file>` 확인. 기대값: researcher=1, planner=1, discuss=1
[VERIFIED: guardrails.md "install.sh 실행 후 PATCH count 즉시 확인" 규칙]

---

## 기록 메타데이터 설계 세부사항

### 항목 형태 전환 계획

**Before (현재):**
```markdown
## 설계 결정 — index-first 접근 표준화

**시도:** 에이전트가 knowledge/ 전체를 순차 로드
**결과:** 컨텍스트 비용이 높고 관련 없는 정보까지 로드됨
**결정:** index.md를 먼저 읽어 관련 파일만 선택적으로 Read하는 index-first 접근 표준화 (RELEVANCE-03)
**상태:** [active]
```

**After (목표):**
```markdown
## index-first 접근 표준화
[active] [context: file-loading, agent-behavior]

**시도:** 에이전트가 knowledge/ 전체를 순차 로드
**결과:** 컨텍스트 비용이 높고 관련 없는 정보까지 로드됨
**결정:** index.md를 먼저 읽어 관련 파일만 선택적으로 Read하는 index-first 접근 표준화 (RELEVANCE-03)
**Observed:** 1 times (2026-04-12)
```

**변경 사항:**
1. 제목에서 "설계 결정 —" 프리픽스 제거 (카테고리 중복, 파일명이 이미 decisions.md)
2. 상태 태그를 제목 다음 줄로 이동
3. `[context: ...]` 태그 추가
4. `**Observed:** N times (날짜)` 기본 포함

**주의:** 제목 프리픽스 제거는 현재 index.md 키워드 인덱스의 fragment ID(#설계-결정--index-first-접근-표준화)를 깨뜨린다. 제목 변경 시 index.md 키워드 인덱스도 함께 갱신 필요.

---

## 신규 증강 방법론 평가 (D-03)

### 평가 대상 세 가지

**1. 신뢰도 가중치 (Observed 횟수 기반)**

- **방식:** 현재 Observed 카운터를 "신뢰도 신호"로 재정의. 조회 시 에이전트가 Observed가 높은 항목을 더 신뢰하도록 패치 지시 추가.
- **구현 비용:** SKILL.md + 패치 파일 지시 텍스트 수정만 필요 → 낮음
- **효과:** Observed=1인 항목보다 Observed=3인 항목이 더 신뢰할 수 있다는 신호를 에이전트에 제공
- **한계:** 현재 15개 항목 중 Observed 카운터 보유 항목이 1개뿐. 신뢰도 차별화가 의미 있으려면 더 많은 항목에 Observed가 쌓여야 함
- **권고:** 채택. 패치 지시에 우선순위 힌트로 추가.

**2. Cross-session 합산 (여러 세션 독립 재확인)**

- **방식:** Observed 카운터의 날짜가 서로 다른 날이면 "독립적 재확인"으로 더 높은 신뢰도 부여
- **구현 비용:** Observed 날짜 파싱 로직을 에이전트 지시에 추가 → 낮음 (프롬프트 수정)
- **효과:** 같은 날 2회 기록(현재 유일한 Observed 2 사례)보다 다른 날 2회 기록이 더 신뢰성 높음을 구분
- **한계:** 날짜 파싱을 에이전트에 맡기면 해석 오류 가능
- **권고:** 조건부 채택. 간단한 지시("날짜가 다른 경우 독립적 재확인으로 더 신뢰성 높음")로 추가.

**3. 사용 컨텍스트 태깅 (어떤 Phase/task에서 참조됐는지)**

- **방식:** context 태그에 "어느 phase 유형에서 이 결정이 활용됐는지"를 기록
- **구현 비용:** 항목 메타데이터 설계(D-02 범위 1)의 일부로 구현 가능 → context 태그로 커버됨
- **효과:** 에이전트가 현재 작업 컨텍스트와 항목의 context 태그를 비교해 관련성 판단
- **권고:** 채택. D-02 범위 1(기록 메타데이터 설계)과 통합하여 구현.

---

## 구현 단계 순서

Phase 8 구현은 다음 순서로 진행해야 한다:

**Wave 1: 메타데이터 형식 확정 + SKILL.md 수정**
1. decisions.md 신규 항목 형태 확정 (형식 템플릿 작성)
2. SKILL.md Step 5 B+C fusion 정책 수정:
   - 신규 항목 기록 형태 반영 (Observed 기본 포함, context 태그 지시)
   - 충돌 기반 decay 추가 ([uncertain] 상태 전환)
3. 기존 15개 decisions.md 항목 소급 수정

**Wave 2: 패치 파일 업데이트 + install.sh 재배포**
1. gsd-phase-researcher.patch.md 수정 (우선순위 지침, [uncertain]/[superseded] 처리)
2. gsd-planner.patch.md 수정 (동일)
3. gsd-discuss-phase.patch.md 수정 (동일) — 파일 존재 여부 확인 후
4. install.sh --force 재배포 + PATCH count 검증

**Wave 3: 검증**
1. decisions.md 형식 일관성 확인 (모든 항목에 context 태그 + Observed)
2. 컴파일 시뮬레이션 — 동일 결론 raw 항목 추가 후 Observed 카운터 증가 확인
3. 충돌 시뮬레이션 — 반대 결론 raw 항목 추가 후 [uncertain] 전환 확인
4. 패치 파일 PATCH count 확인 (researcher=1, planner=1, discuss=1)

---

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| `~/.claude/skills/gsd-knowledge-compile/SKILL.md` | Wave 1 수정 | ✓ | 설치됨 | — |
| `patches/gsd-phase-researcher.patch.md` | Wave 2 수정 | ✓ | 현재 존재 | — |
| `patches/gsd-planner.patch.md` | Wave 2 수정 | ✓ | 현재 존재 | — |
| `patches/gsd-discuss-phase.patch.md` | Wave 2 수정 | 확인 필요 | — | 신규 생성 |
| `install.sh` | Wave 2 재배포 | ✓ | 현재 존재 | — |
| `/gsd-knowledge-compile` 스킬 | Wave 3 시뮬레이션 | ✓ | 설치됨 | — |

**gsd-discuss-phase 패치 파일 존재 여부를 구현 시작 전 확인 필요.**
[ASSUMED — patches/ 디렉토리 목록 미확인]

---

## Validation Architecture

config.json에 `nyquist_validation` 키가 없으므로 활성화됨.

### Test Framework

| Property | Value |
|----------|-------|
| Framework | 수동 검증 + 컴파일 시뮬레이션 |
| Config file | none |
| Quick run command | `/gsd-knowledge-compile` 실행 후 decisions.md diff 확인 |
| Full suite command | Wave 3 시뮬레이션 3단계 전체 |

### Phase Requirements → Test Map

| 요구사항 | 동작 | 테스트 방법 | 자동화 가능 |
|---------|------|-----------|------------|
| context 태그 추가 | 모든 decisions.md 항목에 `[context: ...]` 존재 | grep으로 태그 없는 항목 감지 | ✅ `grep -L "context:" .knowledge/knowledge/decisions.md` |
| Observed 기본 포함 | 모든 신규 항목에 Observed 줄 존재 | 기존 항목 제외, 신규 항목 grep | 부분 자동화 |
| [uncertain] 상태 전환 | 반대 결론 raw 항목 컴파일 후 해당 항목이 [uncertain]으로 변경 | 테스트 raw 항목 추가 + 컴파일 + diff | ✅ 수동 시뮬레이션 |
| 패치 파일 지침 추가 | [uncertain] 처리 지침이 패치 파일에 존재 | grep | ✅ `grep "uncertain" patches/*.patch.md` |
| PATCH count 정상 | researcher=1, planner=1, discuss=1 | grep -c | ✅ |

### Wave 0 Gaps

- [ ] decisions.md context 태그 형식 템플릿 확정 (Wave 1 시작 전)
- 기존 테스트 인프라로 커버 가능 — 추가 프레임워크 설치 불필요

---

## Open Questions (PARTIALLY RESOLVED)

1. **gsd-discuss-phase.patch.md 존재 여부** — [RESOLVED: Plan 02 Task 2에서 파일 존재 시 수정, 없으면 신규 생성으로 처리]
   - What we know: Phase 5/6에서 discuss-phase 패치가 구현됨 (앵커 `check_existing`으로 수정)
   - Resolution: Plan 02 Task 2 Action이 파일 존재 여부 확인 후 분기 처리를 포함

2. **decisions.md 제목 프리픽스 ("설계 결정 —") 제거 여부** — [RESOLVED: CONTEXT.md 제약에 따라 유지. Plan 01이 프리픽스를 그대로 보존]
   - What we know: 현재 15개 항목 모두 "설계 결정 —" 프리픽스 포함. index.md 키워드 인덱스가 이 형태로 참조 중
   - Resolution: 프리픽스 유지 — 변경 시 index.md 대규모 수정 발생. Plan 01이 이 결정을 반영.

3. **B+C fusion 시뮬레이션 결과 (Phase 7 D-03 미실행)** — [실행 중 검증 예정 — Wave 3에서 해결]
   - What we know: Phase 7이 스킵됨 — D-03 시뮬레이션이 실제로 실행되지 않았음
   - What's unclear: B+C fusion이 실제로 동작하는지 검증되지 않음 (A4 assumption)
   - Resolution plan: Phase 8 Plan 03 Task 1에서 시뮬레이션 실행. 미동작 시 SKILL.md 지시 강화 분기(PARTIAL) 처리 포함.

---

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | context 태그 6개 카테고리(file-loading, agent-behavior, knowledge-format, compile-logic, install-deploy, scope-backlog)가 현재 15개 항목을 충분히 커버 | 기록 메타데이터 설계 세부사항 | 중간 — 카테고리 추가/통합 필요 시 소급 수정 비용 발생 |
| A2 | decisions.md 항목 형태 변경이 index.md 키워드 인덱스와 충돌하지 않거나 동시 수정으로 해소 가능 | 기록 메타데이터 설계 세부사항 | 낮음 — index.md는 컴파일 시 재생성 가능 |
| A3 | gsd-discuss-phase.patch.md가 patches/ 디렉토리에 존재 | Environment Availability | 낮음 — 파일 없으면 신규 생성으로 처리 가능 |
| A4 | B+C fusion이 실제로 동작한다 (Phase 7 D-03 시뮬레이션 미실행으로 미검증) | 구현 단계 순서 Wave 3 | 중간 — 미동작 시 SKILL.md 지시 강화 추가 작업 필요 |
| A5 | SKILL.md 수정 후 install.sh로 재배포 가능 (install_skill 함수가 SKILL.md 배포 담당) | Standard Stack | 낮음 — install.sh 코드 분석으로 확인 가능 |

---

## Sources

### Primary (HIGH confidence)
- `07-RESEARCH.md` 직접 읽기 — Phase 7 권고안 전체 (충돌 기반 decay, 시간 기반 decay 비권고)
- `08-CONTEXT.md` 직접 읽기 — D-01~D-04 잠긴 결정 및 Claude's Discretion
- `SKILL.md` 직접 읽기 — Step 5 B+C fusion 정책 현재 상태
- `decisions.md` 직접 읽기 — 15개 항목 현재 형태 분석
- `patches/gsd-phase-researcher.patch.md` 직접 읽기 — 현재 조회 지침
- `patches/gsd-planner.patch.md` 직접 읽기 — 현재 조회 지침
- `guardrails.md` 직접 읽기 — install.sh PATCH count 확인 규칙

### Secondary (MEDIUM confidence)
- `index.md` 직접 읽기 — 현재 키워드 인덱스 구조 (항목 형태 변경 시 영향 범위 파악)

### Tertiary (LOW confidence)
- context 태그 카테고리 설계 — decisions.md 15개 항목 귀납적 분류 (검증 미실시)

---

## Metadata

**Confidence breakdown:**
- Phase 7 권고안 구현 범위: HIGH — RESEARCH.md에서 직접 읽어 확인
- 현재 시스템 상태: HIGH — SKILL.md, decisions.md, 패치 파일 직접 읽기
- context 태그 분류 체계: MEDIUM — 항목 내용 분석 기반, 사용자 확인 권고
- B+C fusion 동작 여부: MEDIUM — 정의는 확인됐으나 실제 동작은 Phase 8 Wave 3에서 검증 필요

**Research date:** 2026-04-14
**Valid until:** 2026-05-14 (안정적 시스템, 30일)
