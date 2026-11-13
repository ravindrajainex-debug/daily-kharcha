# Daily Kharcha — Multi-Company Foundation

## Decision
The first secure multi-company release uses **Supabase Auth + PostgreSQL Row Level Security (RLS)** as the initial backend foundation. It is a relational, tenant-aware design and can support many companies without creating a separate website per company.

This is a backend foundation proposal in code, not a deployed service. No Supabase project has been connected and no production credentials have been added.

## Tenant model
- One Daily Kharcha platform.
- One platform super-admin role, controlled only by a trusted server-side process.
- Many company records, each with a unique immutable UUID.
- Company memberships connect users to companies and assign one of: company_owner, company_admin, hr_admin, manager, employee.
- Business records (expenses, attendance, and future leave, assets, salary, reports, documents) carry a company_id.
- PostgreSQL RLS checks the signed-in user's active membership and company status on every database request.
- A company user must not be able to read or change another company's rows by changing a URL, request body, or browser state.

## Company onboarding and approval
1. A company submits an application. It remains pending and has no company workspace access.
2. A trusted server endpoint validates the application and stores it.
3. The platform super admin reviews and approves/rejects it.
4. Approval creates the company workspace and first company_owner membership through a trusted server process.
5. The company owner invites admins/HR/employees. Role changes and invitations are server-side only.
6. Suspended/rejected companies lose normal company access; platform admin retains oversight.

The public application endpoint and approval/invitation endpoints still need to be implemented as Supabase Edge Functions before production use. Do not expose a service-role key in browser code.

## Roles
| Role | Scope |
|---|---|
| PLATFORM_SUPER_ADMIN | All companies and platform settings |
| COMPANY_OWNER | Own company |
| COMPANY_ADMIN | Own company |
| HR_ADMIN | Own company HR functions |
| MANAGER | Own company team functions |
| EMPLOYEE | Own personal records and permitted team information |

The first migration protects company-level reads and writes. Fine-grained HR, manager, approval, salary, and document permissions must be added before those modules are released.

## Current database foundation
Migration `supabase/migrations/202611010001_multi_company_core.sql` creates:
- profiles and a server-controlled platform-admin flag
- companies with pending/active/rejected/suspended states
- company memberships and roles
- tenant-scoped expenses
- tenant-scoped attendance records with optional, consent-marked location fields
- audit log storage
- RLS policies and indexes

Membership writes are deliberately not granted to browser clients. A trusted server function must create memberships and assign roles. The platform-admin flag cannot be changed by an ordinary authenticated user.

## Security rules before launch
- Apply the migration to a new Supabase project and verify the policies with at least two separate test companies.
- Add Edge Functions for company application, super-admin approval/rejection, invitation, membership changes, and secure audit events.
- Set the first platform super-admin through a one-time trusted administrative procedure; never through a public signup form.
- Keep service-role and other secrets only in server-side environment variables.
- Use server-side validation, rate limiting, email/mobile verification, secure session handling, backups, restore testing, and monitoring.
- Add automated negative tests proving Company A cannot read, update, delete, or infer Company B's records.
- Add explicit permission tests for every role, especially HR, manager, salary, and employee data.
- Do not add QR payment activation until trusted payment verification/webhooks are implemented.

## Not included yet
This foundation does not yet provide a live login screen, OTP delivery, company application UI, approval dashboard, invitations, production hosting, reports, leave, or payment processing. The existing `index.html` remains a browser-only prototype and is not connected to this database.
