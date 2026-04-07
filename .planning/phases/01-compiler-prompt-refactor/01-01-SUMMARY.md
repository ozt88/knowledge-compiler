---
plan: 01-01
phase: 01-compiler-prompt-refactor
status: complete
completed: 2026-04-07
---

## Summary

researcher와 verifier 패치 파일의 컴파일러 프롬프트를 부정형에서 긍정형 지시로 전환했다.

## What Was Built

- `patches/gsd-phase-researcher.patch.md` Step 0의 부정형 지시 5개를 긍정형으로 전환
- `patches/gsd-verifier.patch.md` Step 10b는 이미 긍정형 — 변경 없이 검증만 완료

## Key Changes

| 위치 | 변경 전 | 변경 후 |
|------|---------|---------|
| researcher L19 | "이것은 하지 마라" 목록과 이유 | 피해야 할 패턴과 그 이유 목록 |
| researcher L22 | don't overwrite, append/update | 읽은 뒤 새 항목을 추가하거나 업데이트하여 병합하라 |
| researcher L25 | [rejected] 항목은 같은 접근 시도 금지 | [rejected] 항목을 확인하고 대안 접근법을 선택하라 |
| researcher L26 | 연구 추천에서 제외할 패턴 | 목록을 확인하고 검증된 패턴을 우선 적용하라 |
| researcher L27 | 이미 해결된 문제는 재조사 불필요 | 이미 해결된 문제를 확인하고 새로운 미해결 문제에 집중하라 |

## Verification Results

```
researcher 부정형 패턴: 0개 (PASS)
researcher "확인하고" 등장: 3회 (PASS, 기준 ≥2)
researcher knowledge 파일 참조: 8회 (PASS, 기준 ≥4)
verifier 부정형 패턴: 0개 (PASS)
verifier knowledge 파일 참조: 4회 (PASS, 기준 ≥4)
```

## Decisions

- verifier 패치는 이미 긍정형이므로 파일 변경 없음이 올바른 결정

## Self-Check: PASSED

key-files.created:
  - patches/gsd-phase-researcher.patch.md
  - patches/gsd-verifier.patch.md
