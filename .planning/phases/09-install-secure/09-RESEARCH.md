# Phase 9: Install & Secure - Research

**Researched:** 2026-04-23
**Domain:** RTK (rtk-ai/rtk) 설치 및 텔레메트리 보안 설정
**Confidence:** HIGH

---

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

- **D-01:** `brew install rtk` 사용 (cargo install rtk 금지 — crates.io 동명 패키지 "Rust Type Kit" 존재). Linuxbrew binary는 `/home/linuxbrew/.linuxbrew/bin`에 설치되어 PATH 문제 없음.
- **D-02:** 설치 후 `rtk gain` 실행으로 올바른 바이너리인지 즉시 검증.
- **D-03:** `RTK_TELEMETRY_DISABLED=1` 환경변수를 `~/.bashrc`에 영구 등록한 후 `rtk init -g` 실행. 이렇게 하면 init 대화형 프롬프트 자체가 텔레메트리 수집을 못 하게 차단된다.
- **D-04:** `~/.bashrc`에만 등록 (`/etc/environment`는 불필요 — 과도).
- **D-05:** `rtk telemetry disable` 별도 실행은 하지 않음. D-03의 env var으로 충분하다고 결정. (VERIFY-02에서 `rtk telemetry status` 확인은 Phase 10에서 수행)
- **D-06:** `export RTK_TELEMETRY_DISABLED=1` → `echo '...' >> ~/.bashrc` → `rtk init -g` 순서로 실행. 환경변수가 미리 설정된 상태에서 init 실행.
- **D-07:** PATH 문제 없음. Linuxbrew 바이너리는 이미 PATH에 등록된 경로에 설치됨. 별도 PATH 조작 불필요.
- **D-08:** 프로젝트 파일 수정 없음. RTK는 개인 도구 — README나 설정 파일 변경 불필요. GSD 커밋 메시지로 설치 이력 충분.

### Claude's Discretion

- settings.json 백업 방법 — RTK가 자동으로 `.bak` 생성하므로 추가 조치는 Claude 판단
- jq 의존성 사전 확인 여부 — 필요하다고 판단되면 체크 추가

### Deferred Ideas (OUT OF SCOPE)

없음 — 논의가 Phase 9 범위 내에서 유지됨.
</user_constraints>

---

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| INSTALL-01 | RTK v0.37.2+를 `brew install rtk`로 설치하고 `rtk gain`으로 올바른 바이너리임을 확인 | brew formula v0.37.2 확인됨, `rtk gain` 검증 방법 문서화 |
| INSTALL-02 | `rtk init -g`로 Claude Code `~/.claude/settings.json`에 `PreToolUse` Bash hook을 등록 | 기존 PreToolUse 훅 구조 확인, Bash 매처 충돌 없음 검증됨 |
| SEC-01 | `RTK_TELEMETRY_DISABLED=1` 환경변수를 `~/.bashrc`에 영구 등록 | ~/.bashrc에 미등록 확인, 등록 방법 문서화 |
| SEC-02 | `rtk telemetry disable` 실행 후 `rtk telemetry status`가 "disabled" 반환 확인 | CONTEXT.md D-05에 의해 Phase 10으로 이관됨 — 이 Phase에서는 env var만으로 충분 |
</phase_requirements>

---

## Summary

Phase 9는 순수 시스템 레벨 설치 작업이다. RTK v0.37.2를 Homebrew로 설치하고, 텔레메트리 환경변수를 `~/.bashrc`에 영구 등록한 후, `rtk init -g`로 Claude Code settings.json에 PreToolUse Bash 훅을 등록한다. 프로젝트 코드 변경은 전혀 없다.

환경 조사 결과: Homebrew 5.0.7 설치됨, RTK formula v0.37.2 사용 가능, jq 1.8.1 설치됨, `~/.claude/settings.json` 존재, `RTK_TELEMETRY_DISABLED` 미등록 상태. 실행 순서는 D-06에 의해 확정됨: env var 설정 → ~/.bashrc 등록 → `rtk init -g`.

핵심 주의 사항: `rtk init -g`는 대화형 프롬프트를 표시한다 (텔레메트리 동의 여부). `RTK_TELEMETRY_DISABLED=1`이 환경에 미리 설정되어 있으면 이 프롬프트가 자동으로 거부 처리된다. settings.json 패치 후 JSON 유효성 검증 필수.

**Primary recommendation:** `brew install rtk` → `rtk gain` 검증 → `RTK_TELEMETRY_DISABLED=1` ~/.bashrc 등록 → `rtk init -g` → settings.json JSON 유효성 확인

---

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| RTK 바이너리 설치 | OS / Package Manager | — | Homebrew가 바이너리를 /home/linuxbrew/.linuxbrew/bin에 관리 |
| Claude Code 훅 등록 | ~/.claude/settings.json | — | Claude Code PreToolUse 이벤트가 RTK 훅을 실행 |
| 텔레메트리 차단 | Shell 환경 (~/.bashrc) | RTK 내부 설정 | env var이 RTK 바이너리보다 먼저 평가됨 |
| Bash 출력 압축 | OS / RTK 바이너리 | Claude Code hook system | RTK가 Bash 명령 결과를 인터셉트하여 필터링 |

---

## Standard Stack

### Core

| 도구 | 버전 | 목적 | 상태 |
|------|------|------|------|
| Homebrew (Linuxbrew) | 5.0.7 | RTK 패키지 매니저 | 설치됨 [VERIFIED: brew --version] |
| RTK | v0.37.2 | Bash 출력 압축 프록시 | 미설치 — 설치 필요 [VERIFIED: brew info rtk] |
| jq | 1.8.1 | RTK 훅 스크립트 의존성 | 설치됨 [VERIFIED: jq --version] |

### 관련 파일

| 파일 | 상태 | Phase 9에서의 역할 |
|------|------|-----------------|
| `~/.claude/settings.json` | 존재 [VERIFIED: ls 확인] | `rtk init -g`가 PreToolUse Bash 훅 추가 |
| `~/.bashrc` | 존재 | `RTK_TELEMETRY_DISABLED=1` 영구 등록 위치 |
| `~/.claude/settings.json.bak` | 미존재 — rtk init 후 생성됨 | RTK 자동 백업 |

**설치 명령:**
```bash
brew install rtk
```

---

## Architecture Patterns

### 데이터 플로우

```
Claude Code (Bash tool call)
        |
        v
PreToolUse hook (settings.json)
  ├── [matcher: "Write|Edit"] → gsd-prompt-guard.js
  ├── [matcher: "Write|Edit"] → gsd-read-guard.js
  ├── [matcher: "Write|Edit"] → gsd-workflow-guard.js
  ├── [matcher: "Bash"] → gsd-validate-commit.sh    ← 기존
  └── [matcher: "Bash"] → rtk-rewrite.sh            ← Phase 9에서 추가됨
                |
                v
          RTK 바이너리 실행
                |
        ┌───────┴──────────┐
        v                  v
  [명령 인식됨]        [명령 미인식]
  압축된 출력 반환      원본 pass-through
```

### settings.json 훅 등록 구조 (Phase 9 이후 예상)

```json
"PreToolUse": [
  {"matcher": "Write|Edit", "hooks": [{"type": "command", "command": "...gsd-prompt-guard.js"}]},
  {"matcher": "Write|Edit", "hooks": [{"type": "command", "command": "...gsd-read-guard.js"}]},
  {"matcher": "Write|Edit", "hooks": [{"type": "command", "command": "...gsd-workflow-guard.js"}]},
  {"matcher": "Bash", "hooks": [{"type": "command", "command": "...gsd-validate-commit.sh"}]},
  {"matcher": "Bash", "hooks": [{"type": "command", "command": "bash ~/.claude/hooks/rtk-rewrite.sh"}]}
]
```

### RTK init 옵션

```bash
rtk init -g              # 글로벌 설치 (대화형 — 텔레메트리 프롬프트 표시)
rtk init -g --auto-patch # 비대화형 (CI용 — 개인 개발 환경에는 권장 안함)
rtk init -g --hook-only  # 훅만 설치, CLAUDE.md/RTK.md 추가 없음
rtk init --show          # 현재 설치 상태 확인
```

**권장 방식:** 환경변수 사전 설정 후 일반 `rtk init -g` 실행 (D-06 결정)

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| settings.json 훅 등록 | 수동 JSON 편집 | `rtk init -g` | RTK가 백업(.bak) 생성 + 올바른 JSON 구조 보장 |
| 텔레메트리 차단 | 바이너리 패치 / 네트워크 차단 | `RTK_TELEMETRY_DISABLED=1` env var | RTK 공식 메커니즘, 업그레이드 후에도 지속 |
| Bash 출력 압축 | 커스텀 셸 함수 래퍼 | RTK 바이너리 | 100+ 명령 커버, 스마트 필터링, 단일 바이너리 |

---

## Common Pitfalls

### Pitfall C1: crates.io 이름 충돌 — 잘못된 바이너리 설치

**What goes wrong:** `cargo install rtk`는 crates.io의 "Rust Type Kit"을 설치. `rtk gain` 실행 시 오류 발생.
**Prevention:** `brew install rtk` 사용. 설치 후 즉시 `rtk gain` 실행으로 검증 (토큰 절감 통계가 출력되어야 함).
**Warning signs:** `rtk gain` → "unrecognized command" 또는 다른 형식의 출력

### Pitfall C2: rtk init 대화형 프롬프트에서 텔레메트리 실수 동의

**What goes wrong:** `rtk init -g` 실행 시 텔레메트리 동의 프롬프트 표시. Enter 키를 무심코 누르면 opt-in 처리됨.
**Prevention:** `RTK_TELEMETRY_DISABLED=1`을 현재 셸에 export한 상태에서 `rtk init -g` 실행 (D-06). env var이 미리 설정되면 프롬프트가 자동 거부 처리됨.
**Warning signs:** `rtk telemetry status` → "enabled"

### Pitfall C3: settings.json 패치 후 JSON 구조 손상

**What goes wrong:** `rtk init -g`가 settings.json을 잘못 패치하면 Claude Code가 전체 설정을 읽지 못함.
**Prevention:** 패치 후 `jq . ~/.claude/settings.json > /dev/null && echo "JSON valid"` 실행. `.bak` 파일 존재 확인.
**Warning signs:** `~/.claude/settings.json.bak` 부재, jq 파싱 오류

### Pitfall H2: 두 개의 Bash matcher 실행 순서 불확실

**What goes wrong:** `gsd-validate-commit.sh`와 RTK 훅 두 개가 Bash 이벤트에 매칭됨. Claude Code 훅 실행 순서는 배열 순서이지만 앞쪽 훅의 block 결정이 이후 훅을 건너뛸 수 있음.
**현재 영향:** 낮음 — `gsd-validate-commit.sh`는 git commit 패턴만 차단, RTK는 pass-through 방식으로 동작. 일반적인 경우 충돌 없음.
**Prevention:** 설치 후 `git status` 명령으로 RTK 압축 출력 확인. GSD 워크플로 실행으로 기존 guard 정상 동작 검증.

### Pitfall T1: 텔레메트리 opt-in 상태가 업그레이드 후 지속

**What goes wrong:** Homebrew로 RTK 업그레이드 후 `~/.local/share/rtk/.device_salt`가 유지됨. 텔레메트리 동의 상태 보존.
**Prevention:** `RTK_TELEMETRY_DISABLED=1` env var은 업그레이드 후에도 지속적으로 텔레메트리 차단. ~/.bashrc 등록으로 영속성 확보.

---

## Code Examples

### Phase 9 실행 순서 (전체)

```bash
# Step 1: RTK 설치
brew install rtk

# Step 2: 올바른 RTK 검증 (토큰 절감 통계가 출력되면 정상)
rtk gain
# Expected: "Token savings: ..." 형식의 통계 출력
# Error: "unrecognized command" → C1 pitfall 발생, brew 재설치 필요

# Step 3: 텔레메트리 env var를 현재 셸에 설정 (init 전 필수)
export RTK_TELEMETRY_DISABLED=1

# Step 4: ~/.bashrc에 영구 등록 (SEC-01)
echo 'export RTK_TELEMETRY_DISABLED=1' >> ~/.bashrc

# Step 5: Claude Code 글로벌 훅 등록 (INSTALL-02)
# RTK_TELEMETRY_DISABLED=1이 export된 상태이므로 텔레메트리 프롬프트 자동 거부
rtk init -g

# Step 6: settings.json JSON 유효성 검증 (Claude's Discretion)
jq . ~/.claude/settings.json > /dev/null && echo "JSON valid" || echo "JSON INVALID - check .bak"

# Step 7: 백업 파일 존재 확인
ls -la ~/.claude/settings.json.bak

# Step 8: RTK hook이 settings.json에 등록되었는지 확인 (INSTALL-02 검증)
jq '.hooks.PreToolUse[] | select(.matcher == "Bash")' ~/.claude/settings.json
```

### SEC-02 확인 명령 (Phase 9 성공 기준)

```bash
# RTK_TELEMETRY_DISABLED=1이 새 셸에서 적용되는지 확인
bash -c 'source ~/.bashrc && echo "RTK_TELEMETRY_DISABLED=$RTK_TELEMETRY_DISABLED"'
# Expected: RTK_TELEMETRY_DISABLED=1

# rtk telemetry status (env var 설정 후)
RTK_TELEMETRY_DISABLED=1 rtk telemetry status
# Expected: "disabled"
```

---

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Homebrew (Linuxbrew) | INSTALL-01 | ✓ | 5.0.7 | — |
| RTK formula | INSTALL-01 | ✓ (미설치) | v0.37.2 available | — |
| jq | INSTALL-02 (훅 스크립트) | ✓ | 1.8.1 | python3 json 파싱으로 대체 가능 |
| ~/.claude/settings.json | INSTALL-02 | ✓ | 존재 | — |
| ~/.bashrc | SEC-01 | ✓ | 존재 | — |

**Missing dependencies with no fallback:** 없음 — 모든 의존성 충족

**Pre-flight 확인 결과:**
- `RTK_TELEMETRY_DISABLED`: ~/.bashrc에 미등록 → Phase 9에서 등록 필요
- RTK 훅 in settings.json: 미존재 → Phase 9에서 `rtk init -g`로 등록

---

## Validation Architecture

### Test Framework

| Property | Value |
|----------|-------|
| Framework | Bash assertions (설치/설정 검증 — 유닛 테스트 프레임워크 불필요) |
| Config file | none |
| Quick run command | 각 검증 명령 개별 실행 |
| Full suite command | 아래 검증 단계 순차 실행 |

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command | Check |
|--------|----------|-----------|-------------------|-------|
| INSTALL-01 | `rtk gain` 토큰 통계 출력 | smoke | `rtk gain` | ❌ Wave 0 (설치 후) |
| INSTALL-02 | settings.json에 Bash matcher RTK 훅 존재 | smoke | `jq '.hooks.PreToolUse[] \| select(.matcher == "Bash") \| .hooks[].command' ~/.claude/settings.json \| grep rtk` | ❌ Wave 0 |
| SEC-01 | ~/.bashrc에 RTK_TELEMETRY_DISABLED=1 존재 | smoke | `grep 'RTK_TELEMETRY_DISABLED=1' ~/.bashrc` | ❌ Wave 0 |
| SEC-02 | rtk telemetry status → "disabled" | smoke | `RTK_TELEMETRY_DISABLED=1 rtk telemetry status` | ❌ Wave 0 |

### Wave 0 Gaps

모든 검증은 RTK 설치 후 수행 가능 — 별도 테스트 파일 불필요. 각 태스크 완료 시점에 해당 smoke 명령 실행으로 검증.

---

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | `RTK_TELEMETRY_DISABLED=1` env var가 미리 설정된 상태에서 `rtk init -g` 실행 시 텔레메트리 프롬프트가 자동 거부 처리됨 | Architecture Patterns | 대화형 프롬프트가 표시될 경우 수동으로 'n' 입력 필요 |

**A1 설명:** PITFALLS.md에서 "env var 설정 → init 실행" 순서를 권장하고, init이 env var를 존중한다고 기술되어 있으나 [CITED: .planning/research/PITFALLS.md], env var가 실행 중 prompt를 완전히 suppress하는지는 RTK 소스 코드 레벨에서 직접 확인되지 않음. 실제로는 `--auto-patch` 옵션이 더 확실하지만 D-01 맥락상 대화형 방식 유지.

---

## Open Questions

1. **`rtk init -g`가 --hook-only 없이 실행될 때 CLAUDE.md 수정 여부**
   - What we know: `rtk init -g` 기본 실행 시 `~/.claude/CLAUDE.md`에 `@RTK.md` 참조 추가 및 `~/.claude/RTK.md` 생성 [CITED: .planning/research/STACK.md]
   - What's unclear: D-08 결정 ("프로젝트 파일 수정 없음")이 `~/.claude/` 글로벌 파일에도 적용되는지
   - Recommendation: `--hook-only` 플래그 사용 여부를 플래너가 결정. 기본 `rtk init -g`로 진행하고 `~/.claude/RTK.md` 생성은 허용 (개인 도구 설정 파일).

2. **`rtk init -g` 텔레메트리 프롬프트 자동 거부 보장**
   - What we know: env var 선설정 후 init 실행 순서 (D-06)
   - What's unclear: env var이 interactive prompt를 suppresses하는지 vs 단순히 데이터 전송만 차단하는지
   - Recommendation: 태스크에 "프롬프트 표시 시 'n' 입력" 폴백 지시 포함.

---

## Sources

### Primary (HIGH confidence)
- `.planning/research/STACK.md` — RTK 버전, 설치 방법, 텔레메트리 제어, settings.json 충돌 분석 [VERIFIED: 파일 직접 확인]
- `.planning/research/PITFALLS.md` — C1~C3, H1~H3, T1~T3, Q1~Q4, I1~I2 전체 함정 목록 [VERIFIED: 파일 직접 확인]
- `~/.claude/settings.json` — 기존 PreToolUse 훅 구조 확인 [VERIFIED: 파일 직접 읽기]
- `brew info rtk` — formula v0.37.2, Apache-2.0, 미설치 상태 [VERIFIED: 명령 실행]
- `jq --version` — jq 1.8.1 설치 확인 [VERIFIED: 명령 실행]
- `brew --version` — Homebrew 5.0.7 설치 확인 [VERIFIED: 명령 실행]
- `grep RTK_TELEMETRY ~/.bashrc` — env var 미등록 상태 확인 [VERIFIED: 명령 실행]

### Secondary (MEDIUM confidence)
- `.planning/phases/09-install-secure/09-CONTEXT.md` — D-01~D-08 결정 사항

---

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — brew info rtk로 v0.37.2 공식 formula 확인, 환경 의존성 전체 검증됨
- Architecture: HIGH — settings.json 직접 확인, 기존 훅 구조 파악, RTK init 동작 이전 연구 문서 기반
- Pitfalls: HIGH — PITFALLS.md가 RTK 소스 코드 + live settings.json 검사 기반으로 작성됨

**Research date:** 2026-04-23
**Valid until:** 2026-05-23 (RTK는 활발히 개발 중 — formula 버전 변경 가능)
