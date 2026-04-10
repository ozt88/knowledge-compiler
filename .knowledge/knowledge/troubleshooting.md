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
