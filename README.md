# Claude Workflow

A portable, versioned development methodology for Claude-powered projects.

## What This Is

This repository contains the complete sprint planning, implementation, review, and documentation workflow developed across ARGUS (65+ conversations, 23+ sprints), MuseFlow (11 conversations, 4 sprints), and Grove (11 conversations, 6 phases). It codifies hard-won patterns into reusable protocols, templates, schemas, and tooling.

The workflow is designed for a **two-Claude architecture**: Claude.ai handles strategic planning, architectural review, and sprint design. Claude Code handles implementation and review execution. Git bridges the two.

## Repository Structure

```
claude-workflow/
├── protocols/           # How to run each type of conversation (19 protocols)
├── templates/           # Fill-in-the-blank sprint artifacts (13 templates)
├── schemas/             # Structured output schemas for runner/review (4 schemas)
├── claude/              # Claude Code configuration (universal)
│   ├── skills/          # close-out, review, canary-test, diagnostic, doc-sync
│   ├── rules/           # universal.md (53 cross-project rules)
│   └── agents/          # builder, reviewer, doc-sync-agent
├── runner/              # Autonomous Sprint Runner (Python package, 13 modules)
├── scaffold/            # New project starter kit
├── scripts/             # scaffold.sh, setup.sh, sync.sh, phase-2-validate.py
├── bootstrap-index.md   # Claude.ai project knowledge file (the key integration point)
├── VERSIONING.md        # Version policy
└── MIGRATION.md         # Guide for migrating existing projects (e.g., ARGUS)
```

## Integration Pattern

### Claude.ai (Strategic Layer)
Each Claude.ai project includes `bootstrap-index.md` as its only workflow-related
project knowledge file. It tells Claude where to fetch protocols and templates on
demand from this repo via `web_fetch` on raw GitHub URLs. Project-specific context
(current state, decisions, architecture) stays as separate project knowledge files.

### Claude Code (Implementation Layer)
This repo is added as a **git submodule** at `workflow/` in each project.
The `setup.sh` script symlinks universal skills, rules, and agents into `.claude/`.
Project-specific rules live alongside the symlinked universal ones.

### Autonomous Runner
The runner package lives in this repo. Each project's entry point imports from the
submodule path. Environment variable prefix is configurable per project.

## Quick Start

### New Project
```bash
git clone https://github.com/stevengizzi/claude-workflow.git
./claude-workflow/scripts/scaffold.sh ~/projects/my-new-project
```

### Existing Project
```bash
cd ~/projects/existing-project
git submodule add https://github.com/stevengizzi/claude-workflow.git workflow
./workflow/scripts/setup.sh
```

### Check for Divergence
```bash
./workflow/scripts/sync.sh
```
