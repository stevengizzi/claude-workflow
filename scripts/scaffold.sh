#!/usr/bin/env bash
# scaffold.sh — Initialize a new project with the claude-workflow structure.
# Usage: ./scaffold.sh /path/to/new-project [project-name]

set -euo pipefail

WORKFLOW_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TARGET_DIR="${1:?Usage: ./scaffold.sh /path/to/new-project [project-name]}"
PROJECT_NAME="${2:-$(basename "$TARGET_DIR")}"

if [ -d "$TARGET_DIR/.git" ]; then
    echo "Error: $TARGET_DIR already has a git repo. Use setup.sh for existing projects."
    exit 1
fi

echo "=== Scaffolding new project: $PROJECT_NAME ==="
echo "    Target: $TARGET_DIR"
echo "    Workflow source: $WORKFLOW_DIR"
echo ""

# Create project directory
mkdir -p "$TARGET_DIR"
cd "$TARGET_DIR"

# Initialize git
git init
echo "✓ Git initialized"

# Add workflow as submodule
git submodule add https://github.com/stevengizzi/claude-workflow.git workflow
echo "✓ Workflow submodule added"

# Create project documentation structure
mkdir -p docs docs/sprints docs/strategies
mkdir -p .claude/skills .claude/rules .claude/agents
mkdir -p config scripts tests

# Copy scaffold templates for docs
for doc in decision-log dec-index risk-register sprint-history project-knowledge architecture roadmap; do
    if [ -f "$WORKFLOW_DIR/scaffold/docs/${doc}.md" ]; then
        cp "$WORKFLOW_DIR/scaffold/docs/${doc}.md" "docs/${doc}.md"
    else
        # Create minimal stubs
        echo "# ${PROJECT_NAME} — $(echo "$doc" | sed 's/-/ /g' | sed 's/\b\(.\)/\u\1/g')" > "docs/${doc}.md"
        echo "" >> "docs/${doc}.md"
        echo "> Created $(date +%Y-%m-%d). Update as the project evolves." >> "docs/${doc}.md"
    fi
done
echo "✓ Documentation structure created"

# Copy CLAUDE.md scaffold
if [ -f "$WORKFLOW_DIR/scaffold/CLAUDE.md" ]; then
    sed "s/\[PROJECT_NAME\]/$PROJECT_NAME/g" "$WORKFLOW_DIR/scaffold/CLAUDE.md" > "CLAUDE.md"
else
    cat > "CLAUDE.md" << CLAUDE_EOF
# ${PROJECT_NAME} — Claude Code Context

> Dense, actionable context for Claude Code sessions.
> Last updated: $(date +%Y-%m-%d)

## Active Sprint

**No active sprint.** Project initialized.

## Current State

- **Active sprint:** None
- **Tests:** 0
- **Infrastructure:** TBD

## Commands

\`\`\`bash
# Tests (update after choosing test framework)
# python -m pytest tests/
\`\`\`

## Key Decisions

*No decisions yet. See docs/decision-log.md.*
CLAUDE_EOF
fi
echo "✓ CLAUDE.md created"

# Run setup to create symlinks
"$WORKFLOW_DIR/scripts/setup.sh" "$TARGET_DIR"

# Create .gitignore
cat > ".gitignore" << 'EOF'
__pycache__/
*.pyc
.env
*.egg-info/
dist/
build/
node_modules/
.DS_Store
EOF
echo "✓ .gitignore created"

# Create runner entry point
cat > "scripts/sprint-runner.py" << 'EOF'
#!/usr/bin/env python3
"""Autonomous Sprint Runner — project entry point."""
import sys
import os

# Add workflow submodule to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'workflow', 'runner'))

from sprint_runner.main import main

if __name__ == "__main__":
    main()
EOF
chmod +x "scripts/sprint-runner.py"
echo "✓ Runner entry point created"

# Initial commit
git add -A
git commit -m "Initialize project with claude-workflow scaffold"
echo "✓ Initial commit"

echo ""
echo "=== Project scaffolded successfully ==="
echo ""
echo "Next steps:"
echo "  1. Update CLAUDE.md with project-specific context"
echo "  2. Update docs/project-knowledge.md with project description"
echo "  3. Add project-specific rules to .claude/rules/"
echo "  4. Run the Discovery protocol (see workflow/protocols/discovery.md)"
echo "  5. Copy bootstrap-index.md to your Claude.ai project knowledge"
echo "     Source: $WORKFLOW_DIR/bootstrap-index.md"
