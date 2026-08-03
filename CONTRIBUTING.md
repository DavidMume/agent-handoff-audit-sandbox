# Contributing

Issues and pull requests are welcome.

## Before opening a PR

1. Syntax-check any shell script you touched:
   ```bash
   bash -n install.sh
   bash -n scripts/init-project.sh
   ```
2. If you changed `scripts/init-project.sh`, run it twice against a scratch Git repo and confirm the second run reports `Kept existing ...` / `Instruction already present in ...` with no duplicated content — see [`docs/TROUBLESHOOTING.md`](docs/TROUBLESHOOTING.md) for the exact steps.
3. Keep documentation in sync with actual script behavior. This repo intentionally avoids documenting commands, files, or flags that the code doesn't actually implement.
4. Never commit real secrets, tokens, or personal data — including inside `.agent-coordination/` examples in `docs/examples/`, which must stay fictional.

## Scope

- Bug reports and fixes: open an issue describing the symptom, the command you ran, and what you expected instead.
- Documentation improvements: welcome, especially anything that keeps a first-time installer from getting stuck.
- New features: open an issue first to discuss scope before implementing — this keeps the skill's contract (see `SKILL.md`) small and predictable for both Claude Code and Codex.

## Commit and PR conventions

- One logical change per PR where reasonable.
- Prefix commit subjects with a short type when it helps (`docs:`, `fix:`, `chore:`), matching the existing history.
- Describe what you tested in the PR body — this project treats "I ran it and it worked" as a claim that needs the actual command and outcome, not just an assertion.
