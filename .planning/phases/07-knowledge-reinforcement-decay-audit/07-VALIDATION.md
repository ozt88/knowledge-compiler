---
phase: 7
slug: knowledge-reinforcement-decay-audit
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-04-14
---

# Phase 7 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | bash script (grep 기반 검증) |
| **Config file** | 없음 — Wave 0에서 테스트 raw 항목 생성 |
| **Quick run command** | `grep -c "Observed" .knowledge/knowledge/decisions.md` |
| **Full suite command** | `grep -c "Observed" .knowledge/knowledge/decisions.md && grep "\[conflict:" .knowledge/knowledge/decisions.md; echo "RESEARCH.md exists: $(test -f .planning/phases/07-knowledge-reinforcement-decay-audit/07-RESEARCH.md && echo YES || echo NO)"` |
| **Estimated runtime** | ~5 seconds |

---

## Sampling Rate

- **After every task commit:** Run `grep -c "Observed" .knowledge/knowledge/decisions.md`
- **After every plan wave:** Run full suite command
- **Before `/gsd-verify-work`:** Full suite must be green
- **Max feedback latency:** 10 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 7-01-01 | 01 | 1 | D-03 (Before snapshot) | — | decisions.md baseline 기록 | smoke | `wc -l .knowledge/knowledge/decisions.md` | ✅ | ⬜ pending |
| 7-01-02 | 01 | 1 | D-03 (테스트 raw 추가) | — | 테스트 항목이 2026-04-14.md에 추가됨 | smoke | `grep "index-first" .knowledge/raw/2026-04-14.md` | ✅ W0 | ⬜ pending |
| 7-01-03 | 01 | 2 | D-03 (컴파일 실행) | — | /gsd-knowledge-compile 실행 후 decisions.md 변경 | smoke | `grep "Observed" .knowledge/knowledge/decisions.md` | ✅ | ⬜ pending |
| 7-01-04 | 01 | 2 | D-03 (Observed 증가 확인) | — | Observed 카운터가 Before 대비 증가 | smoke | `grep -c "Observed" .knowledge/knowledge/decisions.md` | ✅ | ⬜ pending |
| 7-01-05 | 01 | 3 | D-03 (conflict 감지 확인) | — | conflict 태그 추가 여부 확인 | smoke | `grep "\[conflict:" .knowledge/knowledge/decisions.md` | ✅ | ⬜ pending |
| 7-02-01 | 02 | 4 | D-02 (감쇄 갭 문서화) | — | 감쇄 메커니즘 갭 분석 RESEARCH.md에 포함 | manual | `grep "감쇄" .planning/phases/07-knowledge-reinforcement-decay-audit/07-RESEARCH.md` | ✅ | ⬜ pending |
| 7-02-02 | 02 | 4 | D-04 (권고안 확정) | — | RESEARCH.md에 최종 권고안 섹션 포함 | manual | `grep "최종 권고안" .planning/phases/07-knowledge-reinforcement-decay-audit/07-RESEARCH.md` | ✅ | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `.knowledge/raw/2026-04-14.md` — 테스트 raw 항목 추가 (index-first 재확인용 + conflict 감지용)

*기존 인프라(decisions.md, SKILL.md, /gsd-knowledge-compile)는 모두 존재함.*

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Observed 카운터 증가 (before/after 비교) | D-03 reinforcement | 수치 변화는 grep 가능하나 내용 해석 필요 | 시뮬레이션 전 decisions.md snapshot 기록 → 컴파일 후 변경 항목 확인 |
| conflict 태그 추가 여부 | D-03 conflict | conflict 위치의 의미론적 정확성 확인 필요 | 테스트 항목 추가 후 컴파일 → decisions.md에서 [conflict:] 태그 위치 및 내용 확인 |
| 권고안 품질 검토 | D-04 report | 권고 내용의 타당성은 사람 검토 필요 | RESEARCH.md 최종 권고안 섹션 읽기 — 충돌 기반 권고/시간 기반 비권고 근거 확인 |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 10s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
