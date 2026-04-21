# Pitfalls: Token Optimization (RTK) Installation

**Domain:** RTK v0.28+ added to existing Claude Code setup with GSD workflow hooks
**Researched:** 2026-04-21
**Overall confidence:** HIGH (verified against RTK source code + live settings.json inspection)

---

## Critical Pitfalls (must prevent)

### Pitfall C1: crates.io Name Collision — Installing the Wrong Binary

**What goes wrong:** `cargo install rtk` installs "Rust Type Kit" (reachingforthejack/rtk), a completely different CLI for querying Rust types and generating FFI bindings. Running `rtk gain` will fail with an unrecognized command.

**Why it happens:** Another crate named `rtk` was published to crates.io before RTK (Rust Token Killer). The RTK README explicitly warns about this but users attempting the standard `cargo install` flow hit it anyway.

**Consequences:** Silent installation of wrong binary. `rtk init -g` may still run but does nothing useful. Hook is installed but `rtk rewrite` inside the hook shell script fails silently (the hook guards against missing `rtk` with `if ! command -v rtk &>/dev/null; exit 0`), meaning the hook exists but provides zero savings.

**Prevention:**
- Use `cargo install --git https://github.com/rtk-ai/rtk` (correct)
- Or use `curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh` (correct)
- Or `brew install rtk` on macOS (correct)
- Verify immediately after install: `rtk gain` should print token savings stats, not an error

**Detection:** After install, run `rtk --version` — should output `rtk 0.28.x` or higher with RTK branding, not type-kit output.

---

### Pitfall C2: Telemetry Opt-In During Interactive `rtk init`

**What goes wrong:** `rtk init -g` prompts interactively for telemetry consent. If the operator answers "y" or presses Enter while distracted, telemetry is enabled. Telemetry sends a daily HTTPS POST containing command usage counts, token savings estimates, OS/arch, and top command names to `rtk-ai.app` servers outside corporate control.

**Why it happens:** RTK's telemetry is opt-in by default (GDPR-compliant), but the interactive prompt during init makes it easy to accidentally consent. The prompt reads to stderr, and in fast setup flows it can be overlooked.

**What is collected (if opted in):** Anonymous device hash (SHA-256 of random local salt), OS, arch, version, commands-per-day count, top 5 command names (e.g. "git", "cargo"), token savings figures, ecosystem distribution, `hook_type: "claude"`. Does NOT collect file contents, paths, arguments, or secrets.

**Corporate compliance risk:** Even though data is anonymized, any outbound network call to a third-party SaaS from a developer workstation may require security review under corporate data governance policies. The `hook_type: "claude"` field reveals that the team uses Claude Code internally.

**Prevention:**
1. During `rtk init -g` — answer `n` to the telemetry prompt
2. Immediately after any init: `rtk telemetry disable`
3. Verify: `rtk telemetry status` must show disabled
4. Alternatively, set env var permanently: `export RTK_TELEMETRY_DISABLED=1` in `~/.bashrc` or `~/.zshrc` — this blocks telemetry regardless of consent state and survives reinstall

**Detection:** `rtk telemetry status` shows current state. Check `~/.local/share/rtk/.device_salt` — if it exists, telemetry infrastructure has been initialized (disable and run `rtk telemetry forget` to clean up local DB at `~/.local/share/rtk/tracking.db`).

---

### Pitfall C3: Hook Appended to PreToolUse Array Conflicts with GSD Hooks

**What goes wrong:** `rtk init -g` appends a new `{"matcher": "Bash", "hooks": [...]}` entry to the `hooks.PreToolUse` array in `~/.claude/settings.json`. The current setup already has an existing `PreToolUse` entry:

```json
"PreToolUse": [
  {
    "matcher": "Write|Edit",
    "hooks": [{"type": "command", "command": "node .../gsd-prompt-guard.js"}]
  },
  {
    "matcher": "Write|Edit",
    "hooks": [{"type": "command", "command": "node .../gsd-read-guard.js"}]
  },
  {
    "matcher": "Write|Edit",
    "hooks": [{"type": "command", "command": "node .../gsd-workflow-guard.js"}]
  },
  {
    "matcher": "Bash",
    "hooks": [{"type": "command", "command": "bash .../gsd-validate-commit.sh"}]
  }
]
```

RTK adds a fifth entry with `"matcher": "Bash"`. Claude Code runs ALL matching hooks for each tool call. For Bash tool calls, both `gsd-validate-commit.sh` AND the RTK hook will run.

**Why this is usually safe:** Claude Code's hook system runs all matching hooks sequentially. The RTK hook exits 0 (pass-through) for non-rewriteable commands and emits a JSON `permissionDecision: "allow"` with a modified command for rewriteable ones. The existing `gsd-validate-commit.sh` runs a separate validation. These operate independently.

**Where it can break:**
- If `gsd-validate-commit.sh` exits non-zero (blocking a Bash call), the RTK hook rewrite may not apply — order matters
- If the RTK hook emits `permissionDecision: "allow"` with a rewritten command, subsequent hooks in the same array still run against the already-approved action (behavior not fully documented)
- If `jq` is not installed, the RTK hook exits 0 silently (its guard: `if ! command -v jq &>/dev/null; exit 0`) — no rewrite, no error

**Prevention:**
- Manually review the settings.json after `rtk init -g` to confirm the new entry did not corrupt existing structure
- RTK creates a `.json.bak` backup before patching — verify backup exists at `~/.claude/settings.json.bak`
- Test existing GSD hooks still fire correctly after RTK install: trigger a commit validation scenario
- Ensure `jq` is installed: `which jq`

**Detection:** After install, run `git status` from within Claude Code — should produce compact RTK output. Run a GSD workflow (e.g., `gsd:execute-phase`) to confirm guards still fire.

---

## Hook Conflicts

### Pitfall H1: `rtk init -g` with `--auto-patch` Skips the Backup Prompt

**What goes wrong:** Using `--auto-patch` flag (non-interactive CI mode) skips the user consent prompt for patching settings.json. It still creates a backup, but the operator has no chance to review what will be changed.

**Prevention:** Always run `rtk init -g` interactively (without `--auto-patch`) on a personal development machine. Use `--auto-patch` only in CI/CD provisioning scripts where the settings.json is freshly generated.

---

### Pitfall H2: Multiple `"matcher": "Bash"` Entries — Execution Order Uncertainty

**What goes wrong:** With RTK installed, there are now two `"matcher": "Bash"` entries in `PreToolUse`. The Claude Code docs do not explicitly specify whether hooks within the same event run in array order, and whether an earlier hook's `permissionDecision` short-circuits later hooks.

**Why it matters here:** The existing `gsd-validate-commit.sh` runs FIRST (it was added first). If it outputs a block decision for a git commit command, the RTK hook may or may not still run. Conversely, if RTK rewrites `git commit -m "..."` to `rtk git commit -m "..."`, the commit validator may need to handle the `rtk` prefix.

**Prevention:**
- The RTK hook guards commit commands with exit 0 pass-through (RTK rewrites `git commit` to `rtk git commit`, which is still recognizable)
- Test the combined stack: run a git commit through Claude Code and verify both RTK compression AND gsd-validate-commit fire correctly
- If `gsd-validate-commit.sh` parses the raw command string, it may need to handle the `rtk git commit` prefix post-rewrite

---

### Pitfall H3: RTK Hook Placed AFTER GSD Hook — Order Not Guaranteed

**What goes wrong:** RTK's `insert_hook_entry` appends to the end of the `PreToolUse` array. The GSD `"matcher": "Bash"` hook (`gsd-validate-commit.sh`) runs first. If a future GSD hook update uses `permissionDecision: "block"` for certain Bash commands that RTK would have rewritten, RTK never gets to rewrite them.

**Prevention:** This is currently benign because `gsd-validate-commit.sh` only blocks invalid commit patterns, not general Bash commands. Monitor for GSD updates that add broader Bash blocking.

---

## Telemetry / Compliance Risks

### Pitfall T1: Telemetry Opt-In Survives Binary Updates

**What goes wrong:** If telemetry was accidentally enabled during initial setup, updating RTK via `cargo install --git` or Homebrew does NOT reset consent state. The local `~/.local/share/rtk/.device_salt` and SQLite database persist across upgrades.

**Prevention:** After any RTK upgrade, run `rtk telemetry status` to confirm state. Use `RTK_TELEMETRY_DISABLED=1` env var as belt-and-suspenders — it blocks telemetry regardless of stored consent and is not affected by upgrades.

---

### Pitfall T2: Telemetry Endpoint is Compile-Time Injected — Cannot Audit from Binary

**What goes wrong:** The telemetry endpoint URL and auth token are injected at compile time via Rust's `option_env!()`. This means you cannot inspect the official release binary to see where data is sent. If building from source with `cargo install --git`, the build process fetches the secret from the RTK CI environment — your local build will have `RTK_TELEMETRY_URL` unset, making the telemetry code dead. But pre-built binaries from releases may have the live endpoint compiled in.

**Implication:** Pre-built binaries (from install.sh or Homebrew) WILL phone home if telemetry is enabled. Self-compiled binaries (from `cargo install --git`) will NOT phone home regardless of consent state because the endpoint is missing.

**Prevention for corporate compliance:**
- Prefer `cargo install --git` over pre-built binaries if data governance requires zero network calls
- Or set `RTK_TELEMETRY_DISABLED=1` in environment — overrides compiled-in endpoint

---

### Pitfall T3: Local SQLite Tracking DB Contains Usage History

**What goes wrong:** Even with telemetry disabled, RTK maintains a local SQLite database at `~/.local/share/rtk/tracking.db` storing command usage history for the `rtk gain` analytics feature. This database retains 90 days of command history by default and contains: timestamp, command names, token savings counts.

**Corporate compliance note:** The local DB does not transmit data externally when telemetry is disabled. However, it does record which CLI commands Claude Code executed, which may be sensitive in certain audit environments.

**Prevention:** If local command logging is also a concern, configure `tracking.history_days = 0` in `~/.config/rtk/config.toml`, or skip RTK's tracking entirely (this also disables `rtk gain` analytics). For cleanup: `rtk telemetry forget` deletes the local DB.

---

## Output Quality Risks

### Pitfall Q1: RTK Only Intercepts Bash Tool — Built-in Tools Bypass Compression

**What goes wrong:** The RTK PreToolUse hook fires only for the `Bash` tool. Claude Code's built-in `Read`, `Grep`, and `Glob` tools bypass the hook entirely. This means:
- When Claude uses `Read` to read a large file → full uncompressed content reaches context
- When Claude uses `Grep` to search → full match output reaches context
- The 60-90% savings claim assumes Claude uses shell commands (`cat`, `grep`, `find`) rather than built-in tools

**Why it matters for knowledge-compiler:** GSD agents (researcher, verifier, planner) are instructed to use Read/Grep/Glob over shell equivalents per CLAUDE.md global conventions. RTK will provide zero savings for these built-in tool calls.

**Prevention:**
- Understand that RTK savings only apply to Bash tool calls
- Do not disable Read/Grep/Glob usage in GSD agents just to route through RTK — the built-in tools are faster and safer
- Set realistic expectations: actual savings in a knowledge-compiler session will be lower than 60-90% benchmark (which assumes heavy `cat`/`grep`/`find` Bash usage)
- Consider whether `rtk discover` (which identifies missed opportunities) helps identify where to use Bash instead of built-ins

---

### Pitfall Q2: Aggressive Compression Hides Information Claude Needs

**What goes wrong:** RTK's filters truncate, deduplicate, and strip content before Claude sees it. For error diagnosis, the compressed output may omit context needed to understand the root cause. Example: `cargo test` in "failures only" mode hides intermediate output that may contain the setup step that caused the failure.

**How RTK mitigates this:** When a command fails, RTK saves the full unfiltered output to `~/.local/share/rtk/tee/` and includes the path in the compressed output. Claude can then read the full log. However, this requires Claude to know to check the tee file, and adds a round-trip.

**Prevention:**
- For debugging phases, Claude can use `rtk <command> -v` (verbose) or bypass RTK entirely with the raw command
- The `tee.mode = "failures"` default in `~/.config/rtk/config.toml` is correct — keep it
- Configure `exclude_commands` in config to skip RTK for commands where full output is always needed (e.g., `exclude_commands = ["claude"]`)

---

### Pitfall Q3: Hook Rewrite of `&&` Chains Requires All Parts to Use `rtk` Prefix

**What goes wrong:** In command chains like `git add . && git commit -m "msg" && git push`, RTK only rewrites the first recognized command. Subsequent parts of a chain remain uncompressed. The RTK documentation states that ALL parts of a chain should use the `rtk` prefix, but the auto-rewrite hook only rewrites the whole command string if it matches at the start.

**Prevention:** For chained git commands in Claude Code sessions, prefer separate tool calls over `&&` chains. This also improves observability and allows intermediate inspection.

---

### Pitfall Q4: `rtk rewrite` Silently Passes Through Unknown Commands

**What goes wrong:** For any command RTK doesn't recognize, it exits with code 1 (no rewrite), and the hook passes through unchanged. This is correct behavior, but it creates a false sense of coverage: operators may assume all Bash commands are being optimized when many are passing through untouched.

**Prevention:** Use `rtk discover` after 7 days of use to identify top Bash commands that RTK is not rewriting. This reveals real savings opportunities vs. current baselines.

---

## Installation Method Risks

### Pitfall I1: Using install.sh Pipe-to-Shell in Corporate Environment

**What goes wrong:** `curl -fsSL ... | sh` is a one-liner that executes remote code. In corporate environments with security scanning or network proxies, this may be blocked or flagged.

**Prevention:** Use pre-built binary download with signature verification (check RTK releases for checksums), or build from source via `cargo install --git` which goes through standard Cargo dependency resolution and is auditable.

---

### Pitfall I2: PATH Not Updated After `~/.local/bin` Install

**What goes wrong:** The install.sh script installs to `~/.local/bin`, which may not be in `$PATH` for non-interactive shells. When Claude Code invokes Bash (non-interactive), the RTK binary may not be found. The hook guards against this (`if ! command -v rtk &>/dev/null; exit 0`) — it silently passes through, providing zero savings without any error.

**Prevention:**
- Verify `echo $PATH` includes `~/.local/bin`
- Add to `~/.bashrc` AND `~/.bash_profile`: `export PATH="$HOME/.local/bin:$PATH"`
- Test from a fresh shell: `rtk --version`
- After Claude Code restart, run a git command and verify RTK compression is applied

---

## Phase-Specific Warnings

| Phase Topic | Likely Pitfall | Mitigation |
|-------------|----------------|------------|
| Installation | C1: Wrong crates.io binary | Use `--git` install, verify with `rtk gain` |
| Init prompt | C2: Accidental telemetry opt-in | Answer 'n', then run `rtk telemetry disable` |
| settings.json patch | C3: Hook conflicts with GSD | Review `.json.bak`, test GSD guards still fire |
| Corporate compliance | T1+T2: Telemetry state unclear | Set `RTK_TELEMETRY_DISABLED=1` as env var |
| Local data audit | T3: Tracking DB exists | Set `tracking.history_days` or `rtk telemetry forget` |
| Savings expectations | Q1: Built-in tools bypass hook | Set realistic expectations, do not replace Read/Grep/Glob |
| Debug sessions | Q2: Compressed output hides details | Use `-v` flag or raw commands when diagnosing |
| PATH in non-interactive shells | I2: RTK not found silently | Verify PATH in `~/.bashrc`, test from Claude session |

---

## Prevention Checklist

Install sequence that avoids all critical pitfalls:

```bash
# Step 1: Install from correct source (NOT cargo install rtk)
cargo install --git https://github.com/rtk-ai/rtk
# or: curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh

# Step 2: Verify correct binary
rtk gain   # Must print token savings stats, not an error

# Step 3: Ensure PATH for non-interactive shells
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc

# Step 4: Run init INTERACTIVELY — answer 'n' to telemetry prompt
rtk init -g

# Step 5: Disable telemetry explicitly, regardless of init answer
rtk telemetry disable
rtk telemetry status   # Must show: disabled

# Step 6: Set env var as belt-and-suspenders
echo 'export RTK_TELEMETRY_DISABLED=1' >> ~/.bashrc

# Step 7: Verify settings.json backup exists and structure is valid
ls ~/.claude/settings.json.bak
python3 -c "import json; json.load(open('$HOME/.claude/settings.json'))" && echo "JSON valid"

# Step 8: Restart Claude Code and verify RTK hook fires
# In Claude session: git status  -> should produce compact RTK output

# Step 9: Verify existing GSD hooks still fire
# Trigger a GSD workflow and confirm guards activate normally
```

---

## Sources

- RTK source code: `src/hooks/init.rs` — `insert_hook_entry()`, `patch_settings_json_command()` (HIGH confidence)
- RTK docs: `docs/TELEMETRY.md` — full telemetry field list, consent model (HIGH confidence)
- RTK README.md — name collision warning, Bash-only hook limitation, built-in tool caveat (HIGH confidence)
- Live `~/.claude/settings.json` inspection — existing GSD hooks structure (HIGH confidence)
- RTK hook script: `.claude/hooks/rtk-rewrite.sh` — exit code protocol, jq dependency (HIGH confidence)
- crates.io API: confirmed `rtk` = "Rust Type Kit" by reachingforthejack (HIGH confidence)
