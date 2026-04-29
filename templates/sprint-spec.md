<!-- workflow-version: 1.2.0 -->
<!-- last-updated: 2026-04-29 -->
# Template: Sprint Spec

Fill in all sections. Leave nothing as TBD -- if something is genuinely unknown,
that is a signal to do more discovery before committing to the sprint.

---

    # Sprint [N]: [Title]

    ## Goal
    [1-2 sentences: what this sprint delivers and why it matters]

    ## Scope

    ### Deliverables
    [Numbered list of concrete, testable deliverables]
    1. [Deliverable with clear definition of done]
    2. [Deliverable with clear definition of done]

    ### Acceptance Criteria
    For each deliverable, the specific conditions that must be true for it to be complete:
    1. [Deliverable 1]:
       - [Criterion A -- testable assertion]
       - [Criterion B -- testable assertion]
    2. [Deliverable 2]:
       - [Criterion A]
       - [Criterion B]

    ### Defense-in-Depth Cross-Layer Composition Tests (mandatory when DEC entries claim N≥3 layer defense)

    When a sprint materializes a DEC entry that claims defense-in-depth across
    N≥3 layers (e.g., a 4-layer OCA defense; a 5-layer alert observability
    architecture), the regression checklist MUST include at least one test
    that exercises a *cross-layer composition path* — a scenario where the
    failure of one layer is supposed to be caught by another, asserting that
    the catch happens.

    Per-layer correctness tests are necessary but not sufficient. Cross-layer
    tests are the only mechanism that catches composition failures pre-merge.
    A DEC claiming defense-in-depth whose per-layer tests all pass but whose
    cross-layer path is unexercised is fragile to empirical falsification —
    a single production scenario that defeats multiple layers simultaneously
    will pass through.

    Cross-layer tests are typically slow, ugly, and span multiple modules.
    That is the cost of catching composition failures structurally rather
    than after merge.

    <!-- Origin: ARGUS Sprint 31.91 DEC-386 empirical falsification
         (2026-04-28). DEC-386 claimed 4-layer defense closing ~98% of
         DEF-204's blast radius; all four layers' individual tests passed;
         the Apr 28 paper session produced 60 NEW phantom shorts via a
         cross-layer path that no single layer's test exercised. Cross-layer
         composition testing is the structural defense against this class
         of failure. -->

    ### Performance Benchmarks (if applicable)
    | Metric | Target | Measurement Method |
    |--------|--------|--------------------|
    | [e.g., Response time] | [e.g., < 200ms p95] | [e.g., load test with k6] |

    ### Config Changes (if applicable)
    List every new or modified config field introduced by this sprint.
    For each field, provide the YAML path and the corresponding Pydantic model
    field name. Verify the names match exactly -- Pydantic silently ignores
    unrecognized fields and uses defaults.

    | YAML Path | Pydantic Model | Field Name | Default |
    |-----------|---------------|------------|---------|
    | [e.g., ai.model] | [e.g., AIConfig] | [e.g., model] | [e.g., "claude-opus-4-5-20251101"] |

    If no config changes, write "No config changes in this sprint."

    ## Dependencies
    - [What must be true before this sprint starts]
    - [What external systems, APIs, or data must be available]
    - [What previous sprint work this builds on]

    ## Relevant Decisions
    - DEC-[N]: [brief description -- how it constrains this sprint]
    - DEC-[N]: [brief description]

    ## Relevant Risks
    - RSK-[N]: [brief description -- how it affects this sprint]

    ### Severity Calibration Rubric for new RSK entries

    When filing a new RSK as part of this sprint, calibrate severity using
    the floors below. The disposition author may rate higher than the floor
    but not lower without explicit reviewer sign-off.

    - **MEDIUM-HIGH floor:** The mitigation depends on operator action that
      has empirically failed within the last 10 sprints, OR a similar failure
      mode has been empirically observed in the project within the last 5
      sprints.
    - **HIGH floor:** The mitigation depends on a sprint-bounded fix and the
      bound exceeds 4 weeks (calendar) OR 3 sprints (whichever is longer).
    - **CRITICAL floor:** The failure mode produces unrecoverable financial
      loss or data loss within a single trading session OR a single execution
      window.

    Example: an RSK whose only mitigation is "operator runs daily-flatten
    script manually" must be rated MEDIUM-HIGH (or higher) if there is
    empirical precedent of the operator missing a run. Rating it LOW or
    LOW-MEDIUM relies on the operator never failing — which is empirically
    false in many production-track histories.

    Severity calibration disputes are escalation triggers for adversarial
    review. A disposition author rating an RSK below the floor without
    explicit reviewer sign-off is a Round 2 finding shape.

    <!-- Origin: ARGUS Sprint 31.92 Round 2 H-R2-3 (2026-04-29). RSK-
         RECONSTRUCTED-POSITION-DEGRADATION was filed at LOW-MEDIUM despite
         Apr 28 paper-session debrief proving operator daily-flatten can
         fail (27 of 87 ORPHAN-SHORT detections from a missed run). The
         reviewer correctly identified the under-rating; the disposition
         author had calibrated by instinct rather than by empirical
         precedent. The rubric makes the calibration auditable. -->

    ## Falsifiable Assumption Inventory (mandatory when sprint touches safety-load-bearing code)

    This section is mandatory when the sprint modifies or extends code paths
    that are safety-load-bearing — order execution, position management,
    broker abstraction, reconciliation, exit management, risk gating, or any
    code path identified as safety-critical in the project's CLAUDE.md
    key-learnings or equivalent canonical document. Optional but encouraged
    otherwise.

    A "primitive-semantics assumption" is a claim about runtime behavior of
    an underlying primitive that the proposed mechanism's correctness depends
    on. Examples:
    - "asyncio's single-threaded event loop serializes concurrent X."
    - "broker.get_positions() returns fresh state."
    - "modifyOrder is deterministic at sub-50ms latency."
    - "this regex catches every variant of the error string IBKR can produce."
    - "this dict-clear fires on every code path that closes the position."

    Each assumption load-bearing on the proposed mechanism must be paired
    with a spike or test that *falsifies* (not merely *measures*) the
    assumption under the conditions where the failure mode would manifest.
    A spike that measures `modifyOrder` latency at 50ms p95 in steady state
    does NOT falsify the deterministic-amend hypothesis — to falsify, the
    spike must try to break the assumption (concurrent amends across
    positions; amends during reconnect; amends with stale order IDs).

    | # | Primitive-semantics assumption | Falsifying spike or test | Status |
    |---|--------------------------------|--------------------------|--------|
    | 1 | [statement of the assumption] | [spike or test that falsifies it] | falsified / measured-only / unverified |
    | 2 | [statement] | [spike or test] | falsified / measured-only / unverified |

    The "Status" column is load-bearing for the adversarial review:
    - **falsified:** spike/test exists, was run, and produced results that
      confirmed the assumption (i.e., attempted to break it and failed to).
    - **measured-only:** spike/test exists and measures the primitive's
      behavior but does not attempt to falsify under stress conditions.
      ESCALATE during adversarial review — measure-only spikes are the
      failure mode this section exists to prevent.
    - **unverified:** assumption not yet tested. Spec-author MUST add a
      falsifying spike to the session breakdown OR justify in writing why
      the assumption cannot be falsified pre-merge (rare; subject to
      explicit reviewer scrutiny; documented inline below the table).

    The inventory is itself a falsifiable artifact. If a future adversarial
    review finds an additional primitive-semantics assumption load-bearing
    on the mechanism not in this list, the inventory has failed — and the
    mechanism's adversarial-review verdict must be downgraded accordingly.

    The inventory is generated in Phase A (sprint-planning protocol step 9),
    handed off through Phase B's design summary, and reproduced verbatim in
    Phase C's sprint spec. Adversarial review (Phase C-1) has explicit
    checklist items that scrutinize the FAI: every load-bearing primitive-
    semantics assumption listed; no "measured-only" spikes that should be
    "falsified"; no "unverified" entries without justification.

    <!-- Origin: ARGUS Sprint 31.92 Round 1 + Round 2 (2026-04-29). Round 1
         caught the asyncio yield-gap race assumption (the concurrent-emits
         race was thought to be impossible because asyncio is single-threaded;
         in fact coroutines yield control during await, and a second
         coroutine can run an entire ceiling-check-and-place sequence between
         yield points). Round 2 caught the ib_async position cache freshness
         assumption (broker.get_positions() was thought to return fresh
         state; in fact ib_async's local cache is stale during the reconnect
         window, returning pre-disconnect state until subscriptions complete).
         Both were primitive-semantics assumptions whose violation silently
         produced the symptom class the proposed fix claimed to address.
         Both were caught only by close inspection, not by skim review.
         Two consecutive rounds of the same class of error indicated the
         planning protocol had a structural gap — the proposed mechanism's
         correctness depended on primitive-semantics claims that were not
         enumerated, let alone falsified. This section closes that gap. -->

    ## Hypothesis Prescription (if applicable)

    Include this section ONLY for sprints whose first session begins with a
    diagnostic phase — i.e., sprints where the symptom is reproducible but the
    root cause is not yet conclusively established at spec-authoring time. Skip
    this section for sprints with a fully-understood mechanism.

    Spell out every plausible hypothesis the spec author considered. For each,
    name the evidence that would confirm or rule it out. Then explicitly
    authorize the implementing session to adapt the fix shape if the diagnostic
    contradicts the primary hypothesis.

    | ID | Hypothesis | Confirms-if | Rules-out-if | Spec-prescribed fix shape |
    |---|---|---|---|---|
    | H1 | [the primary hypothesis the spec author thinks is most likely] | [observable signal] | [observable signal] | [the fix this hypothesis would warrant] |
    | H2 | [secondary hypothesis] | [observable signal] | [observable signal] | [the fix this hypothesis would warrant] |
    | Hn | [further hypotheses, including "something else" if the space is genuinely open] | [observable signal] | [observable signal] | [the fix this hypothesis would warrant, OR "HALT and surface to operator"] |

    **Required halt-or-proceed gate language** in the implementation prompt:

    > If the diagnostic confirms H1, proceed to Phase B with the H1 fix shape.
    > If H2/H3 (etc.) are confirmed, adapt the fix shape to match the confirmed
    > mechanism. If findings are inconclusive or fall outside the enumerated
    > hypotheses, HALT and write the diagnostic findings file with status
    > INCONCLUSIVE; surface to operator before proceeding. Do NOT ship a Phase B
    > fix that doesn't address the Phase A finding.

    The escape-hatch language is load-bearing. Without it, the implementing
    session can rationalize the spec-prescribed fix even after the diagnostic
    contradicts it. The implementing session is explicitly authorized to deviate
    from the spec-prescribed fix shape when the diagnostic finding warrants it,
    provided the deviation is called out in the close-out's "Judgment Calls"
    section with cross-reference to the diagnostic findings file.

    <!-- Origin: ARGUS Sprint 31.915 retrospective (2026-04-29). The
         disk-pressure investigation's spec listed H1 (aiosqlite cursor.rowcount
         post-commit semantics) as the primary hypothesis with the explicit
         clause "the impl prompt assumes H1 as the primary hypothesis but does
         not foreclose H2/H3." Phase A's instrumented diagnostic conclusively
         ruled out H1 and confirmed H3 (vacuum-raises-eats-success-INFO). The
         fix shape changed from "rowcount-before-commit" (H1) to
         "deletion-INFO-before-vacuum" (H3). Without the "does not foreclose"
         language, the implementing session might have rationalized the
         H1-prescribed fix despite contradicting evidence, shipping a 2-line
         change that addressed nothing. -->

    ## Session Count Estimate
    [N] sessions estimated. [Brief rationale for the estimate.]
    [If frontend sessions with visual review items: +0.5 sessions budgeted
    for visual-review fix contingency.]
