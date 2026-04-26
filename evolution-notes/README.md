# Evolution Notes

Structured capture of what individual Claude.ai conversations contributed to the metarepo's protocols and templates. Each note is a single conversation's view — not a synthesis.

## Why this folder exists

The metarepo evolves through conversations. Each conversation invents, extends, or applies patterns. Without a capture step, the rationale for any given protocol change lives only in conversation history that's not durably queryable. Evolution notes are the audit trail.

They are **inputs**, not deliverables. A later synthesis conversation reads a batch of notes + any associated sprint close-outs + the current metarepo state, and produces a sprint package that actually updates the protocols. Evolution notes themselves don't change protocols.

## Workflow: Extract → Synthesize → Implement

1. **Extract** — at the end of a conversation that produced new patterns, write one evolution note per conversation to this folder. Commit immediately, while context is fresh.
2. **Synthesize** — after any real-world execution that validates or invalidates the patterns (e.g. a sprint that used them), open a fresh synthesis conversation. Feed it the relevant notes + execution evidence + current metarepo state. Output: a sprint package for metarepo updates.
3. **Implement** — execute the sprint package as a routine Claude Code sprint in this repo. Tag a new protocol version. Done.

## Synthesis Status Convention

When a synthesis sprint consumes one or more evolution notes, the synthesizing sprint's first session updates each consumed note with a one-line `**Synthesis status:**` header at the top of the note's metadata block (the section above the first body `---` separator). The format is:

```
**Synthesis status:** SYNTHESIZED in <sprint-name> (commit <SHA>). See <protocol-or-template-path>, ... for the resulting metarepo additions.
```

Where:
- `<sprint-name>` is the synthesizing sprint's identifier (e.g., `synthesis-2026-04-26`).
- `<commit <SHA>>` is the metarepo commit that landed the synthesis (the principal fold-in commit; subsequent normalization commits are not cited here).
- The reference to resulting metarepo additions points at the highest-level outputs (typically protocol files; not every modified line).

A note's status header has these possible values:

| Status | Meaning |
|---|---|
| (no header) | PENDING — note has not been consumed by any synthesis sprint |
| `SYNTHESIZED in <sprint> (commit <SHA>)` | Note consumed; metarepo additions landed at the cited commit |
| `SUPERSEDED by <new-note>` | A later evolution note replaces this one (rare; use only when the original captured a fundamentally different framing later refined) |
| `DEFERRED PENDING <condition>` | Note has been read by a synthesis sprint but explicit deferral happened (e.g., a candidate pattern was reviewed and deferred to next strategic check-in) |

The body of an evolution note is byte-frozen after capture. The metadata header is the only mutable part; status updates are additive metadata, not body edits.

<!-- Origin: synthesis-2026-04-26 (this sprint introduces the convention).
     The 3 evolution notes from 2026-04-21 are the first to receive a
     SYNTHESIZED status header; future synthesis sprints follow the same
     pattern. -->

## Template

Every note should follow the template at the top of any existing note (all notes share it). The required sections are:

- What this conversation produced
- Novel patterns introduced
- Patterns that already existed and got applied
- Decisions that were made implicitly but should be explicit
- What surprised us
- Open questions for synthesis
- What should NOT be codified

The last section is load-bearing: it protects the synthesis phase from over-generalizing one-off choices into universal rules.

## Naming

`YYYY-MM-DD-<short-name>.md` where short-name is a 2–3 word identifier for what the conversation was about. Multiple notes from the same day are fine — the short-name disambiguates.

## Status

A note is "pending synthesis" until a synthesis sprint package explicitly consumes it. There's no formal status tracking here; the synthesis conversation is responsible for identifying which notes it's drawing from.
