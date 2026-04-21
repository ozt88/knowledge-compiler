# Stack Research: Token Optimization Tools

**Project:** knowledge-compiler v1.2
**Researched:** 2026-04-21
**Confidence:** HIGH (RTK 공식 GitHub README, INSTALL.md, TELEMETRY.md 직접 확인)

---

## RTK (rtk-ai/rtk)

**정의:** Bash 툴 출력을 LLM에 전달하기 전에 필터링·압축하는 Rust 단일 바이너리 CLI 프록시.
60-90% 토큰 절감. 2026-01-22 오픈소스화, 현재 31,058 stars.

### 버전 정보

| 항목 | 값 |
|------|-----|
| 최신 stable | v0.37.2 (2026-04-20 릴리스) |
| 언어 | Rust (단일 바이너리, 의존성 없음) |
| 라이선스 | Apache-2.0 (Homebrew) / MIT (GitHub badge) |
| Homebrew 30일 설치 수 | 19,070건 |

### 설치 방법 (WSL2 Linux x86_64 환경)

**권장: Homebrew (Linuxbrew) — 가장 안정적이고 업데이트 용이**

```bash
brew install rtk
# → /home/linuxbrew/.linuxbrew/bin/rtk 설치
# → Linuxbrew가 이미 설치되어 있음 (Homebrew 5.0.7 확인됨)
```

Homebrew에서 v0.37.2 확인됨 (`brew info rtk`).

**대안 1: install.sh (curl)**

```bash
curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh
# → ~/.local/bin/rtk 설치
# → ~/.local/bin은 이미 PATH에 포함되어 있음
```

**대안 2: 사전 빌드 바이너리 직접 다운로드**

```bash
# Linux x86_64 musl (정적 링크, WSL2에 적합)
curl -L https://github.com/rtk-ai/rtk/releases/download/v0.37.2/rtk-x86_64-unknown-linux-musl.tar.gz | tar xz
mv rtk ~/.local/bin/
```

**NOT 권장: cargo install** — Cargo/Rust가 이 환경에 없음. crates.io에 동명의 다른 패키지(Rust Type Kit) 존재하여 혼동 위험.

### 설치 후 검증

```bash
rtk --version   # "rtk 0.37.2" 출력 확인
rtk gain        # 토큰 절감 통계 출력 — 이게 나와야 올바른 RTK
# "command not found"가 나오면 잘못된 패키지 설치된 것
```

### Claude Code 훅 통합

RTK는 Claude Code의 **PreToolUse 훅 (Bash 매처)**으로 통합된다.

```bash
rtk init -g              # 글로벌 설치 (권장)
# → ~/.claude/hooks/rtk-rewrite.sh 설치
# → ~/.claude/RTK.md 생성 (10줄, meta commands만)
# → ~/.claude/CLAUDE.md에 @RTK.md 참조 추가
# → ~/.claude/settings.json에 PreToolUse 훅 등록 (선택, 프롬프트로 확인)
```

**작동 방식:**
```
Claude "git status" → settings.json PreToolUse 훅 → rtk-rewrite.sh → rtk git status → RTK 바이너리 필터 → 압축된 출력
```

**기존 settings.json과의 충돌:**
현재 settings.json에 PreToolUse 훅이 `Write|Edit` 매처로 3개 등록되어 있음. RTK는 `Bash` 매처로 추가 — 매처가 다르므로 충돌 없음. `--auto-patch` 옵션으로 비대화형 패치 가능.

```bash
rtk init -g --auto-patch    # 대화 없이 settings.json 자동 패치 (CI/CD용)
rtk init -g --hook-only     # 훅만 설치, CLAUDE.md/RTK.md 추가 없음
rtk init --show             # 현재 설치 상태 확인
```

### 텔레메트리 제어 — 핵심 항목

**기본값: 비활성화 (opt-in 방식)**

RTK 텔레메트리는 명시적 동의 없이 어떠한 데이터도 전송하지 않는다. GDPR Art. 6, 7 준수.

```bash
rtk telemetry status    # 현재 동의 상태 확인
rtk telemetry disable   # 동의 철회 (데이터 수집 즉시 중단)
rtk telemetry forget    # 동의 철회 + 로컬 데이터 삭제 + 서버 삭제 요청
```

**환경변수로 강제 비활성화 (사내 보안 규정 준수용 권장):**

```bash
export RTK_TELEMETRY_DISABLED=1
# ~/.bashrc 또는 ~/.zshrc에 추가하면 consent 상태와 무관하게 완전 차단
```

`rtk init` 실행 시 동의 여부를 묻는 프롬프트가 나온다. 이때 거부하거나, `--auto-patch`로 비대화형 실행 시 자동으로 비활성화 상태 유지.

**무엇이 수집되지 않는가 (명시적 확인):**
- 소스 코드, 파일 경로, 명령 인수
- 시크릿, API 키, 환경 변수 값
- 레포지토리 이름/URL, 개인정보

**수집 항목 (opt-in 시에만):** 익명 device hash (SHA-256), RTK 버전, OS, 일일 명령 수, 토큰 절감량 (집계값만).

### 설정 파일

```toml
# ~/.config/rtk/config.toml
[hooks]
exclude_commands = ["curl", "playwright"]  # 재작성에서 제외할 명령

[tee]
enabled = true
mode = "failures"   # 실패 시 원본 출력 저장 (LLM이 재실행 없이 읽기 가능)
```

---

## 대안 도구 분석

### 비교 범위

클라이언트 단에서만 동작하고, Claude Code Bash 훅으로 통합 가능한 도구만 대상으로 조사.
서버 사이드 프록시(LiteLLM 등), MCP 서버, Claude Code 내장 autocompact는 범위 외.

### 대안 없음 — RTK가 해당 니치의 유일한 선택지

GitHub에서 다수의 쿼리로 조사한 결과, RTK에 직접 경쟁하는 동급 도구가 현재 존재하지 않는다:

- "Claude Code token optimization hook" 검색: 0건
- "LLM bash output compress token" 검색: 0건
- "claude code hook bash token compress" 검색: 0건
- "ai token reduce output filter cli" 검색: 0건

RTK는 2026년 1월 오픈소스화 이후 31,000+ stars를 획득했으며, Homebrew 공식 formula에 등재되어 있다. 이 수준의 traction을 가진 동등 도구가 존재하지 않음.

### 부분적 대안

| 도구 | 설명 | 왜 Not 선택 |
|------|------|------------|
| **Claude Code autocompact** | 내장 컨텍스트 압축 (`CLAUDE_CODE_AUTOCOMPACT_PCT_OVERRIDE=80` 이미 설정됨) | 이미 활성화됨. Bash 출력 필터링 아님, 전체 컨텍스트 압축 |
| **수동 CLAUDE.md 지시** | "출력을 간결하게" 등의 프롬프트 지시 | LLM이 무시하거나 일관성 없음, 정량적 절감 불가 |
| **simonw/llm CLI** | LLM API 호출 CLI | 토큰 최적화 도구 아님, 다른 용도 |
| **커스텀 셸 함수** | `function git() { command git $@ | head -50; }` 형태 | 명령별 수동 작성 필요, 100+ 명령 커버 불가, RTK의 스마트 필터링 없음 |

---

## 권장 스택

**RTK v0.37.2 — brew install rtk**

### 선택 근거

1. **텔레메트리 기본 비활성화 (opt-in):** 사내 보안 규정 준수. `RTK_TELEMETRY_DISABLED=1` 환경변수로 이중 보호 가능.
2. **Claude Code 네이티브 통합:** `rtk init -g`로 PreToolUse 훅 자동 등록. GSD 기존 훅(`Write|Edit` 매처)과 매처 충돌 없음.
3. **대안 없음:** 이 기능을 하는 다른 도구가 현재 없음. RTK가 사실상 표준.
4. **Linuxbrew 사용 가능:** `brew install rtk` — 이 환경에서 가장 간단하고 안전한 설치 방법. Homebrew 5.0.7 이미 설치됨, RTK v0.37.2 formula 확인됨.
5. **단일 바이너리:** 의존성 없음, 언인스톨 clean.
6. **WSL2 완전 지원:** `rtk-x86_64-unknown-linux-musl` 바이너리 및 훅 전체 기능 동작.

### 설치 명령 (최종)

```bash
# 1. 설치
brew install rtk

# 2. 검증 (올바른 RTK인지 확인)
rtk gain

# 3. Claude Code 통합 (대화형 — telemetry 거부 선택)
rtk init -g

# 또는 비대화형 (CI/스크립트용)
RTK_TELEMETRY_DISABLED=1 rtk init -g --auto-patch

# 4. 텔레메트리 환경변수 영구 설정 (사내 보안)
echo 'export RTK_TELEMETRY_DISABLED=1' >> ~/.bashrc

# 5. 설치 확인
rtk init --show
```

### 설치하지 말아야 할 것

- `cargo install rtk` — crates.io에 동명의 다른 패키지(Rust Type Kit) 존재, 혼동 위험
- `cargo install --git https://github.com/rtk-ai/rtk` — Cargo/Rust가 이 환경에 없음
- npm/pip/기타 패키지 매니저 — RTK는 Rust 바이너리, 해당 없음

---

## 의존성 요약

| 항목 | 상태 |
|------|------|
| Linuxbrew | 설치됨 (5.0.7) |
| RTK | 미설치 — 설치 필요 |
| Cargo/Rust | 없음 — brew 사용으로 불필요 |
| Claude Code hooks dir | 존재 (`~/.claude/hooks/`) |
| settings.json PreToolUse 섹션 | 존재 (RTK 훅 추가 가능) |
| `~/.local/bin` | PATH에 포함됨 (curl 설치 방식 사용 시) |

---

## 소스

- https://github.com/rtk-ai/rtk (README, INSTALL.md, docs/TELEMETRY.md 직접 확인)
- https://github.com/rtk-ai/rtk/releases/tag/v0.37.2 (릴리스 노트, 에셋 목록)
- `brew info rtk` 실행 결과 (v0.37.2, Homebrew 공식 formula 확인)
- `~/.claude/settings.json` 직접 확인 (기존 훅 구성 파악)
