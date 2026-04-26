# Evolution Notes — Market Session Debrief + Campaign Absorption

**Date:** 2026-04-21
**Conversation title:** *<set by operator — suggested: "Market Session Debrief — 2026-04-21 + Campaign Absorption">*
**Contributes to:** `workflow/protocols/codebase-health-audit.md` (new patterns for post-audit-planning absorption), `workflow/protocols/market-session-debrief.md` (downstream coupling signals), `workflow/protocols/impromptu-triage.md` (scoping-before-fix variant), possibly new `workflow/templates/stage-flow.md` and `workflow/templates/scoping-session-prompt.md`.
**Synthesis status:** SYNTHESIZED in synthesis-2026-04-26 (commit <pending-final-synthesis-sprint-commit>). See `protocols/campaign-orchestration.md`, `protocols/operational-debrief.md`, `protocols/codebase-health-audit.md` for the resulting metarepo additions.

## What this conversation produced

A market session debrief report for ARGUS's 2026-04-21 paper trading session (10 findings, F-01 through F-10). Cross-referencing those findings against the already-drafted audit Phase 3 fix prompts revealed substantial overlap — the biggest bug (entry_price=0 from a getattr typo) had already been independently diagnosed in FIX-04 — plus genuine gaps (bracket amendment leak, log-volume regression, UI unit mismatch). The conversation then invented and documented a "campaign absorption" pattern: treating audit Phase 3 + debrief impromptu as one coordinated campaign with two tracks, one Work Journal conversation, one running register, one close-out. Six planning files were drafted for `docs/sprints/sprint-31.9/` (README, STAGE-FLOW DAG, combined work-journal handoff, IMPROMPTU-01 fix prompt, IMPROMPTU-02 scoping-prompt-that-generates-a-fix-prompt, placeholder for the fix prompt itself). A debrief report was saved to `docs/debriefs/2026-04-21.md`. A SUPERSEDED notice was added to the audit-local handoff pointing at the new campaign handoff. The audit folder was deliberately NOT moved or restructured.

## Novel patterns introduced (that should become metarepo-canonical)

### Campaign absorption
- **Problem it solves:** When a pre-planned audit is about to execute, and a separate event (market session debrief, incident post-mortem) surfaces bugs that partially overlap with audit findings, running them as one coordinated campaign keeps the running register coherent (DEFs, DECs, test baselines) without losing the audit's per-session discipline.
- **Mechanism:** Preserve the audit's existing folder and session prompts untouched. Create a new campaign-level folder (e.g. `docs/sprints/sprint-<N>/`) with a README, a dependency DAG, a combined work-journal handoff, and any new session prompts. The campaign handoff supersedes the audit-local one (which gets a SUPERSEDED notice pointing at the new one). A single Work Journal conversation drives the whole thing.
- **Confidence:** hypothesized. The pattern feels right but Sprint 31.9 hasn't executed yet. The specific failure mode to watch is whether running 24 sessions through a single Work Journal conversation exceeds practical context capacity.
- **Generalizability:** needs-adaptation. Probably works for audit + impromptu combos where the impromptu is ≤2-3 sessions and the audit hasn't started executing. Past that threshold, separate sprints likely dominate.

### Read-only scoping-before-fix session pattern
- **Problem it solves:** Some impromptus diagnose a bug where the root cause isn't yet pinned to a specific code path, and attempting to scope a fix prompt without that diagnosis produces either a bloated session (compaction risk ≥14) or a prompt that hand-waves the fix. A dedicated read-only investigation session de-risks this.
- **Mechanism:** Split the impromptu into two sessions. The first (scoping) reads source, runs no code, produces two output artifacts: a structured findings report AND the generated fix prompt for the second session. The scoping prompt specifies a required findings template (code-path map, hypothesis verification, race conditions identified, root-cause statement, fix proposal, test strategy, risk assessment). The scoping session also has explicit "must NOT do" constraints (no source/test/config writes, no running tests, no attempting the fix even if it looks 1-line).
- **Confidence:** hypothesized. Structurally sound but unproven until IMPROMPTU-02 actually executes. The practical risk is that some bugs can't be diagnosed without running code, in which case the read-only discipline blocks necessary investigation.
- **Generalizability:** broadly-applicable for any fix where the root cause is under ~50% confidence at planning time. Not worthwhile for well-understood fixes — the overhead of a second session isn't justified.

### STAGE-FLOW artifact for multi-track campaigns
- **Problem it solves:** When a sprint has more than one mandatory-ordering chain (e.g., main audit trunk + scoping branch + fix that joins both), a text table is insufficient. Operators need a visual DAG to reason about parallelization opportunities and hard dependencies at a glance.
- **Mechanism:** Box-and-arrow ASCII DAG committed as a standalone doc next to the README. Each stage box lists its sessions, the ARGUS state constraint (DOWN / LIVE OK / READ-ONLY), and any eligibility notes. A "Hard mandatory edges" table below the DAG enumerates every dependency with a reason. The DAG is explicitly declared authoritative over any condensed stage tables elsewhere in the planning package.
- **Confidence:** hypothesized for the multi-track fork-join case specifically. The base DAG visual format came from an earlier audit-planning conversation (linear-only) and proved useful there — this conversation extended it to handle forks and joins.
- **Generalizability:** needs-adaptation. Linear sprints don't need a DAG — a table suffices. Campaign-level sprints with fork-join, cross-track dependencies, or conditional eligibility benefit.

### Handoff supersession with explicit pointer
- **Problem it solves:** When a planning document is committed and then scope grows, editing in place loses the original context (which may still matter for understanding decisions). Abandoning the old doc entirely leaves dangling references from other artifacts that point at it.
- **Mechanism:** Add a SUPERSEDED banner at the top of the old doc pointing at the new doc. The old doc's body is left unchanged below the banner. The new doc is the canonical entry point.
- **Confidence:** proven as a general pattern (standard in ADRs and RFCs), novel in this metarepo's current vocabulary.
- **Generalizability:** broadly-applicable wherever planning artifacts evolve under version control.

### Fork-join staging (Stage 9A side-branch, 9B join)
- **Problem it solves:** Linear stage-barrier staging forces unnecessarily sequential execution when a read-only or otherwise non-conflicting session could run in parallel with barred-DOWN stages.
- **Mechanism:** Number a side-branch session explicitly (e.g. "Stage 9A" alongside linear 1–8, with 9B as the join). The DAG visualizes the branch; the dependency table enumerates which predecessors gate each successor. Importantly, the side-branch is marked on the DAG with its *mandatory* predecessors, not merely its *earliest eligibility*, so the ordering is unambiguous.
- **Confidence:** hypothesized. It's a natural extension of linear staging, but may be unnecessary ceremony if only one session benefits.
- **Generalizability:** needs-adaptation. Overhead is only justified if the parallelization actually shaves execution time (e.g., saves a weekend window).

## Patterns that already existed and got applied (not novel)

- `workflow/protocols/market-session-debrief.md` — 7-phase debrief protocol was followed verbatim to produce the debrief report
- `workflow/protocols/impromptu-triage.md` — the baseline single-session impromptu pattern was the starting point; IMPROMPTU-01 follows it directly, IMPROMPTU-02 extends it via the scoping-before-fix variant above
- `workflow/protocols/codebase-health-audit.md` v1.0.0 — the audit's 3-phase structure (Phase 1 read-only, Phase 2 operator triage, Phase 3 fixes) was the existing canvas the campaign painted on
- `workflow/templates/work-journal-closeout.md` — the running-register pattern (DEFs, DECs, outstanding items, review flags) was copied wholesale into the combined campaign handoff
- The 4-tag safety taxonomy (`safe-during-trading` / `weekend-only` / `read-only-no-fix-needed` / `deferred-to-defs`) from the audit plan — applied to impromptu sessions identically
- `workflow/claude/skills/close-out.md` and `workflow/claude/skills/review.md` — standard per-session reporting; applied to IMPROMPTU-01 and IMPROMPTU-02-fix. IMPROMPTU-02-scoping received a *carved-out* close-out (no Tier 2 review, scope-verification note replaces test delta) — this carve-out is the only novelty on this axis.
- Standalone session prompt convention ("do not read other FIX-NN prompts") from the audit — applied identically to IMPROMPTU-NN prompts
- Sprint folder convention `docs/sprints/sprint-<N.M>/` — followed from ARGUS's historical pattern
- Compaction risk scoring (ARGUS DEC-275) — used as justification for splitting IMPROMPTU-02 into scoping + fix

## Decisions that were made implicitly but should be explicit in the metarepo

- **"Preserve authoritative-record folders when work graduates to a larger campaign" rule.** The audit folder stayed at `docs/audits/audit-2026-04-21/` rather than moving into `docs/sprints/sprint-31.9/audit-phase-3/`. Rationale: the Phase 1 findings reports are the audit's authoritative record and moving them would break historical traceability across ARGUS's sprint history. Probably a general rule for any work with canonical-output artifacts the operator may reference later.

- **"One Work Journal conversation per campaign" heuristic.** Used without a justified upper bound. Is it 24 sessions? 30? 50? At what point does a single Work Journal become too context-loaded to function? The metarepo currently doesn't say.

- **"SUPERSEDED notice rather than delete" convention for planning-artifact evolution.** Used here without being documented as a pattern. Should be codified somewhere light-touch (probably in the campaign absorption protocol, not a standalone convention doc).

- **"Scoping session produces findings + generated fix prompt as two distinct artifacts"** — not one combined document. The artifacts serve different downstream consumers (human operator reviewing findings; Claude Code session executing the fix prompt). Worth making explicit.

- **"Campaign close-out covers both tracks with cross-track synthesis"** — the handoff's Stage 9B close section explicitly asks for a narrative covering both audit and impromptu outcomes, plus a paper-trading-data-quality recommendation. Current audit protocol doesn't anticipate cross-track synthesis like this.

- **"Pre-flight check before kickoff"** — I produced one informally in the last operator exchange (commit planning package, verify paper-trading state, confirm baseline). Not codified anywhere. Either belongs in the campaign protocol as a required step or as a standalone template.

- **"Track B impromptu naming (IMPROMPTU-NN)"** — I invented this ad-hoc to distinguish from audit's FIX-NN. Whether that's the right campaign-wide convention is unstated in the metarepo.

- **"Find-is-debunked" result path.** F-05 (duplicate trade_ids) was downgraded from CRITICAL to COSMETIC mid-analysis when the ULID truncation explanation surfaced. The debrief protocol doesn't have an explicit "debunked" status; findings silently got downgraded. A status would help the synthesis phase of future debriefs.

## What surprised us

- **How much audit Phase 3 and the debrief findings already overlapped.** F-02 (`entry_price=0` from getattr typo) was the largest-impact bug in the debrief AND already CRITICAL P1-C1-C01 in FIX-04. This overlap was the strongest argument FOR absorption — if the audit had already caught the biggest problem, you don't need a separate fix sprint for it. The audit protocol doesn't anticipate that debrief findings might corroborate or duplicate audit findings; it treats the two as independent diagnostic streams.

- **The 45/46 correlation between a single log-line pattern ("Bracket amended") and untracked broker positions.** This smoking-gun-from-log-analysis finding wasn't something the debrief protocol's Phase 6 (error catalog) explicitly suggests producing. The protocol's guidance is general; it doesn't suggest "correlate error categories against specific problem outcomes" as a diagnostic technique. Should.

- **ULID truncation false positive.** F-05 initially looked like a CRITICAL data-integrity bug ("79 trade IDs appear 2+ times") and was downgraded to cosmetic only after decoding ULID timestamp semantics. Worth a line in the debrief protocol: "apparent trade_id duplicates in logs are almost always truncation artifacts; verify the DB has unique IDs before treating as data corruption."

- **Log volume dominated by a single INFO line.** 84% of a 182MB session log came from `pattern_strategy.py:298` emitting a redundant progress message once per symbol × strategy × candle during warm-up. The debrief protocol's Phase 1 doesn't explicitly check for log-size regressions or cardinality-explosion patterns. Probably should — it's the kind of thing that compounds quietly.

- **The operator's "one sprint" question shifted the plan mid-conversation.** My initial recommendation was two sequential sprints (audit, then impromptu). The operator's counter — "can we make it one?" — produced the campaign absorption pattern. Worth codifying: an explicit branching decision at planning time between "run sequentially" and "absorb into campaign," rather than defaulting silently to one or the other.

- **Session count grows during planning.** The audit protocol's "18 sessions" from Phase 1 became 22 in Phase 2 (some split), then 24 in this campaign (+ 2 impromptus, + scoping). The metarepo should expect session count to grow through each planning phase rather than assume it's fixed.

- **STAGE-FLOW.md's usefulness snuck up on me.** I produced it only after the operator explicitly asked "give me a DAG like the audit one." Before that, I had a textual stage table in the README and thought it was enough. Having the DAG available makes dependency reasoning substantially faster for the operator. Likely true for any multi-track sprint.

## Open questions for synthesis

### Explicit asks from the operator

1. **When is absorption right vs. running sequentially?** The threshold is unclear. Here it worked because (a) the audit hadn't started executing, (b) the debrief impromptu was 2 sessions not 10, (c) the overlap with audit findings was meaningful (F-02 double-coverage). If the audit had been mid-flight, or the impromptu had been 10 sessions, or the overlap had been zero, the right answer might be different. Synthesis should propose a decision tree with at least those three axes (plus ideally a "cost of delay on either side" axis).

2. **Is STAGE-FLOW.md audit-specific or universal?** My current belief: every multi-session sprint with non-linear dependencies (fork-join, cross-track, conditional eligibility) should produce one; pure linear sprints don't need it and a table suffices. Synthesis should either codify this or explicitly reject it.

3. **Does the read-only scoping session pattern warrant a new template in `workflow/templates/`?** My current belief: yes. The structured findings template it produces is non-trivial (code-path map, hypothesis verification, race conditions, root-cause statement, fix proposal, test strategy, risk assessment) and reusable for any impromptu where root cause is under ~50% confidence at planning time. The template would be reusable in non-audit contexts too (routine incident investigations).

### Additional open questions surfaced during drafting

4. **Campaign identifier naming convention.** This campaign uses `sprint-31.9-health-and-hardening`. Should the metarepo enforce a format (e.g. sprint-number + theme)? The current protocols don't say.

5. **Cross-track session-numbering.** I used `IMPROMPTU-NN` to distinguish from audit's `FIX-NN`. Is that standard for non-audit sessions inside a campaign, or ad-hoc? Neither currently documented.

6. **Stage sub-numbering (9A/9B).** When is it justified vs. just adding another stage (9, 10)? I used 9A/9B because they're the same logical phase (final impromptu) but have different execution constraints. Synthesis should either bless or reject the convention.

7. **Planning-conversation file-count limit.** This conversation produced 6 files plus a debrief plus an edit to an existing file. Is there a practical max-files-per-planning-conversation threshold? If this had been 15 files, the operator would likely have had trouble keeping track mid-draft. Not a hard constraint, but a signal for when to break planning into multiple conversations.

8. **"Debunked" finding status.** F-05 was initially CRITICAL, then cosmetic. Should debrief findings have an explicit DOWNGRADED / DEBUNKED status in reports, so the reader can trace the diagnostic path?

## What should NOT be codified

- **F-numbering (F-01 through F-10) for debrief findings.** That was ad-hoc to this debrief. Cross-debrief, naming findings by letter+number could collide. The debrief protocol should just say "give each finding a stable local identifier" and leave the form to the operator.

- **The specific IMPROMPTU-01 bundling** (log hygiene + UI unit fix + cosmetic cleanup in one session). That was a function of file-overlap minimization for this codebase. Don't turn it into a "bundle safe-during-trading cosmetic fixes" rule.

- **The 9-stage count, or the specific stage-to-session assignments.** Functions of the audit's specific file-overlap constraints and the 22-session size. A different-sized campaign will have different staging.

- **The specific sprint number 31.9.** Just an available slot in ARGUS's history. Not a pattern.

- **Specific DEF ranges (DEF-082, DEF-142, DEF-150, DEF-161).** ARGUS-specific.

- **The "debrief → check for audit pending → consider absorption" flow as an automatic step in every debrief.** Most debriefs won't have an audit pending. Absorption should be conditional on "audit planned within N days AND hasn't started Phase 3 yet" or similar gating, not a default consideration.

- **"STAGE-FLOW is authoritative over the condensed table" as a universal rule.** It was the right call here because the DAG is more expressive than the table. In another context the table might be authoritative. The metarepo should say "don't duplicate, or if you must, declare authoritative" — not mandate one over the other.

- **The exact pre-flight check list I gave verbally.** If synthesis likes the idea of a pre-flight checklist, design one properly — don't copy mine.

- **The specific ⚠ SUPERSEDED banner glyphs and wording.** Codify the pattern (point at replacement doc, preserve body below) without the stylistic specifics.

- **"One Work Journal conversation for all 24 sessions" as a rule.** It's an open question whether this scales. Framed as a rule, it might push future campaigns to overload a single conversation.

- **"Paper-trading data quality flag" as a close-out deliverable.** That's specific to ARGUS's CounterfactualTracker promotion model. Other projects won't have an analogous concern.
