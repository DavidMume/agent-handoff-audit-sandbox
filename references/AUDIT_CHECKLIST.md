# Reciprocal audit checklist

Apply only items relevant to the project. Record evidence, not generic assurances.

## 1. Scope and provenance

- Confirm branch, commit range, uncommitted changes, generated files, migrations, environment changes, and deployed version.
- Attribute changes to Claude, Codex, mixed authorship, or unknown using worklog and Git history.
- Confirm no task, file, test, or deployment was omitted from the claimed completion.
- Check for accidental large files, credentials, local paths, debug artifacts, copied datasets, and license-incompatible material.

## 2. Functional correctness

- Compare implementation with the user's acceptance criteria.
- Test happy paths, failure paths, empty states, boundary values, retries, concurrency, cancellation, and partial completion.
- Check stale state, race conditions, idempotency, timezone/date handling, locale, encoding, numeric precision, and destructive operations.
- Verify data migrations, rollback behavior, backward compatibility, and import/export integrity.
- Verify bilingual content has equal functionality and numeric consistency where applicable.

## 3. Security

Review, where relevant:

- Authentication, session management, password reset, MFA assumptions, token expiry, logout, and account recovery.
- Authorization, object-level access, tenant isolation, admin boundaries, privilege escalation, and insecure direct object references.
- Input validation and output encoding.
- SQL/NoSQL/LDAP/template/command/code injection.
- XSS, CSRF, SSRF, open redirects, path traversal, unsafe file upload, archive extraction, and deserialization.
- API keys, secrets, certificates, environment variables, logs, source maps, client bundles, Git history, and example files.
- Cryptography choices, transport security, storage encryption, random generation, and key lifecycle.
- CORS, CSP, security headers, cookies, caching, rate limits, abuse controls, replay, and enumeration.
- Dependency and supply-chain risk: lockfiles, install scripts, typosquatting, abandoned packages, known vulnerabilities, and excessive permissions.
- Cloud/IAM configuration, public buckets, database rules, serverless bindings, preview deployments, and production/debug separation.
- CI/CD permissions, untrusted pull requests, artifact integrity, deployment provenance, and rollback.
- Denial-of-service, unbounded queries, file sizes, loops, memory, queues, and cost-amplification paths.
- Mobile-specific storage, screenshots, pasteboard, deep links, universal links, entitlements, backups, and device logs.

Never exploit a live third-party system. Use safe local or authorized testing only.

## 4. Privacy and data governance

- Identify personal, sensitive, financial, health, location, child, biometric, credential, and behavioral data.
- Verify data minimization, purpose limitation, consent where relevant, collection notices, and user expectations.
- Check retention, deletion, export, correction, account closure, backups, and downstream processors.
- Check analytics, cookies, advertising identifiers, crash reports, telemetry, logs, support tools, and third-party SDKs.
- Ensure development/test data is synthetic or properly protected.
- Check access controls for staff, administrators, vendors, and family/shared-account roles.
- Flag cross-border transfer, residency, re-identification, model-training, and automated-decision risks.
- Ensure secrets or personal data are not written to `.agent-coordination/`.

## 5. Potential legal and compliance risks

This is issue spotting, not legal advice.

- Open-source licenses, attribution, notices, source-disclosure obligations, fonts, images, datasets, maps, articles, trademarks, and generated assets.
- Terms of service, API usage rights, scraping restrictions, rate limits, and platform policies.
- Privacy policy, cookie notice, consent records, processor agreements, and contact/deletion mechanisms.
- Consumer claims, pricing, subscriptions, refunds, warranties, misleading statements, dark patterns, and accessibility obligations.
- Employment, immigration, financial, medical, legal, political, educational, or safety claims that users may rely on.
- Children or family accounts, parental consent, school data, and age-appropriate design.
- Defamation, impersonation, copyright, election-related content, and moderation obligations.
- Jurisdiction-specific requirements and whether qualified counsel is needed.
- Record each concern with the applicable feature and jurisdiction uncertainty; never state definitive legal compliance without qualified review.

## 6. Reliability and operations

- Error handling, retries, timeouts, circuit breakers, fallbacks, offline behavior, and recovery after interruption.
- Observability without leaking secrets or personal data.
- Backups, restore tests, migration safety, rollback, disaster recovery, and incident response.
- Environment parity, configuration validation, health checks, cold starts, quotas, billing/cost limits, and external-service failure.
- Domain, redirects, canonical URLs, asset paths, cache invalidation, robots, sitemap, and direct-route refresh behavior for web deployments.
- Ensure build output excludes `.agent-coordination/`.

## 7. Frontend, UX, accessibility, and internationalization

- Keyboard navigation, focus, labels, landmarks, contrast, motion preferences, zoom, screen readers, form errors, and touch targets.
- Responsive layouts on mobile, tablet, and desktop.
- Loading, empty, offline, error, permission-denied, and partial-data states.
- Translation completeness; no hardcoded user-facing strings where a translation system exists.
- Natural Spanish and English wording, preserved numbers, locale-aware dates, and stored language preference.
- Links, buttons, tooltips, charts, legends, downloadable content, and non-color alternatives.
- Prevent deceptive or irreversible actions without confirmation.

## 8. Data and model integrity

- Dataset provenance, licenses, timestamps, missingness, transformations, joins, duplicates, leakage, and reproducibility.
- No invented statistics or unsupported causal claims.
- Model/version provenance, evaluation set integrity, bias, drift, confidence, uncertainty, and failure disclosure.
- Prompt injection and untrusted retrieved content for AI/RAG systems.
- Human review and appeal paths for consequential outputs.
- Separation between exploratory and validated/published results.

## 9. Tests and evidence

- Run the repository's documented checks.
- Add targeted regression tests for confirmed defects when proportionate.
- Record exact commands and concise outcomes.
- Distinguish automated tests, manual checks, static analysis, dependency scans, and production verification.
- Re-run relevant checks after fixes.
- Verify the deployed artifact corresponds to the audited commit.

## 10. Closure rules

- The agent that authored a fix cannot be the sole verifier of the related finding.
- Do not close findings without reproducible verification evidence.
- No full approval with unresolved critical/high findings.
- Accepted risk requires named human approval, rationale, and review/expiry date.
- When one agent is unavailable, mark the audit provisional.
