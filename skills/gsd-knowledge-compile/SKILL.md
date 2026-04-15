---
name: gsd-knowledge-compile
description: "On-demand knowledge compile — context is preserved (no /clear)"
argument-hint: ""
allowed-tools:
  - Read
  - Write
  - Bash
  - Glob
  - Agent
---

<objective>
세션 중 언제든 on-demand로 .knowledge/raw/ 누적 데이터를 .knowledge/knowledge/로 컴파일한다.

/gsd-clear와 동일한 compile 로직을 수행하되, 마지막 단계에서 /clear를 실행하지 않는다. 컨텍스트는 유지된다.
</objective>

<process>

**Step 1: raw/ 존재 확인**

`.knowledge/raw/` 디렉토리가 없으면:
- "No .knowledge/raw/ found — nothing to compile" 출력
- 종료

**Step 2: compile-manifest.json 로드**

`.planning/compile-manifest.json`을 읽는다.
- 없으면: full compile 모드 (모든 raw/*.md + .planning/**/*.md 처리)
- 있으면: manifest의 `last_compiled` 날짜 기록

**Step 3: 변경된 소스 파일 스캔**

다음 파일을 스캔해 변경 여부를 판단한다:
- `raw/*.md` — 파일명 날짜(YYYY-MM-DD)가 `last_compiled`보다 최신이거나 같은 파일
- `.planning/**/*.md` — manifest에 없는 신규 파일, 또는 manifest에 기록된 mtime과 현재 mtime이 다른 파일
- **제외:** `.planning/compile-manifest.json` 자체 (자기 참조 방지)

변경된 파일이 없으면:
- "Knowledge is up to date — no changes since last compile" 출력
- 종료

**Step 4: 변경 파일 읽기**

변경된 raw/*.md 파일과 관련 .planning/**/*.md 파일을 Read 도구로 읽는다.

**Step 5: knowledge/ 병합**

읽은 파일에서 knowledge를 추출해 `.knowledge/knowledge/`에 병합한다.

**포함 기준:**
- 미래 세션의 실수를 방지하는 결정/발견
- 시스템 동작 구조 지식
- 반복 오류와 해법
- 중요 완료 이벤트 (Phase 완료, 설계 결정 등)

**건너뛰는 항목:**
- 일회성 검증 작업, 결과 없는 탐색
- 이미 존재하는 중복 항목

**파일별 업데이트:**
- `decisions.md` — 신규 항목 형식:
  ```
  ## 설계 결정 — [제목]
  [active] [context: tag1, tag2]

  **시도:** [...]
  **결과:** [...]
  **결정:** [...]
  **Observed:** 1 times (YYYY-MM-DD)
  ```
  - `[context: ...]` 태그는 항목의 적용 영역을 나타낸다. 카테고리: `file-loading`, `agent-behavior`, `knowledge-format`, `compile-logic`, `install-deploy`, `scope-backlog`. 항목당 최대 3개.
  - 상태값: `[active]`, `[rejected]`, `[superseded]`, `[uncertain]`
  - `**Observed:** 1 times (YYYY-MM-DD)`를 기본 포함한다 (최초 기록일 = 오늘 날짜)
- `guardrails.md` — 대안이 하나로 고정된 케이스 (긍정형 행동으로 작성)
- `anti-patterns.md` — 문맥에 따라 적절한 접근이 달라지는 케이스 (Observation-Reason-Instead 구조)
- `troubleshooting.md` — 오류 메시지 ↔ 해법 매핑
- `index.md` — Quick Reference 테이블 + 키워드 인덱스

**B+C fusion 정책:**
- 동일 결론 재확인 → `**Observed:** N times (date1, date2, ...)` 줄 추가 또는 카운트 증가. 날짜가 서로 다른 날이면 독립적 재확인으로 더 높은 신뢰도를 의미한다.
- 반대 결론 (동일 주제에서 이전 결정과 **직접적으로 모순되는** 결론) →
  1. `[conflict: YYYY-MM-DD]` 태그 추가
  2. `> **New (YYYY-MM-DD):**` blockquote로 새 내용 보존
  3. 항목 상태를 `[uncertain]`으로 변경
- `[uncertain]` 항목 처리 — 다음 컴파일 시 raw에서 추가 증거를 수집한다:
  - 동일 방향 증거 발견 → `[active]`로 복귀 + conflict blockquote 아래에 판정 결과 기록
  - 반대 방향 증거 확정 → `[superseded]` 또는 `[rejected]`로 확정
  - 증거 없음 → `[uncertain]` 유지

**Step 6: manifest 및 index.md 업데이트**

- `.planning/compile-manifest.json` 업데이트: 처리된 각 파일의 현재 mtime 기록, `last_compiled`를 오늘 날짜로 갱신
- `.knowledge/knowledge/index.md`의 `Last compiled` 날짜를 오늘 날짜로 업데이트

**Step 7: 결과 요약 출력 (/clear 실행하지 않음)**

compile 결과를 사용자에게 요약 출력한다:
- 처리된 파일 수 (예: "Processed 3 raw files")
- 추가/업데이트된 knowledge 항목 수 (예: "Added 2 entries, updated 1 entry")
- 수정된 knowledge 파일 목록 (예: "Modified: decisions.md, index.md")

컨텍스트는 유지된다. 세션을 계속 진행할 수 있다.

</process>
