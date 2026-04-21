# Architecture: Token Optimization Integration

**Project:** knowledge-compiler v1.2
**Researched:** 2026-04-21
**Confidence:** HIGH (공식 Claude Code hooks 문서 직접 확인)

---

## Integration Points

### 1. Claude Code Hook 시스템 구조

Claude Code는 `~/.claude/settings.json`의 `hooks` 섹션을 통해 tool 실행 전후에 shell command를 실행한다. 관련 hook event는 세 가지다.

| Hook Event | 발화 시점 | 주요 output 필드 |
|---|---|---|
| `PreToolUse` | tool 실행 직전 | `updatedInput` (command 수정), `permissionDecision` (allow/deny/ask/defer), `additionalContext` |
| `PostToolUse` | tool 실행 완료 후 | `decision: "block"`, `additionalContext`, `updatedMCPToolOutput` (MCP 전용) |
| `SessionStart` | 세션 시작 | `additionalContext`, `systemMessage` |

**확인된 사실:** PreToolUse hook은 `updatedInput` 필드로 Bash tool의 `command` 파라미터를 실행 전에 수정할 수 있다. 이것이 RTK의 핵심 메커니즘이다.

### 2. RTK의 Bash 인터셉션 메커니즘

RTK는 `rtk init -g` 실행 시 `~/.claude/settings.json`에 PreToolUse Bash hook을 추가한다.

**동작 흐름:**
```
Claude가 Bash("git status") 호출
  → PreToolUse hook 발화 (stdin으로 JSON 수신)
  → rtk hook 실행: command = "git status" 파싱
  → hook stdout으로 반환:
    {
      "hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "permissionDecision": "allow",
        "updatedInput": {
          "command": "rtk git status"
        }
      }
    }
  → 실제 실행 명령: "rtk git status"
  → RTK가 명령 실행 후 출력을 클라이언트 사이드에서 압축
  → Claude에게 압축된 결과 반환
```

**RTK가 settings.json에 추가하는 예상 hook 구조:**
```json
{
  "PreToolUse": [
    {
      "matcher": "Bash",
      "hooks": [
        {
          "type": "command",
          "command": "rtk hook pre-bash",
          "timeout": 10
        }
      ]
    }
  ]
}
```

### 3. 현재 knowledge-compiler의 기존 Hook 목록

`~/.claude/settings.json`에 GSD가 등록한 기존 hooks:

| Event | Matcher | Command | 역할 |
|---|---|---|---|
| `SessionStart` | * | `gsd-check-update.js` | GSD 버전 업데이트 확인 |
| `SessionStart` | * | `gsd-session-state.sh` | 프로젝트 STATE.md 주입 |
| `PostToolUse` | `Bash\|Edit\|Write\|MultiEdit\|Agent\|Task` | `gsd-context-monitor.js` | 컨텍스트 사용량 모니터링, CRITICAL 시 additionalContext 주입 |
| `PostToolUse` | `Write\|Edit` | `gsd-phase-boundary.sh` | Phase boundary 감지 |
| `PreToolUse` | `Write\|Edit` | `gsd-prompt-guard.js` | .planning/ 파일 프롬프트 인젝션 방어 |
| `PreToolUse` | `Write\|Edit` | `gsd-read-guard.js` | 파일 읽기 전 가드 |
| `PreToolUse` | `Write\|Edit` | `gsd-workflow-guard.js` | GSD 워크플로 외 직접 수정 경고 |
| `PreToolUse` | `Bash` | `gsd-validate-commit.sh` | Conventional Commits 형식 검증 (opt-in) |

---

## Hook Conflict Analysis (RTK hook vs 기존 GSD hooks)

### 충돌 없음: 설계 레벨

Claude Code는 동일 event+matcher에 다수 hooks 공존을 지원한다. 모두 실행되며, 결정 우선순위는 `deny > defer > ask > allow`다. RTK hook과 GSD hooks는 각자 독립적으로 실행된다.

### 잠재적 충돌 1: PreToolUse Bash — gsd-validate-commit.sh vs RTK

| 항목 | gsd-validate-commit.sh | RTK hook |
|---|---|---|
| 역할 | git commit 메시지 형식 검증 | bash command를 "rtk ..." 로 rewrite |
| 대상 | `git commit` 명령만 | 모든 bash 명령 |
| 실행 순서 | settings.json 배열 순서 |  settings.json 배열 순서 |
| 결정 방식 | `deny` (비준수 시) 또는 exit 0 | `allow` + `updatedInput` |

**충돌 가능성:** LOW

- `gsd-validate-commit.sh`가 먼저 실행된다면: git commit을 deny하고 RTK hook은 실행 안 됨 → RTK가 래핑할 명령 자체가 차단됨 → 정상 동작
- RTK hook이 먼저 실행된다면: `git commit "..."` → `rtk git commit "..."` 로 rewrite → gsd-validate-commit은 `rtk git commit`을 파싱해야 함 → **validate-commit이 Conventional Commits 검사를 못 할 수 있음**

**실행 순서 결정 방법:** settings.json의 `hooks.PreToolUse` 배열에서 앞에 있는 것이 먼저 실행됨. RTK가 배열 끝에 추가되면 validate-commit이 먼저 실행되어 문제 없음.

**gsd-validate-commit.sh는 기본적으로 OPT-IN (`.planning/config.json`에 `hooks.community: true` 필요)이므로 일반 상황에서는 no-op이다.** 충돌 위험 낮음.

### 잠재적 충돌 2: PostToolUse Bash — gsd-context-monitor.js와 RTK

RTK가 PostToolUse Bash hook을 추가하는 경우 gsd-context-monitor.js와 같은 matcher를 가짐. 둘 다 실행되지만 서로 독립적이므로 충돌 없음.

**단, RTK가 Bash 출력을 압축한 상태로 tool_response를 받을 수 있음.** 이 경우 gsd-context-monitor.js가 받는 tool_response의 크기가 줄어들어 context 계산이 부정확해질 수 있으나, context-monitor는 token 수가 아닌 StatusLine API의 remaining_percentage를 읽으므로 영향 없음.

### 잠재적 충돌 3: RTK의 updatedInput과 permissions 배열

현재 settings.json의 `permissions.allow` 배열에는 특정 명령 패턴이 등록되어 있다. RTK가 "git status"를 "rtk git status"로 rewrite하면, `Bash(git log:*)` 같은 허용 패턴이 `rtk git log` 명령에 매치되지 않아 permission 팝업이 발생할 수 있다.

**해결:** `rtk init -g` 실행 후 `Bash(rtk:*)` 패턴을 permissions.allow에 추가하거나, RTK hook이 `permissionDecision: "allow"`를 함께 반환하여 자동 승인.

RTK가 `permissionDecision: "allow"`를 반환하면 permission 프롬프트 자체가 skip된다. 이것이 RTK의 "transparent" 동작의 핵심이다.

### 충돌 없음: CLAUDE.md 기반 수집

RTK는 CLAUDE.md의 텍스트 지시사항 (Knowledge Compiler 수집 규칙)에 전혀 개입하지 않는다. LLM이 응답할 때 `.knowledge/raw/`에 append하는 행동은 Bash tool을 통해 발생하므로, RTK가 `rtk append ...`로 rewrite할 수 있지만 파일 append 자체는 그대로 동작한다.

---

## Configuration Steps

### Step 1: RTK 설치

```bash
# RTK 설치 방법 (npm 기반 추정)
npm install -g rtk
# 또는 별도 설치 방법 (공식 문서 확인 필요)
```

### Step 2: RTK 초기화 (Global)

```bash
rtk init -g
```

이 명령이 `~/.claude/settings.json`의 `hooks.PreToolUse` 배열에 RTK Bash hook을 추가한다.

**주의:** `rtk init -g` 실행 후 settings.json을 확인하여 RTK hook이 배열의 **끝**에 추가되었는지 확인. 배열 위치를 수동으로 조정해야 할 수 있음. GSD hooks(특히 gsd-validate-commit.sh)가 RTK hook보다 먼저 실행되어야 한다.

### Step 3: 텔레메트리 확인

milestone_context에 따르면 RTK 텔레메트리는 **opt-in only**. 기본값은 OFF이므로 `rtk init -g` 후 별도 설정 불필요.

```bash
# 텔레메트리가 비활성화 상태인지 확인
rtk telemetry status
# → "disabled" 상태 확인
# telemetry enable을 실행하지 않는 한 자동으로 OFF
```

### Step 4: Permission 설정 확인

`rtk init -g`가 자동으로 RTK permission을 추가하는지 확인. 추가하지 않으면 수동으로:

```json
// ~/.claude/settings.json의 permissions.allow에 추가
"Bash(rtk:*)"
```

또는 RTK hook이 `permissionDecision: "allow"`를 반환하므로 불필요할 수 있음.

### Step 5: 통합 검증

```bash
# RTK가 정상 동작하는지 확인
git status  # Claude가 이 명령 실행 시 내부적으로 "rtk git status"로 변환
# 출력이 압축되어 반환되면 성공

# 기존 GSD hooks가 여전히 동작하는지 확인
# .planning/STATE.md가 있는 프로젝트에서 세션 시작 → STATE 주입 확인
```

---

## Build Order

의존성 기반 순서:

```
1. [INSTALL] RTK 바이너리 설치
   └─ 선행 조건: 없음 (독립 도구)
   └─ 결과물: rtk 명령 사용 가능

2. [CONFIGURE] rtk init -g 실행
   └─ 선행 조건: Step 1 완료
   └─ 수정 대상: ~/.claude/settings.json (기존 파일 수정)
   └─ 결과물: settings.json에 PreToolUse Bash hook 추가

3. [VERIFY TELEMETRY] 텔레메트리 비활성화 상태 확인
   └─ 선행 조건: Step 2 완료
   └─ 명령: rtk telemetry status → "disabled" 확인
   └─ 액션 없음: opt-in only이므로 기본값 OFF

4. [VERIFY HOOK ORDER] settings.json hook 순서 확인
   └─ 선행 조건: Step 2 완료
   └─ 확인: PreToolUse Bash hooks 배열에서 GSD hooks가 RTK hook보다 앞에 있는지
   └─ 필요시: 수동으로 배열 순서 조정

5. [VERIFY PERMISSIONS] permission 설정 확인
   └─ 선행 조건: Step 2 완료
   └─ 확인: RTK 명령이 permission 팝업 없이 실행되는지
   └─ 필요시: "Bash(rtk:*)" 패턴을 permissions.allow에 추가

6. [INTEGRATION TEST] 실제 동작 검증
   └─ 선행 조건: Steps 1-5 완료
   └─ 테스트: Claude Code 세션에서 git status 실행 → 압축 출력 확인
   └─ 테스트: GSD hooks 정상 동작 확인 (phase-boundary, context-monitor)
```

---

## 신규 vs 수정 파일

| 파일 | 변경 유형 | 설명 |
|---|---|---|
| `~/.claude/settings.json` | **수정** | `rtk init -g`가 hooks 섹션에 RTK hook 추가 |
| RTK 바이너리 | **신규** | 시스템에 새로 설치되는 CLI 도구 |
| RTK 설정 파일 | **신규** | `~/.rtk/` 또는 유사 위치 (설치 후 확인 필요) |
| `~/.claude/CLAUDE.md` | **수정 없음** | RTK와 무관, 기존 수집 지시 유지 |
| GSD hooks (`~/.claude/hooks/`) | **수정 없음** | RTK와 독립적으로 공존 |
| `knowledge-compiler/.planning/` | **수정 없음** | RTK 영향 범위 밖 |

---

## 소스 및 신뢰도

| 항목 | 근거 | 신뢰도 |
|---|---|---|
| Claude Code hook 시스템 (PreToolUse updatedInput) | 공식 문서 직접 확인 (code.claude.com/docs/en/hooks) | HIGH |
| RTK 설치/동작 방식 | milestone_context 설명 기반 (직접 확인 불가) | MEDIUM |
| RTK가 PreToolUse hook 사용 | milestone_context "Bash hook intercepts all bash tool calls" + updatedInput 메커니즘 추론 | MEDIUM |
| 텔레메트리 기본값 OFF | milestone_context "opt-in only via rtk telemetry enable" | MEDIUM |
| Hook 충돌 분석 | 공식 문서 + 현재 settings.json 직접 확인 | HIGH |
| Permission 충돌 가능성 | 현재 settings.json 분석 + PreToolUse allow 메커니즘 | HIGH |
