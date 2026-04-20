# Schema: Runner Configuration

**Referenced by:** DEC-278, DEC-279, DEC-286, DEC-287
**Location:** `config/runner.yaml`

---

## Overview

The runner configuration file controls the orchestrator's behavior. It is a
YAML file validated by a Pydantic model at runner startup. All fields have
sensible defaults — the minimal config only requires the sprint directory path.

## Schema

```yaml
# runner-config.yaml — Autonomous Sprint Runner Configuration

# --------------------------------------------------------------------------
# Sprint Package Location
# --------------------------------------------------------------------------
sprint:
  # Path to the sprint directory containing prompts and review context
  directory: "docs/sprints/sprint-23"

  # Session execution order (list of session IDs matching prompt filenames)
  # If omitted, runner reads session-breakdown.md and infers order
  # IMPORTANT: Each session_id here maps to prompt files named:
  #   {sprint_dir}/sprint-{N}-{session_id}-impl.md
  #   {sprint_dir}/sprint-{N}-{session_id}-review.md
  # Example: session_id "session-1" in sprint-24.5 → sprint-24.5-session-1-impl.md
  session_order:
    - "session-1"
    - "session-2"
    - "session-3"
    - "session-4"

  # Path to the review context file (shared across all review prompts)
  review_context_file: "docs/sprints/sprint-23/review-context.md"

# --------------------------------------------------------------------------
# Execution Mode
# --------------------------------------------------------------------------
execution:
  # autonomous | human-in-the-loop
  # autonomous: runner drives the full loop, halting only on ESCALATE/errors
  # human-in-the-loop: runner assists with structured output and logging only
  mode: "autonomous"

  # Maximum retries per session for transient failures
  max_retries: 2

  # Base delay between retries (seconds). Uses exponential backoff:
  # first retry = retry_delay_seconds, second = retry_delay_seconds × 4
  retry_delay_seconds: 30

  # Maximum wall-clock time per session (seconds). 0 = no limit.
  session_timeout_seconds: 0

  # Enable agent teams for sessions flagged as parallelizable
  enable_agent_teams: false

  # Claude Code model override (null = use default from .claude/settings.json)
  model_override: null

  # Test count tolerance for independent verification (DEC-291).
  # If actual count differs from close-out by more than this, halt.
  test_count_tolerance: 0

  # Output size threshold (bytes) for compaction detection (DEC-293).
  # Sessions with output exceeding this are flagged as compaction-likely.
  compaction_threshold_bytes: 102400  # 100KB

# --------------------------------------------------------------------------
# Git
# --------------------------------------------------------------------------
git:
  # Branch to operate on. Runner verifies this at startup.
  branch: "main"

  # Commit message format. Placeholders: {sprint}, {session_id}, {title}
  commit_message_format: "[Sprint {sprint}] Session {session_id}: {title}"

  # Whether to auto-commit after each CLEAR session
  auto_commit: true

  # Whether to save .patch files for all sessions (including failed)
  save_patches: true

# --------------------------------------------------------------------------
# Notifications
# --------------------------------------------------------------------------
notifications:
  # Per-tier enable/disable toggles
  tiers:
    HALTED: true            # Non-negotiable — always on
    SESSION_COMPLETE: true   # Recommended: always on
    PHASE_TRANSITION: true   # First runs: on. Disable once trust established.
    WARNING: true            # Recommended: always on
    COMPLETED: true          # Always on

  # Primary channel
  primary:
    type: "ntfy"
    endpoint: "https://ntfy.sh/my-project-runner"
    # Optional authentication token for private topics
    auth_token: null

  # Optional redundancy channel(s)
  secondary: []
    # - type: "slack"
    #   webhook_url: "https://hooks.slack.com/services/..."
    # - type: "email"
    #   smtp_host: "smtp.gmail.com"
    #   smtp_port: 587
    #   from: "runner@example.com"
    #   to: "steven@example.com"

  # Quiet hours (UTC). Suppresses SESSION_COMPLETE, PHASE_TRANSITION, and
  # WARNING notifications. HALTED and COMPLETED always send regardless.
  quiet_hours:
    enabled: true
    # Operator is on US East Coast (ET). Quiet hours = overnight.
    # US market hours (9:30 AM - 4:00 PM ET) are active trading time.
    start_utc: "05:00"  # 1 AM ET — well after market close
    end_utc: "13:00"    # 9 AM ET — before US pre-market ramp-up

  # Re-notify if HALTED goes unacknowledged for this many minutes
  halted_reminder_minutes: 60

# --------------------------------------------------------------------------
# Cost Tracking
# --------------------------------------------------------------------------
cost:
  # Estimated cost ceiling per sprint run (USD). Runner halts if exceeded.
  ceiling_usd: 50.0

  # Token-to-cost conversion rates (per 1M tokens)
  # Used for estimation when running via subscription (not API billing)
  rates:
    input_per_million: 3.0     # Sonnet 4.6 default
    output_per_million: 15.0
    cached_input_per_million: 0.30

  # Whether to halt on ceiling breach or just warn
  halt_on_ceiling: true

# --------------------------------------------------------------------------
# Run Log
# --------------------------------------------------------------------------
run_log:
  # Base directory for run logs (relative to repo root)
  # Actual path: {base_directory}/run-log/
  base_directory: "docs/sprints/sprint-23"

  # Whether to auto-generate work-journal.md after each session
  auto_generate_journal: true

  # Whether to commit run-log changes to git after each session
  commit_run_log: true

# --------------------------------------------------------------------------
# Tier 2.5 Triage
# --------------------------------------------------------------------------
triage:
  # Whether to enable automated Tier 2.5 triage
  enabled: true

  # Path to the triage prompt template
  prompt_template: "docs/protocols/templates/tier-2.5-triage-prompt.md"

  # Auto-insert fix sessions for Category 1-2 issues
  auto_insert_fixes: true

  # Maximum fix sessions to auto-insert per sprint before halting
  max_auto_fixes: 3

  # Path to the fix prompt template (used for auto-generated fix sessions)
  fix_prompt_template: "docs/protocols/templates/fix-prompt.md"

# --------------------------------------------------------------------------
# Spec Conformance Check
# --------------------------------------------------------------------------
conformance:
  # Whether to run spec conformance check after each session
  enabled: true

  # Path to the conformance check prompt template
  prompt_template: "docs/protocols/templates/spec-conformance-prompt.md"

  # What to do on DRIFT-MINOR
  drift_minor_action: "warn"  # warn | halt

  # What to do on DRIFT-MAJOR
  drift_major_action: "halt"  # always halt

# --------------------------------------------------------------------------
# Doc Sync
# --------------------------------------------------------------------------
doc_sync:
  # Whether to run automated doc-sync after all sessions complete
  enabled: true

  # Path to the doc-sync prompt template
  prompt_template: "docs/protocols/templates/doc-sync-automation-prompt.md"

  # Documents to update (overridden by doc-sync-queue.jsonl at runtime)
  target_documents:
    - "docs/project-knowledge.md"
    - "docs/architecture.md"
    - "docs/decision-log.md"
    - "docs/dec-index.md"
    - "docs/sprint-history.md"
    - "CLAUDE.md"
```

## Pydantic Model

The runner validates this config at startup using a Pydantic model. Key
validation rules:

- `execution.mode` must be one of the enum values
- `execution.max_retries` must be 0–5
- `cost.ceiling_usd` must be > 0
- `triage.max_auto_fixes` must be 0–10
- `notifications.quiet_hours.start_utc` and `end_utc` must be valid HH:MM
- `notifications.tiers.HALTED` must be true (cannot disable)
- `notifications.tiers.COMPLETED` must be true (cannot disable)
- `sprint.directory` must exist on disk
- `sprint.session_order` items must have corresponding prompt files

## Environment Variables

The runner also respects these environment variables (override config values):

| Variable | Overrides | Purpose |
|----------|-----------|---------|
| `WORKFLOW_RUNNER_MODE` | `execution.mode` | Quick mode switch |
| `WORKFLOW_RUNNER_SPRINT_DIR` | `sprint.directory` | Sprint directory path |
| `NTFY_TOPIC` | `notifications.primary.endpoint` | Notification endpoint |
| `WORKFLOW_COST_CEILING` | `cost.ceiling_usd` | Cost ceiling override |

## Mode Behavior

- **Autonomous mode:** All features active. Runner drives the full loop.
- **Human-in-the-loop mode:** Runner produces structured output and run logs
  but does not auto-proceed between sessions. Acts as an enhanced logging
  and record-keeping layer for manual execution.
