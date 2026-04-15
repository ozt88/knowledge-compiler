---
phase: 08-knowledge-record-retrieve-design
plan: "02"
subsystem: knowledge
tags: [uncertain, decay, context-tags, patch, install, skill]
dependency_graph:
  requires:
    - 08-01 (decisions.md 메타데이터 형식 확정)
  provides:
    - SKILL.md Step 5 B+C fusion 정책 [uncertain] 상태 전환 + context 태그 기록 지시
    - 패치 파일 3개에 uncertain/superseded 처리 지침 + 조회 우선순위
    - install.sh --force 재배포 버그 수정 (em dash, nested marker, skip 계산)
  affects:
    - skills/gsd-knowledge-compile/SKILL.md
    - patches/gsd-phase-researcher.patch.md
    - patches/gsd-planner.patch.md
    - patches/gsd-discuss-phase.patch.md
    - install.sh
tech_stack:
  added: []
  patterns:
    - "충돌 기반 decay: 반대 결론 시 [uncertain] 상태 전환 + [conflict: date] 태그"
    - "조회 우선순위: Observed 카운터 높은 항목 > context 태그 일치 항목"
    - "[uncertain]/[superseded] 상태별 에이전트 처리 지침"
key_files:
  created: []
  modified:
    - skills/gsd-knowledge-compile/SKILL.md
    - patches/gsd-phase-researcher.patch.md
    - patches/gsd-planner.patch.md
    - patches/gsd-discuss-phase.patch.md
    - install.sh
decisions:
  - "B+C fusion에 '직접적으로 모순되는' 판단 기준 명시 — 다른 맥락의 유사 결론을 conflict로 잘못 판정 방지"
  - "gsd-planner.patch.md에 PATCH 마커 줄 추가 — grep -q PATCH_MARKER 검사가 작동하려면 마커가 삽입 내용에 있어야 함"
  - "install.sh unpatch 로직: skip = block_size - 1 (마커가 patch_content 2번째 줄이므로)"
  - "discuss-phase 앵커 check_existing → cross_reference_todos 수정 — 실제 discuss-phase.md에 check_existing step tag 없음"
metrics:
  duration: "~21 minutes"
  completed: "2026-04-15T07:29:45Z"
  tasks_completed: 2
  files_modified: 5
---

# Phase 08 Plan 02: B+C Fusion Decay + 조회 지침 업데이트 Summary

SKILL.md Step 5에 충돌 기반 decay([uncertain] 상태 전환)를 추가하고, 패치 파일 3개에 조회 우선순위 및 uncertain/superseded 처리 지침을 추가하여 install.sh --force로 재배포 완료. 재배포 과정에서 install.sh의 `unpatch` 로직 버그 3개를 발견하여 함께 수정.

## Tasks Completed

| Task | Name | Commit | Files |
|------|------|--------|-------|
| 1 | SKILL.md Step 5 B+C fusion 정책 수정 + context 태그 기록 지시 | 475eb2b | skills/gsd-knowledge-compile/SKILL.md |
| 2 | 패치 파일 3개 수정 + install.sh 버그 수정 + 재배포 | a1043ca | patches/\*.patch.md, install.sh |

## What Was Built

### Task 1: SKILL.md Step 5 수정

**B+C fusion 정책 변경:**

변경 전:
```
- 반대 결론 → [conflict: YYYY-MM-DD] 태그 추가 + blockquote로 새 내용 보존
```

변경 후:
```
- 반대 결론 (동일 주제에서 이전 결정과 직접적으로 모순되는 결론) →
  1. [conflict: YYYY-MM-DD] 태그 추가
  2. blockquote로 새 내용 보존
  3. 항목 상태를 [uncertain]으로 변경
- [uncertain] 항목 처리 — 다음 컴파일 시 raw에서 추가 증거 수집:
  - 동일 방향 증거 → [active]로 복귀
  - 반대 방향 증거 → [superseded] 또는 [rejected]로 확정
  - 증거 없음 → [uncertain] 유지
```

**decisions.md 신규 항목 형식 지시 추가:**
- context 태그 6개 카테고리 + 최대 3개 제한
- Observed: 1 times (YYYY-MM-DD) 기본 포함 지시
- 상태값 목록 명시

### Task 2: 패치 파일 3개 수정

세 파일 모두에 추가된 내용:
- Observed 카운터 우선순위 (독립적 재확인 = 높은 신뢰도)
- `[context: ...]` 태그 일치 항목 우선
- `[uncertain]` 항목: 경고 + raw/ 추가 컨텍스트 확인 지시
- `[superseded]` 항목: 참고 목적으로만 사용, 권고안에 반영 금지

gsd-planner.patch.md 추가 변경:
- PATCH 마커 줄(`<!-- PATCH:knowledge-compiler — reapply after GSD updates -->`) 추가

gsd-discuss-phase.patch.md 변경:
- Insert 앵커 `check_existing` → `cross_reference_todos` 수정

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] install.sh unpatch 로직 3개 버그 수정**
- **Found during:** Task 2 검증 단계
- **Issue 1:** awk `$0 ~ marker` 패턴에서 em dash(`—`) 멀티바이트 문자가 일부 awk 구현에서 매칭 실패 → `index($0, marker)`로 교체
- **Issue 2:** nested marker 문제 — 패치 내용 안에 PATCH 마커가 있어 skip 중에도 재매칭됨 → `skip == 0 && ...` 조건 추가
- **Issue 3:** skip 계산 오류 — `block_size + 1`이 실제 블록보다 1줄 더 건너뛰어 앵커 줄(## Step 1:) 삭제됨 → `block_size - 1`로 수정 (마커가 patch_content 2번째 줄 기준)
- **Files modified:** install.sh
- **Commit:** a1043ca

**2. [Rule 1 - Bug] gsd-discuss-phase.patch.md 앵커 오류 수정**
- **Found during:** Task 2 검증 단계
- **Issue:** `<step name="check_existing">` 앵커가 discuss-phase.md에 존재하지 않음. 실제 파일에는 `<step name="cross_reference_todos">` 사용
- **Fix:** 패치 파일 주석 및 install.sh 앵커를 `cross_reference_todos`로 수정
- **Files modified:** patches/gsd-discuss-phase.patch.md, install.sh
- **Commit:** a1043ca

**3. [Rule 1 - Bug] gsd-planner.patch.md PATCH 마커 누락**
- **Found during:** Task 2 검증 단계
- **Issue:** gsd-planner.patch.md에 `<!-- PATCH:knowledge-compiler — reapply ... -->` 마커 줄 없음. install.sh의 `grep -q "$PATCH_MARKER"` 검사가 패치 삽입 여부를 감지 못해 매번 재삽입됨
- **Fix:** 패치 파일에 마커 줄 추가
- **Files modified:** patches/gsd-planner.patch.md
- **Commit:** a1043ca

## Verification Results

```
SKILL.md uncertain count = 4   ✓ (>= 3 기준)
SKILL.md context: count = 2    ✓ (>= 2 기준)
SKILL.md 직접적으로 모순 = 1   ✓
PATCH count researcher = 1     ✓
PATCH count planner = 1        ✓
PATCH count discuss = 1        ✓
patches uncertain (all 3) ✓
patches superseded (all 3) ✓
patches Observed (all 3) ✓
--force 3회 반복 후에도 count=1 유지 ✓
```

## Known Stubs

None.

## Threat Flags

None — 플랜의 threat_model에서 정의된 T-08-02-01/02/03 모두 구현됨:
- T-08-02-01: "직접적으로 모순되는" 기준 명시로 과도한 uncertain 판정 방지
- T-08-02-02/03: PATCH count 검증 통과 (researcher=1, planner=1, discuss=1)

## Self-Check: PASSED

- skills/gsd-knowledge-compile/SKILL.md: FOUND
- patches/gsd-phase-researcher.patch.md: FOUND
- patches/gsd-planner.patch.md: FOUND
- patches/gsd-discuss-phase.patch.md: FOUND
- install.sh: FOUND
- Commit 475eb2b: FOUND
- Commit a1043ca: FOUND
