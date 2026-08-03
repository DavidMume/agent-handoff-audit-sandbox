# Quickstart

Install and start your first handoff in under ten minutes. For explanations of any term used here, see the [README's concepts section](../README.md#important-concepts). For depth beyond this page, see the [full usage guide](USAGE_GUIDE.md).

## 1. Clone

```bash
git clone https://github.com/DavidMume/agent-handoff-audit-sandbox.git
cd agent-handoff-audit-sandbox
```

## 2. Install

```bash
bash install.sh
```

Confirm it worked:

```bash
ls -la ~/.local/share/agent-handoff-audit
ls -la ~/.claude/skills/agent-handoff-audit
ls -la ~/.agents/skills/agent-handoff-audit
```

## 3. Initialize a project

```bash
cd ~/Projects/your-project
bash ~/.local/share/agent-handoff-audit/scripts/init-project.sh .
```

This creates `.agent-coordination/` plus pointer blocks in `AGENTS.md` and `CLAUDE.md`.

## 4. Start with Claude

In your Claude Code conversation, in that project:

```text
/agent-handoff-audit start
```

Do the task as usual.

## 5. Handoff

```text
/agent-handoff-audit handoff
```

This writes one entry to `.agent-coordination/WORKLOG.md` and closes the session.

## 6. Continue with Codex

In a Codex CLI session, same project:

```text
$agent-handoff-audit takeover
```

Codex reads Claude's handoff, checks the diff, and continues. When it finishes:

```text
$agent-handoff-audit handoff
```

## 7. Final audit

When the feature/milestone is done, run the reciprocal review from each agent:

```text
/agent-handoff-audit final-audit      (Claude)
$agent-handoff-audit final-audit      (Codex)
```

No `CRITICAL` or `HIGH` finding should be left open before calling it approved.

---

Next: [full usage guide](USAGE_GUIDE.md) · [troubleshooting](TROUBLESHOOTING.md) · [filled-in examples](examples/)
