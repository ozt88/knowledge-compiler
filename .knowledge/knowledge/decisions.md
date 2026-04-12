# Decisions

## 설계 결정 — guardrails.md + anti-patterns.md 이중 구조

**시도:** guardrails.md와 anti-patterns.md를 단일 파일로 유지
**결과:** 절대적 케이스와 맥락 의존적 케이스의 분류가 모호해짐
**결정:** 두 파일 분리 유지 — guardrails.md(절대적/대안 확정 케이스를 긍정형 액션), anti-patterns.md(맥락 의존적 케이스를 관찰-이유-대신)
**상태:** [active]

## 설계 결정 — index-first 접근 표준화

**시도:** 에이전트가 knowledge/ 전체를 순차 로드
**결과:** 컨텍스트 비용이 높고 관련 없는 정보까지 로드됨
**결정:** index.md를 먼저 읽어 관련 파일만 선택적으로 Read하는 index-first 접근 표준화 (RELEVANCE-03)
**상태:** [active]

## 설계 결정 — 컴파일 타임 선별 기준 도입

**시도:** raw 항목을 모두 동등하게 knowledge에 포함
**결과:** 일회성 확인 작업과 중요한 결정이 같은 가중치로 저장됨
**결정:** 컴파일러 지시에 선별 기준 추가 — 미래 세션 가치 있는 결정/발견만 포함, 일회성 확인·단순 탐색·중복은 건너뜀 (RELEVANCE-01)
**상태:** [active]

## 설계 결정 — D-08 패턴 (researcher/verifier 핵심 블록 동일성)

**시도:** researcher와 verifier 패치에 각각 별도 형식 지시 작성
**결과:** 두 파일 간 선별 기준이 달라져 컴파일 일관성이 깨질 위험
**결정:** 핵심 형식 지시 블록(선별 기준, index.md 형식)은 두 패치에서 글자 단위 동일하게 유지. troubleshooting/index 설명은 각 파일 고유 표현 허용 (D-08)
**상태:** [active]

## 설계 결정 — 쿼리 시점 관련성 모델 선택

**시도:** BM25/TF-IDF/벡터 임베딩 기반 사전 스코어링 고려
**결과:** D-05(벡터 임베딩 Out of Scope), D-03(저장 시점 수동 마킹 금지) 위반
**결정:** 쿼리 시점 관련성 판별 — 컴파일 타임 선별 기준 + 구조적 index.md + index-first 접근 조합으로 달성
**상태:** [active]

## 설계 결정 — Phase 4 요구사항 (RELEVANCE 시리즈)

**시도:** Phase 3까지 COMPILE/COLLECT 요구사항만 존재
**결과:** 지식 중요도 우선순위 메커니즘 부재
**결정:** RELEVANCE-01~04 4개 요구사항을 Phase 4에 매핑하여 추가
**상태:** [active]

## 설계 결정 — PageIndex 연동 Backlog 처리

**시도:** PageIndex(Vectorless RAG) 즉시 연동 고려
**결과:** 지식이 아직 충분히 축적되지 않아 효과 미미, 추가 인프라 부담
**결정:** Phase 999.1(Backlog)으로 등록 — v1.x 이후 지식 충분히 쌓인 뒤 검토
**상태:** [active]

## 설계 결정 — install.sh --force 옵션 추가

**시도:** install.sh patch_agent()가 PATCH 마커 존재 시 무조건 skip
**결과:** Phase 2 이후 패치 내용이 에이전트 파일에 미반영되는 버그 발생
**결정:** install.sh에 --force 옵션 추가하여 마커 있어도 최신 패치 내용으로 교체 가능하게 수정
**상태:** [active]

## 설계 결정 — Phase 5 spec-only → implementation 전환 후 ROADMAP 동기화
**Observed:** 2 times (2026-04-12, 2026-04-12)

**시도:** Phase 5를 "명세 문서 작성(spec-only)" 단계로 계획
**결과:** 사용자 요청으로 spec 문서 생성을 건너뛰고 패치/스킬 직접 구현으로 전환. ROADMAP이 즉시 업데이트되지 않아 검증 단계에서 5개 갭 발생(ROADMAP-PLAN 불일치)
**결정:** 갭 클로저 플랜(05-02-PLAN.md)으로 ROADMAP.md Phase 5 Goal/SCs/plan entry 및 REQUIREMENTS.md WORKFLOW-01~07을 실제 구현에 맞게 정렬하여 해소. 이후 ROADMAP-PLAN 동기화는 guardrails로 강제.
**상태:** [active]

## 설계 결정 — researcher compile 제거, /gsd-clear primary 트리거

**시도:** researcher Step 0에서 compile 수행
**결과:** researcher 역할(리서치)과 compile 역할 혼재
**결정:** researcher는 compile 없이 Step 3 lookup만 수행. /gsd-clear(세션 종료 시)와 planner fallback(이전 세션 compile 누락 시)이 compile 담당
**상태:** [active]

## 설계 결정 — 갭 클로저 플랜 패턴 (implementation 후 docs 정렬)

**시도:** implementation plan 실행 후 ROADMAP이 자동으로 업데이트되기를 기대
**결과:** 검증 단계에서 ROADMAP-PLAN 불일치 갭 발견 — 별도 갭 클로저 플랜 필요
**결정:** implementation 완료 후 docs가 현실과 달라진 경우 별도 gap-closure plan(--gaps 플래그)으로 문서 정렬. 이는 일반 실행 플랜과 달리 문서만 수정하는 패턴.
**상태:** [active]
