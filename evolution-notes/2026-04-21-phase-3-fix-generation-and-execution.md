# Evolution Notes — Phase 3 Fix-Session Generation & Execution Workflow

**Date:** 2026-04-21
**Conversation title:** Claude.ai — Audit 2026-04-21 Phase 3 Fix-Prompt Generation (the long conversation that started from a Phase 2 CSV of 379 findings and ended with a complete Phase 3 execution package: 22 FIX-session prompts, Work Journal handoff, automation script, and 8-stage execution plan)
**Contributes to:** `workflow/protocols/codebase-health-audit.md`
**Synthesis status:** SYNTHESIZED in synthesis-2026-04-26 (commit <pending-final-synthesis-sprint-commit>). See `protocols/campaign-orchestration.md`, `protocols/operational-debrief.md`, `protocols/codebase-health-audit.md` for the resulting metarepo additions.

---

## What this conversation produced

A complete Phase 3 execution package for ARGUS's first codebase audit. Inputs were a 379-row operator-finalized Phase 2 review CSV and a phase-3-fix-generation-rules.md specification. Outputs were: 22 standalone Claude Code prompts (one per fix_session_id group), a 8-stage DAG-based execution plan with parallelization explicitly computed from a file-overlap matrix plus Rule-4 sensitivity map, a Work Journal handoff document hybridizing the claude-workflow work-journal-closeout template with audit-specific additions, a stripped automation script (--status + CLAUDE.md tests-line auto-maintenance only), and a BASELINE.md freezing the entry state. The conversation resolved several real-time questions about edge cases (CSV column drift, read-only findings with fix-now decisions, operator Option A vs B for a config-loading architectural decision) and reconciled the process with the operator's standard sprint workflow (close-out per session, Tier 2 review per session, Work Journal as primary log, final close-out via templates/work-journal-closeout.md).

---

## Novel patterns introduced (that should become metarepo-canonical)

### Pattern 1: Stage-based DAG scheduling from file-overlap + safety matrix

- **Name:** fix-session-stage-dag
- **Problem it solves:** When a Phase 2 review produces many fix-session groups (>10), naive "run them serially" wastes weekends, and naive "run them all in parallel" violates Rule 4 (sensitive-file serialization) and safety-tag discipline.
- **Mechanism:** Compute a per-group file-touch set. Cross-reference against the Rule-4 sensitive file list (main.py, order_manager.py, risk_manager.py, orchestrator.py, universe_manager.py in ARGUS's case — project-specific). Compute pairwise file-disjointness within each safety-tag pool. Greedy-pack stages such that (a) each stage contains at most one Rule-4-sensitive group, (b) all stage members have compatible safety tags, (c) all stage members have pairwise-disjoint file sets. Emit as a linear chain of stage barriers — all sessions in stage N must commit before stage N+1 opens. This compressed 22 sessions into 8 stages for ARGUS.
- **Confidence:** proven (computed, verified against the actual file matrix, produced a plan that respects all three constraints)
- **Generalizability:** broadly-applicable — any audit/sprint with >10 fix groups should use this instead of ad-hoc scheduling. The Rule-4 sensitive file list varies per project but the algorithm is project-agnostic.

### Pattern 2: Per-row safety-tag override table for CSV drift

- **Name:** csv-drift-override-table
- **Problem it solves:** Phase 2 review CSVs with embedded newlines inside suggested_fix fields can clobber downstream columns (specifically, the safety column). Re-editing the CSV breaks the operator-finalized contract.
- **Mechanism:** Identify the drifted rows by matching safety values against the canonical 4-tag set. For each drifted row, infer the tag from finding text + severity + file context (not from severity alone — that was rejected as unreliable). Store the overrides in a small Python dict keyed by finding_id. The generator reads the original CSV untouched and applies the override table at prompt-generation time. The drifted-row inferred tag is labeled inline in the generated prompt as `_(tag inferred — operator may override)_` so the contract remains transparent.
- **Confidence:** proven (9 drifted rows handled cleanly; none reached the wrong safety tag in the final plan)
- **Generalizability:** broadly-applicable — any multi-phase review workflow with operator-finalized CSVs should expect column drift and handle it without re-editing source.

### Pattern 3: Hybrid action-type routing for non-standard safety tags

- **Name:** non-standard-safety-routing
- **Problem it solves:** Phase 2 rules say `read-only-no-fix-needed` and `deferred-to-defs` tags route findings OUT of Phase 3. In practice, operators sometimes mark `fix-now` on these anyway because they want them handled in-campaign.
- **Mechanism:** Inside the generated prompt, each finding's action block branches on its tag:
  - `safe-during-trading` / `weekend-only` → standard code-change block
  - `read-only-no-fix-needed` → 5-step "verify + annotate" block with explicit escalation to DEF-creation if the suggested_fix asks for one (this nuance emerged mid-conversation)
  - `deferred-to-defs` → "code fix + DEF log" block requiring a DEF-NNN entry in CLAUDE.md
- **Confidence:** proven (15 such rows handled correctly in the generated prompts)
- **Generalizability:** broadly-applicable — the branching logic belongs in the Phase 3 fix-generation template itself, not in ad-hoc per-audit code.

### Pattern 4: Scoring-context fingerprint as an architectural prerequisite inside a FIX session

- **Name:** fingerprint-before-behavior-change
- **Problem it solves:** When a FIX session materially changes a pipeline's output distribution (e.g., correcting a scoring bug that had been suppressing variance), any in-flight data collected against the old pipeline becomes mis-comparable with data collected against the new pipeline. If the audit lands the fix without separating pre/post, downstream analysis (promotion decisions, comparisons, statistical tests) silently merges incomparable contexts.
- **Mechanism:** Inside the FIX session's implementation order, land fingerprint infrastructure BEFORE the behavior-changing edits. Steps: (1) new module with `compute_X_fingerprint(config)` using SHA-256 of canonical JSON, (2) idempotent schema migration adding a `fingerprint TEXT` column to the persistence store, (3) wire computation at event-capture time, (4) optional filter parameter on the downstream consumer that defaults to no-op, (5) startup log line emitting current fingerprint, (6) tests, (7) baseline test checkpoint confirming zero behavior change before proceeding to the real fix. Commit message body explicitly calls out the split so future readers understand pre-fix vs post-fix data coexist with different fingerprints.
- **Confidence:** hypothesized — we designed this but haven't yet observed it executed end-to-end (FIX-01 runs in Stage 1 of the campaign)
- **Generalizability:** needs-adaptation — the fingerprint concept itself (SHA-256 of canonical JSON with first-16-hex truncation) is broadly applicable. The "land fingerprint infra BEFORE the behavior change inside the same session" pattern is the generalizable piece. Applies to any audit or sprint where a FIX will meaningfully shift a data distribution that is being actively persisted.

### Pattern 5: Operator choice embedded in prompt with auto-propagation to dependent sessions

- **Name:** operator-choice-checkbox-with-cross-session-propagation
- **Problem it solves:** Some audit findings resolve multiple ways with meaningful architectural differences (Option A: minimum fix, Option B: structural fix). The decision belongs to the operator, not Claude Code, but once made, it affects downstream sessions.
- **Mechanism:** Embed a checkbox block inside the prompt for the first-to-execute session. Operator pre-checks before pasting into Claude Code. Downstream sessions that depend on the choice reference the earlier session's commit — specifically, they include conditional instructions ("if Option B was chosen, this session's work collapses to X") that Claude Code evaluates against the actual state of `main`. No runtime operator interaction for dependent sessions. In this audit: FIX-01 carried the Option A/B choice for `load_config()` merge semantics, and FIX-02 automatically benefited from Option B being chosen (overflow.yaml divergence becomes auto-resolved).
- **Confidence:** hypothesized — the mechanism is designed but not yet observed end-to-end
- **Generalizability:** broadly-applicable — any multi-session plan with cross-session operator-decision-dependent branches should use this instead of deferring the decision or requiring re-prompting.

### Pattern 6: Work Journal handoff as hybrid bootstrap

- **Name:** work-journal-handoff-hybrid
- **Problem it solves:** The claude-workflow `templates/work-journal-closeout.md` is written for standard sprints (3–8 serial sessions). Audit campaigns (20+ sessions, multi-stage, parallelism) need audit-specific framing that doesn't fit into the template's shape but also shouldn't abandon the template.
- **Mechanism:** Produce a hybrid handoff document whose top half is audit-campaign-specific (baseline, 8-stage plan, paste protocol, running-register format, escalation criteria, campaign regression checklist) and whose bottom half points at the canonical claude-workflow close-out template for the final Stage 8 deliverable. The Work Journal conversation reads the hybrid handoff once, then ingests paste-able close-out and review blocks from each session per the canonical skill files (`workflow/claude/skills/close-out.md` and `review.md`). At campaign end, the Work Journal produces a filled-in doc-sync prompt per the standard template's human-in-the-loop mode.
- **Confidence:** proven (the handoff document was produced, reviewed, corrected once for a stale DEF reference, and seeded into the expected Claude.ai conversation)
- **Generalizability:** broadly-applicable — any non-standard-shape campaign (audit, multi-sprint refactor, migration) should produce a hybrid handoff rather than forcing the standard template or writing ad-hoc instructions.

### Pattern 7: Stripped automation with git-commit-body as source of truth

- **Name:** git-commit-body-as-test-state-oracle
- **Problem it solves:** A campaign running 22 sessions across weeks needs CLAUDE.md's "Current State" test-count line kept current so downstream Claude sessions see the right baseline. Manual updates are error-prone. Full JSON appendix files are redundant with what the Work Journal already tracks.
- **Mechanism:** Enforce a canonical commit-message footer in every audit session: `Test delta: <baseline> -> <new> (net +N / 0)`. A small script greps `git log --grep='audit(FIX-'`, parses the test-delta footer from each body, identifies the chronologically-latest post count, and rewrites CLAUDE.md's Tests line in place. No separate state file; git log IS the state. Also provides a `--status` flag printing stage-by-stage progress from the same source. Completely idempotent — safe to run after every commit or once at campaign end.
- **Confidence:** proven (smoke-tested with fake audit commits; correctly reconstructed status and updated CLAUDE.md)
- **Generalizability:** broadly-applicable — the "commit-message-body as structured source of truth for automation" pattern is underused. Requires discipline on the commit format, but removes a whole class of "where is the state stored?" questions.

### Pattern 8: Section-ordering preserves execution order (close-out gates commit)

- **Name:** commit-gated-by-close-out-self-assessment
- **Problem it solves:** The canonical close-out.md skill says the session commits AFTER producing the close-out report, but only IF the self-assessment is not FLAGGED. Putting the Commit section of a prompt AFTER the Tier 2 Review section creates confusing visual ordering even though prose can describe correct execution order. Claude Code implementations will sometimes follow the visual order.
- **Mechanism:** Structure the generated prompt's section order to match execution order: Findings to Fix → Post-Session Verification (tests + back-annotation) → Close-Out Report (self-assessment gate) → Commit (if not FLAGGED) → Tier 2 Review (after commit, matches review.md's "fresh session or subagent after implementation") → Operator Handoff → Definition of Done. Visual order and execution order become identical.
- **Confidence:** proven (noticed mid-conversation that the prompts had Commit after Review; fixed by splitting the post-session section into pre-commit and post-commit halves)
- **Generalizability:** broadly-applicable — any template that invokes close-out and review skills should enforce this ordering. Belongs in the implementation-prompt template itself.

---

## Patterns that already existed and got applied (not novel)

- `templates/implementation-prompt.md` — baseline template shape for Phase 3 prompts
- `workflow/claude/skills/close-out.md` — Tier 1 self-review with `---BEGIN-CLOSE-OUT---` markers and `json:structured-closeout` appendix
- `workflow/claude/skills/review.md` — Tier 2 diff-based review with `---BEGIN-REVIEW---` markers and `json:structured-verdict` appendix
- `templates/work-journal-closeout.md` — Work Journal close-out structure (sprint summary, DEF numbers, DEC entries, resolved items, outstanding items)
- `protocols/codebase-health-audit.md` — Phase 1/2/3 structure the audit campaign follows
- Phase 3 rules from the uploaded `phase-3-fix-generation-rules.md`: Rule 1 (no shared files for parallel), Rule 2 (uniform safety tags for parallel), Rule 3 (one baseline per parallel batch), Rule 4 (sensitive-file serialization)
- DEC-275 compaction risk scoring (referenced but not redone)
- DEC-328 test suite tiering (standard pytest command inherited)
- DEC-330 close-out reports to file pattern
- DEC-383 `config_fingerprint` column on trades table (the prior-art that Pattern 4 mirrors)
- The `compute_parameter_fingerprint()` pattern in `argus/strategies/patterns/factory.py` (also mirrored by Pattern 4)

---

## Decisions that were made implicitly but should be explicit in the metarepo

### D1: Prompts are standalone; no cross-referencing allowed

Every FIX prompt must be pasteable into a fresh Claude Code session with zero knowledge of other FIX prompts. We followed this rigidly — even sessions with clear coupling (FIX-01 and FIX-02 on the Option A/B decision) handle the coupling via prose instructions referencing the state of `main`, not via cross-prompt references. Should be explicit in the phase-3 template: "no `see FIX-XX.md`" rule.

### D2: Findings within a prompt are pre-ordered to minimize file churn

We implemented this as the `sort_findings_by_file()` helper that groups findings by file, sorted by file with the most findings first. The rule is implicit: "group by file, heaviest-file first, within-group stable order." Should be explicit in the phase-3 template.

### D3: Safety-tag session resolution rule

Any weekend-only finding in a group promotes the whole session to weekend-only. We applied this silently. The rule is conservative and correct but should be explicit in the phase-3-fix-generation-rules.md document (it's there implicitly in the "if any finding is weekend-only, the whole session is weekend-only" line, but the generator implementation should reference this rule by name).

### D4: Close-out self-assessment gates commit, not push

The canonical close-out.md says "Do NOT push if self-assessment is FLAGGED." We implemented this as "pause before Commit section if FLAGGED." The distinction matters: some shops commit locally and push later. In our case we conflated them because the prompt template pushes immediately. Should be explicit: "FLAGGED blocks BOTH commit and push; do not stage, do not commit, wait for operator."

### D5: The "smallest-blast-radius operator default" rule

When presenting operator-choice options (Option A vs B), we defaulted to Option A (smaller-blast-radius) if left unchecked. This is sensible but implicit. The rule should be explicit: "if the prompt presents multiple options and the operator fails to check one, Claude Code takes the option explicitly labeled as default or the smallest-blast-radius option, and surfaces this choice in the close-out's judgment-calls section."

### D6: Cognitive limit on parallel sessions was rejected

When asked about parallelism, I initially suggested a 2-concurrent-session practical ceiling. The operator explicitly rejected this constraint and asked for pure DAG-based parallelism. Result: Stage 1 runs 6 sessions concurrently. The metarepo should NOT encode a cognitive-limit ceiling — operator preference on concurrent session count is project-specific, not workflow-canonical.

---

## What surprised us during the conversation

### S1: The claude-workflow skill files already encoded what we needed

We considered inventing a "structured session appendix JSON schema" mid-conversation before the operator pointed at `workflow/claude/skills/close-out.md` and `review.md`. The skills already had `json:structured-closeout` and `json:structured-verdict` appendix schemas, complete with markered blocks, verdict enums, and file-change tracking. The lesson: when extending an audit workflow, check the skills directory before designing new artifacts. The metarepo should make this discoverability easier — perhaps a "skills-to-templates cross-reference index" file.

### S2: Phase 2 CSV column drift was a real structural issue, not an edge case

9 rows of 379 had safety-column drift from embedded newlines in suggested_fix. That's 2.4% — high enough that any audit workflow with >100 findings should expect it. Current phase-2 protocol treats the CSV as operator-finalized-and-immutable, but doesn't specify what happens when the CSV itself has structural issues. Needs a "CSV integrity validation" step in phase-2 close-out or a "per-row override table" mechanism in phase-3.

### S3: Read-only findings with "Open a new DEF entry" suggested_fix

The phase-3 rules say `read-only-no-fix-needed` routes findings OUT of Phase 3. But several rows had suggested_fix text like "Open a new DEF entry for X." These need DEF creation, not pure verification. We invented the "5-step routing" (verify → if suggested_fix is observational, back-annotate only; if it asks for a DEF or a small fix, promote to deferred-to-defs handling). This wasn't in the rules. It should be.

### S4: The safety-column taxonomy isn't quite 4 values — it's 4 canonical values + stylistic variants

Markdown wrappers (`**weekend-only**`), code wrappers (`` `safe-during-trading` ``), parentheticals (`safe-during-trading (import-site change)`), etc., all appeared in the CSV from 20+ different rows. We built a normalizer. The lesson: phase-2 review tools should enforce canonical form at CSV-write time, either via a dropdown constraint or a validator. The metarepo could provide a tiny validation script to run on a phase-2 CSV before it's handed to phase-3.

### S5: The operator's standard workflow mattered more than the phase-3 rules

Midway through, the operator clarified that close-out reports and review reports get pasted into a Work Journal conversation, with running register tracking even cosmetic items. This shifted the whole shape of the Phase 3 deliverable — the JSON appendix became secondary, the paste-able markered blocks became primary, the automation script got stripped. The phase-3 rules didn't anticipate this integration. It should be a first-class concern: "Phase 3 output format depends on whether the operator has a Work Journal chat workflow."

### S6: Fingerprint infrastructure as audit scope expansion

The operator explicitly requested that FIX-01 include scoring-fingerprint infrastructure as a scope extension beyond the CSV findings, because landing the quality-pipeline fix without it would contaminate 22 in-flight shadow variants. This is a fantastic move, but the phase-3 rules have no provision for "scope additions that are not in the CSV but are architecturally required by a CSV finding." Should be a formal mechanism: "Phase 3 prompts may include architectural prerequisites flagged during phase-3 generation, but must be clearly labeled as 'not from CSV' so the audit trail remains clean."

---

## Open questions for synthesis

### Q1: How do evolution notes from multiple parallel conversations synthesize?

The operator asked me to NOT synthesize with other conversations' outputs. But the metarepo update mechanism presumably needs to merge these. What's the synthesis protocol? Who writes it?

### Q2: Should the phase-2 review tool itself be standardized beyond CSV?

CSV worked for 379 rows but barely. 800+ row audits would likely break. Alternatives: SQLite (queryable, validatable), JSON Lines (streamable, preserves structure), or a hosted tool with schema enforcement. The phase-2 review step needs a protocol-level decision about what's the canonical format at scale.

### Q3: Is the 4-safety-tag taxonomy the final answer?

We observed `safe-during-trading`, `weekend-only`, `read-only-no-fix-needed`, `deferred-to-defs`. For ARGUS this was sufficient. For other projects, other axes might matter: `requires-DB-migration`, `requires-deployment-coordination`, `breaks-API-contract`. Is the taxonomy a fixed 4-value enum or an extensible tag system? Current phase-3 rules treat it as fixed but don't say so explicitly.

### Q4: What's the right cardinality for fix-session groups?

CSV grouping yielded 1-finding sessions (FIX-00, 20, 21) and 37-finding sessions (FIX-05). Phase-3 rules say "5-12 findings, never more than ~8 files." Both bounds were violated. Should the rule be tightened, or are the bounds advisory? If advisory, what's the actual driving constraint? (We ended up using "single logical theme + file-overlap matrix" which is less crisp than a numeric rule.)

### Q5: Should FIX-session prompts include close-out and review in all cases, or only when a Work Journal workflow is in use?

We baked close-out + review into all 22. For operators without a Work Journal, these blocks still have value (paste into a text file, review manually) but are heavier than necessary. Should the phase-3 generator branch on "Work Journal present Y/N"? Or is close-out + review canonical regardless?

---

## What should NOT be codified

### N1: ARGUS's specific Rule-4 sensitive file list

The 5 files (main.py, order_manager.py, risk_manager.py, orchestrator.py, universe_manager.py) are ARGUS-specific. A web app would have a different list; a Kubernetes operator would have a different list. The metarepo should codify the CONCEPT of a Rule-4 list (and the greedy-packing algorithm in Pattern 1), but the list itself is per-project and lives in project-specific rules (e.g., ARGUS's `.claude/rules/`).

### N2: The specific 8-stage pack for this audit

The stage assignment (Stage 1 has FIX-01+11+00+15+17+20, etc.) is derived from the CSV groupings + ARGUS's Rule-4 map + the pairwise file-overlap matrix. It's correct for this audit and would be wrong for any other. Codify the algorithm, not the output.

### N3: The specific DEC-384 allocation and Option A/B pair

DEC-384 for load_config() merge semantics and the overflow.broker_capacity divergence are ARGUS-specific. The operator-choice-checkbox mechanism (Pattern 5) is generalizable; this instance of it is not.

### N4: "Fingerprint infrastructure inside FIX-01" as a universal pattern

The scoring-fingerprint work is a specific application of Pattern 4 (fingerprint-before-behavior-change). The universal pattern is "if a fix shifts a data distribution, land fingerprint infra first in the same session." The specific quality-weights-and-thresholds implementation is ARGUS-specific.

### N5: The 4,933/1-flake baseline and DEF-150 time-of-day bug

These are ARGUS state at 2026-04-21. Do not codify. The audit workflow should speak about "baseline" abstractly, not about specific counts.

### N6: The operator's rejection of cognitive-limit parallelism

This was a project-specific preference. The metarepo should neither encode a cognitive-limit rule NOR reject one — it should be silent on the topic and let each project decide.

---

## Specifically-flagged items

### How did Phase 2 review handle the volume of findings? Was CSV the right tool or did something else emerge?

**CSV was adequate but barely.** Phase 2 produced 379 rows with 12 columns across 10 Phase 1 sessions. The CSV held the operator's triage decisions (`fix-now`), fix-session-group assignments (22 groups), safety tags, and notes. It worked well enough that the operator finalized it and we could ingest it mechanically.

**Structural issues that surfaced:**

- **Column drift from embedded newlines in `suggested_fix` and `finding` fields** — affected 9 rows (2.4%). Required inference-based workaround (Pattern 2). At higher scales this percentage could climb because longer findings have more chances to include newlines.
- **Stylistic inconsistency in the safety column** — 20+ rows used markdown-formatted variants, parentheticals, code-wrapped values, etc. Required a normalizer.
- **Semantic inconsistency** — 15 rows had tags (`read-only-no-fix-needed`, `deferred-to-defs`) that per the phase-3 rules should have excluded them from Phase 3, but they had `decision=fix-now` anyway. Required Pattern 3 (non-standard-safety-routing).

**What should replace CSV for larger audits:**

- Under 100 findings: CSV is fine. Spreadsheet tools let operators triage quickly.
- 100–500 findings: CSV with a validator script that flags drift, enforces canonical safety-tag form, and rejects the file until clean. The validator could live in the metarepo.
- 500+ findings: JSON Lines or SQLite with schema enforcement. Spreadsheet triage becomes cognitively expensive; a lightweight web UI over SQLite would scale better.

**My recommendation:** add a `phase-2-validate.py` script to the metarepo that runs against the CSV before it's handed to phase-3. Validates: (1) column-count integrity per row, (2) safety column in the canonical 4-value set, (3) decision column in the canonical {fix-now, fix-later, ignore} set, (4) every `fix-now` has a non-empty `fix_session_id`, (5) fix_session_ids look like `FIX-NN-kebab-name`.

### What decision-classification axes beyond `fix-now / defer / ignore` emerged? Is the four-safety-tag taxonomy the final answer?

**The decision axis (`fix-now`/`fix-later`/`ignore`) worked cleanly at the triage level.** All 379 rows were `fix-now`. Whether that's because of pure fix-now bias or a genuine reflection that this audit's scope is 100% actionable, I can't tell — but the axis itself is sound.

**The safety-tag axis is more complex.** The 4 canonical values (`safe-during-trading`, `weekend-only`, `read-only-no-fix-needed`, `deferred-to-defs`) did NOT fully cover what we saw:

- **Missing axis: "can be applied atomically vs. requires a code+test+doc trio"** — some findings are single-line changes, others cascade across 3 files. This affects session grouping more than safety, but it's a real axis we were implicitly navigating.
- **Missing axis: "reversibility"** — some fixes are trivially revertible (config flip), others change on-disk schemas (counterfactual_positions table migration). For weekend-only sessions this matters: schema migrations need extra care.
- **Missing axis: "stakeholder dependency"** — CPA consultation, exchange agreement, legal review. None applied to this audit but would in others.

**The 4-tag taxonomy is sufficient-but-not-final for this audit.** For a metarepo-canonical answer, I'd propose:

- Core axis (required): `safe-during-trading` | `weekend-only` | `maintenance-window`
- Modifier tags (zero-or-more): `reversible` | `requires-migration` | `requires-coordination` | `read-only-verify` | `promote-to-def`

The `read-only-no-fix-needed` and `deferred-to-defs` values in our CSV were really modifier tags masquerading as core tags. Separating them lets a finding be "weekend-only + requires-migration + promote-to-def" without force-fitting into one of four boxes.

### What findings got re-classified during Phase 2 and why?

I did not have direct visibility into Phase 2 triage deliberations (I received the finalized CSV). But based on notes columns, cross-references between findings, and the Sprint 31.85 history in CLAUDE.md, I can identify these reclassifications:

**DEF-150 reclassified from "xdist race condition" to "time-of-day arithmetic bug"** — Original CLAUDE.md description was "race condition under -n auto, passes in isolation." Phase 1 finding `P1-G1-M07` re-analyzed and identified the actual root cause: `(datetime.now(UTC).minute - 2) % 60` produces timestamps in the future when `minute ∈ {0,1}`. The reclassification was kept inside Phase 2 via the finding's description; the CSV notes column preserved this as context for phase-3. Why: the old classification would have misdirected future fixers toward xdist parallelism issues instead of the actual 1-line arithmetic fix.

**DEF-089 promoted from DEF to OBSOLETE** — `P1-H4` (which became FIX-00) re-evaluated DEF-089 (In-memory ResultsCollector for parallel sweeps) and concluded it had been superseded by Sprint 31.5's ProcessPoolExecutor approach. Reclassified as obsolete CLAUDE.md annotation rather than active work. Why: preserve audit trail without pretending it's still open.

**DEF-082 and DEF-142 re-categorized from "quality-pipeline issues" to "confirmed CRITICAL"** — Both entered Phase 2 as known DEFs; Phase 1 provided empirical confirmation (e.g., "catalyst_quality always 50.0 — actually reading wrong DB"). Phase 2 promoted them to CRITICAL and assigned to FIX-01. Why: Phase 1 provided the root-cause evidence Phase 2 needed to escalate.

**Some `read-only-no-fix-needed` findings ended up with suggested fixes that did ask for changes** — 6 rows across FIX-05, FIX-06, FIX-08, FIX-09, FIX-11. Phase 2 marked them `fix-now` anyway because the "fix" was small (a comment, a DEF entry, a grep verification). This wasn't a reclassification so much as a nuance that the phase-3 rules hadn't anticipated — it forced Pattern 3's step-4 routing.

**`max_concurrent_positions: 50` + `overflow.broker_capacity: 30` → 20-position silent loss window** — H2-D05 reframed what looked like two separate config divergences (FIX-16 config-consistency territory) as one mechanism with a measurable impact (20 positions silently routed to counterfactual tracking per session). Moved to FIX-02 priority tier. Why: empirical impact justified the priority lift.

**One meta-observation:** reclassifications happened when Phase 1's root-cause analysis contradicted CLAUDE.md's existing description, and when Phase 2's empirical evidence re-scored severity. The phase-2 step was doing real work, not just applying a decision filter. The metarepo should say: "Phase 2 is triage AND reclassification. Preserve both in the CSV — reclassifications belong in the `notes` column with a `RECLASSIFIED` marker so phase-3 generators can surface them."

---

**End of evolution notes.**
