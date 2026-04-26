# Evolution Notes — ARGUS codebase audit (first-ever) planning & execution

**Date:** 2026-04-21
**Conversation title:** ARGUS audit Phase 1 + Phase 2 planning and execution
**Contributes to:** `workflow/protocols/codebase-health-audit.md`
**Synthesis status:** SYNTHESIZED in synthesis-2026-04-26 (commit <pending-final-synthesis-sprint-commit>). See `protocols/campaign-orchestration.md`, `protocols/operational-debrief.md`, `protocols/codebase-health-audit.md` for the resulting metarepo additions.

---

## What this conversation produced

A full end-to-end execution of the first codebase audit in ARGUS's project history (89 sprints of accumulated debt). The conversation produced: an 18-session Phase 1 audit plan, the 18 session prompts themselves, a P1-H4 DEF triage report (amended in-flight with empirical DB verification), a 379-row Phase 2 review CSV with all fix-now decisions made, a combined Phase 1+2 doc-sync prompt for Claude Code, and a handoff prompt for a fresh Claude.ai conversation to generate Phase 3 fix-session prompts. One critical discovery mid-audit: DEF-142 (quality-engine grade compression) was marked "resolved" in Sprint 32.9 but never actually activated at runtime — empirically confirmed by a live-DB query showing 97% of 7-day signals graded B with zero A-grades, reopening a quality-pipeline bug that had been affecting the 22 shadow variants for weeks.

---

## Novel patterns introduced (that should become metarepo-canonical)

### Empirical verification as a triage verdict upgrader

- **Name** — Empirical verification upgrade
- **Problem it solves** — Triage reports often conclude "suspicious — verify before reopening" which leaves the reader doing unmotivated verification work. High-signal findings get lost in ambiguity.
- **Mechanism** — When a triage verdict is "high-confidence suspicious," the triage step produces a concrete verification command (SQL query, grep, test run) the operator can run in ≤2 minutes. If the command confirms the suspicion, the triage document gets amended with a new "Empirical Verification" subsection containing the query, the raw output table, and an interpretation paragraph. The DEF's status is upgraded from "suspicious" to "confirmed unresolved" and the Handoff section is rewritten to reflect that the fix now has concrete evidence behind it, not just a theoretical concern.
- **Confidence** — proven (this conversation upgraded DEF-142 from suspicious to confirmed in-flight, which then justified bundling two separately-tracked fixes into a single weekend session)
- **Generalizability** — broadly-applicable (any audit with live system access benefits from runnable verification commands instead of prose-only triage)

### Bundled fix with architectural scope extension

- **Name** — Architectural-consequence bundling
- **Problem it solves** — Audit findings are often symptoms of the same root cause, but the fix for the root cause frequently demands additional architectural work not captured as a finding (data migration, schema change, compatibility layer). Without a home, that work either gets dropped or gets tacked onto Phase 3 sessions that don't know why they're doing it.
- **Mechanism** — When multiple findings share a root cause, bundle them into one fix session. Then explicitly name any architectural work that's a *consequence* of the fix (not a finding itself) and include it as a distinct scope item in that session's prompt, with rationale for why bundling is strictly cleaner than landing it separately. The fix session's commit message then reflects both scopes. Example: FIX-01 bundled DEF-082 + DEF-142 + 4 H2 findings (all quality-pipeline root causes) and extended scope to include a `scoring_fingerprint` column + infrastructure, because that infrastructure needed to land *before* the scoring change so pre-fix and post-fix shadow data could be distinguished.
- **Confidence** — proven (produced a clean fix design where the alternative would have been "fix scoring, then rebuild promotion comparability afterward on compromised data")
- **Generalizability** — broadly-applicable to any fix that changes a scoring/pricing/valuation computation whose historical outputs are referenced downstream

### Audit-prompt pre-flight verification gate

- **Name** — Generation pre-flight gate
- **Problem it solves** — Large generation tasks (18 audit prompts, 22 Phase 3 prompts, etc.) can silently misread inputs and waste 30-60 minutes producing mis-formatted output. The operator discovers the error after extraction.
- **Mechanism** — Before committing to generation, the prompt requires Claude to confirm three things: can you parse input A (report row count and distribution), can you parse input B (template structure), and do you understand the scope extension. Report these three confirmations, then wait for operator "proceed" before generating. One extra conversational turn, catches all input-misreading errors.
- **Confidence** — hypothesized (was designed for Phase 3 handoff; not yet executed at time of this conversation)
- **Generalizability** — broadly-applicable to any multi-hour generation task

### Pre-commit CSV + doc-sync prompt split

- **Name** — Operator owns judgment commits, Claude owns mechanical commits
- **Problem it solves** — When a doc-sync prompt tells Claude Code to "create this 380-row CSV," Claude might reformat, paraphrase, or reconstruct rather than paste verbatim. The operator's judgment (decision column values, FIX group assignments) is too valuable to risk.
- **Mechanism** — Split the commit responsibility. Operator commits the CSV themselves directly from Claude.ai's download (preserving byte-exact content). The doc-sync prompt has a pre-flight that verifies the CSV is present at expected row count, then only handles the mechanical doc-edit commits. Each commit has a single responsible author; the operator-judgment artifact is protected from LLM reformatting.
- **Confidence** — proven (operator ran this sequence successfully with commit 4892035 landing after pre-committed CSV)
- **Generalizability** — broadly-applicable to any workflow where Claude Code is handling artifacts a human has made careful judgments on

### Comprehensive-fix approval heuristic with hot-file carve-out

- **Name** — Approval-heavy audit with regression-risk calibration
- **Problem it solves** — "Fix everything" sounds appealing but inflates Phase 3 session count and creates regression risk in files that are already fragile (recent race-condition fixes, high-churn code). Pure severity-based triage misses this.
- **Mechanism** — Default every finding to `fix-now`, then carve out only one exception: COSMETIC findings tagged `weekend-only` that touch "hot files" (files that recently fought stability issues) become `fix-later` DEFs. LOW+`weekend-only` in hot files are still `fix-now` but bundled with same-file higher-severity fixes to amortize regression surface. All other LOW/COSMETIC (in non-hot files, or `safe-during-trading`) are `fix-now`. This preserves comprehensiveness while respecting that not every legitimate finding is worth the surface-area cost.
- **Confidence** — proven (applied to 379 findings producing 100% fix-now rate with explicit carve-outs)
- **Generalizability** — broadly-applicable, but the "hot files" list is project-specific

---

## Patterns that already existed and got applied (not novel)

- `workflow/protocols/codebase-health-audit.md` — base protocol structure (session-based audit, finding severities, safety tags)
- `templates/implementation-prompt.md` — used as structural template for Phase 3 session prompts (not yet generated in this conversation, but referenced in the handoff)
- `protocols/in-flight-triage.md` — informed the DEF triage step (P1-H4)
- Compaction-risk scoring (DEC-275) — governed the 18-session decomposition
- DEC-345 separate-DB pattern — informed the scoring_fingerprint scope extension design
- Parameter fingerprint pattern (`compute_parameter_fingerprint()`) — directly reused as the model for scoring_fingerprint
- Commit-message format convention — reused verbatim from sprint close-out convention

---

## Decisions that were made implicitly but should be explicit in the metarepo

### Combined doc-sync for audit phases
The operator asked "should we combine Phase 1 + Phase 2 doc-syncs?" and I endorsed it with four reasons (atomicity of audit narrative, Phase 2 revising Phase 1 verdicts, fewer context switches, low downside). **This decision deserves explicit codification**: when an audit has multiple doc-sync-producing phases, default to combined doc-sync unless there's a specific reason to split. "Commit-per-phase" is not the right default for audits even though it is for sprints.

### Approval-heavy default for first audits
The operator framed "first audit in the whole project history, so might as well do it comprehensively, right?" as a rhetorical question. I endorsed with the hot-file carve-out calibration. **This deserves explicit codification**: first-ever audits should default to `fix-now` for 85%+ of findings, with explicit carve-outs for regression-risk-vs-value asymmetries, not the reverse ("defer LOW/COSMETIC by default"). This is opposite to the heuristic most fix-generation guidance assumes.

### In-flight triage amendment is a standard pattern, not an exception
When DEF-142 was empirically verified mid-audit, I amended the already-delivered triage document with new sections, new table headers, and a revised Handoff. **This deserves explicit codification**: audits should expect mid-flight empirical discoveries and the protocol should describe how to amend deliverables (header annotation, dedicated "Empirical Verification" section, updated Handoff with ordering implications). Currently the protocol is silent on this, so operators are left to invent the amendment structure.

### FIX group numbering carries priority tier semantics
The initial FIX-00/01/02 + FIX-10-through-28 gapped numbering encoded "these three first, everything else in parallel." The operator challenged this; we renumbered contiguously. **This deserves explicit codification**: priority should be carried by commit-message ordering statements and handoff-note language, NOT by numerical gaps. Contiguous numbering is the default; priority is surfaced in the prompt's ordering sections.

### "Hot files" as a concept
I invoked "files that recently fought stability issues" to justify carve-outs but never formalized what qualifies a file as hot. **This should become explicit**: define hot files by either recent DEF count (3+ DEFs resolved in last 5 sprints), recent commit churn in risk-manager/execution/data paths, or a specifically-maintained list per project. Leaving it implicit means the heuristic is un-auditable.

---

## What surprised us during the conversation

### The protocol didn't anticipate empirical disconfirmation of a claimed-resolved issue
DEF-142 was marked resolved in Sprint 32.9. The P1-D1 C2 finding said "the resolution edited the wrong file." The P1-H4 triage flagged this as "high-confidence suspicious." The operator ran a 2-minute SQL query and empirically confirmed the fix had never reached runtime. Three sprints of subsequent work, including the Sprint 31A/31.5/31.75 shadow variant deployment, operated against a broken scoring pipeline. **The existing audit protocol has no concept of "resolved DEFs are not trustworthy until spot-checked."** This feels like a blind spot worth filling.

### Automated CSV extraction hit a wall on non-standard report structures
14 of 18 audit sessions used CRITICAL/MEDIUM/LOW/COSMETIC severity tables and extracted cleanly (271 findings). The four docs-heavy sessions (H1A, H1B, H2, H3) used Q-numbered or Section-numbered custom structures and extracted to zero findings. I had to hand-curate 86 additional findings to itemize them. **The protocol should either standardize on severity-table structure for all reports, or provide an explicit "custom-structure session" pattern with its own itemization rule.** The current state (inconsistent structures across session types) produced hidden extraction debt.

### Session count was not predictable from file sizes
I originally scoped roughly 10-12 sessions; the final count was 18. The growth came from realizing that `order_manager.py` (3,036 lines) + `main.py` (2,400 lines) + `risk_manager.py` could not share a session; that backtest engine (current) and backtest legacy (VectorBT) had fundamentally different concerns; that catalyst/quality was coupled tightly enough to share one session but experiments/learning needed its own; that docs needed a primary-context vs supporting-docs split; and that the DEF triage (P1-H4) needed to live in Claude.ai, not Claude Code. **File sizes alone underestimated the actual decomposition.** The growth was driven by coupling-analysis and environment-constraints, neither of which shows up in file-size heuristics.

### Total findings count was a poor predictor of Phase 3 effort
379 findings across 22 FIX groups sounds daunting, but the distribution is heavily lopsided: FIX-05 (37), FIX-03 (31), FIX-15 (28), FIX-09 (27), FIX-06 (26), FIX-13 (25) account for 174 findings (46% of total). Meanwhile FIX-00 has 1, FIX-20 has 1, FIX-21 has 1. **Phase 3 session-count ≠ FIX-group-count.** The large groups will split further at execution time; the small groups will bundle with adjacent groups or run as 10-minute commits. Total effort is a function of per-session overhead × execution-time-per-session, and the CSV doesn't surface either. The audit protocol should add an "estimated Phase 3 session count" column that's separate from "findings count."

### Scope extensions arose naturally, but the protocol had no home for them
The scoring_fingerprint extension to FIX-01 emerged from the conversation, not from any audit finding. Phase 3 fix-generation rules (from the audit package) don't describe how to handle architectural scope that's a *consequence* of findings but not a finding itself. **Without explicit framing, future audits will either drop this scope or silently fold it into a fix session in a way downstream readers can't trace back to reasoning.** The protocol should name this case and describe how to capture it (separate scope doc? explicit section in the fix prompt? new DEC?).

---

## Open questions for synthesis

1. **Should the DEF-triage step become a mandatory pre-audit activity on every project?** ARGUS had never done DEF triage before P1-H4, and 1 of the 25 spot-checked strikethrough DEFs turned out to be incorrectly resolved. Extrapolating: 4% bad-strikethrough rate × 87 resolved DEFs ≈ 3-4 other suspicious strikethroughs this audit missed. Is it worth requiring DEF triage *before* the code audit begins so findings can reference re-verified DEF state?

2. **How should the protocol treat "hot files"?** Current invocation is heuristic ("files that recently fought stability issues"). Options: formal definition (N DEFs in last M sprints), maintained list per project, or continue leaving it to operator judgment. The trade-off is auditability of the decision vs maintenance burden of the list.

3. **What's the right granularity for Phase 3 fix groups?** 22 groups for 379 findings averaged 17 findings/group, but the actual distribution was 1-37. Should groups target a fixed size range (10-20 findings each), with over-large groups pre-split during Phase 2? This affects Phase 3 prompt generation downstream.

4. **Should audit packages ship with a test-count baseline snapshot?** Phase 3 enforces "net test-count delta ≥ 0" per session, but each session's baseline is computed at session start, not pre-audit. If tests drift negatively across 22 sessions by +1 each, the audit produces a 22-test regression with no single session responsible. Consider a pre-audit baseline snapshot that every session must net-meet against.

5. **What's the right approach when a discovery mid-audit changes the scope?** The DEF-142 discovery added scope (scoring_fingerprint work) that wasn't in the Phase 1 plan. I handled this by amending the triage and extending FIX-01 scope. Should the protocol describe this as a standard "discovery-driven scope change" pattern, or should it be rare enough to treat as operator-judgment-case-by-case?

---

## What should NOT be codified

### ARGUS-specific: the FIX-01 scoring_fingerprint design
The specific column schema (`scoring_fingerprint TEXT` on `counterfactual_positions`), the specific reuse of the parameter-fingerprint SHA-256 pattern, and the specific PromotionEvaluator filter parameter are all ARGUS-specific. The *generalizable* pattern is "scoring-change bundling with infrastructure for before/after data distinction" — codify that pattern, not the implementation.

### ARGUS-specific: the particular hot-file list
`order_manager.py`, `main.py`, `risk_manager.py`, etc. are hot for ARGUS because of its specific recent history. Other projects will have different hot files. Codify the *concept* of hot files, not this list.

### One-off: 22 FIX groups
The exact group count is a function of ARGUS's size and audit scope. Future audits will produce different counts. Don't codify "22" as any kind of target.

### One-off: severity distribution (21/170/150/38)
This shape is specific to this audit. Future audits with different histories will produce different shapes. Don't use these numbers as targets or expectations.

### Speculative: the generation pre-flight gate
I designed this for the Phase 3 handoff but it hasn't been executed yet. If it turns out to add friction without catching errors, it shouldn't be codified. Re-evaluate after Phase 3 prompt generation completes.

### ARGUS-specific: the 24-hour DEF-142 verification query SQL
The exact SQL query is specific to ARGUS's `quality_history` schema. The generalizable pattern is "triage recommendations include a ≤2-minute verification command" — codify the pattern, not the query.

---

## Specifically flagged items

### Alternatives considered for session-splitting

The P1 session list went through three drafts. Drafts considered:

**Draft 1 (rejected) — 10 sessions by top-level directory:**
`argus/core/`, `argus/strategies/`, `argus/execution/`, `argus/data/`, `argus/intelligence/`, `argus/backtest/`, `argus/api/`, `argus/ui/`, `tests/`, `docs/`. Rejected because core and intelligence were both too large (600+ lines of findings would exceed Claude Code's per-session comfort zone) and docs needed to split.

**Draft 2 (rejected) — 14 sessions with size-based splits:**
Split `argus/core/` into main.py + rest; split `argus/intelligence/` into catalyst/quality + experiments/learning; split backtest into engine + legacy. Still lumped all docs together. Rejected when the docs session scope became clear (3 primary-context docs alone at 3,702 combined lines demanded a dedicated session), and when P1-H4 DEF triage was identified as Claude.ai-only work.

**Draft 3 (final) — 18 sessions:**
Added the 4-session docs decomposition (H1A primary-context, H1B supporting, H2 config-consistency, H3 claude-rules) and moved H4 (DEF triage) to Claude.ai. Also added P1-I (dependencies) as its own session since it was cross-cutting and didn't belong with any single code domain.

**Why the chosen split won:** Three factors beyond pure size:
1. **Domain coupling**: catalyst/quality were tightly coupled (P1-D1 findings confirmed this), so they shared a session; experiments/learning were coupled to each other but decoupled from catalyst/quality, so they got their own session.
2. **Environment constraints**: P1-H4 required cross-session synthesis across all other sessions' outputs, which only works in Claude.ai, not Claude Code. This forced the splitting-by-environment dimension.
3. **Review-style heterogeneity**: docs reviews, code reviews, config-consistency reviews, and rules/skills reviews all use different reading strategies. Mixing them in one session produces worse findings. This pushed H1/H2/H3/H4 apart even where combined size would have fit.

### Was the 18-session expansion predictable from file sizes?

**No.** File sizes predicted approximately 10-12 sessions. The actual 18 emerged from:

- **Environment constraints**: +1 session (P1-H4 DEF triage required Claude.ai, not Claude Code — not a size issue)
- **Review-style heterogeneity**: +3 sessions (splitting docs into H1/H2/H3 wasn't about size, but about reading strategies)
- **Coupling analysis**: +2 sessions (intelligence split into catalyst/quality vs experiments/learning; backtest split into engine vs legacy — driven by coupling, not size)

So roughly 6 of the 18 sessions (33%) came from dimensions orthogonal to file size. **The lesson**: size is a floor on session count but not a ceiling. Budget for session-count to grow ≥30% beyond raw size-based estimates.

### Minimum viable audit scope

If a project has no paper-trading-active constraint, which sessions collapse?

Sessions that exist *because* ARGUS is paper-trading-live (and can collapse for a non-production project):

- **P1-H2 (config consistency)** — collapses partially. Without live-vs-paper config divergence to check, you still need YAML-to-Pydantic consistency checks, but the "paper-trading overrides" question disappears. Estimate: ~40% size reduction, still its own session.
- **P1-A2 (core rest — orchestrator, risk manager)** — collapses into P1-A1. Risk manager's paper-trading-override surface is a big driver of the split; remove that and the full core fits in one session.
- **P1-C1 (execution)** — remains as standalone session. Order Manager complexity is independent of live status.
- **P1-D1 (catalyst/quality)** — remains. Quality pipeline audit is architectural, not production-specific.

Sessions that exist for any project regardless of production status:

- All of P1-B (strategies/patterns), P1-C2 (data layer), P1-D2 (experiments/learning), P1-E1/E2 (backtest), P1-F1/F2 (API/frontend), P1-G1/G2 (tests), P1-H1A/H1B (docs), P1-H3 (rules), P1-I (deps), P1-H4 (DEF triage)

**Minimum viable audit for a non-production project: approximately 14 sessions** (18 - 3 for config-reduction and core-consolidation - 1 if strategies folder is smaller than ARGUS's).

**Minimum viable audit for a small greenfield project (<10K LOC): approximately 6-8 sessions** by folding domain-coupled sessions together. Threshold where session-count savings exceed finding-quality loss is probably around 30K LOC — below that, mega-sessions are fine; above, decompose per the ARGUS model.

---

## Synthesis phase notes

This conversation alone produced a specific audit execution. The other two audit-related conversations (audit-plan generation + audit-session-prompt refinement, per the transcript catalog) likely produced complementary patterns: session-prompt authoring conventions, the original 18-session decomposition, and the Phase 3 fix-generation rules.

When synthesizing across all three, prioritize:
1. Pattern dedup (several patterns here likely appeared in the earlier conversations too — check audit-plan generation for the original session-splitting logic)
2. Sequencing of insights (which pattern emerged first? what depended on what?)
3. Open questions deduplicated across all three
4. The "what should NOT be codified" lists should be unioned — if any one conversation says "don't codify X," respect that even if another conversation seems to want to

Do not synthesize without reading all three evolution notes first.
