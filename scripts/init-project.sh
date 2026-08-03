#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-.}"
MODE="${2:-local}"
ROOT="$(cd "$ROOT" && pwd)"
COORD="${ROOT}/.agent-coordination"
SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATES="${SKILL_DIR}/templates"

if [ "$MODE" != "local" ] && [ "$MODE" != "--tracked" ]; then
  echo "Usage: $0 [repository-path] [--tracked]" >&2
  exit 2
fi

mkdir -p "$COORD"

copy_if_missing() {
  local source="$1"
  local target="$2"
  if [ ! -e "$target" ]; then
    cp "$source" "$target"
    echo "Created ${target#$ROOT/}"
  else
    echo "Kept existing ${target#$ROOT/}"
  fi
}

copy_if_missing "$TEMPLATES/CURRENT_STATE.md" "$COORD/CURRENT_STATE.md"
copy_if_missing "$TEMPLATES/WORKLOG.md" "$COORD/WORKLOG.md"
copy_if_missing "$TEMPLATES/DECISIONS.md" "$COORD/DECISIONS.md"
copy_if_missing "$TEMPLATES/RISKS.md" "$COORD/RISKS.md"
copy_if_missing "$TEMPLATES/FINAL_AUDIT.md" "$COORD/FINAL_AUDIT.md"
copy_if_missing "$TEMPLATES/ACTIVE_SESSION.md" "$COORD/ACTIVE_SESSION.md"

append_block_once() {
  local file="$1"
  local marker="$2"
  local content="$3"
  touch "$file"
  if ! grep -Fq "$marker" "$file"; then
    printf "\n%s\n" "$content" >> "$file"
    echo "Updated ${file#$ROOT/}"
  else
    echo "Instruction already present in ${file#$ROOT/}"
  fi
}

AGENTS_BLOCK='<!-- agent-handoff-audit -->
## Shared agent coordination
For every substantial implementation task, follow the installed `agent-handoff-audit` skill. At task start read `.agent-coordination/` using its token-saving order; before finishing, verify the work and write one compact handoff. Claude and Codex communicate about implementation state only through this ledger. Run reciprocal audits at major completion milestones.'

CLAUDE_BLOCK='<!-- agent-handoff-audit -->
## Shared agent coordination
For every substantial implementation task, follow the installed `agent-handoff-audit` skill. At task start read `.agent-coordination/` using its token-saving order; before finishing, verify the work and write one compact handoff. Claude and Codex communicate about implementation state only through this ledger. Run reciprocal audits at major completion milestones.'

append_block_once "$ROOT/AGENTS.md" "<!-- agent-handoff-audit -->" "$AGENTS_BLOCK"
append_block_once "$ROOT/CLAUDE.md" "<!-- agent-handoff-audit -->" "$CLAUDE_BLOCK"

if [ "$MODE" = "local" ]; then
  GITIGNORE="$ROOT/.gitignore"
  touch "$GITIGNORE"
  if ! grep -Fxq ".agent-coordination/" "$GITIGNORE"; then
    printf "\n# Local Claude/Codex coordination ledger; may contain sensitive operational findings\n.agent-coordination/\n" >> "$GITIGNORE"
    echo "Added .agent-coordination/ to .gitignore"
  else
    echo ".agent-coordination/ is already ignored"
  fi
else
  echo "Tracked mode selected. Review coordination files before pushing, especially in public repositories."
fi

echo
echo "Repository coordination initialized at: $COORD"
echo "Next: start Claude or Codex from the repository root."
