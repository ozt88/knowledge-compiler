# Troubleshooting

## install.sh — PATCH 마커 존재 시 패치 미반영
[context: install-deploy]

**에러:** Phase 2 이후 패치 내용이 에이전트 파일(gsd-phase-researcher.md, gsd-verifier.md)에 반영되지 않음
**원인:** install.sh의 patch_agent()가 PATCH 마커 존재 시 무조건 skip
**해결:** install.sh --force 옵션으로 강제 재적용; 또는 에이전트 파일의 Step 0/10b 블록을 최신 패치 내용으로 직접 교체
**파일:** install.sh, ~/.claude/agents/gsd-phase-researcher.md, ~/.claude/agents/gsd-verifier.md
**Observed:** 1 times (2026-04-15)

## gsd-tools phase add — 백로그 항목 Phase 번호 오인
[context: scope-backlog]

**에러:** /gsd:add-phase 실행 시 의도한 번호(4)가 아닌 1000이 할당됨
**원인:** Phase 999.1 백로그 항목을 gsd-tools가 999로 인식하여 최대 정수 카운트에 포함
**해결:** 수동으로 ROADMAP.md와 STATE.md의 Phase 번호를 4로 수정 후 디렉토리 이름도 변경
**파일:** .planning/ROADMAP.md, .planning/STATE.md
**Observed:** 1 times (2026-04-15)

## Phase 검증 — 부정형 패턴 grep 음성인데 코드 미반영
[context: install-deploy, compile-logic]

**에러:** feat 커밋 검증은 통과했으나 이후 docs 커밋이 패치 파일을 이전 상태로 교체
**원인:** docs 커밋 stat에 패치 파일이 포함되지 않아 변경 사실이 눈에 띄지 않음
**해결:** git cat-file로 각 커밋 tree blob hash 비교하여 revert 확인; 이후 재적용
**파일:** patches/gsd-phase-researcher.patch.md, patches/gsd-verifier.patch.md
**Observed:** 1 times (2026-04-15)

## install.sh --force 인수 파싱 순서 버그
[context: install-deploy]

**에러:** install.sh --force 실행 시 FORCE가 항상 false로 동작하여 기존 패치 재적용 불가
**원인:** argument 파싱 블록(`while [[ $# -gt 0 ]]`)이 patch_agent() 호출 이후에 위치
**해결:** argument 파싱 블록을 스크립트 앞쪽(patch_agent 호출 전)으로 이동
**파일:** install.sh (커밋: 41c29b0)
**Observed:** 1 times (2026-04-15)

## install.sh awk -v 멀티라인 변수 개행 소실
[context: install-deploy]

**에러:** patch_workflow()에서 awk -v patch="$patch_content" 로 멀티라인 내용 전달 시 개행이 소실되어 패치 내용이 한 줄로 플래트닝됨
**원인:** awk -v 변수 할당에서 개행(\n) 문자가 보존되지 않는 동작
**해결:** patch_content를 임시 파일로 저장 후 awk getline으로 읽거나, printf/heredoc 방식으로 전환
**파일:** install.sh (patch_workflow 함수)
**상태:** WR-02 — 코드 리뷰에서 발견, 미수정
**Observed:** 1 times (2026-04-15)

## install.sh --force가 CLAUDE.md를 stale 내용으로 덮어씀
[context: install-deploy]

**에러:** templates/claude-md-section.md 업데이트 전에 install.sh --force 실행 시 CLAUDE.md의 최신 내용이 구버전으로 덮어써짐
**원인:** install.sh --force는 templates/claude-md-section.md 내용을 CLAUDE.md에 삽입. template 파일이 구버전이면 최신 CLAUDE.md 변경이 유실
**해결:** CLAUDE.md 내용 변경 시 templates/claude-md-section.md를 먼저 동일하게 업데이트한 뒤 install.sh --force 실행
**파일:** templates/claude-md-section.md, ~/.claude/CLAUDE.md, install.sh
**Observed:** 1 times (2026-04-15)

## gsd-clear/gsd-knowledge-compile — last_raw_captured UTC 타임존 불일치
[context: compile-logic]

**에러:** Step 0 실행 시 항상 "nothing to record" — JSONL 항목이 cutoff보다 이전으로 판정
**원인:** `last_raw_captured`를 현재 벽시계 시각(KST)을 UTC 포맷으로 그대로 기록. KST 22:10을 22:10Z로 저장하면 실제 UTC(13:10Z)보다 9시간 미래 값이 됨. JSONL 타임스탬프는 순수 UTC이므로 항상 cutoff보다 이전
**해결:** 서브에이전트가 JSONL에서 처리한 마지막 항목의 실제 UTC 타임스탬프를 반환 → 그 값을 `last_raw_captured`에 저장. 현재 시각(벽시계) 사용 금지
**파일:** skills/gsd-clear/skill.md, skills/gsd-knowledge-compile/skill.md, .planning/compile-manifest.json
**Observed:** 1 times (2026-04-15)

## install.sh unpatch_agent — <!-- PATCH --> 주석 블록 제거 불가
[context: install-deploy]

**에러:** `install.sh --force` 실행 시 researcher/planner PATCH 블록이 제거되지 않고 재삽입 → 중복 증가
**원인:** `unpatch_agent` awk가 `## Step 0: Knowledge Compile` / `## Step 10b: Knowledge Reconcile` 헤더 기반으로 블록 감지. researcher/planner 패치는 `<!-- PATCH:knowledge-compiler -->` 주석으로 시작하므로 패턴 매칭 불가
**해결:** Python regex로 직접 제거 후 `install.sh`(--force 없이) 재실행으로 단일 블록 삽입: `re.sub(r'<!-- PATCH:knowledge-compiler[^>]*-->\n.*?(?=\n## |\Z)', '', content, flags=re.DOTALL)`
**파일:** install.sh (unpatch_agent), ~/.claude/agents/gsd-phase-researcher.md, ~/.claude/agents/gsd-planner.md
**Observed:** 1 times (2026-04-15)

## install.sh patch_workflow — 앵커 미매칭 시 무음 실패
[context: install-deploy]

**에러:** `install.sh` 실행 후 discuss-phase.md에 PATCH 마커 미삽입 (count=0), install.sh는 "patched" 출력
**원인:** `patch_workflow` 앵커(`<step name="load_prior_context">`)가 실제 파일에 존재하지 않음. awk가 한 번도 매칭되지 않고 파일을 그대로 출력. 성공/실패 감지 로직 없음
**해결:** 앵커를 실제 존재하는 step으로 수정. discuss-phase.md의 올바른 앵커 = `<step name="check_existing">`. 패치 후 즉시 `grep -c "PATCH:knowledge-compiler"` 로 count 확인
**파일:** install.sh (patch_workflow discuss-phase 앵커), ~/.claude/get-shit-done/workflows/discuss-phase.md
**Observed:** 1 times (2026-04-15)

## install.sh patch_agent — planner 패치 마커 미삽입 (매번 재패치 시도)
[context: install-deploy]

**에러:** `install.sh` 실행 후 `gsd-planner.md`에 PATCH 마커 count=0. install.sh는 "patched" 출력하지만 `grep -q "PATCH:knowledge-compiler"` 다음 실행 시 또 "patched" 반복
**원인:** `gsd-planner.patch.md`의 line 3(tail -n +3 이후 첫 줄)에 `<!-- PATCH:knowledge-compiler -->` 마커가 없음. 삽입된 내용에 마커가 포함되지 않아 `patch_agent` 중복 체크가 매번 실패
**해결:** 삽입 시 마커 주석을 content 앞에 수동으로 추가: `<!-- PATCH:knowledge-compiler — reapply after GSD updates -->`를 patch_content 앞에 붙여 Edit 또는 Python으로 직접 삽입
**파일:** patches/gsd-planner.patch.md (line 3에 PATCH 마커 없음), ~/.claude/agents/gsd-planner.md
**Observed:** 1 times (2026-04-15)

## gsd-knowledge-compile 스킬 — "Unknown skill" 오류
[context: install-deploy]

**에러:** `/gsd-knowledge-compile` 실행 시 "Unknown skill" 메시지로 스킬을 찾지 못함
**원인:** `install.sh`가 스킬 파일을 `skill.md`(소문자)로 복사했으나 Claude Code는 `SKILL.md`(대문자)만 인식
**해결:** `git mv skills/gsd-knowledge-compile/skill.md skills/gsd-knowledge-compile/SKILL.md` 후 install.sh 복사 경로도 대문자로 수정. 설치된 파일도 rename.
**파일:** `skills/gsd-knowledge-compile/SKILL.md`, `install.sh` (install_skill 함수)
**Observed:** 1 times (2026-04-15)

## install.sh — local 키워드 함수 밖 사용 (set -e 크래시)
[context: install-deploy]

**에러:** `install.sh --project` 실행 시 새 환경에서 즉시 종료. "line N: local: can only be used in a function" 출력
**원인:** new-project.md / new-milestone.md 패치 블록의 `local tmp_file="$(mktemp)"` 선언이 함수 바깥에 위치. bash `set -e` 환경에서 `local`은 함수 밖에서 exit code 1 반환 → 스크립트 즉시 종료
**해결:** `local` 키워드 제거, `tmp_file="$(mktemp)"` 로 변경 (함수 밖에서는 단순 변수 할당)
**파일:** install.sh (237행, 255행 — new-project.md / new-milestone.md 패치 블록)
**Observed:** 1 times (2026-04-15)

## gap closure 실행 중 git reset --soft로 인한 파일 삭제
[context: install-deploy, agent-behavior]

**에러:** gap closure plan 실행(05-02) 중 Task 1 커밋이 Phase 5 구현 파일(patches, skills, install.sh)을 전부 삭제
**원인:** 이전 세션의 `git reset --soft` 연산이 남긴 staged deletions이 첫 커밋에 포함됨. reset --soft는 working tree 파일은 유지하지만 index(staged) 상태를 변경하여 이전 브랜치의 삭제 상태가 staged로 남음
**해결:** 원본 커밋 해시(00e7ee9, e5c9cbf, 62b9795, d344242)에서 `git checkout {commit} -- {files}`로 파일 복구 후 별도 restore 커밋 생성
**파일:** patches/gsd-discuss-phase.patch.md, patches/gsd-planner.patch.md, patches/gsd-phase-researcher.patch.md, skills/gsd-clear/skill.md, skills/gsd-knowledge-compile/skill.md, install.sh
**Observed:** 1 times (2026-04-15)
