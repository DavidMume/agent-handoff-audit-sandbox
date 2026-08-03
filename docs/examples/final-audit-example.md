# Example: `FINAL_AUDIT.md` (finding + sign-off)

Fictional project — a demo recipe-sharing app. No real data.

## A finding

```markdown
## FINDING-20260802-01 — Reset tokens never expire

- Auditor: Codex
- Author reviewed: Claude
- Severity: MEDIUM
- Status: fix-in-progress
- Category: security
- Affected files/commits: `src/services/mockEmail.ts` (commit `a1b2c3d`)
- Evidence: Token generation has no expiry field; `ResetPasswordForm.tsx` accepts any stored token regardless of age
- Impact: Reset links would stay valid indefinitely in a real deployment, widening the account-takeover window
- Reproduction or reasoning: Read `generateResetToken()` in `mockEmail.ts` — no timestamp or expiry check exists anywhere in the accept path
- Recommended remediation: Add an expiry timestamp at generation and check it on redemption; add a regression test for an expired token
- Fix owner: Claude
- Fixed in: commit `b4c5d6e`
- Verified by: Codex
- Verification command/evidence: `npm test -- ResetPasswordForm` — PASSED — new "rejects expired token" test included
- Residual risk: none — closed
```

## Final sign-off

```markdown
# Final Audit Sign-off

- Candidate branch/commit: `feature/password-recovery` @ `b4c5d6e`
- Commit range reviewed: `9f8e7d6..b4c5d6e`
- Deployment target: none (demo project, not deployed)
- Claude audit status: complete
- Codex audit status: complete
- Tests/build/scans: `npm test` — PASSED; `npm run build` — PASSED
- Critical open: 0
- High open: 0
- Accepted risks: none
- Legal review recommended: no — no real user data, no production deployment
- Privacy review recommended: no — demo project, mock data only
- Final status: APPROVED
- Signed by agents: Claude, Codex
- Human approval: pending (project owner to confirm before merge)
```
