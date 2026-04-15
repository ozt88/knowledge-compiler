<!-- PATCH:knowledge-compiler for gsd-phase-researcher.md -->
<!-- Insert BEFORE: "## Step 1: Receive Scope and Load Context" -->

<!-- PATCH:knowledge-compiler — reapply after GSD updates -->

**During research (Step 3):** knowledge/ lookup order:

1. `index.md` — Quick Reference 테이블에서 현재 리서치 주제와 관련된 파일 식별
2. `decisions.md` — 조회 우선순위:
   - Observed 카운터가 높은 항목 우선 (여러 세션에서 재확인된 결정은 더 신뢰성 높음)
   - `[context: ...]` 태그가 현재 리서치 주제와 일치하는 항목 우선
   - `[rejected]` 항목: 이 방향을 피하고 대안을 선택
   - `[uncertain]` 항목: 이 결정은 불확실 상태 — 사용 전 raw/ 최근 항목에서 추가 컨텍스트 확인 필요
   - `[superseded]` 항목: 참고 목적으로만 읽고 리서치 권고안에 반영하지 않음
3. `anti-patterns.md` — Review the list and prioritize proven patterns in research recommendations
4. `troubleshooting.md` — Check already-solved problems and focus on new unresolved issues

**Lookup order:** Read index.md first to identify files relevant to the current phase, then selectively Read only those files.
