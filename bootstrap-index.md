# Workflow Bootstrap Index

> This file is the sole workflow reference in this Claude.ai project's knowledge.
> All protocols, templates, and schemas live in the metarepo and are fetched on demand.
> **Do not duplicate protocol content in project knowledge files.**
>
> Metarepo: https://github.com/stevengizzi/claude-workflow
> Raw file base: https://raw.githubusercontent.com/stevengizzi/claude-workflow/main/

---

## How This Works

When a conversation requires a protocol or template, **fetch it from the metarepo**
using `web_fetch` on the raw GitHub URL. This ensures every conversation uses the
latest version without manual syncing.

**Fetch pattern:**
```
web_fetch: https://raw.githubusercontent.com/stevengizzi/claude-workflow/main/{path}
```

**When to fetch:** At the start of the conversation, once the conversation type is
identified. Fetch only what's needed for the current conversation type.

---

## Conversation Type → What to Fetch

### Sprint Planning
Fetch first:
- `protocols/sprint-planning.md`

Fetch during artifact generation (Phase C/D):
- `templates/sprint-spec.md`
- `templates/design-summary.md`
- `templates/spec-by-contradiction.md`
- `templates/implementation-prompt.md`
- `templates/review-prompt.md`

### Adversarial Review
- `protocols/adversarial-review.md`

### Tier 3 Architectural Review
- `protocols/tier-3-review.md`

### In-Flight Triage (Sprint Work Journal)
- `protocols/in-flight-triage.md`

### Impromptu Triage (Unplanned Work)
- `protocols/impromptu-triage.md`
- `templates/implementation-prompt.md`
- `templates/review-prompt.md`

### Discovery (New Project)
- `protocols/discovery.md`

### Strategic Check-In
- `protocols/strategic-check-in.md`

### Codebase Health Audit
- `protocols/codebase-health-audit.md`

### Retrofit (Existing Project)
- `protocols/retrofit-survey.md`
- `templates/decision-entry.md`

---

## Protocol Index

| Protocol | Path | Purpose |
|----------|------|---------|
| Sprint Planning | `protocols/sprint-planning.md` | Core planning — produces full sprint package |
| Adversarial Review | `protocols/adversarial-review.md` | Stress-test sprint specs |
| Tier 3 Review | `protocols/tier-3-review.md` | Architectural review at phase boundaries |
| In-Flight Triage | `protocols/in-flight-triage.md` | Mid-sprint issue classification |
| Impromptu Triage | `protocols/impromptu-triage.md` | Scope and plan unplanned work |
| Discovery | `protocols/discovery.md` | New project kickoff research |
| Strategic Check-In | `protocols/strategic-check-in.md` | Periodic direction review |
| Codebase Health Audit | `protocols/codebase-health-audit.md` | Systematic code quality review |
| Retrofit Survey | `protocols/retrofit-survey.md` | Bring existing project into workflow |
| Autonomous Runner | `protocols/autonomous-sprint-runner.md` | Runner operations and state machine |
| Notification Protocol | `protocols/notification-protocol.md` | ntfy.sh notification spec |
| Run Log Spec | `protocols/run-log-specification.md` | Runner log format |
| Spec Conformance | `protocols/spec-conformance-check.md` | Design-intent alignment check |
| Tier 2.5 Triage | `protocols/tier-2.5-triage.md` | Automated issue triage |

## Template Index

| Template | Path | Used During |
|----------|------|-------------|
| Sprint Spec | `templates/sprint-spec.md` | Sprint planning Phase C |
| Design Summary | `templates/design-summary.md` | Sprint planning Phase B |
| Implementation Prompt | `templates/implementation-prompt.md` | Sprint planning Phase D |
| Review Prompt | `templates/review-prompt.md` | Sprint planning Phase D |
| Spec by Contradiction | `templates/spec-by-contradiction.md` | Sprint planning Phase C |
| Decision Entry | `templates/decision-entry.md` | Any decision logging |
| Fix Prompt | `templates/fix-prompt.md` | Runner auto-fix sessions |
| Doc-Sync Prompt | `templates/doc-sync-automation-prompt.md` | Runner post-sprint doc sync |
| Conformance Prompt | `templates/spec-conformance-prompt.md` | Runner conformance checks |
| Triage Prompt | `templates/tier-2.5-triage-prompt.md` | Runner automated triage |

## Schema Index

| Schema | Path | Used By |
|--------|------|---------|
| Run State | `schemas/run-state-schema.md` | Runner state persistence |
| Runner Config | `schemas/runner-config-schema.md` | Runner YAML configuration |
| Structured Close-Out | `schemas/structured-closeout-schema.md` | Tier 1 close-out JSON |
| Structured Verdict | `schemas/structured-review-verdict-schema.md` | Tier 2 review JSON |

---

## Version Tracking

When fetching a protocol, note the version header if present:
```
<!-- workflow-version: X.Y.Z -->
<!-- last-updated: YYYY-MM-DD -->
```

If mid-sprint and a protocol has changed since the sprint started, note the
version difference but continue with the version used at planning time.
Adopt the new version for the next sprint.

---

## What Stays in Project Knowledge (Not Here)

These are **project-specific** and belong in each project's own knowledge files:

- Project description and goals
- Current state (active sprint, test counts, infrastructure)
- Architecture document
- Sprint history and decision log references
- Risk register and deferred items
- Build track queue and roadmap
- Active constraints, costs, and tech stack details
- Communication style preferences
- Project-specific Claude rules summary
