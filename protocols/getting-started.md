<!-- workflow-version: 1.0.0 -->
<!-- last-updated: 2026-03-14 -->
# Protocol: Getting Started

**Context:** Claude.ai conversation — the very first conversation in a new project
**Frequency:** Once per project, before everything else
**Output:** A project ready to run Discovery, or (for simple projects) ready for Sprint 1

---

## When to Use

When someone starts a new Claude.ai project and asks how to begin. This protocol
assumes the user has no familiarity with the workflow system. It explains concepts
as it introduces them and guides the user through each step interactively.

This protocol is the entry point for new users. Everything else in the metarepo
is reached through this protocol or through the bootstrap-index.md routing table.

---

## How This Conversation Should Work

**Claude reads this protocol, then guides the user conversationally.** Do not
dump the entire protocol on the user. Instead, work through it step by step,
explaining each concept as it becomes relevant, asking questions to understand
the user's situation, and adapting the path based on their answers.

**Tone:** Patient, clear, practical. Assume the user is intelligent but
unfamiliar with this specific workflow. Avoid jargon until it's introduced.

---

## Step 1: Understand the Project

Start by understanding what the user is building. Ask:

1. **What is the project?** What does it do, who is it for, why does it matter?
2. **How much prior work exists?** Is this a brand new idea, or have they done
   ideation, research, prototyping, or had previous conversations about it?
3. **What is their technical background?** Can they code? In what languages?
   Have they used Claude Code before? Have they used git?
4. **What is their goal for this workflow?** Are they planning to use the full
   two-Claude architecture (Claude.ai for planning, Claude Code for
   implementation)? Or are they primarily using Claude.ai for planning and
   doing implementation themselves?

Based on their answers, determine the **project profile:**

- **Software project with Claude Code:** Full workflow applies — Discovery,
  scaffolding, sprint planning, autonomous runner, the works.
- **Software project without Claude Code:** Planning protocols and documentation
  system apply. Skip skills, agents, runner setup. Implementation prompts become
  task descriptions the user executes manually.
- **Non-software project:** Documentation discipline (decision log, risk register)
  and strategic protocols (discovery, check-ins) apply. Sprint planning adapts
  to the project's work units instead of code sessions.

> **Important:** The workflow adapts to the project, not the other way around.
> Not every project needs every protocol. The documentation system and decision
> logging are universal. Everything else is opt-in based on project needs.

---

## Step 2: Write the Project Manifesto

Every project needs a short description that answers: what is this, who is it
for, and why does it matter? This document becomes the anchor for every
subsequent conversation.

If the user already has prior conversations or notes, help them distill these
into a manifesto. If they're starting from scratch, interview them to produce
one.

**The manifesto should be:**
- 1-3 paragraphs (not longer)
- Written in the user's voice, not in formal documentation style
- Focused on goals and constraints, not technical details
- Honest about what they don't know yet

**Example structure:**
```
I'm building [what] for [who]. The goal is [why — what success looks like].

My constraints are: [budget, timeline, technical skill, hours available, etc.]

What I know: [prior decisions, chosen tools, domain expertise]
What I don't know: [open questions, areas of uncertainty]
```

Once the manifesto is written, the user should add it as a project knowledge
file in their Claude.ai project. Name it something descriptive (e.g.,
`project-manifesto.md` or `[project-name]-manifesto.md`).

---

## Step 3: Explain the Workflow System

Give the user a brief orientation. They don't need to understand everything
now — just enough to know what's coming.

**Key concepts to explain (briefly, conversationally):**

- **Decision Log (DEC entries):** Every significant choice gets logged with
  its rationale and alternatives rejected. This prevents future sessions from
  "fixing" deliberate tradeoffs. Think of it as a project journal that
  explains *why* things are the way they are.

- **Risk Register (RSK entries):** Known uncertainties and their mitigations.
  Things that could go wrong and what the plan is if they do.

- **Canon documents:** A small set of living documents that together describe
  the project's current state, architecture, decisions, and plans. These get
  updated after every sprint and serve as the shared context between
  conversations.

- **Discovery protocol:** A structured research phase before building begins.
  Prevents expensive pivots by surfacing unknowns early.

- **Sprint cycle:** Plan → implement → review → document. Each sprint has a
  clear scope, defined acceptance criteria, and a review process that catches
  regressions.

**If the user is using Claude Code, also explain:**
- **Two-Claude architecture:** Claude.ai (this interface) handles planning,
  design, and review. Claude Code handles implementation. Git bridges them.
  This separation means each session starts with full context and clear
  instructions.
- **Autonomous runner:** A Python orchestrator that can drive sprint execution
  automatically, running implementation and review sessions sequentially with
  safety checks between each.

**Do not explain:** Compaction risk scoring, Tier 2.5 triage, conformance
checks, structured close-out schemas, or other implementation details. These
are relevant during sprint planning, not during onboarding.

---

## Step 4: Determine Next Steps

Based on the project profile from Step 1:

### Path A: New Idea, Unfamiliar Domain
The user has an idea but hasn't done research or made foundational decisions.

**Next steps:**
1. Add the manifesto as project knowledge ✓ (done in Step 2)
2. Start a new conversation for Discovery (Variant B: Unfamiliar Domain)
3. After Discovery completes, start another new conversation for Document
   Seeding (which creates the canon documents from Discovery's outputs)
4. After Document Seeding, add the generated canon documents as project
   knowledge
5. Ready for Sprint 1 planning

### Path B: New Idea, Familiar Domain
The user knows the domain and has a clear technical direction.

**Next steps:**
1. Add the manifesto as project knowledge ✓ (done in Step 2)
2. Start a new conversation for Discovery (Variant A: Familiar Domain)
3. After Discovery completes, continue in the same conversation (or a new
   one) with Document Seeding
4. Add the generated canon documents as project knowledge
5. Ready for Sprint 1 planning

### Path C: Existing Ideation / Prior Conversations
The user has conversation transcripts, design docs, or notes from prior work.

**Next steps:**
1. Add the manifesto as project knowledge ✓ (done in Step 2)
2. Add prior conversation transcripts / documents as project knowledge
3. Start a new conversation for Document Seeding (Variant: Seeding Without
   Discovery) — Claude will extract decisions, risks, and architecture from
   the existing material
4. Claude will flag whether a formal Discovery conversation is still needed
5. Add the generated canon documents as project knowledge
6. Ready for Sprint 1 planning (or Discovery first, if recommended)

### Path D: Non-Software Project
The user is doing research, writing, business planning, or other non-code work.

**Next steps:**
1. Add the manifesto as project knowledge ✓ (done in Step 2)
2. Discuss which workflow elements apply to their project type:
   - Decision logging: almost certainly yes
   - Risk register: probably yes
   - Sprint planning: maybe — depends on whether their work decomposes into
     discrete deliverables
   - Code-related protocols: no
3. Run a lightweight Discovery focused on their domain's unknowns
4. Create a simplified version of the canon documents (project-knowledge.md,
   decision-log.md, and roadmap.md at minimum)
5. Establish a working rhythm that fits their project

---

## Step 5: Scaffold the Repository (Software Projects Only)

If the user is building software and using Claude Code, they need a repository
set up with the workflow's file structure. This step can happen now or after
Discovery — it doesn't depend on decisions.

**If they have an existing repo:** Guide them through the setup script:
```bash
# From the project repo root
git submodule add https://github.com/stevengizzi/claude-workflow.git workflow
./workflow/scripts/setup.sh .
```

**If they're starting a new repo:** Guide them through the scaffold script:
```bash
git clone https://github.com/stevengizzi/claude-workflow.git /tmp/workflow
/tmp/workflow/scripts/scaffold.sh /path/to/new-project project-name
```

This creates the full file structure: `docs/`, `.claude/skills/`, `.claude/agents/`,
`.claude/rules/`, `CLAUDE.md`, runner entry point, and empty document templates.

**If they're not using git or Claude Code:** Skip this step entirely. The canon
documents can live anywhere — in the Claude.ai project knowledge, in a shared
folder, wherever the user keeps their project files.

---

## Step 6: Route to the Next Protocol

End the conversation by clearly stating what to do next and in what order.
Be specific about which protocol to read and how to start the next conversation.

Example:

> "Your project is set up. Here's what to do next:
>
> 1. **Next conversation:** Start a new conversation and say: 'I'm ready to run
>    the Discovery protocol for [project name]. My domain familiarity is [HIGH/
>    MEDIUM/LOW].' Claude will clone the metarepo and walk you through it.
>
> 2. **After Discovery:** Start another new conversation and say: 'I've completed
>    Discovery for [project name]. I'm ready to run the Document Seeding protocol
>    to create the canon documents.' Bring the Discovery outputs with you.
>
> 3. **After Document Seeding:** Add the generated documents to your project
>    knowledge, then you're ready for Sprint 1 planning."

---

## Anti-Patterns

1. **Trying to do everything in one conversation.** Getting Started, Discovery,
   Document Seeding, and Sprint 1 planning should be separate conversations.
   Long conversations lose context.

2. **Skipping the manifesto.** Without a manifesto, Discovery has nothing to
   anchor on and Claude has to guess what the project is about.

3. **Over-engineering the setup for simple projects.** A weekend side project
   doesn't need a risk register. Scale the workflow to the project, not vice
   versa.

4. **Starting implementation before Discovery.** The temptation to "just start
   coding" is strong. Discovery prevents the expensive pivots that result from
   building on unvalidated assumptions.
