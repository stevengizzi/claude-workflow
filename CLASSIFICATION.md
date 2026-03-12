# ARGUS → Metarepo File Classification

> This document maps every workflow-related file in the ARGUS repo to its
> destination in the metarepo migration. Use this as a checklist during migration.

---

## Files That Move to Metarepo

### Protocols (docs/protocols/ → workflow/protocols/)

| ARGUS Path | Metarepo Path | Notes |
|------------|---------------|-------|
| `docs/protocols/sprint-planning.md` | `protocols/sprint-planning.md` | Core protocol |
| `docs/protocols/adversarial-review.md` | `protocols/adversarial-review.md` | |
| `docs/protocols/tier-3-review.md` | `protocols/tier-3-review.md` | Remove ARGUS-specific examples |
| `docs/protocols/in-flight-triage.md` | `protocols/in-flight-triage.md` | |
| `docs/protocols/impromptu-triage.md` | `protocols/impromptu-triage.md` | |
| `docs/protocols/discovery.md` | `protocols/discovery.md` | Remove ARGUS reference in anti-patterns |
| `docs/protocols/strategic-check-in.md` | `protocols/strategic-check-in.md` | |
| `docs/protocols/codebase-health-audit.md` | `protocols/codebase-health-audit.md` | |
| `docs/protocols/retrofit-survey.md` | `protocols/retrofit-survey.md` | |
| `docs/protocols/autonomous-sprint-runner.md` | `protocols/autonomous-sprint-runner.md` | |
| `docs/protocols/notification-protocol.md` | `protocols/notification-protocol.md` | |
| `docs/protocols/run-log-specification.md` | `protocols/run-log-specification.md` | |
| `docs/protocols/spec-conformance-check.md` | `protocols/spec-conformance-check.md` | |
| `docs/protocols/tier-2.5-triage.md` | `protocols/tier-2.5-triage.md` | |

### Templates (docs/protocols/templates/ → workflow/templates/)

| ARGUS Path | Metarepo Path |
|------------|---------------|
| `docs/protocols/templates/sprint-spec.md` | `templates/sprint-spec.md` |
| `docs/protocols/templates/design-summary.md` | `templates/design-summary.md` |
| `docs/protocols/templates/implementation-prompt.md` | `templates/implementation-prompt.md` |
| `docs/protocols/templates/review-prompt.md` | `templates/review-prompt.md` |
| `docs/protocols/templates/spec-by-contradiction.md` | `templates/spec-by-contradiction.md` |
| `docs/protocols/templates/decision-entry.md` | `templates/decision-entry.md` |
| `docs/protocols/templates/fix-prompt.md` | `templates/fix-prompt.md` |
| `docs/protocols/templates/doc-sync-automation-prompt.md` | `templates/doc-sync-automation-prompt.md` |
| `docs/protocols/templates/spec-conformance-prompt.md` | `templates/spec-conformance-prompt.md` |
| `docs/protocols/templates/tier-2.5-triage-prompt.md` | `templates/tier-2.5-triage-prompt.md` |

### Schemas (docs/protocols/schemas/ → workflow/schemas/)

| ARGUS Path | Metarepo Path |
|------------|---------------|
| `docs/protocols/schemas/run-state-schema.md` | `schemas/run-state-schema.md` |
| `docs/protocols/schemas/runner-config-schema.md` | `schemas/runner-config-schema.md` |
| `docs/protocols/schemas/structured-closeout-schema.md` | `schemas/structured-closeout-schema.md` |
| `docs/protocols/schemas/structured-review-verdict-schema.md` | `schemas/structured-review-verdict-schema.md` |

### Claude Skills (.claude/skills/ → workflow/claude/skills/)

| ARGUS Path | Metarepo Path | Notes |
|------------|---------------|-------|
| `.claude/skills/close-out.md` | `claude/skills/close-out.md` | Universal |
| `.claude/skills/review.md` | `claude/skills/review.md` | Universal |
| `.claude/skills/canary-test.md` | `claude/skills/canary-test.md` | Universal |
| `.claude/skills/diagnostic.md` | `claude/skills/diagnostic.md` | Universal |
| `.claude/skills/doc-sync.md` | `claude/skills/doc-sync.md` | Universal |

### Claude Agents (.claude/agents/ → workflow/claude/agents/)

| ARGUS Path | Metarepo Path |
|------------|---------------|
| `.claude/agents/builder.md` | `claude/agents/builder.md` |
| `.claude/agents/reviewer.md` | `claude/agents/reviewer.md` |
| `.claude/agents/doc-sync-agent.md` | `claude/agents/doc-sync-agent.md` |

### Universal Rules (.claude/rules/ → workflow/claude/rules/)

| ARGUS Path | Metarepo Path | Notes |
|------------|---------------|-------|
| `.claude/rules/universal.md` | `claude/rules/universal.md` | Already self-describes as metarepo-sourced |

### Runner (scripts/ → workflow/runner/)

| ARGUS Path | Metarepo Path | Notes |
|------------|---------------|-------|
| `scripts/sprint-runner.py` | `runner/sprint-runner.py` | Generalize docstring |
| `scripts/sprint_runner/*.py` (13 files) | `runner/sprint_runner/*.py` | Generalize ARGUS_ env var prefix |

---

## Files That Stay in ARGUS (Project-Specific)

### Claude Rules (.claude/rules/)

| File | Why It Stays |
|------|-------------|
| `architecture.md` | ARGUS component isolation, Event Bus rules |
| `backtesting.md` | VectorBT sweep architecture, ARGUS-specific |
| `code-style.md` | Python type hint rules (partially universal — see notes) |
| `doc-updates.md` | ARGUS doc update protocol with specific doc names |
| `risk-rules.md` | Order flow path, risk management rules |
| `sprint_14_rules.md` | Legacy sprint-specific contracts |
| `testing.md` | ARGUS test structure mirroring |
| `trading-strategies.md` | Strategy development rules |

### Documentation (docs/)

All of these are project-specific:
- `project-knowledge.md`, `project-bible.md`, `architecture.md`
- `decision-log.md`, `dec-index.md`, `risk-register.md`
- `sprint-history.md`, `roadmap.md`, `sprint-campaign.md`
- `live-operations.md`, `paper-trading-guide.md`
- `strategies/`, `research/`, `backtesting/`, `ui/`, `guides/`
- `sprints/` (all sprint artifacts)

### CLAUDE.md

Project-specific. Not extracted.

### Source Code, Tests, Config

Obviously project-specific.

---

## Partially Universal Files (Need Splitting)

These ARGUS files contain both universal and project-specific content:

### `.claude/rules/code-style.md`
- **Universal portion:** Type hints required, descriptive naming, PEP 8 base
- **ARGUS-specific:** Specific import ordering, ARGUS naming conventions
- **Recommendation:** Extract universal code style rules into a new
  `claude/rules/code-style-base.md` in the metarepo. ARGUS keeps its
  version that adds project-specific extensions.

### `.claude/rules/doc-updates.md`
- **Universal portion:** "Update docs after every session" principle, audit checklist
- **ARGUS-specific:** Specific doc names (Decision Log, Architecture, Bible, etc.)
- **Recommendation:** The universal principle is already in `universal.md` (RULE-014
  through RULE-018). The ARGUS-specific file adds doc-name specifics. Keep in ARGUS.

### `.claude/rules/testing.md`
- **Universal portion:** Mirror source tree, descriptive test names, no test deletion
- **ARGUS-specific:** Specific directory mappings, ARGUS fixture patterns
- **Recommendation:** Same as code-style — extract base rules to metarepo,
  ARGUS extends. Low priority since universal.md already covers the key principles.

### `docs/process-evolution.md`
- **Content:** Narrative history of how the workflow evolved across ARGUS
- **Recommendation:** Keep in ARGUS as project-specific history. The metarepo
  could have its own `docs/methodology-origins.md` that summarizes the key
  learnings without ARGUS-specific narrative.

---

## Claude.ai Project Knowledge Migration

### Remove from ARGUS Claude.ai project (replaced by bootstrap-index):
- `adversarial-review.md`
- `discovery.md`
- `strategic-check-in.md`
- `codebase-health-audit.md`
- `retrofit-survey.md`
- `tier-3-review.md`
- `impromptu-triage.md`
- `in-flight-triage.md`
- `sprint-planning.md`
- `spec-by-contradiction.md`
- `decision-entry.md`
- `sprint-spec.md`
- `design-summary.md`
- `implementation-prompt.md`
- `review-prompt.md`

### Add to ARGUS Claude.ai project:
- `bootstrap-index.md` (from metarepo)

### Keep in ARGUS Claude.ai project (project-specific):
- `My_Day_Trading_Manifesto`
- Project Knowledge document (pasted in conversation or as knowledge file)
- Any other ARGUS-specific context files
