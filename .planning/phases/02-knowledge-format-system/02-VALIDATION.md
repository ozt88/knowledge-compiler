---
phase: 2
slug: knowledge-format-system
status: draft
nyquist_compliant: true
wave_0_complete: true
created: 2026-04-07
---

# Phase 2 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | none — prompt text verification (grep/read) |
| **Config file** | none |
| **Quick run command** | `grep -E "(guardrails\.md\|anti-patterns\.md)" patches/gsd-phase-researcher.patch.md patches/gsd-verifier.patch.md` |
| **Full suite command** | `grep -c "guardrails" patches/gsd-phase-researcher.patch.md patches/gsd-verifier.patch.md && grep -c "관찰" patches/gsd-phase-researcher.patch.md patches/gsd-verifier.patch.md` |
| **Estimated runtime** | ~2 seconds |

---

## Sampling Rate

- **After every task commit:** Run `grep -E "(guardrails\.md|anti-patterns\.md)" patches/gsd-phase-researcher.patch.md patches/gsd-verifier.patch.md`
- **After every plan wave:** Run full grep suite
- **Before `/gsd:verify-work`:** All grep checks must pass
- **Max feedback latency:** 5 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 2-01-01 | 01 | 1 | COMPILE-03, COMPILE-04, COMPILE-05 | grep | `grep -c "guardrails.md" patches/gsd-phase-researcher.patch.md && grep "긍정형\|경유 필수\|방식 사용" patches/gsd-phase-researcher.patch.md && grep "관찰-이유-대신\|맥락 의존" patches/gsd-phase-researcher.patch.md` | ✅ | ⬜ pending |
| 2-01-02 | 01 | 1 | COMPILE-03, COMPILE-04, COMPILE-05 | grep | `grep -c "guardrails.md" patches/gsd-verifier.patch.md && grep "긍정형\|경유 필수\|방식 사용" patches/gsd-verifier.patch.md && grep "관찰-이유-대신\|맥락 의존" patches/gsd-verifier.patch.md` | ✅ | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

*Existing infrastructure covers all phase requirements — text patch files exist, grep verification is immediate.*

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| guardrails.md 예시 소재의 도메인 적합성 | COMPILE-04 | 자연어 품질 판단 | 패치 파일의 guardrails.md 예시 섹션을 읽고 knowledge-compiler 도메인 예시인지 확인 |
| anti-patterns.md 예시의 관찰-이유-대신 구조 | COMPILE-05 | 자연어 구조 판단 | 패치 파일의 anti-patterns.md 예시 섹션을 읽고 관찰/이유/대신 세 항목이 모두 존재하는지 확인 |

---

## Validation Sign-Off

- [x] All tasks have `<automated>` verify or Wave 0 dependencies
- [x] Sampling continuity: no 3 consecutive tasks without automated verify
- [x] Wave 0 covers all MISSING references
- [x] No watch-mode flags
- [x] Feedback latency < 5s
- [x] `nyquist_compliant: true` set in frontmatter

**Approval:** approved
