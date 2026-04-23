---
phase: 9
slug: install-secure
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-04-23
---

# Phase 9 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | bash (shell assertions — no framework) |
| **Config file** | none |
| **Quick run command** | `rtk gain` |
| **Full suite command** | `rtk gain && rtk telemetry status && grep RTK_TELEMETRY_DISABLED ~/.bashrc && cat ~/.claude/settings.json | jq '.hooks.PreToolUse[] | select(.command | contains("rtk"))'` |
| **Estimated runtime** | ~5 seconds |

---

## Sampling Rate

- **After every task commit:** Run `rtk gain`
- **After every plan wave:** Run full suite command
- **Before `/gsd-verify-work`:** Full suite must be green
- **Max feedback latency:** 10 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 9-01-01 | 01 | 1 | INSTALL-01 | — | rtk 바이너리 존재 | shell | `which rtk && rtk gain` | ✅ | ⬜ pending |
| 9-01-02 | 01 | 1 | INSTALL-02 | — | PreToolUse hook 등록 | shell | `cat ~/.claude/settings.json | jq '.hooks.PreToolUse'` | ✅ | ⬜ pending |
| 9-02-01 | 02 | 1 | SEC-01 | — | ~/.bashrc에 RTK_TELEMETRY_DISABLED=1 존재 | shell | `grep RTK_TELEMETRY_DISABLED ~/.bashrc` | ✅ | ⬜ pending |
| 9-02-02 | 02 | 1 | SEC-02 | — | rtk telemetry status disabled 반환 | shell | `rtk telemetry status` | ✅ | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

*Existing infrastructure covers all phase requirements. Shell assertions are direct CLI commands.*

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| 새 셸 세션에서 RTK_TELEMETRY_DISABLED 적용 확인 | SEC-01 | 새 bash 프로세스 실행 필요 | `bash -c 'echo $RTK_TELEMETRY_DISABLED'`가 1 반환하는지 확인 |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 10s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
