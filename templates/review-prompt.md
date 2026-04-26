<!-- workflow-version: 1.2.0 -->
<!-- last-updated: 2026-04-26 -->
# Template: Tier 2 Review Prompt

> **Primary path:** The @reviewer subagent is invoked at the end of the
> implementation session (see implementation-prompt.md). This produces
> the review report within the same CLI invocation.
>
> **This template is used when:**
> - Running in human-in-the-loop mode with separate manual review sessions
> - The @reviewer subagent invocation fails and a fallback is needed
> - The runner is in legacy mode (pre-subagent integration)
>
> When generating sprint packages, always generate both the implementation
> prompt (with @reviewer invocation) and this review prompt as a fallback.
> The runner will use whichever path its configuration specifies.

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
