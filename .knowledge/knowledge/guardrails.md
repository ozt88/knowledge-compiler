# Guardrails

## raw/ 읽기
[context: file-loading]

raw/ 읽기는 knowledge/index.md 경유 필수 — index.md로 관련 날짜 파악 후 해당 raw 파일만 선택적으로 Read한다.

## decisions.md 병합
[context: knowledge-format]

decisions.md는 decisions/ 하위 파일 병합 방식이 아닌 단일 파일 직접 업데이트 방식 사용.

## D-08 핵심 블록 동일성
[context: install-deploy, compile-logic]

researcher 패치와 verifier 패치의 선별 기준 블록, index.md 형식 블록은 글자 단위 동일하게 유지.
**[Phase 6 이후 적용 범위 변경]** verifier 패치가 삭제됨 — researcher 패치 단독 유지. 선별 기준 블록 동일성 원칙은 향후 새 패치 추가 시 적용.

## index.md 형식
[context: knowledge-format]

index.md는 Quick Reference 테이블(주제|파일|핵심 항목) + Last compiled 메타 + 키워드 인덱스 형식으로 생성. 에이전트가 index.md 하나만 읽어도 관련 파일로 이동 가능하게 구성.

## guardrails.md 기술 형식
[context: knowledge-format]

guardrails.md는 대안이 하나로 확정되는 케이스를 긍정형 액션("~경유 필수", "~방식 사용")으로 기술. 형식: "## [주제]\n[긍정형 액션]"

## 컴파일러 지시 부정형 금지
[context: compile-logic, agent-behavior]

컴파일러 프롬프트는 긍정형 지시만 포함. "~하지 마라" 형식은 LLM 준수율이 낮으므로 긍정형 액션으로 재기술.

## git push 사용자 승인
[context: agent-behavior]

git push는 bypassMode가 아닌 경우 항상 사용자 명시적 승인 후 실행한다.

## ROADMAP-PLAN 동기화
[context: agent-behavior]

Phase plan이 ROADMAP 목표에서 벗어나는 방향으로 변경될 경우 ROADMAP.md를 동시에 업데이트한다 — 사후 불일치 검증 실패 방지.

## Knowledge raw 수집 — per-turn CLAUDE.md 방식
[context: compile-logic]

Knowledge raw 수집은 CLAUDE.md per-turn 지시로 수행한다 (`응답할 때마다 .knowledge/raw/YYYY-MM-DD.md에 append`). /gsd-knowledge-compile은 raw → knowledge/ 컴파일 전용. Step 0 subagent JSONL 파싱 없음.

## templates/claude-md-section.md 동기화
[context: install-deploy]

CLAUDE.md의 Knowledge Compiler 섹션 내용을 변경할 경우 templates/claude-md-section.md도 동일하게 업데이트한다 — install.sh --force 재배포 시 stale 내용으로 덮어쓰기 방지.

## Knowledge Compiler 전역 CLAUDE.md 적용
[context: install-deploy]

`~/.claude/CLAUDE.md`의 Knowledge Compiler 섹션은 전역 적용이므로 개별 프로젝트 CLAUDE.md에 중복 추가 불필요. 프로젝트 설치는 `.knowledge/raw/` + `.knowledge/knowledge/` 디렉토리 생성으로 완료.

## decisions.md 제목 변경 시 index.md 동시 갱신
[context: knowledge-format]

decisions.md 항목 제목을 변경할 경우 `index.md` 키워드 인덱스의 fragment ID도 즉시 동시에 업데이트한다 — 제목 변경과 index.md 갱신은 단일 커밋으로 처리.

## install.sh 실행 후 PATCH count 즉시 확인
[context: install-deploy]

install.sh 실행(--force 포함) 후 즉시 `grep -c "PATCH:knowledge-compiler" <file>` 로 각 대상 파일 count를 확인한다. 기대값: researcher=1, planner=1, verifier=0, discuss=1. count가 기대값과 다르면 Python 수동 제거 후 재시도.

## knowledge seed 파일 — universal meta-knowledge 전용
[context: install-deploy, knowledge-format]

templates/knowledge-seed/ 파일에는 어느 프로젝트에나 적용되는 meta-knowledge만 포함한다. 이 repo 고유 지식(install.sh 버그, GSD Phase 번호, PATCH count 등)은 이 repo의 .knowledge/knowledge/ 에만 기록한다.
