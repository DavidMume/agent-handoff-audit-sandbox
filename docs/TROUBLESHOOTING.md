# Troubleshooting

Each entry: **Symptom → Likely cause → How to check → Safe fix**. "Safe fix" never includes a destructive command without first showing how to confirm it's actually safe to run.

---

### `claude: command not found`

- **Symptom:** running `claude --version` prints "command not found."
- **Likely cause:** Claude Code isn't installed, or its install location isn't on your `PATH`.
- **How to check:** `command -v claude` (empty output means it's not on `PATH`).
- **Safe fix:** install Claude Code following its own documentation, or add its install directory to your shell's `PATH`. This skill's `/agent-handoff-audit` commands only work once Claude Code itself is installed and running — the skill doesn't install the agent for you.

### `codex: command not found`

- **Symptom:** running `codex --version` prints "command not found."
- **Likely cause:** the Codex CLI isn't installed, or isn't on your `PATH`.
- **How to check:** `command -v codex`.
- **Safe fix:** install the Codex CLI per OpenAI's documentation. If you only use Claude Code, this is expected and fine — the skill works with either agent alone.

### The skill doesn't appear / doesn't seem to activate

- **Symptom:** you type `/agent-handoff-audit start` (or `$agent-handoff-audit start`) and the agent doesn't seem to recognize the protocol.
- **Likely cause:** either the install didn't complete, the agent was already running before you installed it, or the project was never initialized (no `.agent-coordination/`, no pointer block in `AGENTS.md`/`CLAUDE.md`).
- **How to check:**
  ```bash
  ls -la ~/.claude/skills/agent-handoff-audit   # Claude
  ls -la ~/.agents/skills/agent-handoff-audit   # Codex
  ls -la .agent-coordination                     # inside the project
  grep -c "agent-handoff-audit" AGENTS.md CLAUDE.md
  ```
- **Safe fix:** if the symlinks are missing, re-run `bash install.sh`. If the project was never initialized, run `scripts/init-project.sh`. Then fully restart the agent (quit and reopen Claude Code / the Codex CLI session) so it re-reads the skill folder.

### Symlink is broken

- **Symptom:** `ls -la ~/.claude/skills/agent-handoff-audit` shows the link in a different color (often red) or a "No such file or directory" error when you try to open it.
- **Likely cause:** the real install at `~/.local/share/agent-handoff-audit` was moved, renamed, or deleted, but the symlink still points at the old path.
- **How to check:**
  ```bash
  ls -la ~/.claude/skills/agent-handoff-audit
  ls -la ~/.local/share/agent-handoff-audit
  ```
  If the second command fails, the target is genuinely gone.
- **Safe fix:** re-run `bash install.sh` from a clone of this repository — it recreates the real install and both symlinks in one step, backing up whatever was there first.

### Permission denied

- **Symptom:** `install.sh` or `init-project.sh` prints `Permission denied` while creating a folder or file.
- **Likely cause:** you don't have write access to the target path — most often `~/.local/share`, `~/.claude`, `~/.agents`, or the project folder itself.
- **How to check:** `ls -la ~/.local/share` (look at the owner column) or, for a project, `ls -la /path/to/project` and confirm you own it or have group write access.
- **Safe fix:** never re-run with `sudo` to force it — that changes file ownership to `root` and creates a worse problem later. Instead, fix ownership of your own home-directory folders (`sudo chown -R "$(whoami)" ~/.local ~/.claude ~/.agents` — only if you're certain those paths should be yours) or install into a location you do own.

### `.agent-coordination/` wasn't created

- **Symptom:** you ran `init-project.sh` but the folder doesn't exist afterward.
- **Likely cause:** the script was pointed at the wrong path, or it errored out partway (check its printed output — it doesn't fail silently).
- **How to check:** re-run it and read every line of output: `bash ~/.local/share/agent-handoff-audit/scripts/init-project.sh /path/to/project`.
- **Safe fix:** confirm `/path/to/project` is correct and exists, then re-run. It's idempotent, so re-running is always safe.

### `AGENTS.md` looks duplicated

- **Symptom:** the coordination block appears twice in `AGENTS.md`.
- **Likely cause:** the marker comment `<!-- agent-handoff-audit -->` was edited or removed by hand from one copy but not the other, so `init-project.sh`'s duplicate check (which looks for that exact marker) no longer detects the existing block.
- **How to check:** `grep -n "agent-handoff-audit" AGENTS.md`.
- **Safe fix:** manually delete the extra copy, keeping the marker line intact on the one you keep, so future runs of `init-project.sh` correctly detect it.

### `CLAUDE.md` looks duplicated

Same cause, check, and fix as `AGENTS.md` above — just run `grep -n "agent-handoff-audit" CLAUDE.md`.

### Repository has no `.git`

- **Symptom:** `init-project.sh` runs, but you didn't expect to use this outside a Git repo, or a git-aware step behaves unexpectedly.
- **Likely cause:** `init-project.sh` itself doesn't require `.git` to exist — it only creates files. But the *protocol* (branch/commit tracking in `ACTIVE_SESSION.md` and `WORKLOG.md`) assumes Git is present, since "branch" and "commit" are core fields in every ledger entry.
- **How to check:** `git status` from the project root; `fatal: not a git repository` confirms it.
- **Safe fix:** run `git init` in the project first if you intend to use version control (recommended), or accept that the ledger's branch/commit fields will simply stay blank if you deliberately aren't using Git.

### A previous install already existed

- **Symptom:** running `install.sh` prints `Backing up existing target: ... -> ....backup-<timestamp>`.
- **Likely cause:** this is expected, informational output — not an error. A prior install (from this repo or another copy) was already present.
- **How to check:** `ls -d ~/.local/share/agent-handoff-audit.backup-* 2>/dev/null` to see prior backups.
- **Safe fix:** nothing required — the new version is installed and the old one is preserved under a timestamped name. Same-second backups receive an additional numeric suffix instead of overwriting one another. Delete old backups by hand once you've confirmed the new install works.

### A previous agent left the session open

- **Symptom:** `ACTIVE_SESSION.md` shows `Status: active` for an agent that isn't actually running anymore.
- **Likely cause:** that agent's session ended (crashed, was closed, or the human just moved on) without running `handoff`, which is the step that closes the session.
- **How to check:** read `.agent-coordination/ACTIVE_SESSION.md` and compare its `Updated:` timestamp with how long ago you know work actually stopped.
- **Safe fix:** don't silently overwrite it. Note in your next handoff that the previous session looked stale and was superseded, then update `ACTIVE_SESSION.md` to reflect your own session. If you're not sure whether the other agent is truly done, ask the human first.

### `ACTIVE_SESSION.md` looks stale

Same situation as above — see the fix there. The general rule: a stale-looking session is a signal to proceed cautiously and say so in your handoff, not a reason to stop entirely, and not something to overwrite without comment either.

### Two agents edited the same file

- **Symptom:** you notice conflicting or overlapping changes from Claude and Codex in the same file.
- **Likely cause:** an agent skipped the `start` protocol's check of `ACTIVE_SESSION.md`, or the session record was stale and misread as safe to ignore.
- **How to check:** `git diff` and `git log -p -- path/to/file` to see both sets of changes and when they landed.
- **Safe fix:** don't silently pick one side. Have the next agent (or you, manually) reconcile the two versions, record what happened in `WORKLOG.md` and, if it caused real rework, in `RISKS.md` — then continue. Never `git checkout --` or `git reset --hard` to discard one side without first confirming with whoever made those changes that they're not needed.

### The ledger ended up in Git accidentally

- **Symptom:** `git status` or a GitHub repo view shows `.agent-coordination/` tracked, but you expected it to be gitignored.
- **Likely cause:** the project was initialized with `--tracked`, or files were added with `git add -A`/`git add .` before `.gitignore` picked them up, or `.gitignore` never actually contained the `.agent-coordination/` line.
- **How to check:**
  ```bash
  git check-ignore -v .agent-coordination/WORKLOG.md   # empty output = not ignored
  git ls-files .agent-coordination/                     # any output = tracked
  ```
- **Safe fix:** if it's only staged, not committed: `git restore --staged .agent-coordination/` and confirm `.gitignore` contains `.agent-coordination/`. If it's already committed but not pushed: remove it from the last commit and add the `.gitignore` line before committing again. If it's already pushed: treat it like the secret-exposure case below if it contains anything sensitive, and coordinate with your team before rewriting shared history.

### A secret was accidentally written

Follow [Security and privacy](../README.md#security-and-privacy) in the README immediately: stop, don't push, rotate the secret, clean the file, check Git history, and record the incident without repeating the secret's value.

### An audit was done by only one agent

- **Symptom:** `FINAL_AUDIT.md` shows findings from only Claude or only Codex.
- **Likely cause:** the other agent wasn't run yet, or isn't installed/available for this project.
- **How to check:** read `FINAL_AUDIT.md`'s sign-off section for `Claude audit status` / `Codex audit status`.
- **Safe fix:** label it `PROVISIONAL — SECOND AGENT REVIEW REQUIRED` (per the protocol) and don't treat it as a full approval until the second agent actually reviews it. If only one agent is genuinely available, say so explicitly to the human rather than presenting it as complete.

### Tests weren't actually run

- **Symptom:** a `WORKLOG.md` entry claims tests passed, but there's no evidence anyone ran them.
- **Likely cause:** an agent (or a person) wrote an optimistic handoff without actually executing the test command.
- **How to check:** look for the exact command and outcome in the entry's `Verification:` field — the protocol requires "PASSED / FAILED / NOT RUN / BLOCKED / N/A," not a vague "tests pass."
- **Safe fix:** run the project's actual test command yourself before trusting the claim, and if the entry was wrong, don't rewrite it (`WORKLOG.md` is append-only) — add a new entry correcting the record.

### GitHub Actions fails

This repository doesn't ship a CI workflow by default (no `.github/workflows/`). If you add one for your own fork or for a project you initialized:

- **Symptom:** the workflow run shows a red ✕.
- **Likely cause:** most commonly a shell syntax error in a modified script, a path assumption that doesn't hold on the CI runner (e.g., assuming `$HOME` is writable the same way it is locally), or a missing dependency the runner doesn't have preinstalled.
- **How to check:** open the failed step's log in the GitHub Actions tab and read the first error line, not just the last one.
- **Safe fix:** reproduce the same command locally first (`bash -n script.sh`, then actually running it in a scratch folder) before changing CI configuration — most failures here are the same syntax/logic bug you can already catch with `bash -n`.
