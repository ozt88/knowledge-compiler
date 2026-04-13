# Quick Task: skill.md → SKILL.md 대소문자 수정

## What was done
- Renamed `skills/gsd-knowledge-compile/skill.md` → `SKILL.md` (git mv)
- Fixed `install.sh` to reference `SKILL.md` instead of `skill.md`
- Renamed already-installed `~/.claude/skills/gsd-knowledge-compile/skill.md` → `SKILL.md`

## Why
Claude Code skill loader requires `SKILL.md` (uppercase). The file was installed as `skill.md`, causing "Unknown skill" error.

## Verification
Run `./install.sh --force` and check `~/.claude/skills/gsd-knowledge-compile/SKILL.md` exists.
