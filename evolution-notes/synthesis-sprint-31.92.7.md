# synthesis-sprint-31.92.7 — Evolution Notes

**Completed:** 2026-05-12
**Predecessor synthesis sprint:** synthesis-sprint-31.92.6 (sealed 2026-05-10)
**Trigger:** post-Sprint-31.92.7-seal (ARGUS commit `188c8e7a`); operator surfaced a prior-conversation Phase A input package (`synthesis-sprint-inputs-from-31_92_65-and-31_92_7.md`) covering adversarial-review-derived candidates from Sprint 31.92.65 + Sprint 31.92.7. Operator additionally folded 5 Work-Journal-derived supplementary candidates from a prior session in this conversation. **16 distinct amendments folded across 6 sessions.**

---

## Architectural Note — claude/rules/universal.md is symlinked (carry-forward)

(Carrying forward the architectural truth from synthesis-sprint-31.92.6 D4.)

`argus:.claude/rules/universal.md` is a symbolic link into the workflow
submodule at `workflow/claude/rules/universal.md`. All RULE edits to the
universal rules file are structurally metarepo amendments; ARGUS captures
them via submodule pointer bumps, not via separate file commits.

**synthesis-sprint-31.92.7 DOES amend universal.md** at D6 with two new
RULE entries:

- **RULE-056** — Phase A API-surface verification artifact non-bypassable
  (codifies W-2; binds `templates/phase-a-api-surface-audit.md`).
- **RULE-057** — Round-N+1 verdict-text completeness audit non-bypassable
  (codifies W-NEW2; binds `templates/round-N-adversarial-review-prompt.md`
  Task 3).

**Verification one-liner (unchanged from predecessor):**

```bash
ls -la /path/to/argus/.claude/rules/universal.md
# Expected: lrwxrwxrwx ... -> ../../workflow/claude/rules/universal.md
```

After D6 lands, the ARGUS submodule pointer bump propagates RULE-056 + RULE-057 to ARGUS without further code edits.

---

## Session Inventory (6 sessions)

| Session | File(s) | Lessons folded | Commit |
|---|---|---|---|
| D1 | 5 new template files at `templates/round-N-revision-summary.md` + `round-N-surgical-fix-summary.md` + `round-N-adversarial-review-prompt.md` + `phase-a-api-surface-audit.md` + `cross-document-api-shape-matrix.md` | T-1 (RECONFIRMED) + T-2 (NEW) + T-3 (NEW) + W-2 artifact template (NEW) + W-4 artifact template (NEW); also W-NEW2 audit logic lives in T-3 Task 3 | `2aca5d6` |
| D2 | `templates/sprint-spec.md` (v? → v?) + `templates/implementation-prompt.md` (v1.7.0 → v1.8.0) | SS-1 file-path convention (W-NEW2 path-prefix variant) + SS-2 FAI letter-suffix-list sweep (W-NEW additive variant) + IP-1 Tier 2 Enumeration Imperative (WJ-2) + IP-2 Non-negotiable invocation PLANNING NOTE (WJ-3) + IP-3 Self-Anchoring schematic-spec/grep/RULE-038 triangle (WJ-4) | `aeec10e` |
| D3 | `protocols/sprint-planning.md` (v? → v?) | SP-1 Phase A API-Surface Verification (W-2 HIGHEST priority — 4 consecutive sprints) + SP-2 Phase C Cross-Document API-Shape Matrix (W-4) + SP-3 Phase D bidirectional Phase A↔C consistency (W-1) + SP-4 Phase D Constraints/Scope/Review-Focus/DoD/narrative sweep (W-NEW) + SP-5 Phase D additive-change letter-suffix sweep (W-NEW additive) + SP-6 new H2 §Three-Stream Parallel Execution (O-1) | `44131ce` |
| D4 | `protocols/in-flight-triage.md` (v1.4.0 → v1.5.0) | WJ-1 §Canonical-artifact cross-check H3 subsection (Sprint 31.92.7 Refresh #6 + #10 + #13 + IMP-12.5 scoping) + WJ-5 §Non-Substantive Artifact Separation H2 (Sprint 31.92.7 S8 fold-into-feature surfacing) | `2db9b2b` |
| D5 | `protocols/adversarial-review.md` (v? → v?) | AR-1 §Surgical-Fix-Class REVISE Criteria (W-NEW3) + AR-2 §Round-N+1 Verdict-Text-Completeness Audit (W-NEW2) + AR-3 §Reviewer Time-Budget Guidance (O-2 geometric decay calibration) | `02dbc6a` |
| D6 | `claude/rules/universal.md` (RULE-056 + RULE-057 added) + `bootstrap-index.md` (v1.1.0 → v1.2.0) + new `evolution-notes/synthesis-sprint-31.92.7.md` (this file) | Bookkeeping closure + RULE codification + cumulative narrative + cross-amendment verification | (this commit) |

---

## Two Layers of Lessons Folded

### Layer 1 — Adversarial-review-derived (Primary Input: uploaded `synthesis-sprint-inputs-from-31_92_65-and-31_92_7.md`)

6 W-class workflow gaps + 3 new artifact patterns + 2 operational learnings to codify:

#### W-class workflow gaps

- **W-2 Phase A API-surface verification gap** (⭐ HIGHEST, 4 consecutive sprints) →
  - SP-1 amendment in `protocols/sprint-planning.md` (Phase A mandatory artifact gating Phase B)
  - `templates/phase-a-api-surface-audit.md` (NEW) at D1
  - RULE-056 non-bypassable binding at D6
  - Empirical anchor: Sprint 31.92.7 R1 (`broker.get_positions(symbol)` doesn't exist; `on_order_filled` doesn't exist; "12-field metadata" wrong); Sprint 31.92.65 R1 + R2 (`ActiveAlert.last_observed_at`, `bulk_ack_id`, `HealthMonitorConfig`, `bus.emit()`, `Layout.tsx`, `frontend/...` path prefix); Sprint 31.92.65 R3 (FAI letter-suffix list mismatch).
- **W-1 Phase A ↔ Phase C bidirectional consistency** (4 consecutive sprints) →
  - SP-3 amendment in `protocols/sprint-planning.md` Phase D Sweep 1
  - Empirical anchor: Sprint 31.92.65 R2 N-R2-4 (joint design summary A4 retained REJECTED architecture).
- **W-NEW Phase D revision-pass Constraints/Scope/Review-Focus/DoD/narrative sweep gap** →
  - SP-4 amendment in `protocols/sprint-planning.md` Phase D Sweep 2
  - Two sub-patterns: amendment changes (architectural revision touching surface) + additive changes (new FAI letter)
  - Empirical anchor: Sprint 31.92.65 R2 N-R2-2 (Constraints retained stale instruction post-revision); Sprint 31.92.65 R3 N-R3-NEW-1 (stale FAI letter-suffix lists).
- **W-NEW additive variant (letter-suffix sweep)** →
  - SP-5 amendment in `protocols/sprint-planning.md` Phase D Sweep 3
  - SS-2 amendment in `templates/sprint-spec.md`
  - Empirical anchor: Sprint 31.92.65 R3 N-R3-NEW-1 (3 stale A/B/C references after FAI-65-D addition).
- **W-4 Cross-document API-shape consistency matrix** →
  - SP-2 amendment in `protocols/sprint-planning.md` (Phase C deliverable artifact)
  - `templates/cross-document-api-shape-matrix.md` (NEW) at D1
  - Empirical anchor: Sprint 31.92.7 R2 drift cleanup (commit `7e0f780e`: 33 edits across 12 secondary artifacts; 4 patterns persisted).
- **W-NEW2 Round-N verdict text completeness audit** (NEW) →
  - AR-2 amendment in `protocols/adversarial-review.md`
  - `templates/round-N-adversarial-review-prompt.md` Task 3 (NEW) at D1
  - RULE-057 non-bypassable binding at D6
  - Empirical anchor: Sprint 31.92.65 R3 N-R3-NEW-2 (bulk-ack `_dedup_index` clearing semantic asserted by FAI-65-D invariant (d) but not enumerated in AC4.x/AC1.5 — inherited from R2 verdict's FAI-65-D specification text).
- **W-NEW3 Surgical-fix-class REVISE codification** (NEW) →
  - AR-1 amendment in `protocols/adversarial-review.md` (5 criteria + verdict-text template)
  - `templates/round-N-surgical-fix-summary.md` (NEW) at D1
  - Empirical anchor: Sprint 31.92.65 R2 reviewer-judgment surgical-class invocation (verbatim quote: "DO NOT trigger sprint decomposition. REVISE (surgical-class)").

#### New artifact patterns (Primary Input Section 2)

- **T-1 `round-N-revision-summary.md` template** (RECONFIRMED) — codified at D1; validated across Sprint 31.92.7 R2 + Sprint 31.92.65 R2.
- **T-2 `round-N-surgical-fix-summary.md` template** (NEW) — codified at D1; binding partner of W-NEW3.
- **T-3 `round-N-adversarial-review-prompt.md` template** (NEW) — codified at D1; binding partner of W-NEW2.

#### Operational learnings (Primary Input Section 3)

- **O-1 Three-stream parallel execution feasibility** → SP-6 amendment in `protocols/sprint-planning.md` (new H2 with disjoint-file-targets + ≤3 conversations + adrev-not-parallel-with-own-revision-pass prerequisites).
- **O-2 Reviewer time budget geometric decay** → AR-3 amendment in `protocols/adversarial-review.md` (R1 ~6h / R2 ~1.5h / R3 ~30min calibration).
- **O-3 Round 3 pre-commitment rule calibration** — NO ACTION needed; the rule is well-calibrated per Sprint 31.92.65 trajectory (3 Critical R1 → 2 Critical R2 surgical-class → 0 Critical R3). Documented in AR-3 as cross-reference only.

### Layer 2 — Work-Journal-derived (Supplementary Input from this conversation's archived prior session)

5 Work-Journal-derived candidates anchored to Sprint 31.92.7 only:

- **WJ-1 Register-refresh canonical-artifact cross-check** (HIGH) →
  - D4 amendment in `protocols/in-flight-triage.md`
  - Empirical anchor: Sprint 31.92.7 Refresh #6 (FAI semantic-description mapping errors + missed FAI-7-6 + fabricated FAI-7-4 status) + Refresh #10 (RSK-057 + RSK-058 never tracked) + Refresh #13 (CF target attribution to "S11 doc-sync" incorrect) + IMP-12.5 scoping (residual-count inflation).
- **WJ-2 Tier 2 bounded-language Enumeration Imperative** (MEDIUM) →
  - IP-1 amendment in `templates/implementation-prompt.md` § Tier 2 Review
  - Empirical anchor: Sprint 31.92.7 CF-S2-1 (7 → 11 tests growth pattern — unbounded-claim artifact).
- **WJ-3 Non-negotiable @reviewer invocation wording** (MEDIUM) →
  - IP-2 amendment in `templates/implementation-prompt.md` § Tier 2 Review
  - Empirical anchor: Sprint 31.92.7 S5–S13 drift + IMP-12.5 verbatim re-encoding remediation.
- **WJ-4 Self-Anchoring Pre-Flight schematic-spec/grep/RULE-038 triangle** (LOW) →
  - IP-3 amendment in `templates/implementation-prompt.md` § Pre-Flight Self-Anchoring block
  - Empirical anchor: Sprint 31.92.7 IMP-12.5 9-AC triangle validation.
- **WJ-5 Spike-results JSON git-hygiene (chore-isolate default)** (LOW) →
  - D4 amendment in `protocols/in-flight-triage.md` (new H2 §Non-Substantive Artifact Separation)
  - Empirical anchor: Sprint 31.92.7 S8 fold-into-feature surfacing.

### Layer 3 — Process-evolution lessons NOT folded (per operator D-40 disposition from prior conversation)

F.34..F.39 lessons from Sprint 31.92.7 remain in ARGUS `docs/process-evolution.md`. ARGUS-specific operational observations, not generalizable to other projects using the metarepo. Explicitly excluded from metarepo absorption at Phase A.

---

## Cumulative Cross-References

The amended files now form a coherent cross-reference network spanning synthesis-sprint-31.92.6 + synthesis-sprint-31.92.7:

### Register discipline (cross-sprint coherent)
`protocols/in-flight-triage.md` v1.5.0 § Per-Session Register Discipline:
- §FLAGGED self-assessment subsection (synthesis-sprint-31.92.6)
- §Canonical-artifact cross-check subsection (synthesis-sprint-31.92.7 WJ-1)

### Phase A discipline (NEW — entire pipeline introduced this synthesis)
- `protocols/sprint-planning.md` Phase A § API-Surface Verification (D3 SP-1)
- `templates/phase-a-api-surface-audit.md` (D1 — the canonical artifact)
- RULE-056 non-bypassable (D6 — binding rule)

### Phase C discipline (NEW — Phase C now has structured artifact)
- `protocols/sprint-planning.md` Phase C § Cross-Document API-Shape Matrix (D3 SP-2)
- `templates/cross-document-api-shape-matrix.md` (D1 — the canonical artifact)
- Each revision pass refreshes the matrix per `protocols/sprint-planning.md` Phase D Sweep 4

### Phase D revision-pass discipline (consolidated)
- `protocols/sprint-planning.md` Phase D § Revision-Pass Sweep Checklist (D3 SP-3 + SP-4 + SP-5):
  - Sweep 1 — Bidirectional Phase A ↔ Phase C consistency (W-1)
  - Sweep 2 — Constraints/Scope/Review-Focus/DoD/narrative sweep (W-NEW amendment-class)
  - Sweep 3 — Additive-change letter-suffix sweep (W-NEW additive variant)
  - Sweep 4 — Cross-document API-shape matrix refresh (W-4 binding)

### Round-N adversarial review discipline (3 new templates + 3 protocol amendments)
- `templates/round-N-revision-summary.md` (D1 T-1) — canonical for non-surgical revisions
- `templates/round-N-surgical-fix-summary.md` (D1 T-2) — canonical for surgical-class revisions
- `templates/round-N-adversarial-review-prompt.md` (D1 T-3) — Round-N (N≥2) reviewer prompt
- `protocols/adversarial-review.md` §Surgical-Fix-Class REVISE Criteria (D5 AR-1; W-NEW3)
- `protocols/adversarial-review.md` §Round-N+1 Verdict-Text-Completeness Audit (D5 AR-2; W-NEW2)
- `protocols/adversarial-review.md` §Reviewer Time-Budget Guidance (D5 AR-3; O-2)
- RULE-057 non-bypassable (D6 — binding rule for W-NEW2)

### Self-Anchoring triangle (synthesis-sprint-31.92.7 contribution)
- `templates/implementation-prompt.md` v1.8.0 §Pre-Flight Self-Anchoring (D2 IP-3):
  - SHA-capture pattern (synthesis-sprint-31.92.6)
  - Schematic-spec/grep/RULE-038 three-element discipline triangle (synthesis-sprint-31.92.7)
- Composes with `templates/implementation-prompt.md` §Files to Modify > Structural anchor + pre-flight grep-verify (synthesis-2026-04-26 + Sprint 31.91)
- Composes with RULE-038 in `claude/rules/universal.md`

### Tier 2 verdict discipline
- `templates/implementation-prompt.md` v1.8.0 §Tier 2 Review (D2):
  - Enumeration Imperative H3 (D2 IP-1; WJ-2)
  - Non-negotiable invocation PLANNING NOTE (D2 IP-2; WJ-3)
- Composes with `templates/round-N-adversarial-review-prompt.md` Task 1 (D1)

### Commit hygiene
- `protocols/in-flight-triage.md` v1.5.0 §Non-Substantive Artifact Separation (D4 WJ-5)
- Composes with `templates/implementation-prompt.md` §F3 disposition flexibility (synthesis-sprint-31.92.6)

### Three-stream parallel execution
- `protocols/sprint-planning.md` § Three-Stream Parallel Execution (D3 SP-6)
- Tested empirically during Sprint 31.92.7 + Sprint 31.92.65 concurrent planning window

---

## Sprint 31.92.8 Readiness

With synthesis-sprint-31.92.7 sealed, Sprint 31.92.8 (Watchdog Promotion architectural decision) opening conversation reads against the substantially-amended metarepo state. **Sprint 31.92.8 will be the inaugural sprint exercising the new workflow.**

### What changes for Sprint 31.92.8 Phase A

- **Phase A produces a NEW mandatory artifact**: `docs/sprints/sprint-31.92.8/phase-a-api-surface-audit.md` per `templates/phase-a-api-surface-audit.md`. Failure to produce gates Phase B per RULE-056.
- **Empirical anchor for confidence**: 4 consecutive sprints with 3–4 Critical primitive-semantics misses per Round-1 verdict. Sprint 31.92.8 should produce ≤1 Critical primitive-semantics miss at Round 1 if the new workflow works. Lower-bound success metric.

### What changes for Sprint 31.92.8 Phase C

- **Phase C produces a NEW mandatory artifact**: `docs/sprints/sprint-31.92.8/cross-document-api-shape-matrix.md` per `templates/cross-document-api-shape-matrix.md`. Updated at every revision pass.

### What changes for Sprint 31.92.8 adversarial-review rounds

- **Round 1**: standard adrev (no template change at Round 1 yet).
- **Round 2+** (if reached): uses `templates/round-N-adversarial-review-prompt.md`. Task 3 W-NEW2 verdict-text-completeness audit applies per RULE-057.
- **Time budgets**: per AR-3 calibration. Operator can plan accordingly.

### What changes for Sprint 31.92.8 Work Journal

- **§Per-Session Register Discipline** uses `protocols/in-flight-triage.md` v1.5.0:
  - §Canonical-artifact cross-check H3 (NEW from this synthesis) — register refreshes structurally cross-check against sprint-package canonical artifacts.
  - §FLAGGED self-assessment (carry-forward from synthesis-sprint-31.92.6).
- **§Non-Substantive Artifact Separation** H2 codifies chore-isolate default for spike-results JSON.

### What does NOT change

- The empirical-baseline gating for Sprint 31.92.8 architectural-decision entry: 3+ clean paper sessions OR ~2,000 cumulative positions, whichever comes second (per Sprint 31.92.7 FAI-7-5 deferred-by-design rationale). Operator confirms gate-met before Phase A opens.
- The CF-T3-1 hard gate (real-broker FAI-7-1 + FAI-7-A refalsification using S3-shipped test infrastructure at `tests/integration/test_broker_truth_check_latency.py`). Lands as paper-session-1 operator-supervised task during Sprint 31.92.8.

---

## Meta-Observations (synthesis-sprint-31.92.7's own lessons)

### Higher session count + larger scope than predecessor — opposite trajectory from anticipated

synthesis-sprint-31.92.7 has **6 sessions vs predecessor's 5; 3 NEW templates + 2 NEW RULEs vs predecessor's 0 NEW templates + 2 NEW RULEs; 16 lessons folded vs predecessor's ~12.**

This is the **opposite** of the "scaling DOWN as the metarepo stabilizes" trajectory anticipated in synthesis-sprint-31.92.6 evolution-notes. The reason:
- synthesis-sprint-31.92.7 was the FIRST synthesis sprint to absorb adversarial-review-derived candidates at scale (uploaded document covered 4 consecutive sprints' findings).
- The empirical-anchor strength of W-2 (4-consecutive-sprint confirmation) demanded a HIGHEST-priority amendment + mandatory artifact template + non-bypassable RULE.
- Future synthesis sprints can re-evaluate whether the metarepo is now stabilizing. RULE-056 + RULE-057's empirical effects will be observable in Sprint 31.92.8 R1 verdict.

### Two-input-stream merge worked cleanly

The Phase A planning artifact merged:
- Primary input: uploaded `synthesis-sprint-inputs-from-31_92_65-and-31_92_7.md` (adversarial-review-derived)
- Supplementary input: 5 Work-Journal-derived candidates from this conversation's archived prior session

The two streams were **completely disjoint** — no candidate appeared in both streams. The merge approach (adopt primary as foundation; fold supplementary as additional scope into appropriate sessions) preserved the empirical-strength prioritization while losing nothing.

**Lesson:** when Phase A inputs come from multiple sources, the right merge strategy is to organize by canonical empirical-anchor strength (adversarial-review verdicts > Work-Journal observations > individual-session anecdotes), fold all into a single Phase A artifact, and proceed with a unified session breakdown.

### Forward-reference pattern was clean

D5 referenced RULE-057 which is added at D6. This forward-reference was documented in D5's verification target #7 with explicit "do not fail if RULE-057 not yet in universal.md" guidance. D6's commit resolves the forward-reference.

**Pattern works for:**
- RULE additions that follow protocol amendments codifying their behavior (the protocol amendment lands first; the RULE references it; the RULE codification lands at the close-of-sprint commit).
- Cross-session template references (D3/D5 reference D1's templates; D1 lands first).

### Verification regex strictness — third confirmation lands

The predecessor's recommendation (case-insensitive grep + lowercase canonical summary phrase) compounded across both synthesis-sprint-31.92.6 + synthesis-sprint-31.92.7. **Third confirmation:** in this synthesis sprint, NO verification grep produced an unexpected near-miss or false-negative across the impl prompt verification target groups (D1's 7 + D2's 10 + D3's 11 + D4's 11 + D5's 9 = 48 verification targets total). Pattern is empirically validated.

**Action:** codify this as a standing impl-prompt-authoring convention in the next synthesis sprint (synthesis-sprint-31.92.8 or successor) if a fourth confirmation lands.

### Sprint 31.92.7's own structural-anchor exception

D3's `protocols/sprint-planning.md` amendments used semantic-anchor preference (RULE-038) heavily because the protocol file's exact line numbers couldn't be predicted at Phase A time. The impl prompt explicitly instructed the implementer to grep-verify against actual structure and adapt with disclosure. **Pattern works for large protocol files** where the schematic spec describes intent + the implementer aligns to grep-verified reality.

### Carry forward to next synthesis sprint

1. **Empirical effect of RULE-056 + RULE-057 in Sprint 31.92.8.** Did Round-1 verdict produce ≤1 Critical primitive-semantics miss? Did Round-N+1 verdict-text-completeness audit catch a finding the prior round missed? These observations feed the next synthesis sprint's calibration.
2. **W-NEW3 surgical-class invocation pattern.** Did Sprint 31.92.8's adversarial-review use the surgical-class disposition? Did the criteria (AR-1 5-bullet list) feel correctly-calibrated? Observations feed AR-1 refinement.
3. **O-2 reviewer time-budget data.** Add Sprint 31.92.8 R1/R2/R3 time spent to the AR-3 calibration table. If geometric decay holds, the model is validated for a 5th sprint.
4. **Verification regex strictness pattern fourth confirmation.** If synthesis-sprint-31.92.8 also produces zero misses, codify as standing convention.

---

## Annotated tag (OPTIONAL)

If operator wants a durable seal record:

```bash
cd /path/to/workflow
git tag -a synthesis-sprint-31.92.7-sealed -m "synthesis-sprint-31.92.7 sealed 2026-05-12 — Sprint 31.92.65 + Sprint 31.92.7 metarepo absorption; 6 sessions; 7 metarepo files amended (in-flight-triage.md v1.5.0 + implementation-prompt.md v1.8.0 + sprint-spec.md next-minor + sprint-planning.md next-minor + adversarial-review.md next-minor + universal.md +2 RULEs + bootstrap-index.md v1.2.0) + 5 new templates + 1 new evolution-notes file; 16 lessons folded (1 HIGHEST + 5 HIGH + 5 MEDIUM + 3 LOW + 2 operational learnings); W-2 (Phase A API-surface verification) is the headline amendment."
git push origin synthesis-sprint-31.92.7-sealed
```

This is operator-discretion; the evolution-notes file itself is the canonical durable record.

---

*End synthesis-sprint-31.92.7 evolution notes.*
