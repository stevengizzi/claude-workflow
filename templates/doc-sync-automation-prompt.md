<!-- workflow-version: 1.1.0 -->
<!-- last-updated: 2026-04-26 -->
# Template: Doc-Sync Automation Prompt

This template is populated by the runner after all sessions complete and
invoked as a Claude Code session. Placeholders in `{CURLY_BRACES}` are
replaced at runtime.

---

    # Sprint {SPRINT} Doc Sync

    ## Instructions
    You are performing documentation synchronization after a completed sprint.
    This is a documentation-only session. Do NOT modify any source code, tests,
    or configuration files. Only modify documentation files.

    Follow the doc-sync skill in .claude/skills/doc-sync.md.

    ## Sprint Summary
    Sprint: {SPRINT}
    Goal: {SPRINT_GOAL}
    Sessions completed: {SESSION_COUNT}
    Tests: {TESTS_BEFORE} → {TESTS_AFTER} (+{NEW_TESTS})
    New files: {NEW_FILES_COUNT}
    Modified files: {MODIFIED_FILES_COUNT}

    ## Doc Update Checklist (from Sprint Planning)
    {DOC_UPDATE_CHECKLIST}

    ## Accumulated Doc-Sync Queue
    These items were accumulated across all sessions during the sprint run.
    Each entry identifies a document and the change needed.

    {DOC_SYNC_QUEUE_CONTENTS}

    ## Accumulated Issues Log
    For reference — issues encountered during the sprint. Some may have resulted
    in DEC entries that need to be added to the decision log.

    {ISSUES_LOG_CONTENTS}

    ## Accumulated Scope Changes
    For reference — scope modifications that may affect documentation.

    {SCOPE_CHANGES_CONTENTS}

    ## Accumulated Deferred Observations
    These should be triaged into DEF entries or discarded.

    {DEFERRED_OBSERVATIONS_CONTENTS}

    ## Work Journal Close-Out
    The Work Journal tracked all issues, DEF/DEC assignments, carry-forwards,
    and resolutions throughout the sprint. Its close-out is the canonical source
    for DEF number assignments and resolved items.

    **CRITICAL:** If a DEF number appears in this section as RESOLVED, do NOT
    create an open DEF entry for it in CLAUDE.md.

    **CRITICAL:** If the Work Journal assigned DEF numbers, those assignments
    take precedence over any numbers the doc-sync session would otherwise assign.
    Do not re-assign DEF numbers that the Work Journal already allocated.

    {WORK_JOURNAL_CLOSEOUT}
    
    ## DEC Entries Needed
    These were identified during sessions as needing DEC entries. Draft each
    following the DEC template format in docs/decision-log.md.

    {DEC_ENTRIES_NEEDED}

    ## Target Documents

    Update the following documents. For each, read the current version first,
    then apply the changes from the doc-sync queue. Maintain each document's
    existing format and style.

    1. **docs/project-knowledge.md** — Update sprint history table, test counts,
       current state section, any new components or decisions.

    2. **docs/architecture.md** — Update if new modules, components, or
       integration patterns were introduced.

    3. **docs/decision-log.md** — Add DEC entries identified during the sprint.

    4. **docs/dec-index.md** — Update the quick-reference index with new DECs.

    5. **docs/sprint-history.md** — Add the sprint entry with session details.

    6. **CLAUDE.md** — Update deferred items, any new operational context.

    7. **docs/roadmap.md** — Update if sprint outcomes affect future plans.

    8. **Work Journal Close-Out** — If provided, use as source of truth for
       DEF assignments and resolved items. Cross-reference against all DEF
       entries created in this session.

    {ADDITIONAL_TARGET_DOCUMENTS}

    ## Constraints
    - Do NOT modify source code, tests, or config files
    - Do NOT make architectural decisions — only document what was decided
    - If a doc-sync item is ambiguous, note it in the close-out as needing
      human review rather than guessing
    - Preserve existing document formatting and conventions
    - For DEC entries: use the next sequential number after {CURRENT_MAX_DEC}
    - If the Work Journal Close-Out is provided, use its DEF number assignments
      as canonical. Do NOT assign new DEF numbers that conflict with Work Journal
      assignments. If the Work Journal did not assign a DEF number to an item
      discovered during doc-sync, use the next available number after the Work
      Journal's highest assigned number.
    - Items marked RESOLVED in the Work Journal must NOT appear as open DEF
      entries in CLAUDE.md or any other document.

    ## Close-Out
    After all documentation updates are complete, follow the close-out skill
    in .claude/skills/close-out.md.

    Include the structured close-out appendix with:
    - verdict: COMPLETE or INCOMPLETE
    - files_modified: list of all documentation files updated
    - Any items from the doc-sync queue that could not be resolved (noted as
      scope_gaps for human review)

---

## Between-Session Doc-Sync (Campaign Mode)

[The standard doc-sync template above covers post-sprint reconciliation. This subsection covers a different cadence: between-session doc-sync within a long-running campaign, where small targeted updates land between successive Claude Code sessions to keep CLAUDE.md and other coordination docs current with the running register.]

A between-session doc-sync prompt is a tiny, targeted operation. Unlike a full doc-sync (which reconciles everything at sprint close), a between-session doc-sync handles a specific small update — typically a DEF closure, a metric update (test count, file count), or a status-line refresh. It uses find/replace patches with explicit pre-state verification and post-state grep checks.

### Structure of a Between-Session Doc-Sync Prompt

```
# Between-Session Doc-Sync: <description>

## Pre-State Verification
[Grep commands the implementer runs first to confirm the document is in
the expected state before the patch lands. If the pre-state doesn't
match, halt and report.]

```bash
grep "<expected-string>" <file-path>
# Expected: <count>
```

## Patch
[Exact find/replace pairs. Use ` ```text ` blocks rather than diff syntax;
the implementer applies them via str_replace tools.]

**File:** `<path>`

**Find:** ...
**Replace with:** ...

## Post-State Verification
[Grep commands run after the patch to confirm the new state. Mirror the
pre-state checks.]

```bash
grep "<new-string>" <file-path>
# Expected: <count>
```

## Commit Message
[Exact commit message text the implementer should use.]

```
docs(<scope>): <short description>
```

## Report Back
[Specific paste-back format the implementer returns: confirmation that
pre-state matched, that patch landed, that post-state matched, and the
commit SHA.]
```

### When to Use Between-Session Doc-Sync

- During a long-running campaign with 5+ sessions where coordination docs (CLAUDE.md, sprint-history.md, etc.) drift between sessions.
- For mechanical updates that don't require operator judgment but DO require precision (specific find/replace with verifiable state transitions).
- To prevent end-of-sprint doc-sync from accumulating ~12 small edits in one session.

### When NOT to Use

- For substantive content changes that require operator judgment (use a full doc-sync session instead).
- For changes that touch multiple files (use a doc-sync session that handles them coherently).
- For tiny single-line changes during the implementer's own session — fold those into the session's own commits with the relevant changes.

<!-- Origin: synthesis-2026-04-26 P34. ARGUS Sprint 31.9 campaign-close ran
     ~12 between-session doc-sync prompts via the campaign-tracking
     conversation, each with this structure (pre-verify / patch / post-
     verify / commit / report-back). Existing doc-sync template covered
     sprint-end only; this addition covers campaign-internal cadence. -->
