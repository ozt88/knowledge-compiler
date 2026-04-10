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
5. After reading existing knowledge files, add new entries or update existing entries to merge them

**During research (Step 3):** knowledge/ lookup order:
- `decisions.md` — Check [rejected] entries and choose an alternative approach
- `anti-patterns.md` — Review the list and prioritize proven patterns in research recommendations
- `troubleshooting.md` — Check already-solved problems and focus on new unresolved issues

**Lookup order:** Read index.md first to identify files relevant to the current phase, then selectively Read only those files.
