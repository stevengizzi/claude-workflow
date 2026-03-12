#!/usr/bin/env bash
# sync.sh — Compare project workflow files against the metarepo.
# Usage: ./workflow/scripts/sync.sh [project-root]
# Run from project root, or pass project root as argument.
#
# Reports: symlink status, file divergence, version mismatches.
# Does NOT modify files — read-only audit.

set -euo pipefail

PROJECT_DIR="${1:-$(pwd)}"
WORKFLOW_DIR="$PROJECT_DIR/workflow"

if [ ! -d "$WORKFLOW_DIR" ]; then
    echo "Error: workflow/ submodule not found at $WORKFLOW_DIR"
    exit 1
fi

echo "=== Workflow Sync Audit ==="
echo "    Project: $PROJECT_DIR"
echo "    Workflow: $WORKFLOW_DIR"
echo "    Date: $(date +%Y-%m-%d)"
echo ""

ISSUES=0

# --- Check submodule freshness ---
echo "## Submodule Status"
cd "$WORKFLOW_DIR"
LOCAL_SHA=$(git rev-parse HEAD 2>/dev/null || echo "unknown")
REMOTE_SHA=$(git ls-remote origin HEAD 2>/dev/null | cut -f1 || echo "unknown")
cd "$PROJECT_DIR"

echo "  Local:  $LOCAL_SHA"
echo "  Remote: $REMOTE_SHA"
if [ "$LOCAL_SHA" = "$REMOTE_SHA" ]; then
    echo "  ✓ Submodule is up to date"
else
    echo "  ⚠ Submodule is behind remote — run: cd workflow && git pull origin main"
    ISSUES=$((ISSUES + 1))
fi
echo ""

# --- Check symlinks ---
echo "## Symlink Status"

check_symlink() {
    local category="$1"
    local name="$2"
    local project_path="$PROJECT_DIR/.claude/${category}/${name}.md"
    local workflow_path="$WORKFLOW_DIR/claude/${category}/${name}.md"

    if [ -L "$project_path" ]; then
        local target
        target=$(readlink "$project_path")
        if [ -f "$project_path" ]; then
            echo "  ✓ .claude/${category}/${name}.md (symlink, valid)"
        else
            echo "  ✗ .claude/${category}/${name}.md (symlink, BROKEN → $target)"
            ISSUES=$((ISSUES + 1))
        fi
    elif [ -f "$project_path" ]; then
        if [ -f "$workflow_path" ]; then
            if diff -q "$project_path" "$workflow_path" > /dev/null 2>&1; then
                echo "  ~ .claude/${category}/${name}.md (copy, identical — could be symlink)"
            else
                echo "  ⚠ .claude/${category}/${name}.md (copy, DIVERGED from metarepo)"
                diff --brief "$workflow_path" "$project_path" 2>/dev/null || true
                ISSUES=$((ISSUES + 1))
            fi
        else
            echo "  ? .claude/${category}/${name}.md (project-specific, not in metarepo)"
        fi
    else
        if [ -f "$workflow_path" ]; then
            echo "  ✗ .claude/${category}/${name}.md (MISSING — expected from metarepo)"
            ISSUES=$((ISSUES + 1))
        fi
    fi
}

# Check skills
for skill in close-out review canary-test diagnostic doc-sync; do
    check_symlink "skills" "$skill"
done

# Check universal rules
check_symlink "rules" "universal"

# Check agents
for agent in builder reviewer doc-sync-agent; do
    check_symlink "agents" "$agent"
done

echo ""

# --- Check for project-specific rules (informational) ---
echo "## Project-Specific Rules"
if ls "$PROJECT_DIR/.claude/rules/"*.md > /dev/null 2>&1; then
    for f in "$PROJECT_DIR/.claude/rules/"*.md; do
        name=$(basename "$f" .md)
        if [ "$name" != "universal" ]; then
            echo "  · $name.md (project-specific)"
        fi
    done
else
    echo "  (none)"
fi
echo ""

# --- Check if protocols/templates exist in docs/ (legacy location) ---
echo "## Legacy File Check"
LEGACY=0
for proto in sprint-planning adversarial-review tier-3-review in-flight-triage impromptu-triage discovery strategic-check-in codebase-health-audit retrofit-survey; do
    if [ -f "$PROJECT_DIR/docs/protocols/${proto}.md" ]; then
        if diff -q "$PROJECT_DIR/docs/protocols/${proto}.md" "$WORKFLOW_DIR/protocols/${proto}.md" > /dev/null 2>&1; then
            echo "  ~ docs/protocols/${proto}.md (identical to metarepo — can be removed)"
        else
            echo "  ⚠ docs/protocols/${proto}.md (DIVERGED — may contain project-specific changes)"
            ISSUES=$((ISSUES + 1))
        fi
        LEGACY=$((LEGACY + 1))
    fi
done
if [ "$LEGACY" -eq 0 ]; then
    echo "  ✓ No legacy protocol copies found in docs/protocols/"
fi
echo ""

# --- Check runner ---
echo "## Runner Status"
if [ -d "$PROJECT_DIR/scripts/sprint_runner" ]; then
    # Check if it's a copy or symlink
    if [ -L "$PROJECT_DIR/scripts/sprint_runner" ]; then
        echo "  ✓ scripts/sprint_runner/ (symlink)"
    else
        RUNNER_DIFF=$(diff -rq "$PROJECT_DIR/scripts/sprint_runner/" "$WORKFLOW_DIR/runner/sprint_runner/" 2>/dev/null | grep -c "differ" || true)
        if [ "$RUNNER_DIFF" -gt 0 ]; then
            echo "  ⚠ scripts/sprint_runner/ (copy, $RUNNER_DIFF files DIVERGED)"
            diff -rq "$PROJECT_DIR/scripts/sprint_runner/" "$WORKFLOW_DIR/runner/sprint_runner/" 2>/dev/null | head -10
            ISSUES=$((ISSUES + $RUNNER_DIFF))
        else
            echo "  ~ scripts/sprint_runner/ (copy, identical — could use submodule import)"
        fi
    fi
else
    echo "  · scripts/sprint_runner/ not present (may use submodule import pattern)"
fi
echo ""

# --- Summary ---
echo "==============================="
if [ "$ISSUES" -eq 0 ]; then
    echo "✓ All clear — no divergence detected"
else
    echo "⚠ $ISSUES issue(s) found — review above"
fi
echo "==============================="

exit 0
