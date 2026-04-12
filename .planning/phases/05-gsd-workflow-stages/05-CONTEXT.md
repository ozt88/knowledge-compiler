# Phase 5: GSD Workflow Stages - Context

**Gathered:** 2026-04-12
**Status:** Ready for planning

<domain>
## Phase Boundary

GSD 워크플로 각 단계(discuss/plan/research/execute/verify)에서 지식 활동(수집·컴파일·조회)이 어떻게 배분되는지 명세로 정의하는 것.

이번 Phase의 산출물은 **명세 문서**다 — 구현(패치 파일 수정, gsd-clear 커맨드 제작)은 다음 Phase에서 수행한다.

**범위 밖:**
- 패치 파일 실제 수정
- `/gsd-clear` 커맨드 구현
- 다중 작업자 간 knowledge 동기화

</domain>

<decisions>
## Implementation Decisions

### 컴파일 트리거

- **D-01:** researcher Step 0 compile **완전 제거** — researcher는 compile 없이 리서치만 수행한다. 이전 세션의 knowledge/는 읽을 수 있다.
- **D-02:** `/gsd-clear` 신규 커맨드를 primary 컴파일 트리거로 정의한다 — 작업 종료 시 사용자가 명시적으로 실행, compile 후 /clear.
- **D-03:** planner Step 0 compile을 **fallback**으로 유지한다 — `/gsd-clear` 없이 세션을 닫은 경우, 다음 Phase 계획 시 planner가 compile을 수행한다.
- **D-04:** 컴파일 시점 철학: Phase 내부는 컨텍스트가 충분하므로 compile 불필요. compile은 Phase 간 정보 단절 방지 목적이다.

### 컴파일 소스

- **D-05:** compile 소스 = `raw/` + `.planning/**` 전체.
  - `.planning/phases/`, `.planning/quick/`, `.planning/debug/` 등 GSD가 생성한 모든 아티팩트 포함.
  - PLAN.md, RESEARCH.md, CONTEXT.md, VERIFICATION.md, REVIEW.md 등 파일 유형 제한 없음.
- **D-06:** 증분 컴파일 — `compile-manifest.json`으로 마지막 compile 이후 변경된 파일만 처리한다.
  - 구체적 구현 방식(hash vs mtime 등)은 researcher 재량.
  - manifest 파일 위치: `.planning/compile-manifest.json`.

### 중복 처리

- **D-07:** 동일 내용이 여러 소스에 중복 등장할 경우 B+C 융합 방식 — 강화(reinforcement) + 최신 소스 우선을 병합한 정책을 researcher가 구체적으로 설계한다.

### 조회 주체 및 시점

- **D-08:** discuss → knowledge/ **참조** — 이미 결정된 사항 재질문 방지, 이전 실패 방향 제시 방지.
- **D-09:** planner → knowledge/ **참조** (compile 직후, 가장 최신 상태).
- **D-10:** researcher → knowledge/ **참조** (planner Step 0 compile 이전 실행이므로 한 Phase 뒤처진 knowledge 참조 — 허용).
- **D-11:** executor, verifier → knowledge/ 참조 **불필요** (Phase 내 컨텍스트로 충분).

### gitignore 정책

- **D-12:** `.knowledge/`는 git 추적 여부와 무관하게 시스템이 동작한다.
  - **git 추적 시:** 환경 간 knowledge 유지, manifest와 함께 증분 동작.
  - **gitignore 시:** 로컬 누적, 새 환경에서 빈 상태로 시작 후 재축적.
  - 시스템이 두 경우 모두 gracefully 처리해야 한다.

### 온디맨드 컴파일 커맨드

- **D-14:** `/gsd-knowledge-compile` 신규 커맨드 — 어떤 시점에도 compile을 수동으로 실행할 수 있는 단일 커맨드.
  - 서브커맨드 없음. 호출하면 compile 실행 후 결과 요약 출력.
  - `/gsd-clear`(compile + /clear)와 구분: `/gsd-knowledge-compile`는 컨텍스트를 유지한 채 compile만 수행.

### discuss-phase 패치 배포

- **D-15:** discuss-phase는 workflow 파일(`$HOME/.claude/get-shit-done/workflows/discuss-phase.md`)이므로 agents/ 패치와 별도로 `install.sh`에서 배포한다.
  - `patches/gsd-discuss-phase.patch.md` 신규 생성 → install.sh에서 workflow 파일에 적용.

### Phase 5 산출물

- **D-13 (수정):** 이번 Phase 결과물은 **직접 구현**이다 — spec 문서 생성 없이 패치 파일 수정 + 신규 스킬 생성 + install.sh 업데이트를 수행한다.
  - 건너뛰는 것: `docs/gsd-knowledge-workflow-spec.md` 생성 불필요.

### Claude's Discretion

- compile-manifest.json 구현 방식: mtime 기반 권장
- B+C 중복 처리: 70% 키워드 overlap 임계값, [conflict] 태그 방식

</decisions>

<specifics>
## Specific Ideas

- 사용자 표현: "Phase 간 정보 누락만 아니면 괜찮다 — Phase 내부는 컨텍스트로 충분하다"
- 사용자 표현: "컴파일하고 대화 저장에 너무 많은 컨텍스트와 시간을 쓰는 게 아닌가" — 비용 효율이 중요한 설계 원칙
- 세션 하나에 Phase 하나 작업하는 패턴 → Stop hook 대신 `/gsd-clear` 커맨드가 더 적합
- Knowledge는 개인 로컬 자산 — 팀 공유 대상이 아님. 다른 작업자가 함께 knowledge를 쌓아주길 기대하지 않음

</specifics>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### 현재 시스템 상태

- `patches/gsd-phase-researcher.patch.md` — Step 0 compile 지시 (D-01에 의해 제거 대상), Step 3 knowledge 조회 패턴
- `patches/gsd-planner.patch.md` — 현재 planner knowledge 참조 방식 (D-03 fallback compile 추가 위치)
- `patches/gsd-verifier.patch.md` — verifier Step 10b 현재 상태 (참조용)

### 프로젝트 핵심 문서

- `.planning/PROJECT.md` — Core Value, Constraints (파일시스템 기반 접근, 패치 방식 배포)
- `.planning/ROADMAP.md` — Phase 5 목표
- `.knowledge/knowledge/index.md` — 현재 knowledge 구조 및 Last compiled 패턴 (증분 compile 참조)

### 이전 Phase 결정 (패턴 참조)

- `.planning/phases/04-knowledge-importance-prioritization-scoring/04-CONTEXT.md` — D-05(파일시스템 기반), D-06(패치 방식) carry-forward

</canonical_refs>

<code_context>
## Existing Code Insights

### 현재 compile 위치

- `patches/gsd-phase-researcher.patch.md` Step 0 — raw/ 날짜 기반 증분 compile 로직. D-01에 의해 이 Step이 제거됨.
- `patches/gsd-planner.patch.md` — knowledge/ 참조 지시 존재. D-03 fallback compile 추가 위치.

### 현재 knowledge 구조

- `.knowledge/knowledge/index.md` — `Last compiled` 날짜 필드로 증분 판단. compile-manifest.json과 병행하거나 대체 검토 필요.
- `.knowledge/knowledge/` — decisions.md, guardrails.md, anti-patterns.md, troubleshooting.md, index.md 5파일 구조.

### Integration Points

- `/gsd-clear` 커맨드 — 신규 GSD skill로 생성. compile 실행 후 Claude `/clear` 호출.
- discuss-phase 워크플로 — knowledge/ 참조 지시 추가 위치 (`load_prior_context` step).

</code_context>

<deferred>
## Deferred Ideas

- **패치 파일 실제 수정** — 명세 완성 후 다음 Phase에서 구현
- **`/gsd-clear` 커맨드 구현** — 명세 완성 후 다음 Phase에서 구현
- **다중 작업자 간 knowledge 동기화** — 현재 Out of Scope. 사용자가 다중 작업자 환경에서도 개인 로컬 knowledge로 운영하는 방식으로 결정됨.
- **`.knowledge/` gitignore 권장 정책** — 사용자 선택에 맡김, 시스템이 양쪽 모두 지원.

</deferred>

---

*Phase: 05-gsd-workflow-stages*
*Context gathered: 2026-04-12*
