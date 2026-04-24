# Skill: Close-Out (Tier 1 Self-Review)

## Trigger
Run this as the FINAL action of every implementation session, after all code changes
are complete and tests pass.

## Pre-Conditions
- All implementation work for this session is complete
- All tests have been run
- All changes have been committed (or are ready to commit)

## Procedure

### Step 1: Generate Close-Out Report
Produce the following report between the markers shown. This exact format is required
for downstream parsing by the Tier 2 review.

**Important:** Render the report inside a fenced code block (triple backticks with `markdown` 
language hint) so the user can copy/paste it with table formatting preserved.

```
---BEGIN-CLOSE-OUT---

**Session:** [Sprint number] — [Session description]
**Date:** [ISO date]
**Self-Assessment:** [CLEAN | MINOR_DEVIATIONS | FLAGGED]

### Change Manifest
| File | Change Type | Rationale |
|------|-------------|-----------|
| [path] | [added/modified/deleted] | [why] |

<!-- The Change Manifest must include sprint operational files edited during the
     session (e.g., RUNNING-REGISTER.md, CAMPAIGN tracker, DEF register). A
     file that was edited but not listed is an incomplete manifest, even if
     the edit was "just bookkeeping."
     Origin: Sprint 31.9 retro, P11 — Tier 2 flagged RUNNING-REGISTER.md
     omissions from FIX-05's manifest. -->


### Judgment Calls
Decisions made during implementation that were NOT specified in the prompt:
- [decision]: [rationale]
(Write "None" if all decisions were pre-specified.)

### Scope Verification
Map each spec requirement to the change that implements it:
| Spec Requirement | Status | Implementation |
|-----------------|--------|----------------|
| [requirement] | [DONE/PARTIAL/SKIPPED] | [file:function or explanation] |

### Regression Checks
Run each item from the session's regression checklist:
| Check | Result | Notes |
|-------|--------|-------|
| [check description] | [PASS/FAIL] | [details if FAIL] |

### Test Results
- Tests run: [count]
- Tests passed: [count]
- Tests failed: [count]
- New tests added: [count]
- Command used: [exact test command]

<!-- The "after - before" delta MUST equal "New tests added" exactly. If it
     doesn't, flag it explicitly: either pre-existing tests disappeared
     (regression hiding inside the delta), or new tests were counted twice.
     Never let a gain in new tests silently offset a loss in pre-existing
     tests — that pattern is how silent test regressions land.
     Origin: Sprint 31.9 retro, P10. -->


### Unfinished Work
Items from the spec that were not completed, and why:
- [item]: [reason]
(Write "None" if all spec items are complete.)

### Notes for Reviewer
Anything the Tier 2 reviewer should pay special attention to:
- [note]
(Write "None" if no special attention needed.)

---END-CLOSE-OUT---
```

### Step 2: Self-Assessment Criteria
Rate your session using these criteria:

- **CLEAN:** All spec requirements met. No judgment calls outside spec. All tests pass.
  All regression checks pass. No unfinished work.
- **MINOR_DEVIATIONS:** All spec requirements met, but minor judgment calls were needed
  (e.g., naming choices, minor implementation details not specified). All tests pass.
- **FLAGGED:** Any of: spec requirement partially met or skipped; test failures;
  regression check failures; significant judgment calls that may affect other sprints;
  scope exceeded; architectural concerns.

### Step 3: Commit
After generating the close-out report:

1. Stage changes (prefer explicit paths over `git add -A` to avoid accidentally
   committing untracked files outside session scope).
2. **Pre-commit scope check.** Run `git diff --name-only --cached` and confirm
   every staged path is within the session's declared scope (the Change Manifest).
   If a staged file is not in the manifest — either add it to the manifest (and
   justify why it was touched) or unstage it. Do not commit a mixed-scope diff.
   <!-- Origin: Sprint 31.9 retro, P4. A scope-mixing commit (c3bc758 "chimera
        Pass 3") bundled unrelated changes across sessions. The pre-commit
        grep is the cheapest gate against that class of bug. -->
3. Commit with message: `[Sprint X.Y] [session scope summary]`
4. Push to remote: `git push`

Do NOT push if self-assessment is FLAGGED — wait for developer review of the close-out.

### Step 4: CI Verification
After pushing, wait for CI to complete on the session's final commit and record
the green CI run URL in the close-out report. If CI fails, do not start the
next session until a fix has landed and the re-run is green. If a subsequent
push arrives before CI completes on the prior commit, most CI providers cancel
the prior run — so the intervening state becomes unverified.

Record in the close-out:
- CI run URL: [link to the run covering this session's final commit]
- CI status: [GREEN / RED / CANCELLED-BY-NEXT-PUSH]

<!-- Origin: Sprint 31.9 retro, P25. See also RULE-050 in
     claude/rules/universal.md. -->


## Structured Close-Out Appendix

After producing the human-readable close-out report above, append a machine-
parseable JSON block. This block is used by the autonomous runner for automated
decision-making and by the run-log for structured record-keeping.

Fence the block with:

    ```json:structured-closeout
    {
      "schema_version": "1.0",
      "sprint": "[sprint number]",
      "session": "[session ID]",
      "verdict": "COMPLETE | INCOMPLETE | BLOCKED",
      "tests": {
        "before": [N],
        "after": [N],
        "new": [N],
        "all_pass": true | false
      },
      "files_created": ["path1", "path2"],
      "files_modified": ["path1", "path2"],
      "files_should_not_have_modified": [],
      "scope_additions": [
        {"description": "...", "justification": "..."}
      ],
      "scope_gaps": [
        {
          "description": "...",
          "category": "SMALL_GAP | SUBSTANTIAL_GAP",
          "severity": "LOW | MEDIUM | HIGH",
          "blocks_sessions": ["S3a"],
          "suggested_action": "..."
        }
      ],
      "prior_session_bugs": [
        {
          "description": "...",
          "affected_session": "S1a",
          "affected_files": ["path"],
          "severity": "LOW | MEDIUM | HIGH",
          "blocks_sessions": []
        }
      ],
      "deferred_observations": ["observation 1", "observation 2"],
      "doc_impacts": [
        {"document": "architecture.md", "change_description": "..."}
      ],
      "dec_entries_needed": [
        {"title": "...", "context": "..."}
      ],
      "warnings": [],
      "implementation_notes": "Free-text notes about decisions made during implementation"
    }
    ```

Rules for the structured appendix:
- Always produce it, even in human-in-the-loop mode (for record-keeping)
- The verdict field must match the overall assessment in the human-readable report
- files_should_not_have_modified must be empty for a clean session
- Every scope gap must have a category (SMALL_GAP or SUBSTANTIAL_GAP)
- Prior-session bugs should identify the affected session by ID
- The appendix must be valid JSON (no trailing commas, proper quoting)
