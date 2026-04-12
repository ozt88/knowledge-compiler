# Troubleshooting

## install.sh — PATCH 마커 존재 시 패치 미반영

**에러:** Phase 2 이후 패치 내용이 에이전트 파일(gsd-phase-researcher.md, gsd-verifier.md)에 반영되지 않음
**원인:** install.sh의 patch_agent()가 PATCH 마커 존재 시 무조건 skip
**해결:** install.sh --force 옵션으로 강제 재적용; 또는 에이전트 파일의 Step 0/10b 블록을 최신 패치 내용으로 직접 교체
**파일:** install.sh, ~/.claude/agents/gsd-phase-researcher.md, ~/.claude/agents/gsd-verifier.md

## gsd-tools phase add — 백로그 항목 Phase 번호 오인

**에러:** /gsd:add-phase 실행 시 의도한 번호(4)가 아닌 1000이 할당됨
**원인:** Phase 999.1 백로그 항목을 gsd-tools가 999로 인식하여 최대 정수 카운트에 포함
**해결:** 수동으로 ROADMAP.md와 STATE.md의 Phase 번호를 4로 수정 후 디렉토리 이름도 변경
**파일:** .planning/ROADMAP.md, .planning/STATE.md

## Phase 검증 — 부정형 패턴 grep 음성인데 코드 미반영

**에러:** feat 커밋 검증은 통과했으나 이후 docs 커밋이 패치 파일을 이전 상태로 교체
**원인:** docs 커밋 stat에 패치 파일이 포함되지 않아 변경 사실이 눈에 띄지 않음
**해결:** git cat-file로 각 커밋 tree blob hash 비교하여 revert 확인; 이후 재적용
**파일:** patches/gsd-phase-researcher.patch.md, patches/gsd-verifier.patch.md

## install.sh --force 인수 파싱 순서 버그

**에러:** install.sh --force 실행 시 FORCE가 항상 false로 동작하여 기존 패치 재적용 불가
**원인:** argument 파싱 블록(`while [[ $# -gt 0 ]]`)이 patch_agent() 호출 이후에 위치
**해결:** argument 파싱 블록을 스크립트 앞쪽(patch_agent 호출 전)으로 이동
**파일:** install.sh (커밋: 41c29b0)

## install.sh awk -v 멀티라인 변수 개행 소실

**에러:** patch_workflow()에서 awk -v patch="$patch_content" 로 멀티라인 내용 전달 시 개행이 소실되어 패치 내용이 한 줄로 플래트닝됨
**원인:** awk -v 변수 할당에서 개행(\n) 문자가 보존되지 않는 동작
**해결:** patch_content를 임시 파일로 저장 후 awk getline으로 읽거나, printf/heredoc 방식으로 전환
**파일:** install.sh (patch_workflow 함수)
**상태:** WR-02 — 코드 리뷰에서 발견, 미수정

## install.sh --force가 CLAUDE.md를 stale 내용으로 덮어씀

**에러:** templates/claude-md-section.md 업데이트 전에 install.sh --force 실행 시 CLAUDE.md의 최신 내용이 구버전으로 덮어써짐
**원인:** install.sh --force는 templates/claude-md-section.md 내용을 CLAUDE.md에 삽입. template 파일이 구버전이면 최신 CLAUDE.md 변경이 유실
**해결:** CLAUDE.md 내용 변경 시 templates/claude-md-section.md를 먼저 동일하게 업데이트한 뒤 install.sh --force 실행
**파일:** templates/claude-md-section.md, ~/.claude/CLAUDE.md, install.sh

## gap closure 실행 중 git reset --soft로 인한 파일 삭제

**에러:** gap closure plan 실행(05-02) 중 Task 1 커밋이 Phase 5 구현 파일(patches, skills, install.sh)을 전부 삭제
**원인:** 이전 세션의 `git reset --soft` 연산이 남긴 staged deletions이 첫 커밋에 포함됨. reset --soft는 working tree 파일은 유지하지만 index(staged) 상태를 변경하여 이전 브랜치의 삭제 상태가 staged로 남음
**해결:** 원본 커밋 해시(00e7ee9, e5c9cbf, 62b9795, d344242)에서 `git checkout {commit} -- {files}`로 파일 복구 후 별도 restore 커밋 생성
**파일:** patches/gsd-discuss-phase.patch.md, patches/gsd-planner.patch.md, patches/gsd-phase-researcher.patch.md, skills/gsd-clear/skill.md, skills/gsd-knowledge-compile/skill.md, install.sh
