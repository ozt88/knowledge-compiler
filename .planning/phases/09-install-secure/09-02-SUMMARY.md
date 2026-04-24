---
phase: 09-install-secure
plan: "02"
subsystem: rtk-telemetry-hook
tags: [rtk, telemetry, bashrc, claude-settings, security, hook]
key-files:
  modified:
    - "~/.bashrc"
    - "~/.claude/settings.json"
  created:
    - "~/.claude/settings.json.bak"
metrics:
  tasks_completed: 2
  tasks_total: 2
  requirements_addressed: [INSTALL-02, SEC-01, SEC-02]
---

# Plan 09-02 Summary: 텔레메트리 차단 + Hook 등록

## Commits

| Task | Description |
|------|-------------|
| Task 1 | `~/.bashrc`에 `export RTK_TELEMETRY_DISABLED=1` 영구 등록 (시스템 파일 — project git 외) |
| Task 2 | `~/.claude/settings.json`에 RTK PreToolUse Bash hook 추가 (시스템 파일 — project git 외) |

*참고: 두 태스크 모두 project git 외부 시스템 파일 수정으로, project git 커밋 없음. 실제 변경은 아래 검증 결과로 확인.*

## Task 1 결과: RTK_TELEMETRY_DISABLED=1 ~/.bashrc 등록

- `grep -c '^export RTK_TELEMETRY_DISABLED=1$' ~/.bashrc` → **1** (정확히 1회, 중복 없음) ✓
- `bash -i -c 'echo $RTK_TELEMETRY_DISABLED'` → **1** (인터랙티브 새 셸 검증) ✓
- `/etc/environment`에 RTK 라인 없음 ✓ (D-04 준수)
- 현재 셸 `RTK_TELEMETRY_DISABLED=1` export 완료 ✓
- **비고:** `bash -c 'source ~/.bashrc && echo $RTK_TELEMETRY_DISABLED'`는 ~/.bashrc 상단 인터랙티브 가드(`case $- in *i*)`로 비대화형 모드에서 early-return — `bash -i` 사용으로 정상 검증.

## Task 2 결과: rtk init -g + settings.json 패치

### rtk init -g 실행 결과
- **비대화형 모드 이슈:** stdin 파이프로 인해 rtk init이 `(non-interactive mode, defaulting to N)`으로 settings.json 자동 패치 거부
- **조치:** RTK 제공 JSON 구조를 Edit 도구로 직접 패치 (백업 수동 생성, jq 유효성 보장)
- **실제 hook command:** `rtk hook claude` (PLAN 예상 `bash ~/.claude/hooks/rtk-rewrite.sh`와 상이 — RTK v0.37.2 기준 실제 명령)

### 검증 결과

| 항목 | 결과 | 상태 |
|------|------|------|
| `jq . ~/.claude/settings.json > /dev/null` | exit 0 | ✓ |
| `~/.claude/settings.json.bak` 존재, 21842 bytes | 존재 | ✓ |
| PreToolUse Bash matcher에 `rtk hook claude` 등록 | 등록됨 | ✓ |
| GSD hook 4개 보존 (prompt/read/workflow-guard, validate-commit) | 모두 보존 | ✓ |
| PreToolUse 총 개수 4→5 | 5개 | ✓ |
| `rtk telemetry status` → enabled: no | env override blocked | ✓* |
| D-08: project git status 변경 없음 | 변경 없음 | ✓ |

*SEC-02 비고: `rtk telemetry status` 출력에 "disabled" 문자열 미포함. 실제 출력:
```
enabled: no
env override: RTK_TELEMETRY_DISABLED=1 (blocked)
```
`enabled: no`는 텔레메트리가 차단됨을 의미. D-05에 따라 `rtk telemetry disable` 미실행 — env var만으로 충분히 차단됨. A1 가정 검증 완료.

### Phase 10 이관 사항
- **H2(훅 충돌):** RTK Bash hook(`rtk hook claude`)과 기존 GSD Bash hook(`gsd-validate-commit.sh`) 공존. Phase 10에서 실제 git 명령 실행 시 충돌 여부 검증 필요.
- **`rtk hook claude` vs `rtk-rewrite.sh`:** RESEARCH.md의 hook command 예측이 v0.37.2 실제 동작과 다름. 향후 버전 업그레이드 시 command 재확인 필요.

## Deviations

1. **rtk init -g 비대화형 패치 거부:** stdin 파이프로 non-interactive 모드 → Edit 도구로 직접 패치. Don't Hand-Roll 원칙의 정신(JSON 유효성)은 jq 검증으로 보장.
2. **hook command 상이:** PLAN 예상 `bash ~/.claude/hooks/rtk-rewrite.sh` → 실제 `rtk hook claude`. settings.json에 `rtk hook claude`로 등록됨.
3. **SEC-02 텍스트 매칭:** `rtk telemetry status` 출력에 "disabled" 단어 없이 "enabled: no"로 표현. 텔레메트리 차단 상태는 동일.

## Self-Check: PASSED

- [x] Task 1: ~/.bashrc에 `export RTK_TELEMETRY_DISABLED=1` 1회 등록, 인터랙티브 새 셸 검증
- [x] Task 2: settings.json JSON 유효, RTK hook 등록, GSD hook 4개 보존, .bak 존재
- [x] SEC-01: 영구 env var 등록
- [x] INSTALL-02: PreToolUse Bash hook 등록
- [x] SEC-02: 텔레메트리 차단 상태 확인 (enabled: no)
- [x] D-08: project 파일 변경 없음
