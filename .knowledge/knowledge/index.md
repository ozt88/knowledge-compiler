# Knowledge Index

**Last compiled:** 2026-04-27
**Total entries:** 69 (decisions: 22, guardrails: 17, anti-patterns: 9, troubleshooting: 14)

## Quick Reference

| 주제 | 파일 | 핵심 항목 |
|------|------|-----------|
| 설계 결정 (D-03, D-05, D-08 등) | decisions.md | guardrails/anti-patterns 분리, index-first 접근, D-08 동일성, PageIndex backlog, spec→implementation 전환+ROADMAP 동기화, researcher compile 제거→GSD 최소 부하 원칙, gap closure 플랜 패턴, knowledge raw 수집 명시적 전환, JSONL 참조율 측정, context/Observed 전체 파일 확장, knowledge seed universal 전략, graphify 노드명 lookup 통합, RTK/GSD hook 공존, gsd-validate-commit.sh opt-in, superseded SUMMARY 패턴 |
| 절대적 규칙 / 긍정형 액션 | guardrails.md | raw/ 읽기 경유 필수, D-08 블록 동일성(Phase 6 후 범위 축소), index.md 형식, 부정형 지시 금지, git push 승인, ROADMAP-PLAN 동기화, knowledge raw 수집 per-turn, templates 동기화, install.sh 실행 후 PATCH count 확인 필수, knowledge seed 파일 universal-only, RTK brew 전용 설치, rtk init -g Edit 직접 패치, bash -i 검증 |
| 맥락 의존적 주의사항 | anti-patterns.md | raw/ 직접 쿼리, docs 커밋 revert, gsd-tools 번호 버그, install.sh workflow 핸들러 스텁, gap closure staged deletion 미확인, Python PATCH 정리 후 --force 재실행 금지, crates.io rtk 혼동(Pitfall C1), rtk telemetry "disabled" grep 실패 |
| 에러 → 해결 매핑 | troubleshooting.md | install.sh skip 버그, --force 인수 파싱 순서, awk -v 개행 소실, phase add 번호 오인, 검증 통과 후 revert, gap closure git reset --soft 파일 삭제, unpatch_agent 주석 블록 제거 불가, patch_workflow 앵커 무음 실패, local 함수 밖 사용 set -e 크래시, rtk init -g 비대화형 패치 거부, rtk telemetry "enabled: no" 포맷 |

## 전체 요약

knowledge-compiler 프로젝트(v1.1 Positive Prompt Refactor)의 5개 Phase 진행 과정에서 도출된 핵심 지식을 기록한다.

**Phase 1 (Compiler Prompt Refactor):** researcher 패치의 부정형 지시 5개를 긍정형으로 전환. verifier 패치는 이미 긍정형이었으므로 변경 없음.

**Phase 2 (Knowledge Format System):** guardrails.md(긍정형 액션) + anti-patterns.md(관찰-이유-대신) 이중 구조 확립. docs 커밋이 feat 변경을 되돌리는 버그 발생 → 감지 후 재적용으로 해소.

**Phase 3 (Collection Instruction Refactor):** templates/claude-md-section.md 수집 규칙 긍정형 전환, ~/.claude/CLAUDE.md 동기화 완료.

**Phase 4 (Knowledge Importance Prioritization):** 컴파일 타임 선별 기준 + index.md 쿼리 안내 형식(Quick Reference) + index-first 접근 표준화. D-08 패턴으로 researcher/verifier 핵심 블록 동일성 보장.

**Phase 5 (GSD Workflow Stages):** PLAN이 spec-only에서 직접 구현으로 전환됨. researcher Step 0 compile 제거(Step 3 lookup만 유지), planner fallback compile 추가, discuss-phase knowledge lookup 패치 생성, /gsd-clear + /gsd-knowledge-compile 스킬 신설, install.sh에 patch_workflow + install_skill 배포 로직 통합. 초기 검증에서 ROADMAP-PLAN 불일치 5개 갭 발견 → 갭 클로저 플랜(05-02)으로 ROADMAP/REQUIREMENTS 정렬 완료. Phase 5 완전 달성.

**Phase 5 후속 — Knowledge 수집 방식 재설계:** CLAUDE.md per-turn 수집 지시 제거. /gsd-clear와 /gsd-knowledge-compile에 Step 0(last_raw_captured 기준 세션 요약 → raw 기록) 추가. compile-manifest.json에 last_raw_captured 필드 신설로 중복 방지.

**Phase 6 (GSD Knowledge Reference Audit):** PATCH 마커 중복 삽입 발견(researcher×6, planner×6, verifier×8) + discuss-phase 미설치(앵커 `load_prior_context` 부재 무음 실패). verifier 패치 전체 제거 결정(count=0) — compile/lookup 불필요. planner fallback compile 제거. GSD 최소 부하 원칙 확립: researcher/planner/discuss만 lookup(×1), compile은 /gsd-knowledge-compile 수동 전용. Python으로 중복 제거, 올바른 앵커(`check_existing`) 적용. unpatch_agent awk가 `<!-- PATCH -->` 주석 블록 처리 불가 → Python 필수 우회 경로 확립.

**Phase 8 (Knowledge Record & Retrieve Design):** decisions.md 항목에 context 태그와 Observed 메타데이터 소급 적용. 상태 태그를 제목 줄 다음으로 이동하여 조회 효율성 개선. 6개 카테고리(file-loading, agent-behavior, knowledge-format, compile-logic, install-deploy, scope-backlog)로 항목 분류 완료. B+C fusion 시뮬레이션: "index-first 접근 표준화" Observed 2 times(증강 확인), "GSD 최소 부하 원칙" [uncertain]+[conflict: 2026-04-15](감쇄 확인). Phase 8 UAT 7/7 pass. context/Observed를 전체 knowledge 파일(anti-patterns, troubleshooting)로 확장 결정. install.sh --project 시 templates/knowledge-seed/ 5개 파일 자동 복사 추가(universal meta-knowledge 전용). install.sh `local` 함수 밖 사용 버그(set -e 크래시) 수정.

**Phase 9 (Install & Secure):** RTK v0.37.2 Homebrew 설치 완료. Pitfall C1(crates.io 동명 패키지) 차단 — `rtk gain`으로 즉시 검증. `RTK_TELEMETRY_DISABLED=1` ~/.bashrc 영구 등록. rtk init -g가 비대화형 환경에서 settings.json 자동 패치 거부 → Edit 도구로 직접 삽입. RTK hook command 실제값 = `rtk hook claude` (RESEARCH 예측 `rtk-rewrite.sh`와 상이). `rtk telemetry status` 출력 포맷 = `enabled: no` ("disabled" 미포함). GSD 기존 hook 4개 보존, PreToolUse 총 5개로 확장.

**Phase 10 (Verify):** RTK/GSD hook 공존 검증 — 3/3 SC PASS. SC-1: settings.json JSON 유효 + RTK/GSD hook FOUND + Total 5. SC-2: `rtk git status` 압축 출력(`~ Modified:`, `? Untracked:`) 확인. SC-3: gsd-validate-commit.sh dry-run exit 0(hooks.community opt-in 미활성). v1.2 Token Optimization 마일스톤 완료 조건 충족.

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
| unpatch_agent | troubleshooting.md#installsh-unpatch_agent---patch--주석-블록-제거-불가, anti-patterns.md#python-patch-정리-후-installsh---force-재실행 |
| patch_workflow | troubleshooting.md#installsh-patch_workflow--앵커-미매칭-시-무음-실패 |
| check_existing | troubleshooting.md#installsh-patch_workflow--앵커-미매칭-시-무음-실패 |
| PATCH count | guardrails.md#installsh-실행-후-patch-count-즉시-확인 |
| GSD 최소 부하 | decisions.md#설계-결정--gsd-프로세스-knowledge-최소-부하-원칙-phase-6 |
| verifier 패치 | decisions.md#설계-결정--gsd-프로세스-knowledge-최소-부하-원칙-phase-6 |
| uncertain | decisions.md#설계-결정--gsd-프로세스-knowledge-최소-부하-원칙-phase-6 |
| conflict | decisions.md#설계-결정--gsd-프로세스-knowledge-최소-부하-원칙-phase-6 |
| SKILL.md | troubleshooting.md#gsd-knowledge-compile-스킬--unknown-skill-오류 |
| fragment ID | guardrails.md#decisionsmd-제목-변경-시-indexmd-동시-갱신 |
| context 태그 | decisions.md#설계-결정--context-태그와-observed-전체-knowledge-파일-확장 |
| Observed | decisions.md#설계-결정--context-태그와-observed-전체-knowledge-파일-확장, anti-patterns.md, troubleshooting.md |
| seed | decisions.md#설계-결정--knowledge-seed-파일-universal-meta-knowledge-전략, guardrails.md#knowledge-seed-파일--universal-meta-knowledge-전용 |
| local | troubleshooting.md#installsh--local-키워드-함수-밖-사용-set--e-크래시 |
| set -e | troubleshooting.md#installsh--local-키워드-함수-밖-사용-set--e-크래시 |
| graphify | decisions.md#설계-결정--graphify-노드명-knowledge-lookup-통합-tier-12 |
| phase-researcher 앵커 | decisions.md#설계-결정--graphify-노드명-knowledge-lookup-통합-tier-12 |
| RTK | guardrails.md#rtk-설치--brew-전용, anti-patterns.md#cratesio-rtk-설치-혼동, troubleshooting.md#rtk-init--g--비대화형-모드, decisions.md#설계-결정--rtk-hook과-gsd-hook-matcher-레벨-분리-공존 |
| rtk init | guardrails.md#rtk-init--g-비대화형-환경, troubleshooting.md#rtk-init--g--비대화형-모드-settingsjson-패치-거부 |
| rtk telemetry | anti-patterns.md#rtk-telemetry-status-disabled-문자열-없음, troubleshooting.md#rtk-telemetry-status--disabled-문자열-grep-실패 |
| hooks.community | decisions.md#설계-결정--gsd-validate-commitsh-opt-in-구조 |
| brew install | guardrails.md#rtk-설치--brew-전용, anti-patterns.md#cratesio-rtk-설치-혼동 |
| bash -i | guardrails.md#bash--c-source-bashrc--비대화형-검증-불가 |
| superseded | decisions.md#설계-결정--superseded-plan의-추적-완결-패턴 |
| Pitfall C1 | anti-patterns.md#cratesio-rtk-설치-혼동 |
