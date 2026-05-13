<!-- workflow-version: 1.0.0 -->
<!-- last-updated: 2026-05-12 -->
# Round-N Surgical-Fix Summary Template

> **Purpose:** Canonical structure for documenting the surgical-fix pass following a Round-N adversarial review verdict of REVISE (surgical-class).
>
> **When to use:** Round-N verdict explicitly invokes "REVISE (surgical-class) — sprint decomposition trigger NOT met" per the surgical-fix criteria in `protocols/adversarial-review.md`.
>
> **When NOT to use:** Round-N verdict = REVISE (non-surgical-class) — use `templates/round-N-revision-summary.md` instead.
>
> **Codified from:** synthesis-sprint-31.92.7 T-2 (Sprint 31.92.65 Round 2 surgical-class disposition).

---

## Frontmatter

- **Sprint:** `<sprint-id>`
- **Round number being revised:** Round `<N-1>` (surgical-class REVISE) → Round `<N>` surgical-fix pass
- **Round-(N-1) verdict reference:** path + commit SHA (verdict must explicitly invoke surgical-class disposition)
- **Anchor SHA at surgical-fix start:** captured at start
- **Anchor SHA at surgical-fix end:** captured at commit-time

## Section 1 — Surgical-Fix Class Confirmation

Cite the Round-(N-1) verdict text confirming surgical-class disposition. Quote the verbatim verdict sentence(s) (e.g., "The Round-1 escalation note's sprint-decomposition trigger is NOT met... DO NOT trigger sprint decomposition. REVISE (surgical-class).").

Confirm all five surgical-fix criteria (from `protocols/adversarial-review.md`) are met:

- [ ] Substantive architectural resolutions in the prior revision pass are sound.
- [ ] Findings are stale-reference cleanup + ≤2 enumerated architectural edge cases.
- [ ] Estimated revision effort < 1 hour.
- [ ] No new FAI items required (or ≤1 new FAI item that's clearly bounded).
- [ ] Round-(N-1) verdict text explicitly invokes "REVISE (surgical-class)" disposition.

If any criterion is unmet, STOP — the revision is not surgical-class. Use `round-N-revision-summary.md` instead.

## Section 2 — Surgical-Fix Items Executed

Smaller table than non-surgical revision summary. 10–15 mechanical items + ≤2 architectural-enumeration items:

| Item ID | Type | File(s) | Pre-fix state | Post-fix state | Commit SHA |
|---|---|---|---|---|---|
| SF-1 | Stale-reference cleanup | `docs/sprints/sprint-N/regression-checklist.md` L42 | "13-field" | "14-field" | `commit-sha` |
| SF-2 | Architectural edge case | `docs/sprints/sprint-N/sprint-spec.md` AC4.1 | C4 enumeration list | adds C5 | `commit-sha` |
| ... | ... | ... | ... | ... | ... |

Each item is mechanical OR enumerated edge case — never a fresh architectural decision.

## Section 3 — Post-Edit Grep Verification Table

For each pattern, document its file-level distribution before and after the surgical-fix pass:

| Pattern | Files | Pre-fix hit count | Post-fix hit count | Verdict |
|---|---|---|---|---|
| `on_order_filled` | sprint-package globally | 7 | 0 | CLEAR — all references renamed to `on_fill` ✓ |
| `12-field metadata` | sprint-package globally | 8 | 0 | CLEAR — all references corrected to "13-field" ✓ |
| `bracket_amendment_aborted` | sprint-package globally | 5 | 12 | EXPECTED — additive (5 → 12 expected for amendment X) ✓ |
| ... | ... | ... | ... | ... |

Verdict column values:
- **CLEAR** — drift eliminated
- **EXPECTED** — additive change confirmed
- **DRIFT** — unexpected change requires investigation; if uncleared, surgical-fix pass FAILS

## Section 4 — Production-Code Re-Verification

For surgical-fix passes that touch ONLY documentation (no production-code edits): explicitly state "No production-code work required for this pass" and skip to Section 5.

For surgical-fix passes that touch production code (rare; usually ≤2 architectural edge cases):

| Production-code surface | File:line | Re-verified at SHA |
|---|---|---|
| `<symbol>` | `<path:line>` | `<SHA>` |

## Section 5 — Workflow-Protocol Gaps Confirmed

Per the synthesis-sprint routing protocol, surface any workflow-protocol gaps confirmed during the surgical-fix pass:

| Gap ID | Description | Synthesis-sprint routing |
|---|---|---|
| W-N | <one-line description> | synthesis-sprint-`<next-id>` Phase A input |

Surgical-fix passes routinely re-confirm gaps from prior rounds (e.g., W-2 API-surface verification re-confirmed when stale-reference cleanup catches another instance). Cumulative re-confirmation strengthens the empirical anchor for the synthesis sprint.

## Section 6 — Round-(N+1) Readiness Assertion

Smaller scope than non-surgical readiness assertion:

- **All Round-(N-1) findings:** mechanically absorbed via SF-N items in Section 2.
- **No new primitive-semantics misses introduced** (Round 3 pre-commitment rule).
- **Grep verification table (Section 3):** all rows show CLEAR or EXPECTED verdicts.

If readiness cannot be asserted, document the gap and STOP.

---

*End Round-N Surgical-Fix Summary template.*
