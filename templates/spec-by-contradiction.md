<!-- workflow-version: 1.1.0 -->
<!-- last-updated: 2026-04-29 -->
# Template: Specification by Contradiction

This document defines what Sprint [N] explicitly does NOT do. It prevents scope
creep during implementation and gives the Tier 2 reviewer clear boundaries to check.

---

    # Sprint [N]: What This Sprint Does NOT Do

    ## Out of Scope
    These items are related to the sprint goal but are explicitly excluded:
    1. [Item]: [Why it is excluded -- e.g., "deferred to Sprint N+1", "not needed for MVP"]
    2. [Item]: [Why]

    ### Rejecting Adversarial-Review-Proposed Alternatives

    When the disposition author rejects an alternative proposed by an
    adversarial reviewer (and lists the rejection here as Out of Scope),
    the rejection rationale MUST distinguish between:

    - **Empirical falsification:** "Reviewer's proposed alternative X was
      tested via [spike script / test fixture / measurement] and found to
      [be infeasible / produce worse outcomes / introduce a new failure
      mode]. Cross-reference: [spike artifact path]."
    - **Judgment call:** "Reviewer's proposed alternative X was judged not
      worth the marginal complexity given [stated trade-off]. NOT empirically
      falsified — the rejection is a judgment call subject to revisit if
      the trade-off changes."

    Rationale framing must NOT use definitional language ("definitively
    impossible," "this cannot work," "structurally infeasible") for
    rejections that are actually judgment calls. Doing so misleads future
    readers and makes the rejection unfalsifiable. Judgment calls remain
    valid; they just must be labeled as such.

    The framing distinction matters because adversarial-review rejections
    are routinely re-litigated when the cost-benefit of the alternative
    shifts (e.g., a forward-pull that was scope-creep at Sprint N becomes
    natural scope at Sprint N+5). Future planners reading "definitively
    impossible" will not re-evaluate; future planners reading "judgment
    call given X trade-off" will.

    <!-- Origin: ARGUS Sprint 31.92 Round 2 L-R2-1 (2026-04-29). The Round 1
         disposition author rejected reviewer's options for C-2 (trades-table
         reconstruction) on attribution-ambiguity grounds and (DEF-209
         forward-pull) on scope-creep grounds without empirical testing.
         Round 2 caught both rationales as untested judgment calls
         masquerading as definitional impossibilities. Re-framing them as
         judgment calls preserves the rejection while making it
         re-evaluable. -->

    ## Edge Cases to Reject
    The implementation should NOT handle these cases in this sprint:
    1. [Edge case]: [Expected behavior -- e.g., "return error", "ignore", "log and skip"]
    2. [Edge case]: [Expected behavior]

    ## Scope Boundaries
    - Do NOT modify: [list of files, modules, or systems that must not be touched]
    - Do NOT optimize: [areas where correctness is sufficient, performance is deferred]
    - Do NOT refactor: [areas that may look like they need cleanup but are out of scope]
    - Do NOT add: [features or capabilities that are tempting but not in the spec]

    ## Interaction Boundaries
    - This sprint does NOT change the behavior of: [list of interfaces, APIs, or contracts]
    - This sprint does NOT affect: [list of components that should be unaware of the changes]

    ## Deferred to Future Sprints
    | Item | Target Sprint | DEF Reference |
    |------|--------------|---------------|
    | [item] | Sprint [N+X] or Unscheduled | DEF-[N] |
