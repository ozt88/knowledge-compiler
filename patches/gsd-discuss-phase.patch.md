<!-- PATCH:knowledge-compiler for discuss-phase.md -->
<!-- Insert BEFORE: "<step name=\"load_prior_context\">" -->

<!-- PATCH:knowledge-compiler — reapply after GSD updates -->

**Project knowledge:** discuss 시작 전 이전 세션의 결정사항을 확인한다.

**Skip condition:** `.knowledge/knowledge/`가 없거나 `index.md`가 없으면 건너뜀.

**If knowledge/ exists:**

1. `.knowledge/knowledge/index.md` 읽기 — Quick Reference 테이블과 키워드 인덱스 확인.
2. 현재 Phase 주제와 관련 있는 knowledge 파일 식별.
3. 관련 파일만 선택적으로 읽기:
   - `decisions.md` — `[rejected]` 항목 확인: 이미 거부된 방향을 재질문하거나 재제안하지 않음
   - `guardrails.md` — 하드 제약 확인: discuss 중 이 제약을 위반하는 선택지를 제시하지 않음
4. compile은 수행하지 않음 — discuss는 조회만.

**Lookup order:** index.md를 먼저 읽고, Quick Reference에서 관련 파일만 선택적으로 로드한다.

