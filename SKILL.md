---
name: agent-handoff-audit
description: Coordinate sequential work between Claude Code, Codex, or another coding agent through a compact shared handoff ledger. Use at the start and end of substantial implementation tasks, when taking over another agent's changes, and for reciprocal milestone or final audits covering correctness, security, privacy, dependencies, deployment, accessibility, and potential legal/compliance risks. Do not use for tiny read-only questions.
---

# Agent Handoff and Reciprocal Audit

Use this skill to let coding agents work sequentially in the same repository without repeatedly rediscovering context.

## Core contract

- Communicate between agents only through `.agent-coordination/`.
- Treat `WORKLOG.md` as append-only. Never rewrite or delete another agent's entry.
- Store facts, decisions, evidence, commands, results, and next actions. Never store private chain-of-thought.
- Never place secrets, tokens, passwords, private keys, personal data, production records, or full confidential logs in the ledger.
- Do not claim a test, build, deployment, scan, or review succeeded unless it was actually run and the result was observed.
- Keep entries compact. Refer to files, commits, issues, and commands instead of copying large diffs or terminal output.
- Work sequentially. If another live session appears active, do not edit overlapping files until the conflict is resolved.
- Preserve user changes and unrelated work. Never reset, discard, overwrite, force-push, or delete work merely to simplify the task.
- Do not commit, push, deploy, change infrastructure, rotate credentials, or add production dependencies unless the user or repository instructions authorize it.
- `.agent-coordination/` is operational metadata. Do not include it in a website, application bundle, public artifact, telemetry payload, or production deployment.

## Agent identity

Infer the active agent from the runtime:

- Claude Code -> `Claude`
- OpenAI Codex -> `Codex`
- Otherwise use the product or agent name shown by the runtime.

Do not ask the user when the identity is obvious.

## Coordination files

Use these files in the repository root:

- `.agent-coordination/CURRENT_STATE.md`: short, replaceable snapshot of the project.
- `.agent-coordination/WORKLOG.md`: append-only handoffs.
- `.agent-coordination/DECISIONS.md`: durable architectural or product decisions.
- `.agent-coordination/RISKS.md`: open risks, blockers, and accepted risks.
- `.agent-coordination/FINAL_AUDIT.md`: reciprocal audit findings and sign-off.
- `.agent-coordination/ACTIVE_SESSION.md`: current agent, scope, start time, and status.

If the directory is absent, create it using the formats in `references/LOG_FORMATS.md`. Prefer the bundled `scripts/init-project.sh` when it is available.

## Token-saving read order

At the beginning of a task, read only:

1. Repository instructions: `AGENTS.md`, `CLAUDE.md`, and relevant nested instruction files.
2. `.agent-coordination/CURRENT_STATE.md`.
3. Open items in `.agent-coordination/RISKS.md`.
4. The newest relevant decisions in `.agent-coordination/DECISIONS.md`.
5. Only the last two handoff entries in `.agent-coordination/WORKLOG.md`.
6. The exact files, commit, or diff referenced by those entries.

Read older history only when the current snapshot or referenced evidence is insufficient. Never ingest the entire worklog by default.

## Start protocol

Before substantial edits:

1. Determine the requested scope and the active agent identity.
2. Inspect `git status --short`, current branch, and current `HEAD`.
3. Read the coordination files using the token-saving order above.
4. Check `ACTIVE_SESSION.md`.
   - If it shows an active different agent working on overlapping files, stop and report the collision.
   - If clearly stale, mark it stale in the next handoff and continue cautiously.
5. Review the previous agent's latest relevant changes before building on them.
6. Record the current agent, timestamp, branch, starting commit, task, and intended file scope in `ACTIVE_SESSION.md`.
7. Continue the user's task. Do not create a diary entry for every command; write one compact handoff at the end of the meaningful unit of work.

## While working

- Follow the repository's existing architecture, tests, formatting, and deployment rules.
- Prefer the smallest correct change.
- Verify assumptions by reading code or running targeted commands.
- When discovering a material issue in another agent's work, record evidence without blame.
- Update `DECISIONS.md` only for durable decisions that a future agent must preserve.
- Update `RISKS.md` only for unresolved or explicitly accepted risks.
- Keep detailed raw output in temporary local files only when needed; summarize the result in the ledger.
- If the task changes scope, update `ACTIVE_SESSION.md`.

## Handoff protocol

At the end of every substantial task or before switching agents:

1. Review the actual diff and remove accidental or unrelated changes.
2. Run the most relevant available checks: tests, lint, type-check, build, security scan, or a focused manual verification.
3. Record failures honestly. Distinguish:
   - passed,
   - failed,
   - not run,
   - blocked,
   - not applicable.
4. Append exactly one structured entry to `WORKLOG.md` using `references/LOG_FORMATS.md`.
5. Update `CURRENT_STATE.md` so a new agent can resume without reading the full history.
6. Add or update material decisions and open risks.
7. Mark `ACTIVE_SESSION.md` as closed. Do not leave it looking active.
8. In the user-facing response, summarize the result and point to unresolved blockers. Do not paste the whole ledger.

A handoff must include:

- agent and timestamp,
- task and scope,
- starting and ending commit or working-tree state,
- files changed,
- behavior implemented,
- commands/checks with outcomes,
- decisions made,
- unresolved issues and risks,
- exact next recommended action,
- whether commit, push, deployment, or migration occurred.

Keep a normal handoff under 60 lines and roughly 800 words. Use file paths and commit hashes instead of full diffs.

## Takeover review

When taking over work from the other agent:

1. Read its latest relevant handoff and inspect the referenced diff or commit.
2. Confirm that the reported checks match available evidence.
3. Look for obvious regressions, incomplete migrations, unhandled errors, exposed secrets, unsafe defaults, broken localization, inaccessible UI, and deployment mismatches.
4. Fix issues that are within the current authorized scope.
5. Record any material finding in the next handoff and, when unresolved, in `RISKS.md`.

This is a focused continuity review, not the full final audit.

## Reciprocal milestone and final audit

Run a full reciprocal audit only when the user requests it or a major milestone/project is presented as complete.

Load `references/AUDIT_CHECKLIST.md` only for this mode.

Required sequence:

1. Freeze the candidate scope by recording the branch, commit range, deployment target, and expected behavior in `FINAL_AUDIT.md`.
2. Claude independently audits Codex-authored changes.
3. Codex independently audits Claude-authored changes.
4. Each finding must include severity, evidence, affected files, impact, reproduction or reasoning, recommended remediation, owner, and status.
5. The author may fix a finding, but the other agent must verify closure.
6. Do not mark a finding closed solely because code changed.
7. Re-run relevant tests/build/scans after fixes.
8. Produce a final residual-risk summary.

Severity:

- `CRITICAL`: likely active compromise, irreversible data loss, major privacy exposure, or unsafe production operation.
- `HIGH`: exploitable vulnerability, broken authorization, significant privacy/compliance exposure, or major functional failure.
- `MEDIUM`: meaningful defect or weakness with limited reach or requiring special conditions.
- `LOW`: minor hardening, maintainability, accessibility, documentation, or edge-case issue.
- `INFO`: observation or future improvement without a current defect.

Completion rule:

- No unresolved `CRITICAL` or `HIGH` finding may be presented as fully approved.
- Any accepted risk must name the human approver, date, rationale, and expiry/review date.
- Legal and regulatory items are risk flags, not legal advice. Recommend qualified legal review when jurisdiction, contracts, licensing, employment, health, finance, children, biometrics, or sensitive personal data are involved.
- If only one agent performed the audit, label it `PROVISIONAL — SECOND AGENT REVIEW REQUIRED`.

## Failure and interruption protocol

If blocked or interrupted:

1. Do not pretend completion.
2. Leave the working tree in the safest recoverable state available.
3. Append a handoff marked `BLOCKED` or `INTERRUPTED`.
4. Record the exact command/error summary, what was attempted, what remains, and the safest next step.
5. Close or mark stale the active session.
6. Never include secrets from error output.

## Expected invocation modes

Interpret the user's request or invocation argument as one of:

- `start`: initialize/read the ledger and begin a task.
- `handoff`: verify current work and write the end-of-task handoff.
- `takeover`: review the previous agent's work, then continue.
- `audit`: perform a focused independent audit of the other agent's changes.
- `final-audit`: run the full reciprocal completion process.
- `status`: summarize `CURRENT_STATE.md`, open risks, and the last relevant handoff without modifying code.

When no mode is stated, apply `start` automatically at the beginning of substantial work and `handoff` before finishing.
