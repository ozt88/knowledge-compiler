<!-- PATCH:knowledge-compiler for gsd-phase-researcher.md -->
<!-- Insert BEFORE: "## Step 1: Receive Scope and Load Context" -->

## Step 0: Knowledge Compile (before research)

<!-- PATCH:knowledge-compiler — reapply after GSD updates -->

Before researching, check if the project has accumulated knowledge from previous sessions.

**Skip condition:** If `.knowledge/raw/` does not exist or is empty, skip to Step 1.

**If raw/ has content:**

1. Read `.knowledge/knowledge/index.md` and extract the `Last compiled` date (YYYY-MM-DD format).
   - If index.md does not exist or has no "Last compiled" line, treat as first compile (process ALL raw files).
2. List `.knowledge/raw/*.md` files. Filter to only files with filename date >= the "Last compiled" date.
   - Filename pattern: `YYYY-MM-DD.md`. Compare the date portion with "Last compiled" date.
   - **If no files are newer than "Last compiled" date: skip Step 0 entirely** (log "No new raw entries since {date}, skipping compile").
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
7. Merge new entries into existing knowledge files using the rules below. Then **call Write tool for every file that changed** — do NOT output compiled content as text only. A Step 0 that produces no Write calls is incomplete.

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

8. Write `index.md` using the Write tool: set `Last compiled` to today's date (YYYY-MM-DD), update `Total entries` count.

**Step 0 completion gate:** Confirm at least one Write tool call was made to `.knowledge/knowledge/`. If no files were written (e.g., all entries were duplicates), log "Step 0: no new knowledge entries — skipping write" and proceed to Step 1.

**During research (Step 3):** knowledge/ lookup order:
- `decisions.md` — Check [rejected] entries and choose an alternative approach
- `anti-patterns.md` — Review the list and prioritize proven patterns in research recommendations
- `troubleshooting.md` — Check already-solved problems and focus on new unresolved issues

**Lookup order:** Read index.md first to identify files relevant to the current phase, then selectively Read only those files.
