# Phase 10: Verify - Pattern Map

**Mapped:** 2026-04-24
**Files analyzed:** 2 (검증 대상 기존 파일)
**Analogs found:** 2 / 2

---

## 개요

Phase 10은 순수 검증(verification) Phase다. 새 파일을 생성하거나 기존 파일을 수정하지 않는다. 검증 대상은 Phase 9에서 완성된 두 파일(`~/.claude/settings.json`, `~/.claude/hooks/gsd-validate-commit.sh`)이며, Planner는 이 파일들을 **읽기 전용**으로 참조하여 bash 명령을 조합하는 task를 계획한다.

---

## File Classification

| 검증 대상 | Role | Data Flow | Closest Analog | Match Quality |
|-----------|------|-----------|----------------|---------------|
| `~/.claude/settings.json` | config | event-driven | `~/.claude/settings.json` (자기 자신) | exact — PreToolUse 배열 구조 동일 |
| `~/.claude/hooks/gsd-validate-commit.sh` | middleware | request-response | `~/.claude/hooks/gsd-validate-commit.sh` (자기 자신) | exact — stdin JSON → exit code 패턴 |

---

## Pattern Assignments

### `~/.claude/settings.json` (config, event-driven)

**역할:** PreToolUse 훅 배열 — RTK hook과 GSD hook 공존 여부 검증

**Analog:** `~/.claude/settings.json` (자기 자신)

**현재 PreToolUse 배열 구조** (lines 121-171):
```json
"PreToolUse": [
  {
    "matcher": "Write|Edit",
    "hooks": [{ "type": "command", "command": "node \"/home/ozt88/.claude/hooks/gsd-prompt-guard.js\"", "timeout": 5 }]
  },
  {
    "matcher": "Write|Edit",
    "hooks": [{ "type": "command", "command": "node \"/home/ozt88/.claude/hooks/gsd-read-guard.js\"", "timeout": 5 }]
  },
  {
    "matcher": "Write|Edit",
    "hooks": [{ "type": "command", "command": "node \"/home/ozt88/.claude/hooks/gsd-workflow-guard.js\"", "timeout": 5 }]
  },
  {
    "matcher": "Bash",
    "hooks": [{ "type": "command", "command": "bash /home/ozt88/.claude/hooks/gsd-validate-commit.sh", "timeout": 5 }]
  },
  {
    "matcher": "Bash",
    "hooks": [{ "type": "command", "command": "rtk hook claude" }]
  }
]
```

**검증 패턴 (SC-1) — JSON 유효성 + hook 공존 확인:**
```bash
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

**기대 출력:**
```
JSON valid: OK
RTK hook: FOUND
GSD commit hook: FOUND
Total PreToolUse hooks: 5
```

---

### `~/.claude/hooks/gsd-validate-commit.sh` (middleware, request-response)

**역할:** PreToolUse Bash hook — git commit 명령을 가로채 Conventional Commits 형식 검증

**Analog:** `~/.claude/hooks/gsd-validate-commit.sh` (자기 자신)

**opt-in 구조 패턴** (lines 10-16):
```bash
# opt-in 구조: config.json에 hooks.community: true가 없으면 즉시 exit 0
if [ -f .planning/config.json ]; then
  ENABLED=$(node -e "try{const c=require('./.planning/config.json');process.stdout.write(c.hooks?.community===true?'1':'0')}catch{process.stdout.write('0')}" 2>/dev/null)
  if [ "$ENABLED" != "1" ]; then exit 0; fi
else
  exit 0
fi
```

**stdin JSON 파싱 패턴** (lines 18-21):
```bash
INPUT=$(cat)
CMD=$(echo "$INPUT" | node -e "let d='';process.stdin.on('data',c=>d+=c);process.stdin.on('end',()=>{try{process.stdout.write(JSON.parse(d).tool_input?.command||'')}catch{}})" 2>/dev/null)
```

**검증 패턴 (SC-3) — gsd-validate-commit.sh dry-run:**
```bash
echo '{"tool_name":"Bash","tool_input":{"command":"git commit -m \"docs(10): verify phase complete\""}}' \
  | bash /home/ozt88/.claude/hooks/gsd-validate-commit.sh
echo "exit code: $?"
```

**기대 출력:**
```
exit code: 0
```
(이유: `/home/ozt88/knowledge-compiler/.planning/config.json`에 `hooks.community: true` 없음 → opt-in 비활성 → 즉시 exit 0)

---

## Shared Patterns

### RTK hook 동작 메커니즘

**Source:** RESEARCH.md (VERIFIED: rtk hook claude dry-run 실행)
**Apply to:** SC-2 검증 task

RTK PreToolUse hook stdin/stdout 계약:
```json
// 입력 (Claude Code가 stdin으로 전달)
{"tool_name":"Bash","tool_input":{"command":"git status"}}

// rtk hook claude 출력 (rewrite 후)
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecisionReason": "RTK auto-rewrite",
    "updatedInput": {"command": "rtk git status"},
    "permissionDecision": "allow"
  }
}
```

**SC-2 검증 명령:**
```bash
rtk git status
```

**기대 출력 형식 (RTK 압축 포맷):**
```
* master...origin/master [ahead N]
~ Modified: N files
   <파일명>
? Untracked: N files
   <파일명>
```
원본 `git status` 대비: "use git add", "use git restore" 등 안내 문구 제거됨.

### Bash hook 공통 계약

**Source:** `/home/ozt88/.claude/hooks/gsd-validate-commit.sh` (lines 1-47)
**Apply to:** SC-3 검증 task 및 hook 동작 이해

모든 GSD Bash hook의 공통 패턴:
```bash
#!/bin/bash
# <name> — <event> hook: <description>
# OPT-IN: ...

INPUT=$(cat)          # stdin으로 tool call JSON 수신
CMD=$(echo "$INPUT" | node -e "...JSON.parse..." 2>/dev/null)  # Node.js 파싱

# 조건 검사
if [[ "$CMD" =~ <패턴> ]]; then
  echo '{"decision": "block", "reason": "..."}'
  exit 2              # block
fi

exit 0                # pass
```

---

## No Analog Found

없음 — 이 Phase의 모든 검증 대상은 기존 파일을 직접 참조한다.

---

## 검증 명령 요약 (Planner 참조용)

| SC | 명령 | 기대 결과 | 검증 요건 |
|----|------|-----------|-----------|
| SC-1 | `python3 -c "import json; ..."` (위 전체 스크립트) | JSON valid: OK, RTK/GSD hook: FOUND, Total: 5 | VERIFY-01 |
| SC-2 | `rtk git status` | `~ Modified:`, `? Untracked:` 압축 포맷 출력 | VERIFY-02 |
| SC-3 | `echo '{"tool_name":"Bash",...}' \| bash gsd-validate-commit.sh; echo "exit code: $?"` | exit code: 0 | VERIFY-02 |

---

## Metadata

**Analog search scope:** `~/.claude/settings.json`, `~/.claude/hooks/`, Phase 9 PATTERNS.md
**Files scanned:** 4 (settings.json, gsd-validate-commit.sh, gsd-session-state.sh, 09-PATTERNS.md)
**Pattern extraction date:** 2026-04-24
