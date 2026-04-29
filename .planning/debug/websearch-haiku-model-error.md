---
status: root_cause_found
trigger: "WebSearch가 작동하지 않음 — vertex_ai/claude-haiku-4-5@20251001 모델 접근 불가 오류"
created: 2026-04-23T00:00:00Z
updated: 2026-04-23T09:00:00Z
---

## Current Focus
<!-- OVERWRITE on each update - reflects NOW -->

hypothesis: 환경 변수 ANTHROPIC_SMALL_FAST_MODEL 및 ANTHROPIC_DEFAULT_HAIKU_MODEL이 Vertex AI 모델 ID로 설정되어 있어, WebSearch 도구가 해당 모델을 사용하려 할 때 접근 불가 오류 발생
test: -
expecting: -
next_action: 환경 변수 수정 또는 제거

## Symptoms
<!-- Written during gathering, then IMMUTABLE -->

expected: WebSearch 도구가 검색 결과를 반환해야 함
actual: "There's an issue with the selected model (vertex_ai/claude-haiku-4-5@20251001). It may not exist or you may not have access to it." 오류 반환
errors: vertex_ai/claude-haiku-4-5@20251001 모델 접근 불가
reproduction: WebSearch 도구 호출 시 매번 발생
started: 모름 (오늘 처음 시도)

## Eliminated
<!-- APPEND only - prevents re-investigating -->

- GSD 설정 파일 문제: .planning/config.json에 model_profile 설정 없음 — GSD 에이전트 모델 해상도와 무관

## Evidence
<!-- APPEND only - facts discovered -->

- timestamp: 2026-04-23T09:00:00Z
  finding: 환경 변수 ANTHROPIC_DEFAULT_HAIKU_MODEL=vertex_ai/claude-haiku-4-5@20251001 확인
  source: env 출력

- timestamp: 2026-04-23T09:00:00Z
  finding: 환경 변수 ANTHROPIC_SMALL_FAST_MODEL=vertex_ai/claude-haiku-4-5@20251001 확인
  source: env 출력

- timestamp: 2026-04-23T09:00:00Z
  finding: Claude Code VSCode 확장으로 실행 중 (CLAUDE_CODE_ENTRYPOINT=claude-vscode)
  source: env 출력

- timestamp: 2026-04-23T09:00:00Z
  finding: WebSearch 도구는 내부적으로 ANTHROPIC_SMALL_FAST_MODEL 환경 변수로 지정된 모델을 사용함
  source: 에러 메시지 분석 + 환경 변수 확인

- timestamp: 2026-04-23T09:00:00Z
  finding: vertex_ai/claude-haiku-4-5@20251001 는 Vertex AI 특정 버전 모델 ID로, 현재 환경에서 접근 불가하거나 해당 버전이 deprecated됨
  source: 에러 메시지 직접 확인

## Resolution
<!-- OVERWRITE as understanding evolves -->

root_cause: ANTHROPIC_SMALL_FAST_MODEL 및 ANTHROPIC_DEFAULT_HAIKU_MODEL 환경 변수가 접근 불가한 Vertex AI 모델 버전(vertex_ai/claude-haiku-4-5@20251001)으로 설정되어 있어 WebSearch 도구 실행 실패
fix: 해당 환경 변수를 제거하거나 유효한 모델 ID로 변경 (예: claude-haiku-4-5 또는 현재 세션 모델로 상속)
verification: 환경 변수 수정 후 WebSearch 도구 재시도
files_changed: []
