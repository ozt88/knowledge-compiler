# Knowledge Index

**Last compiled:** 2026-04-12
**Total entries:** 42 (decisions: 14, guardrails: 11, anti-patterns: 6, troubleshooting: 8, +3 updated)

## Quick Reference

| 주제 | 파일 | 핵심 항목 |
|------|------|-----------|
| 설계 결정 (D-03, D-05, D-08 등) | decisions.md | guardrails/anti-patterns 분리, index-first 접근, D-08 동일성, PageIndex backlog, spec→implementation 전환+ROADMAP 동기화, researcher compile 제거, gap closure 플랜 패턴, knowledge raw 수집 명시적 전환 |
| 절대적 규칙 / 긍정형 액션 | guardrails.md | raw/ 읽기 경유 필수, D-08 블록 동일성, index.md 형식, 부정형 지시 금지, git push 승인, ROADMAP-PLAN 동기화, knowledge raw 수집 명시적 트리거, templates/claude-md-section.md 동기화 |
| 맥락 의존적 주의사항 | anti-patterns.md | raw/ 직접 쿼리, docs 커밋 revert, gsd-tools 번호 버그, install.sh workflow 핸들러 스텁, gap closure staged deletion 미확인 |
| 에러 → 해결 매핑 | troubleshooting.md | install.sh skip 버그, --force 인수 파싱 순서, awk -v 개행 소실, phase add 번호 오인, 검증 통과 후 revert, gap closure git reset --soft 파일 삭제 |

## 전체 요약

knowledge-compiler 프로젝트(v1.1 Positive Prompt Refactor)의 5개 Phase 진행 과정에서 도출된 핵심 지식을 기록한다.

**Phase 1 (Compiler Prompt Refactor):** researcher 패치의 부정형 지시 5개를 긍정형으로 전환. verifier 패치는 이미 긍정형이었으므로 변경 없음.

**Phase 2 (Knowledge Format System):** guardrails.md(긍정형 액션) + anti-patterns.md(관찰-이유-대신) 이중 구조 확립. docs 커밋이 feat 변경을 되돌리는 버그 발생 → 감지 후 재적용으로 해소.

**Phase 3 (Collection Instruction Refactor):** templates/claude-md-section.md 수집 규칙 긍정형 전환, ~/.claude/CLAUDE.md 동기화 완료.

**Phase 4 (Knowledge Importance Prioritization):** 컴파일 타임 선별 기준 + index.md 쿼리 안내 형식(Quick Reference) + index-first 접근 표준화. D-08 패턴으로 researcher/verifier 핵심 블록 동일성 보장.

**Phase 5 (GSD Workflow Stages):** PLAN이 spec-only에서 직접 구현으로 전환됨. researcher Step 0 compile 제거(Step 3 lookup만 유지), planner fallback compile 추가, discuss-phase knowledge lookup 패치 생성, /gsd-clear + /gsd-knowledge-compile 스킬 신설, install.sh에 patch_workflow + install_skill 배포 로직 통합. 초기 검증에서 ROADMAP-PLAN 불일치 5개 갭 발견 → 갭 클로저 플랜(05-02)으로 ROADMAP/REQUIREMENTS 정렬 완료. Phase 5 완전 달성.

**Phase 5 후속 — Knowledge 수집 방식 재설계:** CLAUDE.md per-turn 수집 지시 제거. /gsd-clear와 /gsd-knowledge-compile에 Step 0(last_raw_captured 기준 세션 요약 → raw 기록) 추가. compile-manifest.json에 last_raw_captured 필드 신설로 중복 방지.

## 키워드 인덱스

| 키워드 | 파일#섹션 |
|--------|-----------|
| D-08 | decisions.md#D-08-패턴, guardrails.md#D-08-핵심-블록-동일성 |
| index-first | decisions.md#설계-결정--index-first-접근-표준화, guardrails.md#raw-읽기 |
| guardrails.md | decisions.md#설계-결정--guardailsmd-+-anti-patternsmd-이중-구조, guardrails.md#guardailsmd-기술-형식 |
| anti-patterns.md | decisions.md#설계-결정--guardailsmd-+-anti-patternsmd-이중-구조, anti-patterns.md |
| install.sh | troubleshooting.md#installsh--patch-마커-존재-시-패치-미반영, troubleshooting.md#installsh---force-인수-파싱-순서-버그, anti-patterns.md#installsh-workflow-패치-핸들러-스텁 |
| revert | anti-patterns.md#docs-커밋이-feat-변경사항-되돌리기, troubleshooting.md#phase-검증--부정형-패턴-grep-음성인데-코드-미반영 |
| gsd-tools | anti-patterns.md#gsd-tools의-백로그-phase-번호-인식-오류, troubleshooting.md#gsd-tools-phase-add--백로그-항목-phase-번호-오인 |
| 선별 기준 | decisions.md#설계-결정--컴파일-타임-선별-기준-도입 |
| RELEVANCE | decisions.md#설계-결정--phase-4-요구사항-relevance-시리즈 |
| PageIndex | decisions.md#설계-결정--pageindex-연동-backlog-처리 |
| gsd-clear | decisions.md#설계-결정--researcher-compile-제거-gsd-clear-primary-트리거 |
| ROADMAP | guardrails.md#roadmap-plan-동기화, decisions.md#설계-결정--phase-5-spec-only--implementation-전환-후-roadmap-동기화 |
| git push | guardrails.md#git-push-사용자-승인 |
| awk | troubleshooting.md#installsh-awk--v-멀티라인-변수-개행-소실 |
| gap closure | decisions.md#설계-결정--갭-클로저-플랜-패턴, anti-patterns.md#gap-closure-실행-전-staged-deletion-미확인, troubleshooting.md#gap-closure-실행-중-git-reset---soft로-인한-파일-삭제 |
| git reset | anti-patterns.md#gap-closure-실행-전-staged-deletion-미확인, troubleshooting.md#gap-closure-실행-중-git-reset---soft로-인한-파일-삭제 |
| last_raw_captured | decisions.md#설계-결정--knowledge-raw-수집-방식-변천 |
| gsd-knowledge-compile | decisions.md#설계-결정--knowledge-raw-수집-방식-변천, guardrails.md#knowledge-raw-수집--per-turn-claudemd-방식 |
| gsd-clear | decisions.md#설계-결정--gsd-clear-커스텀-스킬-삭제 |
| JSONL 측정 | decisions.md#설계-결정--jsonl-기반-knowledge-참조율-측정 |
| per-turn | guardrails.md#knowledge-raw-수집--per-turn-claudemd-방식, decisions.md#설계-결정--knowledge-raw-수집-방식-변천 |
| template | guardrails.md#templatesclaude-md-sectionmd-동기화, troubleshooting.md#installsh---force가-claudemd를-stale-내용으로-덮어씀 |
| UTC | troubleshooting.md#gsd-cleargsd-knowledge-compile--last_raw_captured-utc-타임존-불일치 |
