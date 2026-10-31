-- Daily Kharcha SaaS foundation (additive migration)
-- Apply only after the initial supabase/schema.sql on a fresh project.
-- This migration adds platform ownership, company approval, plans, subscriptions and support.

create extension if not exists pgcrypto;

alter table public.companies
  add column if not exists approval_status text not null default 'pending'
    check (approval_status in ('pending','approved','rejected','suspended')),
  add column if not exists approved_at timestamptz,
  add column if not exists approved_by uuid references auth.users(id),
  add column if not exists subscription_status text not null default 'inactive'
    check (subscription_status in ('inactive','trial','active','past_due','expired','cancelled'));

create table if not exists public.platform_owners (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

create table if not exists public.company_applications (
  id uuid primary key default gen_random_uuid(),
  applicant_user_id uuid not null references auth.users(id) on delete cascade,
  company_name text not null,
  contact_name text not null,
  email text not null,
  mobile text not null,
  designation text,
  gstin text,
  address text,
  status text not null default 'pending'
    check (status in ('pending','approved','rejected')),
  reviewed_by uuid references auth.users(id),
  reviewed_at timestamptz,
  review_note text,
  created_company_id uuid references public.companies(id),
  created_at timestamptz not null default now()
);

create table if not exists public.subscription_plans (
  id uuid primary key default gen_random_uuid(),
  plan_code text not null unique,
  plan_name text not null,
  billing_interval text not null check (billing_interval in ('monthly','yearly')),
  price_inr numeric(12,2) not null check (price_inr >= 0),
  max_employees integer,
  features jsonb not null default '{}'::jsonb,
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.company_subscriptions (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies(id) on delete cascade,
  plan_id uuid not null references public.subscription_plans(id),
  status text not null default 'pending'
    check (status in ('pending','trial','active','past_due','expired','cancelled')),
  starts_at timestamptz,
  ends_at timestamptz,
  amount_inr numeric(12,2) not null check (amount_inr >= 0),
  payment_reference text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (ends_at is null or starts_at is null or ends_at > starts_at)
);

create table if not exists public.support_tickets (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies(id) on delete cascade,
  raised_by uuid not null references auth.users(id),
  subject text not null,
  description text not null,
  priority text not null default 'normal' check (priority in ('low','normal','high','urgent')),
  status text not null default 'open' check (status in ('open','in_progress','waiting','resolved','closed')),
  assigned_owner uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.platform_owners enable row level security;
alter table public.company_applications enable row level security;
alter table public.subscription_plans enable row level security;
alter table public.company_subscriptions enable row level security;
alter table public.support_tickets enable row level security;

create or replace function public.is_platform_owner()
returns boolean
language sql stable security definer
set search_path = public, pg_temp
as $$
  select exists(select 1 from public.platform_owners where user_id = auth.uid())
$$;

revoke all on function public.is_platform_owner() from public;
grant execute on function public.is_platform_owner() to authenticated;

create policy platform_owner_read_self on public.platform_owners
  for select to authenticated using (user_id = auth.uid());

create policy applications_submit_self on public.company_applications
  for insert to authenticated with check (applicant_user_id = auth.uid() and status = 'pending' and reviewed_by is null and created_company_id is null);
create policy applications_read_self_or_owner on public.company_applications
  for select to authenticated using (applicant_user_id = auth.uid() or public.is_platform_owner());
create policy applications_review_owner on public.company_applications
  for update to authenticated using (public.is_platform_owner()) with check (public.is_platform_owner());

create policy plans_read_active on public.subscription_plans
  for select to authenticated using (active = true or public.is_platform_owner());
create policy plans_manage_owner on public.subscription_plans
  for all to authenticated using (public.is_platform_owner()) with check (public.is_platform_owner());

create policy subscriptions_read_company_or_owner on public.company_subscriptions
  for select to authenticated using (company_id = public.current_company_id() or public.is_platform_owner());
create policy subscriptions_manage_owner on public.company_subscriptions
  for all to authenticated using (public.is_platform_owner()) with check (public.is_platform_owner());

create policy support_read_company_or_owner on public.support_tickets
  for select to authenticated using (company_id = public.current_company_id() or public.is_platform_owner());
create policy support_create_company_member on public.support_tickets
  for insert to authenticated with check (company_id = public.current_company_id() and raised_by = auth.uid());
create policy support_update_owner on public.support_tickets
  for update to authenticated using (public.is_platform_owner()) with check (public.is_platform_owner());

create index if not exists applications_status_created_idx on public.company_applications(status, created_at desc);
create index if not exists subscriptions_company_end_idx on public.company_subscriptions(company_id, ends_at desc);
create index if not exists support_company_status_idx on public.support_tickets(company_id, status, created_at desc);

-- IMPORTANT:
-- 1) Do not add platform owner users through public signup. Insert the owner's auth user UUID
--    into platform_owners only through a trusted SQL/admin process after account verification.
-- 2) Do not let browser clients approve applications or create company Admin profiles.
--    Approval and first-Admin provisioning must be implemented in a trusted server-side function.
-- 3) Do not expose service_role credentials in the browser or repository.
-- 4) Existing tables/policies still require a full security review and automated RLS tests
--    before any real employee, salary, receipt or location data is stored.
