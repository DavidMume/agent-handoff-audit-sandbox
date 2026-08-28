#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/agent-handoff-audit.XXXXXX")"

cleanup() {
  rm -rf "$TEST_ROOT"
}
trap cleanup EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_file() {
  [ -f "$1" ] || fail "Expected file: $1"
}

assert_dir() {
  [ -d "$1" ] || fail "Expected directory: $1"
}

assert_absent() {
  [ ! -e "$1" ] || fail "Expected path to be absent: $1"
}

TEST_HOME="$TEST_ROOT/home"
mkdir -p "$TEST_HOME"

HOME="$TEST_HOME" bash "$REPO_ROOT/install.sh" >/dev/null

INSTALL_DIR="$TEST_HOME/.local/share/agent-handoff-audit"
assert_file "$INSTALL_DIR/SKILL.md"
assert_file "$INSTALL_DIR/install.sh"
assert_file "$INSTALL_DIR/scripts/init-project.sh"
assert_file "$INSTALL_DIR/templates/WORKLOG.md"
assert_file "$INSTALL_DIR/references/LOG_FORMATS.md"
assert_absent "$INSTALL_DIR/.git"
assert_absent "$INSTALL_DIR/.agent-coordination"
assert_absent "$INSTALL_DIR/docs"
assert_absent "$INSTALL_DIR/assets"
assert_absent "$INSTALL_DIR/tests"

[ -L "$TEST_HOME/.claude/skills/agent-handoff-audit" ] || fail "Claude target is not a symlink"
[ -L "$TEST_HOME/.agents/skills/agent-handoff-audit" ] || fail "Codex target is not a symlink"
[ "$(readlink "$TEST_HOME/.claude/skills/agent-handoff-audit")" = "$INSTALL_DIR" ] || fail "Claude symlink target is incorrect"
[ "$(readlink "$TEST_HOME/.agents/skills/agent-handoff-audit")" = "$INSTALL_DIR" ] || fail "Codex symlink target is incorrect"

HOME="$TEST_HOME" bash "$REPO_ROOT/install.sh" >/dev/null
find "$TEST_HOME/.local/share" -maxdepth 1 -type d -name 'agent-handoff-audit.backup-*' | grep -q . || fail "Reinstall did not back up the previous install"

LOCAL_PROJECT="$TEST_ROOT/local-project"
mkdir -p "$LOCAL_PROJECT"
bash "$INSTALL_DIR/scripts/init-project.sh" "$LOCAL_PROJECT" >/dev/null
bash "$INSTALL_DIR/scripts/init-project.sh" "$LOCAL_PROJECT" >/dev/null

assert_dir "$LOCAL_PROJECT/.agent-coordination"
assert_file "$LOCAL_PROJECT/.agent-coordination/ACTIVE_SESSION.md"
[ "$(grep -Fc '<!-- agent-handoff-audit -->' "$LOCAL_PROJECT/AGENTS.md")" -eq 1 ] || fail "AGENTS.md instruction was duplicated"
[ "$(grep -Fc '<!-- agent-handoff-audit -->' "$LOCAL_PROJECT/CLAUDE.md")" -eq 1 ] || fail "CLAUDE.md instruction was duplicated"
[ "$(grep -Fxc '.agent-coordination/' "$LOCAL_PROJECT/.gitignore")" -eq 1 ] || fail ".gitignore entry was duplicated or missing"

TRACKED_PROJECT="$TEST_ROOT/tracked-project"
mkdir -p "$TRACKED_PROJECT"
bash "$INSTALL_DIR/scripts/init-project.sh" "$TRACKED_PROJECT" --tracked >/dev/null
assert_dir "$TRACKED_PROJECT/.agent-coordination"
assert_absent "$TRACKED_PROJECT/.gitignore"

if bash "$INSTALL_DIR/scripts/init-project.sh" "$TEST_ROOT/invalid-project" --invalid >/dev/null 2>&1; then
  fail "Invalid mode unexpectedly succeeded"
fi

echo "Smoke test passed"
