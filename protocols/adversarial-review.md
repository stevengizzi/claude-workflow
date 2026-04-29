<!-- workflow-version: 1.1.0 -->
<!-- last-updated: 2026-04-29 -->
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
