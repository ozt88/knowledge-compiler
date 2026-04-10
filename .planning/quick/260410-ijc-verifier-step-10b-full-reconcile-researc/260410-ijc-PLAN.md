---
phase: quick-260410-ijc
plan: 01
type: execute
wave: 1
depends_on: []
files_modified:
  - patches/gsd-verifier.patch.md
autonomous: true
must_haves:
  truths:
    - "verifier Step 10b는 index.md의 Last compiled 날짜 기반으로 신규 raw 파일만 처리한다"
    - "Last compiled 이후 신규 raw 파일이 없으면 raw 처리를 스킵한다"
    - "컴파일 완료 후 index.md의 Last compiled 날짜가 업데이트된다"
    - "충돌/강화 감지 규칙과 step 4 (conflicting active -> uncertain)는 그대로 유지된다"
  artifacts:
    - path: "patches/gsd-verifier.patch.md"
      provides: "incremental compile 로직이 적용된 verifier 패치"
      contains: "Last compiled"
  key_links:
    - from: "patches/gsd-verifier.patch.md"
      to: "patches/gsd-phase-researcher.patch.md"
      via: "동일한 incremental raw 처리 로직 (D-08 패턴)"
      pattern: "Last compiled"
---

<objective>
verifier Step 10b의 raw 처리 방식을 full reconcile에서 incremental compile로 전환한다.

Purpose: researcher Step 0과 동일한 Last compiled 기반 증분 로직을 적용하여 불필요한 전체 재처리를 제거하고, D-08 패턴(두 패치 간 incremental 로직 일관성)을 준수한다.
Output: 수정된 `patches/gsd-verifier.patch.md`
</objective>

<execution_context>
@$HOME/.claude/get-shit-done/workflows/execute-plan.md
@$HOME/.claude/get-shit-done/templates/summary.md
</execution_context>

<context>
@patches/gsd-verifier.patch.md
@patches/gsd-phase-researcher.patch.md
</context>

<tasks>

<task type="auto">
  <name>Task 1: verifier Step 10b full reconcile을 incremental compile로 전환</name>
  <files>patches/gsd-verifier.patch.md</files>
  <action>
`patches/gsd-verifier.patch.md`의 Step 10b "If raw/ has content:" 섹션을 아래와 같이 수정한다.

**교체할 부분 (현재 1-3번 단계):**
```
1. Read all `.knowledge/raw/*.md` files
2. Read existing `.knowledge/knowledge/` files (if any)
3. Full reconcile — reprocess ALL raw entries and rebuild knowledge/:
```

**새로운 1-5번 단계로 교체 (researcher Step 0의 1-5번과 동일한 텍스트):**
```
1. Read `.knowledge/knowledge/index.md` and extract the `Last compiled` date (YYYY-MM-DD format).
   - If index.md does not exist or has no "Last compiled" line, treat as first compile (process ALL raw files).
2. List `.knowledge/raw/*.md` files. Filter to only files with filename date >= the "Last compiled" date.
   - Filename pattern: `YYYY-MM-DD.md`. Compare the date portion with "Last compiled" date.
   - **If no files are newer than "Last compiled" date: skip Step 10b raw processing entirely** (log "No new raw entries since {date}, skipping compile").
3. Read only the filtered (newer) raw files.
4. Check if `.knowledge/knowledge/` exists. If not, create it.
5. Read existing knowledge files (if any): `decisions.md`, `anti-patterns.md`, `troubleshooting.md`, `index.md`
```

**6번 단계:** 현재 "3. Full reconcile — reprocess ALL..." 아래의 컴파일 규칙 블록(Raw entry selection criteria부터 anti-patterns.md 재분류까지)을 그대로 유지하되, 단계 번호를 6으로 변경한다.

**7번 단계 추가 (researcher의 step 7과 동일):**
```
7. After reading existing knowledge files, add new entries or update existing entries to merge them.
```
이 단계는 6번(컴파일 규칙) 뒤, 충돌/강화 감지 블록 앞에 배치한다.

**충돌/강화 감지 블록:** 그대로 유지 (현재 위치에서 번호만 조정 불필요 — 이미 번호 없는 블록).

**기존 step 4 (conflicting active -> uncertain):** 번호를 8로 변경하여 유지.

**Last compiled 업데이트 단계 추가 (researcher의 step 8과 동일 텍스트):**
```
9. Update `index.md`: set `Last compiled` to today's date (YYYY-MM-DD), update `Total entries` count.
```

**삭제할 줄:**
77번 줄의 "**This is a FULL reconcile** (not incremental like Step 0 in researcher). This is the phase completion point, so revalidate overall consistency." 전체 삭제.

**유지할 것:**
- "knowledge/ usage instruction" 섹션 (파일 마지막) — 그대로 유지
- Skip condition 줄 — 그대로 유지
- 충돌 감지 / 강화 감지 블록 — 그대로 유지

**주의:** step 2의 스킵 메시지를 verifier 컨텍스트에 맞게 "skip Step 10b raw processing entirely"로 작성한다 (researcher는 "skip Step 0 entirely").
  </action>
  <verify>
    <automated>
# 1) incremental 로직 존재 확인
grep -c "Last compiled" patches/gsd-verifier.patch.md | grep -q "[1-9]" && echo "PASS: Last compiled found" || echo "FAIL: Last compiled not found"
# 2) full reconcile 제거 확인
grep -c "FULL reconcile" patches/gsd-verifier.patch.md | grep -q "^0$" && echo "PASS: FULL reconcile removed" || echo "FAIL: FULL reconcile still present"
# 3) "Read all" 제거 확인
grep -c "Read all.*raw" patches/gsd-verifier.patch.md | grep -q "^0$" && echo "PASS: Read all removed" || echo "FAIL: Read all still present"
# 4) 충돌 감지 유지 확인
grep -c "Conflict detection" patches/gsd-verifier.patch.md | grep -q "[1-9]" && echo "PASS: Conflict detection preserved" || echo "FAIL: Conflict detection missing"
# 5) step 4 (uncertain) 유지 확인
grep -c "uncertain" patches/gsd-verifier.patch.md | grep -q "[1-9]" && echo "PASS: uncertain rule preserved" || echo "FAIL: uncertain rule missing"
# 6) Last compiled 업데이트 단계 존재 확인
grep -c "Update.*index.md.*Last compiled.*today" patches/gsd-verifier.patch.md | grep -q "[1-9]" && echo "PASS: Last compiled update step found" || echo "FAIL: Last compiled update step missing"
    </automated>
  </verify>
  <done>
- verifier Step 10b가 index.md Last compiled 기반 incremental 로직을 사용한다
- "Read all raw/*.md" 및 "FULL reconcile" 문구가 제거되었다
- 신규 raw 파일이 없으면 raw 처리를 스킵하는 조건이 존재한다
- 컴파일 후 Last compiled 날짜 업데이트 단계가 존재한다
- 충돌/강화 감지 규칙과 conflicting active -> uncertain 규칙이 유지된다
- knowledge/ usage instruction 섹션이 유지된다
  </done>
</task>

</tasks>

<verification>
1. `grep "Last compiled" patches/gsd-verifier.patch.md` — incremental 로직 핵심 키워드 존재
2. `grep "FULL reconcile" patches/gsd-verifier.patch.md` — 결과 없음 (제거됨)
3. `grep "Read all" patches/gsd-verifier.patch.md` — 결과 없음 (제거됨)
4. `grep "Conflict detection" patches/gsd-verifier.patch.md` — 존재 (유지됨)
5. `grep "uncertain" patches/gsd-verifier.patch.md` — 존재 (유지됨)
6. researcher 패치의 step 1-3 로직과 verifier 패치의 step 1-3 로직이 구조적으로 동일
</verification>

<success_criteria>
- verifier Step 10b가 researcher Step 0과 동일한 incremental compile 패턴을 사용한다
- full reconcile 관련 문구가 모두 제거되었다
- 기존 규칙(충돌/강화 감지, uncertain 전환, usage instruction)이 모두 보존되었다
</success_criteria>

<output>
After completion, create `.planning/quick/260410-ijc-verifier-step-10b-full-reconcile-researc/260410-ijc-SUMMARY.md`
</output>
