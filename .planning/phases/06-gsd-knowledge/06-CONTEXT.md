# Phase 6: GSD Knowledge Reference Audit - Context

**Gathered:** 2026-04-12
**Status:** Ready for planning

<domain>
## Phase Boundary

GSD 각 단계(discuss/plan/research/execute/verify/clear)가 knowledge를 실제로 올바르게 참조하는지 검증하고, 누락된 참조를 즉시 보완한다.

**검증 대상:**
- 패치 파일 4개: `patches/gsd-phase-researcher.patch.md`, `patches/gsd-planner.patch.md`, `patches/gsd-discuss-phase.patch.md`, `patches/gsd-verifier.patch.md`
- 스킬 1개: `skills/gsd-knowledge-compile/skill.md`
- 설치 파일: `~/.claude/agents/gsd-phase-researcher.md`, `~/.claude/agents/gsd-planner.md`, `~/.claude/agents/gsd-verifier.md`, `~/.claude/get-shit-done/workflows/discuss-phase.md`

**이 Phase에서 함께 처리하는 사항:**
- 미커밋 변경사항(gsd-clear 삭제 + gsd-knowledge-compile Step 0 제거) 결정·커밋
- 누락/불일치 발견 시 즉시 패치 파일 수정 + install.sh 업데이트 + 커밋
- **JSONL 세션 로그 분석으로 knowledge 실제 참조율 측정**

**범위 밖:**
- 새로운 knowledge 기능 추가
- install.sh 구조 리팩토링

</domain>

<decisions>
## Implementation Decisions

### 검증 방법

- **D-16: 설치 파일 직접 확인** — 패치 파일 내용 검토에 그치지 않고, 실제 설치된 `~/.claude/agents/*.md`와 `~/get-shit-done/workflows/discuss-phase.md`에 `PATCH:knowledge-compiler` 마커가 존재하는지 grep으로 확인.
  - 패치 파일이 존재해도 설치 안 됐으면 의미 없음

### 검증 기준 (단계별 정의)

- **D-17: 올바른 참조 기준** — 각 단계의 "올바른 참조"는 Phase 5에서 확정된 D-번호 결정으로 판단:
  - `researcher` → `PATCH:knowledge-compiler` 마커 존재 + Step 3에 knowledge lookup 지시 포함 (D-01, D-10)
  - `planner` → `PATCH:knowledge-compiler` 마커 존재 + fallback compile 절차 포함 + knowledge lookup 지시 포함 (D-03, D-09)
  - `discuss` → `PATCH:knowledge-compiler` 마커 존재 + knowledge lookup 지시 포함 (D-08)
  - `verifier` → `PATCH:knowledge-compiler` 마커 존재 + Step 10b compile 절차 포함
  - `gsd-knowledge-compile` 스킬 → on-demand compile 전체 절차 포함 (Step 0 subagent capture 제거 후 상태가 정상인지 확인)

### 미커밋 변경사항 처리

- **D-18: gsd-clear 스킬 삭제 확정** — `skills/gsd-clear/skill.md` 삭제를 Phase 6 첫 작업으로 커밋. 근거:
  - gsd-clear는 GSD 내장 스킬로 이미 존재 (별도 커스텀 스킬 불필요)
  - install.sh도 이미 gsd-clear를 설치하지 않음
  - subagent raw capture(Step 0)는 CLAUDE.md 명시적 수집 방식으로 대체됨

- **D-19: gsd-knowledge-compile Step 0 제거 확정** — subagent 기반 JSONL 파싱(Step 0) 제거를 커밋. 근거:
  - CLAUDE.md에서 응답 시마다 raw/ 직접 기록으로 전환됨
  - subagent JSONL 파싱은 복잡도 대비 가치 낮고 UTC/KST 타임존 버그 발생
  - Step 0 제거 후 Step 1부터 시작하는 현재 상태가 최종 의도

- **D-20: install.sh gsd-clear 설치 항목 없음 — 확인 필요** — install.sh가 이미 `install_skill "gsd-knowledge-compile"`만 실행하고 gsd-clear는 설치하지 않음. 이 상태가 의도와 맞는지 감사 중 확인.

### 발견 시 처리 방식

- **D-21: 감사 + 즉시 수정 원스톱** — 누락된 참조나 불일치 발견 즉시:
  1. 해당 패치 파일 수정
  2. install.sh에 누락된 배포 항목 추가 (필요 시)
  3. 변경사항 커밋
  4. 설치 파일에 반영 여부 재확인

### 측정 방법론

- **D-22: JSONL 세션 로그 기반 실제 참조율 측정** — Phase 6에서 각 GSD 단계별로 knowledge 파일을 실제로 Read 도구로 호출했는지 JSONL 로그를 파싱해 집계한다.
  - 측정 스크립트: `analyze_knowledge_reads.js` (이미 생성됨)
  - 측정 지표: 세션별 `compiled_reads` 횟수 (raw/ 제외, knowledge/knowledge/ 한정)
  - 단계 식별: 세션 첫 user 메시지에서 GSD 스킬 이름 추출

- **D-23: 사전 측정 결과 (discuss 작성 시점 기준)** — JSONL 8개 세션 분석 결과:

  | 세션 | 단계 | 컴파일 knowledge 읽음 | 판정 |
  |------|------|----------------------|------|
  | `5359e240` | gsd-plan-phase (earlier) | ❌ 0건 | **MISS** |
  | `d3e873e1` | gsd-execute-phase | ✅ 5파일 (D-11 위반) | **UNEXPECTED** |
  | `d5f904c3` | gsd-plan-phase + discuss (현재 세션) | ✅ index→relevant 순 | PASS |
  | `ef7bc8b5` | gsd-add-phase | ❌ 0건 | 비대상 |
  | 04-10~04-11 세션들 | 패치 설치 이전 | ❌ 전부 없음 | 기준선 |

  **핵심 발견:**
  - 패치가 설치됐는데도 planner가 knowledge를 읽지 않은 세션 존재 → 설치 상태 재검증 필요
  - executor가 D-11 의도와 다르게 knowledge를 읽음 → 패치 없는데 읽힌 이유 조사 필요
  - discuss-phase (현재 세션)는 index-first 패턴으로 정상 작동 확인

### Claude's Discretion

- 각 설치 파일에서 PATCH 마커 확인 방법: `grep -l "PATCH:knowledge-compiler" ~/.claude/agents/*.md` + workflow 파일
- 불일치 유형 분류: (a) 패치 미설치 (b) 패치 내용 불충분 (c) 패치 내용 설계 의도 불일치
- 측정 스크립트 최종 위치: 작업 완료 후 삭제하거나 `.planning/tools/` 이동 (Claude's discretion)

</decisions>

<specifics>
## Specific Ideas

- 사용자 확인 사항: "설치 파일까지 확인" → 단순 코드 리뷰가 아닌 실제 설치 상태 검증
- 미커밋 변경사항(gsd-clear 삭제, Step 0 제거)은 Phase 6 PLAN.md의 첫 번째 작업으로 처리
- subagent capture 제거 이유: CLAUDE.md 명시적 수집 방식(응답 시 raw/ 직접 기록)으로 대체됨 + UTC/KST 버그

</specifics>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### 설계 결정 원본

- `.planning/phases/05-gsd-workflow-stages/05-CONTEXT.md` — D-01~D-15: 각 단계 knowledge 활동 분배 설계
- `.planning/STATE.md` — 현재 프로젝트 상태, Decisions 섹션

### 현재 구현 파일

- `patches/gsd-phase-researcher.patch.md` — researcher Step 3 lookup 패치
- `patches/gsd-planner.patch.md` — planner fallback compile + lookup 패치
- `patches/gsd-discuss-phase.patch.md` — discuss knowledge lookup 패치
- `patches/gsd-verifier.patch.md` — verifier Step 10b compile 패치
- `skills/gsd-knowledge-compile/skill.md` — on-demand compile 스킬 (Step 0 제거된 현재 상태)
- `install.sh` — 패치 배포 스크립트

### knowledge 시스템 상태

- `.knowledge/knowledge/index.md` — 현재 knowledge 구조 및 설계 결정 요약

</canonical_refs>

<deferred>
## Deferred Ideas

- executor(gsd-executor) 패치 — D-11에 따라 현재 Phase 불필요. 향후 knowledge 활용 패턴이 바뀌면 검토.
- plan-checker 패치 — 동일하게 D-11 범위
- knowledge 참조 자동 검증 스크립트 — 감사를 자동화하는 도구. 현재는 수동 검사로 충분.

</deferred>

---

*Phase: 06-gsd-knowledge*
*Context gathered: 2026-04-12*
