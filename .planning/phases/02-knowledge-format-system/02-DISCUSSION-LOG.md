# Phase 2: Knowledge Format System - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-04-07
**Mode:** Interactive (discuss)

---

## Areas Selected

모든 4개 영역 선택: 형식 지시 구체성, 분류 경계 정의, 마이그레이션 절차, 패치 파일 구조

---

## 형식 지시 구체성

**Q:** guardrails.md와 anti-patterns.md의 항목 형식을 패치에 어떻게 명시할까요?
- 예시 템플릿 포함 (권장) ← **선택**
- 구조 설명만 (필드 이름 + 의미)
- 요구사항 목록만 (최소한)

**Q:** 예시 템플릿은 어떤 수준으로 넣을까요?
- 단일 예시 1개씩
- 복수 예시 (2-3개) ← **선택**

**결정:** 유형별 복수 예시(2-3개) 인라인 포함

---

## 분류 경계 정의

**Q:** 컴파일러가 두 파일 간 분류를 어떻게 판단하도록 할까요?
- 명확한 판단 기준 제시 (권장) ← **선택**
- 컴파일러 자율 판단

**Q:** '대안이 하나로 확정 = guardrails, 상황에 따라 다름 = anti-patterns' 하나로 충분한가요?
- 하나로 충분 ← **선택**
- 추가 기준 필요

**결정:** 단일 기준("대안이 하나로 확정되는가")으로 분류

---

## 마이그레이션 절차

**Q:** 기존 anti-patterns.md 항목을 컴파일러가 어떻게 처리할까요?
- 자동 분류 + 이전 (권장) ← **선택**
- 그대로 유지 + 신규만 분류

**Q:** 마이그레이션 후 기존 anti-patterns.md는 어떻게 할까요?
- 컴파일러가 덮어쓰기 ← **선택**
- 남기고 개행선 추가

**결정:** 자동 분류·이전 + 덮어쓰기, researcher/verifier 동일 절차 적용

---

## 패치 파일 구조

**Q:** researcher와 verifier 패치에 형식 지시를 어떻게 배치할까요?
- 동일한 형식 지시 중복 작성 (권장) ← **선택**
- 공통 정의는 한쪽만, 다른 쪽은 참조

**Q:** researcher(incremental)와 verifier(full reconcile)의 마이그레이션 절차를 구분할까요?
- 동일한 절차 적용 ← **선택**
- incremental은 신규만, verifier만 전체 마이그레이션

**결정:** 두 패치 독립 중복 작성, 동일한 마이그레이션 절차

---

*Generated: 2026-04-07*
