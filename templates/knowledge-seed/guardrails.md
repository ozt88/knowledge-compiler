# Guardrails

## raw/ 읽기
[context: file-loading]

raw/ 읽기는 knowledge/index.md 경유 필수 — index.md로 관련 날짜 파악 후 해당 raw 파일만 선택적으로 Read한다.

## decisions.md 병합
[context: knowledge-format]

decisions.md는 단일 파일 직접 업데이트 방식 사용 — 하위 디렉토리 분산 방식 사용 금지.

## index.md 형식
[context: knowledge-format]

index.md는 Quick Reference 테이블(주제|파일|핵심 항목) + Last compiled 메타 + 키워드 인덱스 형식으로 생성. 에이전트가 index.md 하나만 읽어도 관련 파일로 이동 가능하게 구성.

## guardrails.md 기술 형식
[context: knowledge-format]

guardrails.md는 대안이 하나로 확정되는 케이스를 긍정형 액션("~경유 필수", "~방식 사용")으로 기술. 형식: "## [주제]\n[context: ...]\n[긍정형 액션]"

## 컴파일러 지시 부정형 금지
[context: compile-logic, agent-behavior]

컴파일러 프롬프트는 긍정형 지시만 포함. "~하지 마라" 형식은 LLM 준수율이 낮으므로 긍정형 액션으로 재기술.

## Knowledge raw 수집 — per-turn CLAUDE.md 방식
[context: compile-logic]

Knowledge raw 수집은 CLAUDE.md per-turn 지시로 수행한다. /gsd-knowledge-compile은 raw → knowledge/ 컴파일 전용.

## Knowledge Compiler 전역 CLAUDE.md 적용
[context: install-deploy]

~/.claude/CLAUDE.md의 Knowledge Compiler 섹션은 전역 적용이므로 개별 프로젝트 CLAUDE.md에 중복 추가 불필요. 프로젝트 설치는 .knowledge/raw/ + .knowledge/knowledge/ 디렉토리 생성으로 완료.

## decisions.md 제목 변경 시 index.md 동시 갱신
[context: knowledge-format]

decisions.md 항목 제목을 변경할 경우 index.md 키워드 인덱스의 fragment ID도 즉시 동시에 업데이트한다 — 제목 변경과 index.md 갱신은 단일 커밋으로 처리.
