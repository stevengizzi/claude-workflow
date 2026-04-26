<!-- workflow-version: 1.0.0 -->
<!-- last-updated: 2026-04-26 -->

# Campaign Orchestration

A **campaign** is a multi-session work effort with persistent coordination state — typically 5+ sessions over multiple days, often with multiple parallel tracks, an accumulating findings/DEFs/judgment register, and a non-trivial close-out narrative. Campaigns differ from standard sprints in shape and require additional coordination machinery.

This protocol covers: campaign absorption (folding new mid-campaign work into ongoing tracks), supersession (when a later artifact replaces an earlier one), authoritative-record preservation (sealing campaign internals at close), cross-track close-out, pre-execution gates, naming conventions, DEBUNKED finding status, the absorption-vs-sequential decision matrix, and the two-session SPRINT-CLOSE option for campaigns whose close-out itself merits its own session pair.

For the recurring-event-driven knowledge-stream patterns (operational debriefs, post-incident reviews, periodic operational reviews) see `protocols/operational-debrief.md`. For the impromptu-vs-extend-current-sprint decision see `protocols/impromptu-triage.md`. For multi-stage execution DAGs see `templates/stage-flow.md`.

## When This Protocol Applies

Apply when a sprint or work effort has at least 2 of:
- 5+ sessions executed serially or in parallel.
- A persistent coordination surface (a Claude.ai conversation, an issue tracker with a campaign label, a wiki page with a running register — any persistent artifact tracking work-in-flight beyond a single session).
- Cross-session findings, DEFs, or judgment calls that accumulate (not just per-session deltas).
- A close-out that requires synthesizing across sessions (not just summarizing the last one).

Standard sprints (3–8 serial sessions, single coordination thread) use `protocols/sprint-planning.md` directly without this protocol's machinery.

## 1. Campaign Absorption

When new work surfaces mid-campaign — a new finding, an unexpected DEF closure opportunity, an in-flight scope addition — the campaign coordination surface decides whether to ABSORB the work into the ongoing campaign or DEFER it to a follow-on. The decision uses the absorption decision matrix (§8 below).

Absorption is judged along these axes (campaign-specific specifics vary; these are the typical dimensions):

- **Work-execution state.** Is the relevant track currently executing, between sessions, or post-close? Absorbing into a running session is high-risk; absorbing between sessions is low-risk; absorbing post-close requires reopening (high-cost).
- **Incoming-work size.** Is the new work a single small fix (1 session of effort), a feature (2–4 sessions), or a meaningful pivot (5+ sessions)? Larger work is biased toward DEFER.
- **Cross-track impact.** Does the new work affect tracks beyond the surfacing track? If yes, absorption requires cross-track coordination; bias toward DEFER unless coordination cost is tractable.
- **Operator-judgment availability.** Is the operator available within the absorption window? If not, defer.

When absorbing, the campaign coordination surface generates a brief absorption note (typically 1–2 paragraphs) and updates the running register. The new work joins the campaign's execution graph; downstream sessions reference the updated graph.

When deferring, the campaign coordination surface logs a DEFERRED entry in the running register with a clear trigger condition (e.g., "Next sprint touching X" or "Next strategic check-in").

<!-- Origin: synthesis-2026-04-26 evolution-note-2 (debrief-absorption).
     Generalized from ARGUS Sprint 31.9 campaign-close where mid-campaign
     findings (DEF-204 mechanism diagnostic, IMPROMPTU-04, etc.) were
     absorbed via this two-axis judgment + running-register update
     pattern. -->

## 2. Supersession Convention

When a later campaign-internal artifact replaces an earlier one — for example, a refined version of a CAMPAIGN-CLOSE-PLAN supersedes the original after a mid-campaign pivot — the new artifact is named with a SUPERSEDES-ANNOTATION at the top:

```
**SUPERSEDES:** CAMPAIGN-CLOSE-PLAN-v1.md (committed YYYY-MM-DD; replaced YYYY-MM-DD because <reason>).
```

The superseded artifact is NOT deleted. It remains in the campaign folder, with an `**SUPERSEDED-BY:**` annotation added at its top:

```
**SUPERSEDED-BY:** CAMPAIGN-CLOSE-PLAN-v2.md (committed YYYY-MM-DD; this version replaced because <reason>).
```

Both artifacts persist as authoritative-record. The supersession chain reads forward from any superseded artifact to its current replacement.

## 3. Authoritative-Record Preservation

At campaign close, the campaign folder contains:
- The campaign-close artifacts (CAMPAIGN-CLOSE-PLAN, RUNNING-REGISTER, CAMPAIGN-COMPLETENESS-TRACKER, etc.).
- Per-session close-outs and reviews.
- The campaign synthesis SUMMARY.md (the operator-facing one-pager).
- Any superseded prior versions (per §2).

This entire folder is then **sealed**. No subsequent commit modifies its contents. If a future sprint references campaign findings, it does so by reference (citing the campaign folder + relevant section), not by edit.

The sealing convention prevents post-hoc rewriting of campaign history. If a finding turns out to be wrong (per §7 DEBUNKED status), the correction lives in a NEW artifact, not as an edit to the original.

For RETRO-FOLD-style synthesis sprints that consume campaign artifacts, the consumed artifacts retain their byte-frozen state; the synthesis sprint produces NEW protocol/template content that cites the campaign artifacts as Origin evidence.

<!-- Origin: synthesis-2026-04-26 N1.6 (sealed campaign folders). ARGUS
     Sprint 31.9's campaign folder (`docs/sprints/sprint-31.9/`) is the
     reference instance of this pattern: 39 files, sealed at close,
     never edited subsequently. Synthesis sprints (this one) consume
     them as Origin references. -->

## 4. Cross-Track Close-Out

A multi-track campaign produces close-out artifacts per track AND a cross-track synthesis. The cross-track synthesis covers:

- Per-track outcomes (one line each).
- Cross-track findings (anything that surfaced in 2+ tracks).
- Cross-track recommendations (anything affecting future campaigns or sprints).
- Per-track deferrals (consolidated).

The cross-track synthesis is the campaign's primary handoff to the next planning conversation. Per-track close-outs serve as deeper reference but are not the primary input.

## 5. Pre-Execution Gate

Before any campaign session executes, the pre-execution gate verifies:

- [ ] All prior session close-outs are present in the campaign folder.
- [ ] All prior Tier 2 reviews are CLEAR or CONCERNS_RESOLVED (no open ESCALATE or unresolved CONCERNS).
- [ ] The running register is current (last update timestamp ≤ 24h old, or operator-judgment override).
- [ ] The session being initiated is the next in the execution graph (not skipping a dependency).
- [ ] If the session is parallel-tracked, the parallel track's coordination state has been read.

Failure on any item halts session execution until resolved. The gate is encoded in the session's implementation-prompt Pre-Flight section as explicit grep + ls + state-check commands.

## 6. Naming Conventions

Campaign-internal artifacts use prefix-style names that signal their role:

| Prefix | Meaning |
|---|---|
| `CAMPAIGN-CLOSE-PLAN.md` | The campaign-close planning artifact (one per campaign) |
| `CAMPAIGN-CLOSE-A-`, `CAMPAIGN-CLOSE-B-`, ... | Sequential close-out sessions during the campaign-close phase |
| `CAMPAIGN-COMPLETENESS-TRACKER.md` | Cross-session completeness checklist |
| `RUNNING-REGISTER.md` | Accumulating findings/DEFs/judgment register |
| `SPRINT-CLOSE-A-`, `SPRINT-CLOSE-B-`, ... | Sessions in the two-session SPRINT-CLOSE pattern (§9 below) |
| `IMPROMPTU-NN-` | Mid-campaign impromptu sessions (NN = sequential) |
| `FIX-NN-<kebab-name>` | A specific fix work-item; NN sequential within campaign |

The naming is a convention not a hard rule; campaigns adopt it for legibility. Departures should be conscious decisions, not drift.

## 7. DEBUNKED Finding Status

A finding initially recorded as a DEF or candidate may, on later investigation, turn out to be wrong (the symptom was misdiagnosed, the root cause was different, the original analysis used incorrect data). When this happens, the finding is marked DEBUNKED — not closed, not resolved, but explicitly invalidated.

DEBUNKED status differs from CLOSED:
- CLOSED: the issue was real and is now fixed.
- DEBUNKED: the issue was not real; the original analysis was wrong.

A DEBUNKED entry includes:
- The original finding text (preserved).
- A `**DEBUNKED:**` annotation with date, reason, and reference to the corrective analysis.
- A pointer to the new finding (if any) that the corrective analysis surfaced.

DEBUNKED status protects the audit trail. Without it, an operator scanning closed findings would not know that one of them was actually a misdiagnosis.

<!-- Origin: synthesis-2026-04-26 evolution-note-2 + ARGUS Sprint 31.9
     campaign-close where DEF-XXX (stale during campaign-close debugging)
     was identified as DEBUNKED rather than auto-closed. -->

## 8. Absorption-vs-Sequential Decision Matrix

For each candidate piece of new mid-campaign work, evaluate:

| Dimension | Bias toward ABSORB | Bias toward DEFER |
|---|---|---|
| Work size | ≤1 session | ≥2 sessions |
| Cross-track impact | Single track | Multi-track |
| Execution-state of relevant track | Between sessions | Mid-session |
| Operator availability | Available now | Unavailable in next 24h |
| Current campaign load | Light (1–2 active tracks) | Heavy (3+ active tracks) |
| Risk of context-window blow-up if absorbed | Low | Medium-to-high |
| Strategic urgency | Imminent (blocks downstream work) | Non-blocking |

Apply the matrix as judgment, not algorithm. If the dimensions point in conflicting directions, default to DEFER (lower-risk default). Document the decision in the running register either way.

## 9. Two-Session SPRINT-CLOSE Option

For campaigns where the close-out itself is non-trivial — multi-track synthesis, large doc-sync, formal handoff — the close-out runs as TWO sessions instead of folding into the final implementation session:

- **SPRINT-CLOSE-A.md:** First close-out session. Runs the §4 cross-track close-out narrative, drafts the campaign SUMMARY, drafts the doc-sync prompts, identifies any deferred items.
- **SPRINT-CLOSE-B.md:** Second close-out session. Lands the doc-sync, finalizes the SUMMARY, seals the campaign folder per §3.

The split is appropriate when SPRINT-CLOSE work would push the close-out session past compaction-risk limits (typically score ≥14 per `protocols/sprint-planning.md` Phase A). Standard sprints fold close-out into the final implementation session.

<!-- Origin: synthesis-2026-04-26 P33. ARGUS Sprint 31.9 ran
     SPRINT-CLOSE-A and SPRINT-CLOSE-B as a paired two-session structure
     because the close-out (cross-track synthesis + 12 between-session
     doc-syncs + final SUMMARY) would have blown a single session's
     context budget. -->

## 10. Appendix: 7-Point Check (Optional, Conditionally Applies)

[*This appendix applies only when the campaign coordination surface is a long-lived Claude.ai conversation that produces handoff prompts for Claude Code sessions. Other coordination surfaces (issue trackers, wikis) have their own native verification mechanisms and do not need this check. Skip the appendix if your coordination surface is not a long-lived Claude.ai conversation.*]

When a Claude.ai conversation operates as a campaign coordination surface — accumulating context across many sessions, generating multiple handoff prompts, tracking the running register — the conversation is at risk of compaction and silent context loss. The 7-point check verifies the conversation's state at planned checkpoints (typically before generating each session's handoff prompt):

1. **Session count.** Is the next session-to-handoff the expected sequential session? (Off-by-one would indicate skipped state.)
2. **Running register currency.** Does the conversation have the latest running register state in context? (Stale register → missed updates.)
3. **Cross-track state.** If the campaign has parallel tracks, is the conversation aware of all tracks' current state? (Track drift → coordination errors.)
4. **Open ESCALATE/CONCERNS resolution.** Are any prior sessions' Tier 2 reviews still open with unresolved findings? (Open findings → premature next session.)
5. **Recent commit alignment.** Does the conversation's understanding of `main` HEAD match the actual git state? (Drift → stale handoff.)
6. **Sprint-spec scope drift.** Has the campaign's actual work drifted from the sprint-spec scope? (Drift → re-scope needed before continuing.)
7. **Compaction self-check.** Is any of the above context degraded or contradictory? (Yes → halt and reload from authoritative artifacts.)

The 7-point check is a discipline, not a tool. The campaign coordination surface runs through it before generating each handoff prompt. Failure on any point halts handoff generation until resolved (typically by reloading from the running register and recent close-outs).

<!-- Origin: synthesis-2026-04-26 P32. ARGUS Sprint 31.9's campaign-tracking
     conversation ran a similar 7-point pattern manually before each
     session handoff. Codifying as appendix (rather than a standalone
     protocol) because the check is conditional on the coordination
     surface shape — only Claude.ai conversations need it. Other
     coordination surfaces (issue trackers, wikis) get their state from
     the native tooling rather than from accumulated conversation
     context. F10: conditional framing applied. -->

## Cross-References

- `protocols/operational-debrief.md` — recurring-event-driven knowledge streams (operational debriefs, post-incident reviews) that feed campaign absorption (§1).
- `protocols/impromptu-triage.md` — when to absorb mid-campaign vs. spawn impromptu sprint vs. defer.
- `protocols/sprint-planning.md` — protocol invoked by the campaign coordination surface for each session's planning.
- `templates/stage-flow.md` — DAG artifact template for multi-track campaign execution graphs.
- `templates/work-journal-closeout.md` §"Hybrid Mode" — non-standard-shape close-out structure for campaigns.
- `templates/doc-sync-automation-prompt.md` §"Between-Session Doc-Sync" — for campaign-internal find/replace patches.
- `claude/skills/close-out.md` — per-session close-out skill (used by every campaign session).
