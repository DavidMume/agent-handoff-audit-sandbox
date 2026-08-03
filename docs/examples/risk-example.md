# Example: a `RISKS.md` entry

Fictional project — a demo recipe-sharing app. No real data.

```markdown
## RISK-20260802-01 — Password reset tokens never expire

- Opened: 2026-08-02T11:10:00-05:00
- Opened by: Codex
- Severity: MEDIUM
- Status: open
- Area: security
- Evidence: `src/services/mockEmail.ts` generates a reset token with no expiry field; `ResetPasswordForm.tsx` accepts any token that exists in the in-memory store, regardless of age
- Impact: In a real deployment (not this demo), an intercepted or leaked reset link would remain valid indefinitely, extending the window for account takeover
- Recommended action: Add an expiry timestamp to each token and reject expired ones before wiring this up to a real email service or database
- Owner: unassigned
- Verification required: A test confirming an expired token is rejected
- Acceptance details: not accepted
```
