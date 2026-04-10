# 지식 컴파일러 설계 문서

> Phase 05 포스트모템에서 도출된 GSD 워크플로 확장 설계.
> 2026-04-05 세션에서 논의 완료, MVP 구현 완료.

---

## 1. 풀려는 문제

GSD로 탐색적 작업 중 반복 발생한 문제:

### 1.1 문제의 세 겹

1. **프레임 불일치** — GSD는 "뭘 할지 아는 상태"(Plan→Execute)를 전제하지만, 인게임 검증은 "뭐가 틀렸는지 모르는 상태"에서 시작하는 탐색
2. **지식 유실** — 탐색 중 발생한 학습(시도→실패→결정)이 세션 종료와 함께 증발
3. **조회 불가** — 기록이 있어도 GSD sub-agent(planner, researcher)가 접근 불가 (memory는 메인 에이전트만 읽음)

### 1.2 실제 사례

| 루프 | 시도 | 결과 | 교훈 |
|------|------|------|------|
| 1 | sidecar format v2 사용 | translations_loaded=0 | v3 format 필요 |
| 2 | Python build script (v1 DB) | v1 번역 나옴 | Go go-v2-export 필요 |
| 3 | ReplacePlainText (문자 단위 태그 매핑) | 색깔 번짐, 태그 노출 | 한/영 길이 차이로 원천 불가 |
| 4 | TryTranslateCore 먼저 실행 | 이미 번역된 텍스트 재처리 | ContainsKorean 우선 체크 필요 |

4번의 피드백 루프가 모두 기록 없이 ad-hoc으로 진행됨.

---

## 2. 해법 탐색 경로

```
MCP 벡터DB (mcp-memory-service, knowledgegraph-mcp)
    ↓ 검토: 시맨틱 검색은 좋으나 추가 인프라 부담
Karpathy "LLM Knowledge Bases" 인사이트
    ↓ 전환: "개인 규모에서는 마크다운 + 인덱스면 충분"
파일시스템 기반 지식 컴파일러 (최종 방향)
```

### 왜 MCP 서버가 아닌가
- GSD 서브에이전트는 이미 Read/Grep/Glob 사용 → 추가 MCP 도구 불필요
- 벡터DB 설치/유지보수 부담
- 마크다운 파일이 사람도 읽을 수 있음
- `.knowledge/` 내 배치로 프로젝트 구조에 자연 통합

### 왜 Claude 내장 memory가 아닌가
- memory는 메인 에이전트만 접근 (서브에이전트 불가)
- MEMORY.md 200줄 제한
- 키워드 매칭만 지원 (파일명/description 기반)

---

## 3. 지식 컴파일러 설계

### 3.1 핵심 원칙

1. **수집과 판단을 분리** — 저장 시점에 "이게 중요한가?" 묻지 않음
2. **관측과 정책을 분리** — "뭘 봤는가"(observation)와 "뭘 결정했는가"(decision)는 다른 계층
3. **컴파일러는 GSD 외부 도구** — 작업 실행과 지식 빌드를 분리
4. **사람은 직접 안 쓰되 승격/검토는 함** — LLM이 작성, 사람이 승인
5. **planner는 원본이 아니라 brief를 받음** — 전체 knowledge가 아니라 Phase 맞춤 요약

### 3.2 파이프라인

```
[1.수집] → [2.컴파일] → [3.린트] → [4.브리핑] → [5.조회]
 raw/       knowledge/    자가검증    planning     planner가
 턴 단위     주기적 변환    무결성확인  brief 생성   brief를 제약
 자동 저장                                        조건으로 사용
```

### 3.3 각 단계 상세

#### Stage 1: 수집 (raw/)

**단위:** 턴 (유저 메시지 → Claude 작업 → 응답 완료 = 1턴)

**메커니즘 테스트 결과 (2026-04-05):**

| Hook 타입 | 발동 | 파일 쓰기 | 턴 컨텍스트 접근 | 요약 생성 |
|-----------|------|----------|----------------|----------|
| `command` | ✅ | ✅ (bash로 직접) | ❌ (환경변수/stdin 없음) | ❌ |
| `prompt`  | ✅ | ❌ (도구 없음) | ✅ (transcript 참조 확인) | ❌ (검증/게이트 모드) |

**채택된 방식: CLAUDE.md 행동 지시**
- CLAUDE.md에 "매 응답 마지막에 `.knowledge/raw/{YYYY-MM-DD}.md`에 턴 요약 append" 지시
- 장점: 컨텍스트 접근 O, 파일 쓰기 O, 추가 인프라 불필요
- 단점: 에이전트가 가끔 빼먹을 수 있음 (MVP 허용 범위)

#### Stage 2: 컴파일 (raw/ → knowledge/)

LLM이 raw를 읽고 구조화된 지식 파일로 변환.

**knowledge/ 파일 구조:**

| 파일 | 내용 |
|------|------|
| `index.md` | 전체 요약 + 키워드 인덱스 |
| `decisions.md` | 시도 → 결과 → 결정 (상태 태그 포함) |
| `anti-patterns.md` | 맥락 의존형 접근법 (Observation-Reason-Instead 형식) |
| `troubleshooting.md` | 에러 메시지 ↔ 해결책 매핑 |
| `guardrails.md` | 대안이 단일 선택으로 고정된 경우 — 긍정형 행동 지시 |

**Decision 상태 태그:**
- `[active]` — 현재 유효한 결정
- `[rejected]` — 시도했으나 기각된 접근
- `[superseded]` — 새 결정으로 대체됨
- `[uncertain]` — 검증 필요한 가설

**컴파일 트리거:**
- Phase 시작 직전: gsd-phase-researcher Step 0 (incremental)
- Phase 검증 완료: gsd-verifier Step 10b (incremental)

#### Stage 3: 린트

v1.1 구현 완료. Step 10b(컴파일) 직후 Step 10c로 실행.

**Skip condition:** `.knowledge/knowledge/` 디렉토리가 없으면 전체 skip.

**규칙:**

| Rule | 검사 대상 | 조건 | 조치 |
|------|-----------|------|------|
| 1 | `decisions.md` | 충돌하는 `[active]` decision 쌍 | `[conflict: YYYY-MM-DD]` 마킹 |
| 2 | `guardrails.md` | raw/ 출처 없는 guardrail | `[unverified]` 태그 |
| 3 | `decisions.md` | `[superseded]` 대체 참조 없음 | `[superseded-orphan]` 마킹 |

#### Stage 4: 브리핑 (이후 확장)

Phase 시작 시 해당 Phase와 관련된 지식만 뽑아서 brief 생성.
brief는 "참고 문서"가 아니라 **planning guardrail** — MUST/MUST NOT이 planner 행동을 제약.

#### Stage 5: 조회

- planner/researcher는 knowledge/를 직접 참조 (MVP)
- 상세 근거 필요 시 knowledge/ 원본 직접 Read/Grep
- 모든 접근은 파일시스템 읽기만으로 동작

---

## 4. 구현 순서

### MVP (완료)
1. **raw/ 수집** — CLAUDE.md 행동 지시
2. **자동 컴파일** — researcher Step 0 (incremental) + verifier Step 10b (incremental)
3. **knowledge/ → planner 연동** — researcher가 knowledge/ 참조

### 이후 확장
4. planning brief 자동 생성
5. ~~lint 단계~~ ✓ (v1.1 Step 10c — MVP로 승격)
6. Exploration Phase 타입 도입
7. 점진적 컴파일 최적화

---

## 5. 관찰 포인트 (v3 진입 조건)

1. CLAUDE.md 행동 지시 수집의 안정성 — 빼먹기 빈도가 낮은지
2. knowledge/ 참조 효과 — planner가 실제로 과거 실수를 회피하는지
3. (v1.1 결과) CLAUDE.md 행동 지시 방식 채택 확정 — 수집 누락률 허용 범위 내
4. (v1.1 결과) knowledge/ 참조로 researcher가 과거 결정을 활용하는 것 확인
