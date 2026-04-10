# Knowledge Compiler

GSD 워크플로 확장 — 세션 간 지식 유실을 방지하는 자동 수집·컴파일·참조 파이프라인.

## 문제

GSD로 탐색적 작업(인게임 검증, 디버깅 등) 중 발생한 학습이 세션 종료와 함께 증발.
서브에이전트(planner, researcher)가 과거 시도/실패/결정에 접근할 수 없어 같은 실수 반복.

## 해법

```
매 턴 → .knowledge/raw/ 에 자동 수집 (CLAUDE.md 행동 지시)
Phase 계획 시작 → researcher가 raw/ → knowledge/ incremental compile
Phase 검증 완료 → verifier가 raw/ incremental compile + knowledge lint
다음 Phase → researcher가 knowledge/ 참조하여 과거 실수 회피
```

## 설치

### 1. GSD 에이전트 패치 (전역, 머신당 1회)

```bash
git clone https://github.com/ozt88/knowledge-compiler.git
cd knowledge-compiler
chmod +x install.sh
./install.sh
```

### 2. 프로젝트 설정 (프로젝트당 1회)

```bash
./install.sh --project /path/to/your/project
```

또는 수동:
1. 프로젝트에 `.knowledge/raw/`, `.knowledge/knowledge/` 디렉토리 생성
2. `templates/claude-md-section.md` 내용을 프로젝트 `CLAUDE.md`에 추가

### GSD 업데이트 후

```bash
cd knowledge-compiler
./install.sh
```

에이전트 패치가 덮어씌워졌을 경우 재적용됩니다 (이미 적용된 경우 skip).

## 구조

```
knowledge-compiler/
├── install.sh                              # 설치 스크립트
├── patches/
│   ├── gsd-phase-researcher.patch.md       # researcher Step 0: incremental compile
│   └── gsd-verifier.patch.md               # verifier Step 10b/10c: incr. + lint
├── templates/
│   ├── claude-md-section.md                # CLAUDE.md에 추가할 턴 수집 지시
│   └── .knowledge/                         # 프로젝트 디렉토리 구조 템플릿
│       ├── raw/.gitkeep
│       └── knowledge/.gitkeep
└── README.md
```

## knowledge/ 파일 구조

| 파일 | 내용 |
|------|------|
| `index.md` | 전체 요약 + 키워드 인덱스 |
| `decisions.md` | 시도 → 결과 → 결정 (`[active]`, `[rejected]`, `[superseded]`, `[uncertain]`) |
| `anti-patterns.md` | 맥락 의존형 접근법 (Observation-Reason-Instead 형식) |
| `troubleshooting.md` | 에러 메시지 ↔ 해결책 매핑 |
| `guardrails.md` | 대안이 단일 선택으로 고정된 경우 — 긍정형 행동 지시 |

## 요구사항

- [GSD](https://github.com/gsd-build/get-shit-done) 1.32.0+
- Claude Code CLI

## 설계 문서

상세 설계와 테스트 결과: [docs/DESIGN.md](docs/DESIGN.md)
