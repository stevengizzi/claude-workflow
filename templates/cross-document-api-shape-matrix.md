<!-- workflow-version: 1.0.0 -->
<!-- last-updated: 2026-05-12 -->
# Cross-Document API-Shape Matrix Template

> **Purpose:** Phase C artifact tracking API/method/class/field/file-path consistency across ALL sprint-package documents. Updated at every revision pass. Acts as a checklist for revision-pass authors.
>
> **When to use:** Every sprint Phase C onward. Initial draft at Phase C; refreshed at every revision pass.
>
> **Empirical anchor:** W-4 confirmed at Sprint 31.92.7 Round-2 drift cleanup (commit `7e0f780e`: 33 edits across 12 secondary artifacts). 4 patterns persisted: `on_fill` x4 surfaces, Fork B x6 surfaces, "13-field" x8 surfaces, count-chain x13 surfaces, S4 keyword x2 surfaces.
>
> **Codified from:** synthesis-sprint-31.92.7 W-4 amendment.

---

## Frontmatter

- **Sprint:** `<sprint-id>`
- **Phase C author:** `<author identity>`
- **Anchor SHA at initial draft:** captured at Phase C
- **Latest update SHA:** captured at last revision pass (refreshed at each pass)

## Section 1 — Matrix

Each row tracks one API/method/class/field/file-path across all sprint-package documents. Columns = documents; rows = cited names.

| Cited name | sprint-spec.md | joint-design-summary.md | impl prompts (per session) | regression-checklist.md | doc-update-checklist.md | tier-3-review-input-template.md | escalation-criteria.md | phase-e-quality-checklist.md |
|---|---|---|---|---|---|---|---|---|
| `_mechanism_a_post_cancel_recheck` | AC1.1, AC1.2 | A1 §"Mechanism A" | S2 L42, S3 L17 | check #4 | doc-A | ✓ | (n/a) | check #2 |
| `on_fill` (vs `on_order_filled`) | AC2.4 | A3 §"Fill callback" | S2 L88, S4 L23 | check #7 | doc-B | ✓ | esc-3 | check #5 |
| `Fork B` (no-arg `get_positions()`) | DEC-408 spec | A4 §"Fork decision" | S3 L51 | (n/a) | doc-C | ✓ | (n/a) | (n/a) |
| `13-field metadata` (vs `12-field`) | DEC-393 schema | A2 §"Metadata schema" | S2 L67, S3 L29 | check #11 | doc-D | ✓ | (n/a) | check #8 |
| ... | ... | ... | ... | ... | ... | ... | ... | ... |

### Cell values
- **Section/AC ID** — name appears at the cited location (e.g., "AC1.1", "S2 L42", "DEC-408 spec").
- **(n/a)** — document does not cite this name (correctly).
- **DRIFT** — document cites a stale or wrong shape; revision pass must correct.

## Section 2 — Per-Revision-Pass Update Log

Each revision pass appends a row to the update log:

| Pass | Date | Anchor SHA | Rows added | Rows updated | Rows DRIFT → CORRECTED | New patterns identified |
|---|---|---|---|---|---|---|
| Phase C initial | `<date>` | `<SHA>` | 47 | 0 | 0 | n/a |
| Round 1 revision | `<date>` | `<SHA>` | 3 (new methods added by amendments) | 12 (existing names appeared in new locations) | 0 | n/a |
| Round 2 surgical-fix | `<date>` | `<SHA>` | 0 | 0 | 33 across 4 patterns | n/a (re-confirms W-4) |
| ... | ... | ... | ... | ... | ... | ... |

## Section 3 — Drift Detection at Revision Pass

The revision-pass author uses this matrix as a drift-detection checklist:

1. For every Round-(N-1) verdict concern that requires a name change (e.g., "rename `on_order_filled` → `on_fill`"): locate the cited name's row in the matrix.
2. Sweep ALL cells with a non-(n/a) value in that row.
3. For each non-(n/a) cell, verify the document at that location has been updated.
4. If unupdated: log as DRIFT in the matrix + add to the revision-pass amendment plan.

This procedure prevents the Sprint 31.92.7 Round-2 drift cleanup pattern (33 edits surfacing AFTER Round-2 verdict because revision pass only updated primary surfaces).

## Section 4 — Cross-Reference to Other Artifacts

- **Phase A API-Surface Audit** (`templates/phase-a-api-surface-audit.md`) — the upstream source for the names in Section 1.
- **Round-N Revision Summary** § Section 6 (Production-Code Surfaces Re-Verified) — the per-pass re-verification record.
- **Round-N Adversarial Review Prompt** § Task 3b (Fix scope → downstream sweep) — the verdict-time audit checks whether the verdict-proposed fix specifies downstream sweep targets. This matrix IS those targets.

## Section 5 — Cell-Update Convention

When a cell transitions from "AC1.1" to a different location (e.g., after revision moves the cited content), update the cell text in place + append the change to Section 2 update log. Do not delete history — the update log is the durable audit trail.

If a cell transitions to (n/a) (citation removed): mark cell as "(n/a — removed at Round N)". This is rare but possible for fork-rejected names.

---

*End Cross-Document API-Shape Matrix template.*
