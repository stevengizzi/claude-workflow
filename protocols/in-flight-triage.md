<!-- workflow-version: 1.2.0 -->
<!-- last-updated: 2026-04-27 -->
# Protocol: In-Flight Triage

**Context:** Claude.ai conversation (Sprint Work Journal)
**Frequency:** Continuously during sprint execution
**Output:** Issue classification, fix prompts, close-out language, DEF entries

---

## When to Use
When anything unexpected arises during sprint implementation:
- A bug in the current session's code
- A bug discovered in a prior session's code
- The spec didn't account for something the implementation needs
- A feature idea or improvement occurs to you mid-session

## Setup

During sprint planning (Phase D of sprint-planning.md), a **Work Journal Handoff
Prompt** is generated alongside implementation and review prompts. This prompt
is pasted into a fresh Claude.ai conversation to create the Sprint Work Journal.
The work journal conversation persists for the duration of the sprint.

If the work journal conversation grows long enough to risk compaction, start a
fresh conversation with the handoff prompt plus a brief "issues so far" summary.

## Per-Session Register Discipline (Compaction Mitigation)

For sprints expected to exceed 8 implementation sessions OR sprints with
multiple Tier 3 review checkpoints, the Work Journal conversation faces
compaction risk that can silently corrupt register state. The mitigation
is to externalize the register to a per-session-refreshed markdown
artifact at `docs/sprints/<sprint-id>/work-journal-register.md` in the
project repo.

### When to use

REQUIRED for:
- Sprints with ≥ 8 implementation sessions
- Sprints with ≥ 2 Tier 3 review checkpoints
- Any sprint where the operator explicitly requests it

OPTIONAL but RECOMMENDED for:
- Sprints with 5-7 sessions where conversation density is high
- Sprints with multiple parallel tracks (so register state is high-volume)

NOT REQUIRED for:
- Sprints with ≤ 4 sessions (compaction risk is minimal)
- Single-session impromptus

### Discipline

1. **At sprint start (Work Journal acknowledgment turn):** Identify whether
   the discipline applies per "When to use" criteria. Surface this to
   operator for explicit confirmation if not already specified in the
   sprint plan or handoff prompt.

2. **First register artifact:** Produce after the FIRST session close-out
   lands cleanly OR after Tier 3 #1 if there is one before any session
   completes. This establishes the initial state.

3. **Refresh cadence:** AFTER EVERY SESSION CLOSE-OUT and AFTER EVERY
   TIER 3 VERDICT — no exceptions. Even sessions that don't materially
   change the register (e.g., a session adding no DEFs, no DECs, no
   scope additions, no resolved carry-forwards, only test count) receive
   a refresh with updated test counts, commit SHAs, and timestamps. The
   principle: artifact is always current to the most recent
   session/verdict, full stop. No exceptions, no judgment calls about
   whether "this session warranted a refresh."

4. **Operator action per refresh:** Operator commits the refreshed file
   to the project repo. The git history of the file IS the session-grain
   audit trail.

5. **Conflict resolution:** If the Work Journal conversation and the
   register artifact ever conflict, the artifact wins. The conversation
   IS the editing surface; the artifact is persisted truth.

### Required register sections

The artifact contains AT MINIMUM the following sections (mirrors
`templates/work-journal-closeout.md` standard structure but produced
incrementally):

- Last refresh metadata (timestamp, anchor commit, sessions complete,
  Tier 3 reviews complete, active session, sprint phase)
- Sprint identity (pinned context — predecessor, mode, primary defects,
  reserved DECs)
- Test tally (per-session deltas + cumulative)
- DECs (materialized + reserved + freed)
- DEFs (filed during sprint + filed pre-sprint with status + anticipated
  but not filed with reasons)
- Risks filed
- Resolved carry-forward items (cumulative)
- Outstanding code-level items (sprint-tracked, not DEF-worthy)
- Carry-forward watchlist (active)
- Pre-applied operator decisions (re-stated for self-containment)
- Operator decisions log (mid-sprint — timestamped)
- Tier 3 reviews (with verdicts + outcomes)
- Session order (with check-marks for complete sessions)
- Sprint-end deliverable forward-looking note

### Continuation strategy

Within a single Work Journal conversation, continue through compaction
events. Trust the register artifact as the backstop. The conversation
preserves fingertip context (sprint texture, operator decision style,
patterns being tracked) that compaction lossy-summarizes; the artifact
preserves the structured state.

Open a fresh Work Journal conversation only if:
- Compaction visibly damages register state (Work Journal claims a
  disposition that contradicts the artifact)
- The conversation gets ratty and Work Journal asks operator to re-paste
  things
- A natural sprint-phase boundary makes a clean slate strategically
  valuable (e.g., between Tier 3 #1 and Tier 3 #2 of a multi-track sprint)

Fresh-conversation onboarding takes 1-2 turns: paste the original handoff
prompt + the register artifact at its latest state + a brief continuation
note (sessions complete, Tier 3 verdicts complete, what's next).

## Issue Categories

### Category 1: In-Session Bug
Small bugs in the current session's own code — typos, off-by-one errors, test
failures during implementation.

**Action:** Fix in the same implementation session. Mention in the close-out
report under standard findings. No additional process overhead.

**Example:** "My test for batch splitting is off by one — the assertion expects
3 batches but the code produces 2."

### Category 2: Prior-Session Bug
A bug in a prior session's code discovered during the current session.

**Action:**
1. Do NOT fix it in the current session — it is outside the session's scope.
2. Finish the current session. Note the bug in the close-out report under
   "Issues in prior sessions."
3. After the current session's Tier 2 review, run a **targeted fix prompt**
   before proceeding to the next session that depends on the broken code.
4. The fix prompt should be minimal: bug description, affected file, proposed
   fix, and regression test. It gets its own close-out.
5. If nothing downstream depends on the buggy code, the fix can be deferred
   to a post-sprint cleanup (Sprint N.1).

**Example:** "While implementing Session 3a, I noticed Session 1b's
build_viable_universe doesn't handle empty FMP responses — it crashes instead
of returning the fallback."

### Category 3: Scope Gap
The spec didn't account for something. The implementation needs something that
was not planned.

**Action depends on size:**

**Small scope gap** (extra config field, additional validation, one more test
case — belongs to the current session's logical change):
- Implement in the current session.
- Document the scope addition in the close-out report under "Scope additions."
- The Tier 2 reviewer will see it and evaluate whether it fits.

**Substantial scope gap** (new file, new test category, changes to files outside
the session's scope boundary, new API endpoint):
- Do NOT squeeze it into the current session.
- Note as "Discovered scope gap" in the close-out report.
- After the session's Tier 2 review, write a **focused follow-up prompt** to
  address it before proceeding to the next dependent session.
- If nothing downstream depends on it, it can wait until a post-sprint cleanup
  (Sprint N.1) or be added to Sprint N.5 scope.

**Example (small):** "The UniverseFilterConfig also needs a max_float field —
I'll add it alongside min_float since I'm already in config.py."

**Example (substantial):** "The FMP batch endpoint returns paginated results
with a nextPage token. We need a pagination loop, but that changes the
FMPReferenceClient interface significantly."

### Category 4: Feature Idea / Improvement
"This would be better if we also..." — not a bug, not required for the sprint
to function.

**Action:**
1. Do NOT build it.
2. Note it in the close-out report under "Deferred observations."
3. These accumulate through the sprint and get triaged during doc-sync:
   - Some become DEF entries
   - Some become Sprint N.5 or N+1 scope
   - Some get dropped as not worth the effort

**Example:** "The routing table could be updated incrementally instead of
rebuilt from scratch. Would be faster but doesn't matter until we have intraday
re-scanning."

---

## DEF/DEC Number Tracking

The Work Journal is the canonical authority for DEF and DEC number assignments
during a sprint. The sprint handoff reserves number ranges at the start.

**When assigning a DEF number:**
1. Use the next available number from the reserved range
2. Log it in the Work Journal's running DEF table with: number, description, status, source session
3. If the item is resolved during the sprint, mark it as RESOLVED — do NOT delete it

**When tracking a DEC number:**
1. Log the number, brief description, and source session
2. The doc-sync session creates the full DEC entry from session close-outs

**At sprint close, the Work Journal produces the doc-sync deliverable.** The
format depends on the execution mode:

**Human-in-the-loop mode:** The Work Journal produces a **filled-in doc-sync
prompt** (based on `templates/doc-sync-automation-prompt.md`) with the Work
Journal close-out data embedded directly. This is a single artifact the
developer can paste into Claude Code — no intermediate step required. The Work
Journal has all the information needed to populate every field: sprint summary,
session list, test deltas, resolved DEFs, deferred items, scope changes, DEC
entries, and the close-out itself.

**Autonomous runner mode:** The Work Journal (or its equivalent `issues.jsonl` +
`work-journal.md`) produces a **structured close-out block** following the
`templates/work-journal-closeout.md` template. The runner programmatically
populates the doc-sync prompt template from this structured data plus its own
accumulated logs.

In both modes, the Work Journal close-out data prevents the #1 doc-sync failure
mode: DEF number collisions between the Work Journal's assignments and the
doc-sync session's independent assignments.

--

## Work Journal Conversation Format

When bringing an issue to the work journal, include:
1. **Which session** you are currently in
2. **What you found** (error message, unexpected behavior, missing capability)
3. **Your instinct** on the category (the journal will confirm or reclassify)

The work journal will:
1. Classify the issue
2. Advise on the correct action
3. Draft whatever is needed (fix prompt, close-out language, DEF entry)
4. Maintain a running issue tracker for the sprint

---

## Anti-Patterns

1. **Fixing prior-session bugs in the current session.** This conflates two
   sessions' work in one close-out report and bypasses review for the fix.

2. **Fixing bugs inside a Tier 2 review prompt.** Reviews are read-only.
   Always. No exceptions.

3. **Batching unrelated fixes at sprint end.** Creates an untraceable blob of
   changes with no individual review coverage. Each fix needs its own prompt
   and close-out.

4. **Ignoring scope gaps and hoping they don't matter.** If you noticed it,
   it matters. Log it. The triage decision is "when to fix," not "whether to
   acknowledge."

5. **Building Category 4 ideas mid-sprint.** The sprint scope was planned for
   a reason. Feature ideas go in deferred observations, not in code.

---

## Autonomous Runner Mode

When the sprint is executing under the autonomous runner, the in-flight triage
workflow changes as follows:

### What Changes
- The **Work Journal conversation** is replaced by the runner's `issues.jsonl`
  and auto-generated `work-journal.md`. Issues are classified automatically
  by the Tier 2.5 triage subagent.
- **Category 1 and 2 issues** with clear fixes are handled by auto-inserted
  fix sessions. The runner generates fix prompts from templates.
- **Category 3 Small issues** are handled by auto-inserted micro-fix sessions.
- **Category 3 Substantial and Category 4 issues** cause the runner to HALT
  and notify the developer.

### What Stays the Same
- The Category 1-4 classification system is unchanged
- Fix sessions still go through implementation → review → conformance
- Each fix has its own close-out report
- Doc sync still happens after all sessions complete
- The developer still reviews all accumulated issues post-sprint

### Anti-Patterns (Runner-Specific)
1. **Disabling Tier 2.5 triage to avoid halts.** The triage layer exists
   because autonomous execution cannot make architectural judgments. Disabling
   it converts "safe autonomous" into "reckless autonomous."
2. **Setting max_auto_fixes too high.** More than 3 auto-inserted fix sessions
   per sprint suggests the planning was insufficient. Halt and re-plan.
3. **Not reviewing the issues log post-sprint.** Auto-resolved issues still
   need human review to catch systematic patterns.