---
phase: 1
slug: compiler-prompt-refactor
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-04-07
---

# Phase 1 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | grep (shell) |
| **Config file** | none |
| **Quick run command** | `grep -n "하지 마라\|금지\|불필요\|제외할" patches/gsd-phase-researcher.patch.md patches/gsd-verifier.patch.md` |
| **Full suite command** | `grep -c "하지 마라\|금지\|불필요\|제외할" patches/gsd-phase-researcher.patch.md patches/gsd-verifier.patch.md` |
| **Estimated runtime** | ~1 second |

---

## Sampling Rate

- **After every task commit:** Run `grep -n "하지 마라\|금지\|불필요\|제외할" patches/gsd-phase-researcher.patch.md patches/gsd-verifier.patch.md`
- **After every plan wave:** Run `grep -c "하지 마라\|금지\|불필요\|제외할" patches/gsd-phase-researcher.patch.md patches/gsd-verifier.patch.md`
- **Before `/gsd:verify-work`:** Full suite must return 0 matches
- **Max feedback latency:** ~1 second

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 1-01-01 | 01 | 1 | COMPILE-01 | grep | `grep -c "하지 마라\|금지" patches/gsd-phase-researcher.patch.md` exits 0 | ✅ | ⬜ pending |
| 1-01-02 | 01 | 1 | COMPILE-02 | grep | `grep -c "하지 마라\|금지" patches/gsd-verifier.patch.md` exits 0 | ✅ | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

*Existing infrastructure covers all phase requirements — no test framework needed, grep validation only.*

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| 긍정형 표현이 자연스러운 한국어인지 확인 | COMPILE-01, COMPILE-02 | 언어 품질은 자동화 불가 | 각 Step 프롬프트를 읽고 지시가 긍정형("~를 포함하라", "~로 작성하라")인지 확인 |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 1s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
