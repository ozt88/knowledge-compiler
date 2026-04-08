# Phase 4: Knowledge Importance Prioritization Scoring - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-04-09
**Phase:** 04-knowledge-importance-prioritization-scoring
**Areas discussed:** Phase 범위 및 출력물, 중요도 판별 주체, 중요도 표현 방식, Downstream 활용 방식, 성공 기준 (UAT)

---

## Phase 범위 및 출력물

| Option | Description | Selected |
|--------|-------------|----------|
| 탐색 + ADR 작성 | 메커니즘 설계 탐색 후 결정 문서 작성으로 종료 — 구현은 Phase 5에서 | |
| 탐색 + 구현까지 | 1개 Phase에서 설계-구현 모두 완료 | ✓ |
| 실험 프로토타입만 | 작동하는 일부 구현 후 효과 확인 | |

**User's choice:** 탐색 + 구현까지 (1 Phase 완결)

---

## "우선순위를 매긴다"의 의미 탐색

**User's response (free text):** "동작을 기대하기보다는 문제의식에 가까워. raw에는 매 요청과 응답이 쌓이는데 그것을 어떻게 지식화하는지에 따라서 성능의 차이가 심할것 같아"

**Notes:** 구체적 동작 명세보다 문제의식에서 출발. raw 항목의 지식화 방식이 downstream 성능에 영향을 준다는 핵심 통찰.

---

## raw 항목 문제 유형

| Option | Description | Selected |
|--------|-------------|----------|
| 하찮은 공계 잡동사니 | 재현 가치 없는 수준의 항목 | |
| 복잡한 작업도 같은 수준으로 관리됨 | 중요한 작업이 일상어 수준 항목과 동등 처리 | |
| 오래된 항목을 외울 필요성 | 컴파일 시 오래된 내용 검토 안 함 | |
| 다어쓰다 (모두 상당한 문제) | | ✓ |

**User's choice:** 세 가지 모두 상당한 문제

---

## 중요도 판별 주체

| Option | Description | Selected |
|--------|-------------|----------|
| 컴파일러(LLM)가 자동 판단 | researcher/verifier가 raw 항목 컴파일 시 LLM이 중요도 평가 | |
| 수집 시 주체(CLAUDE)가 직접 마킹 | raw에 쓸 때마다 Claude가 스스로 중요도 표시 | |
| 규칙 기반 자동화 | 특정 키워드/파일 변경/결정 키워드 존재 시 중요 마킹 규칙 | |
| 하이브리드 | raw에 힌트 제공 + 컴파일러가 최종 판단 | |

**User's response (free text):** "다른 프로젝트들이 차용한 좋은 방법 리서치를 좀 하면 좋겠는데"

**Notes:** 판별 주체 결정 전 RAG/IR 분야 선행 연구 탐색 요청. Phase 내 리서치 단계가 핵심.

---

## 리서치 대상 분야

| Option | Description | Selected |
|--------|-------------|----------|
| AI 메모리 시스템 (MemGPT, Mem0 등) | LLM 메모리 관리 프레임워크의 중요도/세분화 접근방식 | |
| Note-taking PKM 시스템 (Obsidian, Logseq 등) | Spaced Repetition, 중요도 플래그, 링크 기반 중요도 등 | |
| RAG / Information Retrieval 연구 | 문서 중요도 스코어링, 재순위, MMR(최대 다양성) 등 | ✓ |
| 특정 시스템 없이, 실용적 접근만 | 오버엔지니어링 없이 실제 문제에 맞는 미니멀 접근 식별 | |

**User's choice:** RAG / Information Retrieval 연구

---

## 중요도 표현 방식 (저장 위치)

| Option | Description | Selected |
|--------|-------------|----------|
| raw 파일 내 인라인 마킹 | raw 한줄 제목에 태그 추가 (e.g. [HIGH]) | |
| knowledge 파일 안에서 세분화 | 컴파일 시 중요 항목은 별도 섹션/표시로 구분 | |
| 별도 인덱스 파일 (importance-index.md) | knowledge 항목과 중요도 점수를 매핑하는 별도 파일 | |
| 클로즈에 맡김 (눈에 띄도록 설계하고 결정) | RAG/IR 리서치 후 가장 적합한 방식으로 결정 | |

**User's response (free text):** "중요도는 지식을 쿼리하는 시점에 결정될것 같은데. 내가 찾는 지식에 유의미한 정보를 제공할 수 있는 방법이 필요해"

**Notes:** 사전 스코어링이 아닌 쿼리 시점 관련성 모델 선호. 핵심 철학 전환.

---

## Downstream 활용 방식 (Agent 쿼리 경험)

| Option | Description | Selected |
|--------|-------------|----------|
| 지금처럼 Read/Grep로 직접 접근 | 다만 knowledge 구조가 잘 잡혀서 에이전트가 스스로 중요한 것을 찾는다 | |
| index.md가 '지금 여기 관련성이 높은 항목'을 모아 안내 | 컴파일 시마다 index.md가 업데이트되어 Agent가 으의 파일로 주제를 좌함하면 관련 캐네시아를 파악 | |
| 쿼리 기반 제공 (리서치 후 결정 — 권장) | RAG/IR 연구를 살펴보고 가장 맞는 접근 방식을 선택한다 (벡터 없는 소박한 접근이 우선) | ✓ |

**User's choice:** 쿼리 기반 제공 — 리서치 후 결정

---

## 성공 기준 (UAT)

| Option | Description | Selected |
|--------|-------------|----------|
| researcher agent가 구동할 수 있는 데모 | researcher가 knowledge에 쿼리하여 관련 항목만 돌려주는 실제 동작 확인 | |
| 리서치 문서 + 설계 ADR + 구현 코드 | 세 가지 산출물이 존재하면 완료 | |
| raw로부터 중요 항목을 분류할 수 있는 구체적 테스트 케이스 | 특정 raw 항목 입력 시 시스템이 해당 항목을 '중요'로 식별하는지 확인 | |
| 구체적 성공 기준은 리서치 후 결정 | RAG/IR 연구를 본 뒤에야 측정 가능한 기준 정의 가능 | ✓ |

**User's choice:** 구체적 성공 기준은 리서치 후 결정

---

## Claude's Discretion

- RAG/IR 연구 중 발견한 접근법 중 파일시스템 제약에 맞지 않는 것 제외 여부
- 구현 세부 방식 (파일 구조, 메타데이터 형식 등) — 리서치 결과 기반 결정

## Deferred Ideas

- 사람이 직접 쿼리하는 시나리오 — 1차 대상 아님
- PageIndex 연동 — Backlog Phase 999.1
- 구체적 성공 기준 — 리서치 후 정의
