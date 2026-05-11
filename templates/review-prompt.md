<!-- workflow-version: 1.4.0 -->
<!-- last-updated: 2026-05-10 -->
# Template: Tier 2 Review Prompt (DEPRECATED for default Phase D — HITL fallback only)

> **DEPRECATED for default sprint-planning workflows.** As of metarepo amendment
> 2026-05-04 ratifying empirical evidence from Sprint 31.92 (six refresh sessions
> consistently VESTIGIAL-marking standalone review prompts; impl prompt's inline
> §Tier 2 Review section is authoritative across all execution paths):
>
> **The default Phase D artifact is the implementation prompt only.** The @reviewer
> subagent invocation in the impl prompt's §Tier 2 Review (Mandatory) section
> produces the review report within the same CLI invocation. No standalone review
> prompt is required for default execution.
>
> **This template is preserved for these specific use cases:**
> - Human-in-the-loop mode with separate manual review sessions (operator running
>   review in a fresh CLI invocation rather than as a subagent within the
>   implementation session).
> - Adversarial-review or Tier 3 review patterns where review-as-its-own-session
>   structurally requires its own framing prompt distinct from implementation.
> - Retrospective review of a session that was already executed without inline
>   reviewer (e.g., post-hoc audits).
>
> **Do NOT use this template:**
> - As a Phase D artifact in default sprint planning. Phase D produces only the
>   impl prompt; the impl prompt's §Tier 2 Review section provides the reviewer
>   invocation.
> - In refresh-session output. Refreshed impl prompts inherit the inline-reviewer
>   pattern; standalone review prompts in refresh-session scope are VESTIGIAL.
>
> **Cross-reference:** Sprint 31.92 sprint-close manifest at
> `docs/sprints/sprint-31.92-def-204-round-2/d14-doc-sync-manifest.md` (in the
> ARGUS repo) documents the six-session empirical evidence base.

This is a small, session-specific file. The shared context (Sprint Spec,
Specification by Contradiction, regression checklist, escalation criteria) lives
in the Review Context File and is referenced by path -- not duplicated here.

---

    # Tier 2 Review: Sprint [N], Session [M]

    ## Instructions
    You are conducting a Tier 2 code review. This is a READ-ONLY session.
    Do NOT modify any source code files.

    Follow the review skill in .claude/skills/review.md.

    Your review report MUST include a structured JSON verdict at the end,
    fenced with ```json:structured-verdict. See the review skill for the
    full schema and requirements.

    **Write the review report to a file** (DEC-330):
    docs/sprints/sprint-[N]/session-[M]-review.md

    Create the file, write the full report (including the structured JSON
    verdict) to it, and commit it. This is the ONE exception to "do not
    modify any files" — the review report file is the sole permitted write.

    ## Pre-Flight

    1. **Read `.claude/rules/universal.md` in full and treat its contents as binding for this review.** The full set of universal RULE entries (currently RULE-001 through RULE-053) applies regardless of whether any specific rule is referenced inline in this prompt — particularly RULE-013 (read-only mode) which governs the entire review session.

    ## Review Context
    Read the following file for the Sprint Spec, Specification by Contradiction,
    Sprint-Level Regression Checklist, and Sprint-Level Escalation Criteria:

    [path to review-context.md]

    ## Tier 1 Close-Out Report
    Read the close-out report from:
    docs/sprints/sprint-[N]/session-[M]-closeout.md

    [PLANNING NOTE: When generating review prompts, fill in the actual path
    with the correct sprint and session numbers. The close-out file is committed
    by the implementation session per DEC-330. If for any reason the file does
    not exist, the reviewer should flag this as CONCERNS — the close-out report
    is required for review.]

    ## Review Scope
    - Diff to review: git diff HEAD~1 (or specify the correct range)
    - Test command: [exact test command — see DEC-328 note below]
    - Files that should NOT have been modified: [list]

    ## Session-Specific Review Focus
    [Numbered list of things to check that are specific to this session --
    e.g., "Verify proposals persisted to DB, not memory-only" or
    "Verify WebSocket endpoint is /ws/v1/ai/chat, not SSE"]

    ## Visual Review (if applicable)
    [Include this section for any session that modifies UI. Omit entirely for
    backend-only sessions. These are checks the developer must perform in a
    browser -- they cannot be verified by code review or automated tests alone.]

    The developer should visually verify:
    1. [What to look at]: [Expected appearance or behavior]
    2. [What to look at]: [Expected appearance or behavior]
    [etc.]

    Verification conditions:
    - [State the app must be in for visual review -- e.g., "with AI enabled",
      "with no API key set", "with sample data loaded"]

    [PLANNING NOTE: When generating review prompts, include this section for
    any session that creates or modifies UI components, pages, layouts,
    animations, or user-facing states. Mirror the Visual Review items from the
    corresponding implementation prompt. The developer should be able to look
    at this section and know exactly what to open in a browser and what
    "correct" looks like, without reading the rest of the review prompt. If a
    session is backend-only, omit this section entirely.]

    [PLANNING NOTE: The review skill supports three verdicts: CLEAR (proceed),
    CONCERNS (medium issues, may need triage in autonomous mode), and ESCALATE
    (requires human). Session-specific review focus items should cover the
    scenarios most likely to produce CONCERNS for that particular session.]

    [PLANNING NOTE (DEC-328): When generating review prompts:
      - Non-final reviews (Session 1 of 3, Session 2 of 3): use scoped test
        command targeting the session's affected modules. The close-out just
        confirmed full suite pass — re-running full suite in review is redundant.
      - Final review (last session of sprint): use full suite with `-n auto`.
        This is the last checkpoint before merge.
      Example: In a 3-session sprint, Reviews 1 and 2 use scoped commands,
      Review 3 uses the full suite.]

    ## Additional Context
    [Any session-specific context the reviewer needs -- e.g., "This is attempt 2
    at fixing the auth bug, check if diagnostic-first was followed" or "This
    session follows Session 1 which set up the data model"]

    ## Verdict Combinations (canonical per Sprint 31.92.6)

    The combination of implementer Self-Assessment + Tier 2 Verdict surfaces
    discriminator semantics. Four canonical combinations observed:

    1. **STRICT_ADHERENCE / CLEAR** — implementation matches intent exactly;
       no deviations; clean review.

    2. **MINOR_DEVIATIONS / CLEAR** — local non-semantic deviations exist
       (RULE-038-driven canonical-reality alignments OR test-infrastructure
       adaptations). Reviewer accepts when deviations have no impact on
       impl-prompt intent. Canonical examples: Sprint 31.92.6 S5a-1, S5a-2.

    3. **MINOR_DEVIATIONS / CLEAR-WITH-NOTES** — deviations carry
       impl-prompt-intent impact OR architectural-lock-class issues.
       Reviewer adds NOTES to flag downstream concerns without escalating
       to CONCERNS. Canonical examples: Sprint 31.92.6 S3b, S4b-1, S5c.

    4. **FLAGGED / CLEAR** — implementer surfaces sprint-boundary
       scope-reframe disclosure; literal contract met; structural-class
       issue routed to operator-level path decision. Reviewer confirms
       CLEAR when the FLAGGED disposition is honest, well-scoped, and
       doesn't unilaterally fix the reframe. Canonical example: Sprint
       31.92.6 S5b ("exemplary FLAGGED usage per Universal RULE-011").

    **Discriminator** (per Sprint 31.92.6 S5a-2 reviewer reasoning):
    MINOR_DEVIATIONS escalates to CLEAR-WITH-NOTES when deviations carry
    impl-prompt-intent impact; stays at CLEAR when deviations are
    RULE-038-driven canonical-reality alignments.

    **Escalation classes** (used sparingly):
    - CONCERNS — deviations require pre-merge fix; not a sprint failure
    - CONCERNS_RESOLVED — issued post-fix verification
    - ESCALATE — A-class trigger fired; requires Tier 3 or operator review
    - HALT — implementation cannot proceed

    ### Accepting FLAGGED self-assessment

    When the implementer self-assesses as FLAGGED, the reviewer verifies:

    1. **Literal contract met** — impl-prompt's Definition-of-Done is
       satisfied
    2. **Structural-class issue** — surfaced issue is NOT
       within-session-fixable
    3. **Operator paths enumerated** — implementer provides path a/b/c
       options
    4. **No unilateral fix** — implementer hasn't attempted to reshape the
       reframe themselves

    When all 4 are met, Tier 2 verdict is **CLEAR** (not CLEAR-WITH-NOTES;
    not CONCERNS). The FLAGGED disclosure is the operator's signal, not a
    reviewer concern. Document in verdict rationale that this is exemplary
    RULE-011 usage.
