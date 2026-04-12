# Phase 5: GSD Workflow Stages - Research

**Researched:** 2026-04-12
**Domain:** Knowledge pipeline specification — compile trigger redesign, per-stage knowledge activity allocation
**Confidence:** HIGH (all findings drawn from codebase inspection and locked CONTEXT.md decisions)

---

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

- **D-01:** researcher Step 0 compile 완전 제거 — researcher는 compile 없이 리서치만 수행한다. 이전 세션의 knowledge/는 읽을 수 있다.
- **D-02:** `/gsd-clear` 신규 커맨드를 primary 컴파일 트리거로 정의한다 — 작업 종료 시 사용자가 명시적으로 실행, compile 후 /clear.
- **D-03:** planner Step 0 compile을 fallback으로 유지한다 — `/gsd-clear` 없이 세션을 닫은 경우, 다음 Phase 계획 시 planner가 compile을 수행한다.
- **D-04:** 컴파일 시점 철학: Phase 내부는 컨텍스트가 충분하므로 compile 불필요. compile은 Phase 간 정보 단절 방지 목적이다.
- **D-05:** compile 소스 = `raw/` + `.planning/**` 전체. `.planning/phases/`, `.planning/quick/`, `.planning/debug/` 등 GSD가 생성한 모든 아티팩트 포함. PLAN.md, RESEARCH.md, CONTEXT.md, VERIFICATION.md, REVIEW.md 등 파일 유형 제한 없음.
- **D-06:** 증분 컴파일 — `compile-manifest.json`으로 마지막 compile 이후 변경된 파일만 처리한다. 구체적 구현 방식(hash vs mtime 등)은 researcher 재량. manifest 파일 위치: `.planning/compile-manifest.json`.
- **D-07:** 동일 내용이 여러 소스에 중복 등장할 경우 B+C 융합 방식 — 강화(reinforcement) + 최신 소스 우선을 병합한 정책을 researcher가 구체적으로 설계한다.
- **D-08:** discuss → knowledge/ 참조 — 이미 결정된 사항 재질문 방지, 이전 실패 방향 제시 방지.
- **D-09:** planner → knowledge/ 참조 (compile 직후, 가장 최신 상태).
- **D-10:** researcher → knowledge/ 참조 (planner Step 0 compile 이전 실행이므로 한 Phase 뒤처진 knowledge 참조 — 허용).
- **D-11:** executor, verifier → knowledge/ 참조 불필요 (Phase 내 컨텍스트로 충분).
- **D-12:** `.knowledge/`는 git 추적 여부와 무관하게 시스템이 동작한다.
- **D-13:** 이번 Phase 결과물은 워크플로 명세 문서다. 구현(패치 파일 수정, gsd-clear 커맨드)은 명세 기반으로 다음 Phase에서 수행.

### Claude's Discretion

- compile-manifest.json의 구체적 구현 방식 (hash 알고리즘, mtime 비교 등)
- B+C 중복 처리 구체적 정책 (강화 임계값, 최신 우선 충돌 해소 방식)
- 명세 문서의 정확한 형식 및 구조

### Deferred Ideas (OUT OF SCOPE)

- 패치 파일 실제 수정 — 명세 완성 후 다음 Phase에서 구현
- `/gsd-clear` 커맨드 구현 — 명세 완성 후 다음 Phase에서 구현
- 다중 작업자 간 knowledge 동기화 — Out of Scope
- `.knowledge/` gitignore 권장 정책 — 사용자 선택에 맡김
</user_constraints>

---

## Summary

Phase 5의 목표는 GSD 워크플로 각 단계(discuss/plan/research/execute/verify)에서 knowledge 활동(수집·컴파일·조회)이 어떻게 배분되어야 하는지를 **명세 문서**로 정의하는 것이다. 구현은 다음 Phase에서 수행하므로 이번 Phase의 산출물은 사양서다.

현재 시스템에서 researcher Step 0가 compile을 수행한다. 이를 제거하고 `/gsd-clear` 커맨드(신규)를 primary compile trigger로, planner Step 0 compile을 fallback으로 재배치하는 것이 핵심 변경이다. compile 소스가 `raw/`에서 `raw/ + .planning/**` 전체로 확장되며, `compile-manifest.json` 기반 증분 처리가 추가된다.

이번 연구의 초점은 현재 시스템 상태 파악, 각 GSD 단계의 integration point 정의, 명세 문서가 담아야 할 내용 구조화, 그리고 B+C 중복 처리 및 manifest 구현 방식 설계다.

**Primary recommendation:** 명세 문서를 `05-SPEC.md`로 작성하되, GSD 단계별 행동표 + 컴파일러 입력 소스 목록 + manifest 구조 + `/gsd-clear` 커맨드 명세 + 중복 처리 정책의 5개 섹션으로 구성한다.

---

## Current System State (Verified)

[VERIFIED: codebase inspection]

### 현재 compile 위치 및 방식

**researcher Step 0** (`patches/gsd-phase-researcher.patch.md`):
- 삽입 위치: `## Step 1: Receive Scope and Load Context` 앞
- 동작: `raw/` 파일을 `Last compiled` 날짜 기준으로 필터링, knowledge/ 파일로 컴파일
- 증분 방식: `index.md`의 `Last compiled` 날짜 vs raw 파일명 날짜 비교
- D-01에 의해 **제거 대상**

**verifier Step 10b** (`patches/gsd-verifier.patch.md`):
- 삽입 위치: `## Return to Orchestrator` 앞
- 동작: turn count sanity check → raw/ 증분 컴파일 → knowledge lint (Step 10c)
- D-01 범위 밖 — verifier compile은 **유지됨** (Phase-end compile, not Phase-start)
- verifier는 Phase가 끝날 때 실행되므로 compile 역할이 gsd-clear와 다르지 않음

**planner Step 0** (`patches/gsd-planner.patch.md`):
- 현재 역할: knowledge/ 조회만 수행 (compile 없음)
- D-03: fallback compile 추가 위치 — `/gsd-clear` 없이 세션 종료 시 다음 Phase 계획 때 compile 수행

### 현재 GSD 에이전트 파일 목록 (패치 대상)

`$HOME/.claude/agents/` 에 존재하는 관련 파일:
- `gsd-phase-researcher.md` — D-01: Step 0 제거
- `gsd-planner.md` — D-03: Step 0 fallback compile 추가
- `gsd-verifier.md` — 유지 (verifier compile은 Phase-end compile로 gsd-clear와 역할 분리)

`$HOME/.claude/skills/` 에 신규 추가 필요:
- `gsd-clear` — `/gsd-clear` 커맨드 구현 파일 (이번 Phase는 명세만)

`$HOME/.claude/get-shit-done/workflows/discuss-phase.md`:
- `load_prior_context` step에 knowledge/ 참조 지시 추가 위치 (D-08)
- 현재: PROJECT.md, REQUIREMENTS.md, STATE.md, prior CONTEXT.md 파일만 읽음
- 추가 필요: `.knowledge/knowledge/` index-first 조회

### 현재 knowledge/ 구조

```
.knowledge/
├── raw/
│   └── YYYY-MM-DD.md          # 턴별 수집 (CLAUDE.md 지시로 자동 생성)
└── knowledge/
    ├── index.md                # Last compiled + Quick Reference + 키워드 인덱스
    ├── decisions.md            # Attempt → Result → Decision + 상태 태그
    ├── guardrails.md           # 절대적 규칙, 긍정형 액션
    ├── anti-patterns.md        # 맥락 의존적, Observation-Reason-Instead
    └── troubleshooting.md      # 에러 ↔ 해결 매핑
```

### 현재 증분 컴파일 메커니즘

현재: `index.md`의 `Last compiled: YYYY-MM-DD` 날짜 vs raw 파일명 날짜(YYYY-MM-DD.md) 비교.
- 날짜가 같거나 이전이면 skip
- 하루에 여러 번 컴파일해도 날짜 단위로만 구분 → **동일 날짜 내 중간 컴파일 불가**

신규 D-06: `compile-manifest.json` 기반 — 파일 단위 증분 추적.
- 위치: `.planning/compile-manifest.json`
- `.planning/**` 전체가 소스로 추가되므로 날짜 기반으로는 추적 불가 → 파일 단위 필요

---

## Architecture Patterns

### GSD 워크플로 단계별 knowledge 활동 매핑 (명세 핵심)

| 단계 | 커맨드 | compile | lookup | collect | 비고 |
|------|--------|---------|--------|---------|------|
| discuss | `/gsd-discuss-phase` | ✗ | ✓ (D-08) | ✗ | load_prior_context step에 추가 |
| plan | `/gsd-plan-phase` | ✓ fallback (D-03) | ✓ (D-09) | ✗ | compile 후 lookup |
| research | `/gsd-research-phase` | ✗ (D-01) | ✓ (D-10) | ✗ | compile 없이 조회만 |
| execute | `/gsd-execute-phase` | ✗ (D-11) | ✗ (D-11) | ✓ (CLAUDE.md) | 수집만 |
| verify | `/gsd-verify-work` | ✓ (Step 10b) | ✗ | ✓ (CLAUDE.md) | Phase-end compile |
| **clear** | `/gsd-clear` | ✓ **primary** (D-02) | ✗ | ✗ | 세션 종료 전 명시적 실행 |

**collect**: CLAUDE.md 행동 지시로 모든 단계에서 자동 수행 — 별도 지시 불필요.

### /gsd-clear 커맨드 명세 (신규)

**목적:** 세션 종료 직전 사용자가 명시적으로 실행. compile 후 `/clear`로 컨텍스트 초기화.

**실행 순서:**
1. `.knowledge/raw/` 존재 확인 (없으면 skip)
2. `compile-manifest.json` 로드 (없으면 full compile 모드)
3. 변경된 소스 파일 목록 추출:
   - `raw/` — manifest의 `last_compiled` 이후 생성/수정된 파일
   - `.planning/**` — manifest의 파일별 hash/mtime 변경된 파일
4. 변경 파일에서 knowledge 추출 → knowledge/ 병합 (D-07 정책 적용)
5. `compile-manifest.json` 업데이트
6. `index.md` 업데이트 (`Last compiled` = 오늘 날짜)
7. `/clear` 실행

**skip 조건:** `.knowledge/raw/`가 없거나 변경된 소스 파일이 없으면 compile 없이 `/clear`만 실행.

### compile-manifest.json 구조 (D-06, Claude's Discretion)

[ASSUMED] 다음 구조를 권장한다. 구체적 hash 알고리즘은 플래너/구현자 재량.

```json
{
  "last_compiled": "2026-04-12T08:45:00Z",
  "sources": {
    "raw/2026-04-11.md": { "mtime": "2026-04-11T22:00:00Z", "included": true },
    "raw/2026-04-12.md": { "mtime": "2026-04-12T09:00:00Z", "included": true },
    ".planning/phases/04-knowledge-importance-prioritization-scoring/04-CONTEXT.md": {
      "mtime": "2026-04-10T10:00:00Z",
      "included": true
    },
    ".planning/phases/05-gsd-workflow-stages/05-RESEARCH.md": {
      "mtime": "2026-04-12T10:00:00Z",
      "included": false
    }
  }
}
```

**mtime vs hash 선택 기준:**
- mtime: 구현 단순, LLM이 bash stat으로 읽기 용이. 동일 내용 재저장 시 false positive 가능.
- hash (MD5/SHA1): 내용 변경 시에만 처리. bash + openssl/md5sum으로 구현 가능. 더 정확하지만 복잡.
- **권장:** mtime 기반으로 시작. 문제 발생 시 hash로 전환 (CONTEXT.md Claude's Discretion).

**`included` 플래그:** `.planning/**` 파일 중 knowledge 추출 가치가 없는 파일(예: STATE.md 업데이트만 있는 커밋) skip 처리 기록용.

### B+C 중복 처리 정책 (D-07, Claude's Discretion)

동일 내용이 `raw/`와 `.planning/**` 모두에 나타날 경우:

**B: Reinforcement (강화)**
- 동일 결론이 2개 이상 소스에 등장 → `**Observed:** N times` 카운터 증가
- 기준: 섹션 제목 키워드 70% 이상 겹침 (기존 verifier Step 10b 충돌 감지 기준 준용)

**C: Latest-source priority (최신 소스 우선)**
- 동일 주제의 내용이 상충할 경우 → 가장 최근 날짜 소스의 내용으로 덮어씀
- 단, 기존 `[conflict]` 태그 메커니즘과 병행: 상충 시 `[conflict: YYYY-MM-DD]` 유지 + 최신 내용을 `> New:` 블록으로 추가

**B+C 융합 규칙:**
1. 두 소스 내용이 동일 결론 → reinforcement 처리 (B)
2. 두 소스 내용이 상충 → 최신 소스를 `> New:` 블록으로 추가 + `[conflict]` 태그 (C)
3. 한 소스만 존재 → 일반 추가

### .planning/** 소스 처리 원칙 (D-05)

`.planning/` 아티팩트는 `raw/`와 성격이 다르다:

| 파일 유형 | 지식 추출 방식 |
|-----------|--------------|
| `*-CONTEXT.md` | `<decisions>` 섹션 — locked decisions 추출 |
| `*-RESEARCH.md` | `## Standard Stack`, `## Architecture Patterns`, `## Common Pitfalls` — 기술 발견 추출 |
| `*-PLAN.md` | `<action>` 블록 패턴 — 실제 실행된 접근법 추출 (선택적) |
| `*-VERIFICATION.md` | 검증 결과 — 실패 항목 troubleshooting으로 추출 |
| `STATE.md`, `ROADMAP.md` | Phase 진행 상태 — decisions.md 완료 이벤트로 추출 |
| `PROJECT.md` | 핵심 가치/제약 — guardrails로 추출 |

**선별 기준:** 기존 raw/ 선별 기준과 동일 원칙 적용:
- 포함: 미래 세션에서 같은 실수 방지 가능한 결정/발견
- 건너뜀: 단순 상태 업데이트, 일회성 확인 작업

### planner Step 0 fallback compile 명세 (D-03)

**위치:** `gsd-planner.md`의 `<project_context>` 블록 내, 기존 knowledge lookup 지시 앞.

**동작:**
1. `.knowledge/raw/` 존재 확인
2. `compile-manifest.json` 확인:
   - manifest 없음 → full compile 수행
   - manifest 있음 → 변경된 파일 있으면 증분 compile
   - 변경 없음 → compile skip, lookup만 수행
3. compile 완료 후 knowledge/ lookup 수행 (D-09)

**핵심 차이:** `/gsd-clear`가 primary이므로, planner Step 0는 manifest 기준으로 "미처리 변경사항이 있을 때만" compile. 이미 `/gsd-clear`로 처리된 경우 skip.

### discuss-phase knowledge lookup 명세 (D-08)

**위치:** `discuss-phase.md`의 `load_prior_context` step 내, Step 1(project-level files 읽기) 앞 또는 후.

**동작:**
```
Step 0.5: knowledge/ lookup (D-08)
- .knowledge/knowledge/ 존재 확인
- index.md 읽기 → Quick Reference 테이블로 관련 파일 식별
- 현재 Phase 주제 관련 파일만 선택적으로 Read
- decisions.md [rejected] → 이미 거부된 방향 제시 금지
- guardrails.md → 재질문 금지 항목 확인
```

**목적:** discuss 단계에서 이미 결정된 사항 재질문 방지, 이전 실패 방향 제시 방지. compile은 수행하지 않음.

### researcher Step 0 제거 후 변경 (D-01)

**제거 대상:** `patches/gsd-phase-researcher.patch.md` 전체 Step 0 블록.

**유지:** Step 3 knowledge lookup 지시 (현재 패치 내 "During research (Step 3)" 섹션).

**영향:**
- researcher가 한 Phase 뒤처진 knowledge를 참조하는 것은 D-10에 의해 허용됨
- researcher는 compile 없이 리서치만 집중 — 컨텍스트/시간 비용 절감 (D-04 철학)

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| 파일 변경 감지 | 커스텀 file watcher | bash `stat` (mtime) 또는 `md5sum` (hash) | 단순 bash로 충분, 외부 의존성 불필요 |
| compile-manifest 파싱 | 커스텀 JSON parser | bash `jq` 또는 LLM direct Read | manifest는 LLM이 직접 Read/Write |
| knowledge 중복 감지 | 임베딩 기반 유사도 | 키워드 70% 겹침 (기존 verifier 방식 재사용) | 일관성, 인프라 불필요 |
| /gsd-clear 구현 | 새 bash 스크립트 | GSD skill 파일 (markdown) | 기존 GSD 패턴과 일관성 |

---

## Common Pitfalls

### Pitfall 1: verifier Step 10b와 /gsd-clear 역할 혼동

**What goes wrong:** D-01 "compile 제거"를 verifier Step 10b까지 제거하는 것으로 오해.
**Why it happens:** D-01은 researcher Step 0만 대상. verifier Step 10b는 Phase 종료 시 compile로 역할이 다름.
**How to avoid:** 명세에서 두 compile의 트리거 시점을 명확히 구분:
- verifier Step 10b = Phase가 완료될 때 (검증 완료 후)
- /gsd-clear = 사용자가 세션 종료 시 명시적 실행
- planner Step 0 = 다음 Phase 계획 시 fallback
**Warning signs:** 명세에서 verifier Step 10b 제거를 언급하면 범위 오류.

### Pitfall 2: .planning/** 소스 처리 시 raw/ 선별 기준 미적용

**What goes wrong:** `.planning/**` 파일 전체를 무차별 knowledge로 추출 → 관련 없는 정보 과다.
**Why it happens:** D-05가 "전체 포함"으로 읽힐 수 있음.
**How to avoid:** D-05는 소스 범위 정의(어떤 파일을 scan할지), 선별은 기존 selection criteria 적용. 파일은 전부 스캔하되 knowledge는 선별.

### Pitfall 3: compile-manifest.json이 .planning/에 있어서 자기 참조 문제

**What goes wrong:** compile 시 `.planning/compile-manifest.json` 자체가 소스 파일로 포함되어 변경 감지 루프 발생.
**Why it happens:** D-05가 `.planning/**` 전체를 소스로 정의.
**How to avoid:** manifest 파일 자체는 소스 목록에서 제외. 명세에 명시적으로 기술.

### Pitfall 4: planner Step 0 compile이 항상 실행되는 fallback

**What goes wrong:** planner가 매번 full compile을 수행 → 컨텍스트/시간 비용 증가.
**Why it happens:** D-03의 "fallback"을 무조건 실행으로 구현.
**How to avoid:** manifest 기반 조건부: 미처리 변경사항이 있을 때만 compile. `/gsd-clear`로 이미 처리된 경우 skip.

### Pitfall 5: discuss-phase에 compile 추가 시도

**What goes wrong:** discuss가 knowledge를 조회하면서 compile도 수행 → D-04 위반.
**Why it happens:** "참조하려면 최신 데이터가 있어야 하지 않나"라는 직관.
**How to avoid:** discuss는 lookup만. compile이 필요하면 이전 단계에서 /gsd-clear 또는 planner Step 0 fallback이 처리한 것을 참조. discuss 단계에서 compile은 비용 대비 효과 낮음(D-04 철학).

---

## Specification Document Structure (명세 문서 구조)

Phase 5 산출물(`05-SPEC.md`)이 담아야 할 내용:

### Section 1: GSD 단계별 knowledge 활동 표

각 단계의 collect/compile/lookup 여부, 담당 파일, 변경 내용을 표 형식으로 정의.

### Section 2: 컴파일러 입력 소스 목록 (D-05)

- `raw/*.md` — 처리 방식
- `.planning/**` 파일 유형별 — 추출 방식
- 제외 목록 — `compile-manifest.json` 자기 참조 방지

### Section 3: compile-manifest.json 구조 (D-06)

- JSON 스키마 정의
- mtime 기반 구현 상세
- gitignore 정책 (D-12)

### Section 4: /gsd-clear 커맨드 명세 (D-02)

- 실행 순서 (단계별 상세)
- skip 조건
- GSD skill 파일 형식 (`$HOME/.claude/skills/gsd-clear`)

### Section 5: B+C 중복 처리 정책 (D-07)

- reinforcement 규칙
- latest-source 우선 규칙
- 기존 conflict/reinforcement 태그 메커니즘과의 연계

### Section 6: 단계별 패치 파일 변경 명세

- researcher: Step 0 제거 diff
- planner: Step 0 fallback compile 추가 위치 및 내용
- discuss-phase: load_prior_context knowledge lookup 추가 위치 및 내용

---

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | compile-manifest.json을 mtime 기반으로 구현하도록 권장 | compile-manifest.json 구조 | hash 기반으로 변경 시 구현 방식만 달라짐, 기능 영향 없음 |
| A2 | verifier Step 10b는 D-01 범위 밖으로 유지 | Architecture Patterns | verifier도 제거 대상이면 Phase-end compile 수단 없어짐 — CONTEXT.md 명시적으로 verifier 언급 없으므로 LOW risk |
| A3 | discuss-phase는 GSD workflow 파일로 패치 (not agent 파일) | discuss-phase knowledge lookup | workflow 파일 패치 방식이 install.sh에 추가 필요 |
| A4 | .planning/** 파일에서 지식 추출 시 파일 유형별 섹션 필터링 | .planning/** 소스 처리 원칙 | 전체 파일 내용을 LLM이 직접 읽고 판단하는 방식도 가능 |

---

## Open Questions

1. **verifier Step 10b 역할 명확화**
   - What we know: D-01은 researcher Step 0 제거. verifier Step 10b는 CONTEXT.md에 언급 없음.
   - What's unclear: verifier Step 10b도 /gsd-clear로 대체되는가, 아니면 독립 유지인가?
   - Recommendation: Phase-end compile과 session-end compile의 역할이 겹치므로 명세에서 명시적으로 정의. 유지 방향이 자연스러움 (verify가 Phase 종료 시점이므로).

2. **discuss-phase 패치 방식**
   - What we know: 현재 install.sh는 agent 파일만 패치 (gsd-phase-researcher.md, gsd-verifier.md, gsd-planner.md). discuss-phase는 workflow 파일.
   - What's unclear: workflow 파일 패치를 install.sh에 추가해야 하는가, 아니면 discuss-phase.md 자체를 직접 수정하는가?
   - Recommendation: install.sh에 workflow 패치 스텝 추가 (기존 new-project.md 패치 패턴 준용). 명세에 포함.

3. **compile-manifest.json gitignore 정책**
   - What we know: D-12는 `.knowledge/` gitignore 여부 무관 동작. manifest는 `.planning/`에 위치.
   - What's unclear: manifest는 git 추적해야 하는가?
   - Recommendation: manifest는 git 추적 권장 (증분 compile의 신뢰성). `.knowledge/` gitignore 시에도 `.planning/compile-manifest.json`은 추적. 명세에 권장사항으로 기술.

---

## Environment Availability

Step 2.6: SKIPPED — 이번 Phase는 명세 문서 작성(코드/config 변경 없음). 외부 의존성 없음.

---

## Validation Architecture

이번 Phase 산출물은 명세 문서(`05-SPEC.md`)이므로 자동화 테스트 대상이 아님. 검증 기준:

| 항목 | 검증 방법 |
|------|---------|
| 모든 locked decisions(D-01~D-13) 커버 | SPEC.md에서 각 Decision ID 언급 확인 |
| 단계별 표 완전성 | 5개 GSD 단계 + /gsd-clear 모두 포함 |
| 명세 충분성 | 다음 Phase 구현자가 SPEC.md만으로 패치 작성 가능한가 |

---

## Sources

### Primary (HIGH confidence)
- `patches/gsd-phase-researcher.patch.md` — 현재 researcher Step 0 compile 구조 확인
- `patches/gsd-planner.patch.md` — 현재 planner knowledge lookup 지시 확인
- `patches/gsd-verifier.patch.md` — verifier Step 10b 및 Step 10c 전체 구조 확인
- `.planning/phases/05-gsd-workflow-stages/05-CONTEXT.md` — 모든 locked decisions 원본
- `install.sh` — 현재 패치 적용 방식 및 anchor 위치 확인
- `$HOME/.claude/get-shit-done/workflows/discuss-phase.md` — load_prior_context step 구조 확인
- `$HOME/.claude/agents/` directory listing — 패치 대상 파일 목록 확인
- `$HOME/.claude/skills/` directory listing — /gsd-clear가 신규임을 확인 (현재 없음)

### Secondary (MEDIUM confidence)
- `.knowledge/knowledge/index.md`, `decisions.md`, `guardrails.md`, `anti-patterns.md` — 현재 knowledge 구조 및 패턴 파악
- `.knowledge/raw/2026-04-12.md` — Phase 5 discuss 결정 사항 원본 수집 확인

---

## Metadata

**Confidence breakdown:**
- Architecture Patterns: HIGH — 현재 코드베이스 직접 확인, 모든 패치 파일 읽음
- Specification Structure: HIGH — CONTEXT.md locked decisions 기반, 추측 없음
- compile-manifest.json 구현 방식: MEDIUM — Claude's Discretion 영역, mtime 권장은 ASSUMED
- B+C 중복 처리 임계값: MEDIUM — 기존 70% 기준 준용, CONTEXT.md Claude's Discretion

**Research date:** 2026-04-12
**Valid until:** 명세 기반 프로젝트이므로 만료 없음 — 다음 Phase 구현 시 참조
