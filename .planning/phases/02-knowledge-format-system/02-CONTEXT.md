# Phase 2: Knowledge Format System - Context

**Gathered:** 2026-04-07
**Status:** Ready for planning

<domain>
## Phase Boundary

컴파일러 프롬프트(researcher/verifier 패치)에 `guardrails.md`와 `anti-patterns.md`의 생성·형식·마이그레이션 지시를 정의하는 것.

새 기능 추가나 수집 방식 변경은 이 Phase 범위 밖이다.

</domain>

<decisions>
## Implementation Decisions

### 형식 지시 구체성 (COMPILE-04, COMPILE-05)
- **D-01:** 두 파일 모두 유형별 복수 예시(2-3개)를 패치에 인라인으로 포함한다.
  - guardrails.md: 절대적 케이스 예시 1개 + 대안 있는 케이스 예시 1개
  - anti-patterns.md: 관찰-이유-대신 구조의 예시 2개 (서로 다른 맥락)
- **D-02:** 예시는 knowledge-compiler 도메인 소재를 사용한다 (실제 내용과 일관성 확보).

### 분류 경계 정의
- **D-03:** 컴파일러 판단 기준: **"대안이 하나로 확정되는가"** 가 유일한 분기 기준이다.
  - 대안이 하나로 확정 → `guardrails.md` (긍정형 액션으로 기술)
  - 상황에 따라 달라질 수 있음 → `anti-patterns.md` (관찰-이유-대신 구조)
- **D-04:** 추가 판단 기준 없음. 컴파일러가 이 하나의 기준만으로 분류한다.

### 마이그레이션 절차 (COMPILE-03)
- **D-05:** 기존 `anti-patterns.md`가 존재하면 모든 항목을 읽어 분류 기준(D-03) 적용 후 자동 분류·이전한다.
  - guardrails로 분류된 항목 → `guardrails.md`에 긍정형 액션으로 재기술
  - anti-patterns에 남을 항목 → 관찰-이유-대신 구조로 재형식화
- **D-06:** 마이그레이션 완료 후 `anti-patterns.md`를 새 형식으로 덮어쓴다 (원본 보존 없음).
- **D-07:** researcher(incremental)와 verifier(full reconcile) 모두 동일한 마이그레이션 절차를 수행한다. researcher에서도 기존 anti-patterns.md 발견 시 마이그레이션 실행.

### 패치 파일 구조
- **D-08:** researcher 패치(`gsd-phase-researcher.patch.md`)와 verifier 패치(`gsd-verifier.patch.md`) 양쪽에 동일한 형식 지시를 독립적으로 중복 작성한다.
  - 교차 의존성 없음 → 각 패치가 단독으로 사용 가능
  - GSD 업데이트 후 재적용 시 독립적으로 처리 가능

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### 현재 패치 파일 (수정 대상)
- `patches/gsd-phase-researcher.patch.md` — Step 0 컴파일 지시 (incremental). 현재 anti-patterns.md를 "피해야 할 패턴과 그 이유 목록"으로만 기술 → 이 Phase에서 확장
- `patches/gsd-verifier.patch.md` — Step 10b full reconcile 지시. 동일한 구조 → 동일하게 확장

### 요구사항 및 설계 문서
- `.planning/REQUIREMENTS.md` — COMPILE-03, COMPILE-04, COMPILE-05 요구사항 원문
- `.planning/ROADMAP.md` — Phase 2 성공 기준 4개 (guardrails 도입, 형식 지시 규정, 역할 경계 명시)
- `docs/DESIGN.md` — 파이프라인 설계 및 두 파일(anti-patterns, guardrails) 도입 배경

### Phase 1 결과물 (참조용)
- `.planning/phases/01-compiler-prompt-refactor/01-01-PLAN.md` — Phase 1에서 결정한 긍정형 전환 패턴. Phase 2의 형식 지시도 동일한 긍정형 기조를 따름

</canonical_refs>

<code_context>
## Existing Code Insights

### 수정 대상 파일
- `patches/gsd-phase-researcher.patch.md`: Step 0 내 `anti-patterns.md` 생성 지시 (4번 항목) 수정 필요
- `patches/gsd-verifier.patch.md`: Step 10b 내 `anti-patterns.md` 생성 지시 (3번 항목) 수정 필요

### 현재 패턴 (변경 전)
- 두 패치 모두 `anti-patterns.md`를 단일 파일로 관리
- 형식 지시: "피해야 할 패턴과 그 이유 목록" — 구체적 형식 없음
- `guardrails.md` 개념 없음

### 변경 후 목표 패턴
- 두 파일: `guardrails.md` (신규) + `anti-patterns.md` (재형식화)
- 각 파일에 명확한 형식 지시 + 인라인 예시 포함
- 기존 anti-patterns.md 발견 시 마이그레이션 절차 실행

### Integration Points
- `install.sh` — 패치 적용 스크립트. 파일 수정 후 이 스크립트로 재적용 가능
- `.knowledge/knowledge/` — 컴파일러가 실제 생성하는 디렉토리. guardrails.md가 이 위치에 신규 생성됨

</code_context>

<specifics>
## Specific Ideas

- guardrails.md 예시 소재: "raw/ 읽기는 knowledge/index.md 경유 필수" (절대적 케이스), "decisions.md는 decisions/ 하위 파일 병합 방식 사용" (대안 있는 케이스)
- anti-patterns.md 예시 소재: 실제 Phase 01에서 발생한 부정형 지시 문제 사례 활용 가능

</specifics>

<deferred>
## Deferred Ideas

None — 논의가 Phase 2 범위 내에서 진행됨.

</deferred>

---

*Phase: 02-knowledge-format-system*
*Context gathered: 2026-04-07*
