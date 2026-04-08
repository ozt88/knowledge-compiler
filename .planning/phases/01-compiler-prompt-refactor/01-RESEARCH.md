# Phase 1: Compiler Prompt Refactor - Research

**Researched:** 2026-04-07
**Domain:** 프롬프트 엔지니어링 — 부정형에서 긍정형 지시로 전환
**Confidence:** HIGH

---

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| COMPILE-01 | researcher가 incremental 컴파일 시 긍정형 지시로 knowledge 파일을 생성한다 | gsd-phase-researcher.patch.md Step 0의 구체적 부정형 라인 3개 식별 완료 |
| COMPILE-02 | verifier가 full reconcile 시 긍정형 지시로 knowledge 파일을 재구성한다 | gsd-verifier.patch.md Step 10b 전체 구조 분석 완료 |
</phase_requirements>

---

## Summary

Phase 1의 작업은 두 개의 패치 파일(`patches/gsd-phase-researcher.patch.md`, `patches/gsd-verifier.patch.md`)에 존재하는 컴파일러 프롬프트 지시를 부정형에서 긍정형으로 전환하는 것이다. 변환 범위가 작고 명확하다 — researcher 패치의 Step 0, verifier 패치의 Step 10b가 전부다.

실험 근거(PROJECT.md 기록)에 따르면 긍정형 프롬프트는 부정형 대비 LLM 준수율이 통계적으로 유의미하게 높다(t=3.09, p<0.05). "Pink Elephant Problem"이란 "~하지 마라"라고 금지할수록 그 행동을 유발하는 역설적 효과를 말한다. 이 Phase는 knowledge 파일 구조 자체를 바꾸지 않는다 — index.md, decisions.md, anti-patterns.md, troubleshooting.md 4개 파일 구조는 그대로 유지된다.

부정형 패턴은 researcher 패치에만 집중되어 있으며(3개 라인), verifier 패치는 구조적으로 부정형이 없다. 단, verifier 패치가 anti-patterns.md를 "새로 발견된 anti-pattern 추가"로 기술하는 부분은 Phase 2(knowledge 파일 형식 체계)의 범위이므로 이 Phase에서는 건드리지 않는다.

**Primary recommendation:** researcher 패치 Step 0의 "During research" 섹션 3개 라인을 긍정형으로 재작성하고, anti-patterns.md 설명 줄의 "이것은 하지 마라" 문구를 긍정형 설명으로 대체한다.

---

## Standard Stack

### Core

| 대상 파일 | 섹션 | 역할 |
|----------|------|------|
| `patches/gsd-phase-researcher.patch.md` | Step 0 (Knowledge Compile) | Phase 시작 전 raw → knowledge incremental 컴파일 |
| `patches/gsd-verifier.patch.md` | Step 10b (Knowledge Reconcile) | Phase 완료 후 full reconcile |

외부 라이브러리, npm 패키지, 런타임 없음. 순수 마크다운 파일 편집.

---

## Architecture Patterns

### 현재 패치 파일 구조 (변경 전)

**gsd-phase-researcher.patch.md — Step 0 분석:**

```markdown
<!-- 부정형 패턴 위치 -->
- `anti-patterns.md` — "이것은 하지 마라" 목록과 이유        ← 라인 19
5. Merge with existing knowledge (don't overwrite, append/update)  ← 라인 22
- `decisions.md` — `[rejected]` 항목은 같은 접근 시도 금지    ← 라인 25
- `anti-patterns.md` — 연구 추천에서 제외할 패턴              ← 라인 26
- `troubleshooting.md` — 이미 해결된 문제는 재조사 불필요     ← 라인 27
```

**gsd-verifier.patch.md — Step 10b 분석:**

```markdown
<!-- 부정형 없음 — 전체 구조 확인 -->
- decisions.md — 모든 시도/결정 통합, 상태 태그 정합성 확인
- anti-patterns.md — 새로 발견된 anti-pattern 추가
- troubleshooting.md — 에러/해결 매핑 갱신
- index.md — 전체 요약 재생성
4. 충돌하는 `[active]` decision이 있으면 `[uncertain]`으로 표시
```

verifier 패치에서 "충돌 → `[uncertain]`으로 표시"는 긍정형 행동 지시다. 부정형 없음 확인.

### 긍정형 전환 패턴

Pink Elephant Problem 대응 원칙:

| 부정형 | 긍정형 전환 방식 |
|--------|----------------|
| "X 하지 마라" | "Y를 대신 하라" |
| "X 금지" | "X 대신 Y 경로를 사용하라" |
| "X 제외할 패턴" | "연구에서 Y를 우선 적용하라 (X는 이미 기각됨)" |
| "재조사 불필요" | "이미 해결된 항목 확인 후 새 문제에 집중하라" |

### 유지해야 할 구조 (변경 금지)

knowledge/ 파일 4개의 이름과 역할은 Phase 1에서 변경 없음:
- `index.md` — 전체 요약 + 키워드 인덱스
- `decisions.md` — 시도 → 결과 → 결정 (상태 태그 포함)
- `anti-patterns.md` — (이름/역할 유지; 형식 재정의는 Phase 2 범위)
- `troubleshooting.md` — 에러 메시지 ↔ 해결책 매핑

---

## Don't Hand-Roll

| 문제 | 하지 말 것 | 대신 |
|------|-----------|------|
| 긍정형 프롬프트 작성법 | 새 이론/패턴 발명 | 기존 Pink Elephant 원칙 적용 — "금지" 대신 "대안 행동" 기술 |
| knowledge 파일 형식 변경 | anti-patterns.md 구조 변경 | Phase 2에서 처리 — Phase 1은 프롬프트 언어만 수정 |
| verifier 패치 대규모 수정 | Step 10b 전체 재작성 | 부정형이 없으므로 최소 변경 또는 변경 없음 |

---

## Common Pitfalls

### Pitfall 1: 범위 초과 — knowledge 파일 형식 변경
**What goes wrong:** anti-patterns.md의 "이것은 하지 마라" 설명을 보고 파일 형식 자체를 바꾸고 싶어짐
**Why it happens:** Phase 2(Knowledge Format System)와 Phase 1이 밀접하게 연관되어 있음
**How to avoid:** Phase 1 성공 기준 3번 명시 — "기존 컴파일 결과 구조를 그대로 유지한다". anti-patterns.md 파일명/역할/구조는 건드리지 않는다.
**Warning signs:** "anti-patterns.md 형식도 바꾸자"는 아이디어가 생기면 즉시 스코프 체크

### Pitfall 2: verifier 패치 불필요 수정
**What goes wrong:** verifier 패치에도 뭔가를 바꿔야 한다는 강박으로 불필요한 변경 추가
**Why it happens:** 두 파일 모두 수정하는 것이 대칭적으로 느껴짐
**How to avoid:** Step 10b를 분석했을 때 부정형 패턴이 없음을 확인했다(라인 분석 완료). 실질적 부정형이 없다면 변경 없음이 올바른 결정.
**Warning signs:** "어색하게 느껴지는" 표현을 억지로 긍정형으로 바꾸려 한다면 재검토

### Pitfall 3: "don't overwrite" 처리 방식
**What goes wrong:** 라인 22의 `(don't overwrite, append/update)`를 무시하거나 어색하게 번역
**Why it happens:** 영문 괄호 안 설명이라 눈에 잘 안 띔
**How to avoid:** "기존 파일을 읽은 후 병합(append/update)하라 — 덮어쓰기 금지" → "기존 파일을 읽은 후 새 항목을 추가하거나 기존 항목을 업데이트하라"로 전환

---

## Code Examples

### 부정형 → 긍정형 전환 예시

**현재 (부정형):**
```markdown
**During research (Step 3):** Also search `.knowledge/knowledge/` for findings relevant to this phase. Especially check:
- `decisions.md` — `[rejected]` 항목은 같은 접근 시도 금지
- `anti-patterns.md` — 연구 추천에서 제외할 패턴
- `troubleshooting.md` — 이미 해결된 문제는 재조사 불필요
```

**전환 후 (긍정형) — 예시:**
```markdown
**During research (Step 3):** Also search `.knowledge/knowledge/` for findings relevant to this phase. Especially check:
- `decisions.md` — `[rejected]` 항목을 확인하고 대안 접근법을 선택하라
- `anti-patterns.md` — 목록을 확인하고 연구 추천에서 검증된 패턴을 우선 적용하라
- `troubleshooting.md` — 이미 해결된 문제를 확인하고 새로운 미해결 문제에 집중하라
```

**anti-patterns.md 설명 줄:**
```markdown
<!-- 현재 -->
- `anti-patterns.md` — "이것은 하지 마라" 목록과 이유

<!-- 전환 후 -->
- `anti-patterns.md` — 피해야 할 패턴과 그 이유 목록
```

**"don't overwrite" 처리:**
```markdown
<!-- 현재 -->
5. Merge with existing knowledge (don't overwrite, append/update)

<!-- 전환 후 -->
5. 기존 knowledge 파일을 읽은 뒤 새 항목을 추가하거나 기존 항목을 업데이트하여 병합하라
```

---

## State of the Art

| 이전 방식 | 현재 방식 | 변경 이유 |
|----------|---------|----------|
| anti-patterns.md "하지 마라" 형식 | 긍정형 지시 (v1.1 목표) | Pink Elephant Problem — 부정형 지시는 준수율 저하 |
| Hook 기반 수집 | CLAUDE.md 행동 지시 | Hook은 턴 컨텍스트 접근 불가 (2026-04-05 실험 결과) |

---

## Open Questions

1. **verifier 패치 변경 필요 여부**
   - What we know: Step 10b 라인 분석 결과 명시적 부정형("하지 마라", "금지" 등) 없음
   - What's unclear: "충돌하는 `[active]` decision이 있으면 `[uncertain]`으로 표시"가 성공 기준을 충족하는지
   - Recommendation: planner가 성공 기준 2번("~하지 마라 형식 없이")을 기준으로 판단. 현재 분석상 변경 불필요 가능성 높음.

2. **"anti-patterns.md — 피해야 할 패턴" 표현 적절성**
   - What we know: "하지 마라" 제거가 목표. "피해야 할"도 부정적 함의가 있음.
   - What's unclear: 성공 기준의 "~하지 마라 형식 없이"가 문자 그대로인지 의도적 부정 표현 전체인지
   - Recommendation: 성공 기준 1번은 "~하지 마라 형식"을 명시적으로 언급함. "피해야 할"은 허용 가능한 것으로 보이나 planner가 확정.

---

## Environment Availability

Step 2.6: SKIPPED — 순수 마크다운 파일 편집, 외부 도구/서비스 의존성 없음.

---

## Validation Architecture

### Test Framework

nyquist_validation 설정 파일 없음 (.planning/config.json 미존재). 이 프로젝트는 코드가 없는 마크다운 패치 파일 편집이므로 자동화 테스트 프레임워크가 해당되지 않는다. 검증은 수동 텍스트 검토로 수행한다.

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | 검증 방법 |
|--------|----------|-----------|----------|
| COMPILE-01 | researcher 패치 Step 0에 "~하지 마라" 패턴 없음 | manual | 패치 파일 내 `하지 마라`, `금지`, `불필요`, `제외` 키워드 grep 후 잔존 여부 확인 |
| COMPILE-02 | verifier 패치 Step 10b에 "~하지 마라" 패턴 없음 | manual | 동일 grep 검증 |
| (공통) | knowledge/ 파일 구조 유지 | manual | 패치 파일에 index.md, decisions.md, anti-patterns.md, troubleshooting.md 4개 모두 언급 확인 |

**검증 명령어 (Phase 완료 후 실행):**
```bash
grep -n "하지 마라\|금지\|불필요\|제외할" patches/gsd-phase-researcher.patch.md patches/gsd-verifier.patch.md
# 기대 결과: 매칭 없음 (0 lines)
```

---

## Sources

### Primary (HIGH confidence)
- `/home/ozt88/knowledge-compiler/patches/gsd-phase-researcher.patch.md` — Step 0 전체 내용, 부정형 패턴 위치 확인
- `/home/ozt88/knowledge-compiler/patches/gsd-verifier.patch.md` — Step 10b 전체 내용, 부정형 패턴 부재 확인
- `/home/ozt88/knowledge-compiler/docs/DESIGN.md` — 긍정형 전환 배경, knowledge 파일 구조 정의
- `/home/ozt88/knowledge-compiler/.planning/PROJECT.md` — 실험 근거(t=3.09, p<0.05), 핵심 결정 이력

### Secondary (MEDIUM confidence)
- `.planning/REQUIREMENTS.md` — COMPILE-01, COMPILE-02 요구사항 명세
- `.planning/ROADMAP.md` — Phase 1 성공 기준 3개 명시

---

## Metadata

**Confidence breakdown:**
- 현재 패치 파일 분석: HIGH — 파일 직접 읽고 라인 수준 검증 완료
- 부정형 패턴 위치: HIGH — grep으로 정확한 라인 번호 확인
- verifier 패치 부정형 부재: HIGH — 전체 파일 분석, 명시적 부정형 없음 확인
- 긍정형 전환 패턴: MEDIUM — Pink Elephant 원칙 적용, 구체적 문구는 planner/executor가 최종 확정

**Research date:** 2026-04-07
**Valid until:** 이 패치 파일이 수정되기 전까지 (안정적, 외부 의존성 없음)
