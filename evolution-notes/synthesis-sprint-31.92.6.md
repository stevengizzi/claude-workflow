# synthesis-sprint-31.92.6 — Evolution Notes

**Completed:** 2026-05-10
**Predecessor synthesis sprint:** synthesis-2026-04-26
**Trigger:** post-Sprint-31.92.6-seal (ARGUS commit `86191542`); operator
identified metarepo doc-sync gap after Sprint 31.92.6 sprint-close
included ARGUS-side doc-sync but did NOT include metarepo amendments.

## Architectural Note — claude/rules/universal.md is symlinked

`argus:.claude/rules/universal.md` is a symbolic link into the workflow
submodule at `workflow/claude/rules/universal.md`. All RULE edits to the
universal rules file are structurally metarepo amendments; ARGUS captures
them via submodule pointer bumps, not via separate file commits.

This means synthesis sprints touching universal.md produce a single
metarepo commit (containing all file edits) + one ARGUS submodule pointer
bump per session — NOT separate file edits across two repos. The D4
session of synthesis-sprint-31.92.6 discovered this empirically; the
original D4 directive's "CROSS-REPO" framing was corrected at firing time.

**Implication for future synthesis sprints:** directives touching
universal.md should frame edits as metarepo file work (with ARGUS
submodule pointer bump as the capture mechanism), NOT as "ARGUS-side"
work that requires a separate commit/review per repo.

**Verification one-liner:**

```bash
ls -la /path/to/argus/.claude/rules/universal.md
# Expected: lrwxrwxrwx ... -> ../../workflow/claude/rules/universal.md
```

This architectural truth is captured here so future synthesis-sprint
authors don't mis-frame universal.md edits.

**Sequencing:** synthesis-sprint-31.92.6 ran FIRST, then Sprint 31.92.7
opens against the amended metarepo (Option C sub-option C.1 per scoping
document).

---

## Session Inventory (5 sessions)

| Session | Files | Lessons folded | Commit |
|---|---|---|---|
| D1 | templates/implementation-prompt.md + templates/review-prompt.md | Sprint 31.92.6 FLAGGED canonical + F3 disposition + POLICY_TABLE precedent + Commit+Push standardization + 4 verdict combinations + Sprint 31.92 Self-Anchoring Pre-Flight | `062377d` |
| D2 | protocols/sprint-planning.md + templates/sprint-spec.md | Sprint 31.92.6 B1 cap methodology + Phase-D-time framing reconciliation + Pattern X/Y/Z/W taxonomy + Sprint 31.92.5 F.10/F.21 + Sprint 31.92 F.5/F.6/F.7/F.8 | `54a9198` |
| D3 | protocols/tier-3-review.md + protocols/adversarial-review.md + protocols/mid-sprint-doc-sync.md | Sprint 31.92 F.5/F.8 + Sprint 31.92.5 F.22 + Sprint 31.92.6 reframe-disposition + Pattern A/B formalization | `f21cfc3` (+ `dcb3ebf` Pattern A/B disambiguation note) |
| D4 | claude-workflow:protocols/in-flight-triage.md + claude-workflow:claude/rules/universal.md (symlinked from argus:.claude/rules/universal.md per D4 architectural discovery) | Sprint 31.92.6 FLAGGED in in-flight discipline + Level 3 MD5 byte-equality + Sprint 31.92.5 F.11 + RULE-040/RULE-038 amendments + NEW RULE-054 + RULE-055 | metarepo: `2a482dd`; argus submodule bump: `d36fa17e` |
| D5 | bootstrap-index.md + evolution-notes/synthesis-sprint-31.92.6.md (this file) | Bookkeeping closure + cross-amendment verification + synthesis narrative | (this commit) |

---

## Three Layers of Lessons Folded

### Sprint 31.92 RETRO-FOLD (campaign-close 2026-05-04)

Lessons sourced from `docs/sprint-campaign.md:2094`:

- **F.5 structural closure framing vs aggregate percentage claims** → folded into `protocols/tier-3-review.md` v1.2.0 § Verdict language (canonical structural-framing examples + aggregate-percentage avoidance guidance)
- **F.6 FAI completeness pattern with multi-tier defense in depth** → folded into `protocols/sprint-planning.md` v1.5.0 § FAI completeness (primary + secondary + tertiary tier discipline)
- **F.7 CL-6 deferral rationale via cross-layer test scope-shaping** → folded into `protocols/sprint-planning.md` v1.5.0 § Cross-layer test scope-shaping (deferral acceptance criteria; 2-per-sprint ceiling)
- **F.8 operator-override pattern with proportional in-sprint mitigation per Round 3 C-R3-1 borderline-class routing** → folded into `protocols/adversarial-review.md` v1.2.0 § Operator-override with proportional in-sprint mitigation
- **Self-Anchoring Pre-Flight architectural pattern** (validated through 7 direct-paste execution sessions) → folded into `templates/implementation-prompt.md` v1.7.0 § Pre-Flight Checks > Self-Anchoring Pre-Flight (canonical default methodology)
- **Standalone review-prompt artifact deprecation in favor of in-session `@reviewer` subagent pattern** → reflected in `templates/review-prompt.md` v1.4.0 framing (subagent-first usage)
- **Structural-anchor-grep audit pass during refresh-prompt authoring** per M-R2-5 finding → folded into `protocols/sprint-planning.md` v1.5.0 § Phase D mechanical pairwise file-overlap matrix

### Sprint 31.92.5 lessons (campaign-close 2026-05-06)

Lessons sourced from `docs/sprint-campaign.md:2096`:

- **F.10 sibling-parallel git-diff verification** → folded into `protocols/sprint-planning.md` v1.5.0 § Sibling-parallel git-diff verification (canonical pairwise diff check at session close)
- **F.11 forensic-attribution threshold** → folded into `protocols/in-flight-triage.md` v1.4.0 § F.11 forensic-attribution threshold (>3 close-outs OR >10 commits triggers dedicated diagnostic session)
- **F.21 mechanical pairwise file-overlap matrix as Phase C artifact** → folded into `protocols/sprint-planning.md` v1.5.0 § Mechanical pairwise file-overlap matrix (DEC-399 canonical adoption)
- **F.22 mid-sprint amendment timing** → folded into `protocols/mid-sprint-doc-sync.md` v1.1.0 § F.22 amendment timing discipline (pre-Phase-B / pre-Phase-D / mid-sprint-via-manifest decision tree)

### Sprint 31.92.6 NEW lessons (sealed 2026-05-10)

- **FLAGGED self-assessment canonical** → folded into `templates/implementation-prompt.md` v1.7.0 + `templates/review-prompt.md` v1.4.0 + `protocols/in-flight-triage.md` v1.4.0 + ARGUS `.claude/rules/universal.md` RULE-054
- **B1 cap re-baseline methodology** → folded into `protocols/sprint-planning.md` v1.5.0 § B1 cap re-baseline (forecast-driven vs structural-work-driven + Phase A takeaway)
- **Path-(a) reframe pattern** → folded into `protocols/tier-3-review.md` v1.2.0 § Reframe-disposition pattern (operator-agency at sprint-boundary)
- **Pattern X/Y/Z/W taxonomy** → folded into `templates/sprint-spec.md` v1.3.0 § Test Pattern Taxonomy
- **MD5 byte-equality discrimination methodology** → folded into ARGUS `.claude/rules/universal.md` RULE-055 + RULE-040 amendment (Level 3 canonical rigor)
- **POLICY_TABLE precedent class formalization** → folded into `templates/implementation-prompt.md` v1.7.0 § Constraints > POLICY_TABLE precedent class
- **F3 disposition flexibility (chore-isolate 58% dominance)** → folded into `templates/implementation-prompt.md` v1.7.0 § F3 disposition flexibility (3 disposition shapes; non-categorical)
- **4 verdict-self-assessment combinations + discriminator** → folded into `templates/review-prompt.md` v1.4.0 § Verdict Combinations
- **Phase-D-time spec-vs-implementation framing reconciliation** → folded into `protocols/sprint-planning.md` v1.5.0 § Phase-D-time spec-vs-implementation framing reconciliation
- **A8 cross-position serialization preservation chain methodology** → folded into `templates/implementation-prompt.md` v1.7.0 § Concurrency-sensitive session discipline (optional)
- **Commit+Push standardization** (operator's accumulated request) → folded into `templates/implementation-prompt.md` v1.7.0 § Commit + Push (canonical)
- **Reframe-disposition Pattern A/B formalization** → folded into `protocols/mid-sprint-doc-sync.md` v1.1.0 § Pattern A vs Pattern B disposition

---

## Cumulative Cross-References

The amended files now form a coherent cross-reference network:

- FLAGGED canonical: `templates/implementation-prompt.md` v1.7.0 (source)
  → `templates/review-prompt.md` v1.4.0 (verdict acceptance criteria)
  → `protocols/tier-3-review.md` v1.2.0 (reframe-disposition pattern)
  → `protocols/in-flight-triage.md` v1.4.0 (in-flight discipline)
  → ARGUS `.claude/rules/universal.md` RULE-054 (binding rule)
- Discrimination methodology: ARGUS `.claude/rules/universal.md` RULE-040
  (amended) + RULE-055 (new)
  → `protocols/in-flight-triage.md` v1.4.0 § Discrimination methodology
  canonical rigor levels (cross-reference)
- Pattern A vs Pattern B: `protocols/mid-sprint-doc-sync.md` v1.1.0
  (source)
  → `protocols/tier-3-review.md` v1.2.0 (reframe-disposition application)
- B1 cap methodology: `protocols/sprint-planning.md` v1.5.0 (source)
  → ARGUS `docs/process-evolution.md` § Sprint 31.92.6 (canonical narrative)

---

## Sprint 31.92.7 Readiness

With synthesis-sprint-31.92.6 sealed, Sprint 31.92.7 spec opening
conversation now reads against the amended metarepo state. Specifically:

- Sprint 31.92.7's Phase A planning uses `protocols/sprint-planning.md`
  v1.5.0 (B1 cap methodology + FAI completeness + Phase-D-time framing
  reconciliation + Mechanical pairwise file-overlap matrix as Phase C
  artifact)
- Sprint 31.92.7's impl prompts use `templates/implementation-prompt.md`
  v1.7.0 (Self-Anchoring Pre-Flight + FLAGGED canonical + POLICY_TABLE
  precedent class + Commit+Push standardization)
- Sprint 31.92.7's Tier 2 reviews use `templates/review-prompt.md` v1.4.0
  (Verdict Combinations canonical + Accepting FLAGGED self-assessment)

Sprint 31.92.7 spec opening starter prompt at
`/mnt/user-data/outputs/sprint-31.92.7-spec-opening-starter-prompt.md`
(authored by Sprint 31.92.6 Work Journal coordination layer; carry-
forward to operator's fresh Claude.ai conversation).

---

## Synthesis-sprint-31.92.6's Own Lessons (meta-observations)

### Verification regex strictness pattern (3 instances across this sprint)

Directive-authored verification greps systematically miss valid amendments
when:

1. Section headings are Title-Case but grep patterns are lowercase
2. Amendment text wraps across multiple lines but grep operates line-by-line

Resolutions seen during synthesis-sprint-31.92.6:

- D1: implementer added lowercase summary phrase to satisfy gate
- D3: implementer used case-insensitive grep (-i) for verification
- pre-D5 correction: false grep alarm; manual content inspection confirmed

**Recommendation for future directive authoring** (carry to next
metarepo synthesis): verification greps should default to case-insensitive
(`grep -ciE`) and prefer single-word distinctive markers over multi-word
phrases that may line-wrap. Alternatively, the directive can require the
implementer to produce a **lowercase canonical summary sentence** at
each amendment site as part of the amendment shape (this is what landed
naturally at D1).

---

## Annotated tag (OPTIONAL)

If operator wants a durable record of synthesis-sprint-31.92.6's seal:

```bash
cd /home/claude/workflow
git tag -a synthesis-sprint-31.92.6-sealed -m "synthesis-sprint-31.92.6 sealed 2026-05-10 — Sprint 31.92 + 31.92.5 + 31.92.6 RETRO-FOLD lessons folded; 8 metarepo files amended + 2 ARGUS RULEs + 1 new evolution-notes file"
git push origin synthesis-sprint-31.92.6-sealed
```

This is operator-discretion; the evolution-notes file itself is the
canonical durable record.
