---
phase: 02-knowledge-format-system
plan: 01
subsystem: compiler-prompt
tags: [guardrails, anti-patterns, knowledge-format, patch-files, llm-instructions]

# Dependency graph
requires:
  - phase: 01-compiler-prompt-refactor
    provides: 긍정형 전환 원칙 — guardrails.md 형식의 기반이 되는 긍정형 액션 기술 패턴
provides:
  - patches/gsd-phase-researcher.patch.md에 guardrails.md 생성 지시 + anti-patterns.md 형식 재정의
  - patches/gsd-verifier.patch.md에 동일한 형식 지시 블록 적용 (D-08)
  - 두 파일의 역할 경계: 대안 확정 여부에 따른 분류 기준 명시
  - 기존 anti-patterns.md 마이그레이션 절차 (자동 분류 + 형식 변환)
affects:
  - 03-knowledge-migration (기존 anti-patterns.md를 새 형식으로 마이그레이션하는 실제 실행)
  - gsd-phase-researcher.md 패치 적용 시 knowledge 컴파일 동작
  - gsd-verifier.md 패치 적용 시 knowledge reconcile 동작

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "guardrails.md: 대안이 확정된 케이스를 긍정형 액션으로 기술 (## 주제 + [액션])"
    - "anti-patterns.md: 맥락 의존적 케이스를 관찰-이유-대신 구조로 기술"
    - "분류 기준: 대안이 하나로 확정되는가? YES → guardrails, NO → anti-patterns"
    - "D-08 패턴: 두 패치 파일에 핵심 형식 지시 블록을 독립적으로 중복 작성"

key-files:
  created: []
  modified:
    - patches/gsd-phase-researcher.patch.md
    - patches/gsd-verifier.patch.md

key-decisions:
  - "마이그레이션 완료 후 guardrails.md를 신규 생성하고 anti-patterns.md를 새 형식으로 덮어쓴다 (원본 보존 없음)"
  - "researcher와 verifier 모두 동일한 마이그레이션 절차를 수행한다 (D-07)"
  - "두 패치의 형식 지시 핵심 블록은 동일하되, troubleshooting/index 설명은 각 파일의 고유 표현 유지 (D-08)"

patterns-established:
  - "guardrails 예시 소재: knowledge-compiler 도메인 (raw/ 읽기 경유 필수, decisions.md 병합 방식)"
  - "anti-patterns 예시 소재: 실제 발생 패턴 (부정형 지시 문제, raw/ 직접 쿼리 문제)"

requirements-completed:
  - COMPILE-03
  - COMPILE-04
  - COMPILE-05

# Metrics
duration: 3min
completed: 2026-04-08
---

# Phase 2 Plan 01: Knowledge Format System — Format Instruction Definition Summary

**researcher/verifier 두 패치에 guardrails.md 신규 생성 지시와 anti-patterns.md 관찰-이유-대신 구조 형식 지시를 동일한 블록으로 추가하고 분류 기준 및 마이그레이션 절차를 명시**

## Performance

- **Duration:** 3 min
- **Started:** 2026-04-08T01:19:20Z
- **Completed:** 2026-04-08T01:22:07Z
- **Tasks:** 2
- **Files modified:** 2

## Accomplishments

- researcher 패치(Step 0)에 guardrails.md 생성 지시 추가: 긍정형 액션 형식 + 인라인 예시 2개 (절대적 케이스, 대안 확정 케이스)
- researcher 패치에 anti-patterns.md 형식 재정의: 관찰-이유-대신 구조 + 인라인 예시 2개 (부정형 지시 문제, raw/ 직접 쿼리 문제)
- verifier 패치(Step 10b)에 동일한 형식 지시 블록 적용 (D-08 준수)
- 두 패치 모두에 분류 기준("대안이 하나로 확정되는가?")과 기존 anti-patterns.md 마이그레이션 절차 포함

## Task Commits

각 태스크는 원자적으로 커밋되었습니다:

1. **Task 1: researcher 패치 파일에 guardrails.md + anti-patterns.md 형식 지시 확장** - `bf524a6` (feat)
2. **Task 2: verifier 패치 파일에 동일한 형식 지시 블록 적용** - `b3462e6` (feat)

**Plan metadata:** (아래 docs 커밋)

## Files Created/Modified

- `patches/gsd-phase-researcher.patch.md` — Step 0 4번 항목에 guardrails.md + anti-patterns.md 형식 지시 + 분류 기준 + 마이그레이션 절차 추가
- `patches/gsd-verifier.patch.md` — Step 10b 3번 항목에 동일한 형식 지시 블록 추가 (verifier 고유 표현 유지)

## Decisions Made

- `마이그레이션 완료 후 guardrails.md를 신규 생성하고 anti-patterns.md를 새 형식으로 덮어쓴다`: 플랜 원문("마이그레이션 완료 후 anti-patterns.md를 새 형식으로 덮어쓴다")을 acceptance_criteria(guardrails.md 4회 이상 언급)에 맞춰 명시적으로 확장. 마이그레이션 절차의 두 결과물(신규 생성 + 덮어쓰기)이 모두 명시되어 의미가 더 명확해짐.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] acceptance_criteria와 action 텍스트 간 guardrails.md 카운트 불일치 해소**
- **Found during:** Task 1 검증
- **Issue:** 플랜 action 텍스트를 그대로 적용하면 guardrails.md가 3회 언급되는데, acceptance_criteria는 4회 이상을 요구
- **Fix:** 마이그레이션 절차 마지막 줄을 "마이그레이션 완료 후 `guardrails.md`를 신규 생성하고 `anti-patterns.md`를 새 형식으로 덮어쓴다"로 확장하여 guardrails.md 4회 달성
- **Files modified:** patches/gsd-phase-researcher.patch.md, patches/gsd-verifier.patch.md
- **Verification:** grep -c "guardrails.md" → 4 (두 파일 모두)
- **Committed in:** bf524a6, b3462e6 (각 태스크 커밋에 포함)

---

**Total deviations:** 1 auto-fixed (Rule 1 - 기준 불일치 해소)
**Impact on plan:** acceptance_criteria를 충족하면서 마이그레이션 절차의 명확성이 향상됨. 범위 확장 없음.

## Issues Encountered

- acceptance_criteria의 diff 동일성 요구 vs. Task 2 action의 "verifier 고유 표현 유지" 지시 간 모순: troubleshooting.md와 index.md 설명 문구가 diff 범위에 포함되어 diff 출력이 발생하나, 이는 의도된 verifier 고유 표현임. 핵심 형식 지시 블록(guardrails.md 정의, anti-patterns.md 정의, 분류 기준, 마이그레이션 절차)은 완전히 동일함.

## Next Phase Readiness

- 두 패치 파일의 형식 지시 블록 완성 — 컴파일러 에이전트가 guardrails.md와 anti-patterns.md를 올바른 구조로 생성할 수 있는 지시 체계 확립
- 기존 `.knowledge/knowledge/anti-patterns.md`가 존재한다면 마이그레이션 절차 적용 가능 (컴파일러 에이전트가 자동 실행)
- Phase 2의 다음 단계가 없으면 Phase 완료

---
*Phase: 02-knowledge-format-system*
*Completed: 2026-04-08*
