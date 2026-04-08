---
phase: 4
slug: knowledge-importance-prioritization-scoring
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-04-09
---

# Phase 4 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | grep (text pattern matching — 마크다운 패치 파일 편집 프로젝트) |
| **Config file** | none — 별도 테스트 프레임워크 없음 |
| **Quick run command** | `grep -c "선별 기준\|포함하는 항목" patches/gsd-phase-researcher.patch.md` |
| **Full suite command** | `bash -c 'grep -c "선별 기준" patches/gsd-phase-researcher.patch.md && grep -c "선별 기준" patches/gsd-verifier.patch.md && grep -c "index.md" patches/gsd-phase-researcher.patch.md'` |
| **Estimated runtime** | ~1 second |

---

## Sampling Rate

- **After every task commit:** Run quick grep verification
- **After every plan wave:** Run full suite command
- **Before `/gsd:verify-work`:** Full suite must pass (all grep counts > 0)
- **Max feedback latency:** ~1 second

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | Status |
|---------|------|------|-------------|-----------|-------------------|--------|
| 04-01-01 | 01 | 1 | RELEVANCE-01 | grep | `grep -c "포함하는 항목\|건너뛰기" patches/gsd-phase-researcher.patch.md` | ⬜ pending |
| 04-01-02 | 01 | 1 | RELEVANCE-02 | grep | `grep -c "Quick Reference\|주제.*파일\|파일 안내" patches/gsd-phase-researcher.patch.md` | ⬜ pending |
| 04-01-03 | 01 | 1 | RELEVANCE-03 | grep | `grep -c "index.md.*먼저\|index.md 경유\|index-first" patches/gsd-phase-researcher.patch.md` | ⬜ pending |
| 04-01-04 | 01 | 2 | RELEVANCE-04 | diff | `diff <(grep -A10 "선별 기준" patches/gsd-phase-researcher.patch.md) <(grep -A10 "선별 기준" patches/gsd-verifier.patch.md)` | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

없음 — 기존 grep 검증 인프라가 Phase 요구사항을 커버함. 별도 테스트 파일 설치 불필요.

*"Existing infrastructure covers all phase requirements."*

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| 수집 타입 힌트 실제 효과 확인 | RELEVANCE-01 보완 | 실제 컴파일 실행 전 검증 불가 | 패치 적용(install.sh) → `/gsd:plan-phase` 실행 → RESEARCH.md Step 0 컴파일 결과 확인 |
| index.md 쿼리 안내 실효성 | RELEVANCE-02 보완 | LLM 행동 관찰 필요 | 컴파일 후 knowledge/index.md 내용이 "주제→파일 매핑" 형식인지 수동 확인 |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 2s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
