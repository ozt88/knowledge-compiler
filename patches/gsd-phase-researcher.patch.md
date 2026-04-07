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
   - `anti-patterns.md` — 피해야 할 패턴과 그 이유 목록
   - `troubleshooting.md` — 에러 메시지 ↔ 해결책 매핑
   - `index.md` — 전체 요약 + 키워드 인덱스
5. 기존 knowledge 파일을 읽은 뒤 새 항목을 추가하거나 기존 항목을 업데이트하여 병합하라

**During research (Step 3):** Also search `.knowledge/knowledge/` for findings relevant to this phase. Especially check:
- `decisions.md` — `[rejected]` 항목을 확인하고 대안 접근법을 선택하라
- `anti-patterns.md` — 목록을 확인하고 연구 추천에서 검증된 패턴을 우선 적용하라
- `troubleshooting.md` — 이미 해결된 문제를 확인하고 새로운 미해결 문제에 집중하라
