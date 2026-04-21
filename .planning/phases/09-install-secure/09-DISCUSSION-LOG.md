# Phase 9: Install & Secure - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-04-21
**Phase:** 09-install-secure
**Areas discussed:** Init 실행 방식, PATH 검증, 프로젝트 문서화

---

## Init 실행 방식

| Option | Description | Selected |
|--------|-------------|----------|
| RTK_TELEMETRY_DISABLED=1 설정 후 rtk init -g | 환경변수로 텔레메트리 프롬프트를 차단한 상태에서 init 실행 | ✓ |
| 대화형 rtk init -g + n 선택 + rtk telemetry disable | 프롬프트에서 수동 n 선택 후 telemetry disable 추가 | |
| RTK_TELEMETRY_DISABLED=1 + rtk init -g + rtk telemetry disable | 환경변수와 명령 둘 다 적용 — 가장 철저한 보안 | |

**User's choice:** RTK_TELEMETRY_DISABLED=1 환경변수 설정 후 rtk init -g (권장)

---

## RTK_TELEMETRY_DISABLED env var 범위

| Option | Description | Selected |
|--------|-------------|----------|
| ~/.bashrc에만 영구 등록 | WSL2 환경에서 가장 일반적인 방식 | ✓ |
| ~/.bashrc + /etc/environment | 시스템 전체 환경변수 등록 — 관리자 권한 필요, 과도 | |

**User's choice:** ~/.bashrc에만 영구 등록으로 충분

---

## PATH 검증

| Option | Description | Selected |
|--------|-------------|----------|
| brew install rtk는 PATH 문제 없음 (권장) | Linuxbrew 바이너리는 보통 PATH에 이미 있음, ~/.local/bin 문제는 curl 설치 시만 | ✓ |
| rtk gain으로 설치 후 즉시 PATH 확인 | rtk gain 실행으로 PATH 문제 여부 실제 확인 후 조치 | |
| which rtk + PATH 확인을 항상 첫 단계로 추가 | PATH 미등록으로 조용 실패할 가능성 폭발적 차단 | |

**User's choice:** brew install rtk는 /home/linuxbrew/.linuxbrew/bin에 설치 — PATH 문제 없음

---

## 프로젝트 문서화

| Option | Description | Selected |
|--------|-------------|----------|
| 파일 문서화 필요 없음 | RTK는 프로젝트 코드가 아니라 개인 도구 | ✓ |
| README.md에 스리른 개발 툴 섹션 추가 | knowledge-compiler README에 RTK 설치 안내 추가 | |
| .rtk 또는 .env.local 파일에 텔레메트리 설정 기록 | 프로젝트 수준 RTK 설정 파일로 말국화 | |

**User's choice:** 파일 문서화 필요 없음 — 설치만 하면 충분

---

## Deferred Ideas

없음
