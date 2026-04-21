# Phase 9: Install & Secure - Context

**Gathered:** 2026-04-21
**Status:** Ready for planning

<domain>
## Phase Boundary

RTK v0.37.2+ 바이너리를 설치하고, Claude Code settings.json에 PreToolUse Bash hook을
등록하며, 텔레메트리를 영구적으로 차단한다. 프로젝트 코드 변경 없음 — 시스템 레벨
도구 설치 및 설정만 수행한다.

</domain>

<decisions>
## Implementation Decisions

### 설치 방법

- **D-01:** `brew install rtk` 사용 (cargo install rtk 금지 — crates.io 동명 패키지
  "Rust Type Kit" 존재). Linuxbrew binary는 `/home/linuxbrew/.linuxbrew/bin`에 설치
  되어 PATH 문제 없음.
- **D-02:** 설치 후 `rtk gain` 실행으로 올바른 바이너리인지 즉시 검증.

### Telemetry 차단 (보안)

- **D-03:** `RTK_TELEMETRY_DISABLED=1` 환경변수를 `~/.bashrc`에 영구 등록한 후
  `rtk init -g` 실행. 이렇게 하면 init 대화형 프롬프트 자체가 텔레메트리 수집을
  못 하게 차단된다.
- **D-04:** `~/.bashrc`에만 등록 (`/etc/environment`는 불필요 — 과도).
- **D-05:** `rtk telemetry disable` 별도 실행은 하지 않음. D-03의 env var으로
  충분하다고 결정. (VERIFY-02에서 `rtk telemetry status` 확인은 Phase 10에서 수행)

### Init 실행 방식

- **D-06:** `export RTK_TELEMETRY_DISABLED=1` → `echo '...' >> ~/.bashrc` →
  `rtk init -g` 순서로 실행. 환경변수가 미리 설정된 상태에서 init 실행.

### PATH

- **D-07:** PATH 문제 없음. Linuxbrew 바이너리는 이미 PATH에 등록된 경로에 설치됨.
  별도 PATH 조작 불필요.

### 문서화

- **D-08:** 프로젝트 파일 수정 없음. RTK는 개인 도구 — README나 설정 파일 변경
  불필요. GSD 커밋 메시지로 설치 이력 충분.

### Claude's Discretion

- settings.json 백업 방법 — RTK가 자동으로 `.bak` 생성하므로 추가 조치는 Claude 판단
- jq 의존성 사전 확인 여부 — 필요하다고 판단되면 체크 추가

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### RTK 설치 소스

- `https://github.com/rtk-ai/rtk` — 공식 GitHub (brew formula: rtk)
- `.planning/research/STACK.md` — 설치 방법, 버전, 텔레메트리 옵션 상세
- `.planning/research/PITFALLS.md` — 함정 목록 (C1~C3, Q1, I2)
- `.planning/research/SUMMARY.md` — 설치 명령 요약

### 프로젝트 요구사항

- `.planning/REQUIREMENTS.md` — INSTALL-01, INSTALL-02, SEC-01, SEC-02

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets

- 없음 — 순수 시스템 도구 설치, 기존 코드 재사용 없음

### Established Patterns

- `~/.claude/settings.json`: 기존 GSD hooks (Write/Edit matcher) 존재.
  RTK hook은 Bash matcher로 별도 추가 — 충돌 없음.

### Integration Points

- `~/.claude/settings.json` — RTK PreToolUse hook 추가 위치
- `~/.bashrc` — RTK_TELEMETRY_DISABLED=1 영구 등록 위치

</code_context>

<specifics>
## Specific Ideas

- 설치 순서: `brew install rtk` → `rtk gain` (검증) →
  `~/.bashrc` env var 등록 → `rtk init -g` → settings.json hook 등록 확인

</specifics>

<deferred>
## Deferred Ideas

없음 — 논의가 Phase 9 범위 내에서 유지됨.

</deferred>

---

*Phase: 09-install-secure*
*Context gathered: 2026-04-21*
