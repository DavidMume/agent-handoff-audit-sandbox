# Coordination log formats

Use ISO 8601 timestamps with timezone when available. Keep entries factual and concise.

## CURRENT_STATE.md

```markdown
# Current State

- Updated: YYYY-MM-DDTHH:MM:SS±HH:MM
- Updated by: Claude | Codex | Other
- Repository:
- Branch:
- HEAD:
- Working tree: clean | modified | conflicted
- Project phase:
- Current objective:
- Last completed:
- In progress:
- Next action:
- Build status: passed | failed | not run | blocked | n/a
- Test status: passed | failed | not run | blocked | n/a
- Deployment status: deployed | not deployed | failed | unknown | n/a
- Open critical/high risks: none | list IDs
- Important files:
  - `path`: purpose
- Resume notes:
  - concise fact
```

## WORKLOG.md entry

Append entries; never edit old entries.

```markdown
## YYYY-MM-DDTHH:MM:SS±HH:MM — Claude | Codex — COMPLETE | PARTIAL | BLOCKED | INTERRUPTED

- Task:
- Scope:
- Started from: branch `...`, commit `...`, working tree `clean|modified`
- Ended at: branch `...`, commit `...|uncommitted`, working tree `clean|modified`
- Files changed:
  - `path`: concise change
- Implemented:
  - observable behavior
- Verification:
  - `command` — PASSED | FAILED | NOT RUN | BLOCKED | N/A — concise evidence
- Decisions:
  - decision ID or `none`
- Risks / unresolved:
  - risk ID and next action, or `none`
- Commit/push/deploy:
  - exact status and identifiers; never infer
- Next agent:
  - exact recommended action
```

## DECISIONS.md entry

```markdown
## DEC-YYYYMMDD-NN — Short title

- Date:
- Made by:
- Status: active | superseded | provisional
- Context:
- Decision:
- Alternatives considered:
- Consequences:
- Related files/issues:
- Supersedes:
```

## RISKS.md entry

```markdown
## RISK-YYYYMMDD-NN — Short title

- Opened:
- Opened by:
- Severity: CRITICAL | HIGH | MEDIUM | LOW | INFO
- Status: open | mitigated | accepted | closed
- Area: security | privacy | legal | reliability | data | deployment | dependency | accessibility | other
- Evidence:
- Impact:
- Recommended action:
- Owner:
- Verification required:
- Acceptance details: human approver, rationale, review/expiry date; otherwise `not accepted`
```

## ACTIVE_SESSION.md

```markdown
# Active Session

- Status: active | closed | stale
- Agent:
- Started:
- Updated:
- Branch:
- Starting commit:
- Task:
- Intended scope:
  - `path or subsystem`
- Notes:
```

## FINAL_AUDIT.md finding

```markdown
## FINDING-YYYYMMDD-NN — Short title

- Auditor: Claude | Codex
- Author reviewed: Claude | Codex | mixed
- Severity: CRITICAL | HIGH | MEDIUM | LOW | INFO
- Status: open | fix-in-progress | ready-for-verification | closed | accepted
- Category:
- Affected files/commits:
- Evidence:
- Impact:
- Reproduction or reasoning:
- Recommended remediation:
- Fix owner:
- Fixed in:
- Verified by:
- Verification command/evidence:
- Residual risk:
```

## Final sign-off

```markdown
# Final Audit Sign-off

- Candidate branch/commit:
- Commit range reviewed:
- Deployment target:
- Claude audit status: complete | provisional | not run
- Codex audit status: complete | provisional | not run
- Tests/build/scans:
- Critical open:
- High open:
- Accepted risks:
- Legal review recommended:
- Privacy review recommended:
- Final status: APPROVED | APPROVED WITH ACCEPTED RISKS | NOT APPROVED | PROVISIONAL
- Signed by agents:
- Human approval:
```
