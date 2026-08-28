#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Checking shell syntax..."
bash -n "$REPO_ROOT/install.sh"
bash -n "$REPO_ROOT/scripts/init-project.sh"
bash -n "$REPO_ROOT/tests/check.sh"
bash -n "$REPO_ROOT/tests/smoke-test.sh"

echo "Running smoke test..."
bash "$REPO_ROOT/tests/smoke-test.sh"

echo "All checks passed"
