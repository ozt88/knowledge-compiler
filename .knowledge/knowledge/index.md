# Knowledge Index

**Last compiled:** 2026-04-09
**Total entries:** 18 (decisions: 8, guardrails: 6, anti-patterns: 4, troubleshooting: 3)

## Quick Reference

| 주제 | 파일 | 핵심 항목 |
|------|------|-----------|
| 설계 결정 (D-03, D-05, D-08 등) | decisions.md | guardrails/anti-patterns 분리, index-first 접근, D-08 동일성, PageIndex backlog |
| 절대적 규칙 / 긍정형 액션 | guardrails.md | raw/ 읽기 경유 필수, D-08 블록 동일성, index.md 형식, 부정형 지시 금지 |
| 맥락 의존적 주의사항 | anti-patterns.md | raw/ 직접 쿼리, docs 커밋 revert, gsd-tools 번호 버그 |
| 에러 → 해결 매핑 | troubleshooting.md | install.sh skip 버그, phase add 번호 오인, 검증 통과 후 revert |

## 전체 요약

knowledge-compiler 프로젝트(v1.1 Positive Prompt Refactor)의 4개 Phase 진행 과정에서 도출된 핵심 지식을 기록한다.

**Phase 1 (Compiler Prompt Refactor):** researcher 패치의 부정형 지시 5개를 긍정형으로 전환. verifier 패치는 이미 긍정형이었으므로 변경 없음.

**Phase 2 (Knowledge Format System):** guardrails.md(긍정형 액션) + anti-patterns.md(관찰-이유-대신) 이중 구조 확립. docs 커밋이 feat 변경을 되돌리는 버그 발생 → 감지 후 재적용으로 해소.

**Phase 3 (Collection Instruction Refactor):** templates/claude-md-section.md 수집 규칙 긍정형 전환, ~/.claude/CLAUDE.md 동기화 완료.

**Phase 4 (Knowledge Importance Prioritization):** 컴파일 타임 선별 기준 + index.md 쿼리 안내 형식(Quick Reference) + index-first 접근 표준화. D-08 패턴으로 researcher/verifier 핵심 블록 동일성 보장.

## 키워드 인덱스

| 키워드 | 파일#섹션 |
|--------|-----------|
| D-08 | decisions.md#D-08-패턴, guardrails.md#D-08-핵심-블록-동일성 |
| index-first | decisions.md#설계-결정--index-first-접근-표준화, guardrails.md#raw-읽기 |
| guardrails.md | decisions.md#설계-결정--guardailsmd-+-anti-patternsmd-이중-구조, guardrails.md#guardailsmd-기술-형식 |
| anti-patterns.md | decisions.md#설계-결정--guardailsmd-+-anti-patternsmd-이중-구조, anti-patterns.md |
| install.sh | troubleshooting.md#installsh--patch-마커-존재-시-패치-미반영 |
| revert | anti-patterns.md#docs-커밋이-feat-변경사항-되돌리기, troubleshooting.md#phase-검증--부정형-패턴-grep-음성인데-코드-미반영 |
| gsd-tools | anti-patterns.md#gsd-tools의-백로그-phase-번호-인식-오류, troubleshooting.md#gsd-tools-phase-add--백로그-항목-phase-번호-오인 |
| 선별 기준 | decisions.md#설계-결정--컴파일-타임-선별-기준-도입 |
| RELEVANCE | decisions.md#설계-결정--phase-4-요구사항-relevance-시리즈 |
| PageIndex | decisions.md#설계-결정--pageindex-연동-backlog-처리 |
