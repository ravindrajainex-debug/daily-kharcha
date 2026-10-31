# Daily Kharcha cloud backend foundation

Selected stack: Supabase (PostgreSQL, Auth and Storage) plus GitHub source control. The existing GitHub Pages HTML remains a visual/local demo; this branch is the backend foundation and does not yet convert every screen to cloud data.

## Setup steps
1. Create a Supabase account/project under the owner's email and choose a nearby India region if available.
2. Run supabase/schema.sql in the Supabase SQL Editor on a fresh project.
3. Set VITE_SUPABASE_URL and VITE_SUPABASE_ANON_KEY in the deployment host.
4. Configure email/OTP authentication, storage buckets and strict bucket policies. Keep Row Level Security enabled.
5. Create the first company and Admin profile using a controlled server-side onboarding process. Never let public sign-up choose an Admin role.
6. Connect the app to a host supporting environment variables, test privately, then point DailyKharcha.in to it.

## Security notes
- Never put a Supabase service_role key in frontend code or GitHub.
- This schema is a foundation, not a production security certification. HR/Admin payroll visibility, onboarding, storage access, audit triggers and RLS need review and automated tests before real employee data is entered.
- Browser GPS requires consent and permission; browsers cannot guarantee hourly background location while closed. Reliable background tracking requires a consented native app and separate review.
- Payment gateway integration is not included; bank/UPI data must be access-restricted and Cashfree secrets kept server-side.

## Next build stages
1. Connect the approved colorful UI to Supabase Auth and company-scoped data services.
2. Add invitation/onboarding and role management on the server.
3. Add private receipt/sample storage and immutable revision/audit history.
4. Add RLS workflow tests and deploy a private test environment.
5. Complete owner acceptance testing before public-domain launch.
