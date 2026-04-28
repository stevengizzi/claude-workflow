<!-- workflow-version: 1.0.2 -->
<!-- last-updated: 2026-04-28 -->
# Protocol: Tier 3 Architectural Review

**Context:** Claude.ai conversation
**Frequency:** When triggered by Tier 2 escalation, sprint completion, or periodic cadence
**Output:** Architectural assessment, DEC/DEF/RSK entries, action items for next sprint

---

## When to Use

**Automatic triggers:**
- Tier 2 review verdict is ESCALATE
- A sprint has completed (all sessions done, all Tier 2 reviews done)
- Periodic cadence (every 3-4 sprints) for project health

**Not needed when:**
- Tier 2 verdict is CLEAR and the sprint is not yet complete -- proceed to next session

## Inputs

Gather before starting the conversation:
1. All Tier 1 close-out reports from the sprint (or the escalated session)
2. All Tier 2 review reports from the sprint (or the escalated session)
3. The Sprint Spec and Specification by Contradiction
4. Current project-knowledge.md and architecture.md

Do NOT provide raw transcripts. The structured reports are the review artifacts.

## Conversation Structure

### 1. Context Loading

"I need a Tier 3 architectural review. Here are the inputs:

Sprint Spec: [paste]
Tier 1 Close-Out(s): [paste]
Tier 2 Review(s): [paste]

Current architecture context: [paste relevant sections]"

### 2. If Triggered by ESCALATE

"The Tier 2 review escalated with these findings:
[paste the ESCALATE findings from the review report]

Evaluate:
1. Is this a real architectural concern or a false positive?
2. If real, what is the impact? (contained to this sprint / affects future sprints / systemic)
3. What is the recommended resolution?
4. Should any existing decisions be revised?"

### 3. Sprint-Level Review (for completed sprints)

"This sprint is complete. All sessions were [CLEAR / mixed]. Review:

1. Did the sprint achieve its stated goals? (check against Sprint Spec)
2. Did the implementation stay within the Specification by Contradiction boundaries?
3. Are there architectural implications from the judgment calls made across sessions?
4. Has the codebase moved in a direction consistent with the architecture document?
5. Were any decisions made during implementation that should be elevated to DECs?"

### 4. Cross-Sprint Concerns

"Looking beyond this sprint:
1. Does anything from this sprint affect upcoming sprint plans?
2. Are there emerging patterns across recent sprints? (growing debt, recurring issues)
3. Should the roadmap be adjusted based on what we learned?
4. Are any risks from the register materializing or becoming more likely?"

### 5. Documentation Reconciliation

"Based on this review:
1. What decisions need to be logged? (DEC entries)
2. What new risks were identified? (RSK entries)
3. What should be deferred? (DEF entries)
4. Does the architecture document need updating?
5. Does the project knowledge document need updating?"

---

## Output

The conversation should produce:
1. Review verdict: PROCEED / REVISE_PLAN / PAUSE_AND_INVESTIGATE
2. New DEC entries for any decisions made or revised in the sprint just reviewed
3. **New DEF entries for any items carrying forward to sprints other than the one just reviewed.** Tier 3 reviews frequently surface architectural commitments whose natural sprint home is downstream — for example: a follow-on cleanup that belongs to a later component-ownership refactor sprint; a contractual time-bounded fence that must be replaced by a runtime gate when a future reconnect-recovery sprint touches the relevant function; a schema extension forcing function for an in-flight session whose impl prompt was written before the schema gap was noticed. These DEF entries are the canonical mechanism for binding future sprint plans — they land in the project's CLAUDE.md (or equivalent canonical-context file) DEF table, which is the surface every future planner reads. Without explicit DEF entries, Tier-3-surfaced commitments rely on prose in the verdict artifact alone, which planners may or may not read. Enumerate every Tier 3 finding that has a sprint home other than the one just reviewed; file each as a DEF with sprint-gating text where appropriate.
4. New RSK entries for any risks identified (especially time-bounded contracts: docstring fences, lock-step constraints across files, etc.)
5. Specific updates needed for project documents (architecture.md, decision-log.md, dec-index.md, project-knowledge.md, pre-live-transition checklist, live-operations runbook, etc.)
6. Guidance for the next sprint planning conversation
7. **A stable repo verdict artifact** at `docs/sprints/<sprint-name>/tier-3-review-N-verdict.md` (where N is the review iteration within this sprint, starting at 1). This is the file that survives Claude.ai conversation rollover; without it, the verdict exists only in a transcript that may eventually be inaccessible. The verdict artifact should be condensed (~200-400 lines) and include: verdict, sessions reviewed with anchor commit, focus areas with caveats, additional concerns enumerated A through N, inherited follow-ups by sprint, any workflow protocol gaps surfaced. Cross-references to DEC/DEF/RSK entries written in this same review.
8. If REVISE_PLAN: specific changes to the roadmap
9. If PAUSE_AND_INVESTIGATE: what needs investigation and a proposed approach
10. **If the verdict surfaces materializable items routed for in-sprint resolution:** the verdict's disposition triggers a mid-sprint doc-sync per `protocols/mid-sprint-doc-sync.md`. The mid-sync produces a `*-doc-sync-manifest.md` enumerating files touched + sprint-close transitions owed. DECs whose architectural narrative depends on subsequent sessions MUST defer to sprint-close (Pattern B). DECs whose architectural narrative is complete at the verdict moment MAY materialize at the verdict's mid-sync (Pattern A); use Pattern B when in doubt.
