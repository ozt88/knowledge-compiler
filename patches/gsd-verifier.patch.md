<!-- PATCH:knowledge-compiler for gsd-verifier.md -->
<!-- Insert BEFORE: "## Return to Orchestrator" -->

## Step 10b: Knowledge Reconcile (after verification)

<!-- PATCH:knowledge-compiler — reapply after GSD updates -->

After writing VERIFICATION.md, reconcile project knowledge from this phase's learnings.

**Skip condition:** If `.knowledge/raw/` does not exist, skip.

**If raw/ exists:**

**Step 10b-pre: Turn count sanity check**

Before processing raw entries, verify collection completeness:

1. **Estimate expected turns:**
   - Count commits since phase start: `git log --oneline` filtered to the current phase range.
   - If VERIFICATION.md exists, count checklist items (`- [x]` or `- [ ]` patterns) as an additional indicator.
   - Use the larger of the two values as `expected_turns`.
2. **Count raw entries:**
   - In today's raw file (`.knowledge/raw/YYYY-MM-DD.md`), count `###` header occurrences → `raw_count`.
3. **Compare:**
   - If `raw_count < expected_turns * 0.5`, output warning:
     `"⚠️ Raw collection gap detected: {raw_count} entries vs ~{expected_turns} expected turns. Verifier will supplement from git log."`
4. **Supplement (only when warning fires):**
   - Run `git log --format="%H %ai %s"` for today's commits.
   - Skip commits whose message keywords already appear in the raw file.
   - For each missing commit, append to today's raw file:
     ```
     ### {HH:MM} — {commit subject line}
     - {brief summary inferred from commit message and changed files}
     - Changed files: {list from git show --stat}
     - (verifier auto-supplement)
     ```
   - Extract HH:MM from the commit timestamp.

1. Read `.knowledge/knowledge/index.md` and extract the `Last compiled` date (YYYY-MM-DD format).
   - If index.md does not exist or has no "Last compiled" line, treat as first compile (process ALL raw files).
2. List `.knowledge/raw/*.md` files. Filter to only files with filename date >= the "Last compiled" date.
   - Filename pattern: `YYYY-MM-DD.md`. Compare the date portion with "Last compiled" date.
   - **If no files are newer than "Last compiled" date: skip Step 10b raw processing entirely** (log "No new raw entries since {date}, skipping compile").
3. Read only the filtered (newer) raw files.
4. Check if `.knowledge/knowledge/` exists. If not, create it.
5. Read existing knowledge files (if any): `decisions.md`, `anti-patterns.md`, `troubleshooting.md`, `index.md`
6. Compile new raw entries into knowledge/ structure:

   **Raw entry selection criteria — included in knowledge:**
   - Decisions or technical findings that prevent the same mistake in future sessions
   - Structural knowledge about system behavior, constraints, and design principles
   - Recurring errors and their solutions
   - Significant completion events that changed project state (phase completions, design decisions, etc.)

   **Skipped entries:**
   - One-off verification tasks or status checks (progress checks, simple lookups)
   - Simple exploration attempts that ended without a result
   - Duplicate entries already present in knowledge/

   - `decisions.md` — Attempt → Result → Decision. Status tags: `[active]`, `[rejected]`, `[superseded]`, `[uncertain]`
   - `guardrails.md` — Describes cases where the alternative is fixed to one choice, written as positive actions
     - Format: "## [Topic]\n[positive action]" (e.g., "must go through ~", "use ~ approach")
     - Example (absolute case): "## raw/ reading\nReading raw/ must go through knowledge/index.md"
     - Example (confirmed-alternative case): "## decisions.md merge\nUse the sub-file merge approach for decisions.md"
   - `anti-patterns.md` — Describes context-dependent cases where the right approach varies, using Observation-Reason-Instead structure
     - Format: "## [Topic]\n**Observation:** [phenomenon]\n**Reason:** [root cause]\n**Instead:** [recommended approach]"
     - Example 1: "## Compiler negative instructions\n**Observation:** Knowledge file creation instructions use 'do not' phrasing\n**Reason:** LLMs have low compliance with negative instructions, leaving unwanted patterns\n**Instead:** Rewrite as positive actions (apply Phase 1 transition principle)"
     - Example 2: "## Direct raw/ file query\n**Observation:** Reading raw/*.md directly for analysis without going through index.md\n**Reason:** High context cost and loads irrelevant information\n**Instead:** Identify relevant dates from index.md, then selectively read only those raw files"
   - `troubleshooting.md` — Error message ↔ solution mapping
   - `index.md` — Generate in the following format:
     - Meta information at the top: "Last compiled", "Total entries"
     - "Quick Reference" table: Topic | File | Key Items
       (so an agent can determine which file to read from index.md alone)
     - Overall summary paragraph
     - Keyword index (keyword → file#section)

   Classification rule: Is the alternative fixed to one choice?
   - YES → write to `guardrails.md` as a positive action
   - NO (varies by context) → write to `anti-patterns.md` using Observation-Reason-Instead structure

   If an existing `anti-patterns.md` is present:
   - Read all entries and apply the classification rule above
     - Alternative is fixed → rewrite to `guardrails.md` as a positive action
     - Varies by context → reformat in `anti-patterns.md` using Observation-Reason-Instead structure
   - After migration, create `guardrails.md` and overwrite `anti-patterns.md` with the new format
7. After reading existing knowledge files, add new entries or update existing entries to merge them.

   **Conflict detection:** When a new raw entry contradicts an existing knowledge entry (opposite conclusion, reversed decision, etc.):
   - Do NOT overwrite the existing entry.
   - Append a `[conflict: YYYY-MM-DD]` tag to the entry heading (where YYYY-MM-DD is today's date).
   - Preserve both contents: show existing content first, then new content with a `> **New (YYYY-MM-DD):**` blockquote.
   - Example:
     ```
     ## Some Decision [conflict: 2026-04-10]
     [existing content]
     > **New (2026-04-10):** [contradicting content]
     ```

   **Reinforcement detection:** When a new raw entry reconfirms an existing knowledge entry (same conclusion observed again):
   - Add or increment `**Observed:** N times (date1, date2, ...)` line below the entry heading.
   - If the `**Observed:**` line already exists, append the new date and increment the count.
   - Example (first reinforcement):
     ```
     ## Some Decision
     **Observed:** 2 times (2026-04-08, 2026-04-10)
     ```
   - Example (subsequent reinforcement):
     ```
     ## Some Decision
     **Observed:** 3 times (2026-04-08, 2026-04-10, 2026-04-11)
     ```

8. If conflicting `[active]` decisions exist, mark them `[uncertain]`
9. Update `index.md`: set `Last compiled` to today's date (YYYY-MM-DD), update `Total entries` count.

**knowledge/ usage instruction (from the index.md generated in Step 10b):**
When an agent queries knowledge/, read index.md first to identify relevant files, then selectively Read only those files.

## Step 10c: Knowledge Lint (Stage 3)

<!-- PATCH:knowledge-compiler — reapply after GSD updates -->

Run once after Step 10b completes.

**Skip condition:** If `.knowledge/knowledge/` does not exist, skip.

**If knowledge/ exists:**

**Rule 1: Conflicting [active] decisions**

1. Read `.knowledge/knowledge/decisions.md`.
2. Parse `##` sections; collect all sections tagged `[active]`.
3. For each pair of `[active]` sections, strip tags and compare core keywords.
   - If keyword overlap ≥ 70%, mark as conflict.
4. On conflict: append `[conflict: YYYY-MM-DD]` to the section heading (keep `[active]`).
5. Output: `"Lint Rule 1: Conflicting active decisions found for topic '{topic}'"`

**Rule 2: Unverified guardrails**

1. Read `.knowledge/knowledge/guardrails.md`. Parse `##` sections.
2. For each guardrail, extract core keywords from heading and body.
3. Search `.knowledge/raw/*.md` for those keywords.
4. If no match found: append `[unverified]` to the section heading.
5. Output: `"Lint Rule 2: Guardrail '{topic}' has no matching raw source — tagged [unverified]. Manual review recommended."`
6. Note: best-effort only. Absence in raw does not mean the guardrail is wrong (earlier sessions may have been deleted). Tag and flag for manual review.

**Rule 3: Superseded orphans**

1. Find `[superseded]` sections in `.knowledge/knowledge/decisions.md`.
2. Check each for a "Superseded by:" line or `→` reference.
3. If missing: append `[superseded-orphan]` to the heading.
4. Output: `"Lint Rule 3: Superseded decision '{topic}' has no replacement reference — tagged [superseded-orphan]."`

**Output format:**

```text
## Stage 3: Knowledge Lint
- Rule 1 (conflicting active): {N} checked / {M} issues
- Rule 2 (unverified guardrails): {N} checked / {M} issues
- Rule 3 (superseded orphans): {N} checked / {M} issues
```

If any issues were found, list each warning message after the summary.
If no issues: output `"Stage 3 lint passed — no issues found."`
