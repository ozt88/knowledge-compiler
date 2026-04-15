<!-- PATCH:knowledge-compiler for discuss-phase.md -->
<!-- Insert BEFORE: "<step name=\"cross_reference_todos\">" -->

<!-- PATCH:knowledge-compiler — reapply after GSD updates -->

**Project knowledge:** discuss 시작 전 이전 세션의 결정사항을 확인한다.

**Skip condition:** `.knowledge/knowledge/`가 없거나 `index.md`가 없으면 건너뜀.

**If knowledge/ exists:**

1. `.knowledge/knowledge/index.md` 읽기 — Quick Reference 테이블과 키워드 인덱스 확인.
2. 현재 Phase 주제와 관련 있는 knowledge 파일 식별.
3. 관련 파일만 선택적으로 읽기:
   - `decisions.md` — 조회 우선순위:
     - Observed 카운터가 높은 항목 우선 (여러 세션에서 재확인된 결정)
     - `[context: ...]` 태그가 현재 Phase 주제와 일치하는 항목 우선
     - `[rejected]` 항목: 이미 거부된 방향을 재질문하거나 재제안하지 않음
     - `[uncertain]` 항목: 사용자에게 "이 결정은 불확실 상태"임을 알리고 재논의 여부 확인
     - `[superseded]` 항목: 대체된 결정임을 참고로만 언급
   - `guardrails.md` — 하드 제약 확인: discuss 중 이 제약을 위반하는 선택지를 제시하지 않음
4. compile은 수행하지 않음 — discuss는 조회만.

**Lookup order:** index.md를 먼저 읽고, Quick Reference에서 관련 파일만 선택적으로 로드한다.
