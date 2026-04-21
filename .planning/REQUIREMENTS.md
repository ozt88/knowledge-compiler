# Requirements: Knowledge Compiler v1.2

**Defined:** 2026-04-21
**Milestone:** v1.2 Token Optimization
**Core Value:** GSD 서브에이전트가 과거 세션의 시도와 결정에 접근하여 같은 실수를
반복하지 않는 것.

## Milestone Goal

클라이언트 단에서 CLI 출력을 압축해 LLM 토큰 소비를 절감하는 도구를
선정·설치·설정한다. 사내 보안 규정 준수를 위해 텔레메트리를 완전 비활성화한다.

## v1.2 Requirements

### 설치 (INSTALL)

- [ ] **INSTALL-01**: RTK v0.37.2+를 `brew install rtk`로 설치하고 `rtk gain`
  으로 올바른 바이너리(토큰 절감 통계 출력)임을 확인한다
- [ ] **INSTALL-02**: `rtk init -g`로 Claude Code `~/.claude/settings.json`에
  `PreToolUse` Bash hook을 등록한다

### 보안 (SEC)

- [ ] **SEC-01**: `RTK_TELEMETRY_DISABLED=1` 환경변수를 `~/.bashrc`에 영구
  등록하여 업그레이드 후에도 텔레메트리가 차단된다
- [ ] **SEC-02**: `rtk telemetry disable` 실행 후 `rtk telemetry status`가
  "disabled"를 반환함을 확인한다

### 검증 (VERIFY)

- [ ] **VERIFY-01**: `~/.claude/settings.json`의 hook 배열을 확인하여 RTK hook이
  존재하고 기존 GSD hook과 충돌 없이 동작함을 검증한다
- [ ] **VERIFY-02**: `git status` 실행 시 RTK 압축 출력이 나오는지 확인하고,
  `git commit` 실행 시 `gsd-validate-commit.sh`가 정상 동작함을 테스트한다

## Future Requirements

- ccusage 병행 설치 — 토큰 사용량 측정 (이후 마일스톤)
- `rtk gain --graph` 모니터링 자동화 (이후 마일스톤)

## Out of Scope

- LLMLingua — torch + transformers 필요, 기업 환경 설치 부담 과도
- 서버 사이드 프록시 / Anthropic prompt caching — 클라이언트 단 도구 아님
- RTK 커스텀 필터 개발 — 표준 필터만으로 충분
- ccusage 설치 — 이번 마일스톤 범위 아님

## Traceability

| REQ-ID | Phase |
|--------|-------|
| INSTALL-01 | — |
| INSTALL-02 | — |
| SEC-01 | — |
| SEC-02 | — |
| VERIFY-01 | — |
| VERIFY-02 | — |
