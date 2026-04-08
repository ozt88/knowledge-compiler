# Phase 3: Collection Instruction Refactor - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-04-08
**Phase:** 03-collection-instruction-refactor
**Areas discussed:** 긍정형 전환 방식, 동기화 방향, 규칙 5번 처리

---

## 긍정형 전환 방식

| Option | Description | Selected |
|--------|-------------|----------|
| 규칙 3에 흡수 | 규칙 3 '포함할 것' 리스트를 세밀화하여 범위를 자연스럽게 한정. 규칙 4 삭제 | ✓ |
| 독립 규칙 유지, 표현 바꾸기 | 규칙 4 자리를 '요약에는 행동과 핵심 판단만 담는다' 형식으로 유지 | |
| 예시로만 범위 전달 | 규칙 4 삭제, 예시를 확장하여 포함/미포함 범위 전달 | |

**User's choice:** 규칙 3에 흡수
**Notes:** 규칙 3의 항목들을 더 구체적으로 서술하면 자연스럽게 범위가 한정됨. 별도 부정형 규칙 불필요.

---

## 동기화 방향

| Option | Description | Selected |
|--------|-------------|----------|
| template이 canonical | template 먼저 수정 → CLAUDE.md 수동 동기화. install.sh 방식과 일관성 | ✓ |
| CLAUDE.md가 canonical | CLAUDE.md 먼저 수정 → template 나중에 동기화 | |
| 동등하게 동시 수정 | 두 파일 동시 수정. 나중에 분리될 위험 있음 | |

**User's choice:** template이 canonical
**Notes:** install.sh가 이미 patch 방식으로 CLAUDE.md에 적용하는 구조이므로 일관성 유지.

---

## 규칙 5번 처리

| Option | Description | Selected |
|--------|-------------|----------|
| COLLECT-01 범위만 (규칙 4만) | 규칙 5는 조건 지시이며 부정형 패턴이 아님. 범위 밖. | ✓ |
| 규칙 5도 긍정형으로 | '사용자가 수집 중지를 요청하면 있음한다' 형태로 전환 | |

**User's choice:** COLLECT-01 범위만 (규칙 4만)
**Notes:** COLLECT-01 요구사항이 "포함하지 않을 것" 항목만을 명시적으로 대상으로 함.

---

## Claude's Discretion

- 규칙 3의 구체적인 항목 표현 방식 (동사, 형용사 선택)

## Deferred Ideas

- 규칙 5 긍정형 전환 — 별도 Phase 필요 시
- template → CLAUDE.md 자동 동기화 메커니즘 — v1.1 범위 초과
