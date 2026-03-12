# Migration Guide: Existing Projects

This guide covers migrating an existing project (e.g., ARGUS) to use the
claude-workflow metarepo as its workflow source of truth.

## Overview

The migration replaces duplicated protocol/template/skill files in the project
with references to the metarepo, while preserving project-specific customizations.

## Pre-Migration Checklist

- [ ] No active sprint in progress
- [ ] All documentation is synced (no pending doc-sync)
- [ ] Git working tree is clean
- [ ] All tests pass

## Step 1: Add the Submodule

```bash
cd ~/projects/argus  # or your project
git submodule add https://github.com/stevengizzi/claude-workflow.git workflow
git commit -m "Add claude-workflow submodule"
```

## Step 2: Run Setup

```bash
./workflow/scripts/setup.sh
```

This creates symlinks for universal skills, rules, and agents. It will skip
any files that already exist as regular files (potential customizations).

## Step 3: Run Sync Audit

```bash
./workflow/scripts/sync.sh
```

This reports:
- Which `.claude/` files are symlinked vs. copied vs. diverged
- Whether `docs/protocols/` contains legacy copies
- Whether the runner code has diverged

## Step 4: Resolve Divergence

For each diverged file, decide:

### `.claude/skills/` and `.claude/agents/`
These should generally be identical to the metarepo. If they've diverged:
1. Compare: `diff .claude/skills/close-out.md workflow/claude/skills/close-out.md`
2. If the project version has improvements → port them to the metarepo first
3. Replace with symlink: `rm .claude/skills/close-out.md && ln -s ../../workflow/claude/skills/close-out.md .claude/skills/close-out.md`

### `.claude/rules/universal.md`
Same as above — improvements should flow to the metarepo.

### `.claude/rules/` (project-specific files)
These stay as regular files in the project. They are NOT symlinked.
Examples: `architecture.md`, `backtesting.md`, `trading-strategies.md`

### `docs/protocols/` (legacy location)
After migration, protocols live in `workflow/protocols/`. The project's
`docs/protocols/` can be removed if all files are identical to the metarepo.

For files that have diverged (project-specific improvements):
1. Port improvements to the metarepo
2. Commit the metarepo changes
3. Delete the project copy
4. The protocol is now fetched from the metarepo by Claude.ai,
   and read from the submodule by Claude Code

If `docs/protocols/` contained project-specific protocols (not in the metarepo),
keep those in the project.

### `scripts/sprint_runner/` (runner code)
Two options:

**Option A: Submodule import (recommended)**
Replace the project's runner copy with an entry point that imports from the submodule:
```python
# scripts/sprint-runner.py
import sys, os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'workflow', 'runner'))
from sprint_runner.main import main

if __name__ == "__main__":
    main()
```
Then delete `scripts/sprint_runner/` from the project.

**Option B: Keep project copy**
If the runner has project-specific modifications (e.g., custom ARGUS_ env var
prefixes), keep the copy and use `sync.sh` to track divergence.

## Step 5: Update Claude.ai Project

1. Copy `workflow/bootstrap-index.md` content
2. Add it as a project knowledge file in your Claude.ai project
3. Remove the individual protocol/template files from project knowledge
4. Keep project-specific knowledge files (project-knowledge.md, manifesto, etc.)

## Step 6: Verify

1. Run `sync.sh` — should show all clear or only expected project-specific files
2. Run tests — everything should still pass
3. Start a test conversation in Claude.ai — verify protocol fetching works

## Step 7: Commit

```bash
git add -A
git commit -m "Migrate to claude-workflow metarepo

- Added workflow submodule
- Symlinked universal skills, rules, agents
- Removed duplicate protocol/template files
- Updated runner to use submodule import
- Claude.ai project updated with bootstrap-index"
```

## ARGUS-Specific Notes

ARGUS has these project-specific files that should NOT be migrated:

### `.claude/rules/` (keep as project files)
- `architecture.md` — ARGUS component isolation rules
- `backtesting.md` — VectorBT sweep architecture mandate
- `code-style.md` — Python type hint and naming rules
- `doc-updates.md` — ARGUS doc update protocol
- `risk-rules.md` — Order flow and risk management rules
- `sprint_14_rules.md` — Legacy sprint-specific contracts
- `testing.md` — ARGUS test structure and naming
- `trading-strategies.md` — Strategy development rules

### Runner env vars
ARGUS uses `ARGUS_RUNNER_MODE`, `ARGUS_RUNNER_SPRINT_DIR`, `ARGUS_COST_CEILING`.
The metarepo runner should be generalized to use a configurable prefix
(e.g., `WORKFLOW_RUNNER_MODE` as default, `ARGUS_RUNNER_MODE` as override).
This is tracked as a TODO for the runner generalization effort.

### `docs/protocols/` files that may have ARGUS-specific content
Review these for ARGUS-specific examples or references before deleting.
The metarepo versions should be project-agnostic.
