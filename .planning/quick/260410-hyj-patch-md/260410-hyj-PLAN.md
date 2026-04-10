---
phase: 260410-hyj-patch-md
plan: 01
type: execute
wave: 1
depends_on: []
files_modified:
  - patches/gsd-phase-researcher.patch.md
  - patches/gsd-verifier.patch.md
  - ~/.claude/agents/gsd-phase-researcher.md
  - ~/.claude/agents/gsd-verifier.md
autonomous: true
requirements: [PATCH-EN-01]
must_haves:
  truths:
    - "Both patch source files contain no Korean text"
    - "Installed agent files reflect the updated English patch sections"
    - "Instruction semantics are preserved — only language is changed, not meaning"
  artifacts:
    - path: "patches/gsd-phase-researcher.patch.md"
      provides: "English-only Step 0 patch content"
    - path: "patches/gsd-verifier.patch.md"
      provides: "English-only Step 10b patch content"
    - path: "~/.claude/agents/gsd-phase-researcher.md"
      provides: "Installed agent with English Step 0 section"
    - path: "~/.claude/agents/gsd-verifier.md"
      provides: "Installed agent with English Step 10b section"
  key_links:
    - from: "patches/gsd-phase-researcher.patch.md"
      to: "~/.claude/agents/gsd-phase-researcher.md"
      via: "patch section lines 425-490"
      pattern: "Step 0: Knowledge Compile"
    - from: "patches/gsd-verifier.patch.md"
      to: "~/.claude/agents/gsd-verifier.md"
      via: "patch section lines 580-645"
      pattern: "Step 10b: Knowledge Reconcile"
---

<objective>
Convert all Korean text in both patch.md source files to English, then update the corresponding sections in the installed agent files to match.

Purpose: GSD agent files are all in English. Korean instructions in patches reduce LLM compliance and create inconsistency with surrounding content.
Output: Four files updated — two patch sources and two installed agents.
</objective>

<execution_context>
@$HOME/.claude/get-shit-done/workflows/execute-plan.md
@$HOME/.claude/get-shit-done/templates/summary.md
</execution_context>

<context>
@.planning/STATE.md
</context>

<tasks>

<task type="auto">
  <name>Task 1: Convert patch source files to English</name>
  <files>patches/gsd-phase-researcher.patch.md, patches/gsd-verifier.patch.md</files>
  <action>
Rewrite every Korean passage in both patch files to English. Preserve meaning exactly — this is a translation, not a rewrite.

Key Korean sections to translate (both files share the same structure):

**raw entry selection criteria (included):**
- 미래 세션에서 동일한 실수를 방지하는 결정 또는 기술적 발견
  → Decisions or technical findings that prevent the same mistake in future sessions
- 시스템 동작, 제약, 설계 원칙에 대한 구조적 지식
  → Structural knowledge about system behavior, constraints, and design principles
- 재발 가능한 에러와 그 해결 방법
  → Recurring errors and their solutions
- 프로젝트 상태를 변화시킨 주요 완료 이벤트 (Phase 완료, 설계 결정 등)
  → Significant completion events that changed project state (phase completions, design decisions, etc.)

**raw entry selection criteria (skipped):**
- 일회성 확인 작업 또는 상태 점검 (진행 상황 확인, 단순 조회)
  → One-off verification tasks or status checks (progress checks, simple lookups)
- 결과 없이 종료된 단순 탐색 시도
  → Simple exploration attempts that ended without a result
- 이미 포함된 항목의 중복 기록
  → Duplicate entries already present in knowledge/

**guardrails.md description:**
- 대안이 하나로 확정되는 케이스를 긍정형 액션으로 기술한다
  → Describes cases where the alternative is fixed to one choice, written as positive actions
- 형식 / 예시 lines: translate label words (형식→Format, 예시→Example, 절대적 케이스→absolute case, 대안 확정 케이스→confirmed-alternative case)

**anti-patterns.md description:**
- 상황에 따라 달라질 수 있는 맥락 의존적 케이스를 관찰-이유-대신 구조로 기술한다
  → Describes context-dependent cases where the right approach varies, using Observation-Reason-Instead structure
- 형식 label words: 관찰→Observation, 이유→Reason, 대신→Instead
- Example titles: 컴파일러 부정형 지시→Compiler negative instructions, raw/ 파일 직접 쿼리→Direct raw/ file query
- Example bodies: translate fully

**troubleshooting.md description:**
- gsd-phase-researcher.patch.md: 에러 메시지 ↔ 해결책 매핑 → Error message ↔ solution mapping
- gsd-verifier.patch.md: 에러/해결 매핑 갱신 → Update error/solution mapping

**index.md description:**
- 맨 위에 "Last compiled", "Total entries" 메타 정보 → Meta information at the top: "Last compiled", "Total entries"
- "Quick Reference" 테이블: 주제 | 파일 | 핵심 항목 → "Quick Reference" table: Topic | File | Key Items
- (에이전트가 index.md만 읽어도 어떤 파일로 갈지 알 수 있도록) → (so an agent can determine which file to read from index.md alone)
- 전체 요약 단락 → Overall summary paragraph
- 키워드 인덱스 (키워드 → 파일#섹션) → Keyword index (keyword → file#section)

**Classification rule:**
- 분류 기준: 대안이 하나로 확정되는가?
  → Classification rule: Is the alternative fixed to one choice?
- YES → guardrails.md에 긍정형 액션으로 기술 → YES → write to guardrails.md as a positive action
- NO (상황에 따라 달라짐) → anti-patterns.md에 관찰-이유-대신 구조로 기술
  → NO (varies by context) → write to anti-patterns.md using Observation-Reason-Instead structure

**Existing anti-patterns.md migration block:**
- 기존 anti-patterns.md가 존재하는 경우 → If an existing anti-patterns.md is present:
- 모든 항목을 읽어 위 분류 기준 적용 → Read all entries and apply the classification rule above
  - 대안이 하나로 확정 → guardrails.md에 긍정형 액션으로 재기술
    → Alternative is fixed → rewrite to guardrails.md as a positive action
  - 상황에 따라 달라짐 → anti-patterns.md에 관찰-이유-대신 구조로 재형식화
    → Varies by context → reformat in anti-patterns.md using Observation-Reason-Instead structure
- 마이그레이션 완료 후 guardrails.md를 신규 생성하고 anti-patterns.md를 새 형식으로 덮어쓴다
  → After migration, create guardrails.md and overwrite anti-patterns.md with the new format

**gsd-phase-researcher.patch.md only — decisions.md line:**
- 시도 → 결과 → 결정. 상태 태그: → Attempt → Result → Decision. Status tags:

**gsd-verifier.patch.md only:**
- decisions.md line: 모든 시도/결정 통합, 상태 태그 정합성 확인
  → Consolidate all attempts/decisions, verify status tag consistency
- Conflict note: 충돌하는 [active] decision이 있으면 [uncertain]으로 표시
  → If conflicting [active] decisions exist, mark them [uncertain]
- Full reconcile note: Phase 완료 시점이므로 전체 일관성을 재검증
  → This is the phase completion point, so revalidate overall consistency
- During-research lookup section title: knowledge/ 조회 순서
  → knowledge/ lookup order (note: this section appears only in gsd-phase-researcher.patch.md — translate its three bullet labels: decisions.md 앞 문장, anti-patterns.md 앞 문장, troubleshooting.md 앞 문장)
- knowledge/ usage instruction (bottom of verifier patch): 에이전트가 knowledge/를 조회할 때 index.md를 먼저 읽어 관련 파일을 파악한 후, 해당 파일만 선택적으로 Read하라.
  → When an agent queries knowledge/, read index.md first to identify relevant files, then selectively Read only those files.

**During research section (gsd-phase-researcher.patch.md lines 58-63):**
- knowledge/ 조회 순서: → knowledge/ lookup order:
- decisions.md bullet: [rejected] 항목을 확인하고 대안 접근법을 선택하라
  → Check [rejected] entries and choose an alternative approach
- anti-patterns.md bullet: 목록을 확인하고 연구 추천에서 검증된 패턴을 우선 적용하라
  → Review the list and prioritize proven patterns in research recommendations
- troubleshooting.md bullet: 이미 해결된 문제를 확인하고 새로운 미해결 문제에 집중하라
  → Check already-solved problems and focus on new unresolved issues
- 조회 순서 note: index.md를 먼저 읽어 현재 Phase와 관련된 파일을 파악한 후, 해당 파일만 선택적으로 Read하라.
  → Read index.md first to identify files relevant to the current phase, then selectively Read only those files.

Do NOT change: HTML comments, heading names (Step 0, Step 10b), file names, tag names like [active]/[rejected]/[superseded]/[uncertain], code-style backtick terms, or the PATCH comment markers.
  </action>
  <verify>
    <automated>grep -rn "[가-힣]" /home/ozt88/knowledge-compiler/patches/ && echo "FAIL: Korean found" || echo "PASS: No Korean text"</automated>
  </verify>
  <done>Both patch files contain zero Korean characters. All translated text matches the semantic meaning of the original Korean.</done>
</task>

<task type="auto">
  <name>Task 2: Sync translated patches into installed agent files</name>
  <files>~/.claude/agents/gsd-phase-researcher.md, ~/.claude/agents/gsd-verifier.md</files>
  <action>
Replace the Korean-containing patch sections in the installed agent files with the English versions just written to the patch source files.

For gsd-phase-researcher.md:
- The patch section starts at the line containing "## Step 0: Knowledge Compile (before research)" (currently line 425)
- It ends at the last line of the section before the next "## Step" heading or end-of-file
- Replace the entire body of this section (from the PATCH comment through the final lookup order note) with the content from the updated patches/gsd-phase-researcher.patch.md
- Keep the surrounding file content (before line 425 and after the section) unchanged

For gsd-verifier.md:
- The patch section starts at the line containing "## Step 10b: Knowledge Reconcile (after verification)" (currently line 580)
- It ends at the last line of the section before end-of-file or next heading
- Replace the entire body with content from the updated patches/gsd-verifier.patch.md
- Keep surrounding file content unchanged

Use Read tool to load the full agent files before editing. Use Edit tool (not Write) so only the changed section is replaced — do not rewrite the entire multi-hundred-line agent files.

Verify after editing that the installed files have no Korean text in the patch sections.
  </action>
  <verify>
    <automated>grep -n "[가-힣]" ~/.claude/agents/gsd-phase-researcher.md ~/.claude/agents/gsd-verifier.md && echo "FAIL: Korean found" || echo "PASS: No Korean text in installed agents"</automated>
  </verify>
  <done>Both installed agent files have the patch sections in English. No Korean characters remain anywhere in either file.</done>
</task>

</tasks>

<verification>
Run both verify commands in sequence:

```bash
grep -rn "[가-힣]" /home/ozt88/knowledge-compiler/patches/ && echo "FAIL" || echo "PASS: patches clean"
grep -n "[가-힣]" ~/.claude/agents/gsd-phase-researcher.md ~/.claude/agents/gsd-verifier.md && echo "FAIL" || echo "PASS: agents clean"
```

Both must output PASS.
</verification>

<success_criteria>
- Zero Korean characters in patches/gsd-phase-researcher.patch.md
- Zero Korean characters in patches/gsd-verifier.patch.md
- Zero Korean characters in the patch sections of ~/.claude/agents/gsd-phase-researcher.md
- Zero Korean characters in the patch sections of ~/.claude/agents/gsd-verifier.md
- All instructions semantically equivalent to original Korean content
</success_criteria>

<output>
After completion, create `.planning/quick/260410-hyj-patch-md/260410-hyj-SUMMARY.md`
</output>
