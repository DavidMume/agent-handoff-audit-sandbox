#!/usr/bin/env bash
set -euo pipefail

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${HOME}/.local/share/agent-handoff-audit"
STAMP="$(date +%Y%m%d-%H%M%S)"

backup_target() {
  local target="$1"
  if [ -L "$target" ] || [ -e "$target" ]; then
    local backup="${target}.backup-${STAMP}"
    echo "Backing up existing target: $target -> $backup"
    mv "$target" "$backup"
  fi
}

if [ "$SOURCE_DIR" = "$INSTALL_DIR" ]; then
  echo "Skill is already in the canonical install directory."
else
  if [ -e "$INSTALL_DIR" ]; then
    backup_target "$INSTALL_DIR"
  fi
  mkdir -p "$(dirname "$INSTALL_DIR")"
  cp -R "$SOURCE_DIR" "$INSTALL_DIR"
fi

mkdir -p "${HOME}/.claude/skills" "${HOME}/.agents/skills"

CLAUDE_TARGET="${HOME}/.claude/skills/agent-handoff-audit"
CODEX_TARGET="${HOME}/.agents/skills/agent-handoff-audit"

backup_target "$CLAUDE_TARGET"
backup_target "$CODEX_TARGET"

ln -s "$INSTALL_DIR" "$CLAUDE_TARGET"
ln -s "$INSTALL_DIR" "$CODEX_TARGET"

echo
echo "Installed successfully."
echo "Claude: $CLAUDE_TARGET"
echo "Codex:  $CODEX_TARGET"
echo
echo "Initialize a repository with:"
echo "  bash \"$INSTALL_DIR/scripts/init-project.sh\" /path/to/repository"
