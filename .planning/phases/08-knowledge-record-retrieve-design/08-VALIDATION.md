---
phase: 8
slug: knowledge-record-retrieve-design
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-04-15
---

# Phase 8 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | bash script (grep 기반) + 컴파일 시뮬레이션 |
| **Config file** | 없음 — Wave 0에서 context 태그 형식 템플릿 확정 |
| **Quick run command** | `grep -c "\[context:" .knowledge/knowledge/decisions.md` |
| **Full suite command** | 아래 Wave 3 시뮬레이션 전체 (시뮬레이션 로그 확인) |
| **Estimated runtime** | ~30 seconds (컴파일 포함) |

---

## Sampling Rate

- **After every task commit:** Run `grep -c "\[context:" .knowledge/knowledge/decisions.md`
- **After every plan wave:** Run full suite command
- **Before `/gsd-verify-work`:** Full suite must be green
- **Max feedback latency:** 30 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 8-01-01 | 01 | 0 | context 태그 형식 확정 | — | 형식 템플릿이 CONTEXT.md에 기록됨 | manual | `grep "context:" .planning/phases/08-*/08-CONTEXT.md` | ✅ | ⬜ pending |
| 8-01-02 | 01 | 1 | decisions.md context 태그 추가 | — | 모든 15개 항목에 `[context: ...]` 존재 | smoke | `grep -c "\[context:" .knowledge/knowledge/decisions.md` | ✅ | ⬜ pending |
| 8-01-03 | 01 | 1 | index.md 동기화 | — | index.md Quick Reference 테이블이 context 태그 반영 | smoke | `grep "context" .knowledge/knowledge/index.md` | ✅ | ⬜ pending |
| 8-02-01 | 02 | 2 | SKILL.md uncertain 전환 추가 | T-08-02-01 | 반대 결론 처리 규칙에 `[uncertain]` 상태 전환 포함 | smoke | `grep "uncertain" skills/gsd-knowledge-compile/SKILL.md` | ✅ | ⬜ pending |
| 8-02-02 | 02 | 2 | 패치 파일 uncertain 지침 추가 | — | planner/researcher 패치에 `[uncertain]` 처리 지침 존재 | smoke | `grep "uncertain" patches/gsd-planner.patch.md patches/gsd-phase-researcher.patch.md` | ✅ | ⬜ pending |
| 8-02-03 | 02 | 2 | install.sh 재배포 | T-08-02-03 | PATCH count researcher=1, planner=1 | smoke | `bash install.sh && grep -c "PATCH:knowledge-compiler" ~/.claude/get-shit-done/patches/gsd-phase-researcher.patch.md` | ✅ | ⬜ pending |
| 8-03-01 | 03 | 3 | B+C fusion 시뮬레이션 (Observed) | — | Observed 카운터 증가 확인 | smoke | `grep -c "Observed" .knowledge/knowledge/decisions.md` | ✅ | ⬜ pending |
| 8-03-02 | 03 | 3 | B+C fusion 시뮬레이션 (conflict→uncertain) | — | `[uncertain]` 상태 전환 확인 | smoke | `grep "\[uncertain\]" .knowledge/knowledge/decisions.md` | ✅ | ⬜ pending |
| 8-03-03 | 03 | 3 | 조회 필터링 검증 | — | `[superseded]` 항목 조회 제외 지침 패치에 존재 | smoke | `grep "superseded" patches/gsd-planner.patch.md` | ✅ | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] context 태그 분류 체계 6개 카테고리 확정 및 형식 템플릿 문서화

*기존 인프라(SKILL.md, decisions.md, 패치 파일, install.sh)는 모두 존재함.*

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| B+C fusion 동작 판정 | D-03 (Phase 7 이월) | 시뮬레이션 결과 내용 해석 필요 | 테스트 raw 항목 추가 → 컴파일 → decisions.md before/after 비교 |
| context 태그 분류 적절성 | D-01 | 의미론적 판단 필요 | 15개 항목의 태그가 실제 사용 패턴을 반영하는지 검토 |
| `[uncertain]` 항목 에이전트 처리 | D-04 | 패치 지침의 실효성 확인 필요 | planner/researcher가 `[uncertain]` 항목 발견 시 올바르게 경고하는지 테스트 세션 수행 |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 30s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
