---
phase: 6
slug: gsd-knowledge
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-04-12
---

# Phase 6 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | bash/grep (shell-level verification — no test framework needed) |
| **Config file** | none — grep-based spot checks |
| **Quick run command** | `grep -c "PATCH:knowledge-compiler" ~/.claude/agents/gsd-phase-researcher.md` |
| **Full suite command** | `bash -c 'for f in ~/.claude/agents/gsd-phase-researcher.md ~/.claude/agents/gsd-planner.md ~/.claude/agents/gsd-verifier.md ~/.claude/get-shit-done/workflows/discuss-phase.md; do echo "$f: $(grep -c "PATCH:knowledge-compiler" "$f" 2>/dev/null || echo 0)"; done'` |
| **Estimated runtime** | ~5 seconds |

---

## Sampling Rate

- **After every task commit:** Run quick grep check on modified install target
- **After every plan wave:** Run full suite (all 4 install targets)
- **Before `/gsd-verify-work`:** Full suite must show exactly 1 PATCH block per file
- **Max feedback latency:** 5 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 6-01-01 | 01 | 1 | D-18/D-19 | — | N/A | shell | `git log --oneline -5` | ✅ | ⬜ pending |
| 6-01-02 | 01 | 2 | D-16/D-17 | — | N/A | shell | `grep -c "PATCH:knowledge-compiler" ~/.claude/agents/gsd-phase-researcher.md` | ✅ | ⬜ pending |
| 6-01-03 | 01 | 2 | D-16/D-17 | — | N/A | shell | `grep -c "PATCH:knowledge-compiler" ~/.claude/agents/gsd-planner.md` | ✅ | ⬜ pending |
| 6-01-04 | 01 | 2 | D-16/D-17 | — | N/A | shell | `grep -c "PATCH:knowledge-compiler" ~/.claude/agents/gsd-verifier.md` | ✅ | ⬜ pending |
| 6-01-05 | 01 | 2 | D-16/D-17 | — | N/A | shell | `grep -l "PATCH:knowledge-compiler" ~/.claude/get-shit-done/workflows/discuss-phase.md` | ✅ | ⬜ pending |
| 6-01-06 | 01 | 3 | D-21 | — | N/A | shell | `git log --oneline -3` | ✅ | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

Existing infrastructure covers all phase requirements. This phase uses shell/grep verification only — no test framework installation needed.

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| discuss-phase patch correctness | D-08 | Anchor fix requires reading workflow context | grep for knowledge lookup section after anchor correction |
| duplicate block removal visual check | D-16 | Count alone doesn't verify content quality | Read first 50 lines of each agent file after dedup |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 5s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
