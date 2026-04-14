# Quick Task: install.sh 버그 수정 + gsd-planner.md 마커 추가

## What was done
- install.sh: new-project.md 패치 블록에 실제 awk 삽입 코드 추가
- install.sh: new-milestone.md 패치 블록에 실제 awk 삽입 코드 추가
- gsd-planner.md: PATCH_MARKER 주석 삽입 (콘텐츠는 이미 존재)
- new-project.md: git init 뒤에 .knowledge/ auto-init 삽입
- new-milestone.md: ## 8. Research Decision 앞에 .knowledge/ auto-init 삽입

## Why
install.sh가 new-project/new-milestone 패치 시 "patched" 메시지만 출력하고
실제 파일 수정을 하지 않는 버그. gsd-planner.md는 콘텐츠는 있으나 마커 누락으로
--force 재적용이 불가능했음.
