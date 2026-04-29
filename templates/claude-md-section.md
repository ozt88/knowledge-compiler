## Knowledge Compiler — raw 수집

응답할 때마다 **primary working directory 기준** `.knowledge/raw/YYYY-MM-DD.md`에 기록할 만한 내용이 있으면 append한다. 경로는 항상 절대경로로 계산한다: `{primary_working_directory}/.knowledge/raw/YYYY-MM-DD.md`.

```
### HH:MM — 한줄 제목
- 항목 1
- 항목 2
```

**기록 대상:** 수행한 작업과 결과, 해결한 문제와 해법, 핵심 결정 사항
**건너뛰는 항목:** 단순 조회, 결과 없는 탐색, 사소한 확인 작업
