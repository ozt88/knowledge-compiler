# Anti-Patterns

## raw/ 파일 직접 쿼리
[context: file-loading]

**관찰:** index.md를 거치지 않고 raw/*.md를 직접 읽어 분석
**이유:** 컨텍스트 비용이 높고 관련 없는 정보까지 로드됨
**대신:** index.md에서 관련 날짜 파악 후 해당 raw 파일만 선택적으로 읽기
**Observed:** 1 times (YYYY-MM-DD)

## 컴파일러 부정형 지시
[context: compile-logic, agent-behavior]

**관찰:** knowledge 파일 생성 지시에 "하지 마라" 형식 사용
**이유:** LLM은 부정형 지시 준수율이 낮아 원치 않는 패턴이 잔존
**대신:** 긍정형 액션으로 재기술
**Observed:** 1 times (YYYY-MM-DD)
