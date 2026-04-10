# Guardrails

## raw/ 읽기

raw/ 읽기는 knowledge/index.md 경유 필수 — index.md로 관련 날짜 파악 후 해당 raw 파일만 선택적으로 Read한다.

## decisions.md 병합

decisions.md는 decisions/ 하위 파일 병합 방식이 아닌 단일 파일 직접 업데이트 방식 사용.

## D-08 핵심 블록 동일성

researcher 패치와 verifier 패치의 선별 기준 블록, index.md 형식 블록은 글자 단위 동일하게 유지.

## index.md 형식

index.md는 Quick Reference 테이블(주제|파일|핵심 항목) + Last compiled 메타 + 키워드 인덱스 형식으로 생성. 에이전트가 index.md 하나만 읽어도 관련 파일로 이동 가능하게 구성.

## guardrails.md 기술 형식

guardrails.md는 대안이 하나로 확정되는 케이스를 긍정형 액션("~경유 필수", "~방식 사용")으로 기술. 형식: "## [주제]\n[긍정형 액션]"

## 컴파일러 지시 부정형 금지

컴파일러 프롬프트는 긍정형 지시만 포함. "~하지 마라" 형식은 LLM 준수율이 낮으므로 긍정형 액션으로 재기술.
