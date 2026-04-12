---
name: gsd-knowledge-compile
description: "On-demand knowledge compile — context is preserved (no /clear)"
argument-hint: ""
allowed-tools:
  - Read
  - Write
  - Bash
  - Glob
---

<objective>
세션 중 언제든 on-demand로 .knowledge/raw/ 누적 데이터를 .knowledge/knowledge/로 컴파일한다.

/gsd-clear와 동일한 compile 로직을 수행하되, 마지막 단계에서 /clear를 실행하지 않는다. 컨텍스트는 유지된다.
</objective>

<process>

**Step 0: 세션 대화 → raw 기록**

`.knowledge/raw/` 디렉토리가 없으면 이 단계를 건너뛴다.

1. `.planning/compile-manifest.json`에서 `last_raw_captured` 읽기
   - 없으면: 세션 전체 대화를 대상으로 함
   - 있으면: 해당 시각 이후 대화만 대상으로 함

2. 대상 범위의 대화에서 기록할 만한 내용 추출:
   - 수행한 작업과 결과 (Phase 실행, 파일 수정, 설계 결정 등)
   - 핵심 발견 또는 결정 사항
   - 해결한 문제 또는 발생한 오류와 해법

3. `.knowledge/raw/{YYYY-MM-DD}.md`에 append (없으면 생성):
   ```
   ### {HH:MM} — {한줄 제목}
   - {항목 1}
   - {항목 2}
   - {항목 3}
   ```
   기록할 내용이 없으면 이 단계를 건너뛴다.

4. `.planning/compile-manifest.json`의 `last_raw_captured`를 현재 시각(ISO)으로 업데이트
   - 파일이 없으면 `{ "last_raw_captured": "..." }` 로 새로 생성

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
- `raw/*.md` — 파일명 날짜(YYYY-MM-DD)가 `last_compiled`보다 최신인 파일
- `.planning/**/*.md` — manifest에 기록된 mtime과 현재 mtime이 다른 파일
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
- `decisions.md` — Attempt → Result → Decision (status: `[active]`, `[rejected]`, `[superseded]`, `[uncertain]`)
- `guardrails.md` — 대안이 하나로 고정된 케이스 (긍정형 행동으로 작성)
- `anti-patterns.md` — 문맥에 따라 적절한 접근이 달라지는 케이스 (Observation-Reason-Instead 구조)
- `troubleshooting.md` — 오류 메시지 ↔ 해법 매핑
- `index.md` — Quick Reference 테이블 + 키워드 인덱스

**B+C fusion 정책:**
- 동일 결론 재확인 → `**Observed:** N times (date1, date2, ...)` 줄 추가 또는 카운트 증가
- 반대 결론 → `[conflict: YYYY-MM-DD]` 태그 추가 + `> **New (YYYY-MM-DD):**` blockquote로 새 내용 보존

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
