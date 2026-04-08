---
phase: 03-collection-instruction-refactor
plan: 01
subsystem: documentation
tags: [claude-md, prompt-engineering, knowledge-compiler, positive-instruction]

# Dependency graph
requires:
  - phase: 02-knowledge-format-system
    provides: knowledge 수집 인프라 (raw 디렉토리, guardrails, anti-patterns)
provides:
  - 긍정형 턴 수집 지시 템플릿 (templates/claude-md-section.md)
  - 긍정형 규칙이 반영된 글로벌 지시 (~/.claude/CLAUDE.md)
affects: [future-phases, knowledge-collection-quality]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Pink Elephant Problem 해소: 부정형 배제 지시 대신 긍정형 허용 항목만 명시"
    - "범위 한정 추가: '각 항목은 한 줄 이내로 요약'으로 코드 전문 여지 차단"

key-files:
  created: []
  modified:
    - templates/claude-md-section.md
    - ~/.claude/CLAUDE.md

key-decisions:
  - "부정형 규칙 삭제 — LLM은 '하지 마라'보다 '이것을 해라'에 더 잘 반응 (Pink Elephant Problem)"
  - "규칙 3 구체화: 허용 범위를 명시하면 나머지는 자동 배제됨"
  - "template이 source of truth — CLAUDE.md는 template 내용으로 동기화"

patterns-established:
  - "긍정형 지시 패턴: 허용 항목 열거로 금지 항목 암묵 배제"

requirements-completed:
  - COLLECT-01

# Metrics
duration: 2min
completed: 2026-04-08
---

# Phase 03 Plan 01: Collection Instruction Refactor Summary

**턴 수집 규칙의 부정형 배제 지시(규칙 4)를 삭제하고 규칙 3을 '수행한 행동과 그 결과, 핵심 발견 또는 결정 사항, 변경된 파일 경로 (각 항목은 한 줄 이내로 요약)'로 세밀화하여 긍정형 전환 완료**

## Performance

- **Duration:** 2min
- **Started:** 2026-04-08T09:03:43Z
- **Completed:** 2026-04-08T09:05:18Z
- **Tasks:** 2
- **Files modified:** 2

## Accomplishments
- templates/claude-md-section.md에서 규칙 4("포함하지 않을 것") 삭제 및 규칙 3 긍정형 세밀화
- 규칙 번호 6개 → 5개로 재조정 (1~5번)
- ~/.claude/CLAUDE.md의 Knowledge Compiler 섹션을 template과 diff 없이 동기화

## Task Commits

Each task was committed atomically:

1. **Task 1: template 긍정형 전환** - `bd024be` (feat)
2. **Task 2: CLAUDE.md 글로벌 지시 동기화** - `95b843f` (feat)

**Plan metadata:** (docs commit 아래에서 추가)

## Files Created/Modified
- `templates/claude-md-section.md` - 긍정형 규칙 5개로 전환 (source of truth)
- `~/.claude/CLAUDE.md` - Knowledge Compiler 섹션을 template과 동일하게 동기화 (레포 외부 파일)

## Decisions Made
- 부정형 규칙 삭제: LLM의 Pink Elephant Problem을 해소하기 위해 "포함하지 않을 것" 항목 전체 제거
- 범위 한정 표현 추가: "각 항목은 한 줄 이내로 요약"을 규칙 3에 추가하여 코드 전문/세부 로그 여지 차단
- template-first 동기화: template이 source of truth, CLAUDE.md는 파생 파일

## Deviations from Plan

None - plan executed exactly as written.

**참고:** ~/.claude/CLAUDE.md는 git 레포 외부 파일이어서 knowledge-compiler 레포에 직접 커밋 불가. Task 2는 파일시스템 수정이 완료된 상태로 빈 커밋으로 기록.

## Issues Encountered
- ~/.claude/CLAUDE.md가 지식 컴파일러 레포 외부에 있어 `git add` 불가 → empty commit으로 기록 처리

## Next Phase Readiness
- Phase 03의 유일한 Plan이 완료됨 — 마일스톤 v1.1 달성
- COLLECT-01 요건 충족
- 이후 턴 수집 품질 개선 여부는 실제 사용을 통해 검증 필요

---
*Phase: 03-collection-instruction-refactor*
*Completed: 2026-04-08*
