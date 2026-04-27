<!-- workflow-version: 1.0.0 -->
<!-- last-updated: 2026-04-27 -->
# Tier 2 @reviewer Prompt — Frontend Sessions

## When to use this template

Use this template instead of `templates/review-prompt.md` when the
session under review is a frontend-focused session:
- Touches `frontend/src/**` primarily
- Adds Vitest tests (not pytest)
- Implements UI components, hooks, page-level integrations, or
  layout-level mountings

For mixed sessions (frontend + backend), use BOTH templates and have
the reviewer alternate focus.

## Checklist (frontend-flavored)

The reviewer must verify each of the following:

### State machine completeness
- [ ] All states reachable from initial state
- [ ] No dead-end states (every state has a valid transition or
      terminal status)
- [ ] State transitions are deterministic (same input → same next state)
- [ ] Loading / error / empty / data states all handled

### Reconnect / disconnect resilience
- [ ] WebSocket disconnect is detected within bounded time
- [ ] On disconnect: graceful fallback (e.g., REST polling, cached state)
- [ ] On reconnect: state refetch + WebSocket resubscription
- [ ] No alerts / events lost in the disconnect window (via REST recovery)

### Acknowledgment race handling (when applicable)
- [ ] Double-click / rapid-fire request idempotency
- [ ] Two-tab race resolution (first-writer-wins or explicit conflict)
- [ ] Stale acknowledgment after auto-resolution (409 handling)

### Accessibility
- [ ] ARIA roles correct (button, dialog, alert, status)
- [ ] Keyboard navigation (Tab, Enter, Escape) functional
- [ ] Focus trap in modals; focus restoration on close
- [ ] Color contrast meets WCAG AA
- [ ] Screen reader announcement order sensible

### Cross-page persistence (when applicable)
- [ ] Component mounted at Layout level, not page level
- [ ] State survives page navigation (visible across pages)
- [ ] No duplicate mount on rapid navigation
- [ ] State clears within 1s of underlying-condition change

### Z-index / layout interactions
- [ ] No overlap with existing UI elements at any breakpoint
- [ ] Stacking order correct under multiple-alert burst
- [ ] Mobile / narrow viewport considered

### Vitest coverage thresholds
- [ ] ≥90% line coverage for new components
- [ ] ≥80% branch coverage for new hooks
- [ ] All state transitions tested
- [ ] All error paths tested

## Reviewer entity

The frontend reviewer is **the same `@reviewer` Tier 2 subagent** used
for backend safety reviews, but invoked with this template instead of
the backend-flavored one. The session implementation prompt flags which
template applies. Operator selects the template at session-kickoff time.