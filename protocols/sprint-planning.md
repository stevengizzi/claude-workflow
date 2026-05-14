<!-- workflow-version: 1.6.1 -->
<!-- last-updated: 2026-05-14 -->
# Protocol: Sprint Planning

**Context:** Claude.ai conversation(s)
**Frequency:** Once per sprint
**Output:** Complete Sprint Package (spec, prompts, review infrastructure, checklists)

---

## When to Use
At the start of every sprint. This is the single most important conversation in
the sprint cycle -- it produces everything the implementation and review phases need.

For multi-session campaigns with persistent coordination state (5+ sessions, multi-track, accumulating registers), see `protocols/campaign-orchestration.md` for the coordination machinery layered on top of per-session sprint planning.

## Conversation Structure

This protocol follows the Compaction-Resistant Planning Protocol (Template Section 3.1.1).

### Phase A: Think

Start the conversation with the sprint context:

    "We are planning Sprint [N] for [Project Name].

    Current state: [brief status -- what the last sprint accomplished]
    Sprint goal: [what this sprint should deliver]
    Relevant decisions: [DEC references that constrain this sprint]
    Known risks: [RSK references relevant to this sprint]

    Let us design this sprint. Before we generate any artifacts, I want to
    think through the requirements, edge cases, and session breakdown."

During Phase A, work through:

0.5 **Execution mode declaration** -- Declare the intended execution mode:
    autonomous / human-in-the-loop / undecided.

    - **Autonomous:** Skip work journal handoff prompt in Phase D. Generate
      runner config as a sprint artifact. Parallelizable assessment in step
      5.5 is mandatory.
    - **Human-in-the-loop:** Skip runner config generation. Generate work
      journal handoff prompt. Parallelizable flags are informational only.
    - **Undecided (default):** Generate both work journal handoff and runner
      config. Safe default for sprints where the mode has not been decided.

1. **Requirements clarification** -- What exactly does this sprint deliver?
   What are the acceptance criteria? Are there performance benchmarks?

2. **Edge cases and boundaries** -- What inputs, states, or conditions could
   cause problems? What should the system do in each case?

3. **Scope boundaries** -- What does this sprint explicitly NOT do?
   (This becomes the Specification by Contradiction.)

4. **Session decomposition** -- How many Claude Code sessions? What is the
   scope of each? What is the dependency order?

   For each session, explicitly answer:
   - **Creates:** What new files does this session produce?
   - **Modifies:** What existing files does this session change?
   - **Integrates:** Which prior session's output does this session wire into
     calling code? (A module that is created but never integrated is dead code.
     Every "Creates" entry in one session must have a corresponding "Integrates"
     entry in a later session, unless it is self-contained.)

5. **Compaction risk assessment** -- For each proposed session, score compaction
   risk using the point system below. The score determines whether the session
   must be split.

   | Factor | Points |
   |--------|--------|
   | Each new file created | +2 per file |
   | Each file modified | +1 per file |
   | Each file in pre-flight reads / context loading | +1 per file |
   | Each new test to write | +0.5 per test |
   | Complex integration wiring (connecting to 3+ existing components) | +3 |
   | External API debugging (live API calls, WebSocket, SSE) | +3 |
   | Large single file (any new file expected to exceed ~150 lines) | +2 per file |

   Thresholds:
   - **0–8 (Low):** Proceed.
   - **9–13 (Medium):** Proceed with caution.
   - **14–17 (High):** Must split before proceeding.
   - **18+ (Critical):** Must split into 3+ sessions.

   When splitting, aim for each sub-session to: create at most 2 new files,
   read at most 6 context files, write at most 8 new tests, and score ≤13.

   Do not move to Phase B with any session scoring 14+.

   The Session Breakdown artifact must include the scoring table for each
   session (see template). When compaction occurs during implementation, log
   the session's planning score and the point of compaction in the close-out
   report. This calibrates future scoring — if the system consistently
   under-predicts, lower the thresholds.

   **Test count estimation guide:** When estimating per-session test counts,
   use ~5 tests per new file + ~3 tests per modified file + ~2 tests per new
   API endpoint as a baseline. Apply a 2× multiplier for sessions that create
   new infrastructure (DB schemas, API routes, WebSocket handlers) because
   integration tests accumulate. This prevents the chronic underestimation seen
   in Sprint 22 (85 estimated vs. 288 actual).

   **Parametrized tests count per case, not per decorator.** When the kickoff
   recommends a parametrized pattern (`@pytest.mark.parametrize`), the estimate
   should multiply the single-test estimate by the number of parameter cases.
   Similarly, exhaustive error-path tests (N orthogonal error types × M
   triggering conditions each) should be enumerated rather than treated as
   "a few tests for error paths."
   <!-- Origin: Sprint 31.9 retro, P23. FIX-13c estimated +25 to +35 pytest;
        actual was +52, primarily because the recommended parametrized page-
        formatter test was counted as 1 but pytest reported 5 (one per tuple),
        and the exhaustive error-path tests for `_build_system_state` totalled
        10 (orchestrator × 2 + broker × 3 + equity × 2 + circuit × 3). -->

   **Measure runtime claims; don't infer them.** When a kickoff cites a runtime
   cost ("N × 30s = 180s"), measure actual durations via `pytest --durations=10`
   against the baseline HEAD during pre-draft investigation, and cite the
   measured numbers. Config defaults and theoretical ceilings drift as earlier
   fixes reduce individual test costs — FIX-13b's kickoff claimed 6 × 30s
   flatten tests, but 4 of 6 had already been reduced to ~1s by FIX-04's
   shared `config` fixture override. Uniform refactors may still be correct
   for consistency, but the runtime-savings pitch needs current numbers.
   <!-- Origin: Sprint 31.9 retro, P20. -->


   **Frontend visual-review fix budget:** For frontend sessions that include
   visual review items, budget an additional 0.5-session fix allowance in the
   session breakdown. If the visual review discovers no issues, the slot is
   unused. If it discovers issues, the fix session is already planned and does
   not require an impromptu triage. This is cheaper than running unplanned fix
   sessions that bypass the standard prompt template. Mark these in the session
   breakdown as "Session [N]f (visual-review fixes) — contingency, 0.5 session."

5.5 **Runner compatibility assessment** -- For each session:

   a. Confirm the session has machine-parseable acceptance criteria (testable
      assertions, not subjective judgments).

   b. Assign `parallelizable` flag (default: false). Set to true ONLY when:
      - The Creates list has 2+ clearly independent outputs
      - No two outputs modify the same files
      - The session is NOT already at compaction risk 14+
      Justify the flag in the session breakdown.

   e. **Resource impact assessment** (when parallelizable is true and sessions
      include frontend test runs): Confirm the project's test runner has global
      timeouts configured (e.g., Vitest `testTimeout`, Jest `testTimeout`).
      Without timeouts, a single hanging test can spawn a zombie process that
      persists after the session ends. With N parallel sessions, this compounds
      to N stuck processes × ~500MB–1GB each.

      For parallel frontend sessions, add to each implementation prompt's
      pre-flight: "Kill orphaned test workers before starting."

   c. Confirm the implementation prompt template includes the structured
      close-out requirement (referencing the close-out skill's structured
      appendix section).

   d. Confirm the implementation prompt template's §Tier 2 Review (Mandatory
      — @reviewer Subagent) section includes the structured verdict requirement
      (referencing the review skill's structured verdict section). The standalone
      review-prompt template (`templates/review-prompt.md`) is HITL-fallback only
      per its deprecation header; default Phase D produces only impl prompts and
      the @reviewer subagent invocation lives inline in each impl prompt.

6. **Config changes assessment** -- If this sprint adds or modifies config
   fields (YAML files + Pydantic models), explicitly list each new field and
   its corresponding Pydantic model field name. Verify the names match exactly.
   Add a regression checklist item: "New config fields verified against Pydantic
   model (no silently ignored keys)." This prevents the class of bug where
   Pydantic silently drops unrecognized fields and uses defaults instead of
   operator-specified values.

7. **Regression assessment** -- What existing functionality could this sprint
   break? What invariants must be preserved?

8. **Workflow mode assessment:**
   - Does this sprint warrant an Adversarial Review? (architectural decisions,
     data model changes, new integrations)
   - Does this sprint need the Iterative Judgment Loop? (visual/UI work)
   - Should we run Synthetic Stakeholder simulation? (API or UX design)
   - **Does any Tier 3 mandatory trigger fire?** (See `protocols/tier-3-review.md`
     § "Mandatory Triggers" for the rubric. If any trigger fires, schedule a
     mandatory mid-sprint Tier 3 in the session breakdown at the natural
     architectural-closure milestone, BEFORE downstream validation sessions
     begin.)

9. **Falsifiable Assumption Inventory (mandatory when sprint touches safety-
   load-bearing code).** For sprints that modify or extend safety-load-bearing
   code paths (order execution, position management, broker abstraction,
   reconciliation, exit management, risk gating, or any code path identified
   as safety-critical in the project's CLAUDE.md key-learnings or equivalent
   canonical document), enumerate every primitive-semantics assumption
   load-bearing on the proposed mechanism. Pair each with a spike or test
   that *falsifies* (not merely *measures*) the assumption.

   See `templates/sprint-spec.md` § "Falsifiable Assumption Inventory" for
   the table format and Status semantics.

   The FAI is a Phase A artifact; it must be present in the design summary
   handoff to Phase B, and reproduced verbatim in the sprint spec at Phase C.
   Adversarial review (Phase C-1) has explicit checklist items that scrutinize
   the FAI: every load-bearing primitive-semantics assumption listed; no
   "measured-only" spikes that should be "falsified"; no "unverified" entries
   without justification.

   The FAI prevents two classes of failure: (a) unrecognized assumptions
   silently encoded in the design (caught only by close inspection); (b)
   spikes that measure rather than falsify — confirming a steady-state
   measurement rather than testing the breaking conditions where the
   assumption would fail.

   For sprints that do NOT touch safety-load-bearing code, the FAI is
   optional but encouraged. Skip explicitly with a one-line note in Phase B's
   design summary: "FAI: not applicable; sprint does not touch safety-load-
   bearing code paths."

   <!-- Origin: ARGUS Sprint 31.92 Round 1 + Round 2 (2026-04-29). See
        templates/sprint-spec.md § "Falsifiable Assumption Inventory" for
        the full Origin context describing the asyncio yield-gap race
        (Round 1) and ib_async cache freshness (Round 2) primitive-semantics
        assumption misses. Two consecutive rounds of the same class of
        error indicated the planning protocol had a structural gap. -->

### B1 cap re-baseline methodology (canonical per Sprint 31.92.6)

The Phase A cap-setting estimate (cumulative pytest delta ceiling) is an
initial planning artifact and may require **forecast-driven re-baseline**
during the sprint if Phase D scope expansion materially exceeds the
Phase A baseline assumption.

**Re-baseline discipline:**

1. **Single re-baseline per sprint maximum.** Repeat re-baselines feel like
   moving goalposts and erode the cap's planning utility.
2. **Re-baseline at LITE refresh boundary**, not mid-session, so the
   adjustment lands in the work-journal-register's headroom prose.
3. **Forecast-driven re-baselines** are acceptable when Phase D scope
   expansion is empirically driven (e.g., Tier 3 dispositions adding
   sub-sessions + cross-layer composition expansion). Document the
   Phase A → Phase D scope delta as rationale.
4. **Structural-work-driven final overage** (beyond re-baselined cap) is
   acceptable when the overage corresponds to canonical compliance work
   (e.g., AC parametrize-full sweep) NOT test bloat. Document as one-shot
   adjustment sequence in sprint-close CLAUDE.md sprint-health note.

**Phase A cap-setting takeaway (Sprint 31.92.6 observation):** account for
cross-layer composition expansion + AC compliance sweep + Phase D scope
flexibility margin (~+50 to +75 above naive sub-session-count ×
per-session-test-budget estimate). Sprint 31.92.6's actual progression:
Phase A +250 → re-baseline +300 at S5a-2 → final +332 (+32 structural-
work-driven overage at S5b).

<!-- Origin: ARGUS Sprint 31.92.6 (2026-05-10). See ARGUS
     docs/process-evolution.md § F.24 for the canonical narrative;
     CLAUDE.md sprint-health note records the +332 one-shot overage
     disposition. -->

### API-Surface Verification (mandatory; gates Phase B)

**Empirical anchor:** W-2 confirmed across 4 consecutive sprints (Sprint 31.92, 31.92.5, 31.92.65, 31.92.7). Each Round-1 adversarial-review verdict in those sprints surfaced 3–4 Critical primitive-semantics misses attributable to un-verified API/method/class/field/file-path citations. The mandatory artifact + Phase B gating prevents these misses from leaving Phase A.

**Binding rule:** RULE-056 (Phase A API-surface verification artifact non-bypassable — see `claude/rules/universal.md`).

**Procedure:**

1. After authoring the joint design summary, problem statement, and any other Phase A artifacts, the Phase A author produces `docs/sprints/<sprint-id>/phase-a-api-surface-audit.md` using the canonical template at `templates/phase-a-api-surface-audit.md`.
2. The artifact enumerates **every production-code name** cited in any Phase A artifact:
   - functions / methods / classes / dataclass fields / attributes / ABC methods
   - file paths / config field names / enum values / constants
3. Each row is classified VERIFIED-SIGNATURE / VERIFIED-BODY / NEW / DRIFT per the template. The two VERIFIED statuses make verification *scope* explicit — signature/existence vs body-contents — so a reviewer reading the audit at a later anchor SHA does not mistake a pre-revision body for incomplete absorption (W-NEW-1).
4. **DRIFT rows GATE Phase B.** Phase B cannot proceed until all DRIFT rows are RESOLVED (citing artifact corrected + resolution commit SHA recorded in the audit artifact's Section 2).
5. The Phase A author asserts completion via the audit artifact's Section 3 checklist. Phase B is structurally blocked until all Section 3 checkboxes resolve.

**Why this is non-bypassable:**

The 4-consecutive-sprint W-2 confirmation produced specific example misses preserved in the audit's empirical-anchor citations:

- Sprint 31.92.7 R1: `broker.get_positions(symbol)` doesn't exist; `on_order_filled` doesn't exist (actual: `on_fill`); "12-field metadata" (actual: 13).
- Sprint 31.92.65 R1: `ActiveAlert.last_observed_at` doesn't exist; `bulk_ack_id` column doesn't exist; `HealthMonitorConfig` doesn't exist (actual: `AlertsConfig`).
- Sprint 31.92.65 R2: `bus.emit()` doesn't exist (actual: `publish()`); `Layout.tsx` mount path doesn't exist (actual: `AppShell.tsx`); `frontend/...` path prefix doesn't exist (actual: `argus/ui/src/...`); `operations.sql` file doesn't exist (Python migrations).

Each of these misses would have been caught at the Phase A audit; each cost an adversarial-review cycle to surface. The mandatory artifact's cost (~30 min for the Phase A author) is amortized across every adversarial-review cycle it eliminates.

### Phase B: Checkpoint

Before generating any artifacts:

    "Before we generate the sprint package, produce a compact design summary
    that captures everything we have decided. If we lose context, this summary
    alone should be sufficient to regenerate all artifacts."

The design summary should follow the design-summary template (see templates/design-summary.md).
Save it immediately after generation.

### Phase C: Generate Spec-Level Artifacts

Generate the spec-level artifacts one at a time, in this order:

1. Sprint Spec (using templates/sprint-spec.md)
2. Specification by Contradiction (using templates/spec-by-contradiction.md)
3. Session Breakdown (list of sessions with scope, dependencies, and compaction
   risk score. Each session must include the scoring table showing points per
   factor and total. Any session scoring 14+ must be split before proceeding.
   Each session must list Creates / Modifies / Integrates / Parallelizable columns.))
4. Sprint-Level Escalation Criteria
5. Sprint-Level Regression Checklist
6. Doc Update Checklist
7. If adversarial review is warranted: **Adversarial Review Input Package** --
   extract and assemble the specific architecture document sections, DEC entries,
   and any other context the adversarial reviewer will need into a single
   standalone document. The developer should be able to open the adversarial
   review conversation and paste exactly three documents: the Sprint Spec, the
   Specification by Contradiction, and this input package. Do not leave the
   architecture excerpt to the developer to assemble -- identify and extract the
   relevant sections during planning, when the context is fresh.

After each artifact: save it, confirm saved, then request the next.

**Do NOT generate implementation prompts or review prompts in this phase.**
These are downstream of the spec-level artifacts and should only be generated
after any adversarial review revisions are resolved (Phase D or Phase E).

If compaction occurs mid-generation:
1. Start a new conversation
2. Paste the design summary from Phase B
3. List which artifacts are already saved
4. Continue from where generation stopped

### Mechanical pairwise file-overlap matrix (Phase C artifact per F.21, canonical per Sprint 31.92.5)

For sprints with parallel-marked sessions, author a mechanical pairwise
file-overlap matrix as a Phase C artifact at
`docs/sprints/sprint-<N>/wave-parallelization-audit.md`:

| Session | Files modified | Overlap with siblings? |
|---|---|---|
| Sxa | argus/execution/foo.py + tests/execution/test_foo.py | None |
| Sxb | argus/execution/bar.py + tests/execution/test_bar.py | None |
| Sxc | argus/core/baz.py + tests/core/test_baz.py | None |

Pairwise overlap analysis: for every (Si, Sj) pair where both are
Parallelizable: True, verify file sets are disjoint. If overlap exists,
sequentialize or rescope.

DEC-399 (Sprint 31.92.5) is the canonical adoption of this pattern as a
process decision.

### FAI completeness with multi-tier defense in depth (canonical per Sprint 31.92)

When authoring FAI (Falsifiable Assumption Inventory), include multi-tier
defense-in-depth coverage:

1. **Primary tier**: the assumption itself (canonical detection mechanism)
2. **Secondary tier**: detection failure mode (what if primary detection
   fails)
3. **Tertiary tier**: defense-in-depth refusal (what if secondary detection
   fails)

Sprint 31.92's L1 Mechanism A binary gate + L2 detection-and-suppression +
L3 SELL-volume ceiling with reconstructed-position refusal is the canonical
example: each layer carries an independent assumption + falsification path.

FAI items that cover only primary detection without secondary/tertiary
fallback are incomplete; surface as Phase E REVISE_PLAN trigger.

### Cross-layer test scope-shaping (canonical per Sprint 31.92 F.7)

When sprint scope includes cross-layer composition tests, the test surface
may exceed sprint bandwidth. CL-N deferral rationale (e.g., Sprint 31.92's
CL-6 deferral) is acceptable when:

1. The deferred cross-layer test verifies a layer-N+M composition that
   sub-rest of the sprint structurally covers via independent layer tests
2. The deferred test is enumerated in the sprint-spec with explicit
   "deferred to <successor-sprint>" rationale
3. The next sprint absorbs the deferred test as part of its sprint-spec

CL-N deferrals should NOT exceed 2 per sprint; if 3+ cross-layer tests
defer, the sprint scope itself needs Phase A re-evaluation.

### Cross-Document API-Shape Matrix (W-4 binding)

**Empirical anchor:** W-4 confirmed at Sprint 31.92.7 Round-2 drift cleanup (commit `7e0f780e`: 33 edits across 12 secondary artifacts). Four patterns persisted after Round-2 verdict's primary-surface corrections: `on_fill` rename (4 surfaces), Fork B selection (6 surfaces), "13-field" correction (8 surfaces), count-chain update (13 surfaces), S4 keyword (2 surfaces).

**Procedure:**

1. After Phase C produces the sprint-spec, joint design summary updates, and impl prompts, the Phase C author initializes `docs/sprints/<sprint-id>/cross-document-api-shape-matrix.md` using the canonical template at `templates/cross-document-api-shape-matrix.md`.
2. The matrix enumerates every API/method/class/field/file-path cited in the sprint package, tracked across columns for each downstream artifact (sprint-spec, joint design summary, per-session impl prompts, regression-checklist, doc-update-checklist, tier-3-review-input-template, escalation-criteria, phase-e-quality-checklist).
3. **Refresh cadence:** the matrix is refreshed at **every revision pass** (per the Phase D Revision-Pass Sweep Checklist below). Each pass appends a row to the matrix's update log (Section 2).

**Why this is a Phase C deliverable:**

W-4's empirical signature: 33 edits at Round-2 drift cleanup arrived AFTER the primary-surface corrections. The drift surfaced because the revision-pass author updated only the canonical citation (e.g., sprint-spec.md AC1.1) and the secondary-document citations (e.g., regression-checklist check #4) lagged. The matrix makes the multi-document drift surface visible at revision-pass time, preventing the drift from accumulating to a Round-2 verdict finding.

### Phase C-1: Adversarial Review Gate

If adversarial review was warranted (Phase A, step 8):

1. **Stop this conversation.** Do not proceed to prompt generation.
2. Run the adversarial-review protocol in a separate conversation (using the
   Adversarial Review Input Package from Phase C, step 7).
3. If the adversarial review produces required revisions:
   a. Open a third conversation (or continue in this one if context allows).
   b. Resolve each finding (Critical first, then Significant).
   c. Update the Sprint Spec, Specification by Contradiction, Session Breakdown,
      Escalation Criteria, Regression Checklist, and Doc Update Checklist as needed.
   d. Produce a brief Revision Rationale document logging each decision.
   e. **Apply the Substantive vs Structural decision rubric** (see
      `protocols/adversarial-review.md` § Resolution). If any rubric trigger
      fires, the dispositions are structural — return to Phase B for re-run.
      Otherwise revisions may be applied directly.
   f. **Run another adversarial review round** (Round N+1) on the revised
      artifacts. Round N+1's bar is whether the revisions themselves
      introduced new issues. Continue until Outcome A (Round CLEAR) is
      reached, OR Outcome C (pattern-of-Criticals) triggers full Phase A
      re-entry. See `protocols/adversarial-review.md` § Resolution for the
      three-outcome state machine.
4. Proceed to Phase D with the final (post-revision) spec-level artifacts.

If adversarial review was NOT warranted: proceed directly to Phase D.

### Operator-override with proportional in-sprint mitigation (canonical per Sprint 31.92 F.8)

When adversarial review surfaces borderline-class concerns (Round 3 C-R3-1
style), operator may override with proportional in-sprint mitigation rather
than full revision. The override is documented in Phase C's adversarial-
review-rationale artifact with:

1. The concern class (HIGH / MEDIUM / LOW / borderline)
2. The mitigation shape (e.g., add canary test + watchdog + cross-layer
   composition test instead of full impl re-architecture)
3. Why the proportional mitigation suffices (structural reasoning)
4. The acceptance gate (typically Tier 3 review of the mitigation outcome)

The override is the operator's signal to the reviewer that the concern was
considered; it is NOT a Tier 2-bypass mechanism.

### Phase D: Generate Prompts

With finalized spec-level artifacts in hand, generate prompts:

1. **Review Context File** -- a single shared document containing:
   - Review instructions (read-only, follow review skill)
   - The full Sprint Spec (embedded, not referenced)
   - The full Specification by Contradiction (embedded)
   - The Sprint-Level Escalation Criteria (embedded)
   - The Sprint-Level Regression Checklist (embedded)

   This file is written once and referenced by the @reviewer subagent invocation
   embedded in each session's implementation prompt (see
   `templates/implementation-prompt.md` § Tier 2 Review (Mandatory — @reviewer
   Subagent)). In HITL-fallback mode, standalone review prompts also reference
   this file by path.
   Save as `review-context.md` in the sprint directory (see File Layout below).

2. For each session:
   a. **Implementation Prompt** (using templates/implementation-prompt.md).
      **File name:** `sprint-{N}-{session_id}-impl.md` in the sprint directory.
      The runner expects this exact naming convention (see File Layout section).
      The Sprint-Level Regression Checklist and Escalation Criteria should
      be embedded directly in each implementation prompt (the implementer
      does not have the review context file).

      If this sprint adds new config fields, include in the implementation
      prompt for the relevant session: "Write a test that loads the YAML
      config file and verifies all keys under the new section are recognized
      by the Pydantic model (no silently ignored fields)."

      If the sprint has multiple sessions, apply test suite tiering (DEC-328):
      - Session 1 pre-flight: full suite with `-n auto`
      - Session 2+ pre-flights: scoped test command for that session's modules
      - All close-outs: full suite with `-n auto` (handled by close-out skill)
      - Non-final reviews: scoped test command
      - Final review: full suite with `-n auto`
      This reduces full suite runs from 3× per session to ~4 total per sprint.

   b. **Tier 2 Review (inline @reviewer subagent invocation, not a standalone
      prompt).** Default Phase D does NOT produce a standalone review-prompt
      file. The implementation prompt's §Tier 2 Review (Mandatory — @reviewer
      Subagent) section provides the reviewer invocation inline; the @reviewer
      subagent runs in its own context window with read-only tool restrictions
      (plus the one permitted write: the review report file), examines the diff,
      and writes its review report to `docs/sprints/sprint-{N}/session-{M}-review.md`
      within the same CLI invocation as the implementation session.

      Each impl prompt's §Tier 2 Review section embeds:
      - The review-context-file path (e.g., `sprint-22/review-context.md`).
      - The close-out report path (`docs/sprints/sprint-{N}/session-{M}-closeout.md`).
      - The diff range (e.g., `git diff HEAD~1`).
      - The test command (per DEC-328 tiering).
      - The "files that should NOT have been modified" list.
      - The session-specific review focus items.
      - The Sprint-Level Regression Checklist (embedded).
      - The Sprint-Level Escalation Criteria (embedded).

      These are exactly the fields a standalone review prompt would have carried;
      they are now encoded inside the impl prompt itself. The developer's
      workflow: paste the impl prompt; the implementation session runs, writes
      the close-out, then invokes @reviewer which produces the review report.
      No separate review-prompt file required.

      **HITL-fallback (optional, NOT default):** A standalone review prompt
      MAY be generated for sprints that explicitly run review as its own CLI
      invocation rather than as a subagent within the implementation session.
      In that case use `templates/review-prompt.md` per its deprecation-header
      guidance and produce `sprint-{N}-{session_id}-review.md` in the sprint
      directory. Otherwise, omit standalone review-prompt generation from
      Phase D entirely.

      Empirical evidence base: Sprint 31.92 (six refresh sessions —
      S2a-prompt-refresh + S2b-prompt-refresh + S3a/S3b combined refresh + S4
      trifold + S5 trifold) consistently VESTIGIAL-marked standalone review
      prompts; the impl prompt's inline §Tier 2 Review section was authoritative
      across all execution paths. See `templates/review-prompt.md` deprecation
      header for the cross-reference.

3. **Work Journal Handoff Prompt** -- a self-contained document that the
   developer pastes into a fresh Claude.ai conversation to create the
   Sprint Work Journal (see in-flight-triage.md). The handoff prompt
   must include:
   - Sprint goal and scope summary
   - Session breakdown table (session, scope, creates, modifies, score)
   - Session dependency chain
   - "Do not modify" file list
   - Issue category definitions (from in-flight-triage.md, summarized)
   - Escalation triggers (from Sprint-Level Escalation Criteria)
   - Reserved DEC/RSK/DEF numbers

   The developer opens the work journal conversation before starting
   Session 1 and brings issues to it throughout the sprint.

After each artifact: save it, confirm saved, then request the next.

### Implementation prompts: structural anchors over line numbers

Implementation prompts MUST reference structural anchors rather than absolute line numbers. The recurring stale-line-number disclosures across multiple Tier 3 reviews (Tier 3 #1 flagged the pattern; Sprint 31.91 S5b's RULE-038 disclosure made it concrete with `:453` actual `~:570` and `:531` actual `~:416-420`) demonstrate that absolute line numbers drift between prompt authoring and prompt consumption.

Required anchor types (use one or more, in priority order):

1. **Function name + class name (if applicable):** e.g., "in `_emit_ibkr_auth_failure_alert` method of `IBKRBroker` class".
2. **Distinctive comment / docstring regex:** e.g., "the line immediately preceding the comment beginning `# Sprint 31.91 Session 5a.2 (DEF-213): rehydrate alert state`".
3. **Distinctive call-pattern regex:** e.g., "every site matching `_broker\.place_order\(Order\(.*side=SELL`".
4. **File-section heading (for docs):** e.g., "under the `## DEFs` heading in `CLAUDE.md`, after the row for DEF-216".

Where line numbers are referenced (e.g., for cross-reference convenience or in error logs), they MUST be flagged as "directional only — verify via grep before editing" and the prompt MUST include a verbatim grep-verify command block.

If the grep-verify reveals drift, the implementer MUST disclose under RULE-038 in the close-out and proceed against the actual structural anchors.

This requirement applies to all impl prompts authored under `protocols/sprint-planning.md` v1.2.0+.

### Anticipating mid-sprint doc-syncs

Sprint planning should anticipate possible triggers for mid-sprint doc-syncs:

- **Tier 3 review checkpoints** (per `escalation-criteria.md`'s A-class halts): Tier 3 verdicts often surface materializable items requiring mid-sync.
- **Impromptu hotfixes** (per `protocols/impromptu-triage.md`): impromptus that change DEF-table state require a mid-sync to record the change in CLAUDE.md.
- **Contradiction discoveries** (mid-sprint discovery that the spec is wrong or implementation reality has diverged): may require mid-sync amendments to sprint-spec, impl prompts, or escalation criteria.

For each anticipated trigger, the sprint plan should note:
- Which session(s) might emit the trigger.
- What the mid-sync is expected to update (rough scope).
- Whether DECs are likely to materialize at the mid-sync (Pattern A) or be deferred to sprint-close (Pattern B per `protocols/mid-sprint-doc-sync.md`).

See `protocols/mid-sprint-doc-sync.md` for the full mid-sync protocol.

### Phase-D-time spec-vs-implementation framing reconciliation

When Phase D generates impl prompts that reference Phase B/C sprint-spec
narrative, verify the sprint-spec framing matches the actual implementation
shape that Phase D produces. Sprint 31.92.6 Tier 3 #2 surfaced two framing
divergences caught only at S5b's AC validation suite execution:

1. **Mode-of-acceptance divergence**: spec narrative may carry a previously-
   ratified adversarial-review proposal (e.g., M-9 SUPERSEDES) while impl
   prompts honor a later operator disposition (e.g., R9 PARTIAL ACCEPT). The
   spec narrative and implementation should reconcile at Phase D, not at
   sprint-close.

2. **Deliverable-label repurposing**: spec deliverable labels (e.g., "Del. H'")
   may be repurposed in impl prompts for different content than the spec
   defines (Sprint 31.92.6 "Del. H'" → spec's Del. L watchdog work).
   Repurposings should be reconciled at Phase D OR at sprint-close per
   path (a)-style reframe.

**Phase-D-time check (recommended):** for each impl prompt, grep the spec
for the deliverable label and confirm the impl scope matches. Where
divergences exist, document inline in the impl prompt's "Mode of acceptance"
or "Deliverable mapping" section. If reconciliation cannot land at Phase D,
file the divergence as a Tier 3 input artifact for mid-sprint review.

### Sibling-parallel git-diff verification (canonical per Sprint 31.92.5)

For Phase D sessions marked Parallelizable: True (relative to siblings), the
mechanical pairwise file-overlap matrix (Phase C artifact per F.21) defines
disjoint file scopes. At session close, verify:

```bash
git diff --name-only <predecessor-anchor>..<session-commit>
# Output must NOT overlap with sibling-session diffs
```

When parallel sessions both modify a shared file (e.g., docs/sprint-history.md
sprint append entries), the sibling-parallel discipline is broken; convert
to sequential execution OR rescope.

### Revision-Pass Sweep Checklist (canonical from synthesis-sprint-31.92.7)

A revision pass MUST include the following sweeps. Failure to sweep is a recurring Round-(N+1) audit finding (W-NEW, W-1, W-NEW additive variant).

#### Sweep 1 — Bidirectional Phase A ↔ Phase C Consistency Check (W-1)

**Empirical anchor:** Sprint 31.92.65 Round 2 N-R2-4 — joint design summary §A4 still cited the REJECTED cadence-from-`last_emit_at` architecture after Round-2 revision moved cadence producer-side. Surgical fix corrected at commit `f09e9dad`. The risk: Sprint 31.92.7 planner reading the joint summary for Sprint 31.92.65 context would inherit the stale architectural commitment.

**Procedure:** After Phase C amendments alter any architectural choice, the revision-pass author MUST sweep Phase A artifacts (joint design summaries, problem statements, preliminary design documents) and either:

- **Update** the Phase A artifact to reflect the new architecture, OR
- **Annotate** the Phase A section as "superseded by Phase C Amendment AMD-N" with a cross-reference to the absorbing amendment.

Failure to update OR annotate is a Major Round-(N+1) finding (cross-sprint contamination risk).

#### Sweep 2 — Constraints / Scope / Review-Focus / DoD / Narrative Sweep (W-NEW amendment-class)

**Empirical anchor:** Sprint 31.92.65 Round 2 N-R2-2 (Critical) — S2 impl Constraints section still said "this session reads `last_emit_at` from existing ActiveAlert" after Round-1 revision moved cadence producer-side and removed `last_emit_at`. The implementer would have prioritized the "Do NOT modify" warning as authoritative — leading to broken implementation.

**Procedure:** When a revision pass changes an architectural surface, sweep ALL of:

- §Constraints sections (per impl prompt)
- "Do NOT modify" warnings (per impl prompt + per session)
- §Scope Boundaries (per impl prompt)
- §Review Focus items (per impl prompt)
- §Definition of Done bullet lists (per session)
- Narrative text containing FAI / AC / DEC / RSK enumerations (across all artifacts)

For each surface, verify the prior-revision-state instruction has been updated to match the new architectural state. Run `grep -rciE "<stale-pattern>" docs/sprints/<sprint-id>/` and confirm 0 hits before declaring sweep complete.

#### Sweep 3 — Additive-Change Letter-Suffix Sweep (W-NEW additive variant)

**Empirical anchor:** Sprint 31.92.65 Round 3 N-R3-NEW-1 (Minor) — adding FAI-65-D updated the canonical FAI table + S1 spike spec, but 3 narrative/DoD/Review-Focus references in S5 still listed "FAI-65-A/B/C" instead of "FAI-65-A/B/C/D" (at lines 54, 253, 348).

**Procedure:** When adding FAI-X / AC-X / DEC-X / RSK-X to a sprint that already contains the (X-1) variant, sweep ALL references to (X-1)-bounded letter-suffix lists and append X:

```bash
# Example: adding FAI-65-D
grep -rciE 'FAI-65-A/B/C(?!/D)' docs/sprints/sprint-31.92.65/
# Expected after sweep: 0 hits (all updated to A/B/C/D)
```

The sweep targets enumerations in narrative, DoD, Review Focus, regression-checklist items — anywhere a letter-suffix list might enumerate the prior count.

#### Sweep 4 — Cross-Document API-Shape Matrix Refresh (W-4 binding)

After completing Sweeps 1–3, append a row to the sprint's `cross-document-api-shape-matrix.md` update log (§Section 2) capturing the revision pass's changes:

- Rows added (new names introduced by amendments)
- Rows updated (existing names appeared in new locations)
- Rows DRIFT → CORRECTED (pre-revision drift cleared by this pass)
- New patterns identified (if any)

The matrix refresh is the durable record that all 4 sweeps completed.

### Phase E: Verify

After all artifacts are generated:

    "Review all generated artifacts against the design summary. Flag any
    inconsistencies, gaps, or mismatches between the spec and the prompts."

---

## Workflow Mode Integration

### If Adversarial Review is warranted:
Follow the Phase C-1 gate described above. The key principle: **spec-level
artifacts are generated before the adversarial review; prompts are generated
after.** This prevents generating prompts twice.

The Adversarial Review Input Package (Phase C, step 7) must be generated
during Phase C so the developer has everything needed to start the adversarial
review without additional preparation.

### If Iterative Judgment Loop is needed:
Modify the session breakdown:
- Plan shorter, more numerous sessions
- Budget 2-3x more sessions than equivalent backend work
- Include screenshot/visual verification steps in each implementation prompt
- Note specific visual elements to check after each session

### If Synthetic Stakeholder is warranted:
Run it during Phase A of this conversation:

    "Before we finalize the spec, roleplay as [a consumer of this API /
    a user of this interface / a developer integrating with this system].
    What would frustrate you? What would be missing? What would be confusing?"

Incorporate findings into the spec before moving to Phase B.

---

## Quality Checks

Before ending the conversation, verify:
- [ ] Every session prompt has a clear single objective
- [ ] Every session prompt includes pre-flight checks
- [ ] Every session prompt includes explicit file paths and scope boundaries
- [ ] Every session prompt includes "do not modify" constraints
- [ ] Every session prompt ends with close-out skill invocation
- [ ] Every session prompt embeds the Sprint-Level Regression Checklist and
      Escalation Criteria directly (implementer does not have review context file)
- [ ] Every session's impl prompt includes the §Tier 2 Review (Mandatory —
      @reviewer Subagent) section providing the reviewer invocation inline
      (default path; standalone review-prompt files are HITL-fallback only
      per `templates/review-prompt.md` deprecation header)
- [ ] Review Context File contains full Sprint Spec, Spec by Contradiction,
      regression checklist, and escalation criteria
- [ ] Every impl prompt's §Tier 2 Review section references the Review Context
      File by path (provided to the @reviewer subagent)
- [ ] Every impl prompt's §Tier 2 Review section instructs the @reviewer to
      read the close-out from `docs/sprints/sprint-{N}/session-{M}-closeout.md`
      (no operator-filled placeholder; close-out is read from disk)
- [ ] No session has a compaction risk score of 14 or above (must be split)
- [ ] The regression checklist covers all critical invariants
- [ ] The escalation criteria are specific and evaluable (not vague)
- [ ] The doc update checklist covers every document affected by this sprint
- [ ] Numbering is correct (DEC/RSK/DEF ranges reserved if needed)
- [ ] If adversarial review was warranted: spec-level artifacts reflect all
      revisions; prompts were generated from post-revision specs
- [ ] If adversarial review was warranted: input package was generated with
      relevant architecture sections extracted (developer pastes, not assembles)
- [ ] If sprint touches safety-load-bearing code: Falsifiable Assumption
      Inventory is present in design summary AND sprint spec; every load-bearing
      primitive-semantics assumption is listed; every entry's Status is
      "falsified" (or "unverified" with explicit written justification);
      no entries are "measured-only"
- [ ] **F.5 structural closure framing**: Phase E verdict language must frame
      closure structurally (e.g., "Mechanism A landed; AC1.4 invariance holds;
      6 cross-layer composition tests preserve binary-gate semantics") rather
      than aggregate percentage claims (e.g., "85% of ACs are met"). Aggregate
      claims obscure binary-gate semantics; structural claims preserve them.
      Canonical per Sprint 31.92's structural closure verdict.
- [ ] If any Tier 3 mandatory trigger fires (per `protocols/tier-3-review.md`
      § Mandatory Triggers): mandatory mid-sprint Tier 3 is scheduled in the
      session breakdown at the natural architectural-closure milestone
- [ ] Every session's Creates/Modifies/Integrates columns are filled in the
      Session Breakdown -- no module is created without a session that integrates it
- [ ] If new config fields are added: YAML field names verified against Pydantic
      model names; regression checklist includes config validation item
- [ ] Frontend sessions with visual review items have a budgeted fix slot
- [ ] Work journal handoff prompt is self-contained (no "paste X here" —
      all sprint context embedded)
- [ ] Every implementation prompt includes structured close-out requirement
- [ ] Every impl prompt's §Tier 2 Review section includes the structured
      verdict requirement (default path; standalone review prompts in
      HITL-fallback mode also include the structured verdict requirement
      per `templates/review-prompt.md`)
- [ ] Parallelizable flags are set with justification for all `true` values
- [ ] No session flagged as parallelizable also scores 14+ on compaction risk
- [ ] If autonomous mode planned: runner config has been reviewed
- [ ] If autonomous mode planned: session order in runner config matches
      session breakdown dependency chain
- [ ] All prompt files follow runner naming convention: `sprint-{N}-{session_id}-impl.md`
      and `sprint-{N}-{session_id}-review.md` in the sprint directory root (no subdirectories)
- [ ] If frontend sessions run Vitest: project has `testTimeout` and `hookTimeout`
      configured (prevents orphaned worker processes from hanging indefinitely)
- [ ] Tracker nicknames reconcile with actual spec filenames. If the session
      list in the tracker uses thematic shorthand ("frontend, solo"), verify
      the generated spec filename describes the real scope. A tracker label
      that drifts from the spec produces kickoffs that trust the wrong
      context at session start.
      <!-- Origin: Sprint 31.9 retro, P13. Stage 6 was tracker-nicknamed
           "frontend, solo" but FIX-08's actual spec was backend-only. -->

---

## Artifact Summary

A complete sprint package contains:

**Spec-level artifacts (Phase C -- generated before adversarial review):**
1. Design Summary (compaction insurance)
2. Sprint Spec
3. Specification by Contradiction
4. Session Breakdown (with Creates/Modifies/Integrates per session)
5. Sprint-Level Escalation Criteria
6. Sprint-Level Regression Checklist
7. Doc Update Checklist
8. Adversarial Review Input Package (if warranted)
9. Revision Rationale (if adversarial review produced changes)

**Prompt-level artifacts (Phase D -- generated after adversarial review):**
10. Review Context File (single shared file)
11. Implementation Prompts (one per session) — each impl prompt embeds the
    §Tier 2 Review (Mandatory — @reviewer Subagent) section providing the
    reviewer invocation inline. Default Phase D produces NO standalone
    review-prompt files; the @reviewer-subagent invocation is inline.
12. Standalone Tier 2 Review Prompts (HITL-fallback only — see
    `templates/review-prompt.md` deprecation header. Default execution
    embeds @reviewer-subagent invocation inside each Implementation Prompt
    and does NOT produce standalone review-prompt files.)
13. Work Journal Handoff Prompt (for in-flight triage conversation)
14. Runner Configuration (runner-config.yaml, if autonomous mode planned)

---

## Sprint Package File Layout

All sprint package files live in a single flat directory. The runner constructs
prompt file paths from the sprint directory name and session IDs in
`session_order` — subdirectories (e.g., `prompts/`) are NOT supported.

**Directory:** `docs/sprints/sprint-{N}/`

**Naming convention:**

| File | Name Pattern | Example |
|------|-------------|---------|
| Design Summary | `design-summary.md` | `design-summary.md` |
| Sprint Spec | `sprint-spec.md` | `sprint-spec.md` |
| Spec by Contradiction | `spec-by-contradiction.md` | `spec-by-contradiction.md` |
| Session Breakdown | `session-breakdown.md` | `session-breakdown.md` |
| Escalation Criteria | `escalation-criteria.md` | `escalation-criteria.md` |
| Regression Checklist | `regression-checklist.md` | `regression-checklist.md` |
| Doc Update Checklist | `doc-update-checklist.md` | `doc-update-checklist.md` |
| Review Context | `review-context.md` | `review-context.md` |
| Runner Config | `runner-config.yaml` | `runner-config.yaml` |
| Implementation Prompt | `sprint-{N}-{session_id}-impl.md` | `sprint-24.5-session-1-impl.md` |
| Review Prompt (HITL fallback only) | `sprint-{N}-{session_id}-review.md` | `sprint-24.5-session-1-review.md` |
| Work Journal Handoff | `work-journal-handoff.md` | `work-journal-handoff.md` |

**Critical:** The runner builds prompt paths as `{sprint_dir}/{sprint_name}-{session_id}-impl.md`
(see `state.py` line ~301). The `{session_id}` values come from `session_order` in
`runner-config.yaml`. If the prompt files don't match this pattern exactly, the
runner will halt with "Prompt file not found."

**Close-out and review reports** (written during execution, not during planning):
- `session-{M}-closeout.md` — written by the implementation session
- `session-{M}-review.md` — written by the @reviewer subagent

---

## Three-Stream Parallel Execution (canonical from synthesis-sprint-31.92.7)

**Empirical anchor:** O-1 validated during Sprint 31.92.7 + Sprint 31.92.65 concurrent planning window. Sprint 31.92.7 revision pass + Sprint 31.92.65 revision pass + Work Journal initialization successfully ran in parallel with disjoint file targets.

### When parallel execution is permissible

The pattern is permissible when **all** of the following hold:

1. **Disjoint file targets.** Each parallel stream operates on a separate sprint folder, and the streams do not share any file. Verify via `git status` per stream — any overlap aborts parallelization.
2. **≤3 active Claude.ai conversations + 1 Work Journal.** Cognitive load ceiling. Beyond this count, operator context-switching cost exceeds throughput gain.
3. **Adversarial review is NOT in parallel with its own revision pass.** The audit-trail dependency is sequential: a revision pass MUST commit before the next adversarial review on the same sprint begins. (Parallel adversarial review of OTHER sprints is fine.)

### When parallel execution is NOT permissible

- Two streams modifying the same file (even at non-overlapping line ranges) — merge conflicts are likely; the operator's mental model degrades.
- Two streams within the same sprint (e.g., S2 + S3 of Sprint 31.92.7) — implementation-prompt dependencies create sequential ordering.
- Adversarial review of Sprint X in parallel with the revision pass of Sprint X — the reviewer needs the revision pass's commit as audit-trail input.

### Operational guidance

- **Begin parallel streams with explicit boundary declaration:** name each stream (e.g., "Stream A: Sprint 31.92.7 R2 revision"; "Stream B: Sprint 31.92.65 R2 revision"; "Stream C: Sprint 31.92.8 Work Journal initialization"). Operator tracks stream-level progress separately.
- **Use Self-Anchoring Pre-Flight per stream:** each stream captures its own anchor SHA. Streams may capture different SHAs if commits land between stream starts.
- **No cross-stream conversation hopping mid-edit:** once a stream's session is in-flight (impl prompt being executed), avoid context-switching to another stream until the current session's close-out is written.

### Failure modes

- **Phantom merge conflicts:** if two streams' files appear adjacent in the repo tree, even disjoint files can cause review-time visual confusion. Mitigation: explicit stream-name in commit messages.
- **Operator memory leak:** running 3 streams + a Work Journal for >3 hours leads to per-stream state confusion. Mitigation: rotate streams every ~90 minutes; capture stream-state in Work Journal between rotations.
