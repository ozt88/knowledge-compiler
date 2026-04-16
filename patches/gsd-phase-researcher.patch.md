<!-- PATCH:knowledge-compiler for gsd-phase-researcher.md -->
<!-- Insert BEFORE: "## Step 1.5: Architectural Responsibility Mapping" -->

<!-- PATCH:knowledge-compiler — reapply after GSD updates -->

**Knowledge Lookup (uses graph context from Step 1.3):**

Build keyword set for knowledge/ lookup:
- Start with phase name and task keywords
- **If graphify returned results in Step 1.3:** extract node labels from graph query results and add them to the keyword set
  - Example: graphify returned [AuthService, JwtValidator] → also search for "AuthService", "JwtValidator"

**knowledge/ lookup order:**

1. `index.md` — Quick Reference 테이블에서 현재 리서치 주제와 관련된 파일 식별 (위 keyword set 사용)
2. `decisions.md` — 조회 우선순위:
   - Observed 카운터가 높은 항목 우선 (여러 세션에서 재확인된 결정은 더 신뢰성 높음)
   - `[context: ...]` 태그가 현재 리서치 주제(keyword set 포함)와 일치하는 항목 우선
   - `[rejected]` 항목: 이 방향을 피하고 대안을 선택
   - `[uncertain]` 항목: 이 결정은 불확실 상태 — 사용 전 raw/ 최근 항목에서 추가 컨텍스트 확인 필요
   - `[superseded]` 항목: 참고 목적으로만 읽고 리서치 권고안에 반영하지 않음
3. `anti-patterns.md` — Review the list and prioritize proven patterns in research recommendations
4. `troubleshooting.md` — Check already-solved problems and focus on new unresolved issues

**Lookup order:** Read index.md first to identify files relevant to the current phase, then selectively Read only those files.
