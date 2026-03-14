<!-- workflow-version: 1.1.0 -->
<!-- last-updated: 2026-03-14 -->
# Template: Implementation Prompt

Fill in all bracketed sections. The structure of this prompt is designed to
front-load context, constrain scope, and end with the close-out skill invocation
followed by mandatory Tier 2 review via the @reviewer subagent.

---

    # Sprint [N], Session [M]: [Session Title]

    ## Pre-Flight Checks
    Before making any changes:
    1. Read these files to load context:
       - [file path 1]
       - [file path 2]
       - [file path 3]
    2. Run the test baseline (DEC-328):
       [IF Session 1 of sprint]:
         Full suite: [full test command with -n auto]
         Expected: [N] tests, all passing
       [IF Session 2+ of sprint]:
         Scoped: [scoped test command targeting this session's modules]
         Expected: all passing (full suite was confirmed by previous close-out)
       Note: In autonomous mode, the expected test count is dynamically adjusted
       by the runner based on the previous session's actual results. The count
       above is the planning-time estimate.
    3. Verify you are on the correct branch: [branch name]
    4. [Any other pre-conditions]

    [PLANNING NOTE (DEC-328): When generating implementation prompts:
      - Session 1 pre-flight: full suite with `-n auto` for parallel execution
      - Session 2+ pre-flight: scoped test command targeting only this session's
      affected modules (e.g., `python -m pytest tests/intelligence/ -x -q`)
      - ALL close-outs: always full suite with `-n auto`
      The close-out skill handles its own test invocation — the pre-flight
      distinction is the only thing the implementation prompt needs to vary.]

    ## Objective
    [1-2 sentences: what this session accomplishes]

    ## Requirements
    [Numbered list of specific changes to make]
    1. In [file path], [specific change with detail]
    2. In [file path], [specific change with detail]
    3. [etc.]

    ## Constraints
    - Do NOT modify: [explicit list of files/modules/functions]
    - Do NOT change: [behaviors, interfaces, contracts to preserve]
    - [Any other constraints]

    ## Canary Tests (if applicable)
    Before making any changes, run the canary-test skill in .claude/skills/canary-test.md
    with these tests:
    - [Test 1: what to assert]
    - [Test 2: what to assert]

    ## Test Targets
    After implementation:
    - Existing tests: all must still pass
    - New tests to write: [list of new tests with what they assert]
    - Minimum new test count: [N]
    - Test command: [exact command]

    ## Config Validation (if this session adds config fields)
    [Include this section when the session adds or modifies YAML config fields
    that map to Pydantic models. Omit entirely for sessions with no config changes.]

    Write a test that loads the YAML config file and verifies all keys under
    the new section are recognized by the Pydantic model. Specifically:
    1. Load [config file path] and extract the [section] keys
    2. Compare against [PydanticModel].model_fields.keys()
    3. Assert no keys are present in YAML that are absent from the model
       (these would be silently ignored by Pydantic and use defaults instead
       of operator-specified values)

    Expected mapping:
    | YAML Key | Model Field |
    |----------|-------------|
    | [yaml_key] | [model_field] |

    ## Visual Review (if applicable)
    [Include this section for any session that modifies UI. Omit entirely for
    backend-only sessions. This tells the developer exactly what to check in
    the browser after the implementation session, separated from code-level
    checks that Claude Code can verify on its own.]

    The developer should visually verify the following after this session:
    1. [What to look at]: [Expected appearance or behavior]
    2. [What to look at]: [Expected appearance or behavior]
    [etc.]

    Verification conditions:
    - [State the app must be in for visual review -- e.g., "with AI enabled",
      "with no API key set", "with sample data loaded"]

    [PLANNING NOTE: When generating implementation prompts, include this section
    for any session that creates or modifies UI components, pages, layouts,
    animations, or user-facing states. The items should be things a human must
    check in a browser -- not things testable via automated tests or grep. Be
    specific about what to look at and what "correct" looks like. If a session
    is backend-only, omit this section entirely.]

    ## Definition of Done
    - [ ] All requirements implemented
    - [ ] All existing tests pass
    - [ ] New tests written and passing
    - [ ] Config validation test passing (if applicable)
    - [ ] Visual review items verified (if applicable)
    - [ ] [Any other completion criteria]
    - [ ] Close-out report written to file
    - [ ] Tier 2 review completed via @reviewer subagent

    ## Regression Checklist (Session-Specific)
    After implementation, verify each of these:
    | Check | How to Verify |
    |-------|---------------|
    | [invariant 1] | [command or assertion] |
    | [invariant 2] | [command or assertion] |

    ## Close-Out
    After all work is complete, follow the close-out skill in .claude/skills/close-out.md.

    The close-out report MUST include a structured JSON appendix at the end,
    fenced with ```json:structured-closeout. See the close-out skill for the
    full schema and requirements.

    **Write the close-out report to a file** (DEC-330):
    docs/sprints/sprint-[N]/session-[M]-closeout.md

    Do NOT just print the report in the terminal. Create the file, write the
    full report (including the structured JSON appendix) to it, and commit it.

    ## Tier 2 Review (Mandatory — @reviewer Subagent)
    After the close-out is written to file and committed, invoke the @reviewer
    subagent to perform the Tier 2 review within this same session.

    Provide the @reviewer with:
    1. The review context file: [path to review-context.md]
    2. The close-out report path: docs/sprints/sprint-[N]/session-[M]-closeout.md
    3. The diff range: git diff HEAD~1
    4. The test command: [exact test command — see DEC-328 note below]
    5. Files that should NOT have been modified: [list]

    The @reviewer will produce its review report (including a structured JSON
    verdict fenced with ```json:structured-verdict) and write it to:
    docs/sprints/sprint-[N]/session-[M]-review.md

    [PLANNING NOTE (DEC-328): For the @reviewer test command:
      - Non-final sessions: scoped test command targeting affected modules
      - Final session of sprint: full suite with `-n auto`]

    [PLANNING NOTE: The @reviewer subagent runs in its own context window with
    read-only tool restrictions (plus the one permitted write: the review report
    file). It independently examines the codebase state, runs tests, and checks
    the diff — it does NOT inherit the implementation session's context. This
    provides the same fresh-context isolation as a separate review session, but
    within a single CLI invocation.

    For the autonomous runner: both the structured close-out and the structured
    verdict are written to disk files. The runner extracts them from disk rather
    than from CLI output, which is more reliable than parsing terminal output.
    The runner's _run_review() step can be simplified to: verify the review
    file exists at the expected path, then extract the structured verdict from
    it.]

    ## Session-Specific Review Focus (for @reviewer)
    [Numbered list of things to check that are specific to this session --
    e.g., "Verify proposals persisted to DB, not memory-only" or
    "Verify WebSocket endpoint is /ws/v1/ai/chat, not SSE"]

    ## Sprint-Level Regression Checklist (for @reviewer)
    [Paste the sprint-level regression checklist here]

    ## Sprint-Level Escalation Criteria (for @reviewer)
    [Paste the sprint-level escalation criteria here]
