<!-- workflow-version: 2.0.0 -->
<!-- last-updated: 2026-04-26 -->
# Protocol: Codebase Health Audit

**Context:** Claude.ai conversation
**Frequency:** Every 4-6 sprints
**Output:** Health assessment, technical debt inventory, roadmap adjustments

---

## When to Use
- At the cadence specified above (every 4-6 sprints)
- When technical debt feels like it is slowing development
- Before a major new phase that will build on the existing codebase
- When onboarding a new contributor who needs to understand code quality

This is NOT tied to any sprint. It is a systemic check.

The protocol runs in three phases. Phase 1 scopes the audit and produces session-budget guidance. Phase 2 generates findings into a structured CSV with a non-bypassable validation gate. Phase 3 takes the validated CSV and runs fix-group sessions.

---

## Phase 1: Scoping and Pre-Flight

Phase 1 frames the audit's scope, identifies coverage targets, and budgets sessions. The phase produces three artifacts: the closed-item health spot-check, the custom-structure rule decision, and the session-count budget.

### 1.1 Closed-Item Health Spot-Check

[F8 generalized terminology: this section uses "closed-item" not "DEF" — DEFs are an ARGUS-specific naming convention. The pattern applies to any tracker's closed items: GitHub Issues with "closed" status, Linear issues marked Done, Jira tickets in Resolved status, etc.]

Before scoping the audit, sample-check 5–10 recently-closed items from the project's tracker. For each:

- **Are they actually closed-and-fixed**, or closed-and-paper-over (CLOSED status set without verification)?
- **Did the close-action commit reference them** (e.g., commit message mentions issue ID)?
- **Are tests (if applicable) added or updated** as part of the close-action?
- **Is the closing rationale documented** somewhere durable (commit body, ticket comment, runbook)?

The spot-check produces a "closed-item hygiene" judgment: HEALTHY (≥80% are closed-and-fixed-and-traceable), DRIFTING (50–80%), or BROKEN (<50%). DRIFTING/BROKEN findings extend the audit's Phase 2 to include closed-item-hygiene reviews; HEALTHY findings allow the audit to proceed without that extension.

### 1.2 Custom-Structure Rule

The audit's structure (which phases run, which artifacts get produced, which validation gates apply) defaults to the structure documented in this protocol. The operator MAY customize when the project's specific shape warrants it (e.g., a security-focused audit might prepend a Phase 0 threat-model review; a compliance audit might add a Phase 4 documentation completeness review).

Customizations MUST:
- Be documented in the audit's kickoff prompt with explicit rationale.
- Identify which deviations from default structure are operative.
- Re-validate that any default-structure validation gates are either preserved or replaced by equivalent custom gates.

### 1.3 Session-Count Budget

Estimate total sessions for the audit using the compaction-risk formula in `protocols/sprint-planning.md` Phase A. For audits, expect:

- Phase 1: 1 session (this scoping work).
- Phase 2: 2–6 sessions (depending on universe scope; multi-track audits run Phase 2 in parallel).
- Phase 3: 1–4 sessions (one per fix-group cluster identified in Phase 2).

A typical small-codebase audit lands at 4–6 total sessions; a mid-size codebase audit lands at 8–12; a large multi-module audit can exceed 15. If session-count budget exceeds 10, the audit is a campaign — apply `protocols/campaign-orchestration.md` for the coordination machinery.

<!-- Origin: synthesis-2026-04-26 evolution-note-1 (audit-execution) §S1
     dispositions S1.1, S1.2, S1.3. F8 generalized terminology applied
     to S1.1: "closed-item" replaces ARGUS-specific "DEF". -->

---

## Phase 2: Findings Generation

Phase 2 produces the audit's findings CSV — a row-per-finding structured artifact that Phase 3 consumes. Phase 2 also identifies hot files, sets per-finding decisions (fix-now / fix-later / defer / debunk / scope-extend), and validates CSV integrity.

### 2.1 CSV Integrity + Override Table

The findings CSV uses the column schema documented in `scripts/phase-2-validate.py`'s module docstring. The schema's columns are: finding_id, file_path, issue_summary, mechanism_signature, decision, fix_session_id, rationale.

Override table: when a finding's decision needs to deviate from a default rule (e.g., a finding marked fix-later by the default policy but the operator decides fix-now because of cross-track impact), the override is documented in a separate `phase-2-overrides.md` artifact with: finding_id, default-decision, override-decision, rationale, operator-attribution. The override artifact lives alongside the CSV in the audit folder.

### 2.2 Scale-Tiered Tooling

The Phase 2 tooling (how findings are generated, who runs the queries, how aggregated) tiers by scope:

| Scale | Tooling |
|---|---|
| ≤500 LOC scoped | Manual review against checklist |
| 500–5K LOC scoped | Manual review + grep-driven discovery |
| 5K–50K LOC scoped | Grep-driven discovery + light static-analysis tools (linter rules, type-check baselines) |
| 50K–500K LOC scoped | Static-analysis tooling + scoped human review (focus on hot files) |
| >500K LOC scoped | Multi-track parallel audits per `protocols/campaign-orchestration.md`, each on a sub-universe |

Tier choice is operator-judgment; the scale boundary is a prompt, not a hard threshold.

### 2.3 Operator-Judgment Commit Pattern

When Phase 2 generates a finding that requires operator judgment to triage (e.g., "this looks like a candidate fix but it could also be intentional design"), the finding is committed to the CSV with `decision=fix-later` and the operator's judgment is captured in the rationale column (e.g., "needs operator triage: is this intentional?"). The Phase 3 fix-group clustering picks these up; if the operator's eventual decision is "intentional," the finding gets re-labeled `decision=debunk` per §2.6 below.

This pattern preserves the finding in the audit trail (so it's not lost) without forcing premature decisions.

### 2.4 Approval-Heavy Pattern with Hot-File Carve-Out

For high-risk codebase regions, Phase 2 may set `decision=fix-now` only with operator explicit approval per finding (rather than per fix-group). This "approval-heavy" pattern is the default for hot files (§2.7 below). The carve-out: if a hot-file finding is below a triviality threshold (e.g., a single-line typo fix, a clearly-cosmetic refactor), the per-finding approval may be skipped and approval batched at the fix-group level.

### 2.5 Combined Doc-Sync

Phase 2 may discover doc-sync work (CLAUDE.md drift, runbook staleness) as a side effect of finding generation. Such findings get `decision=fix-now` and a fix_session_id pointing at a combined doc-sync session that runs alongside Phase 3 fix sessions. This avoids fragmenting doc-sync across many small fix-now sessions.

### 2.6 In-Flight Triage Amendment

Phase 2 findings can change classification mid-audit when new information arrives. The amendment pattern: finding_id stays stable; the row's decision column updates; the rationale column appends the amendment ("Amended YYYY-MM-DD: was fix-later, now fix-now because..."). The audit's `phase-2-overrides.md` artifact tracks all amendments. DEBUNKED status (per `protocols/campaign-orchestration.md` §7) is the most common amendment direction.

### 2.7 Hot Files Operationalizations

[F4 tiered operationalizations: "hot files" is the abstract concept; the operationalization tier varies by project shape. Adopt one tier; do not adopt all.]

Operationalize "hot files" using ONE of the following project-shape-appropriate tiers:

1. **Recent-bug count.** Files with ≥3 closed bugs in the last 90 days are hot.
2. **Recent-churn.** Files with ≥10 commits in the last 30 days are hot.
3. **Post-incident subjects.** Files identified as root-cause in the last 6 months of post-incident reviews are hot.
4. **Maintained list.** A project-maintained `hot-files.md` document (operator-curated, updated quarterly) lists hot files explicitly.
5. **Code-ownership signal.** Files with high committer-diversity (≥5 distinct committers in the last 90 days) are hot, indicating shared-stewardship complexity.

Hot files trigger the approval-heavy pattern (§2.4) by default. The choice of tier is project-specific; document the choice in the audit kickoff.

### 2.8 phase-2-validate.py Non-Bypassable Gate

**Phase 2 cannot complete until `scripts/phase-2-validate.py` exits zero against the findings CSV.** The validator runs 6 checks (row column-count / decision-value canonical / fix-now has fix_session_id / FIX-NN-kebab format / finding_id integrity / mechanism_signature for fix-now/fix-later). Before proceeding to Phase 3, the operator MUST:

1. Run `python3 scripts/phase-2-validate.py path/to/findings.csv`.
2. Confirm exit code is 0.
3. Capture the validator's PASS output in the audit close-out.

A non-zero exit halts Phase 3 generation. Fix the CSV (or fix the validator if the validator is buggy) and re-run before proceeding.

The validator does NOT validate safety tags. See §2.9 below.

### 2.9 Anti-pattern (do not reinvent)

[Important — this section documents a structural rejection. Future audits MUST NOT reintroduce the pattern below.]

A previous synthesis effort considered codifying a 4-tag safety taxonomy on Phase 2 findings (`safe-during-trading`, `weekend-only`, `read-only-no-fix-needed`, `deferred-to-defs`) or a core+modifier expansion thereof. **The taxonomy was empirically overruled** during ARGUS Sprint 31.9 execution — the operator ran fixes during active operational sessions regardless of tag, and the actual audit-trail mechanism turned out to be execution-anchor-commit correlation (per `protocols/operational-debrief.md` §2), not safety tags as routing.

**Do not reinvent this taxonomy.** If a future audit's findings need scheduling or routing logic, use:
- `decision` column values (canonical: fix-now, fix-later, defer, debunk, scope-extend) for fix-vs-defer.
- Fix-group cardinality (§3.7 below) for batching decisions.
- Operator-judgment-commit pattern (§2.3 above) for ambiguous findings.
- Execution-anchor-commit correlation (per `protocols/operational-debrief.md` §2) for audit-trail correlation.

The 4-tag safety taxonomy adds taxonomy-maintenance overhead without earned load-bearing role. Origin: synthesis-2026-04-26 Phase A pushback round 2 (operator empirically rejected the taxonomy based on Sprint 31.9 execution evidence).

<!-- Origin: synthesis-2026-04-26 evolution-note-1 (audit-execution) §S2
     dispositions S2.1–S2.7; Phase A pushback round 2 (safety-tag
     rejection); F4 tiered hot-files; F8 generalized terminology. -->

---

## Phase 3: Fix Generation and Execution

Phase 3 takes Phase 2's validated findings CSV and produces fix prompts, schedules fix sessions, and tracks execution. The phase output is fix-session implementation prompts (one per fix-group cluster) plus the audit's overall close-out.

### 3.1 File-Overlap-Only DAG Scheduling

Fix sessions are scheduled into a DAG where the only dependency relation is **file overlap** — two fix sessions cannot run in parallel if they modify the same file. Other potential scheduling considerations (operator availability, CI capacity, deployment windows) are operator-judgment overlays on top of the file-overlap DAG, not dependency relations.

The file-overlap DAG is mechanically derivable: list each fix session's modified-files set; any two sessions with non-empty intersection are serialized; otherwise parallelizable.

This replaces an earlier proposed scheduling approach that combined file-overlap with a "safety-tag matrix" — see §2.9 (Anti-pattern). File-overlap alone is sufficient for scheduling; the matrix component was rejected.

### 3.2 sort_findings_by_file

Within Phase 3, findings are clustered into fix-groups by source file. A fix-group is a set of findings that all modify the same file or a tightly-coupled set of files (e.g., a class and its tests). This clustering reduces context-loading overhead per fix session: the implementer reads the file once, addresses all findings against it, commits.

The clustering is mechanical (sort findings by file_path; cluster contiguous same-file findings; cross-file fix-groups require explicit operator override). Document the clustering decision in the audit close-out.

### 3.3 Fingerprint-Before-Behavior-Change

[F5 expanded: 3 non-trading examples to ground the abstract pattern.]

Before a fix-group session changes behavior, the session establishes a **mechanism signature** (a fingerprint) for the bug being fixed. The signature is what's used to validate that the fix actually addresses the bug, not just suppresses the symptom.

The signature is captured in the Phase 2 CSV's `mechanism_signature` column (per `scripts/phase-2-validate.py` check 6). The fix session's test strategy validates against the signature.

**Three non-trading examples:**

#### 3.3.1 Pricing Engine Example

A pricing engine occasionally outputs a price 100× the correct value. The mechanism signature is "output > 50× input baseline AND occurs on first call after engine restart." The fix-session validates that post-fix, the signature is no longer reproducible (cold-start tests run; output stays within ≤2× baseline). Without a signature, a fix that "appears to work" might just have shifted the failure mode.

#### 3.3.2 A/B Test Cohort Example

An A/B test framework reports inconsistent cohort assignments — users sometimes flip cohorts within a session. The mechanism signature is "cohort_id changes within a single user session AND change correlates with backend instance routing." The fix-session validates that post-fix, cohort_id is stable across N=10000 user-session-simulations regardless of routing. Without a signature, the fix might pass cursory testing but still flip cohorts under specific routing patterns.

#### 3.3.3 ML Model Recommendation Example

A recommendation model occasionally recommends already-purchased items to users who have purchase-history. The mechanism signature is "recommended item_id appears in user's purchase_history within last 30 days, AND model version is v3.X." The fix-session validates that post-fix, the signature occurrence rate falls below 0.1% (matching the pre-bug baseline). Without a signature, "fixing" the model might just mask the issue while the underlying purchase-history-blindness persists.

### 3.4 Coordination-Surface Branch (Multi-Track Audits)

[F1: "campaign coordination surface" generalized terminology.]

For audits with multiple parallel Phase 3 tracks, the campaign coordination surface (per `protocols/campaign-orchestration.md`) tracks per-track progress. The surface is typically a Claude.ai conversation, but can be an issue tracker with a campaign label, a wiki page, or any persistent artifact tracking work-in-flight beyond a single session. Per-track close-outs feed into the audit's cross-track synthesis (per `protocols/campaign-orchestration.md` §4).

### 3.5 Scope-Extension Home

When a Phase 3 fix session discovers a new finding NOT in the original Phase 2 CSV, the finding gets added to a `phase-2-overrides.md` (per §2.6 in-flight triage amendment) with `decision=scope-extend`. Scope-extend findings are NOT addressed within the current fix-group session; they're either deferred to a follow-on fix session, queued for a future audit, or absorbed per `protocols/campaign-orchestration.md` §1 (Campaign Absorption) if the audit is operating as a campaign.

The scope-extension home prevents fix sessions from drifting into open-ended scope creep.

### 3.6 Contiguous Numbering

Fix sessions are numbered FIX-NN-<kebab-name> where NN is a contiguous integer sequence per audit. Skip-numbers indicate dropped sessions; the close-out documents reasons. Re-using a number indicates a re-run; the original session's artifacts are preserved with an explicit re-run annotation.

### 3.7 Fix-Group Cardinality

A fix-group is a set of findings sharing fix-session ownership. Cardinality guidance:

- **1–3 findings/group:** typical; one session per group is right-sized.
- **4–8 findings/group:** acceptable; session may need to split mid-execution if context-budget pressure surfaces.
- **9+ findings/group:** flag for re-clustering before fix-session generation; the group is too large for reliable single-session execution.

The cardinality is a heuristic, not a hard rule. Operator-judgment override is acceptable with rationale.

### 3.8 git-commit-body-as-state-oracle (OPTIONAL)

[F9: caveats on squash-merge.]

A useful pattern (when applicable): Phase 3 fix sessions write structured information into commit message bodies (closed-item references, mechanism-signature-validation results, coordination-surface state-update markers). Tools that scan commit bodies can derive audit state from git history without separate state files.

**Caveat:** this pattern is optional and brittle in environments with squash-merge or rebase-merge workflows. If the project uses GitHub PR squash-merge, individual fix-session commits collapse into a single squash commit and structured commit-body data is lost. Workarounds: include the structured data in the PR body (which survives squash) instead of individual commit bodies; or use a separate state file (e.g., `audit-state.jsonl`) maintained alongside the audit artifacts.

Use this pattern only if the project's git workflow preserves individual commits in the long-term branch (no squash, no rebase-flatten).

### 3.9 Cross-References

Phase 3 cross-references:
- `protocols/campaign-orchestration.md` — for multi-track audit coordination (§3.4).
- `protocols/operational-debrief.md` — for execution-anchor-commit correlation pattern (replaces rejected safety-tag taxonomy; see §2.9).
- `protocols/impromptu-triage.md` — when Phase 3 fix sessions surface unrelated impromptu work.
- `templates/stage-flow.md` — for documenting multi-track Phase 3 DAGs.
- `templates/scoping-session-prompt.md` — when a Phase 3 finding's root cause is non-obvious and needs a scoping session before the fix session.

<!-- Origin: synthesis-2026-04-26 evolution-note-3 (phase-3-fix-generation-
     and-execution) §S3 dispositions S3.1–S3.8 (excluding rejected
     N3.3 action-type routing and ID3.3 safety-tag session resolution).
     F1 generalized terminology; F5 3 non-trading examples (pricing
     engine, A/B test, ML model); F9 squash-merge caveat. -->

---

## Conversation Structure (Legacy Phase 1 Checklist)

The following checklist enumerates the substantive areas Phase 1's scoping conversation should cover. Run these as discovery prompts during Phase 1; the outputs feed Phase 2's findings CSV.

### 1. Architectural Coherence

Provide Claude with the architecture document and ask it to survey the repo:

"Survey this codebase against our architecture document. Identify:
1. Components that have drifted from the documented architecture
2. Emergent patterns that are not documented
3. Inconsistencies in how similar problems are solved across the codebase
4. Dead code or unused modules
5. Coupling that was not intended by the architecture"

### 2. Test Coverage Analysis

"Analyze the test suite:
1. What is the overall coverage picture? (not just line count -- which critical paths are tested?)
2. Are there important code paths with no test coverage?
3. Are tests meaningful or are any trivial/tautological?
4. Is the test suite maintainable? (brittle tests, excessive mocking, slow tests?)
5. Are there patterns in what gets tested vs. what does not?"

### 3. Dependency Hygiene

"Review the project dependencies:
1. Are any dependencies outdated by more than one major version?
2. Are any dependencies unmaintained or deprecated?
3. Are there redundant dependencies (two libraries doing the same thing)?
4. Are there dependencies we are barely using that could be replaced with simple code?
5. Are there known security vulnerabilities?"

### 4. Naming and Convention Consistency

"Evaluate naming and convention consistency:
1. Are file naming patterns consistent?
2. Are function/method naming conventions consistent?
3. Are error handling patterns consistent?
4. Are logging patterns consistent?
5. Is there a style that has evolved organically that should be documented as a rule?"

### 5. Deferred Items Debt

"Review the deferred items tracker alongside the codebase:
1. Are deferred items accumulating faster than they are being resolved?
2. Are any deferred items becoming urgent (blocking new work, creating risk)?
3. Should any deferred items be promoted to sprint scope?
4. Should any deferred items be cancelled (no longer relevant)?"

### 6. Technical Debt Inventory

"Based on everything above, produce a prioritized technical debt inventory:

| Item | Severity | Impact on Velocity | Recommended Action | Target Sprint |
|------|----------|-------------------|-------------------|---------------|

Severity: HIGH (blocking or degrading work) / MEDIUM (slowing but not blocking) / LOW (cosmetic)
Impact: How much faster would we move if this were resolved?"

---

## Output

The conversation should produce:
1. Technical debt inventory (prioritized)
2. Revised .claude/rules/ entries for any conventions that should be enforced
3. Specific items to add to the sprint roadmap
4. Updated closed-item entries for new or re-prioritized deferred items
5. Architecture document updates (if drift was found)
