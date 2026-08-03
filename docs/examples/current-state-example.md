# Example: `CURRENT_STATE.md`

Fictional project — a demo recipe-sharing app. No real data.

```markdown
# Current State

- Updated: 2026-08-02T11:15:00-05:00
- Updated by: Codex
- Repository: recipe-share-demo
- Branch: feature/password-recovery
- HEAD: a1b2c3d
- Working tree: clean
- Project phase: MVP feature work
- Current objective: Add password recovery to the login flow
- Last completed: Login form with client-side validation (Claude, 2026-08-02T09:40:00-05:00)
- In progress: "Forgot password" email link and reset form
- Next action: Wire the reset form to the mock email service and add its test
- Build status: passed
- Test status: passed
- Deployment status: not deployed
- Open critical/high risks: none
- Important files:
  - `src/components/LoginForm.tsx`: existing login form
  - `src/components/ResetPasswordForm.tsx`: new, in progress
  - `src/services/mockEmail.ts`: fake email sender used in dev/test
- Resume notes:
  - Reset tokens are stored in-memory for the demo; no real database yet
  - Email content is logged to the console, never actually sent
```
