# Phase 9: Install & Secure - Pattern Map

**Mapped:** 2026-04-23
**Files analyzed:** 3 (수정 대상 시스템 파일)
**Analogs found:** 2 / 3

---

## File Classification

| 수정 대상 | Role | Data Flow | Closest Analog | Match Quality |
|-----------|------|-----------|----------------|---------------|
| `~/.claude/settings.json` | config | event-driven | `~/.claude/settings.json` (현재 파일 자체) | exact — 기존 PreToolUse Bash 훅 구조 동일 |
| `~/.bashrc` | config | batch | `~/.bashrc` (현재 파일 자체) | exact — 기존 export 패턴 동일 |
| RTK 바이너리 (`/home/linuxbrew/.linuxbrew/bin/rtk`) | utility | request-response | analog 없음 — 외부 도구 설치 | none |

---

## Pattern Assignments

### `~/.claude/settings.json` — RTK PreToolUse Bash 훅 추가

**역할:** `rtk init -g` 실행으로 자동 패치됨 (직접 편집 금지 — Don't Hand-Roll 원칙)

**Analog:** `~/.claude/settings.json` (lines 119-159) — 기존 PreToolUse 섹션

**기존 Bash matcher 훅 패턴** (lines 151-159):
```json
{
  "matcher": "Bash",
  "hooks": [
    {
      "type": "command",
      "command": "bash /home/ozt88/.claude/hooks/gsd-validate-commit.sh",
      "timeout": 5
    }
  ]
}
```

**Phase 9 이후 예상 추가 항목** (배열에 append):
```json
{
  "matcher": "Bash",
  "hooks": [
    {
      "type": "command",
      "command": "bash ~/.claude/hooks/rtk-rewrite.sh"
    }
  ]
}
```

**핵심 제약:**
- `rtk init -g`가 `.bak` 백업 후 자동 패치 — 수동 JSON 편집 금지
- 패치 후 `jq . ~/.claude/settings.json > /dev/null` 유효성 검증 필수
- `~/.claude/settings.json.bak` 존재 확인 필수

---

### `~/.bashrc` — RTK_TELEMETRY_DISABLED=1 영구 등록

**역할:** 환경변수 영구 등록 (SEC-01 요구사항)

**Analog:** `~/.bashrc` (lines 153-157) — 기존 export 패턴

**기존 export 패턴** (lines 153-157):
```bash
export ANTHROPIC_DEFAULT_SONNET_MODEL='claude-sonnet-4-6'
export ANTHROPIC_DEFAULT_HAIKU_MODEL='vertex_ai/claude-haiku-4-5@20251001'
export ANTHROPIC_MODEL='claude-sonnet-4-6'
export ANTHROPIC_SMALL_FAST_MODEL='vertex_ai/claude-haiku-4-5@20251001'
export CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1
```

**추가할 라인 (동일 패턴):**
```bash
export RTK_TELEMETRY_DISABLED=1
```

**등록 명령:**
```bash
echo 'export RTK_TELEMETRY_DISABLED=1' >> ~/.bashrc
```

**검증 명령:**
```bash
grep 'RTK_TELEMETRY_DISABLED=1' ~/.bashrc
bash -c 'source ~/.bashrc && echo "RTK_TELEMETRY_DISABLED=$RTK_TELEMETRY_DISABLED"'
```

---

## Shared Patterns

### 기존 PreToolUse 훅 구조

**Source:** `~/.claude/settings.json` (lines 119-159)
**Apply to:** RTK 훅 등록 검증 시 참조

현재 PreToolUse 배열에는 4개 항목 존재:
- Write|Edit matcher: gsd-prompt-guard.js, gsd-read-guard.js, gsd-workflow-guard.js
- Bash matcher: gsd-validate-commit.sh

RTK 훅은 **5번째 항목**으로 Bash matcher에 추가됨.

### Bash 훅 스크립트 구조

**Source:** `/home/ozt88/.claude/hooks/gsd-validate-commit.sh`
**Apply to:** RTK 훅 스크립트 동작 이해 시 참조

기존 Bash 훅의 공통 패턴:
```bash
#!/bin/bash
# <name> — <event> hook: <description>

INPUT=$(cat)  # stdin으로 tool call JSON 수신

# Node.js로 tool_input.command 파싱 (jq 불필요 패턴)
CMD=$(echo "$INPUT" | node -e "..." 2>/dev/null)

# 조건 분기 후 exit 0 (pass) 또는 exit 2 (block)
exit 0
```

RTK 훅(`rtk-rewrite.sh`)은 `rtk init -g`가 자동 생성 — 직접 작성 불필요.

### 실행 순서 패턴 (D-06)

모든 단계는 이 순서를 준수해야 함:
```bash
# 1. 현재 셸에 즉시 적용
export RTK_TELEMETRY_DISABLED=1

# 2. ~/.bashrc 영구 등록
echo 'export RTK_TELEMETRY_DISABLED=1' >> ~/.bashrc

# 3. RTK init 실행 (env var이 이미 설정된 상태)
rtk init -g

# 4. JSON 유효성 검증
jq . ~/.claude/settings.json > /dev/null && echo "JSON valid"
```

---

## No Analog Found

| 파일/도구 | Role | Data Flow | Reason |
|-----------|------|-----------|--------|
| RTK 바이너리 (`rtk`) | utility | request-response | 외부 도구 — 코드베이스에 유사 설치 스크립트 없음. RESEARCH.md Code Examples 참조. |

---

## 핵심 주의 사항 (Pitfalls → 구현 지시)

| Pitfall | 대응 패턴 |
|---------|-----------|
| C1: crates.io 동명 패키지 | `brew install rtk` 전용 — `cargo install rtk` 금지 |
| C2: init 대화형 프롬프트 텔레메트리 동의 | `export RTK_TELEMETRY_DISABLED=1` 선행 필수 (D-06 순서 엄수) |
| C3: settings.json JSON 손상 | `jq . ~/.claude/settings.json > /dev/null` 패치 직후 실행 |
| H2: 두 Bash 훅 실행 순서 | 설치 후 `git status`로 RTK 압축 출력 확인 |

---

## Metadata

**Analog search scope:** `~/.claude/` (settings.json, hooks/), `~/.bashrc`
**Files scanned:** 4 (settings.json, gsd-validate-commit.sh, gsd-session-state.sh, .bashrc)
**Pattern extraction date:** 2026-04-23
