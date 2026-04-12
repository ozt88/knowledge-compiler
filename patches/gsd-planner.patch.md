<!-- PATCH:knowledge-compiler for gsd-planner.md -->
<!-- Insert INSIDE: <project_context> block, AFTER the "Project skills" paragraph -->

**Knowledge compile (fallback):** `/gsd-clear`를 실행하지 않고 세션을 종료한 경우를 대비해 compile을 수행한다.

<!-- PATCH:knowledge-compiler — reapply after GSD updates -->

**Skip conditions (모두 해당하면 건너뜀):**
- `.knowledge/raw/` 디렉토리가 없거나 비어 있음
- `.planning/compile-manifest.json`이 존재하고 변경된 파일이 없음

**Fallback compile 절차:**

1. `.knowledge/raw/`가 없으면 compile 건너뜀 → 기존 knowledge lookup으로 진행.
2. `.planning/compile-manifest.json` 로드.
   - 없으면: full compile 모드 (모든 raw/ + .planning/** 처리).
3. 변경된 소스 파일 스캔:
   - `raw/*.md` — 파일의 mtime이 manifest의 `last_compiled`보다 최신인 것
   - `.planning/**/*.md` — manifest에 기록된 mtime과 현재 mtime이 다른 것
   - **제외:** `.planning/compile-manifest.json` 자체 (자기 참조 방지)
4. 변경된 파일이 없으면 compile 건너뜀 → 기존 knowledge lookup으로 진행.
5. 변경된 파일에서 knowledge 추출 → `.knowledge/knowledge/`에 병합 (B+C fusion 정책 적용).
   - 포함: 미래 세션의 실수를 방지하는 결정/발견, 시스템 동작 구조 지식, 반복 오류와 해법, 중요 완료 이벤트
   - 건너뜀: 일회성 검증 작업, 결과 없는 탐색, 이미 존재하는 중복
6. `.planning/compile-manifest.json` 업데이트 (각 파일의 현재 mtime 기록, `last_compiled` 갱신).
7. `.knowledge/knowledge/index.md`의 `Last compiled` 날짜 업데이트.

**Project knowledge:** Check if `.knowledge/knowledge/` exists in the working directory.

**Skip condition:** If `.knowledge/knowledge/` does not exist or `index.md` is missing, skip this step.

**If knowledge/ exists:**

1. Read `.knowledge/knowledge/index.md` to get the "Quick Reference" table and keyword index.
2. Identify which knowledge files are relevant to the current phase (based on phase name, tech stack, and task keywords).
3. Selectively read only the relevant files from:
   - `decisions.md` — Check `[rejected]` entries; do NOT plan tasks using rejected approaches
   - `guardrails.md` — Treat entries as hard constraints; plan tasks must comply
   - `anti-patterns.md` — Treat "Instead" recommendations as preferred patterns in task actions
   - `troubleshooting.md` — If a known problem applies to this phase, include the solution in task actions preemptively

4. Embed knowledge findings directly into task `<action>` blocks:
   - Reference the source: `"per knowledge/guardrails.md: [rule]"` or `"avoiding [anti-pattern] per knowledge/anti-patterns.md"`
   - For rejected decisions: note the alternative in the action — `"Use X (Y was rejected: [reason])"`

**Lookup order:** Always read `index.md` first. Only load individual files when their Quick Reference entry is relevant. Never load all knowledge files unconditionally.
