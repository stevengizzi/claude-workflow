# Workflow Bootstrap Index

> This file is the sole workflow reference in this Claude.ai project's knowledge.
> All protocols, templates, and schemas live in the metarepo and are fetched on demand.
> **Do not duplicate protocol content in project knowledge files.**
>
> Metarepo: https://github.com/stevengizzi/claude-workflow
> Raw file base: https://raw.githubusercontent.com/stevengizzi/claude-workflow/main/

---

## How This Works

When a conversation requires a protocol or template, **clone the metarepo once**
at the start of the conversation and read files locally. This ensures every
conversation uses the latest version without manual syncing.

**Clone pattern (run once per conversation):**
```bash
git clone https://github.com/stevengizzi/claude-workflow.git /home/claude/workflow
```

**Then read files with:**
```
view /home/claude/workflow/{path}
```

This clones the entire repo in one network call. All subsequent reads are local
file operations — no additional fetches needed. The clone lives only for the
duration of the conversation; each new conversation gets a fresh copy.

**When to clone:** At the start of the conversation, once the conversation type
is identified. Clone the repo, then read only the files needed for the current
conversation type.

---

## Quick Start (New Users)

**If this is a brand new project and you're not sure how to begin:**
Start a conversation and say something like "How do I get started?" or
"Help me set up this project." Claude will read the Getting Started protocol
and walk you through everything step by step. No prior knowledge of this
workflow is required.

---

## Conversation Type → What to Read

### Getting Started (New Project Onboarding)
Read first:
- `protocols/getting-started.md`

This protocol guides new users through project setup from scratch. It assumes
no familiarity with the workflow system and explains concepts as they become
relevant. It routes to Discovery and Document Seeding when appropriate.

### Document Seeding (Post-Discovery Canon Creation)
Read first:
- `protocols/document-seeding.md`
- `scaffold/docs/` (all template files — for target structure reference)

This protocol creates the canon documents (project-knowledge.md, decision-log.md,
architecture.md, etc.) from Discovery outputs. Run this between Discovery and
Sprint 1 planning.

### Discovery (New Project Research)
- `protocols/discovery.md`

### Sprint Planning
Read first:
- `protocols/sprint-planning.md`

Read during artifact generation (Phase C/D):
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
- `templates/work-journal-closeout.md` (at sprint close, for generating the handoff)

### Impromptu Triage (Unplanned Work)
- `protocols/impromptu-triage.md`
- `templates/implementation-prompt.md`
- `templates/review-prompt.md`

### Campaign Orchestration / Absorption / Close
- **Campaign Orchestration / Absorption / Close** — read `protocols/campaign-orchestration.md` for the full protocol covering campaign absorption (§1), supersession (§2), authoritative-record preservation (§3), cross-track close-out (§4), pre-execution gates (§5), naming conventions (§6), DEBUNKED status (§7), absorption-vs-sequential decision matrix (§8), and the two-session SPRINT-CLOSE option (§9). Also read `protocols/sprint-planning.md` for per-session planning within the campaign.

### Operational Debrief / Post-Incident Review / Periodic Review
- **Operational Debrief / Post-Incident Review / Periodic Review** — read `protocols/operational-debrief.md` for the abstract pattern covering periodic operational debriefs, event-driven debriefs, and periodic-without-cycle reviews. Cross-reference `protocols/campaign-orchestration.md` §1 for absorbing debrief findings into ongoing campaigns. Project-specific debrief protocols (e.g., ARGUS's `docs/protocols/market-session-debrief.md`) instantiate this abstract pattern.

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
| Getting Started | `protocols/getting-started.md` | New user onboarding — first conversation ever |
| Document Seeding | `protocols/document-seeding.md` | Create canon docs from Discovery outputs |
| Discovery | `protocols/discovery.md` | New project kickoff research |
| Sprint Planning | `protocols/sprint-planning.md` | Core planning — produces full sprint package |
| Adversarial Review | `protocols/adversarial-review.md` | Stress-test sprint specs |
| Tier 3 Review | `protocols/tier-3-review.md` | Architectural review at phase boundaries |
| In-Flight Triage | `protocols/in-flight-triage.md` | Mid-sprint issue classification |
| Impromptu Triage | `protocols/impromptu-triage.md` | Scope and plan unplanned work |
| Campaign Orchestration | `protocols/campaign-orchestration.md` | Multi-session campaigns with persistent coordination state (5+ sessions, multi-track, accumulating registers) |
| Operational Debrief | `protocols/operational-debrief.md` | Recurring-event-driven knowledge streams (periodic / event-driven / periodic-without-cycle); execution-anchor-commit correlation pattern |
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
| Work Journal Close-Out | `templates/work-journal-closeout.md` | Sprint close (Work Journal conversation) |
| Stage Flow | `templates/stage-flow.md` | DAG artifact for multi-track or fork-join campaign execution graphs. ASCII / Mermaid / ordered-list formats. |
| Scoping Session Prompt | `templates/scoping-session-prompt.md` | Read-only scoping-session template producing structured findings + generated fix prompt for a follow-on implementation session. |

## Schema Index

| Schema | Path | Used By |
|--------|------|---------|
| Run State | `schemas/run-state-schema.md` | Runner state persistence |
| Runner Config | `schemas/runner-config-schema.md` | Runner YAML configuration |
| Structured Close-Out | `schemas/structured-closeout-schema.md` | Tier 1 close-out JSON |
| Structured Verdict | `schemas/structured-review-verdict-schema.md` | Tier 2 review JSON |

---

## Version Tracking

When reading a protocol, note the version header if present:
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

- Project description and goals (manifesto)
- Current state (active sprint, test counts, infrastructure)
- Architecture document
- Sprint history and decision log references
- Risk register and deferred items
- Build track queue and roadmap
- Active constraints, costs, and tech stack details
- Communication style preferences
- Project-specific Claude rules summary
