<!-- workflow-version: 1.0.0 -->
<!-- last-updated: 2026-05-12 -->
# Round-N Adversarial Review Prompt Template (N ≥ 2)

> **Purpose:** Canonical structure for adversarial review prompts at Round-N where N ≥ 2 (verification rounds, NOT fresh review). Round-1 uses a different shape; this template is for verification.
>
> **When to use:** A Round-(N-1) revision pass (or surgical-fix pass) has landed; Round-N reviewer is preparing to verify absorption and surface new primitive-semantics misses.
>
> **Time budget guidance:** Round-2 ~1.5h; Round-3 ~30min (per O-2 geometric decay; codified at `protocols/adversarial-review.md` reviewer-time budget section).
>
> **Codified from:** synthesis-sprint-31.92.7 T-3 (NEW; includes W-NEW2 verdict-text-completeness audit).

---

## Frontmatter

- **Sprint:** `<sprint-id>`
- **Round number:** N (where N ≥ 2)
- **Prior round verdict reference:** path + commit SHA + verdict-class (REVISE non-surgical / REVISE surgical / CLEAR-WITH-NOTES)
- **Prior round revision-summary reference:** `templates/round-N-revision-summary.md` or `templates/round-N-surgical-fix-summary.md` instance at `docs/sprints/<sprint-id>/round-(N-1)-revision-summary.md` or surgical-fix-summary
- **Anchor SHA:** captured at review start

## Pre-Flight (mandatory)

Before reviewing, the reviewer must:

1. **Read the Round-(N-1) verdict** in full.
2. **Read the Round-(N-1) revision-summary** (or surgical-fix-summary) in full.
3. **Capture the anchor SHA** that the review will operate against.

## Task 1 — Concern-by-Concern Absorption Verification

For every concern in the Round-(N-1) verdict, the reviewer must verify the disposition documented in the revision summary holds against the actual repo state:

- **ABSORBED concerns:** verify the cited AMD ID landed by inspecting the commit + verifying production-code surfaces match.
- **AUTO-RESOLVED concerns:** verify the absorbing AMD addresses both the original concern and the downstream symptom.
- **PARTIAL concerns:** verify the documented gap matches the actual residual; the carry-forward is correctly filed.
- **NOT-ADDRESSED concerns:** verify the rationale is sound; the carry-forward (RSK or similar) is filed.

Per-concern verification produces one line per concern in the reviewer's Round-N output:

```
C-1 (Critical) — ABSORBED → AMD-1 verified at <SHA>: ✓
C-3 (Critical) — AUTO-RESOLVED → AMD-3 verifies; downstream symptom addressed: ✓
N-1 (Minor) — PARTIAL → AC gap documented; carry-forward filed: ✓
```

## Task 2 — NEW Primitive-Semantics-Misses Audit (Round 3 pre-commitment rule)

The Round 3 pre-commitment rule says: **if Round-N introduces a foundational primitive-semantics miss (asyncio yield gap, cache freshness, callback bookkeeping atomicity, etc.) — even if all Round-(N-1) findings were absorbed — Round-N verdict must be REVISE.**

The reviewer scans the revised sprint package for new primitive-semantics misses:

- API-surface drift introduced by the revision pass (production code referenced by amendments doesn't exist as cited)
- Concurrency / lifecycle / atomicity assumptions in new ACs that are not provably sound
- Inconsistency between asynchronous and synchronous code paths introduced by AMD-N
- Test-code semantic mismatches with production code (per RULE-055 MD5 byte-equality discrimination)

Each finding is logged with severity (Critical / Major / Minor) and triggers the Round 3 rule if Critical.

## Task 3 — W-NEW2 Verdict-Text-Completeness Audit

**NEW for Round-N (N≥2):** the reviewer audits the Round-(N-1) verdict's proposed-resolution text for blind spots. Three sub-questions:

### Sub-question 3a — Invariants → ACs mapping

For every verdict-proposed FAI: do its invariants map to ACs in the sprint-spec? If the invariant requires a behavior the existing AC pattern doesn't cover, was the AC pattern extended? Or is there a gap?

Example finding (Sprint 31.92.65 R3 N-R3-NEW-2):
> Bulk-ack `_dedup_index` clearing semantic asserted by FAI-65-D invariant (d) but not enumerated in AC4.x or AC1.5. **This gap pre-dates the surgical-fix pass; it inherited from the Round-2 verdict's FAI-65-D specification text** and was not introduced by absorption.

### Sub-question 3b — Fix scope → downstream sweep

For every verdict-proposed fix: does it specify ALL downstream sweep targets? Or only the primary surface? Common downstream surfaces: regression-checklist, doc-update-checklist, tier-3-review-input-template, escalation-criteria, phase-e-quality-checklist, Constraints sections, "Do NOT modify" warnings, Review Focus items, DoD bullet lists, narrative text containing FAI / AC / DEC / RSK enumerations.

If the Round-(N-1) verdict specified only the primary surface, this is a Minor concern (drift will surface in Round-(N+1) at downstream surfaces).

### Sub-question 3c — Fork rejection rationale

For every verdict-proposed fork rejection (Fork A vs B; Path α vs β): does the rejection rationale land at the right artifact (`spec-by-contradiction.md` §"Rejecting <fork name>" subsection)? Or only in the verdict text + revision summary?

`spec-by-contradiction.md` is the canonical home for rejected alternatives. If the rationale lives only in the verdict / revision summary, it becomes harder to find at Round-(N+1) or in future cross-sprint reference.

## Task 4 — Reviewer Time-Budget Adherence

Reviewer logs actual review time. Geometric decay calibration:

| Round | Target budget | Empirical median |
|---|---|---|
| 1 | ~6h | (fresh review; full sprint package read) |
| 2 | ~1.5h | (verification + Task 3 audit) |
| 3 | ~30min | (verification + Round 3 rule check; Task 3 audit often shorter due to compounding sealedness) |
| 4+ | n/a | If Round 4 is reached, the prior rounds' surgical-class judgment was wrong; halt and escalate |

If reviewer time materially exceeds the budget, document the surprise in the reviewer's notes (typically: a new architectural concern surfaced, OR Task 3 audit found a gap the prior round missed). This data feeds future O-2 calibration.

## Output: Round-N Verdict

The reviewer produces a verdict using one of the standard verdict shapes:

- **CLEAR-WITH-NOTES** — all concerns absorbed; no new primitive-semantics misses; Task 3 audit ≤2 Minor findings. Sprint can proceed to implementation.
- **REVISE (surgical-class)** — concerns absorbed but ≤2 stale-reference / enumeration items + Task 3 audit findings. Use `templates/round-N-surgical-fix-summary.md`.
- **REVISE (non-surgical-class)** — substantive findings; rework required. Use `templates/round-N-revision-summary.md`.
- **REVISE (Round-3-pre-commitment-rule fire)** — Round-(N-1) findings absorbed but NEW primitive-semantics miss introduced. Mandatory revision pass even though prior round was sealed.

Verdict text MUST cite:
- Specific concern absorption (Task 1)
- New findings (Task 2 + Task 3)
- Disposition class with explicit text matching one of the four shapes above
- Time spent (vs target budget)

---

*End Round-N Adversarial Review Prompt template.*
