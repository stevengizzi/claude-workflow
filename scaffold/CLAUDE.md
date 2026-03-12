# [PROJECT_NAME] — Claude Code Context

> Dense, actionable context for Claude Code sessions.
> Last updated: [DATE]

## Active Sprint

**No active sprint.** Project initialized.

## Current State

- **Active sprint:** None
- **Next sprint:** 1 (Discovery → first implementation sprint)
- **Tests:** 0
- **Infrastructure:** TBD

## Project Structure

```
[PROJECT_NAME]/
├── .claude/         # rules/, skills/, agents/ (universal symlinked from workflow/)
├── workflow/        # Metarepo submodule (protocols, templates, runner)
├── docs/            # Decision log, sprint history, architecture
├── config/          # Project configuration
├── scripts/         # Runner entry point, utilities
└── tests/           # Test suite
```

## Commands

```bash
# Tests (update after choosing test framework)
# python -m pytest tests/

# Sprint runner
python scripts/sprint-runner.py --config config/runner.yaml
```

## Key Decisions

*No decisions yet. See docs/decision-log.md.*

## Deferred Items

*No deferred items yet.*
