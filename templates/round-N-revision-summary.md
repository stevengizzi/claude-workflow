<!-- workflow-version: 1.0.0 -->
<!-- last-updated: 2026-05-12 -->
# Round-N Revision Summary Template

> **Purpose:** Canonical structure for documenting the revision pass following a Round-N adversarial review verdict of REVISE (non-surgical-class).
>
> **When to use:** Round-N verdict = REVISE; substantive architectural rework required; ≥3 new architectural amendments OR ≥1 new FAI entry expected.
>
> **When NOT to use:** Round-N verdict = REVISE (surgical-class) — use `templates/round-N-surgical-fix-summary.md` instead.
>
> **Codified from:** synthesis-sprint-31.92.7 T-1 (validated across Sprint 31.92.7 Round 2 + Sprint 31.92.65 Round 2).

---

## Frontmatter

- **Sprint:** `<sprint-id>` (e.g., `sprint-31.92.7`)
- **Round number being revised:** Round `<N-1>` verdict → Round `<N>` revision pass
- **Round-(N-1) verdict reference:** path + commit SHA (e.g., `docs/sprints/sprint-31.92.7/adversarial-review-verdict.md` @ `6ad9fb85`)
- **Anchor SHA at revision-pass start:** `git rev-parse HEAD` captured at start (e.g., `abc1234`)
- **Anchor SHA at revision-pass end:** captured at commit-time (e.g., `def5678`)

## Section 1 — Fork Decisions (DO NOT RE-LITIGATE)

Lists architectural fork decisions made during the revision pass. Each entry includes:

- **Fork identifier** (e.g., "Fork A vs Fork B" / "Path α vs Path β")
- **Decision:** which fork was selected
- **Rationale:** 2–4 sentences explaining the empirical or design basis
- **Rejected-alternatives cross-reference:** path to `spec-by-contradiction.md` §"Rejecting <alternative>" subsection (mandatory — failure to record rejection in spec-by-contradiction is a Round-(N+1) audit finding)

> **Do not re-litigate:** these fork decisions are sealed for the remainder of the sprint. Any later revision must explicitly supersede them with a new fork decision entry.

## Section 2 — Amendments Executed (table)

| Amendment ID | Concern source (Round-(N-1) reviewer note ID) | File(s) modified | Commit SHA | Verification status |
|---|---|---|---|---|
| AMD-1 | C-1 (Critical) | `argus/foo.py` + `tests/test_foo.py` | `commit-sha` | VERIFIED |
| AMD-2 | C-3 (Critical) | `docs/sprints/sprint-N/sprint-spec.md` | `commit-sha` | VERIFIED |
| ... | ... | ... | ... | ... |

Expected count: 10–12 amendments. Sprint-specific.

## Section 3 — Concern-by-Concern Disposition

For every Round-(N-1) reviewer concern, document one of:

- **ABSORBED** — amendment landed; cross-reference to AMD ID in Section 2.
- **AUTO-RESOLVED** — concern resolved as a side-effect of another amendment; cross-reference the absorbing AMD ID.
- **PARTIAL** — partially addressed; remaining gap documented + carry-forward filed.
- **NOT-ADDRESSED** — explicit decision not to address in this pass; rationale + carry-forward filed (often becomes a Round-(N+1) RSK).

Format as a table:

| Concern ID | Severity | Disposition | AMD reference | Notes |
|---|---|---|---|---|
| C-1 | Critical | ABSORBED | AMD-1 | — |
| C-2 | Critical | AUTO-RESOLVED | AMD-3 | C-2 was a downstream symptom of C-3 |
| N-1 | Minor | PARTIAL | AMD-7 | Architecture in place; AC coverage extends to Sprint 31.92.8 |
| ... | ... | ... | ... | ... |

## Section 4 — New FAI Items (Falsifiable Assumption Inventory)

Lists FAI entries added during the revision pass. Each includes:

- **FAI ID** (e.g., FAI-65-D)
- **Statement** (the falsifiable assumption)
- **Invariants** (the testable properties)
- **Falsification spike spec** (the test/experiment that would falsify it)
- **Owner session** (which session executes the spike)

If no new FAI items, state: "No new FAI items added in this revision pass."

## Section 5 — Compaction-Risk Rescoring

Per RULE-013 / sprint-planning protocol, revisions may shift compaction risk. Document:

- **Per-session rescoring:** for each session whose spec changed, recompute the compaction risk score and note Δ from pre-revision.
- **Cumulative rescoring:** sprint-level compaction risk Δ.
- **Trigger threshold check:** if any session crosses Critical (18+) or sprint-level crosses Critical, decomposition is required.

If no scope changes affected compaction risk, state: "No compaction-risk shifts in this revision pass."

## Section 6 — Production-Code Surfaces Re-Verified by Grep

Table form. Per RULE-038 (session-start grep-verification of factual claims) extended to revision-pass output:

| Cited name | File:line | Pre-revision claim | Post-revision verification |
|---|---|---|---|
| `_mechanism_a_post_cancel_recheck` | `order_manager.py:2555` | Cited; not verified | `grep -n "def _mechanism_a_post_cancel_recheck" argus/execution/order_manager.py` → 1 hit at L2555 ✓ |
| `ActiveAlert.occurrence_count` | `health.py:101-122` | Cited as NEW | `grep -n "occurrence_count" argus/orchestrator/health.py` → 0 hits (NEW; this-sprint-adds) ✓ |
| ... | ... | ... | ... |

This section satisfies the Phase A API-surface verification artifact contract (W-2; codified at RULE-056). The verification table here is the post-revision update; the artifact at `phase-a-api-surface-audit.md` is the pre-Phase-B canonical version.

## Section 7 — Workflow Protocol Gaps Surfaced

Per O-1 / synthesis-sprint routing protocol: any workflow-protocol gaps identified during the revision pass are documented here and routed to the next synthesis sprint.

| Gap ID | Description | Synthesis-sprint routing |
|---|---|---|
| W-N | <one-line description> | synthesis-sprint-`<next-id>` Phase A input |

If no gaps surfaced, state: "No workflow protocol gaps identified in this revision pass."

## Section 8 — Round-(N+1) Readiness Assertion

Explicit assertion that the sprint is ready for Round-(N+1) adversarial review:

- **All Round-(N-1) Critical concerns:** ABSORBED or AUTO-RESOLVED.
- **All Round-(N-1) Major concerns:** ABSORBED, AUTO-RESOLVED, or PARTIAL with carry-forward.
- **All Round-(N-1) Minor concerns:** disposition documented.
- **No new primitive-semantics misses introduced** (Round 3 pre-commitment rule, if N≥2).
- **Verification table (Section 6) covers all production-code surfaces cited in amendments.**

If readiness cannot be asserted, document the gap and STOP. Do not proceed to Round-(N+1).

## Section 9 — Phase A artifact updates (W-1 binding)

Per W-1 (Phase A ↔ Phase C bidirectional consistency, codified at `protocols/sprint-planning.md` Phase D revision-pass checklist):

- **Joint design summary updated?** Yes / No + rationale. If Phase C amendments altered architectural choices made in joint design summary, the Phase A artifact must be updated or explicitly annotated as "superseded by Phase C Amendment N."
- **Problem statement updated?** Yes / No + rationale.

If Yes, list the Phase A artifact paths + amendment-commit SHAs. If No, justify (typically: revision pass did not alter architectural choices fixed in Phase A).

---

*End Round-N Revision Summary template.*
