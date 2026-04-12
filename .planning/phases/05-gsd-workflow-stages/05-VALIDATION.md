---
phase: 5
slug: gsd-workflow-stages
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-04-12
---

# Phase 5 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | none — documentation phase, no automated tests |
| **Config file** | none |
| **Quick run command** | `ls .planning/phases/05-gsd-workflow-stages/*.md` |
| **Full suite command** | `ls .planning/phases/05-gsd-workflow-stages/*.md` |
| **Estimated runtime** | ~1 second |

---

## Sampling Rate

- **After every task commit:** Verify file exists with correct structure
- **After every plan wave:** Check all spec documents are complete
- **Before `/gsd-verify-work`:** All spec docs present and structurally valid
- **Max feedback latency:** 5 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 5-01-01 | 01 | 1 | SPEC | — | N/A | manual | `test -f docs/gsd-knowledge-workflow-spec.md` | ❌ W0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] No test framework installation needed — documentation-only phase

*Existing infrastructure covers all phase requirements.*

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Spec document completeness | D-13 | No automated doc quality check | Review each section covers all decisions (D-01 through D-12) |
| Stage activity map accuracy | D-08 through D-11 | Requires reading comprehension | Cross-check stage table against CONTEXT.md decisions |
| Compile trigger clarity | D-01 through D-04 | Requires human judgment | Verify spec is unambiguous for implementer |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 5s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
