<!-- workflow-version: 1.0.0 -->
<!-- last-updated: 2026-04-26 -->

# Operational Debrief

A **recurring-event-driven knowledge stream** is a series of related debriefs/reviews/retrospectives produced at predictable cadence — sometimes periodic (e.g., daily, weekly), sometimes event-driven (e.g., post-incident, post-deployment), sometimes mid-event without a fixed cycle (e.g., quarterly architectural review). The stream accumulates project knowledge that's expensive to recover if any individual debrief is lost.

This protocol covers the abstract pattern. Project-specific debrief implementations (e.g., ARGUS's `market-session-debrief.md`, a deployment runbook's post-deploy retrospective, a service ops team's weekly health review) instantiate the pattern with project-specific roles, schedules, and artifacts. This metarepo protocol provides the abstraction; project-specific protocols handle the concretes.

For absorbing debrief findings into ongoing campaign work, see `protocols/campaign-orchestration.md` §1 (Campaign Absorption). Absorption is the read-side of the recurring-event-driven stream — what the campaign does with the findings the debrief produces.

## When This Protocol Applies

Apply when the project produces recurring debriefs/reviews/retrospectives that:
- Generate findings that must be acted on (DEFs, deferred items, judgment calls).
- Need to be correlated with the underlying execution state (which version was running, which deployment, which build).
- Accumulate over time into a knowledge stream (the Nth debrief references the (N-1)th's findings).

If the project produces only ad-hoc retrospectives (no cadence, no accumulating stream), use `protocols/sprint-planning.md` Phase A or `protocols/impromptu-triage.md` directly.

## 1. Three Recurring-Event Patterns

Recurring-event-driven knowledge streams come in three shapes. Identify which shape applies before adopting the pattern's machinery.

### 1.1 Periodic Operational Debrief

**Cadence:** Fixed, calendar-driven (daily, weekly, monthly).
**Trigger:** Time elapsed.
**Examples:**
- A trading system's daily post-market debrief covering the trading session's execution.
- An e-commerce service's weekly health review covering uptime, latency p99, error rates.
- A SaaS platform's monthly architectural review covering tech-debt accumulation, hotspot files, deferred refactors.

**Characteristic shape:** Each debrief covers a fixed time window. The debrief's audit trail is correlated with execution-anchor commits at the start and end of the window. The debrief produces findings that the next campaign or sprint absorbs.

### 1.2 Event-Driven Debrief

**Cadence:** Variable, event-driven.
**Trigger:** A specific event occurs (deployment, incident, customer escalation, regulatory event).
**Examples:**
- A post-incident review covering the SEV-1 outage on YYYY-MM-DD.
- A post-deployment retrospective covering the v2.7.0 release.
- A customer-escalation review covering the enterprise-customer ticket #XXX.

**Characteristic shape:** Each debrief covers the event scope (typically a window from "X minutes before symptom" to "X minutes after resolution"). The debrief's audit trail is correlated with the event-anchor (deployment SHA, incident timestamp, ticket ID). The debrief produces findings the next campaign absorbs OR a follow-on incident-prevention sprint takes on directly.

### 1.3 Periodic Review Without a Cycle

**Cadence:** Mid-event, no fixed cycle.
**Trigger:** Operator judgment that a review is due (architectural drift visible, tech-debt threshold exceeded, etc.).
**Examples:**
- A quarterly-ish architecture review (no fixed quarter; runs when operator judgment says due).
- A pre-fundraise codebase audit.
- A pre-acquisition due-diligence review.

**Characteristic shape:** Each review covers the project's current state at the review's start. The audit trail is correlated with the execution-anchor commit at review start (no end commit; the review IS the work). The review produces findings that often spawn a synthesis sprint or strategic check-in.

## 2. Execution-Anchor Commit Correlation

Each debrief in a recurring-event-driven stream MUST correlate its findings with an **execution-anchor commit** — a SHA that uniquely identifies the project state the findings apply to.

**For periodic debriefs (§1.1):** the anchor is typically a pair (start_commit, end_commit). The start_commit is the project's HEAD at the start of the time window; end_commit is HEAD at the end.

**For event-driven debriefs (§1.2):** the anchor is a single SHA — the deployment SHA, the SHA running at the time of the incident, the SHA in production at the time of the customer escalation.

**For periodic-without-cycle reviews (§1.3):** the anchor is the SHA at review start.

The execution-anchor commit is the **audit trail mechanism**. When a future sprint absorbs the debrief's findings, the sprint cites the anchor commit + the relevant code paths. If a finding turns out to be wrong (per `protocols/campaign-orchestration.md` §7 DEBUNKED status), the correction cites the anchor commit too — making the correction's scope explicit.

Recording the anchor commit is **operator-led**. The operator manually notes the SHA at debrief start (e.g., copies HEAD into the debrief document's metadata block).

**Recommended automation: project-specific.** Live systems with continuously-running daemons can write the anchor commit to a known path at startup (e.g., a daemon writing `logs/boot-history.jsonl` with one line per startup containing timestamp + SHA + brief metadata). Whether to automate, where to log to, and what additional metadata to capture is a project-specific decision — the metarepo doesn't prescribe.

For ARGUS's specific implementation of automation, see ARGUS's deferred-items list (the boot-commit-logging automation is tracked there).

<!-- Origin: synthesis-2026-04-26 evolution-note-2 (debrief-absorption) +
     Phase A pushback round 2. The 4-tag safety taxonomy was empirically
     overruled during ARGUS Sprint 31.9: the operator ran fixes during
     active market sessions regardless of tag, using the boot-commit-pair
     correlation as the actual audit-trail mechanism. The execution-
     anchor-commit pattern formalizes that mechanism. -->

## 3. Three Non-Trading Examples

The metarepo intentionally avoids ARGUS-specific terminology. The pattern applies broadly. Three non-trading instantiations:

### 3.1 Deployment Retrospective (Event-Driven)

A SaaS platform deploys v2.7.0 at 14:32 UTC. The post-deployment retrospective runs the next morning, covering the deployment window. Findings:
- The new feature flag rollout had unintended cache-invalidation effects in the staging environment.
- Three customers reported intermittent 502s in the first hour post-deploy.
- The deployment script's pre-deploy migration step took 11 minutes (vs the 4-minute baseline).

**Execution-anchor commit:** `<v2.7.0 SHA>`. All findings reference this SHA + relevant file paths.

### 3.2 Post-Incident Review (Event-Driven)

A payments service experiences a SEV-1 outage at 09:14 UTC affecting 3% of transactions for 47 minutes. The post-incident review runs that afternoon. Findings:
- The root cause was a connection-pool exhaustion under unexpected load.
- The service's monitoring did not page until 11 minutes after symptom onset.
- The runbook's "restart the database connection pool" instruction was missing the hold-flag prerequisite.

**Execution-anchor commit:** `<SHA running at 09:14 UTC>`. The runbook-fix follow-on sprint cites this SHA when adding the hold-flag prerequisite.

### 3.3 Weekly Health Review (Periodic)

A 4-person backend team runs a Monday-morning weekly health review. The review covers the prior week's deploys (12), open Sentry alerts (4), p99 latency drift (within bounds), and tech-debt items added (2). Findings:
- An open Sentry alert from 4 days ago is still un-investigated.
- The 02:00 UTC scheduled task had 2 failures during the week (vs typical 0).
- The migration scheduled for next week needs a pre-check on table sizes.

**Execution-anchor commits:** start (Monday previous week's HEAD) and end (Monday this week's HEAD). All findings reference both SHAs (e.g., the Sentry alert was raised against the Wednesday-mid-week SHA — that SHA is recorded in the alert; the review references it).

## 4. Cross-References

- `protocols/campaign-orchestration.md` §1 — how the campaign absorbs debrief findings.
- `protocols/sprint-planning.md` — when a debrief's findings spawn a planning conversation.
- `protocols/impromptu-triage.md` — when a debrief's findings warrant an immediate impromptu sprint vs. queueing.

## 5. Project-Specific Implementations

This metarepo protocol is the abstract pattern. Project-specific protocols document the concrete cadence, roles, artifacts, and tooling. Examples:

- **ARGUS** (`docs/protocols/market-session-debrief.md`): periodic operational debrief covering the daily trading session. Cadence: daily, post-market. Anchor: boot-commit pair (start, end). Findings: DEFs, candidate retrospective patterns. Absorbs into the next sprint or campaign.

Other projects following this pattern would have their own project-specific protocol documenting their cadence + roles + artifacts.
