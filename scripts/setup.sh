#!/usr/bin/env bash
# setup.sh — Create symlinks from project .claude/ to workflow submodule.
# Usage: ./workflow/scripts/setup.sh [project-root]
# Run from project root, or pass project root as argument.

set -euo pipefail

PROJECT_DIR="${1:-$(pwd)}"
WORKFLOW_DIR="$PROJECT_DIR/workflow"

if [ ! -d "$WORKFLOW_DIR" ]; then
    echo "Error: workflow/ submodule not found at $WORKFLOW_DIR"
    echo "Add it first: git submodule add https://github.com/stevengizzi/claude-workflow.git workflow"
    exit 1
fi

echo "=== Setting up workflow symlinks ==="
echo "    Project: $PROJECT_DIR"
echo "    Workflow: $WORKFLOW_DIR"
echo ""

# Ensure .claude directories exist
mkdir -p "$PROJECT_DIR/.claude/skills"
mkdir -p "$PROJECT_DIR/.claude/rules"
mkdir -p "$PROJECT_DIR/.claude/agents"

# Symlink universal skills
for skill in close-out review canary-test diagnostic doc-sync; do
    SRC="../../workflow/claude/skills/${skill}.md"
    DST="$PROJECT_DIR/.claude/skills/${skill}.md"
    if [ -L "$DST" ]; then
        rm "$DST"
    elif [ -f "$DST" ]; then
        echo "  ⚠ .claude/skills/${skill}.md exists as regular file — skipping (may be customized)"
        continue
    fi
    ln -s "$SRC" "$DST"
    echo "  ✓ .claude/skills/${skill}.md → workflow"
done

# Symlink universal rules
SRC="../../workflow/claude/rules/universal.md"
DST="$PROJECT_DIR/.claude/rules/universal.md"
if [ -L "$DST" ]; then
    rm "$DST"
elif [ -f "$DST" ]; then
    echo "  ⚠ .claude/rules/universal.md exists as regular file — checking if it's a copy..."
    if diff -q "$WORKFLOW_DIR/claude/rules/universal.md" "$DST" > /dev/null 2>&1; then
        echo "    Identical to metarepo — replacing with symlink"
        rm "$DST"
    else
        echo "    Different from metarepo — keeping project copy (run sync.sh to compare)"
    fi
fi
if [ ! -f "$DST" ]; then
    ln -s "$SRC" "$DST"
    echo "  ✓ .claude/rules/universal.md → workflow"
fi

# Symlink agents
for agent in builder reviewer doc-sync-agent; do
    SRC="../../workflow/claude/agents/${agent}.md"
    DST="$PROJECT_DIR/.claude/agents/${agent}.md"
    if [ -L "$DST" ]; then
        rm "$DST"
    elif [ -f "$DST" ]; then
        echo "  ⚠ .claude/agents/${agent}.md exists as regular file — skipping"
        continue
    fi
    ln -s "$SRC" "$DST"
    echo "  ✓ .claude/agents/${agent}.md → workflow"
done

echo ""
echo "=== Setup complete ==="
echo ""
echo "Symlinked files will track the workflow submodule."
echo "Project-specific rules go in .claude/rules/ as separate files."
echo "To update workflow: cd workflow && git pull origin main && cd .."
echo ""
echo "Remember to add bootstrap-index.md to your Claude.ai project knowledge:"
echo "  $WORKFLOW_DIR/bootstrap-index.md"
