# Features Research: Token Optimization

**Domain:** CLI-level token optimization tools for Claude Code
**Researched:** 2026-04-21
**Constraint:** No data leaving client (corporate security)

---

## Comparison Matrix

| Tool | Mechanism | Token Savings | Telemetry Default | Client-Only | Claude Code Support |
|------|-----------|--------------|-------------------|-------------|---------------------|
| **RTK** | CLI proxy — bash hook rewrites commands transparently | 60–90% per session (80% avg) | OFF — explicit opt-in required (GDPR Art.6/7) | YES — Rust binary, local only | YES — `rtk init -g` (PreToolUse hook) |
| **LLMLingua** | ML-based token classification via small LLM (GPT2/LLaMA) | Up to 20x (semantic compression) | None (library) | YES — runs locally but requires torch + GPU/CPU | NO — Python library, must be wired manually |
| **ccusage** | Local JSONL log analyzer — does NOT reduce tokens | N/A (analytics only) | None — local files only | YES — reads `~/.claude` JSONL | YES — analytics/monitoring, not optimization |
| **Custom hooks** | Claude Code PreToolUse hook + bash script | Depends on implementation | None (self-built) | YES — fully controlled | YES — native hook system |
| **Prompt caching** | Anthropic API-level cache for repeated context | 90% cost on cache hits (read cost) | N/A (API feature) | NO — API-side, data leaves client | YES — automatic in Claude Code |

**RTK repo:** 31,058 stars, active (updated 2026-04-21), MIT license
**ccusage repo:** 13,114 stars, analytics only (no token reduction)
**LLMLingua repo:** 6,047 stars, research/RAG focus (not CLI dev workflow)

---

## Table Stakes (must-have)

These features are non-negotiable for a corporate environment with a no-data-exfiltration constraint.

| Feature | Why Required | Complexity | Notes |
|---------|-------------|------------|-------|
| **Client-side only processing** | Corporate security — no code/paths/args sent externally | Low | Eliminates prompt caching (API-side), LLMLingua cloud demo |
| **Telemetry fully disableable** | Security policy compliance | Low | RTK: `RTK_TELEMETRY_DISABLED=1` env var or `rtk telemetry disable` |
| **Zero data collection by default** | Opt-in only model | Low | RTK telemetry is OFF by default — requires explicit consent |
| **Transparent hook integration** | LLM must not need to change behavior | Low | RTK PreToolUse hook rewrites commands before Claude sees output |
| **Bash tool coverage** | Must cover git, ls, grep, test runners (core dev workflow) | Low | RTK covers 100+ commands across all major ecosystems |
| **No external runtime dependencies** | Air-gap/offline capability, security review simplicity | Low | RTK: single Rust binary, zero deps. LLMLingua: requires torch, transformers |
| **Token savings analytics** | Verify ROI without sending data out | Low | RTK `gain` command — local SQLite only |

---

## Differentiators

Features that add value beyond the baseline. Nice-to-have for this milestone.

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| **Auto-rewrite hook (100% coverage)** | Zero manual effort — every bash call gets optimized; subagents covered automatically | Low | RTK installs `.claude/settings.json` PreToolUse hook |
| **Per-command savings breakdown** | Identify highest-impact commands for tuning | Low | `rtk gain --history`, `rtk discover` |
| **Failure tee mode** | If compressed output causes LLM confusion, full output saved locally for re-read without re-execution | Medium | RTK `~/.config/rtk/config.toml` tee.mode setting |
| **Custom TOML filters** | Project-specific compression rules | Medium | RTK supports user-defined filter DSL |
| **`rtk discover`** | Surface missed savings opportunities — commands passing through without compression | Low | Useful for tuning after install |
| **Ultra-compact mode** | Extra savings via ASCII icons and inline format | Low | `rtk --ultra-compact` global flag |
| **`rtk session` / adoption stats** | Track RTK coverage across conversations | Low | Diagnose sessions where hook wasn't active |

---

## Anti-Features (things to avoid)

| Anti-Feature | Why Avoid | What to Do Instead |
|--------------|-----------|-------------------|
| **LLMLingua for CLI dev workflow** | Requires Python, torch, and a local LLM model (~7B params). Compresses semantic content (RAG/CoT), not structured CLI output. Overkill and fragile for git/test/ls output. | Use RTK — purpose-built for CLI output compression |
| **Prompt caching as primary strategy** | API-side — context data leaves client. Also: doesn't reduce output volume, only amortizes repeated context reads. Incompatible with corporate no-exfiltration policy. | RTK for output compression; prompt caching is a separate (API-level) concern |
| **ccusage for optimization** | ccusage is analytics only — reads local JSONL logs to report past usage. Does not reduce tokens in-flight. Useful as a measurement tool, not an optimizer. | Use ccusage only for post-hoc measurement; use RTK for active reduction |
| **Custom hand-rolled hooks** | Building per-command bash output filters from scratch duplicates RTK's 100+ command coverage. High maintenance burden, no community support. | Adopt RTK; add custom TOML filters for project-specific needs only |
| **Telemetry-on-by-default tools** | Any tool that sends usage data externally (even anonymized) without explicit opt-in is a corporate security risk in regulated environments | RTK with `RTK_TELEMETRY_DISABLED=1` env var set in shell profile |
| **Read/Grep/Glob hook coverage expectation** | RTK hooks only intercept Bash tool calls. Claude Code's built-in Read, Grep, Glob tools bypass the hook entirely — do not assume 100% coverage | Document this scope gap clearly; use `rtk read`/`rtk grep` explicitly when needed |

---

## Recommendation

**Select RTK.** Rationale:

1. **Security fit**: Telemetry is OFF by default + `RTK_TELEMETRY_DISABLED=1` env var provides belt-and-suspenders enforcement. No code, paths, or arguments ever sent externally. Confirmed in TELEMETRY.md.

2. **Zero friction integration**: Single command (`rtk init -g`) installs a Claude Code PreToolUse bash hook that transparently rewrites commands. Claude never sees the rewrite.

3. **Coverage breadth**: 100+ commands covering git, file ops, test runners (jest/pytest/cargo test/go test), linters, docker, kubernetes, AWS CLI, package managers. A custom hook would need years to match this.

4. **Proven savings**: 80% average token reduction in 30-min sessions. Independently verifiable with `rtk gain` (local only).

5. **Single binary**: No Python, no torch, no GPU, no model download. `curl | sh` + `rtk init -g` + restart Claude Code.

**Key scope caveat for implementation:** RTK hooks cover only Bash tool calls. The Claude Code built-in `Read`, `Grep`, and `Glob` tools bypass the hook. When full coverage is needed, use `rtk read`/`rtk grep`/`rtk find` via Bash explicitly.

**Telemetry enforcement for corporate deploy:**
```bash
# Add to ~/.bashrc or ~/.zshrc (or mise env)
export RTK_TELEMETRY_DISABLED=1
```
This env var blocks all telemetry regardless of any consent state — strongest available control.

**ccusage role:** Install as a companion measurement tool (`npx ccusage@latest`) to verify actual token/cost savings from local JSONL logs. Reads only local files, no network calls required for Claude models with `--offline` flag.

---

## Sources

- RTK README (HIGH confidence): `https://github.com/rtk-ai/rtk` — 31k stars, MIT, updated 2026-04-21
- RTK TELEMETRY.md (HIGH confidence): confirmed opt-in model, `RTK_TELEMETRY_DISABLED=1` override
- RTK DISCLAIMER.md (HIGH confidence): "disabled by default, requires explicit opt-in consent"
- LLMLingua setup.py (HIGH confidence): requires `torch`, `transformers`, `accelerate` — local LLM inference
- ccusage README (HIGH confidence): 13k stars, analytics/monitoring only, local JSONL reader
- Claude Code repo (HIGH confidence): v2.1.116, hooks are PreToolUse bash interception
