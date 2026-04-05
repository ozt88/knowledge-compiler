<!-- PATCH:knowledge-compiler for gsd-phase-researcher.md -->
<!-- Insert BEFORE: "## Step 1: Receive Scope and Load Context" -->

## Step 0: Knowledge Compile (before research)

<!-- PATCH:knowledge-compiler — reapply after GSD updates -->

Before researching, check if the project has accumulated knowledge from previous sessions.

**Skip condition:** If `.knowledge/raw/` does not exist or is empty, skip to Step 1.

**If raw/ has content:**

1. Read all `.knowledge/raw/*.md` files
2. Check if `.knowledge/knowledge/` exists. If not, create it.
3. Read existing knowledge files (if any): `decisions.md`, `anti-patterns.md`, `troubleshooting.md`, `index.md`
4. Compile new raw entries into knowledge/ structure:
   - `decisions.md` — 시도 → 결과 → 결정. 상태 태그: `[active]`, `[rejected]`, `[superseded]`, `[uncertain]`
   - `anti-patterns.md` — "이것은 하지 마라" 목록과 이유
   - `troubleshooting.md` — 에러 메시지 ↔ 해결책 매핑
   - `index.md` — 전체 요약 + 키워드 인덱스
5. Merge with existing knowledge (don't overwrite, append/update)

**During research (Step 3):** Also search `.knowledge/knowledge/` for findings relevant to this phase. Especially check:
- `decisions.md` — `[rejected]` 항목은 같은 접근 시도 금지
- `anti-patterns.md` — 연구 추천에서 제외할 패턴
- `troubleshooting.md` — 이미 해결된 문제는 재조사 불필요
