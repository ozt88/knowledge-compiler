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

**Step 0: 서브에이전트로 세션 대화 → raw 기록**

`.knowledge/raw/` 디렉토리가 없으면 이 단계를 건너뛴다.

1. `.planning/compile-manifest.json`에서 `last_raw_captured` 읽기
   - 없으면: null (세션 전체 대상)
   - 있으면: 해당 ISO 시각 문자열

2. 현재 세션 JSONL 파일 경로 확인:
   - Bash로 `C:\Users\DELL\.claude\projects\c--Users-DELL-Desktop-knowledge-compiler\` 디렉토리의 `.jsonl` 파일 목록을 mtime 내림차순으로 조회
   - mtime 기준 가장 최신 파일 = 현재 세션 JSONL

3. Agent 도구로 서브에이전트 호출 (subagent_type: general-purpose):
   - JSONL 경로, last_raw_captured 값, 오늘 날짜(YYYY-MM-DD)를 프롬프트에 포함
   - 서브에이전트 역할:
     a. JSONL 파일을 UTF-8로 읽어 각 줄을 JSON 파싱
     b. `last_raw_captured`가 있으면 그 시각 이후 항목만 처리, 없으면 전체
     c. `type == "user"` 항목: `message.content` (string) 추출
     d. `type == "assistant"` 항목: `message.content` 리스트에서 `type == "text"` 블록의 `text` 추출
     e. 추출한 대화에서 기록할 만한 내용 식별:
        - 수행한 작업과 결과 (Phase 실행, 파일 수정, 설계 결정 등)
        - 해결한 문제 또는 발생한 오류와 해법
        - 핵심 발견 또는 결정 사항
     f. `.knowledge/raw/{YYYY-MM-DD}.md`에 append (없으면 생성):
        ```
        ### {HH:MM} — {한줄 제목}
        - {항목 1}
        - {항목 2}
        ```
        기록할 내용이 없으면 파일 수정 없이 종료
     g. 완료 후 다음을 반환:
        - 기록 여부와 작성된 항목 요약
        - JSONL에서 처리한 가장 마지막 타임스탬프 (처리한 항목이 없으면 null 반환)

4. 서브에이전트 완료 후 `.planning/compile-manifest.json`의 `last_raw_captured`를 **서브에이전트가 반환한 마지막 JSONL 타임스탬프**로 업데이트
   - 서브에이전트가 null을 반환한 경우(처리할 항목 없음)에는 업데이트하지 않음
   - 파일이 없으면 `{ "last_raw_captured": "..." }` 로 새로 생성
   - **주의:** 현재 시각(벽시계)은 사용하지 않는다 — JSONL은 UTC이므로 KST 시각과 혼용하면 타임존 불일치 발생

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
