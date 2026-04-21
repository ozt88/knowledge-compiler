# Research Summary: Token Optimization (v1.2)

## Selected Tool

**RTK (rtk-ai/rtk) v0.37.2** — Rust 단일 바이너리 CLI 프록시로, Bash 툴 출력을
LLM에 전달하기 전에 필터링·압축한다. 2026-01-22 오픈소스화, 현재 31,058 stars,
Homebrew 30일 설치 19,070건. 60-90% 토큰 절감(평균 80%). Claude Code
`PreToolUse` 훅으로 네이티브 통합되며, `rtk init -g` 한 명령으로 설치된다.
텔레메트리는 기본 OFF(opt-in 방식, GDPR Art.6/7 준수). 이 기능을 하는 경쟁
도구가 현재 존재하지 않아 사실상 유일한 선택지다.

## Stack Additions

권장 설치 방법 (WSL2 Linux, Linuxbrew 이미 설치됨):

```bash
# 1. 설치
brew install rtk

# 2. 올바른 RTK인지 검증 (crates.io 동명 패키지와 구분)
rtk gain   # 토큰 절감 통계가 출력되면 정상

# 3. Claude Code 훅 통합
RTK_TELEMETRY_DISABLED=1 rtk init -g

# 4. 텔레메트리 이중 차단 (사내 보안 규정)
rtk telemetry disable
echo 'export RTK_TELEMETRY_DISABLED=1' >> ~/.bashrc

# 5. 설치 결과 확인
rtk telemetry status   # "disabled" 확인
```

**절대 사용 금지:** `cargo install rtk` — crates.io에 동명 별개 패키지 존재.

## Feature Table Stakes

| 요구사항 | RTK 지원 | 비고 |
|---------|---------|------|
| 클라이언트 사이드 전용 | YES | 외부 런타임 없음 |
| 텔레메트리 완전 비활성화 | YES | 기본 OFF + env var 이중 차단 |
| Claude Code 훅 통합 | YES | PreToolUse Bash hook |
| 100+ 명령 커버리지 | YES | git, ls, grep, test runners 등 |
| 기존 GSD 훅 공존 | YES | Bash 매처 추가, 충돌 없음 |

**중요 범위 제한:** RTK는 Bash 툴 호출만 인터셉트한다. 내장 `Read`, `Grep`,
`Glob` 툴은 훅을 우회하므로 실제 절감율은 벤치마크보다 낮을 수 있다.

## Key Architecture Points

통합 메커니즘:
```
Claude "git status"
  → PreToolUse hook (settings.json)
  → RTK hook: updatedInput = {"command": "rtk git status"}
  → RTK 바이너리가 명령 실행 후 출력 압축
  → 압축된 결과를 Claude에게 전달
```

- RTK hook이 `PreToolUse Bash` 배열에 추가됨
- 기존 GSD 훅(Write/Edit 매처, gsd-validate-commit.sh)과 충돌 없음
- `rtk init -g` 후 settings.json 배열 순서 수동 확인 필요

## Watch Out For

**C1 — 잘못된 바이너리 설치 (Critical)**
`cargo install rtk`는 crates.io의 "Rust Type Kit"을 설치한다.
반드시 `brew install rtk` 사용 후 `rtk gain`으로 검증.

**C2 — 텔레메트리 실수 동의 (Critical)**
`rtk init -g` 대화형 프롬프트에서 텔레메트리 활성화 가능.
`RTK_TELEMETRY_DISABLED=1` 환경변수로 init 전 차단, 이후 `rtk telemetry disable`.

**C3 — settings.json 구조 손상 (Moderate)**
패치 후 JSON 유효성 검증 필수: `python3 -c "import json; json.load(open('~/.claude/settings.json'))"`.

**Q1 — jq 의존성 미확인 (Moderate)**
RTK hook 스크립트가 `jq`를 사용할 수 있음. `which jq` 선행 확인 필요.

## Open Questions

1. `jq` 설치 여부 — hook이 silently pass-through할 수 있음
2. GSD 워크플로에서 Bash vs Read/Grep/Glob 비율 — 실제 절감율 1주일 측정 필요
3. 사내 감사 정책에서 `~/.local/share/rtk/tracking.db` 허용 여부
