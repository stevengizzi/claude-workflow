# [PROJECT_NAME] — Claude Code Context

> Dense, actionable context for Claude Code sessions.
> Last updated: [DATE]

## Rules

This project follows the universal rules in `.claude/rules/universal.md` (auto-loaded by Claude Code at session start per the implementation-prompt template's Pre-Flight step). Project-specific rules live alongside in `.claude/rules/` (e.g., `<project>-specific.md`).

The keystone Pre-Flight wiring (in `templates/implementation-prompt.md` and `templates/review-prompt.md`) ensures every implementation and review session reads `universal.md` deterministically — universal RULEs apply regardless of whether they're inline-referenced in any specific prompt.

Do not enumerate specific RULEs in this section. Adding new RULEs to `universal.md` should not require updating every project's `CLAUDE.md`. The keystone Pre-Flight wiring is the propagation mechanism.

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
