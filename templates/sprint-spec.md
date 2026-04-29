<!-- workflow-version: 1.1.0 -->
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
