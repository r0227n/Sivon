#!/bin/bash

set -euo pipefail

git_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
meta_skill="$git_root/.agents/skills/using-agent-skills/SKILL.md"

if [ -f "$meta_skill" ]; then
  cat <<'EOF'
agent-skills loaded. Use the skill discovery flowchart to find the right skill
for your task.

EOF
  cat "$meta_skill"
  exit 0
fi

cat <<'EOF'
agent-skills: using-agent-skills meta-skill not found. Skills may still be
available individually.
EOF
