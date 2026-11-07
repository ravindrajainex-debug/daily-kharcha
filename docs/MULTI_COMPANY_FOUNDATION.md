# Daily Kharcha — Multi-Company Product Foundation

## Product direction
Daily Kharcha is a multi-tenant business platform. Many unrelated companies can subscribe/request access, but each company receives an isolated workspace after approval by the Daily Kharcha Super Admin.

## Company onboarding and approval
1. Public website exposes **Request Company Access** and support contact options (call/email).
2. Online request captures legal/company name, business type, registered address, website (optional), authorised contact name/designation, work email, mobile, employee estimate, requested modules, and optional company logo.
3. A request is created with status `PENDING_VERIFICATION`; it cannot create employee accounts or access operational data.
4. Super Admin reviews details and may request clarification, approve, reject, or suspend.
5. On approval, create the tenant and invite the nominated Company Admin. Do not activate the company merely because a form was submitted.
6. Requests received by phone/email are entered by Super Admin into the same review queue, with source and verification notes recorded.

## Tenant isolation — non-negotiable
- Every tenant-owned record carries a server-assigned `tenant_id`.
- The server derives tenant membership from the authenticated session; never trust a tenant/company ID sent by the browser as authority.
- Every read, update, delete, export, report, upload, and background job is scoped to the authenticated tenant.
- Enforce tenant scoping in the database layer (prefer row-level security / equivalent policy) as well as application services.
- Company A must never be able to enumerate, guess, or retrieve Company B records by changing a URL, ID, request body, or file path.
- Super Admin access is separately authenticated, least-privilege, audited, and used only for support/administration.
- Do not use browser localStorage as the production database or for secrets, salary records, client POs, or authentication tokens.

## Roles
- `PLATFORM_SUPER_ADMIN`: verify, approve/reject/suspend tenants; manage plans, support and audit.
- `COMPANY_OWNER`: company profile, branding, billing contacts, and Company Admin appointments.
- `COMPANY_ADMIN`: employee lifecycle, roles, modules, and company settings.
- `HR_ADMIN`: attendance, leave, salary and employee records according to permission.
- `MANAGER`: assigned team visibility and approvals only.
- `EMPLOYEE`: own records and permitted self-service tasks.

## Branding
- Daily Kharcha platform identity remains visible.
- Company may optionally upload its logo (PNG/JPG/WebP, size and dimensions limited) for its workspace, A4 reports and permitted employee screens.
- Validate file type and size on the server; store files in private object storage, not public repository or browser storage. Use tenant-scoped access and signed URLs.
- Company logo is optional; default Daily Kharcha branding is used when absent.

## Core data model (initial)
- `tenants`: id, legal_name, display_name, status, plan_id, timezone, locale, logo_file_id, created_at
- `company_applications`: id, company details, authorised contact, source (web/call/email/admin), status, reviewer_id, verification notes, timestamps
- `users`: id, email, mobile, auth identity, status
- `tenant_memberships`: id, tenant_id, user_id, role, status
- `employees`: id, tenant_id, employee_code, profile fields, status
- `audit_events`: id, tenant_id nullable for platform events, actor_id, action, entity, entity_id, timestamp, metadata
- Business modules (expenses, attendance, leave, assets, salary, samples, orders, reports) all include tenant_id and appropriate employee/user ownership.

## Security and operational requirements before real customer data
- Production authentication (verified email and mobile OTP where enabled), secure session handling, MFA for platform admins, password reset and rate limiting.
- Server-side authorisation on every API endpoint; deny by default.
- Database backups, restore drills, retention policy, encryption in transit and at rest, secrets management, monitoring and incident process.
- Salary and other sensitive HR data require separate permission checks and audit trails.
- Consent-based attendance/location check-ins only; explain purpose and retention to employees.
- Privacy notice, terms, data processing terms, support and deletion/export process.
- Test tenant isolation with automated cross-tenant negative tests before launch.

## Delivery phases
1. Preserve the approved Version 4 demo and complete responsive UI review using dummy data.
2. Build public company application + Super Admin verification queue.
3. Implement backend, database, authentication, tenant isolation and audit logging.
4. Integrate existing modules under tenant-aware APIs and private file storage.
5. Test two or more sample companies, role permissions, reports, uploads, mobile layouts, backups and restore.
6. Launch only after security review; use a proper application host and managed database. GitHub Pages is static hosting and cannot provide the secure backend by itself.

## Current repository note
The current `main` branch contains an earlier single-company/local-browser prototype. This foundation branch is intentionally separate. Do not replace `main` or represent the prototype as a secure multi-company production system until the new implementation is tested and approved.
