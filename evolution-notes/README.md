# Evolution Notes

Structured capture of what individual Claude.ai conversations contributed to the metarepo's protocols and templates. Each note is a single conversation's view — not a synthesis.

## Why this folder exists

The metarepo evolves through conversations. Each conversation invents, extends, or applies patterns. Without a capture step, the rationale for any given protocol change lives only in conversation history that's not durably queryable. Evolution notes are the audit trail.

They are **inputs**, not deliverables. A later synthesis conversation reads a batch of notes + any associated sprint close-outs + the current metarepo state, and produces a sprint package that actually updates the protocols. Evolution notes themselves don't change protocols.

## Workflow: Extract → Synthesize → Implement

1. **Extract** — at the end of a conversation that produced new patterns, write one evolution note per conversation to this folder. Commit immediately, while context is fresh.
2. **Synthesize** — after any real-world execution that validates or invalidates the patterns (e.g. a sprint that used them), open a fresh synthesis conversation. Feed it the relevant notes + execution evidence + current metarepo state. Output: a sprint package for metarepo updates.
3. **Implement** — execute the sprint package as a routine Claude Code sprint in this repo. Tag a new protocol version. Done.

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
