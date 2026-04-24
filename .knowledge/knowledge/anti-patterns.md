# Anti-Patterns

## raw/ 파일 직접 쿼리
[context: file-loading]

**관찰:** index.md를 거치지 않고 raw/*.md를 직접 읽어 분석
**이유:** 컨텍스트 비용이 높고 관련 없는 정보까지 로드됨
**대신:** index.md에서 관련 날짜 파악 후 해당 raw 파일만 선택적으로 읽기
**Observed:** 1 times (2026-04-15)

## 컴파일러 부정형 지시
[context: compile-logic, agent-behavior]

**관찰:** knowledge 파일 생성 지시에 "하지 마라" 형식 사용
**이유:** LLM은 부정형 지시 준수율이 낮아 원치 않는 패턴이 잔존
**대신:** 긍정형 액션으로 재기술 (Phase 1 전환 원칙 적용)
**Observed:** 1 times (2026-04-15)

## docs 커밋이 feat 변경사항 되돌리기
[context: install-deploy]

**관찰:** feat 커밋 이후 docs 커밋이 패치 파일을 feat 이전 상태로 교체
**이유:** stat에 패치 파일 변경이 표시되지 않아 revert 사실을 놓침
**대신:** docs 커밋 전 git cat-file로 패치 파일 blob hash 비교 또는 git diff 확인
**Observed:** 1 times (2026-04-15)

## gsd-tools의 백로그 Phase 번호 인식 오류
[context: scope-backlog]

**관찰:** Phase 999.1 존재 시 gsd-tools phase add가 999를 최대 정수로 카운트하여 1000 할당
**이유:** 소수점 앞자리(999)를 Phase 정수로 인식하는 버그
**대신:** 백로그 항목이 있는 상태에서 phase add 시 수동으로 Phase 번호 확인 및 수정
**Observed:** 1 times (2026-04-15)

## install.sh workflow 패치 핸들러 스텁
[context: install-deploy]

**관찰:** install.sh의 new-project.md / new-milestone.md 핸들러가 info() 출력만 하고 실제 파일 삽입을 수행하지 않음
**이유:** patch_workflow() 함수 추가 시 기존 if-else 블록을 실제 호출로 교체하지 않음
**대신:** patch_workflow() 함수 신규 추가 시 기존 핸들러 블록을 실제 patch_workflow() 호출로 교체
**Observed:** 1 times (2026-04-15)

## Python PATCH 정리 후 install.sh --force 재실행
[context: install-deploy]

**관찰:** Python으로 PATCH 블록을 ×1로 정상화한 직후 `install.sh --force` 실행
**이유:** `--force`는 researcher/planner에 `unpatch_agent`를 호출 → awk가 `<!-- PATCH -->` 블록 처리 불가 → 제거 실패 후 재삽입 → ×2로 파괴. Python 작업 결과가 즉시 무효화됨
**대신:** Python 제거 후에는 `install.sh`(--force 없이) 실행. count=0이면 신규 삽입, count=1이면 skip
**Observed:** 1 times (2026-04-15)

## crates.io rtk 설치 혼동 (Pitfall C1)
[context: install-deploy]

**관찰:** `cargo install rtk` 실행으로 RTK 토큰 압축기 설치 시도
**이유:** crates.io에 동명 패키지 "rtk"(Rust Type Kit)가 존재 — 토큰 압축기와 무관한 별개 패키지
**대신:** `brew install rtk` 사용 후 즉시 `rtk gain` 실행으로 rtk-ai/rtk 바이너리임을 검증. "savings" 키워드 출력 확인 — "unrecognized command" 출력 시 잘못된 바이너리
**Observed:** 1 times (2026-04-23)

## rtk telemetry status "disabled" 문자열 없음
[context: install-deploy]

**관찰:** `rtk telemetry status` 출력에 "disabled" 문자열을 grep으로 확인하려 할 때 매칭 실패
**이유:** RTK v0.37.2 실제 출력 포맷은 `enabled: no` (+ `env override: RTK_TELEMETRY_DISABLED=1 (blocked)`) — "disabled" 단어 미포함
**대신:** `rtk telemetry status` 출력에서 `enabled: no` 확인. `RTK_TELEMETRY_DISABLED=1` env var 설정 시 텔레메트리는 차단된 것이 맞음
**Observed:** 1 times (2026-04-23)

## gap closure 실행 전 staged deletion 미확인
[context: install-deploy, agent-behavior]

**관찰:** gap closure plan 실행 시 이전 세션의 git reset --soft가 남긴 staged deletions이 첫 커밋에 포함되어 구현 파일 전체 삭제 발생 (05-01, 05-02 두 번 반복)
**이유:** gap closure plan 시작 전 `git status` 확인 없이 바로 태스크 실행. staged deletions은 working tree에는 파일이 존재하지만 index에서만 삭제 표시됨
**대신:** gap closure plan 실행 전 반드시 `git status`로 staged 상태 확인. staged deletions 발견 시 `git restore --staged <files>`로 unstage 후 진행
**Observed:** 1 times (2026-04-15)
