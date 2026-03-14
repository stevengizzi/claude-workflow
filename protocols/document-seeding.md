<!-- workflow-version: 1.0.0 -->
<!-- last-updated: 2026-03-13 -->
# Protocol: Document Seeding

**Context:** Claude.ai conversation, immediately after Discovery completes
**Frequency:** Once per project, between Discovery and Sprint 1 planning
**Output:** Populated canon documents ready to serve as project knowledge

---

## When to Use

After the Discovery protocol produces its foundational DEC entries, RSK entries,
and confidence assessment — but before Sprint 1 planning begins. This protocol
transforms Discovery's raw outputs into the documentation structure that all
subsequent workflow conversations depend on.

**Why this step exists:** The Discovery protocol resolves unknowns and logs
decisions. Sprint Planning expects populated project knowledge documents to
already exist. Without Document Seeding, there is a gap where the developer
must manually create and populate 7+ documents from Discovery's output — an
error-prone step that risks inconsistency and incompleteness. This protocol
closes that gap.

## Prerequisites

1. Discovery protocol completed (Variant A or B)
2. Discovery outputs available:
   - Foundational DEC entries (with rationale)
   - RSK entries (with mitigations)
   - Stack/infrastructure decisions
   - Confidence assessment: "Ready to plan sprints"
3. Project manifesto or description exists (even informal — a few paragraphs
   describing what the project is, who it's for, and why it matters)
4. Repository scaffolded (via `scripts/scaffold.sh` or manual setup) with
   empty document templates in `docs/`

If the repository has NOT been scaffolded yet, do that first. The scaffold
creates the file structure and empty templates that this protocol populates.

---

## Conversation Structure

This is a single Claude.ai conversation. It takes Discovery's outputs as
input and produces populated documents as output. The conversation has three
phases.

### Phase 1: Gather Context

Provide Claude with:

1. **Discovery outputs** — paste or reference the DEC entries, RSK entries,
   and any decision documents produced during Discovery
2. **Project manifesto** — the informal description of what and why
3. **Scaffold templates** — the empty templates from `scaffold/docs/` so
   Claude knows the target structure (these are in the metarepo at
   `scaffold/docs/`)
4. **A mature example** (optional but recommended) — a populated
   `project-knowledge.md` from an existing project, to show the level of
   detail and structure expected at maturity

Ask Claude to read the scaffold templates and confirm it understands the
target document set:

    "I've completed Discovery for [project name]. Here are the outputs:
    [DEC entries, RSK entries, decisions, confidence assessment]

    Here is the project manifesto: [description]

    I need to populate the canon documents from the scaffold templates.
    The documents to produce are:
    1. project-knowledge.md (Tier A operational context)
    2. decision-log.md (all DECs from Discovery, with full rationale)
    3. dec-index.md (quick-reference table)
    4. risk-register.md (all RSKs from Discovery)
    5. architecture.md (technical blueprint — what is known so far)
    6. roadmap.md (strategic vision + initial sprint queue)
    7. sprint-history.md (empty but properly formatted)
    8. CLAUDE.md (Claude Code session context)

    Before generating anything, confirm: do you have enough context to
    populate each document, or do you need clarification on any section?"

### Phase 2: Generate Documents (Sequential)

Generate documents one at a time, using the Compaction-Resistant Protocol.
After each document: save it, confirm it's complete, then request the next.

**Generation order** (dependencies flow downward):

1. **decision-log.md** — First, because other documents reference DECs.
   Populate with all Discovery DECs using the decision-entry template format.
2. **dec-index.md** — Mechanical extraction from the decision log.
3. **risk-register.md** — Populate with all Discovery RSKs.
4. **architecture.md** — Fill in what is known from Discovery (stack, major
   components, planned structure). Mark unknown sections explicitly with
   "[To be determined during Sprint N]" rather than leaving them blank.
5. **roadmap.md** — Strategic vision from the manifesto + initial sprint
   queue derived from Discovery's scope analysis.
6. **project-knowledge.md** — The Tier A synthesis. This document references
   all the others and provides the dense operational context for Claude. It
   should be populated last because it draws from everything above.
7. **CLAUDE.md** — Claude Code session context. Derived from
   project-knowledge.md but optimized for implementation sessions.
8. **sprint-history.md** — Stays empty (no sprints yet) but should have the
   correct table headers and format ready.

**For each document, Claude should:**
- Start from the scaffold template structure
- Populate all sections that have content from Discovery
- Mark sections that will be filled during Sprint 1 or later with explicit
  placeholders (not blank — "[Pending Sprint 1]" or similar)
- Cross-reference DEC/RSK numbers where relevant
- Keep language dense and token-efficient (Tier A style for project-knowledge
  and CLAUDE.md; Tier B style for decision-log and architecture)

### Phase 3: Cross-Check

After all documents are generated:

    "Review all generated documents for:
    1. Numbering consistency — every DEC referenced in project-knowledge.md
       exists in decision-log.md and dec-index.md
    2. RSK consistency — every RSK referenced exists in risk-register.md
    3. Architecture alignment — tech stack in architecture.md matches
       stack decisions in the decision log
    4. Roadmap coherence — sprint queue in roadmap.md is achievable given
       the architecture and risk profile
    5. No orphaned references — no document references a DEC, RSK, or
       component that doesn't exist in the canon
    6. CLAUDE.md accuracy — session context reflects project-knowledge.md

    Flag any inconsistencies."

---

## Output Checklist

After this protocol completes, the developer should have:

- [ ] `docs/decision-log.md` — populated with Discovery DECs
- [ ] `docs/dec-index.md` — populated index table
- [ ] `docs/risk-register.md` — populated with Discovery RSKs
- [ ] `docs/architecture.md` — populated (partial is expected)
- [ ] `docs/roadmap.md` — populated with vision + initial sprint queue
- [ ] `docs/project-knowledge.md` — populated Tier A context
- [ ] `docs/sprint-history.md` — formatted, empty
- [ ] `CLAUDE.md` — populated Claude Code context

**Next steps:**
1. Copy the populated documents into the repo (replacing scaffold stubs)
2. Add `project-knowledge.md` to the Claude.ai project knowledge
3. Add `bootstrap-index.md` to the Claude.ai project knowledge (if not
   already present)
4. Commit: "Seed canon documents from Discovery outputs"
5. Proceed to Sprint 1 planning using the sprint-planning protocol

---

## Variant: Seeding Without Discovery

If the project has existing ideation (conversation transcripts, design docs,
informal notes) but has NOT been through a formal Discovery protocol, this
protocol can still be used. Replace "Discovery outputs" with whatever source
material exists. However:

- Claude should flag any foundational decisions that appear to be assumed
  rather than explicitly decided, and log them as DEC entries with
  "[Inferred from ideation — confirm before Sprint 1]" annotations
- Claude should note any risks that are implied but not explicitly
  acknowledged, and log them as RSK entries
- The confidence assessment at the end should include a recommendation
  on whether a formal Discovery conversation is still needed before
  Sprint 1, or whether the seeded documents provide sufficient foundation

This variant is appropriate for projects where the builder has domain
familiarity and wants to move quickly, but it carries higher risk of
unexamined assumptions making it into the foundation.

---

## Anti-Patterns

1. **Generating all documents in one shot.** Compaction risk. Sequential
   generation with saves between each document is mandatory.

2. **Leaving sections blank instead of marking them as pending.** A blank
   section is ambiguous — was it forgotten, or is it genuinely empty? Always
   use explicit placeholders.

3. **Over-populating architecture.md before Sprint 1.** Architecture should
   reflect what is *known and decided*, not what is *speculated*. If the
   data layer hasn't been designed yet, say so — don't guess.

4. **Copying the manifesto into project-knowledge.md verbatim.** The
   manifesto is narrative; project-knowledge.md is dense operational context.
   Transform, don't copy.

5. **Skipping the cross-check.** Inconsistencies introduced during seeding
   compound across every subsequent sprint. The cross-check is cheap; fixing
   downstream inconsistencies is expensive.
