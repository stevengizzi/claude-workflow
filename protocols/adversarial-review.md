<!-- workflow-version: 1.3.0 -->
<!-- last-updated: 2026-05-12 -->
# Protocol: Adversarial Review

**Context:** Claude.ai conversation (separate from sprint planning)
**Frequency:** When flagged during sprint planning; may run multiple rounds
**Output:** "Round CLEAR" verdict, specific spec revisions, OR Phase A return signal

---

## When to Use
When sprint planning flags any of the following:
- The sprint makes architectural decisions that will be hard to reverse
- The sprint changes data models or database schemas
- The sprint introduces new integrations or external dependencies
- The sprint makes security-relevant changes
- The sprint changes core interfaces that other components depend on
- **The sprint touches safety-load-bearing code paths and authored a Falsifiable
  Assumption Inventory** (per `protocols/sprint-planning.md` Phase A step 9).
  The FAI itself becomes part of the adversarial review surface.

## Pre-Requisites
- The Sprint Spec is complete (from the sprint-planning protocol)
- The Specification by Contradiction is complete
- The Architecture document is current
- If applicable: the Falsifiable Assumption Inventory is present in the
  Sprint Spec
- **FAI completeness cross-check** (canonical per Sprint 31.92 F.6):
  adversarial review verifies the FAI's multi-tier defense-in-depth
  coverage per `protocols/sprint-planning.md` § FAI completeness. FAI items
  missing secondary/tertiary fallback layers trigger REVISE_PLAN
  (substantive class) or carry-forward to Phase C revision (structural
  class) per `protocols/adversarial-review.md` § Substantive-vs-Structural
  Rubric.

## Conversation Structure

### Opening Prompt

    "I need you to adversarially review this sprint spec. Your job is to find
    problems, not to be supportive. Here is the spec:

    [paste Sprint Spec]

    And here is what it explicitly does NOT do:

    [paste Specification by Contradiction]

    Current architecture context:

    [paste relevant Architecture sections or DEC entries]

    Try to break this design. Find the flaws."

For Round N+1 reviews (after Round N produced revisions), use this opening
instead:

    "I need you to adversarially review this REVISED sprint spec. This is
    Round [N+1] — Round [N] produced [list of findings] dispositioned per
    revision-rationale-round-N.md. Your job is narrower this round: find
    problems that the revisions INTRODUCED OR FAILED TO FULLY ADDRESS. Try
    to break the revised design. Find the flaws."

Round N+1's bar is whether the revisions themselves introduced new issues,
particularly new primitive-semantics assumptions or new failure-mode
interactions.

### Probing Sequence

Work through these angles. Claude should pursue each aggressively:

**1. Assumption Mining**
    "What assumptions is this spec making that could be wrong? List every
    implicit assumption -- about data, about user behavior, about system state,
    about dependencies, about performance."

    **Falsifiable Assumption Inventory cross-check (mandatory if sprint is
    safety-load-bearing):** "The spec includes a Falsifiable Assumption
    Inventory listing N primitive-semantics assumptions. (a) Is every
    load-bearing primitive-semantics assumption listed? Are there assumptions
    that the proposed mechanism's correctness depends on that are NOT in the
    inventory? (b) For each entry: does the paired spike *falsify* the
    assumption (try to break it under stress conditions where the failure
    mode would manifest), or merely *measure* it (steady-state observation)?
    Measure-only spikes are the failure mode the inventory exists to prevent;
    flag any entry whose Status is 'measured-only' as ESCALATE. (c) For
    'unverified' entries: is the written justification for not falsifying
    pre-merge actually defensible, or is it a rationalization for skipped
    work?"

**2. Failure Mode Analysis**
    "What are the failure modes? For each component or operation in this spec,
    what happens when it fails? Are there cascade failures? Are there states
    that are hard to recover from?"

**3. Future Regret**
    "What will we regret about this design in 3 months? In 6 months? What
    doors does this close? What technical debt does this introduce?"

**4. Specification Gaps**
    "What is underspecified? Where will the implementer have to make judgment
    calls that could go wrong? What edge cases are not addressed?"

**5. Integration Stress**
    "How does this interact with existing systems? What existing behavior
    could this break? What existing assumptions does this violate?"

**6. Simulated Attack (if security-relevant)**
    "If someone wanted to exploit this design, how would they do it?
    What is the attack surface?"

### Resolution

After each round of adversarial review, one of three outcomes:

**Outcome A: Round CLEAR — proceed to Phase D**

No Critical findings; ≤2 High findings; no primitive-semantics assumptions
remain unverified or measure-only in the Falsifiable Assumption Inventory.

    "Based on this review, are there any issues that would change the
    implementation approach? If not, confirm we should proceed to Phase D."

Document the confirmation, all Medium and Low observations, and the verdict
in `adversarial-review-round-N-findings.md`. Apply Mediums and Lows directly
to the spec artifacts. Sprint planner proceeds to Phase D.

**Outcome B: Round produced revisions — re-review required**

≥1 Critical OR ≥3 High findings.

    "Summarize the findings that require spec changes, and propose specific
    revisions to the Sprint Spec, Specification by Contradiction, and any
    other affected artifacts."

Take the revisions back to a sprint planning conversation to update the
affected artifacts. Produce a Round-N revision-rationale.md logging each
disposition (ACCEPT / PARTIAL ACCEPT / REJECT, with reasoning).

After revisions are applied, run Round N+1 adversarial review with narrowed
scope: the new round validates the fixes, not the original design.

**Outcome C: Pattern of repeated Criticals — return to Phase A**

Triggered when ANY of the following holds:
- ≥2 consecutive rounds produced Critical findings.
- The same primitive-semantics assumption *class* is caught in two consecutive
  rounds (e.g., one round catches an asyncio assumption; the next catches a
  cache assumption — both are "runtime semantics of an underlying primitive,"
  same class).
- ≥3 of the dispositions in any single round are PARTIAL ACCEPT (different
  fix shape).

The pattern indicates structural design issue, not just spec gap. Sprint
planner returns to Phase A. Phase A re-entry is permitted to be scope-bounded
(addressing only the Round N+1 findings + their precipitating root cause)
but MUST include:
- Falsifiable Assumption Inventory authoring or revision (if not already
  present, this is when it lands).
- Independent design review (Tier 3 if available, otherwise a fresh
  adversarial review with FULL scope, not narrowed).
- Round (N+2) adversarial review with full scope after the Phase B/C re-run.

#### Operator-override with proportional in-sprint mitigation (canonical per Sprint 31.92 F.8)

For borderline-class concerns (Round 3 C-R3-1 style — concerns whose class
sits between MEDIUM and HIGH; not clearly REVISE_PLAN-worthy but not
ignore-worthy either), operator may issue a **proportional in-sprint
mitigation override** rather than full Phase B/C revision:

1. **Concern class disclosure**: operator labels the concern (HIGH /
   MEDIUM / LOW / borderline) explicitly in the adversarial-review-rationale
   artifact at `docs/sprints/sprint-<N>/adversarial-review-rationale.md`
2. **Mitigation shape**: operator enumerates the proportional mitigation
   (e.g., add canary test + watchdog + cross-layer composition test
   instead of full impl re-architecture)
3. **Structural reasoning**: operator documents WHY the proportional
   mitigation suffices (sound architectural argument; not just
   sprint-bandwidth pressure)
4. **Acceptance gate**: typically a mid-sprint Tier 3 review verifies the
   mitigation outcome

The override is **the operator's signal to the reviewer that the concern was
considered** with full context; it is NOT a Tier 2-bypass mechanism. The
reviewer may still surface ESCALATE if the mitigation is empirically
insufficient at session execution.

Canonical instance: Sprint 31.92 Round 3 C-R3-1 borderline-class routing
absorbed via L3 SELL-volume ceiling + reconstructed-position refusal +
AC2.7 watchdog instead of full L1+L2+L3+L4 re-architecture.

#### Substantive vs Structural decision rubric

The disposition author's instinctive judgment of "minor revisions applied
directly" vs "structural revisions requiring Phase B re-run" is itself
subject to motivated reasoning — the planner role tends toward minimizing
rework. The rubric below replaces instinct with auditable criteria.

ANY of the following triggers "structural" (full Phase B re-run), regardless
of disposition author's instinct:

1. Any disposition introduces, modifies, or eliminates a Hypothesis
   Prescription entry.
2. Any disposition introduces, modifies, or eliminates a primitive-semantics
   assumption in the Falsifiable Assumption Inventory.
3. Any disposition adds or modifies an ABC method, a cross-cutting interface,
   or a public method on a load-bearing class.
4. Any disposition's accept-with-different-fix shape diverges meaningfully
   from the reviewer's proposal — i.e., introduces a third mechanism class
   neither the original spec nor the reviewer's alternative had.
5. ≥3 dispositions in a single round are PARTIAL ACCEPT (different fix
   shape), regardless of severity.
6. Any disposition adds or removes a session in the session breakdown.
7. Any disposition introduces a new RSK entry rated MEDIUM-HIGH or higher
   per the severity calibration rubric (see `templates/sprint-spec.md`
   § "Severity Calibration Rubric").
8. Any disposition modifies the Hypothesis Prescription's halt-or-proceed
   gate language or the FAI's Status assignments.

If NONE of the triggers fires, the disposition author MAY apply revisions
directly per Outcome B's "minor revisions applied directly" path.

If ANY trigger fires, the disposition is structural — Phase B re-run is
mandatory. The Substantive vs Structural decision is logged in the
revision-rationale.md with the specific trigger(s) that fired.

#### Round counting and termination

Adversarial review rounds are numbered from 1. Round 1 is the initial review
on Phase C output. Round 2+ are re-reviews on revised packages. The protocol
terminates at Outcome A (Round CLEAR) or Outcome C (Phase A return).

There is no upper bound on rounds, but ≥3 rounds is itself a signal that the
spec design has unusual fragility and warrants a Tier 3 architectural review
even if the protocol does not formally trigger Outcome C. Sprint planner
should consult Tier 3 reviewer between Round 2 and Round 3 in such cases.

<!-- Origin: ARGUS Sprint 31.92 Round 2 (2026-04-29). The Round 1 disposition
     author judged Round 1's revisions as substantive-not-structural and
     applied them directly without Phase B re-run; Round 2 caught two
     dispositions (H-3, H-4) that had real problems and one disposition (C-1)
     whose fix introduced a new failure mode (H-R2-5, ceiling-vs-protective
     conflict). The original Outcome A/B framing left the substantive-vs-
     structural call entirely to disposition-author instinct. The rubric
     makes the call auditable. The three-outcome state machine captures the
     pattern that binary framing cannot — that some sprints need 2 or 3
     rounds and the protocol should support that natively rather than retrofit
     it. The Outcome C trigger on "same primitive-semantics assumption class
     in two consecutive rounds" is specifically calibrated to the ARGUS
     Sprint 31.92 pattern: Round 1 caught an asyncio assumption, Round 2
     caught an ib_async assumption, both runtime-semantics-of-primitive
     class. -->

---

## Evaluation Criteria

A good adversarial review:
- Finds at least one non-obvious concern (if it finds nothing, it was not aggressive enough)
- Distinguishes between "this is a real risk" and "this is a theoretical concern"
- Proposes concrete mitigations, not just abstract worries
- Does not water down its findings to be polite
- Focuses on the spec as designed, not on alternative architectures
- For Round N+1 reviews: explicitly probes whether revisions introduced new
  primitive-semantics assumptions or new failure-mode interactions; does not
  re-litigate Round N's resolved findings
- For sprints with a Falsifiable Assumption Inventory: cross-checks every
  inventory entry's Status and falsifying-spike adequacy

---

## Surgical-Fix-Class REVISE Criteria (canonical from Sprint 31.92.65 R2)

**Empirical anchor:** Sprint 31.92.65 Round-2 verdict explicitly invoked surgical-class disposition with the text: *"The Round-1 escalation note's sprint-decomposition trigger is NOT met... DO NOT trigger sprint decomposition. REVISE (surgical-class)."* This was the right call but was made via reviewer judgment, not codified criteria. Codification eliminates the reviewer-judgment ambiguity.

### When to invoke surgical-class disposition

REVISE verdicts have an implicit binary disposition: "spec is unsound, requires substantive rework" vs "spec is sound, requires mechanical cleanup." Round-N escalation notes default to the former; the surgical-class disposition preempts the sprint-decomposition trigger when all of the following hold:

1. **Substantive architectural resolutions in the prior revision pass are sound.** Prior round's fork decisions, FAI specifications, and architectural amendments do NOT require re-litigation.
2. **Findings are stale-reference cleanup + ≤2 enumerated architectural edge cases.** Mechanical drift dominates; novel architectural decisions are bounded to a small enumeration.
3. **Estimated revision effort < 1 hour.** Reviewer's time-budget estimate (per § Reviewer Time-Budget Guidance below) confirms the work is mechanical-scoped.
4. **No new FAI items required (or ≤1 new FAI item that's clearly bounded).** Substantive new falsifiable assumptions indicate architectural rework, not surgical fix.
5. **Round-N verdict text explicitly invokes "REVISE (surgical-class)" disposition.** Reviewer judgment is captured in writing; subsequent rounds can audit the surgical-class invocation against actual scope.

### Verdict-text template

When all 5 criteria are met, the verdict explicitly states:

> "**REVISE (surgical-class) — sprint decomposition trigger NOT met.** [Rationale citing the 5 criteria.] The revision pass produces `docs/sprints/<sprint-id>/round-<N>-surgical-fix-summary.md` (per `templates/round-N-surgical-fix-summary.md`) as the canonical revision-pass output, distinct from the larger `templates/round-N-revision-summary.md` template used for non-surgical revisions."

### When NOT to invoke surgical-class

If any criterion is unmet, the verdict is REVISE (non-surgical-class). The revision pass produces a `round-N-revision-summary.md` instance per the canonical template. Sprint-decomposition trigger applies per existing protocol.

### Audit trail

Subsequent rounds (Round-(N+1) and beyond) audit the surgical-class invocation against actual revision-pass scope:

- If the revision pass scope materially exceeded surgical-class bounds (e.g., introduced new FAI items beyond the ≤1 limit; required >1h of revision work), the Round-(N+1) reviewer surfaces this as a Minor finding ("surgical-class invocation in Round-N was too narrow for actual scope; future surgical-class invocations should re-examine criteria #3").
- This feedback compounds the empirical calibration of the criteria.

---

## Round-N+1 Verdict-Text-Completeness Audit (canonical from Sprint 31.92.65 R3)

**Empirical anchor:** Sprint 31.92.65 Round 3 N-R3-NEW-2 — the reviewer noted that the bulk-ack `_dedup_index` clearing semantic was asserted by FAI-65-D invariant (d) but not enumerated in AC4.x/AC1.5. The reviewer explicitly distinguished this as **inherited from the Round-2 verdict's FAI-65-D specification text** (which the surgical-fix pass absorbed verbatim) rather than introduced by the surgical-fix pass. Round-3 verdict text: *"The Round 3 pre-commitment rule specifically targets gaps **introduced by the surgical-fix pass**; this gap pre-dates it."*

### The audit

Round-N+1 reviewers verify whether Round-N's findings were absorbed correctly. They do NOT typically audit the Round-N verdict's **proposed-resolution text** for blind spots. The Round-N verdict author can have systematic blind spots that get propagated through verbatim absorption — and those blind spots survive Round-(N+1) because the reviewer's attention is on absorption verification, not on the original verdict's completeness.

The Round-N+1 verdict-text-completeness audit is a deliberate scrutiny of the prior verdict's proposed-resolution text. The audit lives at `templates/round-N-adversarial-review-prompt.md` Task 3 (created in synthesis-sprint-31.92.7 D1).

### Binding rule

RULE-057 (Round-N+1 verdict-text completeness audit non-bypassable — see `claude/rules/universal.md`).

### The 3 audit sub-questions

The Round-N+1 reviewer asks:

1. **Sub-question 3a — Invariants → ACs mapping.** For every verdict-proposed FAI: do its invariants map to ACs in the sprint-spec? If the invariant requires a behavior the existing AC pattern doesn't cover, was the AC pattern extended? Or is there a gap?

2. **Sub-question 3b — Fix scope → downstream sweep.** For every verdict-proposed fix: does it specify ALL downstream sweep targets (not just the primary surface)? Common downstream surfaces: regression-checklist, doc-update-checklist, tier-3-review-input-template, escalation-criteria, phase-e-quality-checklist, Constraints sections, "Do NOT modify" warnings, Review Focus items, DoD bullet lists, narrative FAI/AC/DEC/RSK enumerations.

3. **Sub-question 3c — Fork rejection rationale.** For every verdict-proposed fork rejection: does the rejection rationale land at the right artifact (`spec-by-contradiction.md` §"Rejecting <fork name>" subsection)? Or only in the verdict text + revision summary?

### Audit findings

Each finding is logged as Minor (downstream sweep gap, missing rationale placement) or Major (missed invariant-to-AC mapping that affects sprint correctness). The audit is performed at Round-N+1 (N≥2) for every adversarial review; it adds approximately 15–30 minutes to the Round-N+1 reviewer's time budget (incorporated into geometric decay calibration in § Reviewer Time-Budget Guidance below).

### Failure mode the audit prevents

Without the audit, gaps in Round-N verdict-proposed-resolution text persist through Round-N+1 absorption verification and surface only at sprint implementation (where the implementer is the first to discover the gap, OR worse, doesn't discover it and ships an incorrect spec). The Sprint 31.92.65 R3 N-R3-NEW-2 finding is the canonical example: a gap that pre-dated the surgical-fix pass survived two rounds of review.

---

## Reviewer Time-Budget Guidance (canonical from synthesis-sprint-31.92.7 O-2)

**Empirical anchor:** Geometric decay validated across Sprint 31.92.65 + Sprint 31.92.7 adversarial-review rounds. Reviewer time budgets follow approximately the pattern below; future sprints can rely on the estimate for scheduling and operator-bandwidth planning.

### Calibrated time budgets

| Round | Target budget | Empirical median | Scope |
|---|---|---|---|
| 1 | ~6h | ~6h | Fresh review; full sprint package read; first-time identification of Critical / Major / Minor concerns |
| 2 | ~1.5h | ~1.5h | Verification (concern-by-concern absorption check); Task 3 verdict-text-completeness audit (if N=2+); no fresh full-package read required |
| 3 | ~30min | ~30min | Verification + Round 3 pre-commitment rule check; Task 3 audit typically shorter due to compounding sealedness |
| 4+ | n/a | (not encountered in 4 sprints) | If Round 4 is reached, prior rounds' surgical-class judgments were wrong; halt and escalate |

### Interpretation

The decay is real and matches design intent:
- Round 1 reads the full sprint package fresh; the budget reflects that breadth.
- Round 2 verifies absorption against the Round-1 verdict; the budget reflects the smaller scope (read-deltas only) plus the verdict-text-completeness audit overhead.
- Round 3 verifies absorption against the Round-2 verdict + scans for Round-3-pre-commitment-rule triggers; the budget reflects the further-reduced scope.

### When the budget is materially exceeded

If reviewer time exceeds the target budget by >50%, the reviewer documents the surprise in their verdict's notes section. Common causes:

- A new architectural concern surfaced (i.e., the Round-N+1 reviewer found a problem the Round-(N) reviewer missed)
- Task 3 audit found a gap the prior round missed (W-NEW2 binding)
- The sprint package itself ballooned between rounds (revision pass added substantial new scope, which a separate amendment should have surfaced)

The time-budget data feeds future calibration of this guidance. Updates to the table above are appended at every synthesis sprint based on cumulative empirical data.

### When the budget is NOT met (underrun)

If reviewer time is materially below target (e.g., Round 1 completed in <2h):
- Either the sprint package is unusually small (verify by counting AC enumeration + impl prompts) — acceptable.
- Or the reviewer is rushing — a Round-(N+1) finding may surface; reviewer time-quality tradeoff is real.

Operator should treat underruns with mild skepticism, not concern.

### Round 3 pre-commitment rule calibration (O-3 cross-reference)

Sprint 31.92.65 produced 3 Critical (R1) → 2 Critical (R2 surgical-class) → 0 Critical (R3). The Round 3 pre-commitment rule iteratively tightens without forcing architectural rework. The cumulative-REVISE chain breaks cleanly at Round 3 when new findings are non-primitive-semantics-relevant. The rule's threshold ("foundational primitive-semantics misses → REVISE; other Critical → CLEAR-WITH-NOTES + RSK") is well-calibrated. No adjustment recommended in this synthesis sprint.
