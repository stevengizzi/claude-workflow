# Sprint Wrap-Up Checklist

> Follow these steps in order when closing out a sprint.
> Each step has a specific output that feeds into the next.

---

## Phase 1: Final Session Completion

**When:** After the last implementation session's review is CLEAR.

- [ ] All session close-outs written and committed
- [ ] All session reviews completed with structured verdicts
- [ ] All code committed and pushed to the sprint branch
- [ ] Full test suite passes (pytest + Vitest)
- [ ] Any visual review completed (for frontend sprints)

**Output:** Sprint branch with all code + docs committed.

---

## Phase 2: Work Journal Close-Out

**When:** Immediately after Phase 1.
**Where:** The Work Journal conversation (Claude.ai project).

Ask the Work Journal to produce its close-out by saying:

> "Sprint is complete. Please generate the Work Journal close-out
> following the work-journal-closeout template."

The Work Journal will produce a structured block containing:
- All DEF numbers assigned (with status: OPEN / RESOLVED)
- All DEC numbers tracked
- All resolved items (must NOT become DEF entries)
- Outstanding code-level items
- Any corrections needed

- [ ] Review the close-out for accuracy
- [ ] Save it as `docs/sprints/sprint-{N}/work-journal-closeout.md`
- [ ] Commit to the sprint branch

**Output:** `work-journal-closeout.md` in the sprint docs folder.

---

## Phase 3: Doc-Sync Session

**When:** After Phase 2 is committed.
**Where:** Claude Code (fresh session).

### Option A: Automated Runner
If using the autonomous runner, the doc-sync automation prompt template
(`templates/doc-sync-automation-prompt.md`) has a `{WORK_JOURNAL_CLOSEOUT}`
placeholder. The runner should read the work-journal-closeout.md file and
paste its contents into that placeholder before invoking the session.

### Option B: Manual
1. Open the doc-sync automation prompt template
2. Fill in the sprint summary placeholders
3. **Paste the entire work-journal-closeout.md into the
   `{WORK_JOURNAL_CLOSEOUT}` placeholder**
4. Run the prompt in Claude Code

The doc-sync session will:
- Update all documentation files (project-knowledge, architecture, decision-log, etc.)
- Create DEC entries from session close-outs
- Create DEF entries using the Work Journal's number assignments
- Skip resolved items
- Report any items it discovered that the Work Journal didn't track

- [ ] Review the doc-sync close-out report
- [ ] Verify DEF numbers match the Work Journal's assignments
- [ ] Verify no resolved items were created as open DEFs
- [ ] Verify DEC entry values match production config

**Output:** Documentation patch on the sprint branch.

---

## Phase 4: Doc-Sync Verification

**When:** After the doc-sync patch is committed.

Run these verification commands:

```bash
# Check for DEF number duplicates
grep -n "DEF-0[0-9][0-9]" CLAUDE.md | sort -t'-' -k2 -n | uniq -d -f1

# Check DEC count matches
grep -c "^### DEC-" docs/decision-log.md
# Should match the "Next DEC" number minus 1

# Check for resolved items that shouldn't be open
# (compare against Work Journal close-out RESOLVED items)
grep "DEF-" CLAUDE.md | grep -v "✅"

# Verify decision-log and dec-index have trailing newlines
tail -c1 docs/decision-log.md | xxd
tail -c1 docs/dec-index.md | xxd
# Should show "0a" (newline), not the last character of content
```

- [ ] No duplicate DEF numbers
- [ ] DEC count is correct
- [ ] No resolved items appear as open DEFs
- [ ] Files have trailing newlines

If issues are found, run a reconciliation prompt (see `sprint-24-doc-sync-reconciliation.md`
for an example of the format).

**Output:** Verified, clean documentation.

---

## Phase 5: Branch Merge + Project Knowledge Update

**When:** After Phase 4 passes all checks.

```bash
# Merge sprint branch to main
git checkout main
git merge sprint-{N}
git push

# Tag the sprint
git tag sprint-{N}-complete
git push --tags
```

- [ ] Sprint branch merged to main
- [ ] Tag created
- [ ] Project knowledge file in Claude.ai project updated
  (copy the relevant sections from `docs/project-knowledge.md` into
  the project's knowledge file, or replace it entirely)

**Output:** Main branch updated, project knowledge current.

---

## Phase 6: Next Sprint Preparation

**When:** After Phase 5.

- [ ] Update the Work Journal handoff template for the next sprint
  (reserved DEC/DEF ranges, session breakdown, protected files)
- [ ] Start a fresh Work Journal conversation with the handoff
- [ ] Begin sprint planning conversation (if not already done)

**Output:** Ready for next sprint.

---

## Quick Reference: What Goes Where

| Artifact | Created By | Consumed By |
|----------|-----------|-------------|
| Session close-outs | Claude Code (implementation) | Doc-sync, Work Journal |
| Session reviews | Claude Code (review) | Doc-sync, Work Journal |
| Work Journal close-out | Claude.ai (this conversation) | Doc-sync prompt |
| Doc-sync patch | Claude Code (doc-sync) | Developer review → merge |
| Reconciliation prompt | Claude.ai (if needed) | Claude Code (fix session) |

## Common Failure Modes

| Failure | Cause | Prevention |
|---------|-------|------------|
| DEF number collision | Doc-sync doesn't see Work Journal assignments | Always include Work Journal close-out in doc-sync prompt |
| Resolved item appears as open DEF | Doc-sync creates entry for something fixed mid-sprint | Work Journal close-out explicitly marks RESOLVED items |
| DEC values don't match production | Doc-sync writes from close-out text, not config files | Doc-sync skill requires reading actual config for verification |
| Stale project knowledge in Claude.ai | Forget to update after merge | Phase 5 checklist includes project knowledge update |
