# Usage guide

The full reference for `agent-handoff-audit`. If you just want to get moving, use the [Quickstart](QUICKSTART.md) instead — come back here for depth. New here? The [README](../README.md#important-concepts) defines terms like *skill*, *symlink*, *handoff*, and *ledger* the first time they appear; this guide assumes you've read that section.

## Contents

- [Installation, step by step](#installation-step-by-step)
- [Architecture](#architecture)
- [Complete examples](#complete-examples)
- [Claude → Codex flow](#claude--codex-flow)
- [Codex → Claude flow](#codex--claude-flow)
- [Cross-audit](#cross-audit)
- [Security and privacy, in depth](#security-and-privacy-in-depth)
- [Uninstalling](#uninstalling)
- [Updating](#updating)
- [Private repositories](#private-repositories)
- [Public repositories](#public-repositories)
- [Using worktrees](#using-worktrees)
- [Agents on different machines](#agents-on-different-machines)
- [Avoiding conflicts](#avoiding-conflicts)
- [Saving tokens](#saving-tokens)
- [Troubleshooting](#troubleshooting)

---

## Installation, step by step

Covered in full in the [README's step-by-step install](../README.md#step-by-step-install). Summary:

```bash
git clone https://github.com/DavidMume/agent-handoff-audit-sandbox.git
cd agent-handoff-audit-sandbox
bash -n install.sh          # syntax check, optional
bash install.sh              # copies the runtime payload to ~/.local/share/agent-handoff-audit
                              # and symlinks it into ~/.claude/skills/ and ~/.agents/skills/
```

Then, per project:

```bash
bash ~/.local/share/agent-handoff-audit/scripts/init-project.sh /path/to/project
```

Both scripts print exactly what they did — there's no hidden state. `install.sh` backs up any existing install or symlink before replacing it (`name.backup-<timestamp>`); `init-project.sh` never overwrites a coordination file, `AGENTS.md`/`CLAUDE.md` block, or `.gitignore` entry that already exists.

---

## Architecture

One real copy of the skill on disk, two symlinks pointing at it, and a per-project scaffold:

```text
~/.local/share/agent-handoff-audit/     ← the one real copy
├── SKILL.md                             (the instructions both agents follow)
├── install.sh
├── scripts/init-project.sh
├── templates/*.md                       (blank starting point for each ledger file)
└── references/
    ├── LOG_FORMATS.md                   (exact structure for each ledger entry)
    └── AUDIT_CHECKLIST.md               (loaded only during final-audit)

~/.claude/skills/agent-handoff-audit  →  symlink to the folder above
~/.agents/skills/agent-handoff-audit  →  symlink to the folder above

/path/to/your/project/
├── AGENTS.md            (pointer block appended, for Codex)
├── CLAUDE.md            (pointer block appended, for Claude Code)
├── .gitignore           (.agent-coordination/ added, unless --tracked)
└── .agent-coordination/
    ├── ACTIVE_SESSION.md
    ├── CURRENT_STATE.md
    ├── DECISIONS.md
    ├── FINAL_AUDIT.md
    ├── RISKS.md
    └── WORKLOG.md
```

Only one real copy exists so there's never a second copy of `SKILL.md` to drift out of sync — updating the skill means updating one folder, and both symlinks immediately see the change.

`install.sh` copies only the runtime payload shown above: `SKILL.md`, `install.sh`, `scripts/`, `templates/`, and `references/`. Repository-only content such as `.git/`, `.agent-coordination/`, `docs/`, `assets/`, and contribution metadata stays in the clone and is never added to the canonical install.

---

## Complete examples

Filled-in, fictional-data examples of every ledger file and format:

- [`current-state-example.md`](examples/current-state-example.md)
- [`handoff-example.md`](examples/handoff-example.md) (a `WORKLOG.md` entry)
- [`risk-example.md`](examples/risk-example.md) (a `RISKS.md` entry)
- [`decision-example.md`](examples/decision-example.md) (a `DECISIONS.md` entry)
- [`final-audit-example.md`](examples/final-audit-example.md) (a `FINAL_AUDIT.md` finding + sign-off)

The exact required fields for each are defined in `references/LOG_FORMATS.md` inside the installed skill.

---

## Claude → Codex flow

1. **Claude:** `/agent-handoff-audit start` — reads the ledger, records an active session.
2. **Claude:** implements the task, runs tests, reviews its diff.
3. **Claude:** `/agent-handoff-audit handoff` — writes one `WORKLOG.md` entry, updates `CURRENT_STATE.md`, closes `ACTIVE_SESSION.md`.
4. **(any amount of time later — minutes, hours, days)**
5. **Codex:** `$agent-handoff-audit takeover` — reads Claude's last handoff, opens the referenced diff/commit, checks the claimed test results are plausible, looks for obvious regressions or omissions.
6. **Codex:** continues the task.
7. **Codex:** `$agent-handoff-audit handoff` — same format, appended below Claude's entry.

See the full walkthrough with a real example handoff in the [README tutorial](../README.md#full-tutorial-claude-starts-codex-continues).

## Codex → Claude flow

Identical in shape, reversed:

1. **Codex:** `$agent-handoff-audit start`.
2. **Codex:** works, verifies, hands off with `$agent-handoff-audit handoff`.
3. **Claude:** `/agent-handoff-audit takeover` — reads Codex's handoff, checks the diff, continues.
4. **Claude:** `/agent-handoff-audit handoff` when done.

There's no special case for "Codex first" — both directions use the same six modes (`start`, `handoff`, `takeover`, `status`, `audit`, `final-audit`) described in the [README](../README.md#every-mode-explained).

---

## Cross-audit

Two different depths exist:

- **`audit`** — a focused, independent look at just the other agent's most recent changes. Use this mid-project when you want a second opinion without the full checklist.
- **`final-audit`** — the full reciprocal review at a milestone, using `references/AUDIT_CHECKLIST.md`: scope/provenance, functional correctness, security, privacy, potential legal/compliance issues, reliability, frontend/accessibility, data/model integrity, and tests/evidence.

Rules that apply to both, and matter most in `final-audit`:

- **The author of a fix can't be the sole verifier of the related finding** — Claude fixing something Codex flagged doesn't close it; Codex has to confirm the fix actually works.
- **Severity is honest, not optimistic**: `CRITICAL` (active compromise, irreversible data loss, major privacy exposure, unsafe production operation) down to `INFO` (an observation, not a defect).
- **No `CRITICAL` or `HIGH` finding may be open when a project is marked fully approved.**
- **A single-agent audit is provisional**, labeled `PROVISIONAL — SECOND AGENT REVIEW REQUIRED`, until the other agent actually reviews it.
- Legal/compliance items are issue-spotting, not legal advice — see [Security and privacy, in depth](#security-and-privacy-in-depth).

A filled-in example: [`docs/examples/final-audit-example.md`](examples/final-audit-example.md).

---

## Security and privacy, in depth

**Never write to the ledger:** passwords, API keys, tokens, private keys, cookies/session identifiers, personal data, medical records, financial data, data about children, real production records, full error output containing secrets, or an agent's private reasoning.

**If a secret is written anyway:**

1. Stop — don't layer more work on top of the exposed state.
2. Don't push. Since `.agent-coordination/` is gitignored by default, in the common case the secret never left your machine — confirm this with `git status .agent-coordination/` (it should show nothing, because it's ignored).
3. Rotate or revoke the secret at its source immediately, regardless of whether it was pushed — treat "probably fine" as "compromised."
4. Edit the file to remove the secret.
5. If the file was ever committed (for example, under `--tracked` mode) or pushed, a plain edit is not enough — Git keeps every prior version. Check with:
   ```bash
   git log -p --all -- .agent-coordination/ | grep -i "the-leaked-value"
   ```
   If it's in history, that history needs to be rewritten and force-pushed, which is a destructive operation — coordinate with your team and read Git's own documentation on history rewriting (`git filter-repo` or GitHub's guide on removing sensitive data) before doing it.
6. Record that an incident happened in `RISKS.md` — the fact that it happened, when, and what was rotated — **without copying the secret's value** into that record.

**What this skill's audits are not:** a penetration test, a professional security review, legal advice, a formal privacy impact assessment, or a compliance certification. `references/AUDIT_CHECKLIST.md` is issue-spotting to catch what an agent can reasonably check by reading code and running local commands — treat any finding under "potential legal and compliance risks" as a prompt to get qualified review, not as the review itself.

---

## Uninstalling

**Step 1 — confirm what's a symlink.** Both Claude's and Codex's install targets should be symlinks, not real folders:

```bash
ls -la ~/.claude/skills/agent-handoff-audit
ls -la ~/.agents/skills/agent-handoff-audit
```

Look for a line starting with `l` and a `->` pointing at `~/.local/share/agent-handoff-audit`. If you see that, it's safe to remove either one directly — you're deleting a pointer, not the actual files:

```bash
rm ~/.claude/skills/agent-handoff-audit
rm ~/.agents/skills/agent-handoff-audit
```

**Step 2 — the real copy**, only once you're sure you don't want the skill anywhere:

```bash
ls -la ~/.local/share/agent-handoff-audit   # confirm this is what you think it is
```

Removing this folder is a normal file deletion, not reversible from within the tool itself — if you're not certain, rename it instead of deleting it, so you can restore it if needed:

```bash
mv ~/.local/share/agent-handoff-audit ~/.local/share/agent-handoff-audit.disabled
```

Only delete it outright once you've confirmed nothing depends on it:

```bash
rm -rf ~/.local/share/agent-handoff-audit
```

**Per-project files are separate.** Uninstalling the skill does not touch `.agent-coordination/`, `AGENTS.md`, or `CLAUDE.md` in any project you initialized — remove those manually, per project, if you want them gone too.

---

## Updating

```bash
cd /path/to/agent-handoff-audit-sandbox
git pull --ff-only
bash install.sh
```

`install.sh` detects the existing install and symlinks, backs each one up with a timestamp suffix (e.g. `agent-handoff-audit.backup-20260803-194403`), then installs the new version. If multiple backups are created in the same second, a numeric suffix prevents collisions. Backups accumulate next to the original path — list them with:

```bash
ls -d ~/.local/share/agent-handoff-audit.backup-* 2>/dev/null
ls -d ~/.claude/skills/agent-handoff-audit.backup-* 2>/dev/null
ls -d ~/.agents/skills/agent-handoff-audit.backup-* 2>/dev/null
```

Once you've confirmed the update works, old backups are ordinary folders/symlinks you can remove by hand when you're ready — nothing does this automatically.

---

## Private repositories

For a private repo shared by a small team (or just you across machines), tracking the ledger in Git can be more useful than keeping it local-only, since it means the ledger travels with `git pull`/`git push` like any other file:

```bash
bash ~/.local/share/agent-handoff-audit/scripts/init-project.sh . --tracked
```

`--tracked` skips the `.gitignore` step, so `.agent-coordination/` gets committed normally. Because it's private, the reduced risk of leaking operational detail publicly makes this trade-off reasonable for many teams — but the [security guardrails](#security-and-privacy-in-depth) about never writing secrets still apply exactly as before; "private" is not the same as "safe to write a password into."

## Public repositories

Default (no `--tracked` flag) is the right choice for anything public: `.agent-coordination/` is gitignored, so operational notes, in-progress risk findings, and internal file paths never appear in your public commit history. If you specifically want a public project's coordination history to be visible (e.g., as a transparency artifact for an open-source project), use `--tracked` deliberately and review every entry before it's pushed — nothing in the ledger format assumes a public audience.

---

## Using worktrees

A **worktree** is Git's own feature for checking out more than one branch of the same repository into separate folders at the same time, instead of switching branches back and forth in one folder:

```bash
git worktree add ../my-project-feature-x feature-x
```

This is useful when you want Claude working on one branch/worktree while Codex works on a different branch/worktree of the same repository, without either agent's uncommitted changes interfering with the other's.

Each worktree needs its own initialization, since `.agent-coordination/` is scoped to a working-tree folder, not to the repository as a whole:

```bash
bash ~/.local/share/agent-handoff-audit/scripts/init-project.sh ../my-project-feature-x
```

Keep in mind the ledgers in each worktree are **independent** — a handoff written in one worktree's `.agent-coordination/` is not automatically visible from another worktree, even though both worktrees share the same underlying Git history. If the two branches will eventually merge, note that explicitly in each `WORKLOG.md` so whoever merges them knows to reconcile the two ledgers by hand (or simply keep one worktree as the canonical coordination point for that feature).

---

## Agents on different machines

`.agent-coordination/` is a local folder on disk — by default (gitignored) it does not travel between machines on its own. If Claude runs on one machine and Codex on another, pick one of:

- **Shared, tracked ledger:** initialize with `--tracked` (see [Private repositories](#private-repositories)) so the ledger commits and pushes/pulls like any other file. Each agent runs `git pull` before `start`/`takeover` and the human operator makes sure the handoff commit is pushed before the other machine begins.
- **Shared filesystem:** point both machines at the same network volume or synced folder (e.g., a shared drive) so `.agent-coordination/` is physically the same folder from both sides.
- **Manual handoff:** copy the `.agent-coordination/` folder (or just the files that changed) between machines yourself between sessions. Slower, but requires no configuration change.

Whichever you choose, the protocol itself doesn't change — an agent still reads the same files in the same order and writes the same handoff format. Only how the folder gets from one machine to the other differs.

---

## Avoiding conflicts

- `ACTIVE_SESSION.md` is the collision check: before editing anything, an agent following the `start` protocol reads it. If it shows the *other* agent as active on overlapping files, the correct behavior is to stop and report the collision to you, not to proceed and race the other session.
- If a previous session's `ACTIVE_SESSION.md` looks stale (the agent crashed, was interrupted, or you simply forgot to run `handoff`), the incoming agent should note that it looked stale in its next handoff rather than silently overwriting it — see [Troubleshooting](TROUBLESHOOTING.md#active_sessionmd-looks-stale).
- Two agents editing the same file at the same time is a workflow problem, not something the ledger prevents by itself — the ledger only works if both agents (and you) actually check it before starting. If it happens anyway, see [Troubleshooting](TROUBLESHOOTING.md#two-agents-edited-the-same-file).

---

## Saving tokens

See [How this saves tokens](../README.md#how-this-saves-tokens) in the README for the short version. The key habit: an agent should stop reading as soon as `CURRENT_STATE.md` plus the last two `WORKLOG.md` entries give it enough to proceed, and only open the *specific* files those entries name — not the whole project, and not the whole worklog history. There's no fixed percentage this saves; it depends entirely on how large the project and its history already are.

---

## Troubleshooting

Moved to its own file: [`docs/TROUBLESHOOTING.md`](TROUBLESHOOTING.md).
