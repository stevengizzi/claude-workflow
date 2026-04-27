<!-- workflow-version: 1.4.0 -->
<!-- last-updated: 2026-04-26 -->
# Template: Implementation Prompt

Fill in all bracketed sections. The structure of this prompt is designed to
front-load context, constrain scope, and end with the close-out skill invocation
followed by mandatory Tier 2 review via the @reviewer subagent.

---

    # Sprint [N], Session [M]: [Session Title]

    ## Pre-Flight Checks
    Before making any changes:
    1. **Read `.claude/rules/universal.md` in full and treat its contents as binding for this session.** The full set of universal RULE entries (currently RULE-001 through RULE-053) applies regardless of whether any specific rule is referenced inline in this prompt.
    2. Read these files to load context:
       - [file path 1]
       - [file path 2]
       - [file path 3]
    3. Run the test baseline (DEC-328):
       [IF Session 1 of sprint]:
         Full suite: [full test command with -n auto]
         Expected: [N] tests, all passing
       [IF Session 2+ of sprint]:
         Scoped: [scoped test command targeting this session's modules]
         Expected: all passing (full suite was confirmed by previous close-out)
       Note: In autonomous mode, the expected test count is dynamically adjusted
       by the runner based on the previous session's actual results. The count
       above is the planning-time estimate.
    [IF frontend session AND parallel execution]:
    N. Kill orphaned test workers from prior sessions:
       `pkill -f "vitest/dist/workers" 2>/dev/null; echo "Cleaned"`
       This prevents RAM accumulation from stuck Vitest fork workers.
    4. Verify you are on the correct branch: [branch name]
    5. [Any other pre-conditions]

    [PLANNING NOTE (DEC-328): When generating implementation prompts:
      - Session 1 pre-flight: full suite with `-n auto` for parallel execution
      - Session 2+ pre-flight: scoped test command targeting only this session's
      affected modules (e.g., `python -m pytest tests/intelligence/ -x -q`)
      - ALL close-outs: always full suite with `-n auto`
      The close-out skill handles its own test invocation — the pre-flight
      distinction is the only thing the implementation prompt needs to vary.]

    [PLANNING NOTE: Frontend test hygiene for parallel sessions.
      When generating implementation prompts for frontend sessions:
      - If the session creates or modifies test files that import components
        with WebSocket hooks, EventSource, setInterval, or other persistent
        connections: the implementation prompt MUST include a requirement to
        mock those hooks at the module level via `vi.mock()`.
      - Unmocked persistent-connection hooks in jsdom cause Vitest fork workers
        to hang indefinitely. With parallel sessions, this compounds — each
        stuck worker holds ~500MB–1GB of RAM and a CPU thread.
      - Include this pre-flight step for ANY frontend session:
        "Kill any orphaned Vitest workers: `pkill -f 'vitest/dist/workers' 2>/dev/null`"
      - Projects using Vitest MUST have `testTimeout` and `hookTimeout` set
        in vitest.config.ts (recommended: 10_000ms). Without these, a single
        unmocked hook can freeze a worker process permanently.]

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
    - Do NOT cross-reference other session prompts. This prompt is standalone;
      it must be pasteable into a fresh Claude Code session with zero knowledge
      of other session prompts. Even sessions with clear coupling handle the
      coupling via prose instructions referencing the state of `main`, not via
      cross-prompt references. (Origin: synthesis-2026-04-26 ID3.1.)

    ## Operator Choice (if applicable)

    [Include this section for sessions that present multiple architectural options
    where operator judgment is required between option A and option B (or A/B/C).
    This template lets the operator pre-check before pasting into Claude Code, and
    downstream sessions reference the resulting choice via git state, not via
    re-prompting.]

    The operator must check ONE option below before this prompt is pasted into
    Claude Code. If the operator fails to check an option, Claude Code defaults
    to the option labeled "default" or, if none is labeled, the smallest-blast-
    radius option, and surfaces this default-application in the close-out's
    Judgment Calls section.

    - [ ] Option A (default — smallest blast radius): [description]
    - [ ] Option B: [description]
    - [ ] Option C: [description]

    Downstream sessions that depend on this choice should NOT re-prompt the
    operator. Instead, they reference the state of `main` after this session's
    commit, with conditional instructions per option (e.g., "if Option B was
    chosen, this session's work collapses to X").

    <!-- PLANNING NOTE: Origin: synthesis-2026-04-26 N3.5. Use this section only
         when an architectural decision genuinely requires operator judgment
         mid-sprint and downstream sessions depend on the choice. Don't use
         for cosmetic preferences. -->

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

    ## Marker Validation (if this session adds pytest markers)
    [Include this section when the session adds a new pytest marker — to
    `pyproject.toml`, `pytest.ini`, or equivalent. Omit entirely for sessions
    that do not add markers.]

    After adding the marker(s), verify each new marker collects non-zero
    tests:

        python -m pytest -m "[new_marker]" --collect-only -q

    A marker that collects zero tests is a dead marker — the CI tiering or
    filtering logic that depends on it will silently skip no work. Record
    the collect-only count in the close-out.

    <!-- PLANNING NOTE: Origin: Sprint 31.9 retro, P2. FIX-18 added markers
         but initially no tests carried the marker; the marker-tiering was a
         no-op until the follow-on session wired tests to it. -->

    ## Risky Batch Edit — Staged Flow (if applicable)
    [Include this section for sessions whose scope involves large-file
    refactors, multi-site renames, or cross-file moves. Omit for single-file
    or small-scope edits.]

    Execute the session in five explicit phases and halt between phase 3 and 4:
    1. Read-only exploration of the affected surface. No edits.
    2. Produce a structured findings report: exact file list, exact site list
       (file:line), the planned edit per site, and any sites that look eligible
       but should be skipped with reasoning.
    3. Write the report to a file in the session directory.
    4. **Halt.** Surface the report to the operator and wait for confirmation.
    5. Apply edits exactly as listed in the confirmed report.

    See RULE-039 in `.claude/rules/universal.md`.
    <!-- PLANNING NOTE: Origin: Sprint 31.9 retro, P5. -->


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

    ## Post-Review Fix Documentation
    If the @reviewer reports CONCERNS and you fix the findings within this same
    session, you MUST update the artifact trail so it reflects reality:

    1. **Append a "Post-Review Fixes" section to the close-out report file:**
       Open docs/sprints/sprint-[N]/session-[M]-closeout.md and append:

       ### Post-Review Fixes
       The following findings from the Tier 2 review were addressed in this session:
       | Finding | Fix | Commit |
       |---------|-----|--------|
       | [description from review] | [what you changed] | [short hash] |

       Commit the updated close-out file.

    2. **Append a "Resolved" annotation to the review report file:**
       Open docs/sprints/sprint-[N]/session-[M]-review.md and append after
       the structured verdict:

       ### Post-Review Resolution
       The following findings were addressed by the implementation session
       after this review was produced:
       | Finding | Status |
       |---------|--------|
       | [description] | ✅ Fixed in [short hash] |

       Update the structured verdict JSON: change `"verdict": "CONCERNS"` to
       `"verdict": "CONCERNS_RESOLVED"` and add a `"post_review_fixes"` array.
       Commit the updated review file.

    If the reviewer reports CLEAR or ESCALATE, skip this section entirely.
    ESCALATE findings must NOT be fixed without human review.

    [PLANNING NOTE: This ensures the artifact trail is self-consistent. Without
    this step, someone reading the review report sees "fix this later" for an
    issue that was already fixed, and the close-out doesn't mention the fix at
    all. The CONCERNS_RESOLVED verdict lets the runner and doc-sync distinguish
    "had concerns, all addressed" from "had concerns, still open."]

    ## Session-Specific Review Focus (for @reviewer)
    [Numbered list of things to check that are specific to this session --
    e.g., "Verify proposals persisted to DB, not memory-only" or
    "Verify WebSocket endpoint is /ws/v1/ai/chat, not SSE"]

    ## Sprint-Level Regression Checklist (for @reviewer)
    [Paste the sprint-level regression checklist here]

    ## Sprint-Level Escalation Criteria (for @reviewer)
    [Paste the sprint-level escalation criteria here]

    ### Verification Grep Precision

    When kickoffs include verification grep commands, prefer the more precise patterns:

    - **Section counting:** use `^## [1-9]\.` (anchor + literal dot) rather than `^## [0-9]` to avoid double-counting `## 10.`, `## 11.`, etc.
    - **Human-authored content with TitleCase:** use `grep -i` for content like Markdown bold-list section names (`**Recent-bug count.**`, `**Work-execution state.**`). Lowercase patterns will return false negatives against TitleCase source.
    - **Token-presence checks across rejection-framed content:** when checking that a rejected pattern is absent, scan only validation logic, not docstrings/rationale blocks. A rejection rationale that names the token is not a reintroduction.

    <!-- Origin: synthesis-2026-04-26 retrospective. S3, S5, S6 each had at least one verification grep that needed re-running with -i or a tightened pattern. The grep imprecision did not change verdicts but added review-time noise. -->

    ## Section Ordering

    This template's section order matches the implementation execution order:
    Pre-Flight → Objective → Requirements → Constraints → Operator Choice (if
    applicable) → Canary Tests (if applicable) → Test Targets → Definition of
    Done → Regression Checklist → Close-Out → Tier 2 Review → Post-Review Fix
    Documentation → Session-Specific Review Focus → Sprint-Level Regression
    Checklist → Sprint-Level Escalation Criteria.

    Visual order matches execution order so Claude Code instances following the
    template top-to-bottom proceed in the correct sequence. Do NOT reorder
    sections when filling in the template — the close-out report's
    self-assessment gates whether commit happens, and Tier 2 review runs after
    commit. Reordering visually inverts this and risks confusion.

    <!-- PLANNING NOTE: Origin: synthesis-2026-04-26 N3.8. Without this note,
         prompts have been generated where Tier 2 Review precedes Commit
         visually even when prose described correct execution order. -->
