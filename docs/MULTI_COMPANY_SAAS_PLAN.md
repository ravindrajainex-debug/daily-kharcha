# Daily Kharcha — Multi-company SaaS product plan

## Product direction
Daily Kharcha is one hosted software service for many independent customer companies. Each company has its own private workspace, users, HR/Admin roles, records and subscription. This is not a separate website copy for every customer.

## Account and approval journey
1. A company contact creates an account and submits a company application.
2. The application remains pending; no company workspace or administrator privileges are granted yet.
3. The platform Owner reviews the application and approves or rejects it.
4. A trusted server-side onboarding process creates the company workspace and its first Company Admin.
5. Company Admin invites HR and employees. Their access is limited by role and company.
6. The company selects/receives a subscription plan; renewal and expiry are visible to the company and platform Owner.

## Roles
- Platform Owner: manages applications, plans, subscriptions, support and platform-level usage metrics. No routine access to customer salary or private HR records.
- Company Admin: manages company profile, users, permissions, modules and company records.
- HR: gets only HR functions explicitly assigned; payroll access is separate and restricted.
- Employee: accesses own expenses, attendance, leave and assigned work.

## Commercial model
Plans can be monthly or yearly. Prices and employee limits remain configurable and are intentionally not fixed in this development stage. Payment gateway integration comes later after merchant onboarding. Manual bank/UPI payment recording can be considered for the pilot.

## Data and privacy principles
- Every business record must be scoped to a company.
- Enforce company boundaries in database Row Level Security, not only in the user interface.
- Keep payroll and location access restricted and auditable.
- Use private storage for receipts and sample photos.
- Provide data export and a clear retention/renewal policy; do not silently delete customer data.
- Location tracking must be transparent, consent-based and limited to the stated work purpose.

## Current engineering status
- Initial database schema and Supabase client are a foundation only.
- The additive SaaS migration introduces platform-owner identity, company applications, plans, subscriptions and support tickets.
- The registration approval workflow and first-admin provisioning must be implemented server-side. Do not trust a browser-supplied role or company ID.
- No Supabase project, cloud deployment, live authentication, payment gateway or production security certification exists yet.
- Do not enter real employee, payroll, bank, receipt or precise location data until security review and testing are complete.

## Next engineering stages
1. Review and test database policies, including cross-company isolation and payroll restrictions.
2. Implement trusted company approval and first-admin provisioning.
3. Connect the approved colorful interface to authentication and cloud data.
4. Add invitations, secure file storage, audit history and support workflows.
5. Add subscription status and manual payment recording, then evaluate a payment gateway.
6. Deploy a private test version and complete owner acceptance testing before public launch.
