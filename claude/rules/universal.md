# Universal Rules - Cross-Project Rule Library
# Loaded into .claude/rules/ for every project.
# Source: Empirical patterns from ARGUS (65 convos, 21 sprints), MuseFlow (11 convos, 4 sprints), Grove (11 convos, 6 phases).
# Version: 1.2

---

## Section Index

| § | Section | RULEs |
|---|---|---|
| 1 | Prompt Adherence | RULE-001 through RULE-005 |
| 2 | Scope Discipline | RULE-006 through RULE-009 |
| 3 | Review Compliance | RULE-010 through RULE-013 |
| 4 | Documentation Integrity | RULE-014 through RULE-018 |
| 5 | Codebase Hygiene | RULE-019 through RULE-024 |
| 6 | Compaction Defense | RULE-025 through RULE-029 |
| 7 | Diagnostic Protocol | RULE-030 through RULE-033 |
| 8 | Research and Infrastructure | RULE-034 through RULE-037 |
| 9 | Session-Start Verification | RULE-038, RULE-039 |
| 10 | Empirical Evidence Discipline | RULE-040 |
| 11 | Flake Discipline | RULE-041 |
| 12 | Anti-Patterns in Code | RULE-042, RULE-043 |
| 13 | Test Discipline | RULE-044 through RULE-048 |
| 14 | Repath + Mechanical Migration Hazards | RULE-049 |
| 15 | CI Verification Discipline | RULE-050, RULE-052 |
| 16 | Fix Validation | RULE-051 |
| 17 | Architectural-Seal Verification | RULE-053 |
| 18 | Self-Assessment Categories | RULE-054 |
| 19 | Discrimination Methodology | RULE-055 |
| 20 | Phase A API-Surface Verification | RULE-056 |
| 21 | Round-N+1 Verdict-Text Completeness Audit | RULE-057 |

<!-- The non-monotonic RULE-NN order across §15/§16/§17 is intentional: sections are organized topically. RULE-051 lands in Fix Validation (§16), RULE-052 lands in CI Verification (§15) alongside RULE-050. Use this index to find a RULE by number. -->

---

## 1. Prompt Adherence

RULE-001: Execute exactly what the implementation prompt specifies. Do not add features, refactor adjacent code, or "improve" things outside the stated scope. If the prompt says "modify function Y in file X," that is the boundary.

RULE-002: If current code behavior appears to conflict with the prompt intent, flag it -- do not rationalize it as "intended design." (Grove: Claude Code rationalized a broken save button as intended; it was a bug. This pattern recurred across projects.)

RULE-003: Read every file listed in the prompt file-read section before writing any code. Do not infer interfaces from memory or assumptions. (ARGUS: "Read these files first, then implement" was the single most reliable prompt pattern.)

RULE-004: Respect all "do not modify" and "do not break" constraints explicitly. If the prompt lists files or behaviors to preserve, treat violations as blocking errors, not warnings. (Grove: An audio analysis session clobbered a FLAC artwork fix because no boundary was set; after boundaries were added, regressions dropped to near zero.)

RULE-005: When the prompt includes a "Definition of Done" or gate-check section, complete every item before considering the session finished. Do not self-assess as complete if any verification step is untested.

---

## 2. Scope Discipline

RULE-006: One session, one objective. If a task has multiple independent concerns, they should be separate sessions. Do not combine unrelated fixes into a single session. (Grove: Every task that completed cleanly had a single well-defined objective. Every task that sprawled started with too broad a scope.)

RULE-007: If you discover a bug or improvement opportunity outside your current scope, document it in the close-out report under "Deferred Items" -- do not fix it now. Scope expansion mid-session is the primary driver of regressions. (ARGUS: Sprint sub-numbering emerged because scope-expanded sessions created review chaos.)

RULE-008: If the first approach to a problem fails, do not attempt more than one additional approach in the same session without explicit user approval. Uncontrolled retries compound context consumption and increase regression risk.

RULE-009: For prompts that list multiple tasks (e.g., "fix bugs A, B, C"), complete and verify each task fully before starting the next. Do not interleave work across tasks.

---

## 3. Review Compliance

RULE-010: Never skip the close-out protocol. It is the final act of every implementation session. Complete the full structured report: change manifest, judgment calls, scope verification, regression checks, test results, self-assessment (CLEAN / MINOR_DEVIATIONS / FLAGGED).

RULE-011: Self-assessment must be honest. If you deviated from spec, mark MINOR_DEVIATIONS or FLAGGED and explain what changed and why. Do not mark CLEAN if any scope item was skipped, modified, or reinterpreted. (Cross-project: rationalization of deviations as "improvements" was the most common review failure.)

RULE-012: If the Tier 2 review prompt is provided, do not modify it. The review prompt was pre-generated during sprint planning to match the implementation spec. Altering it defeats the purpose of independent review.

RULE-013: During Tier 2 review (reviewer agent or fresh session), operate in read-only mode. Analyze the diff, compare to spec, produce a verdict. Do not fix anything -- only report.

---

## 4. Documentation Integrity

RULE-014: When the implementation prompt includes a doc-update checklist, complete all doc updates in the same session as the code changes. Do not defer documentation to a later session. (MuseFlow: doc sync consumed ~15-20% of Claude.ai conversation time because updates were batched rather than immediate. Grove: 5 days of deferred updates produced duplicate DEC numbers and stale descriptions across documents.)

RULE-015: When adding a decision log entry, verify the current highest DEC number in the log before assigning a new one. Do not assume or guess the next number. Duplicate DEC numbers create cross-reference failures.

RULE-016: When updating one document that references content in other documents (e.g., import pipeline order, architecture decisions), verify that all related documents are consistent. If you update the pipeline order in architecture.md, check that CLAUDE.md and the sprint plan reflect the same order.

RULE-017: Decision log entries must include: the decision, the rationale, alternatives considered (if any), and the scope of impact. A DEC entry that only states "we decided X" without rationale is incomplete.

RULE-018: Do not modify Project Knowledge files or Claude.ai-managed documents from Claude Code unless explicitly instructed. The source of truth for planning-layer docs is Claude.ai; Claude Code owns code and code-adjacent docs (.claude/*, README, inline docs).

---

## 5. Codebase Hygiene

RULE-019: Every implementation session must end with all tests passing. If a new test fails, fix it before closing out. If an existing test breaks, that is a regression -- flag it in the close-out report, do not delete or skip the test.

RULE-020: When the prompt specifies a target test count (e.g., "should end at ~X tests"), verify the actual count before closing out. Report the delta if it differs.

RULE-021: Use explicit, descriptive names for all new functions, variables, classes, and files. Follow the project existing naming conventions. If no convention exists, prefer verbose clarity over brevity.

RULE-022: Do not introduce new dependencies without explicit approval in the implementation prompt. If a library would significantly simplify the implementation, flag it in the close-out report as a recommendation -- do not install it.

RULE-023: Commit messages should reference the sprint/session identifier and summarize what changed. Format: [Sprint X / Session Y] Brief description of changes. If the project uses a different commit convention, follow that instead.

RULE-024: When modifying a component that has been the source of prior regressions (check the decision log or risk register), add extra caution: re-run all related tests, verify the specific behaviors listed in "do not break" sections, and flag the component as high-risk in the close-out report. (Grove: RecordingEditPanel.svelte was modified across 8+ sessions and regressed at least twice.)

---

## 6. Compaction Defense

RULE-025: Prefer short, focused sessions over long marathons. If a task is estimated at more than ~45 minutes of active work or touches more than 3 files substantially, it should likely be split into multiple sessions. (Grove: 5-compaction marathon sessions produced more regressions than progress. ARGUS: Sessions exceeding context produced the worst regression rates.)

RULE-026: Front-load file reads. Read all relevant files at the start of the session before making any changes. Do not defer reads to "when needed" -- by the time you need them, earlier context may have been compacted.

RULE-027: If you notice your context becoming large (many files read, many changes made, long conversation history), proactively checkpoint: commit current work, run tests, produce a partial close-out, and suggest continuing in a fresh session. Do not push through -- compaction-induced regressions cost more than the overhead of a session split.

RULE-028: When producing a close-out report, include a "Context State" field: GREEN (session completed well within context limits), YELLOW (session was long, context may be compressed), or RED (session hit compaction, outputs should be verified independently). This gives the review layer a signal about report reliability.

RULE-029: At the start of every session, re-read the implementation prompt in full even if it was provided earlier in the conversation. Do not rely on your summary of it -- the original wording contains constraints that summaries drop.

---

## 7. Diagnostic Protocol

RULE-030: After two failed attempts to fix the same bug, stop attempting fixes. Switch to diagnostic-first mode: build a standalone test or script that reproduces the bug in isolation, outside the application code. Only after the root cause is confirmed should you modify application code. (Grove DEC-022: diagnostic-first had 100% success rate vs. ~33% for ad-hoc fixes. This pattern held across all three projects.)

RULE-031: When entering diagnostic mode, document what was already tried and why it failed before designing the diagnostic test. This prevents the diagnostic from re-testing approaches already known to fail. (Grove: FLAC artwork saga consumed 6+ iterations because each session did not know what previous sessions had tried.)

RULE-032: The diagnostic test must be minimal -- isolate the exact behavior under investigation. Do not build a comprehensive test suite at this stage. The goal is a binary signal: does the API/function/behavior work as expected, yes or no?

RULE-033: After a successful diagnostic leads to a fix, add a regression test for the specific failure mode before closing out the session. The regression test ensures the bug cannot silently return.

---

## 8. Research and Infrastructure

RULE-034: Do not build on provisional infrastructure. If the implementation depends on an external service, library, or data source that has not been validated for the project actual requirements, flag this as a blocker. (ARGUS: Building 10 sprints on Alpaca before discovering Databento was the right choice wasted significant effort.)

RULE-035: If the implementation prompt references an API, service, or library you have not used before in this project, read its documentation or source before implementing against it. Do not guess at interfaces.

RULE-036: When performance is relevant (data processing, API calls, rendering), include performance benchmarks in your verification. "It works" is insufficient if it takes 100x longer than acceptable. (ARGUS Sprint 8: VectorBT implementation used iterrows() and took 4+ hours; the spec had not included performance gates.)

RULE-037: Before relaunching any long-running background command that appears stuck or produces incomplete output, verify the original process is no longer running. Use `pgrep -fl <command>` to check; use `pkill -f <command> && sleep 2` to clean up. Never accumulate duplicate background processes — doing so degrades system performance, produces overlapping partial output, and can corrupt timing-sensitive tests. The correct sequence is always: kill → diagnose → fix → relaunch. (ARGUS Sprint 32.9: repeated pytest relaunches on a hanging async test accumulated 4 concurrent processes, degrading the subsequent full-suite run from ~49s to ~178s.)

---

## 9. Session-Start Verification

RULE-038: At the start of every session, grep-verify every factual claim the prompt makes against the current state of the codebase before acting on it. This applies in at least four variants:

- **File paths.** If the prompt says "edit `src/foo/bar.py:142`," confirm the file exists at that path and the line number still matches. Handoff docs, planning trackers, and kickoff specs routinely drift from source as commits land between authoring and execution.
- **Grep-observable claims.** If the prompt cites a count (e.g., "9 `@patch` decorators in `test_x.py`", "unused import `Foo`"), re-grep before applying the suggested fix. The observation may no longer hold.
- **Metric values.** If the prompt cites a measured metric (coverage %, LOC count, warning count, file count, test count), re-measure at session start and treat the re-measurement as authoritative. Audit values are directional flags, not ground truth.
- **Tracker nicknames vs filenames.** Planning trackers often label sessions by thematic nickname ("frontend, solo") while the actual spec file is named for its scope ("experiments-and-learning-loop"). Before drafting a kickoff or acting on a tracker entry, grep the actual spec filename.
- **Kickoff statistics in close-outs.** Closeouts should explicitly disclose any kickoff-vs-actual discrepancies with attribution rather than quietly conform to the kickoff's stated numbers. Treating kickoff statistics as directional input requiring grep-verification is RULE-038's session-start posture; surfacing discrepancies in the closeout is the disclosure follow-through. Don't propagate a wrong number from kickoff to summary just because the kickoff said it.

When the re-verification disagrees with the prompt, mark the finding as RESOLVED-VERIFIED (if the fix already appears to be in place) or flag the discrepancy in the close-out — do not invent a fix for a claim that no longer holds.

**Amended 2026-05-10 (Sprint 31.92.6)**: when impl-prompt narrative references symbols that diverge from grep-verified production reality (e.g., endpoint name `/audit` canonical vs `/details` speculative; Health-endpoint surface lacks expected fields), the implementer aligns to grep-verified canonical reality and discloses the divergence in close-out under MINOR_DEVIATIONS self-assessment. Disclosure may include carry-forward routing to successor sprint when the divergence has architectural implications. Canonical examples: Sprint 31.92.6 S5a-2's 2 RULE-038 disclosures.

<!-- Origin: Sprint 31.9 retro, P6 + P12 + P13 + P19 + P22 + synthesis-2026-04-26 P28 (consolidated).
     Evidence: FIX-04/06/07 hit repeated spec-path drift (CSV-garbled line drifts;
     Finding 17 pointed at position_sizer.py but the real site was
     quality_engine.py). FIX-13c re-measured AI module coverage and found 3 of 4
     modules worse than the audit claimed (prompts 56% vs 63%). The audit-count
     pattern also hit F22/F24 in FIX-13a where "9 @patch decorators" and "unused
     AfternoonMomentumStrategy import" had both gone stale between audit and
     session. Stage 6 was tracker-nicknamed "frontend, solo" but FIX-08's actual
     scope was backend-only. Evidence for P28: SPRINT-CLOSE-A-closeout.md §1
     corrected the kickoff's "24 closed DEFs" figure to the grep-verified 19
     (5 of the 24 — DEF-152/153/154/158/161 — were closed by earlier campaign
     sessions before IMPROMPTU-04 anchored the campaign-close window); the
     implementer flagged the discrepancy in closeout via grep-verify rather
     than silent conformance. -->

RULE-039: When the prompt describes a risky batch edit (large file refactor, multi-site rename, cross-file move), stage the work as: (1) read-only exploration, (2) structured findings report with the concrete change list, (3) halt, (4) operator confirms the list, (5) edit. The in-session report + halt is the mechanism that makes the final edit pass surgical. Skipping the report step collapses risky edits into guess-and-check and has caught out multiple sessions.

<!-- Origin: Sprint 31.9 retro, P5. Codifies the "scoping-before-fix" variant
     that emerged from impromptu-triage work on 2026-04-21, and matches how
     the pre-edit verification step in the RETRO-FOLD campaign's Prompt 1
     chore caught 3 errors before any edit ran. -->

---

## 10. Empirical Evidence Discipline

RULE-040: Small-sample sweep conclusions are directional only. Benchmarks, A/B comparisons, performance measurements, or optimization sweeps run over small samples (few symbols, few seeds, few runs, few trials) point at which direction the needle moves — they do not establish production-ready decisions. Before promoting any "winner" from a small sample, either (a) run the full-scale confirmation sweep, or (b) document explicitly that the decision is provisional and name the validation sprint that will resolve it.

**Amended 2026-05-10 (Sprint 31.92.6 S5a-1) — discrimination cycle methodology canonical rigor levels:** tests-only sessions (sessions that author/amend tests without modifying production code) require **discrimination verification** to prove the new tests aren't vacuously passing. Three rigor levels canonical:

- **Level 1 — `git diff` empty assertion**: minimum-viable; production code unchanged per `git diff --stat <predecessor>..HEAD -- 'argus/' 'scripts/'` empty.
- **Level 2 — discrimination cycle**: comment out production code emission/dispatch → verify test FAILS → restore → verify test PASSES.
- **Level 3 — MD5 byte-equality** (NEW canonical per Sprint 31.92.6 S5a-1): in addition to Level 2, capture MD5 of production code byte-for-byte before/after the discrimination cycle; verify identical. Required for sessions touching safety-critical paths (DEF-204 family; bracket OCA group threading; SELL emit choke point; reconciliation contract; alert observability subsystem). Canonical example: Sprint 31.92.6 S5a-1 discrimination cycle on `argus/execution/order_manager.py:9742-9766`.

Session prompts requiring Level 3 should explicitly cite "RULE-040 Level 3" in their constraints section. RULE-055 codifies the Level 3 MD5 byte-equality procedure in detail.

<!-- Origin: Sprint 31.9 retro, P7. Concrete example: ARGUS's 24-symbol
     momentum sweep in April 2026 found 2 qualifying variants, but operators
     interpreting the sweep could have over-read those specific symbols as
     universal. The same anti-pattern shows up in coverage sweeps, micro-
     benchmarks, and any "we ran it twice and picked the faster one" flow.
     Amended 2026-05-10 per Sprint 31.92.6 S5a-1 to extend "discrimination"
     scope from small-sample-sweep discipline to tests-only-session
     production-code-preservation discipline. Both share the falsifiability
     posture: prove the signal isn't sampling noise (sweep case) or vacuous
     test pass (tests-only case). -->

---

## 11. Flake Discipline

RULE-041: Any new CI flake must be assigned a DEF (or equivalent deferred-item) number immediately upon first observation, with at minimum: the symptom, the test name, the observed environment (xdist worker, OS, CI run URL), and a reproduction hint. Do not mark a flaky test as "transient" or "unrelated" without a DEF entry. Once the DEF catalog is complete, zero-tolerance on flakes becomes enforceable — any red CI run is a real bug until proven otherwise. Without catalog completeness, real regressions hide inside the "known flake" category.

<!-- Origin: Sprint 31.9 retro, P8. Earned during the campaign's push to
     first-green-CI milestone at commit 793d4fd on 2026-04-22: the cleanup
     only held because every remaining intermittent failure had a DEF number
     with a per-item mitigation (DEF-150/167/171/190/192). -->

---

## 12. Anti-Patterns in Code

RULE-042: `getattr(obj, "field", default)` on a value of known type is a silent-default anti-pattern. The default hides bugs when the attribute name is wrong or the caller is passing a different type than expected — the lookup succeeds against the fallback and the caller sees a benign value (often 0 or None) instead of an exception. Prefer `obj.field` when the type is known; narrow the type (`isinstance` guard) before attribute access when the type is ambiguous. This applies equally to `dict.get(key, default)` when the key is load-bearing (a missing key should raise, not silently evaluate to the default).

<!-- Origin: Sprint 31.9 retro, P9. Concrete example: ARGUS DEF-139/140
     ("startup zombie flatten queue") was caused by four Order Manager call
     sites that read `getattr(pos, "qty", 0)` on a Position object; Position
     uses the field name `shares`, so every call silently returned 0 and the
     flatten reported "positions closed" while the broker retained them.
     DEF-199's root cause included the same family — and the grep-audit that
     FIX-04 ran found the pattern in multiple additional sites. Note: the
     `dict.get(key, default)` extension in the rule body is a same-shape
     generalization (both idioms return a benign default on lookup failure),
     hedged by "when the key is load-bearing." The dict.get case has no
     direct campaign origin evidence — ground it with concrete evidence when
     a future sprint surfaces a `dict.get`-default bug of the same class. -->

RULE-043: `except Exception:` blocks in test code can silently swallow `pytest.fail()`, `assert` failures, and other test-framework signals — turning a regression guard into a tautology. When writing or reviewing tests, narrow each catch to the specific expected exception type. When modifying existing tests that use broad catches, verify that no `pytest.fail(...)`, `assert`, or raise-on-condition was relying on propagation.

<!-- Origin: Sprint 31.9 retro, P17. Concrete example: F19 in FIX-13a found
     `tests/api/test_observatory_ws.py` had been passing since Sprint 25 not
     because the route-disabled behavior was correct, but because the broad
     `except Exception: pass` around the assertions had been quietly
     discarding the explicit `pytest.fail()` call for roughly six months. -->

---

## 13. Test Discipline

RULE-044: When closing a DEF on a test whose failure mode is time-of-day-bounded, timezone-dependent, or otherwise windowed, the closure requires evidence from inside the failing window — or an explicit argument for why the window no longer exists. A single green run from outside the window is not sufficient; the Python-side fix may not exercise the SQL-side comparator, or the CI runner's UTC clock may be outside the ET/local divergence window that triggered the flake.

<!-- Origin: Sprint 31.9 retro, P14. Concrete example: DEF-163's FIX-05
     strikethrough was premature — the Python-side fix didn't exercise the
     SQL-side `date()` comparator, and the test's failure mode was a ~4h
     daily window. IMPROMPTU-03 reopened it and added in-window CI
     regression evidence. -->

RULE-045: Timezone-sensitive tests must derive "today" / "now" the same way the implementation does. If the implementation uses `datetime.now(tz=_ET).date()`, the test must compare against an ET-derived date — never `datetime.date.today()` (local tz) or `datetime.now(UTC).date()`. Three further sub-rules prevent the recurring ET-vs-UTC flake family:

- Avoid `datetime.now(...)` for synthetic test fixture timestamps. Use fixed wall-clock anchors (e.g., 15:00 ET) so the test is deterministic across runners.
- If a test must mock "now," mock it explicitly (e.g., `freeze_time`, `patch('module.datetime')`) rather than letting wall-clock variation drive the assertion.
- On UTC-only CI runners (GitHub Actions Linux), audit any `datetime.now()` / `date.today()` call in a test for implicit local-tz assumptions.

<!-- Origin: Sprint 31.9 retro, P15. Evidence: DEF-163 (SQLite `date()`
     UTC-normalization vs `today_et`), DEF-188 (`datetime.now(tz=_ET).date()`
     vs `datetime.date.today()` on UTC CI runner), and DEF-167 (Vitest
     hardcoded-date decay) all shared the shape — implementation and test
     derived "today" from different sources, or fixed wall-clock anchors
     were used where relative dates drifted. All three were resolved in
     ARGUS Sprint 31.9 (IMPROMPTU-03 + FIX-13a). -->

RULE-046: Do not give non-test classes a `Test*` prefix in a pytest project. Pytest will attempt to collect the class as a test; if the class has an `__init__`, collection will warn (`PytestCollectionWarning: cannot collect test class 'X' because it has a __init__ constructor`). If rename is impossible due to API stability, add `__test__ = False` as a class attribute so pytest skips collection silently.

<!-- Origin: Sprint 31.9 retro, P16. Concrete example: a `TestBaseline`
     Pydantic model in ARGUS's sprint_runner triggered this warning until
     the class attribute was added. -->

RULE-047: Test-only sessions that exercise optional runtime dependencies must mock those dependencies at the `sys.modules` level rather than relying on local environment availability. If the test triggers a lazy `from foo import Bar` that the local dev environment supplies (pip-installed during unrelated work), the test will pass locally but fail in CI where the optional package is not in any dependency group. Use `monkeypatch.setitem(sys.modules, "foo", fake_or_None)` — setting `None` is the canonical way to force the ImportError branch in the code under test.

<!-- Origin: Sprint 31.9 retro, P24. Concrete example: FIX-13c's
     `test_get_client_caches_instance` exercised a lazy `from anthropic import
     AsyncAnthropic`. Locally the test passed because pre-draft coverage
     measurement had pip-installed anthropic; on CI (where anthropic is a
     pure runtime optional, not in any `[project.dependencies]` group) the
     import raised and the test failed. Cross-reference the sibling test
     `test_get_client_raises_importerror_when_anthropic_missing`, which uses
     this pattern correctly. -->

RULE-048: Before relying on a library-behavior side-effect suggested by a kickoff ("just import X and the extension registers"), verify by observation that the side-effect actually fires. Library registration is frequently lazy and runs on first real use, not at import. Trace the behavior under `python -X tracemalloc`, inspect the library source, or add a test that captures the registered state, before accepting a bare-import fix.

<!-- Origin: Sprint 31.9 retro, P18. Concrete example: FIX-13a's DEF-190
     kickoff said "conftest.py-level eager pyarrow import." But `import
     pyarrow` does NOT trigger `register_extension_type` — pyarrow's
     extension registration is lazy and runs on first DataFrame→Arrow
     conversion. The fix had to be strengthened to a forcing function:
     `pd.DataFrame({period_col}) → pa.Table.from_pandas(df)`. -->

---

## 14. Repath + Mechanical Migration Hazards

RULE-049: When a kickoff proposes a `git mv` that changes the directory depth of test files, pre-grep for `parents[N]` path-literal call sites in the moved files and enumerate the expected fix-count in the kickoff. Depth changes silently break `Path(__file__).parents[N] / "fixtures"` idioms, and the breakage only surfaces when the affected tests run. The pre-grep gives the session a check against its own work: if the kickoff says "expect 4 sites to fix," a session that finds only 3 knows to keep looking.

Grep pattern: `grep -rn 'parents\[[0-9]\]' {files-being-moved}`.

<!-- Origin: Sprint 31.9 retro, P21. Concrete example: FIX-13b's F11
     reparented integration test files into a deeper subpackage; 4 path-
     literal sites had to be updated (1 in test_core.py, 3 in
     test_sprint329.py). The kickoff flagged the hazard generically but
     didn't specify a count, so there was no signal if a site was missed. -->

---

## 15. CI Verification Discipline

RULE-050: A session is not complete until CI verifies green on the session's final commit (or the barrier commit, for bundled sessions). Each session's close-out MUST cite a green CI run link, and the Tier 2 reviewer MUST verify CI status as part of the checklist — not merely local pytest. Without this, a red CI state can persist invisibly across multiple sessions because newer pushes cancel older in-flight runs on most CI providers.

Operationally this implies:
- Do not push commits faster than CI can complete a run (typical: ~4 minutes). If a push must go out before the previous CI run finishes, explicitly wait for green before starting the next session.
- A `pytest-timeout` (or equivalent per-test timeout) partially defends this class of regression by converting hangs into per-test failures with tracebacks. It does NOT catch non-hang regressions that complete within the timeout budget.
- If the test baseline changed between two sessions and no one saw a green CI run in between, treat the intervening state as unknown and run a dedicated verification CI.

<!-- Origin: Sprint 31.9 retro, P25. Evidence: six commits accumulated
     between FIX-13a (c9c8891) and FIX-13c hotfix (ffcfb5c) without anyone
     confirming CI passed. Each push cancelled its predecessor; the FIX-13a
     test-timeout regression stayed hidden across FIX-13b (7 commits), Stage
     8 Wave 2 barrier, FIX-13c (3 commits), and Stage 8 Wave 3 barrier —
     unmasked only when the FIX-13c anthropic ImportError happened to fail
     fast enough to produce visible output. -->

RULE-052: When CI turns red for a known cosmetic reason, explicitly log that assumption at each subsequent commit rather than treating it as silent ambient noise. The test is: "if a genuine regression slipped in, would I still notice?" CI-discipline drift on a known-cosmetic red can mask a real regression for the duration of the streak; without per-commit acknowledgment, the cosmetic-status assumption hardens into ambient noise. Operationally: each commit that pushes onto a red-CI baseline must include in its message body a one-line assertion of the cosmetic cause + a verification grep that the cosmetic cause hasn't shifted.

<!-- Origin: synthesis-2026-04-26 P27. Evidence: Sprint 31.9's 6-commit
     CI-red streak between Apr 22 and Apr 24 was correctly diagnosed as
     cosmetic (DEF-205 date-decay) but had masked any potential real
     regression for ~24 hours because each subsequent commit treated the
     red status as ambient. TEST-HYGIENE-01 closed DEF-205 and restored
     the 5,080 baseline; the streak was retrospectively confirmed cosmetic-
     only, but the period of unverified status was a real risk window. -->

---

## 16. Fix Validation

RULE-051: When validating a fix against a recurring symptom, verify against the mechanism signature (e.g., a measurable doubling ratio, a specific log-line correlation, a checksum), not the symptom aggregate (e.g., "the bug appears at EOD"). The mechanism signature is the falsifiable part; the symptom aggregate is the dependent variable. Any fix-validation session should explicitly identify the mechanism signature before running the validation. If the mechanism signature was preserved across debrief docs, a recurring symptom can be correctly attributed to a NEW mechanism rather than misattributed as the previous bug regressing.

<!-- Origin: synthesis-2026-04-26 P26. Evidence: ARGUS Apr 24 paper-session
     debrief preserved the 2.00× math from the DEF-199 fix validation
     (yesterday's mechanism signature). When 44 unexpected shorts surfaced
     today, the 1.00× ratio (set-equality, not 2× doubling) discriminated
     DEF-199 (closed) from DEF-204 (new mechanism: bracket children without
     OCA + side-blind reconciliation). Without the preserved mechanism
     signature, today's cascade would have been misattributed as a
     DEF-199 regression and IMPROMPTU-04 would have been incorrectly
     reopened. Captured in IMPROMPTU-11-mechanism-diagnostic.md
     §Retrospective Candidate. -->

---

## 17. Architectural-Seal Verification

RULE-053: Architecturally-sealed documents (e.g., FROZEN markers on long-form analysis files, sealed sprint folders, ARCHIVE-banner files) require defensive verification at session start, not just trust in the kickoff's instructions to avoid them. Any session that operates near sealed/frozen documents should encode the seal as a verifiable assertion at session start (e.g., grep for the FROZEN marker; halt if absent). The verification protects against the seal being silently removed elsewhere — without it, a future kickoff's avoidance instruction would silently bypass an important architectural decision if the marker is gone.

This rule is a sibling of RULE-038 (session-start grep-verification of factual claims) but distinct: RULE-038 verifies external assertions about current code state; RULE-053 verifies positive assertions about sealed-content protection. Action-on-failure differs: RULE-038 disagreement → flag/ignore the stale claim; RULE-053 missing seal → escalate (the seal's removal is itself the issue, not the work being attempted).

<!-- Origin: synthesis-2026-04-26 P29. Evidence: SPRINT-CLOSE-B-closeout.md
     §2 documents pre-flight check #5 explicitly grep-verified the
     `process-evolution.md` FROZEN marker still existed before allowing
     the session to proceed. If a future operator removes the freeze
     marker, the kickoff's avoidance instruction would silently bypass
     the architectural decision. Defensive verification at session start
     is the protection. -->

---

## 18. Self-Assessment Categories

RULE-054: FLAGGED self-assessment (canonical per Sprint 31.92.6 S5b).

FLAGGED is a Self-Assessment category per RULE-011 reserved for sessions where:

1. **Literal contract met**: impl-prompt's Definition-of-Done is satisfied.
2. **Structural-class issue surfaced**: implementation discovered a structural-class issue NOT within-session-fixable (e.g., spec reframe, deferred-deliverable shape mismatch, architectural-lock-class architectural lock).
3. **Operator paths enumerated**: implementer documents path a/b/c style options for operator-level decision.
4. **No unilateral fix**: implementer does NOT attempt to reshape the reframe themselves.

When all 4 conditions are met, FLAGGED self-assessment is canonical; Tier 2 verdict is CLEAR (NOT CLEAR-WITH-NOTES; NOT CONCERNS).

FLAGGED is distinct from MINOR_DEVIATIONS:

- **MINOR_DEVIATIONS** = local non-semantic deviations within session scope (RULE-038-driven canonical-reality alignments; test-infrastructure adaptations).
- **FLAGGED** = structural-class scope-reframe disclosure requiring operator-level decision.

Canonical example: Sprint 31.92.6 S5b's 24-AC reframe surfaced at AC validation suite execution.

Cross-reference: `templates/implementation-prompt.md` v1.7.0+ § Self-Assessment categories; `templates/review-prompt.md` v1.4.0+ § Accepting FLAGGED self-assessment.

<!-- Origin: Sprint 31.92.6 S5b. Evidence: 24-AC sprint-boundary scope-reframe
     disclosure (Del. E + Del. H' + Del. J + Del. K + AC12.5 clusters) was
     the canonical FLAGGED instance — literal contract met (AC parametrize
     suite executed; 92 items collected, 66 PASS + 26 documented-exemption
     SKIP), structural-class issue surfaced (operator must choose path
     (a)/b/c absorption disposition), no unilateral fix. Operator selected
     path (a) for Sprint 31.92.7 absorption. -->

---

## 19. Discrimination Methodology

RULE-055: MD5 byte-equality discrimination (canonical per Sprint 31.92.6 S5a-1).

Tests-only sessions touching safety-critical paths (DEF-204 family; bracket OCA group threading; SELL emit choke point; reconciliation contract; alert observability subsystem) MUST verify production code byte-for-byte preservation via MD5 byte-equality:

1. Capture MD5 of the touched production-code region BEFORE running tests:
   `md5sum <file>` or `python -c "import hashlib; print(hashlib.md5(open('<file>', 'rb').read()).hexdigest())"`.
2. Run the discrimination cycle per RULE-040 Level 2 (comment out production code emission → verify test FAILS → restore → verify test PASSES).
3. Capture MD5 of the touched production-code region AFTER discrimination cycle: must be IDENTICAL to step 1's hash.

Why: Level 1 (`git diff` empty) misses whitespace + encoding drift + reformatter side-effects. Level 2 (discrimination cycle) proves the test isn't vacuous but doesn't prove byte-for-byte preservation. Level 3 (MD5 byte-equality) is the strongest verification class.

Cross-reference: RULE-040 Level 3 (this RULE codifies what RULE-040 Level 3 references).

Canonical example: Sprint 31.92.6 S5a-1 cross-layer composition tests on `argus/execution/order_manager.py:9742-9766`.

<!-- Origin: Sprint 31.92.6 S5a-1. Evidence: cross-layer composition tests
     for Wave 1 of the 4-primitive coordination required tests-only commits
     against safety-critical SELL-emit choke-point code; Level 2
     discrimination cycle proved test non-vacuity, and Level 3 MD5
     byte-equality verified the production code at lines 9742-9766 was
     byte-for-byte identical before and after the discrimination round.
     Without Level 3, a whitespace-only edit (e.g., trailing-space
     normalization on save) would silently slip past Level 1 git-diff and
     Level 2 fail/pass cycle. -->

---

## 20. Phase A API-Surface Verification

RULE-056: Phase A API-surface verification artifact non-bypassable (canonical per synthesis-sprint-31.92.7 D6).

**Empirical anchor:** W-2 confirmed across 4 consecutive sprints (Sprint 31.92, 31.92.5, 31.92.65, 31.92.7). Each Round-1 adversarial-review verdict in those sprints surfaced 3–4 Critical primitive-semantics misses attributable to un-verified API/method/class/field/file-path citations.

**Rule:** Phase A of every sprint MUST produce a `docs/sprints/<sprint-id>/phase-a-api-surface-audit.md` artifact, per the canonical template at `templates/phase-a-api-surface-audit.md`. The artifact enumerates every production-code name (function, method, class, dataclass field, attribute, ABC method, file path, config field, enum value, constant) cited in any Phase A artifact (joint design summary, sprint-spec preliminary draft, problem statement).

**Non-bypassable contract:**

- Each cited name in Phase A artifacts is classified VERIFIED / NEW / DRIFT in the audit.
- **DRIFT rows GATE Phase B.** Phase B is structurally blocked until all DRIFT rows are RESOLVED (citing artifact corrected; resolution commit SHA recorded in the audit's Section 2).
- The Phase A author asserts completion via the audit's Section 3 checklist. Phase B is structurally blocked until all four checkboxes resolve.

**Why non-bypassable:** the 4-consecutive-sprint empirical anchor is overwhelming. Each Round-1 verdict's Critical misses cost an adversarial-review cycle to surface; the mandatory artifact's ~30-minute Phase A cost is amortized across every cycle it eliminates. Sprint 31.92.8 onward is the inaugural test of this rule's effect.

**Cross-references:**
- Canonical template: `templates/phase-a-api-surface-audit.md`
- Protocol binding: `protocols/sprint-planning.md` Phase A §API-Surface Verification
- Synthesis origin: synthesis-sprint-31.92.7 D6.

---

## 21. Round-N+1 Verdict-Text Completeness Audit

RULE-057: Round-N+1 verdict-text completeness audit non-bypassable (canonical per synthesis-sprint-31.92.7 D6).

**Empirical anchor:** W-NEW2 first surfaced at Sprint 31.92.65 Round 3 (N-R3-NEW-2). The Round-3 reviewer found that the bulk-ack `_dedup_index` clearing semantic was asserted by FAI-65-D invariant (d) but not enumerated in AC4.x/AC1.5. The reviewer explicitly distinguished the gap as **inherited from the Round-2 verdict's FAI-65-D specification text** rather than introduced by the surgical-fix pass — gaps in verdict-proposed-resolution text survive verbatim absorption.

**Rule:** Every Round-N (N≥2) adversarial review MUST perform the Task 3 verdict-text-completeness audit per the canonical template at `templates/round-N-adversarial-review-prompt.md`. The audit scrutinizes the Round-(N-1) verdict's proposed-resolution text for three classes of blind spots:

1. **Invariants → ACs mapping** — does every verdict-proposed FAI's invariants map to ACs in the sprint-spec? Are AC patterns extended where invariants require it?
2. **Fix scope → downstream sweep** — does every verdict-proposed fix specify ALL downstream sweep targets (regression-checklist, doc-update-checklist, Constraints sections, Review Focus items, DoD bullet lists, narrative enumerations)?
3. **Fork rejection rationale** — does every verdict-proposed fork rejection land the rationale at the canonical artifact (`spec-by-contradiction.md` §"Rejecting <fork name>")?

**Non-bypassable contract:**

- Round-N (N≥2) reviewer MUST include Task 3 findings in the verdict output.
- Findings are logged as Minor (downstream sweep gap, missing rationale placement) or Major (missed invariant-to-AC mapping that affects sprint correctness).
- Skipping the audit invalidates the Round-N verdict; the Round-N reviewer must re-issue with audit complete.

**Why non-bypassable:** without the audit, gaps in Round-N verdict-proposed-resolution text persist through Round-N+1 absorption verification and surface only at sprint implementation. The Sprint 31.92.65 R3 N-R3-NEW-2 finding is the canonical example: a gap that pre-dated the surgical-fix pass survived two rounds of review before the audit surfaced it.

**Cross-references:**
- Canonical template: `templates/round-N-adversarial-review-prompt.md` Task 3
- Protocol binding: `protocols/adversarial-review.md` §Round-N+1 Verdict-Text-Completeness Audit
- Synthesis origin: synthesis-sprint-31.92.7 D6.

---

## Meta

This file is maintained in the metarepo and seeded into every project during bootstrap.
Project-specific rules go in separate files in the same .claude/rules/ directory (e.g., backtesting.md for ARGUS-specific rules).
Do not modify this file from within a project -- changes flow from metarepo to projects, not the reverse.
To propose a new universal rule, flag it in the close-out report and it will be evaluated during the next strategic check-in.
