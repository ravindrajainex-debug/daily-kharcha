# Supabase setup — Daily Kharcha

This folder contains the first PostgreSQL migration for the multi-company backend.

## Important
Do not run this migration against a production database until the project has been created, backups are configured, and the migration has been reviewed. The current website is not connected to Supabase.

## Apply locally / in a test project
1. Create a Supabase project for Daily Kharcha.
2. Install the Supabase CLI and link the project.
3. Review the SQL migration.
4. Apply it to a test project first:
   `supabase db push`
5. Create two test companies and users, then test tenant isolation using their real authenticated sessions.
6. Only after security tests pass, plan the application and server-function integration.

Never put the Supabase service-role key in HTML, JavaScript delivered to a browser, GitHub Pages, or a public repository. A browser must use the publishable/anon key with RLS enabled.

## Migration
- `migrations/202611010001_multi_company_core.sql`

See `docs/MULTI_COMPANY_FOUNDATION.md` for the roles, onboarding flow, and release gates.
