<!-- workflow-version: 1.0.0 -->
<!-- last-updated: 2026-04-26 -->

# Scoping Session Prompt Template

A **scoping session** is a read-only investigation session that produces structured findings + a generated fix prompt for a follow-on session. Use it when the root cause of a symptom is non-obvious and a quick-fix attempt would be premature.

This template generates the implementation prompt for the scoping session itself. The session's outputs (findings + generated fix prompt) become inputs to the follow-on fix session.

For when to use the two-session scoping pattern (vs. a single-session impromptu fix), see `protocols/impromptu-triage.md` §"Two-Session Scoping Variant."

## Template

Fill in the bracketed placeholders. Sections marked OPTIONAL can be omitted if not applicable.

```markdown
# Scoping Session: [Symptom or Topic]

## Objective

Investigate the root cause of [SYMPTOM]. Produce two outputs:

1. **Structured findings document** at `[PATH/findings.md]` covering: code-path map, hypothesis verification, race conditions analyzed, root-cause statement, fix proposal, test strategy, risk assessment.
2. **Generated fix prompt** at `[PATH/fix-prompt.md]` ready to be pasted into a follow-on Claude Code session for implementation.

## Read-Only Constraints

This session is **READ-ONLY**. Do NOT modify any source code, configuration, tests, or production-relevant docs. The ONLY permitted writes are:
- The findings document at the specified path.
- The fix prompt at the specified path.

If during investigation you discover a small unrelated issue (typo, dead code, etc.), log it in the findings document under "Incidental Observations" — do NOT fix in this session.

## Required Investigation

[List the specific investigations the session must perform. Examples — adapt to the symptom:]

1. **Code-path map.** Trace the execution path from [ENTRY POINT] through the code that exhibits the symptom. Document every function/class/module touched. Identify any branches, async boundaries, or race-prone interleavings.

2. **Hypothesis verification.** Enumerate ≥3 candidate root causes. For each, state how to test the hypothesis (what to grep, what to log, what state to inspect). Run the tests and document results.

3. **Race conditions and async.** If the symptom involves concurrency, explicitly map the timing diagram of the suspect interleaving. Document the assumed lock/serialization mechanism + whether it actually applies.

4. **Reproducibility analysis.** Can the symptom be reliably reproduced? In what environment? What's the minimum repro? If it's intermittent, what's the empirical reproduction rate?

5. **Side-effect surface.** What side effects does the suspect code path produce (DB writes, external API calls, file writes, log lines)? Are any of them order-dependent or non-idempotent?

## Required Outputs

### Findings Document

Structure (write to `[PATH/findings.md]`):

```markdown
# Scoping Findings: [Symptom or Topic]

## Symptom Summary
[1-2 paragraph description of the symptom]

## Code-Path Map
[Detailed trace of execution path]

## Hypothesis Verification
[For each candidate root cause: hypothesis, test, result]

## Root-Cause Statement
[Single statement: "The root cause is X. Evidence: Y. Confidence: high/medium/low."]

## Fix Proposal
[High-level fix approach. Files to modify. Risks. Test strategy.]

## Test Strategy
[How the fix will be validated. Unit tests, integration tests, smoke tests.]

## Risk Assessment
[What could go wrong with the fix. Blast radius. Rollback plan.]

## Incidental Observations
[OPTIONAL: small unrelated issues noticed during investigation; not fixed]
```

### Generated Fix Prompt

Generate a complete implementation prompt for the follow-on fix session, using `templates/implementation-prompt.md` as the structure. Write to `[PATH/fix-prompt.md]`. The fix prompt's:
- **Pre-Flight Checks** include reading the findings document.
- **Objective** is restating the root-cause + fix approach.
- **Requirements** are the specific code changes needed.
- **Constraints** include any not-touch-this-other-thing limits identified during scoping.
- **Test Targets** include the test strategy from findings.
- **Definition of Done** mirrors the implementation-prompt template's standard.

The fix prompt should be ready-to-paste — the operator can copy it into a fresh Claude Code session with no further editing in the common case.

## Constraints

- **Read-only mode.** No source code modifications. Per RULE-013 (universal.md).
- **Don't pre-empt the fix.** This session investigates; the follow-on session implements. Do NOT include fix code in the findings document; do NOT pre-implement and document.
- **Write both outputs.** The findings document and the fix prompt are both required deliverables. A scoping session that produces only findings (no fix prompt) is incomplete.
- **Confidence levels are mandatory.** The root-cause statement MUST include a confidence level (high/medium/low). Low-confidence findings → either expand the investigation or explicitly defer the fix to a strategic check-in.

## Test Targets

This session creates no executable code; the test targets are the per-hypothesis tests run during investigation.

## Definition of Done

- [ ] Findings document written at `[PATH/findings.md]`
- [ ] Generated fix prompt written at `[PATH/fix-prompt.md]`
- [ ] All ≥3 hypotheses tested and documented
- [ ] Root-cause statement includes confidence level
- [ ] No source code modified (verify via `git status`)
- [ ] Close-out report written
- [ ] Tier 2 review completed via @reviewer subagent

## Close-Out

Standard close-out per `claude/skills/close-out.md`. Note that the Tier 2 review of this session focuses on findings rigor + fix-prompt completeness; not implementation correctness (the fix isn't implemented yet).

## Tier 2 Review (Mandatory)

The @reviewer reads:
1. Review context (sprint-level)
2. The findings document
3. The generated fix prompt
4. The git diff (should show only the two output files added)

The @reviewer's verdict criteria:
- **CLEAR:** Findings rigorous (≥3 hypotheses tested), root-cause statement clear with confidence level, fix prompt ready-to-paste, read-only constraint preserved.
- **CONCERNS:** Findings underspecified (e.g., only 1 hypothesis tested), fix prompt missing required sections, confidence level absent, etc.
- **ESCALATE:** Read-only constraint violated (source code modified), root-cause statement contradicted by evidence, fix prompt would cause harm if executed as-is.
```

The above is the complete template content. Note that the template is a META-template — it produces implementation prompts for scoping sessions, which themselves produce findings + fix prompts.

<!-- Origin: synthesis-2026-04-26 evolution-note-3 (phase-3-fix-generation-
     and-execution). ARGUS Sprint 31.9 ran several scoping-session +
     fix-session pairs (e.g., IMPROMPTU-04 mechanism diagnostic →
     IMPROMPTU-05 fix). Codifying as a metarepo template so future
     campaigns can adopt the pattern without re-deriving its structure. -->
