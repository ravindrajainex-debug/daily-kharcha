# Daily Kharcha — security review before database setup

**Status: NOT READY for production data. Do not apply the current SQL files to the live Supabase project yet.**

This review is based on the current `cloud-backend-foundation` branch. It is a planning and code-review document, not a penetration test or formal security certification.

## Confirmed project direction

- One shared application with separate company workspaces.
- Platform Owner approves company applications.
- Company Admin, HR and Employee roles.
- Company data must be isolated in PostgreSQL Row Level Security (RLS), not only in the user interface.
- Salary, personal details, receipts and location data require stricter access than ordinary expense records.

## Blocking issues found in the current SQL

1. **Initial schema and migrations are not yet a safe deployment sequence.** The base schema creates permissive/incomplete policies and does not establish a complete, tested onboarding path.
2. **Profile security needs redesign.** Role and company membership must be assigned only by trusted server-side operations. A user must never be able to set their own role, company, or active status.
3. **Company approval needs stronger safeguards.** The approval function must verify owner authority, prevent duplicate provisioning, and ensure the applicant's auth account and application state are valid. The platform-owner bootstrap must be documented and performed through a trusted administrative process.
4. **Cross-company relationships need database constraints.** Foreign keys such as expense employee, category, assigned employee, leave reviewer and asset employee must prove that related records belong to the same company.
5. **Sensitive tables need separate policies.** Salary, attendance location, employee assets, audit events, expense revisions, support tickets and company payment details must not inherit broad company-admin/HR access by default.
6. **Client-side writes must be constrained.** Employees must not alter approval fields, reviewer fields, audit events, historical revisions, payment state, or other server-controlled values.
7. **Storage is not configured.** Receipt and sample files must use private buckets with policies enforcing company and record ownership. Public file URLs are not acceptable for private records.
8. **Audit and history are incomplete.** Important changes should be recorded by trusted database triggers or server-side functions; clients must not be able to forge audit entries or revisions.
9. **Automated security tests are missing.** The existing checklist is manual documentation, not executable tests. Add tests for two companies and every role before enabling real customer data.
10. **Operational protections are missing.** Add backup/restore procedures, retention rules, error monitoring, rate limits, and a documented incident response process before launch.

## Safe implementation order

1. Keep the current SQL files as an unapproved draft; do not run them on the active project.
2. Design a clean, ordered migration set with explicit grants, deny-by-default RLS, trusted onboarding, and company-consistent foreign keys.
3. Add automated database tests for cross-company access and role boundaries.
4. Review the complete migration set as a whole and test it on a disposable Supabase project.
5. Only after passing tests, apply it to the intended project and configure Auth, private Storage, backups and environment variables.
6. Connect the website screens to the cloud backend and test with dummy accounts and dummy data.
7. Do not upload actual employee, salary, bank, receipt or location information until the security review is complete.

## Important credentials rule

The browser application may use the Supabase project URL and publishable/anon key with RLS enabled. Never put the Supabase `service_role` key, database password, or other secret in browser code, GitHub, screenshots, or chat.

## Current project state

The Supabase SQL Editor test `SELECT 1;` is harmless and only confirms that the editor can execute a simple query. It has not created the Daily Kharcha tables. No production schema should be assumed to exist.
