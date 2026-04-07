# Phase 2: Knowledge Format System - Research

**Researched:** 2026-04-07
**Domain:** 프롬프트 엔지니어링 — knowledge 파일 형식 체계화 (guardrails.md 신규 도입, anti-patterns.md 형식 재정의)
**Confidence:** HIGH

---

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

#### 형식 지시 구체성 (COMPILE-04, COMPILE-05)
- **D-01:** 두 파일 모두 유형별 복수 예시(2-3개)를 패치에 인라인으로 포함한다.
  - guardrails.md: 절대적 케이스 예시 1개 + 대안 있는 케이스 예시 1개
  - anti-patterns.md: 관찰-이유-대신 구조의 예시 2개 (서로 다른 맥락)
- **D-02:** 예시는 knowledge-compiler 도메인 소재를 사용한다 (실제 내용과 일관성 확보).

#### 분류 경계 정의
- **D-03:** 컴파일러 판단 기준: **"대안이 하나로 확정되는가"** 가 유일한 분기 기준이다.
  - 대안이 하나로 확정 → `guardrails.md` (긍정형 액션으로 기술)
  - 상황에 따라 달라질 수 있음 → `anti-patterns.md` (관찰-이유-대신 구조)
- **D-04:** 추가 판단 기준 없음. 컴파일러가 이 하나의 기준만으로 분류한다.

#### 마이그레이션 절차 (COMPILE-03)
- **D-05:** 기존 `anti-patterns.md`가 존재하면 모든 항목을 읽어 분류 기준(D-03) 적용 후 자동 분류·이전한다.
  - guardrails로 분류된 항목 → `guardrails.md`에 긍정형 액션으로 재기술
  - anti-patterns에 남을 항목 → 관찰-이유-대신 구조로 재형식화
- **D-06:** 마이그레이션 완료 후 `anti-patterns.md`를 새 형식으로 덮어쓴다 (원본 보존 없음).
- **D-07:** researcher(incremental)와 verifier(full reconcile) 모두 동일한 마이그레이션 절차를 수행한다. researcher에서도 기존 anti-patterns.md 발견 시 마이그레이션 실행.

#### 패치 파일 구조
- **D-08:** researcher 패치(`gsd-phase-researcher.patch.md`)와 verifier 패치(`gsd-verifier.patch.md`) 양쪽에 동일한 형식 지시를 독립적으로 중복 작성한다.
  - 교차 의존성 없음 → 각 패치가 단독으로 사용 가능
  - GSD 업데이트 후 재적용 시 독립적으로 처리 가능

### Claude's Discretion

없음 — 모든 주요 결정이 CONTEXT.md에 명시됨.

### Deferred Ideas (OUT OF SCOPE)

없음 — 논의가 Phase 2 범위 내에서 진행됨.

</user_constraints>

---

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| COMPILE-03 | 컴파일러가 guardrails.md를 신규 생성하고, 기존 anti-patterns.md가 존재하면 읽어서 변환 후 반영한다 | researcher/verifier 패치 현재 구조 분석 완료. anti-patterns.md 4번 항목(researcher), 3번 항목(verifier)이 수정 위치. |
| COMPILE-04 | guardrails.md는 절대적/대안 있는 케이스를 긍정형 액션("~경유 필수", "~사용")으로 기술한다 | D-01/D-02 결정에 따른 형식 정의 완료. 예시 소재(CONTEXT.md specifics) 확보. |
| COMPILE-05 | anti-patterns.md는 맥락 의존적 케이스를 원인-결과형(관찰 → 이유 → 대신)으로 기술한다 | D-01/D-02 결정에 따른 형식 정의 완료. Phase 1 부정형 지시 문제 사례가 예시 소재로 활용 가능. |

</phase_requirements>

---

## Summary

Phase 2는 두 가지 작업으로 구성된다. 첫째, `guardrails.md`라는 신규 파일 개념을 도입하고 컴파일러에게 이를 생성하도록 지시한다. 둘째, 기존 `anti-patterns.md`의 형식을 "맥락 의존형 관찰-이유-대신 구조"로 재정의한다. 두 파일의 분기 기준은 단일하다 — "대안이 하나로 확정되면 guardrails.md, 상황에 따라 달라지면 anti-patterns.md".

수정 대상은 두 패치 파일의 특정 섹션이다. researcher 패치는 Step 0의 4번 항목(`anti-patterns.md` 생성 지시)이 수정 대상이며, verifier 패치는 Step 10b의 3번 항목이 수정 대상이다. 두 패치는 동일한 형식 지시를 독립적으로 포함해야 한다(D-08). 기존 `anti-patterns.md`가 있을 경우 자동 마이그레이션을 수행하며, 마이그레이션 후 `anti-patterns.md`는 새 형식으로 덮어쓴다.

이 Phase는 코드 없는 순수 마크다운 패치 파일 편집이다. 외부 라이브러리나 런타임 의존성이 없다. Phase 1에서 확립한 긍정형 지시 원칙(Pink Elephant Problem 대응)이 이 Phase의 형식 설계에도 동일하게 적용된다.

**Primary recommendation:** 두 패치 파일에 guardrails.md 생성 지시 + anti-patterns.md 형식 재정의 + 마이그레이션 절차를 독립적으로(D-08) 추가한다. 인라인 예시는 knowledge-compiler 도메인 소재를 사용한다.

---

## Standard Stack

### Core

| 대상 파일 | 섹션 | 역할 | 변경 범위 |
|----------|------|------|---------|
| `patches/gsd-phase-researcher.patch.md` | Step 0, 4번 항목 | incremental 컴파일 시 knowledge 파일 생성 지시 | anti-patterns 단일 → guardrails+anti-patterns 이중 구조 + 마이그레이션 절차 추가 |
| `patches/gsd-verifier.patch.md` | Step 10b, 3번 항목 | full reconcile 시 knowledge 파일 재구성 지시 | 동일 변경 (독립적 중복) |

외부 라이브러리, npm 패키지, 런타임 없음. 순수 마크다운 파일 편집.

---

## Architecture Patterns

### 현재 패치 파일 구조 (변경 전)

**gsd-phase-researcher.patch.md Step 0, 4번 항목:**

```markdown
4. Compile new raw entries into knowledge/ structure:
   - `decisions.md` — 시도 → 결과 → 결정. 상태 태그: `[active]`, `[rejected]`, `[superseded]`, `[uncertain]`
   - `anti-patterns.md` — 피해야 할 패턴과 그 이유 목록
   - `troubleshooting.md` — 에러 메시지 ↔ 해결책 매핑
   - `index.md` — 전체 요약 + 키워드 인덱스
```

현재: `anti-patterns.md` 단일 파일, 형식 지시 없음, 마이그레이션 절차 없음.

**gsd-verifier.patch.md Step 10b, 3번 항목:**

```markdown
3. Full reconcile — reprocess ALL raw entries and rebuild knowledge/:
   - `decisions.md` — 모든 시도/결정 통합, 상태 태그 정합성 확인
   - `anti-patterns.md` — 새로 발견된 anti-pattern 추가
   - `troubleshooting.md` — 에러/해결 매핑 갱신
   - `index.md` — 전체 요약 재생성
```

현재: 동일하게 `anti-patterns.md` 단일 파일, 형식 지시 없음.

### 목표 패턴 (변경 후)

두 패치 파일의 해당 항목을 다음 구조로 확장한다:

```markdown
   - `guardrails.md` — [신규] 대안이 하나로 확정되는 절대적/확정적 케이스를 긍정형 액션으로 기술
     - 형식: "## [주제]\n[긍정형 액션 기술]"
     - 절대적 케이스 예시: "raw/ 읽기는 knowledge/index.md 경유 필수"
     - 대안 확정 케이스 예시: "decisions.md는 decisions/ 하위 파일 병합 방식 사용"
   - `anti-patterns.md` — 상황에 따라 달라질 수 있는 맥락 의존적 케이스를 관찰-이유-대신 구조로 기술
     - 형식: "## [주제]\n**관찰:** [무엇이 일어났는가]\n**이유:** [왜 문제인가]\n**대신:** [권장 접근법]"
     - 예시 1: [서로 다른 맥락의 사례]
     - 예시 2: [서로 다른 맥락의 사례]
```

마이그레이션 절차 (기존 anti-patterns.md 존재 시):

```markdown
   기존 `anti-patterns.md` 처리:
   - 파일이 존재하면 모든 항목을 읽어 분류 기준 적용
   - 분류 기준: 대안이 하나로 확정되는가?
     - YES → `guardrails.md`에 긍정형 액션으로 재기술
     - NO → `anti-patterns.md`에 관찰-이유-대신 구조로 재형식화
   - 마이그레이션 완료 후 `anti-patterns.md`를 새 형식으로 덮어쓴다
```

### 두 파일의 역할 경계

| 기준 | guardrails.md | anti-patterns.md |
|------|--------------|-----------------|
| 분기 조건 | 대안이 하나로 확정 | 상황에 따라 달라짐 |
| 기술 방식 | 긍정형 액션 ("~경유 필수", "~사용") | 관찰 → 이유 → 대신 |
| 케이스 유형 | 절대적 / 확정적 | 맥락 의존적 |
| 예시 소재 | "raw/ 읽기 → index.md 경유 필수" | Phase 01 부정형 지시 문제 등 |

### 인라인 예시 소재 (D-02: knowledge-compiler 도메인)

CONTEXT.md `<specifics>` 섹션에서 제공된 소재:

**guardrails.md용:**
- 절대적 케이스: `"raw/ 읽기는 knowledge/index.md 경유 필수"`
- 대안 확정 케이스: `"decisions.md는 decisions/ 하위 파일 병합 방식 사용"`

**anti-patterns.md용:**
- Phase 01 부정형 지시 문제 사례 (예: 컴파일러가 `anti-patterns.md`에 "하지 마라" 형식으로 기록 → LLM 준수율 저하)
- 다른 맥락의 사례 (raw/ 직접 읽기 vs. index.md 경유 중 맥락 의존적인 예)

### Anti-Patterns to Avoid

- **양쪽 파일에 동일 항목 중복 기술:** guardrails/anti-patterns 분기 기준이 명확하므로 한 항목은 하나의 파일에만 속한다.
- **분류 기준 추가:** D-04에 따라 "대안 하나로 확정 여부" 외 추가 기준 없음. 복잡한 다중 기준 도입 금지.
- **researcher/verifier 패치 간 교차 참조:** D-08에 따라 각 패치가 독립적으로 동작해야 함. 한 패치에서 다른 패치 참조 금지.

---

## Don't Hand-Roll

| 문제 | 하지 말 것 | 대신 |
|------|-----------|------|
| guardrails.md 분류 기준 설계 | 복잡한 다중 기준 발명 | D-03/D-04 — "대안 하나로 확정 여부" 단일 기준 사용 |
| 예시 소재 발명 | 추상적/임의의 예시 작성 | D-02 — knowledge-compiler 도메인 실제 소재 (index.md 경유 필수, decisions/ 병합 방식 등) |
| 마이그레이션 로직 복잡화 | 버전 관리, 원본 보존, 단계적 이전 | D-05/D-06 — 단순 분류 후 즉시 덮어쓰기 |
| verifier 패치에만 지시 작성 | researcher는 "verifier 참고"로 처리 | D-08 — 양쪽 패치에 동일 지시 독립적으로 중복 작성 |

---

## Common Pitfalls

### Pitfall 1: 예시 없이 형식 지시만 추가
**What goes wrong:** "관찰-이유-대신 구조로 작성하라"고만 명시하고 인라인 예시를 생략
**Why it happens:** 형식 정의가 명확하다고 느껴지면 예시가 불필요해 보임
**How to avoid:** D-01 — 두 파일 모두 유형별 복수 예시(2-3개)를 패치에 인라인 포함. 예시 없는 형식 지시는 LLM이 구조를 임의 해석할 위험이 있다.
**Warning signs:** 패치에 형식 정의만 있고 "예시:" 섹션이 없다면 재검토

### Pitfall 2: researcher와 verifier 패치에 서로 다른 형식 지시 작성
**What goes wrong:** researcher 패치와 verifier 패치의 guardrails.md / anti-patterns.md 형식 지시가 미묘하게 달라짐
**Why it happens:** 각 패치를 별도로 수정하다가 표현이 달라짐
**How to avoid:** D-08 — 형식 지시 블록을 먼저 완성한 후 동일하게 복사. 한쪽을 수정하면 다른 쪽도 동일하게 수정 확인.
**Warning signs:** 두 패치에서 guardrails.md 또는 anti-patterns.md 설명이 다른 경우

### Pitfall 3: 마이그레이션 시 anti-patterns.md 항목 유실
**What goes wrong:** 기존 anti-patterns.md의 일부 항목이 guardrails로 이전되면서 anti-patterns 파일에서 삭제되지 않거나, 반대로 이전 중 유실
**Why it happens:** 마이그레이션 절차가 "읽기 → 분류 → 이중 쓰기"인데 중간 단계를 빠뜨림
**How to avoid:** D-05 지시를 "모든 항목을 읽어" → "분류 기준 적용" → "각 대상 파일에 기술" 3단계로 명시. 항목 단위로 처리.
**Warning signs:** 마이그레이션 후 두 파일의 항목 수 합계가 기존 anti-patterns.md 항목 수보다 적으면 유실 의심

### Pitfall 4: "대안 하나로 확정" 분류 기준 무시하고 guardrails.md 남용
**What goes wrong:** 컴파일러가 대부분의 항목을 guardrails.md에 넣어 anti-patterns.md가 비어버림
**Why it happens:** guardrails이 "더 강한 규칙"처럼 느껴져 중요한 항목을 여기에 우선 배치하려 함
**How to avoid:** D-03/D-04 — 분류 기준은 중요도가 아니라 "대안의 확정성"이다. 패치에 판단 기준을 명시적으로 서술하라.
**Warning signs:** guardrails.md가 anti-patterns.md보다 훨씬 많은 항목을 포함하는 경우

---

## Code Examples

### 목표 패치 지시 구조 (두 패치 공통)

researcher 패치 Step 0 4번 항목과 verifier 패치 Step 10b 3번 항목에 들어갈 지시의 구조:

```markdown
4. Compile new raw entries into knowledge/ structure:
   - `decisions.md` — 시도 → 결과 → 결정. 상태 태그: `[active]`, `[rejected]`, `[superseded]`, `[uncertain]`
   - `guardrails.md` — 대안이 하나로 확정되는 케이스를 긍정형 액션으로 기술한다
     - 형식: "## [주제]\n[긍정형 액션]" (예: "~경유 필수", "~방식 사용")
     - 예시 (절대적 케이스): "## raw/ 읽기\nraw/ 읽기는 knowledge/index.md 경유 필수"
     - 예시 (대안 확정 케이스): "## decisions.md 병합\ndecisions.md는 decisions/ 하위 파일 병합 방식 사용"
   - `anti-patterns.md` — 상황에 따라 달라질 수 있는 맥락 의존적 케이스를 관찰-이유-대신 구조로 기술한다
     - 형식: "## [주제]\n**관찰:** [현상]\n**이유:** [문제 원인]\n**대신:** [권장 접근]"
     - 예시 1: "## 컴파일러 부정형 지시\n**관찰:** knowledge 파일 생성 지시에 '하지 마라' 형식 사용\n**이유:** LLM은 부정형 지시 준수율이 낮아 원치 않는 패턴이 잔존\n**대신:** 긍정형 액션으로 재기술 (Phase 1 전환 원칙 적용)"
     - 예시 2: "## raw/ 파일 직접 쿼리\n**관찰:** index.md를 거치지 않고 raw/*.md를 직접 읽어 분석\n**이유:** 컨텍스트 비용이 높고 관련 없는 정보까지 로드됨\n**대신:** index.md에서 관련 날짜 파악 후 해당 raw 파일만 선택적으로 읽기"
   - `troubleshooting.md` — 에러 메시지 ↔ 해결책 매핑
   - `index.md` — 전체 요약 + 키워드 인덱스
   
   기존 `anti-patterns.md`가 존재하는 경우:
   - 모든 항목을 읽어 분류 기준 적용: 대안이 하나로 확정되는가?
     - YES → `guardrails.md`에 긍정형 액션으로 재기술
     - NO → `anti-patterns.md`에 관찰-이유-대신 구조로 재형식화
   - 마이그레이션 완료 후 `anti-patterns.md`를 새 형식으로 덮어쓴다
```

### guardrails.md 형식 예시

```markdown
## raw/ 읽기
raw/ 읽기는 knowledge/index.md 경유 필수

## decisions.md 병합
decisions.md는 decisions/ 하위 파일 병합 방식 사용
```

### anti-patterns.md 형식 예시

```markdown
## 컴파일러 부정형 지시
**관찰:** knowledge 파일 생성 지시에 '하지 마라' 형식 사용
**이유:** LLM은 부정형 지시 준수율이 낮아 원치 않는 패턴이 잔존 (t=3.09, p<0.05)
**대신:** 긍정형 액션으로 재기술 (Phase 1 전환 원칙 적용)

## raw/ 파일 직접 쿼리
**관찰:** index.md를 거치지 않고 raw/*.md를 직접 읽어 분석
**이유:** 컨텍스트 비용이 높고 관련 없는 정보까지 로드됨
**대신:** index.md에서 관련 날짜 파악 후 해당 raw 파일만 선택적으로 읽기
```

---

## State of the Art

| 이전 방식 | 현재 방식 | 변경 이유 |
|----------|---------|----------|
| anti-patterns.md 단일 파일 | guardrails.md + anti-patterns.md 이중 구조 | 절대적 케이스와 맥락 의존적 케이스의 기술 방식이 근본적으로 다름 |
| 형식 지시 없음 (자유형식) | 파일별 명시적 형식 지시 + 인라인 예시 | LLM이 구조 없이 작성하면 일관성 없는 지식 축적 |
| 마이그레이션 절차 없음 | 기존 anti-patterns.md 자동 분류·이전 | v1.0 anti-patterns는 두 유형이 혼재 → 일회성 정리 필요 |

**Deprecated:**
- `anti-patterns.md`의 자유형식 기술: Phase 2 이후 관찰-이유-대신 구조로 대체됨
- "이것은 하지 마라" 형식: Phase 1에서 이미 제거됨, Phase 2는 구조화된 형식으로 완성

---

## Open Questions

1. **예시 2번째 소재 확정**
   - What we know: CONTEXT.md에 "서로 다른 맥락의 예시 2개"가 필요하다고 명시. 1번째 소재는 확정 (Phase 01 부정형 지시 문제).
   - What's unclear: 2번째 예시 소재 — "raw/ 파일 직접 쿼리" 사례가 충분히 구체적인지
   - Recommendation: planner가 D-02 기준(knowledge-compiler 도메인 실제 소재)에 맞는 2번째 예시를 위의 Code Examples를 참고하여 채택하거나 조정.

2. **기존 anti-patterns.md 현재 상태**
   - What we know: `.knowledge/knowledge/` 디렉토리가 존재하지 않음 (raw/만 있음). 따라서 현재 마이그레이션 대상 파일 없음.
   - What's unclear: Phase 실행 시점에 anti-patterns.md가 생성되어 있을 수 있는지
   - Recommendation: 패치 지시는 "기존 anti-patterns.md가 존재하는 경우"를 조건부로 처리하도록 작성 (D-05 그대로).

---

## Environment Availability

Step 2.6: SKIPPED — 순수 마크다운 파일 편집, 외부 도구/서비스 의존성 없음.

---

## Validation Architecture

### Test Framework

`.planning/config.json`에 `workflow.nyquist_validation` 키 없음 → 활성화로 처리. 그러나 이 프로젝트는 코드가 없는 순수 마크다운 패치 파일 편집이므로 자동화 테스트 프레임워크가 해당되지 않는다. 검증은 텍스트 패턴 매칭(grep)으로 수행한다.

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command |
|--------|----------|-----------|-------------------|
| COMPILE-03 | 두 패치 파일에 guardrails.md 생성 지시 및 마이그레이션 절차 포함 | manual grep | `grep -c "guardrails.md" patches/gsd-phase-researcher.patch.md patches/gsd-verifier.patch.md` |
| COMPILE-04 | guardrails.md 형식 지시가 긍정형 액션 기술 규정 포함 | manual grep | `grep -c "긍정형\|경유 필수\|방식 사용" patches/gsd-phase-researcher.patch.md` |
| COMPILE-05 | anti-patterns.md 형식 지시가 관찰-이유-대신 구조 규정 포함 | manual grep | `grep -c "관찰\|이유\|대신" patches/gsd-phase-researcher.patch.md` |
| (공통) | 역할 경계 명시 — 분류 기준 "대안 하나로 확정" 포함 | manual grep | `grep -c "대안이 하나로\|대안이 하나" patches/gsd-phase-researcher.patch.md patches/gsd-verifier.patch.md` |
| (공통) | 두 패치가 동일한 형식 지시 포함 (D-08) | diff | `diff <(grep -A20 "guardrails.md" patches/gsd-phase-researcher.patch.md) <(grep -A20 "guardrails.md" patches/gsd-verifier.patch.md)` |

### Wave 0 Gaps

없음 — 기존 테스트 인프라(grep 검증)가 Phase 요구사항을 모두 커버함.

---

## Sources

### Primary (HIGH confidence)
- `/home/ozt88/knowledge-compiler/patches/gsd-phase-researcher.patch.md` — Step 0 현재 구조, 수정 대상 위치 (4번 항목) 확인
- `/home/ozt88/knowledge-compiler/patches/gsd-verifier.patch.md` — Step 10b 현재 구조, 수정 대상 위치 (3번 항목) 확인
- `.planning/phases/02-knowledge-format-system/02-CONTEXT.md` — 모든 잠긴 결정(D-01~D-08), 형식 지시 설계, 예시 소재
- `.planning/REQUIREMENTS.md` — COMPILE-03, COMPILE-04, COMPILE-05 원문
- `.planning/phases/01-compiler-prompt-refactor/01-RESEARCH.md` — Phase 1 긍정형 전환 패턴, 구조 유지 제약

### Secondary (MEDIUM confidence)
- `/home/ozt88/knowledge-compiler/docs/DESIGN.md` — guardrails.md/anti-patterns.md 도입 배경, 파이프라인 설계
- `.knowledge/raw/2026-04-07.md` — Phase 2 discuss-phase 결과 요약

---

## Metadata

**Confidence breakdown:**
- 수정 대상 파일/위치: HIGH — 두 패치 파일 직접 읽고 수정 위치 확인
- 형식 지시 내용: HIGH — CONTEXT.md 잠긴 결정(D-01~D-08) 기반, 설계 완료
- 인라인 예시 소재: HIGH — CONTEXT.md specifics에서 제공된 소재 + Phase 1 실제 사례
- 마이그레이션 절차: HIGH — D-05/D-06/D-07 명시, 현재 .knowledge/knowledge/ 없음 확인

**Research date:** 2026-04-07
**Valid until:** 두 패치 파일이 수정되기 전까지 (안정적, 외부 의존성 없음)
