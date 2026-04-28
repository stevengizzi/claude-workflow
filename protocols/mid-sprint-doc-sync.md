<!-- workflow-version: 1.0.0 -->
<!-- last-updated: 2026-04-28 -->
# Protocol: Mid-Sprint Doc-Sync

**Context:** Claude Code session OR Claude.ai conversation, depending on the trigger.
**Frequency:** When triggered by a Tier 3 verdict surfacing materializable items, an impromptu hotfix changing DEF-table state, or a contradiction-discovery moment requiring spec/handoff updates mid-sprint.
**Output:** A `*-doc-sync-manifest.md` artifact in the sprint folder enumerating every file touched + every transition the sprint-close doc-sync still owes.

---

## When to use

A mid-sprint doc-sync runs when ALL of the following hold:

1. The sprint is in flight (not in close-out phase).
2. New documentation surfaces have appeared (DEF rows, DEC reservations, impl prompts, sprint-spec amendments, escalation criteria additions).
3. Those surfaces need to be live in the repo for subsequent sessions to consume them — i.e., deferring to sprint-close would block in-flight work.
4. The changes are forward-only with respect to the sprint's existing artifacts (no rewrite of completed-session closeouts; no DEC writes that would need to be rewritten at sprint-close).

Common triggers:

- **Tier 3 verdict surfacing materializable items.** Tier 3 surfaced DEFs that route into in-flight or upcoming sessions; CLAUDE.md needs the rows; impl prompts may need amendment; the work-journal-register needs new session order rows.
- **Impromptu hotfix changing DEF-table state.** An impromptu fix landed mid-sprint that resolves an existing DEF or files a new one; CLAUDE.md needs the transition.
- **Contradiction-discovery sync.** Mid-sprint discovery that the spec contradicts itself or contradicts implementation reality; spec amendments + DEF filings + work-journal-register updates needed.

## When NOT to use

A mid-sprint doc-sync should NOT run when:

- The change is just a session close-out + register refresh (use the standard per-session register discipline from `protocols/in-flight-triage.md`).
- The change requires writing a DEC entry whose full architectural narrative depends on subsequent sessions. **Defer DEC writes to sprint-close** unless the architectural narrative is genuinely complete at the mid-sprint moment.
- The change is large enough to warrant a sprint-close itself (in which case, close the sprint).

## Required output: the manifest

Every mid-sprint doc-sync produces a manifest at `docs/sprints/<sprint-name>/<descriptor>-doc-sync-manifest.md` (e.g., `pre-impromptu-doc-sync-manifest.md`, `tier-3-1-doc-sync-manifest.md`). The manifest is a **mechanical artifact** consumed by the sprint-close doc-sync. It is NOT a narrative — it is structured data.

The manifest must contain at minimum:

```markdown
# <Descriptor> Doc-Sync Manifest (Sprint <N>)

## Triggering event

(One paragraph: what caused this mid-sprint sync.)

## Files touched (with structural anchors, not line numbers)

| File | Change shape | Sprint-close transition owed |
|---|---|---|
| <path> | <e.g., "Added 9 DEF rows under 'Known issues' header"> | <e.g., "Each row's Status column transitions OPEN→RESOLVED at sprint-close"> |

## DECs the mid-sync DEFERRED to sprint-close

| DEC | Reason for deferral | Cross-reference text source for sprint-close |
|---|---|---|

## DEF transitions OWED at sprint-close

| DEF | Current status (this manifest) | Target status (sprint-close) | Source of resolution |
|---|---|---|---|

## Architecture / catalog freshness items DEFERRED to sprint-close

| Surface | Status | Action at sprint-close |
|---|---|---|

## Workflow version compliance

This manifest was produced under `protocols/mid-sprint-doc-sync.md` version <X.Y.Z>, introduced to the metarepo at commit `<sha>`. Sprint-close doc-sync MUST run under a metarepo state that includes this protocol version or higher (or explicitly disclose the discrepancy).

## Linked artifacts

- Triggering verdict / closeout: <path>
- Impl prompts produced (if any): <list>
- Other deliverables: <list>
```

## Sprint-close doc-sync MUST read all manifests

The sprint-close doc-sync prompt (typically generated from `templates/doc-sync-automation-prompt.md`) MUST, before applying any transitions:

1. List every file in the sprint folder matching `*-doc-sync-manifest.md`.
2. Read each in full.
3. Reconcile their claimed transitions against the actual sprint state (e.g., "DEF-217 manifest says transitions to RESOLVED-IN-SPRINT at Impromptu A close-out; verify Impromptu A landed CLEAR before applying the transition").
4. Apply transitions in manifest-listed order.
5. Skip any transition the manifest claims but the sprint state does NOT support.
6. Surface skipped transitions in the sprint-close output for operator attention.

## DEC-write discipline at mid-sprint syncs

DECs written at mid-sprint syncs are durable architectural decisions that must NOT need rewriting at sprint-close. Two valid patterns:

- **Pattern A (DEC fully describable now):** the architectural decision is complete at the mid-sync moment; cross-references all exist; the DEC has no forward-looking dependencies. Write at the mid-sync. Example: Tier 3 #1's DEC-386 (OCA architecture; Sessions 0+1a+1b+1c sealed; no forward-looking DEFs in DEC-386's narrative).
- **Pattern B (DEC depends on subsequent sessions):** the architectural decision references DEFs being resolved by subsequent sessions, OR the architectural narrative is incomplete at mid-sync. Defer to sprint-close. Manifest records the deferral. Example: Sprint 31.91's DEC-388 (cross-references DEFs being resolved in Impromptus A+B+C; defer to sprint-close).

When in doubt, defer.

## DEF status discipline at mid-sprint syncs

DEFs filed at mid-sprint syncs land in `OPEN` status with explicit routing text (e.g., "OPEN, routed to Impromptu A"). They do NOT land as `RESOLVED-IN-SPRINT` — that transition is owned by the sprint-close doc-sync after verification of the owning session/impromptu close-out.

The manifest is the canonical record of the OPEN→RESOLVED transition owed.

## Cross-reference discipline

Every artifact produced by a mid-sprint sync (verdict amendments, impl prompts, manifest itself) cross-references:

- The triggering event (verdict, closeout, contradiction discovery).
- The work-journal-register at the relevant version.
- The sprint-close doc-sync prompt template (so future readers know where the transitions land).

The work-journal-register is updated by the mid-sprint sync to include the new session order, DEF reservations, and DEC reservations. After the sync, the register is authoritative for the new sprint shape.

## Failure recovery

If a mid-sprint sync fails partway through:

1. The repo is in a partial-edit state. Use `git status` + `git diff` to inspect.
2. The manifest may be incomplete or absent. The sprint-close doc-sync will refuse to apply transitions for an unreadable manifest.
3. Recovery options: (a) finish the sync manually using the partial state as a starting point, (b) revert the partial-edit commit and re-run the prompt, or (c) declare the mid-sync failed and route the affected work as ad-hoc until sprint-close.

The mid-sync prompt should fail-stop on any verification mismatch (expected file content not found at structural anchor) rather than continuing into inconsistent state.

## Cross-references to other protocols

- `protocols/in-flight-triage.md`: per-session register discipline. The mid-sync protocol formalizes the *cross-session* version: when a single sync touches state across multiple sessions / impromptus.
- `protocols/sprint-planning.md`: sprint planning should reserve DEC numbers and anticipate possible mid-sync triggers.
- `protocols/tier-3-review.md`: Tier 3 verdicts that surface materializable items SHOULD produce a manifest under this protocol.
- `protocols/impromptu-triage.md`: impromptus that change DEF-table state SHOULD produce a manifest under this protocol.
- `templates/doc-sync-automation-prompt.md`: sprint-close doc-sync template MUST read manifests before applying transitions.
- `templates/work-journal-closeout.md`: sprint-close close-out generation MUST acknowledge manifest contents.

## History

This protocol was introduced at v1.0.0 in 2026-04-28 after Sprint 31.91 demonstrated the multi-sync pattern was real and recurring (Tier 3 #1 doc-sync, DEF-216 hotfix doc-sync, Tier 3 #2 doc-sync, sprint-close doc-sync — 4 syncs in one sprint). Prior to this protocol's introduction, the coordination was implicit and operator-tracked.
