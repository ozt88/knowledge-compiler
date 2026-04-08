# Phase 3: Collection Instruction Refactor - Context

**Gathered:** 2026-04-08
**Status:** Ready for planning

<domain>
## Phase Boundary

`templates/claude-md-section.md`와 `$HOME/.claude/CLAUDE.md`의 턴 수집 지시 중 부정형 규칙(규칙 4: "요약에 포함하지 않을 것")을 긍정형으로 전환하는 것.

새 수집 항목 추가, 수집 방식 변경, 자동화, 규칙 5("수집 중지" 조건) 변경은 이 Phase 범위 밖이다.

</domain>

<decisions>
## Implementation Decisions

### 긍정형 전환 방식 (COLLECT-01)
- **D-01:** 규칙 4("요약에 포함하지 않을 것")를 삭제하고 규칙 3("요약에 포함할 것")에 흡수한다.
  - 규칙 3의 항목들을 더 세밀하게 기술하여 자연스럽게 범위를 한정한다.
  - 예: "무엇을 했는지, 핵심 발견/결정, 변경된 파일" → "행동과 결과, 핵심 발견 또는 결정, 변경된 파일" 형태로 구체화
  - 규칙 4 자리는 삭제 (규칙 번호 재조정)
- **D-02:** 전환 후에도 코드 전문·개인정보·도구 호출 시퀀스를 요약에 담지 않는 의도는 긍정형 범위 한정으로 동일하게 달성해야 한다.
  - 허용 항목만 명시하면 그 외는 자동으로 배제됨 — 부정형 명시 불필요

### 동기화 방향
- **D-03:** `templates/claude-md-section.md`가 source of truth다.
  - template을 먼저 수정하고, 수정된 내용을 `$HOME/.claude/CLAUDE.md`에 동일하게 반영한다.
  - install.sh의 기존 패치 적용 방식과 일관성 유지.

### 규칙 5번 처리
- **D-04:** 규칙 5("수집 중지" 조건)는 이번 Phase에서 변경하지 않는다.
  - COLLECT-01 요구사항은 "포함하지 않을 것" 항목만 대상으로 명시.
  - 규칙 5는 조건 지시이며 부정형 패턴이 아님 — 범위 밖.

### Claude's Discretion
- 규칙 3의 구체적인 표현 (어떤 동사와 형용사를 사용할지)은 Claude 재량. 단, 긍정형 액션 형태를 유지해야 한다.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### 수정 대상 파일
- `templates/claude-md-section.md` — source of truth 턴 수집 지시 템플릿. 규칙 4("포함하지 않을 것") 항목이 수정 대상
- `~/.claude/CLAUDE.md` (`$HOME/.claude/CLAUDE.md`) — 실제 주입되는 글로벌 지시 파일. template 수정 후 동일하게 반영

### 요구사항
- `.planning/REQUIREMENTS.md` — COLLECT-01: "CLAUDE.md 턴 수집 지시의 부정형 규칙('포함하지 않을 것')을 긍정형으로 전환한다"

### Phase 1 긍정형 전환 패턴 참조
- `.planning/phases/01-compiler-prompt-refactor/01-01-PLAN.md` — Phase 1에서 확립한 긍정형 전환 방식. 동일한 기조 적용

### 설계 배경
- `docs/DESIGN.md` — knowledge-compiler 파이프라인 설계. 수집 → 컴파일 흐름 이해용

</canonical_refs>

<code_context>
## Existing Code Insights

### 수정 대상 섹션 (현재 상태)
```
**규칙:**
1. 응답 완료 직전에 Write 도구로 `.knowledge/raw/{YYYY-MM-DD}.md` 파일에 append (당일 파일이 없으면 생성)
2. 형식: `### {HH:MM} — {한줄 제목}\n{2-3줄 요약}\n` (한국어)
3. 요약에 포함할 것: 무엇을 했는지, 핵심 발견/결정, 변경된 파일
4. 요약에 포함하지 않을 것: 코드 전문, 사용자 개인정보, 도구 호출 세부사항   ← 삭제 대상
5. 사용자가 `/collect-off` 또는 "수집 중지"라고 하면 해당 세션 동안 수집 중단
6. 이 지시는 GSD 워크플로 안팎 모두에서 항상 적용
```

### 목표 상태
- 규칙 4 삭제
- 규칙 3을 세밀화하여 포함 범위 명확화 (행동·결과, 핵심 발견/결정, 변경 파일만)
- 규칙 번호 5→4, 6→5로 재조정

### Integration Points
- `install.sh` — template → CLAUDE.md 동기화 스크립트. 기존 패치 적용 방식과 일관성 확인 필요

</code_context>

<specifics>
## Specific Ideas

- Phase 1의 패턴: "피해야 할 패턴" → "관찰-이유-대신" 같은 구조적 전환보다, 이번은 단순히 허용 범위를 명확히 서술하는 방식이 적합 (D-01)
- "요약에 포함할 것" 항목을 세밀화하는 방향: 1개의 항목 라인 → 3개 구체 항목으로 분리

</specifics>

<deferred>
## Deferred Ideas

- 규칙 5("수집 중지" 조건) 긍정형 전환 — COLLECT-01 범위 밖, 필요 시 별도 Phase
- 자동 동기화 메커니즘 (template → CLAUDE.md 자동 적용) — v1.1 범위 초과

</deferred>

---

*Phase: 03-collection-instruction-refactor*
*Context gathered: 2026-04-08*
