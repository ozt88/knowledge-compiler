---
slug: graphify-knowledge-integration
title: Graphify + Knowledge Compiler 시너지 구현 (Tier 1 + Tier 2)
status: in_progress
created: 2026-04-16
updated: 2026-04-16
---

# Thread: Graphify + Knowledge Compiler 시너지 구현

## Goal

GSD 1.36.0에서 추가된 `/gsd-graphify`(코드베이스 구조 그래프)와
우리 knowledge-compiler(세션 학습 파이프라인)를 연결한다.

**핵심 아이디어:**

- Graphify: "어디를" 건드려야 하나 (컴포넌트 구조/관계)
- Knowledge: "거기서" 과거에 무슨 일이 있었나 (결정/실패/해법)
- 지금은 두 시스템이 phase-researcher에서 독립 병렬 실행 → 연결되면 훨씬 정밀

---

## 구현할 것 (Tier 1 + Tier 2 세트)

### Tier 1 — gsd-phase-researcher.patch.md 수정

**현재 패치 위치:** `## Step 1: Receive Scope and Load Context` 앞에 삽입됨

**문제:** knowledge lookup이 phase name/task keyword로만 검색함.
graphify가 먼저 실행되어 컴포넌트명을 뽑아내도 그 결과를 knowledge lookup에 활용 못 함.

**변경:** 우리 knowledge lookup 블록을 graphify Step 1.3 **뒤로** 재배치.
graphify query 결과(노드 label들)를 knowledge index.md 검색 키워드에 추가.

```
변경 전:
  [우리 패치: knowledge lookup] → Step 1.3: graphify query (독립)

변경 후:
  Step 1.3: graphify query → [우리 패치: graph 노드명 포함해 knowledge lookup]
```

**구체적 로직 (패치에 추가할 내용):**

```
**If graphify returned results (Step 1.3):**

- Extract node labels from graph query results
- Add these labels as additional keywords when searching knowledge/index.md
- Example: graphify returned [AuthService, JwtValidator] →
  search knowledge for "AuthService", "JwtValidator" in addition to phase keywords
```

**패치 앵커 변경:**

- 현재: `## Step 1: Receive Scope and Load Context` 앞에 삽입
- 변경: Step 1.3 graphify 블록 뒤 어딘가에 삽입해야 함
- → install.sh의 anchor 라인도 함께 변경 필요

현재 install.sh:

```bash
patch_agent \
    "$AGENTS_DIR/gsd-phase-researcher.md" \
    "$SCRIPT_DIR/patches/gsd-phase-researcher.patch.md" \
    "## Step 1: Receive Scope and Load Context"
```

변경안: Step 1.3 이후 위치 앵커를 찾아야 함.
`gsd-phase-researcher.md`에서 Step 1.3 이후 Step 1.5 전 적당한 앵커 확인 필요.
현재 Step 1.3 끝 부분: `"If no results or graph.json absent, continue to Step 1.5 without graph context."`

---

### Tier 2 — gsd-knowledge-compile SKILL.md 수정

**파일:** `/home/ozt88/.claude/skills/gsd-knowledge-compile/SKILL.md`
**+ 프로젝트 소스:** `/home/ozt88/knowledge-compiler/skills/gsd-knowledge-compile/SKILL.md`

**현재 `[context: ...]` 태그 정의:**

```
카테고리: `file-loading`, `agent-behavior`, `knowledge-format`,
          `compile-logic`, `install-deploy`, `scope-backlog`
```

추상적 카테고리라 graphify 노드명과 매칭이 안 됨.

**변경 내용 (Step 5 `decisions.md` 업데이트 섹션에 추가):**

```markdown

- `[context: ...]` 태그 선택 규칙 (graphify 활성 시):
  - `.planning/graphs/graph.json`이 존재하면 graphify가 활성화된 프로젝트
  - 해당 결정/가드레일이 특정 컴포넌트(클래스/모듈/서비스)에 관련된 경우
    → 해당 컴포넌트의 그래프 노드명을 context 태그로 사용
    → 예: `[context: AuthService, SessionStore]`

  - 코드베이스와 무관한 일반 결정 (컴파일 로직, 에이전트 동작 등)
    → 기존 추상 카테고리 유지: `[context: compile-logic]`

  - graphify 미활성 프로젝트 → 기존 방식 그대로

```

---

## 파일 목록

변경 대상 파일:

1. `patches/gsd-phase-researcher.patch.md` — Tier 1 (knowledge lookup 로직 + 앵커 위치 변경)
2. `install.sh` — Tier 1 (patch_agent 앵커 라인 변경)
3. `skills/gsd-knowledge-compile/SKILL.md` — Tier 2 (context 태그 가이드 추가)

설치 후 동기화:

- `bash /home/ozt88/knowledge-compiler/install.sh --force` 실행 필요
- `~/.claude/skills/gsd-knowledge-compile/SKILL.md`에 자동 반영됨

---

## 전제 조건 확인 (새 세션에서 먼저 확인)

```bash

# 1. phase-researcher의 현재 Step 1.3 끝 부분 확인 (새 앵커 결정용)

grep -n "graph.json absent\|Step 1.5\|Step 1.4" ~/.claude/agents/gsd-phase-researcher.md

# 2. 현재 패치 파일 내용 확인

cat /home/ozt88/knowledge-compiler/patches/gsd-phase-researcher.patch.md

# 3. 현재 knowledge-compile SKILL.md Step 5 섹션 확인

grep -n "context\|태그" /home/ozt88/knowledge-compiler/skills/gsd-knowledge-compile/SKILL.md
```

---

## References

- GSD 1.36.0 릴리즈: https://github.com/gsd-build/get-shit-done/releases/tag/v1.36.0
- graphify 구현: `~/.claude/get-shit-done/bin/lib/graphify.cjs`
- phase-researcher 현재 Step 1.3: `~/.claude/agents/gsd-phase-researcher.md` 560번줄 근방
- 우리 현재 패치: `patches/gsd-phase-researcher.patch.md` (Step 1 앞에 삽입)
- knowledge-compile SKILL: `skills/gsd-knowledge-compile/SKILL.md`

---

## Next Steps

1. `gsd-phase-researcher.md`에서 Step 1.3 이후 적절한 앵커 라인 확인
2. `patches/gsd-phase-researcher.patch.md` 수정:
   - graphify가 활성화돼 있고 Step 1.3 결과가 있을 때 노드명을 knowledge 검색에 포함하는 조건부 로직 추가
3. `install.sh`의 `patch_agent` 앵커 라인 업데이트
4. `skills/gsd-knowledge-compile/SKILL.md` Step 5에 context 태그 graphify 가이드 추가
5. `bash install.sh --force`로 재설치
6. 테스트: graphify 없는 프로젝트에서 기존 동작 유지 확인
