# Daily Kharcha — role and data-access matrix

**Status: design baseline only.** This document does not mean the permissions have been implemented or tested. The database migrations remain blocked from production use until the security review and automated tests pass.

## Roles
- **Platform Owner:** manages the Daily Kharcha service, reviews company applications, plans, subscriptions and support. Routine access to customer salary, receipts and employee location is not required.
- **Company Admin:** manages one approved company workspace, its people, configuration and business records.
- **HR:** manages permitted employee administration, attendance and leave workflows within one company. Salary access must be explicitly granted by company policy and must not be assumed.
- **Employee:** accesses their own profile, expenses, attendance, leave and any salary statement explicitly released to them.

## Default access rules

| Data area | Platform Owner | Company Admin | HR | Employee |
|---|---|---|---|---|
| Company applications | Review all | No | No | Submit and view own |
| Company profile/settings | Platform-level status only | Manage own company | Read permitted fields | Read permitted fields |
| Employee profiles | No routine personal-data access | Manage own company | Manage approved HR fields | Own profile only |
| Expenses | No routine content access | Company expenses | Company expenses if enabled | Own expenses |
| Attendance records | No routine access | Company attendance | Company attendance | Own attendance |
| Precise attendance locations | No routine access | Restricted, justified access | Restricted, justified access | Own records |
| Leave requests/balances | No routine access | Company oversight | Manage company workflow | Own requests/balance |
| Salary records | No routine access | Explicitly authorized finance role only | No by default | Own released statements only |
| Employee assets | No routine access | Manage own company | Manage own company | Own issued assets |
| Samples and orders | No routine access | Company records | Only if granted | Only assigned/created records |
| Audit history | Platform security metadata only | Own-company audit | Limited HR audit if granted | No |
| Support tickets | Platform support queue | Own-company tickets | Own-company tickets | Submit/view own tickets |
| Subscription/payment status | Platform-wide | Own company only | No | No |

## Mandatory database controls
1. Deny access by default. Every table must have RLS enabled and an explicit policy for each allowed operation.
2. Company membership and role are server-controlled. Browser users must not insert or update their own company_id, role, active, approval state or reviewer fields.
3. Enforce same-company relationships in database constraints, not only in form validation.
4. Separate SELECT, INSERT, UPDATE and DELETE permissions. Do not use broad FOR ALL policies for sensitive records.
5. Salary, precise location, bank/UPI details, private attachments, audit events and historical revisions need separate narrow policies.
6. Use private Storage buckets. Authorize each file using its company and owning record; do not expose public URLs for receipts or employee documents.
7. Create audit events and expense revisions through trusted database triggers or server-side functions, not client-submitted history.
8. Keep platform-owner provisioning outside public signup. Never let a user grant themselves the owner role.
9. Do not put a Supabase service-role key or database password in frontend code, repository files, screenshots or chat.

## Required tests before real data
Use a disposable test project with two unrelated companies and test identities for all four roles. Verify both allowed and denied SELECT/INSERT/UPDATE/DELETE operations, including attempts to change role/company IDs, link another company's employee/category/file, approve an application twice, forge audit history, and read salary/location data without authorization. Tests must fail the deployment if any cross-company access succeeds.

## Delivery gate
The current schema and migrations are not approved for production. Do not run them on the active Supabase project. First redesign the migrations, add executable automated RLS tests, review the full migration sequence on a disposable project, and document backup/restore and incident procedures. Only then connect the website to real customer data.