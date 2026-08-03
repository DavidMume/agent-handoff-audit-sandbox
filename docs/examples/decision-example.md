# Example: a `DECISIONS.md` entry

Fictional project — a demo recipe-sharing app. No real data.

```markdown
## DEC-20260802-01 — Use a mock email service instead of a real provider for this demo

- Date: 2026-08-02
- Made by: Claude
- Status: active
- Context: Password recovery needs to "send" an email, but this is a demo project with no real users
- Decision: Use `src/services/mockEmail.ts`, which logs the email content to the console instead of calling a real email provider
- Alternatives considered: Wiring up a real transactional email provider — rejected for now since there's no production deployment target yet
- Consequences: Any future agent adding a real email provider must replace `mockEmail.ts`'s call sites, not just its internals, and must not reuse its in-memory token store
- Related files/issues: `src/services/mockEmail.ts`, `src/components/ResetPasswordForm.tsx`
- Supersedes: none
```
