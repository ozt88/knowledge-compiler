# Anti-Patterns

## raw/ 파일 직접 쿼리

**관찰:** index.md를 거치지 않고 raw/*.md를 직접 읽어 분석
**이유:** 컨텍스트 비용이 높고 관련 없는 정보까지 로드됨
**대신:** index.md에서 관련 날짜 파악 후 해당 raw 파일만 선택적으로 읽기

## 컴파일러 부정형 지시

**관찰:** knowledge 파일 생성 지시에 "하지 마라" 형식 사용
**이유:** LLM은 부정형 지시 준수율이 낮아 원치 않는 패턴이 잔존
**대신:** 긍정형 액션으로 재기술 (Phase 1 전환 원칙 적용)

## docs 커밋이 feat 변경사항 되돌리기

**관찰:** feat 커밋 이후 docs 커밋이 패치 파일을 feat 이전 상태로 교체
**이유:** stat에 패치 파일 변경이 표시되지 않아 revert 사실을 놓침
**대신:** docs 커밋 전 git cat-file로 패치 파일 blob hash 비교 또는 git diff 확인

## gsd-tools의 백로그 Phase 번호 인식 오류

**관찰:** Phase 999.1 존재 시 gsd-tools phase add가 999를 최대 정수로 카운트하여 1000 할당
**이유:** 소수점 앞자리(999)를 Phase 정수로 인식하는 버그
**대신:** 백로그 항목이 있는 상태에서 phase add 시 수동으로 Phase 번호 확인 및 수정

## install.sh workflow 패치 핸들러 스텁

**관찰:** install.sh의 new-project.md / new-milestone.md 핸들러가 info() 출력만 하고 실제 파일 삽입을 수행하지 않음
**이유:** patch_workflow() 함수 추가 시 기존 if-else 블록을 실제 호출로 교체하지 않음
**대신:** patch_workflow() 함수 신규 추가 시 기존 핸들러 블록을 실제 patch_workflow() 호출로 교체

## gap closure 실행 전 staged deletion 미확인

**관찰:** gap closure plan 실행 시 이전 세션의 git reset --soft가 남긴 staged deletions이 첫 커밋에 포함되어 구현 파일 전체 삭제 발생 (05-01, 05-02 두 번 반복)
**이유:** gap closure plan 시작 전 `git status` 확인 없이 바로 태스크 실행. staged deletions은 working tree에는 파일이 존재하지만 index에서만 삭제 표시됨
**대신:** gap closure plan 실행 전 반드시 `git status`로 staged 상태 확인. staged deletions 발견 시 `git restore --staged <files>`로 unstage 후 진행
