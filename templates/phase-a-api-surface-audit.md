<!-- workflow-version: 1.0.0 -->
<!-- last-updated: 2026-05-12 -->
# Phase A API-Surface Audit Template

> **Purpose:** The mandatory Phase A artifact codifying every production-code API name, class, field, file path, and ABC method cited in the sprint package. Failure to produce this artifact at Phase A gates Phase B.
>
> **When to use:** Every sprint. No exceptions.
>
> **Binding rule:** RULE-056 (Phase A API-surface verification artifact non-bypassable).
>
> **Empirical anchor:** W-2 confirmed across 4 consecutive sprints (Sprint 31.92, 31.92.5, 31.92.65, 31.92.7). 3–4 Critical primitive-semantics misses per Round-1 verdict in each sprint sourced from un-verified API citations.
>
> **Codified from:** synthesis-sprint-31.92.7 W-2 amendment.

---

## Frontmatter

- **Sprint:** `<sprint-id>`
- **Phase A author:** `<author identity>`
- **Anchor SHA:** captured at Phase A artifact authoring (e.g., `git rev-parse HEAD`)
- **Artifact-completion timestamp:** ISO-8601
- **Phase B gating status:** GATING-PHASE-B (until all DRIFT rows resolved)

## Section 1 — Audit Table

Every name cited in any Phase A sprint-package artifact (joint design summary, sprint-spec preliminary draft, problem statement) must appear here with grep-verified signature.

| Cited name | Type | Production-code location | Verified at SHA | Status |
|---|---|---|---|---|
| `_mechanism_a_post_cancel_recheck` | function | `argus/execution/order_manager.py:2555` | `abc1234` | VERIFIED |
| `ActiveAlert.occurrence_count` | dataclass field | `argus/orchestrator/health.py:101-122` (NEW — this-sprint-adds) | `abc1234` | NEW |
| `broker.get_positions()` | ABC method | `argus/brokers/broker.py:112` (no-arg signature) | `abc1234` | VERIFIED |
| `bus.emit()` | method | DRIFT — actual: `EventBus.publish()` at `argus/core/event_bus.py:73` | `abc1234` | **DRIFT** |
| ... | ... | ... | ... | ... |

### Type values
- `function`, `method`, `class`, `dataclass field`, `attribute`, `ABC method`, `file path`, `enum value`, `constant`, `config field`

### Status values
- **VERIFIED** — cited name exists in production code at cited location with cited signature/shape.
- **NEW** — cited name does NOT exist in production code; this sprint will add it. Location indicates planned post-sprint location.
- **DRIFT** — cited name does NOT exist as cited. Actual name + location specified. DRIFT rows **gate Phase B until resolved** (i.e., the citing artifact must be corrected to use the actual name OR the rationale for the NEW-vs-DRIFT classification must be re-evaluated).

## Section 2 — DRIFT Resolution (mandatory if any DRIFT rows)

For each DRIFT row in Section 1, document the resolution:

| Cited (drift) | Actual | Citing artifact | Correction applied | Resolution commit SHA |
|---|---|---|---|---|
| `bus.emit()` | `EventBus.publish()` | `docs/sprints/<sprint-id>/joint-design-summary.md` L42 | replaced `bus.emit(...)` with `event_bus.publish(...)` | `def5678` |
| ... | ... | ... | ... | ... |

If Section 2 contains ≥1 row, the Phase A audit must be re-run after corrections land. The audit is not COMPLETE until all DRIFT rows are RESOLVED (resolution commit SHA present).

## Section 3 — Phase A Completion Assertion

The Phase A author asserts:

- [ ] Every production-code name cited in any Phase A artifact appears in Section 1.
- [ ] All Section 1 rows are classified VERIFIED, NEW, or DRIFT.
- [ ] All DRIFT rows have been resolved (Section 2).
- [ ] All resolution commits are confirmed against `origin/main`.
- [ ] Phase B may now proceed.

If any checkbox is unchecked, **Phase B is structurally blocked** until completion.

## Section 4 — Audit Methodology

The audit uses `grep -nE` against the production-code repo at the Anchor SHA. For each cited name, the audit author runs:

```bash
# For functions/methods:
grep -nE "def <name>\b" <expected-file>
grep -nE "<name>\s*\(" <expected-file>  # call-site verification

# For classes:
grep -nE "^class <name>\b" <expected-file>

# For dataclass fields / attributes:
grep -nE "<name>\s*[:=]" <expected-file>

# For ABC methods:
grep -nE "abstractmethod" <expected-file> -A 5 | grep "<name>"

# For file paths:
ls <path>
test -f <path>
```

Output verification: the grep returns ≥1 hit with the expected line number, OR the audit author classifies the row as NEW or DRIFT.

## Section 5 — Cross-Reference to Other Sprint Artifacts

This audit table is reproduced (or summarized) in the following downstream artifacts:

- **Sprint-spec.md** § Production-Code Surfaces — verbatim copy of VERIFIED + NEW rows.
- **Round-N revision summaries** § Production-Code Surfaces Re-Verified by Grep — re-verification table per revision pass.

The Phase A audit is the canonical source; downstream artifacts cite back to it.

---

*End Phase A API-Surface Audit template.*
