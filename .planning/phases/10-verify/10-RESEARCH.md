# Phase 10: Verify - Research

**Researched:** 2026-04-24
**Domain:** Claude Code hook 통합 검증 (RTK + GSD 공존 확인)
**Confidence:** HIGH

---

## Summary

Phase 9가 이미 완료되어 RTK v0.37.2가 설치되고 `~/.claude/settings.json`에 PreToolUse hook이 등록된 상태다. Phase 10의 목표는 새로운 기능을 구현하는 것이 아니라, **Phase 9에서 등록된 RTK hook이 기존 GSD hook과 충돌 없이 동작하는지 검증**하는 것이다.

현재 `settings.json`의 PreToolUse 배열에는 5개의 hook이 존재한다. Write|Edit matcher 3개(GSD guards), Bash matcher 2개(gsd-validate-commit.sh, rtk hook claude). `rtk hook check`와 `rtk hook claude` dry-run으로 확인한 결과, RTK hook은 `git status` 명령을 `rtk git status`로 rewrite하고 JSON 형식으로 `updatedInput`을 반환한다. gsd-validate-commit.sh는 config.json의 `hooks.community: true` 설정이 없으면 즉시 exit 0하는 opt-in 구조다.

**Primary recommendation:** 이 Phase는 순수 검증(verification) Phase다. 코드 변경 없이 세 가지 검증 명령만 실행하면 된다: (1) settings.json JSON 유효성 + 양쪽 hook 동시 존재 확인, (2) `git status` 실행 후 RTK 압축 출력 확인, (3) `git commit` dry-run으로 gsd-validate-commit.sh 정상 동작 확인.

---

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Hook 등록 상태 확인 | Host OS / Config | — | settings.json은 Claude Code 프로세스가 읽는 호스트 파일 |
| RTK 압축 출력 확인 | Host OS / CLI | — | rtk는 OS 레벨 바이너리, Claude Code의 Bash tool이 실행 |
| GSD commit hook 동작 확인 | Host OS / Config | — | gsd-validate-commit.sh는 PreToolUse hook, config.json opt-in 기반 |

---

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| VERIFY-01 | `~/.claude/settings.json`의 hook 배열을 확인하여 RTK hook이 존재하고 기존 GSD hook과 충돌 없이 동작함을 검증한다 | settings.json 현재 구조 확인 완료 — RTK hook(idx 4)과 GSD hooks(idx 0-3) 공존 확인됨. JSON 유효성은 python3 json.load로 검증 가능 |
| VERIFY-02 | `git status` 실행 시 RTK 압축 출력이 나오는지 확인하고, `git commit` 실행 시 `gsd-validate-commit.sh`가 정상 동작함을 테스트한다 | `rtk git status` 실행으로 압축 출력 확인 가능. gsd-validate-commit.sh는 opt-in 구조(config.json 없으면 exit 0) |

</phase_requirements>

---

## 현재 상태 (Verified Facts)

### settings.json PreToolUse 배열 — 현재 구조

[VERIFIED: 직접 파일 파싱]

```
실행 순서 (배열 index 순):
  1. [Write|Edit] gsd-prompt-guard.js
  2. [Write|Edit] gsd-read-guard.js
  3. [Write|Edit] gsd-workflow-guard.js
  4. [Bash]       gsd-validate-commit.sh
  5. [Bash]       rtk hook claude
```

- RTK hook command: `rtk hook claude` (Phase 9에서 실제 등록된 명령)
- GSD commit hook: `bash /home/ozt88/.claude/hooks/gsd-validate-commit.sh`
- JSON 유효성: python3 `json.load()` 성공 확인됨

### RTK Hook 동작 메커니즘

[VERIFIED: rtk hook claude dry-run 실행]

RTK `PreToolUse` hook은 stdin으로 Claude Code가 전달하는 tool call JSON을 읽고, `updatedInput`을 반환하여 명령을 rewrite한다.

```json
// 입력 예시
{"tool_name":"Bash","tool_input":{"command":"git status"}}

// RTK hook claude 출력 예시
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecisionReason": "RTK auto-rewrite",
    "updatedInput": {"command": "rtk git status"},
    "permissionDecision": "allow"
  }
}
```

`git status` → `rtk git status`로 rewrite됨이 dry-run으로 확인됨.

### GSD validate-commit.sh 동작 메커니즘

[VERIFIED: 소스 코드 직접 읽음]

```bash
# opt-in 구조: config.json에 hooks.community: true가 없으면 즉시 exit 0
if [ -f .planning/config.json ]; then
  ENABLED=$(node -e "...c.hooks?.community===true?'1':'0'...")
  if [ "$ENABLED" != "1" ]; then exit 0; fi
else
  exit 0
fi
```

현재 `/home/ozt88/knowledge-compiler/.planning/config.json`에는 `hooks.community` 키가 없다. 따라서 이 프로젝트에서 gsd-validate-commit.sh는 **항상 exit 0** (통과).

git commit 시 RTK hook과 GSD hook의 실행 순서:
1. gsd-validate-commit.sh → Bash matcher, exit 0 (config.json opt-in 없음)
2. rtk hook claude → `git commit` 명령을 `rtk git commit`으로 rewrite

충돌 없음: 두 hook은 독립적으로 실행되며 서로의 exit code나 출력에 영향을 주지 않는다.

---

## Standard Stack

### Core (검증에 사용할 도구)

| 도구 | 버전 | 목적 |
|------|------|------|
| `python3` | 시스템 기본 | settings.json JSON 유효성 검증 |
| `rtk` | 0.37.2 | hook dry-run, 압축 출력 확인 |
| `jq` | 시스템 기본 | settings.json 구조 파싱 (대안: python3) |
| `bash -i` | 시스템 기본 | 인터랙티브 셸에서 env var 확인 |

---

## Architecture Patterns

### 검증 플로우

```
[검증 시작]
     │
     ▼
[SC-1] settings.json 구조 검증
  ├─ JSON 유효성 확인 (python3 json.load)
  ├─ RTK hook 존재 확인 (command = "rtk hook claude")
  └─ GSD hook 보존 확인 (4개 항목 유지)
     │
     ▼
[SC-2] RTK 압축 출력 검증
  ├─ rtk git status 실행
  └─ 압축 포맷 출력 확인 (~ Modified / ? Untracked 형식)
     │
     ▼
[SC-3] GSD commit hook 충돌 없음 검증
  ├─ gsd-validate-commit.sh dry-run (stdin에 JSON 파이프)
  └─ exit 0 반환 확인
     │
     ▼
[검증 완료]
```

### RTK 압축 출력 포맷

[VERIFIED: rtk git status 실행]

```
* master...origin/master [ahead 14]
~ Modified: 1 files
   templates/claude-md-section.md
? Untracked: 6 files
   .knowledge/raw/2026-04-21.md
   ...
```

원본 `git status` 대비 불필요한 안내 문구(use git add, use git restore 등)가 제거되고 핵심 정보만 남는다.

---

## 검증 명령 레퍼런스

### SC-1: settings.json 구조 검증

```bash
# JSON 유효성 + RTK hook 존재 + GSD hook 보존
python3 -c "
import json
with open('/home/ozt88/.claude/settings.json') as f:
    s = json.load(f)
pre = s['hooks']['PreToolUse']
rtk_found = any('rtk hook claude' in hh['command'] for h in pre for hh in h.get('hooks', []))
gsd_commit_found = any('gsd-validate-commit.sh' in hh['command'] for h in pre for hh in h.get('hooks', []))
print('JSON valid: OK')
print(f'RTK hook: {\"FOUND\" if rtk_found else \"MISSING\"}')
print(f'GSD commit hook: {\"FOUND\" if gsd_commit_found else \"MISSING\"}')
print(f'Total PreToolUse hooks: {len(pre)}')
"
```

기대 결과:
```
JSON valid: OK
RTK hook: FOUND
GSD commit hook: FOUND
Total PreToolUse hooks: 5
```

### SC-2: RTK 압축 출력 확인

```bash
rtk git status
```

기대 결과: `~ Modified:`, `? Untracked:` 형식의 압축 출력

### SC-3: GSD commit hook 충돌 없음 확인

```bash
# gsd-validate-commit.sh dry-run
echo '{"tool_name":"Bash","tool_input":{"command":"git commit -m \"docs(10): verify phase complete\""}}' \
  | bash /home/ozt88/.claude/hooks/gsd-validate-commit.sh
echo "exit code: $?"
```

기대 결과: exit code 0 (config.json에 hooks.community 없으므로 통과)

---

## Don't Hand-Roll

| 문제 | 하지 말 것 | 대신 사용 |
|------|-----------|-----------|
| settings.json JSON 유효성 검증 | 직접 grep/파싱 | `python3 json.load()` 또는 `jq .` |
| RTK hook 동작 테스트 | 실제 git 명령 실행 후 비교 | `rtk hook check` dry-run 또는 `rtk hook claude` stdin 파이프 |

---

## Common Pitfalls

### Pitfall 1: `rtk hook claude`와 실제 hook 실행 혼동

**What goes wrong:** `rtk hook claude`를 직접 호출하면 stdin이 없어 빈 출력이 나옴  
**Why it happens:** Claude Code가 hook을 호출할 때 stdin으로 tool call JSON을 전달함  
**How to avoid:** dry-run 시 `echo '{"tool_name":"Bash",...}' | rtk hook claude` 형식으로 JSON 파이프

### Pitfall 2: gsd-validate-commit.sh가 항상 통과한다고 오해

**What goes wrong:** "hook이 동작 안 한다"고 오판  
**Why it happens:** opt-in 구조 — config.json의 `hooks.community: true` 없으면 exit 0  
**How to avoid:** 이것이 정상 동작. 이 프로젝트에서 commit format 검증은 비활성화 상태

### Pitfall 3: Phase 9 VERIFICATION.md의 `rtk hook command` 불일치

**What goes wrong:** PATTERNS.md에는 `rtk-rewrite.sh`로 기록되어 있으나 실제 등록된 명령은 `rtk hook claude`  
**Why it happens:** `rtk init -g`가 Non-interactive 환경에서 실패하여 Edit 도구로 직접 JSON 패치했고, 실제 명령이 `rtk hook claude`로 변경됨  
**How to avoid:** settings.json 원본에서 직접 command 값 확인

---

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| `rtk` | SC-2, SC-3 | Yes | 0.37.2 | — |
| `python3` | SC-1 JSON 검증 | Yes | 시스템 기본 | `jq` |
| `jq` | SC-1 대안 | 확인 필요 | — | python3 |
| `/home/ozt88/.claude/hooks/gsd-validate-commit.sh` | SC-3 | Yes | — | — |

---

## Validation Architecture

`workflow.nyquist_validation`이 config.json에 없음 → 기본값 enabled 처리.

### Test Framework

| Property | Value |
|----------|-------|
| Framework | 없음 (순수 bash 명령 검증) |
| Config file | none |
| Quick run command | `python3 -c "import json; json.load(open('/home/ozt88/.claude/settings.json'))"` |
| Full suite command | 3개 SC 명령 순차 실행 |

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command |
|--------|----------|-----------|-------------------|
| VERIFY-01 | settings.json에 RTK + GSD hook 공존, JSON 유효 | smoke | `python3 -c "import json; s=json.load(open('~/.claude/settings.json')); ..."` |
| VERIFY-02 | git status RTK 압축 출력 확인 | smoke | `rtk git status` |
| VERIFY-02 | git commit 시 gsd-validate-commit.sh exit 0 | smoke | `echo '...' \| bash gsd-validate-commit.sh; echo $?` |

### Wave 0 Gaps

없음 — 이 Phase는 bash 명령 실행 검증만 필요하며 추가 테스트 파일 생성 불필요.

---

## Open Questions

1. **`git commit` 실제 RTK rewrite 효과**
   - 무엇을 아는가: `rtk hook claude`가 `git commit`을 `rtk git commit`으로 rewrite함이 dry-run으로 확인됨
   - 무엇이 불명확한가: `rtk git commit`이 실제로 commit 출력을 어떻게 압축하는지 (실제 커밋이 필요)
   - 권고: SC-3 검증에서 실제 커밋 없이 gsd-validate-commit.sh exit code만 확인하는 것으로 충분. 실제 commit 압축 효과는 `rtk gain`으로 누적 통계 확인

---

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | Claude Code hooks 배열은 index 순서대로 순차 실행된다 | 현재 상태 섹션 | 만약 병렬 실행이라면 gsd-validate-commit.sh가 RTK rewrite 전 원본 명령을 보게 되나, 어차피 exit 0이므로 영향 없음 |

---

## Sources

### Primary (HIGH confidence)
- 직접 파일 파싱: `/home/ozt88/.claude/settings.json` — PreToolUse 배열 구조, hook commands
- 직접 소스 읽음: `/home/ozt88/.claude/hooks/gsd-validate-commit.sh` — opt-in 동작 구조
- 직접 실행: `rtk hook claude` stdin 파이프 — rewrite 동작 확인
- 직접 실행: `rtk git status` — 압축 출력 형식 확인
- Phase 9 VERIFICATION.md — 완료된 작업 내용 및 Phase 10 이관 사항

### Secondary (MEDIUM confidence)
- Phase 9 PATTERNS.md — hook 구조 분석

---

## Metadata

**Confidence breakdown:**
- 현재 상태 파악: HIGH — 모든 핵심 파일을 직접 읽고 명령 실행으로 확인
- 검증 명령: HIGH — dry-run으로 예상 출력 확인됨
- hook 실행 순서: MEDIUM — Claude Code 배열 순서 실행 가정 (A1)

**Research date:** 2026-04-24
**Valid until:** 안정적 (settings.json 수정 전까지 유효)
