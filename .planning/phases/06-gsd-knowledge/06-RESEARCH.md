# Phase 6: GSD Knowledge Reference Audit - Research

**Researched:** 2026-04-12
**Domain:** GSD agent patch verification + installation state audit
**Confidence:** HIGH

---

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

- **D-16:** 설치 파일 직접 확인 — 패치 파일 내용 검토에 그치지 않고, 실제 설치된 `~/.claude/agents/*.md`와 `~/.claude/get-shit-done/workflows/discuss-phase.md`에 `PATCH:knowledge-compiler` 마커가 존재하는지 grep으로 확인.
- **D-17:** 올바른 참조 기준 — 각 단계의 "올바른 참조"는 Phase 5에서 확정된 D-번호 결정으로 판단:
  - `researcher` → `PATCH:knowledge-compiler` 마커 존재 + Step 3에 knowledge lookup 지시 포함 (D-01, D-10)
  - `planner` → `PATCH:knowledge-compiler` 마커 존재 + fallback compile 절차 포함 + knowledge lookup 지시 포함 (D-03, D-09)
  - `discuss` → `PATCH:knowledge-compiler` 마커 존재 + knowledge lookup 지시 포함 (D-08)
  - `verifier` → `PATCH:knowledge-compiler` 마커 존재 + Step 10b compile 절차 포함
  - `gsd-knowledge-compile` 스킬 → on-demand compile 전체 절차 포함 (Step 0 subagent capture 제거 후 상태가 정상인지 확인)
- **D-18:** gsd-clear 스킬 삭제 확정 — `skills/gsd-clear/skill.md` 삭제를 Phase 6 첫 작업으로 커밋.
- **D-19:** gsd-knowledge-compile Step 0 제거 확정 — subagent 기반 JSONL 파싱(Step 0) 제거를 커밋.
- **D-20:** install.sh gsd-clear 설치 항목 없음 — 확인 필요.
- **D-21:** 감사 + 즉시 수정 원스톱 — 누락 발견 즉시: 패치 파일 수정 → install.sh 업데이트(필요 시) → 커밋 → 재확인.
- **D-22:** JSONL 세션 로그 기반 실제 참조율 측정 (`analyze_knowledge_reads.js` 스크립트 사용).
- **D-23:** 사전 측정 결과 (8개 세션 분석 — 이번 research에서 업데이트됨).

### Claude's Discretion

- 각 설치 파일에서 PATCH 마커 확인 방법: `grep -l "PATCH:knowledge-compiler" ~/.claude/agents/*.md` + workflow 파일
- 불일치 유형 분류: (a) 패치 미설치 (b) 패치 내용 불충분 (c) 패치 내용 설계 의도 불일치
- 측정 스크립트 최종 위치: 작업 완료 후 삭제하거나 `.planning/tools/` 이동 (Claude's discretion)

### Deferred Ideas (OUT OF SCOPE)

- executor(gsd-executor) 패치 — D-11에 따라 현재 Phase 불필요.
- plan-checker 패치 — 동일하게 D-11 범위.
- knowledge 참조 자동 검증 스크립트 — 현재는 수동 검사로 충분.

</user_constraints>

---

## Summary

Phase 6는 코드 작성이 없는 순수 감사·수정 Phase다. 연구 목적은 "현재 설치 상태를 정확히 파악하고 무엇을 고쳐야 하는지 미리 알아내는 것"이다.

직접 설치 파일을 grep한 결과, 두 가지 심각한 문제가 확인됐다. 첫째, gsd-phase-researcher.md / gsd-planner.md / gsd-verifier.md 세 파일 모두 PATCH 블록이 중복 삽입되어 있다 (각각 6회, 6회, 8회). install.sh를 `--force` 없이 반복 실행했거나, GSD 업데이트 후 재적용 시 `unpatch_agent`가 정확히 동작하지 않아 발생한 현상으로 추정된다. 둘째, discuss-phase.md 워크플로 파일에는 PATCH 마커가 전혀 없다 — 앵커 `<step name="load_prior_context">`가 실제 파일에 존재하지 않기 때문에 install.sh의 `patch_workflow` 호출이 무음 실패했다.

D-18·D-19에 따른 미커밋 변경사항(gsd-clear 삭제 + Step 0 제거)은 이미 commit `310d15b`에서 처리됐음을 확인했다. 남은 미커밋 항목은 `analyze2.js`(신규 미추적 파일) 뿐이다.

**Primary recommendation:** (1) 세 에이전트 파일에서 중복 PATCH 블록 제거 후 단일 재삽입 — install.sh `--force` 재실행. (2) discuss-phase.md용 올바른 앵커를 확인하여 패치 적용. (3) D-22 측정 재실행으로 수정 전후 참조율 비교.

---

## Current Installation State (Verified)

> 아래 모든 항목은 이번 research에서 도구로 직접 확인했다. [VERIFIED: bash grep]

### PATCH marker count per installed file

| 설치 파일 | 경로 | PATCH 마커 수 | 기대값 | 판정 |
|-----------|------|--------------|--------|------|
| gsd-phase-researcher.md | `~/.claude/agents/gsd-phase-researcher.md` | **6** | 1 | FAIL — 중복 |
| gsd-planner.md | `~/.claude/agents/gsd-planner.md` | **6** | 1 | FAIL — 중복 |
| gsd-verifier.md | `~/.claude/agents/gsd-verifier.md` | **8** | 1 | FAIL — 중복 |
| discuss-phase.md | `~/.claude/get-shit-done/workflows/discuss-phase.md` | **0** | 1 | FAIL — 미설치 |
| gsd-knowledge-compile skill | `~/.claude/skills/gsd-knowledge-compile/skill.md` | N/A | installed | PASS |

[VERIFIED: `grep -c "PATCH:knowledge-compiler" <file>` 실행 결과]

### Content compliance (patch content criteria, D-17)

| 대상 | PATCH 마커 | 필수 내용 존재 | 판정 |
|------|-----------|--------------|------|
| researcher: Step 3 lookup 지시 | ✓ (6회 중복) | ✓ "During research (Step 3):" 포함 | CONTENT OK, COUNT FAIL |
| planner: fallback compile 절차 | ✓ (6회 중복) | ✓ "Fallback compile 절차:" 포함 | CONTENT OK, COUNT FAIL |
| planner: knowledge lookup 지시 | ✓ (6회 중복) | ✓ "Project knowledge:" 포함 | CONTENT OK, COUNT FAIL |
| discuss: knowledge lookup 지시 | ✗ (0) | ✗ 패치 미적용 | FAIL |
| verifier: Step 10b compile 절차 | ✓ (8회 중복) | ✓ "Step 10b: Knowledge Reconcile" 포함 | CONTENT OK, COUNT FAIL |
| gsd-knowledge-compile: Step 0 제거 | N/A | ✓ Step 1부터 시작 (Step 0 없음) | PASS (D-19 완료) |

[VERIFIED: grep + Read 도구 직접 확인]

### Uncommitted changes state (D-18, D-19)

| 항목 | 기대 상태 | 실제 상태 | 판정 |
|------|----------|----------|------|
| `skills/gsd-clear/` 삭제 커밋 | commit `310d15b`에 포함 | ✓ 프로젝트 skills/ 에 gsd-clear 없음 | DONE |
| Step 0 제거 커밋 | commit `310d15b`에 포함 | ✓ skill.md Step 1부터 시작 | DONE |
| install.sh gsd-clear 설치 없음 (D-20) | install_skill 호출에 gsd-clear 없음 | ✓ `install_skill "gsd-knowledge-compile"`만 존재 | CONFIRMED OK |
| `analyze2.js` | 미추적 신규 파일 | `git status`에 `?? analyze2.js` | 처리 필요 |

[VERIFIED: `git status`, `ls skills/`, install.sh 직접 읽기]

---

## Root Cause Analysis

### 중복 PATCH 삽입 원인

`install.sh`의 `patch_agent` 함수는 `grep -q "$PATCH_MARKER"` 로 이미 패치됐는지 확인한다. `--force` 없이 재실행하면 "already patched — skipping"이 되어야 정상이다.

그러나 실제로 6~8회 중복이 발생했다는 것은 세 가지 중 하나를 의미한다:
1. GSD 에이전트 파일이 업데이트될 때마다 새 파일로 교체되어 마커가 사라지고, 이후 `--force` 재실행으로 재삽입이 반복됐을 가능성 [ASSUMED]
2. `unpatch_agent` 함수가 패치 블록을 정확히 제거하지 못한 채 `--force` 재삽입이 반복됐을 가능성 [ASSUMED]
3. 두 경우의 조합 [ASSUMED]

수정 방법: `--force` 플래그로 install.sh를 재실행하면 `unpatch_agent` → 재삽입 사이클이 동작하여 단일 패치 상태로 복구된다 — 단, `unpatch_agent`가 현재 중복 패치 구조에서 정확히 동작한다면. 안전한 방법은 `sed`/`awk`로 파일 내 모든 `PATCH:knowledge-compiler` 블록을 먼저 수동 제거 후 `--force` 재실행하는 것이다. [ASSUMED: unpatch behavior under multiple duplicates not verified]

### discuss-phase 패치 미적용 원인

[VERIFIED: bash grep] `discuss-phase.md`의 실제 `<step>` 태그 목록:
- initialize, check_blocking_antipatterns, check_existing, cross_reference_todos, scout_codebase, analyze_phase, present_gray_areas, advisor_research, discuss_areas, write_context, confirm_creation, git_commit, update_state, auto_advance

`<step name="load_prior_context">` 는 **존재하지 않는다**. 파일 내 "load_prior_context" 문자열은 line 263에 `**If 'has_plans' is false:** Continue to load_prior_context.` 형태로 텍스트 참조로만 등장한다.

install.sh의 `patch_workflow` 함수는 awk로 `$0 ~ anchor`를 찾는다. 앵커 `<step name="load_prior_context">`가 파일에 없으므로 awk 루프가 한 번도 매칭되지 않고 전체 파일이 그대로 출력된다. 실질적으로 패치가 삽입되지 않았다. install.sh는 성공으로 보고하므로 사용자가 알아채기 어렵다.

**수정 방향:** 올바른 앵커를 선정해야 한다. Knowledge lookup은 Phase analyze 이전에 수행되어야 하므로 `<step name="check_existing">` 또는 `<step name="analyze_phase">` 앵커가 적합하다. `check_existing`이 Phase 시작 시 가장 먼저 실질 작업을 하는 step이므로, knowledge lookup을 그 앞에 두는 것이 D-08 의도(discuss 시작 전 이전 결정사항 확인)에 부합한다.

---

## D-22: JSONL Measurement Update (현재 세션 포함)

research 실행 중 `node analyze_knowledge_reads.js`를 직접 실행했다. [VERIFIED: bash 실행 결과]

| 세션 ID | 날짜 | turns | raw_reads | compiled_reads | GSD 단계 | 판정 |
|---------|------|-------|-----------|---------------|---------|------|
| 39ed1524 | 2026-04-10 | 104 | 1 | {} | 불명 | NO READ |
| b0b12bbc | 2026-04-11 | 116 | 3 | {} | 불명 | NO READ |
| 5359e240 | 2026-04-12 | 106 | 1 | {} | gsd-plan-phase 5 | **MISS** |
| e8bfc017 | 2026-04-10 | 78 | 3 | {} | 불명 | NO READ |
| d3e873e1 | 2026-04-12 | 392 | 2 | {decisions:1,guardrails:1,troubleshooting:2,anti-patterns:1,index:2} | gsd-execute-phase | UNEXPECTED (D-11) |
| 7ced6fc0 | 2026-04-12 | 114 | 1 | {decisions:1,guardrails:1,index:1} | 불명 | READ |
| ef7bc8b5 | 2026-04-12 | 22 | 0 | {} | IDE 파일 열기 | N/A |
| d5f904c3 | 2026-04-12 | 168 | 2 | {index:2,anti-patterns:1,decisions:2,guardrails:1} | gsd-plan-phase + discuss | PASS |
| 8bff0226 | 2026-04-12 | 23 | 0 | {} | gsd-plan-phase 6 (이번) | MISS (초기화만) |

**분석:**
- `5359e240` (gsd-plan-phase 5): 패치가 설치된 상태인데 planner가 knowledge를 읽지 않음. 중복 패치로 인한 파싱 혼란 가능성 또는 세션 시작 시점 기준선 문제 [ASSUMED].
- `d3e873e1` (gsd-execute-phase): executor는 D-11에 따라 knowledge 참조 불필요한데 읽음. 패치 없는 executor가 왜 읽었는지 별도 조사 필요 [ASSUMED: may have manually queried].
- `d5f904c3` (discuss + plan): index-first 패턴 정상 확인.
- `8bff0226` (이번 gsd-plan-phase 6): turns=23, 초기화 단계만 진행한 세션 — 이 research agent 실행을 포함한 세션.

---

## Architecture Patterns

### 감사-수정-검증 사이클 (D-21)

```
1. grep으로 설치 파일 PATCH 마커 카운트 확인
2. 불일치 유형 분류: (a) 미설치 (b) 중복 (c) 내용 불충분
3. 유형에 따른 수정:
   - 중복: unpatch 후 재적용 (install.sh --force, 또는 수동 정리)
   - 미설치: 앵커 수정 후 재적용
   - 내용 불충분: 패치 파일 수정 후 --force 재적용
4. 수정 후 grep 재확인
5. 커밋
```

### 패치 적용 구조 (install.sh)

```bash
# Agent 파일 패치 (앵커 텍스트 기반 awk 삽입)
patch_agent "$AGENTS_DIR/gsd-phase-researcher.md" \
  "$SCRIPT_DIR/patches/gsd-phase-researcher.patch.md" \
  "## Step 1: Receive Scope and Load Context"

# Workflow 파일 패치 (앵커 기반 awk 삽입)
patch_workflow "$WORKFLOWS_DIR/discuss-phase.md" \
  "$SCRIPT_DIR/patches/gsd-discuss-phase.patch.md" \
  "<step name=\"check_existing\">"   # ← 수정 필요한 앵커
```

**Critical:** `patch_workflow` 함수는 앵커 미매칭 시 무음 실패한다. 성공/실패 여부를 명시적으로 검증해야 한다.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| 중복 패치 정리 | 커스텀 cleanup 스크립트 | `install.sh --force` (기존 unpatch + 재삽입) | 이미 구현된 메커니즘 활용 |
| 패치 내용 검증 | 복잡한 파서 | `grep -c PATCH:knowledge-compiler` + `grep -q "키워드"` | 충분한 검증 수준 |
| discuss-phase 앵커 발견 | 새 파일 파싱 도구 | `grep -n "step name"` 직접 실행 | 단순 grep으로 충분 |

---

## Common Pitfalls

### Pitfall 1: install.sh --force 실행 시 unpatch_agent 불완전 동작
**What goes wrong:** 현재 6~8개 중복 블록이 있는 상태에서 `--force`를 실행하면, `unpatch_agent`가 처음 발견한 블록만 제거하고 나머지는 남길 수 있다.
**Why it happens:** `unpatch_agent`의 awk 로직이 단일 블록 제거를 가정하고 작성되어 있을 수 있음 [ASSUMED].
**How to avoid:** `--force` 실행 전 `grep -c PATCH:knowledge-compiler <file>`로 카운트 확인. 1이 되지 않으면 수동 정리 후 재실행.
**Warning signs:** `--force` 후에도 count가 2 이상으로 남음.

### Pitfall 2: discuss-phase 앵커 수정 후 patch_workflow 무음 실패
**What goes wrong:** 올바른 앵커로 수정했어도 awk 매칭이 실패하면 파일이 변경없이 출력되고 install.sh는 성공으로 보고한다.
**Why it happens:** `patch_workflow` 함수에 앵커 미매칭 감지 로직이 없다.
**How to avoid:** 패치 후 `grep -c PATCH:knowledge-compiler <workflow_file>`로 즉시 확인.
**Warning signs:** install.sh가 "patched" 출력했는데 grep count가 0.

### Pitfall 3: 중복 패치가 에이전트 동작에 미치는 영향 과소평가
**What goes wrong:** "중복이어도 내용은 있으니 동작하겠지"라고 가정.
**Why it happens:** 중복된 lookup 지시가 컨텍스트 토큰을 낭비하고, LLM이 중복 지시를 어떻게 처리하는지 예측 불가.
**How to avoid:** 중복 자체를 버그로 취급, 반드시 단일화.

### Pitfall 4: gsd-clear 삭제가 미완료라고 착각
**What goes wrong:** D-18을 "Phase 6 첫 작업"이라 기록했으나 이미 commit `310d15b`에서 완료됨.
**Why it happens:** CONTEXT.md 작성 시점(discuss)과 실제 구현 시점 사이에 작업이 진행됨.
**How to avoid:** 각 D-번호를 실행 전 git log와 교차 확인.

---

## Implementation Task Map

아래는 연구 결과를 기반으로 planner가 도출해야 할 작업 목록이다.

| # | 작업 | 유형 | 근거 |
|---|------|------|------|
| 1 | D-18/D-19 상태 확인 커밋 | git | commit 310d15b 확인 + analyze2.js 처리 |
| 2 | D-20 install.sh gsd-clear 부재 확인 기록 | 검증 | install.sh에 gsd-clear 없음 확인됨 |
| 3 | gsd-phase-researcher.md 중복 패치(×6→×1) 수정 | install.sh --force 또는 수동 | FAIL: count=6 |
| 4 | gsd-planner.md 중복 패치(×6→×1) 수정 | install.sh --force 또는 수동 | FAIL: count=6 |
| 5 | gsd-verifier.md 중복 패치(×8→×1) 수정 | install.sh --force 또는 수동 | FAIL: count=8 |
| 6 | discuss-phase.md 패치 앵커 수정 + 패치 적용 | install.sh 앵커 변경 | FAIL: count=0, 앵커 없음 |
| 7 | 수정 후 전체 설치 상태 재검증 (grep) | 검증 | D-16 |
| 8 | D-22 JSONL 측정 재실행 + 결과 기록 | 측정 | D-22 |
| 9 | analyze2.js 처리 결정 (삭제 or .planning/tools/ 이동) | 정리 | Claude's discretion |

---

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| researcher Step 0 compile | researcher는 compile 없이 Step 3 lookup만 | Phase 5 (D-01) | 불필요한 컴파일 제거 |
| subagent JSONL 파싱 (Step 0) | CLAUDE.md per-turn 직접 기록 | commit 310d15b (D-19) | UTC/KST 버그 해소, 단순화 |
| gsd-clear 커스텀 스킬 | GSD 내장 /gsd-clear 사용 | commit 310d15b (D-18) | 커스텀 스킬 제거 |

---

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | 중복 패치 원인이 GSD 업데이트 후 --force 재실행 반복일 것 | Root Cause Analysis | 원인이 다르면 수정 접근법이 달라질 수 있음 |
| A2 | `unpatch_agent`가 중복 블록 상태에서 일부만 제거할 수 있음 | Root Cause Analysis / Pitfall 1 | 실제로는 한 번에 모두 제거할 수도 있음 (직접 테스트 필요) |
| A3 | d3e873e1 executor 세션이 knowledge를 읽은 이유가 수동 조회일 것 | D-22 Measurement | 패치 없는 executor 경로가 따로 있을 수 있음 |

---

## Open Questions

1. **install.sh unpatch_agent의 중복 블록 처리 능력**
   - What we know: 현재 파일에 6~8개 중복 블록 존재
   - What's unclear: `--force` 실행 시 한 번에 모두 제거되는지, 아니면 한 개만 제거되는지
   - Recommendation: `--force` 실행 전 수동으로 `unpatch_agent` awk 로직을 검토하거나, 작업 전 파일을 백업하고 `--force` 후 카운트 재확인

2. **discuss-phase 패치 삽입 최적 앵커**
   - What we know: `<step name="load_prior_context">` 앵커가 존재하지 않음. 실제 step들: initialize, check_blocking_antipatterns, check_existing, ...
   - What's unclear: `check_existing` 앞에 넣을지 (`<step name="check_existing">`), 아니면 `analyze_phase` 앞에 넣을지
   - Recommendation: `<step name="check_existing">` 앞이 가장 자연스럽다 — check_existing은 Phase 시작 시 첫 실질 단계이므로 knowledge 조회를 그 전에 수행하는 것이 D-08 의도(discuss 시작 전 이전 결정 확인)에 부합

3. **analyze2.js 처리**
   - What we know: 미추적 파일(git status `??`), D-22용 분석 스크립트로 추정
   - What's unclear: `analyze_knowledge_reads.js`와 중복인지, 별도 용도인지
   - Recommendation: 파일 내용 확인 후 중복이면 삭제, 유용하면 `.planning/tools/` 이동

---

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| bash | install.sh 실행 | ✓ | Git Bash on Win | — |
| node | analyze_knowledge_reads.js | ✓ | (기존 실행 확인됨) | — |
| `~/.claude/agents/` | 패치 대상 | ✓ | 3개 파일 확인됨 | — |
| `~/.claude/get-shit-done/workflows/discuss-phase.md` | discuss 패치 | ✓ | 파일 존재 확인됨 | — |

[VERIFIED: bash ls/grep 직접 확인]

---

## Validation Architecture

> config.json에 `workflow.nyquist_validation` 키 없음 → enabled로 처리.

이 Phase는 코드 작성이 없는 감사·수정 Phase다. 자동화된 테스트 대신, 각 작업의 검증은 `grep -c "PATCH:knowledge-compiler" <file>` 카운트가 정확히 1임을 확인하는 방식으로 수행한다.

### Phase Requirements → Verification Map

| 요구사항 | 검증 방법 | 자동화 명령 |
|---------|----------|-----------|
| researcher 패치 단일화 | grep count=1 | `grep -c "PATCH:knowledge-compiler" ~/.claude/agents/gsd-phase-researcher.md` |
| planner 패치 단일화 | grep count=1 | `grep -c "PATCH:knowledge-compiler" ~/.claude/agents/gsd-planner.md` |
| verifier 패치 단일화 | grep count=1 | `grep -c "PATCH:knowledge-compiler" ~/.claude/agents/gsd-verifier.md` |
| discuss-phase 패치 적용 | grep count=1 | `grep -c "PATCH:knowledge-compiler" ~/.claude/get-shit-done/workflows/discuss-phase.md` |
| D-17 내용 기준 충족 | 키워드 grep | (각 기준별 grep, 아래 참조) |
| JSONL 측정 완료 | 스크립트 출력 확인 | `node analyze_knowledge_reads.js` |

### D-17 내용 검증 명령

```bash
# researcher: Step 3 lookup 지시
grep -q "During research (Step 3)" ~/.claude/agents/gsd-phase-researcher.md && echo PASS || echo FAIL

# planner: fallback compile + lookup
grep -q "Fallback compile" ~/.claude/agents/gsd-planner.md && echo PASS || echo FAIL
grep -q "Project knowledge" ~/.claude/agents/gsd-planner.md && echo PASS || echo FAIL

# discuss: knowledge lookup
grep -q "Project knowledge" ~/.claude/get-shit-done/workflows/discuss-phase.md && echo PASS || echo FAIL

# verifier: Step 10b
grep -q "Step 10b: Knowledge Reconcile" ~/.claude/agents/gsd-verifier.md && echo PASS || echo FAIL

# gsd-knowledge-compile: Step 0 없음 확인
grep -q "Step 0" ~/.claude/skills/gsd-knowledge-compile/skill.md && echo FAIL || echo PASS
```

---

## Sources

### Primary (HIGH confidence)
- [VERIFIED: bash grep] `grep -c "PATCH:knowledge-compiler"` — 설치 파일 직접 카운트
- [VERIFIED: bash grep] `grep -n "step name"` on discuss-phase.md — 실제 step 목록 확인
- [VERIFIED: bash node] `node analyze_knowledge_reads.js` — JSONL 측정 실행
- [VERIFIED: Read tool] `install.sh` 직접 읽기 — patch_workflow 앵커 확인
- [VERIFIED: Read tool] 4개 패치 파일 직접 읽기 — 내용 검증
- [VERIFIED: bash git] `git log --oneline -10` — D-18/D-19 커밋 확인

### Secondary (MEDIUM confidence)
- [ASSUMED] 중복 패치 발생 원인 추론

---

## Metadata

**Confidence breakdown:**
- Installation state: HIGH — 직접 grep/bash 확인
- Root cause: MEDIUM — 직접 관찰 + 추론 혼합
- Fix approach: HIGH — install.sh 구조 이해 + 앵커 문제 확인

**Research date:** 2026-04-12
**Valid until:** 2026-04-19 (GSD 업데이트 없으면 안정)
