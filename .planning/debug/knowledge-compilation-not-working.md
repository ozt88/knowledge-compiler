---
status: awaiting_human_verify
trigger: "knowledge-compilation-not-working — .knowledge/knowledge 컴파일이 되지 않음 — 아무것도 쌓이지 않음"
created: 2026-04-09T00:00:00Z
updated: 2026-04-09T00:05:00Z
---

## Current Focus
<!-- OVERWRITE on each update - reflects NOW -->

hypothesis: [CONFIRMED AND FIXED]
test: 에이전트 파일 교체 + install.sh --force 추가 완료
expecting: 다음 gsd-phase-researcher 또는 gsd-verifier 실행 시 .knowledge/knowledge/ 파일 생성됨
next_action: 사용자에게 실제 컴파일 동작 확인 요청

## Symptoms
<!-- Written during gathering, then IMMUTABLE -->

expected: .knowledge/knowledge 컴파일이 정상 동작해야 함
actual: 아무것도 쌓이지 않음 (컴파일 결과물 없음)
errors: 특별한 에러 메시지 없음
reproduction: 매번 발생
started: 처음부터 작동하지 않을 가능성

## Eliminated
<!-- APPEND only - prevents re-investigating -->

- hypothesis: 패치가 에이전트에 삽입되지 않았음
  evidence: grep으로 PATCH:knowledge-compiler 마커 확인 — researcher(라인 426), verifier(라인 581)에 존재
  timestamp: 2026-04-09T00:02:00Z

- hypothesis: install.sh 또는 patch_agent 함수 오류
  evidence: 에이전트 파일에 Step 0, Step 10b가 올바른 위치(execution_flow 내, anchor 바로 앞)에 삽입되어 있음
  timestamp: 2026-04-09T00:02:00Z

- hypothesis: matchmob 등 다른 프로젝트에서 raw 파일 자체가 없음
  evidence: matchmob Phase 1-3은 2026-04-01~02에 연구됨, raw 파일은 2026-04-06에 최초 생성 — 연구 시점에 raw 없어서 skip 조건 발동이 정당했음
  timestamp: 2026-04-09T00:04:00Z

## Evidence
<!-- APPEND only - facts discovered -->

- timestamp: 2026-04-09T00:01:00Z
  checked: ~/.claude/agents/gsd-phase-researcher.md 라인 434-442
  found: Step 0의 컴파일 지시가 Phase 1 구버전 — guardrails.md 없음, "이것은 하지 마라" 형식의 anti-patterns.md 생성 지시
  implication: Phase 2에서 patches/ 파일을 업데이트했지만 에이전트 파일에는 반영 안 됨

- timestamp: 2026-04-09T00:01:30Z
  checked: install.sh patch_agent() 함수 라인 40-43
  found: PATCH_MARKER(PATCH:knowledge-compiler)가 에이전트 파일에 존재하면 무조건 skip
  implication: Phase 2 이후 install.sh를 재실행해도 에이전트 업데이트 불가

- timestamp: 2026-04-09T00:02:00Z
  checked: knowledge-compiler/.knowledge/ 디렉토리 구조
  found: raw/ 디렉토리만 존재, knowledge/ 디렉토리 없음
  implication: knowledge-compiler 프로젝트에서도 컴파일이 한 번도 실행된 적 없음

- timestamp: 2026-04-09T00:03:00Z
  checked: matchmob phase 연구 날짜 vs raw 파일 생성 날짜
  found: Phase 1-3 researcher = 2026-04-01~02, raw 파일 최초 = 2026-04-06 → 연구 시점에 raw 없었음
  implication: matchmob에서는 researcher가 실행될 때마다 정당하게 Step 0을 skip함

- timestamp: 2026-04-09T00:04:00Z
  checked: knowledge-compiler Phase 1 RESEARCH.md 날짜 vs raw 파일 생성 날짜
  found: RESEARCH.md = 2026-04-07, raw/2026-04-07.md birth = 15:53
  implication: Phase 1 researcher 실행 시점에 raw 파일이 이미 존재했을 수 있음 — Step 0이 발동되었지만 knowledge/ 미생성

- timestamp: 2026-04-09T00:04:30Z
  checked: 에이전트 파일 Step 0 패치 내용(구버전) vs patches/gsd-phase-researcher.patch.md(최신)
  found: 에이전트에는 구버전(4개 파일 기본 생성), patches/에는 Phase 2 최신(guardrails.md, 분류기준, 마이그레이션)
  implication: 두 가지 문제 병존: (1) 구버전 패치가 에이전트에 적용됨 (2) install.sh의 마커-기반 skip으로 업데이트 불가

## Resolution
<!-- OVERWRITE as understanding evolves -->

root_cause: |
  복합 원인 두 가지:
  1. install.sh의 patch_agent()가 PATCH_MARKER 존재 시 무조건 skip — Phase 2에서 patches/ 파일을 업데이트해도 에이전트 파일에 반영 불가
  2. 기존 프로젝트(matchmob 등)에서는 researcher 실행 시점에 raw 파일이 아직 없어 Step 0 skip 조건 정당하게 발동됨
  
  결과: 어느 프로젝트에도 knowledge/ 파일이 생성된 적 없음

fix: |
  에이전트 파일의 구버전 패치를 최신 patches/ 내용으로 교체:
  1. gsd-phase-researcher.md의 Step 0 블록을 patches/gsd-phase-researcher.patch.md 최신 내용으로 교체
  2. gsd-verifier.md의 Step 10b 블록을 patches/gsd-verifier.patch.md 최신 내용으로 교체
  3. install.sh에 --force 옵션 추가: 기존 패치를 제거하고 재삽입

verification: 사용자 확인 대기
files_changed: ["~/.claude/agents/gsd-phase-researcher.md", "~/.claude/agents/gsd-verifier.md", "/home/ozt88/knowledge-compiler/install.sh"]
