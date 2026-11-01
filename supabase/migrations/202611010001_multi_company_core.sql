-- Daily Kharcha: secure multi-company core
-- Target: Supabase PostgreSQL. Apply through Supabase migrations, not a browser.
-- This migration creates the tenant boundary; it does not by itself deploy an app.

create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null default '',
  mobile text,
  designation text,
  preferred_language text not null default 'en'
    check (preferred_language in ('en','hi','mr','gu','kn','ur')),
  is_platform_admin boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.companies (
  id uuid primary key default gen_random_uuid(),
  company_name text not null check (length(trim(company_name)) between 2 and 180),
  legal_name text,
  contact_name text not null,
  contact_email text not null,
  contact_mobile text,
  status text not null default 'pending'
    check (status in ('pending','active','rejected','suspended')),
  approved_at timestamptz,
  approved_by uuid references public.profiles(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.company_memberships (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  role text not null
    check (role in ('company_owner','company_admin','hr_admin','manager','employee')),
  status text not null default 'active'
    check (status in ('invited','active','disabled')),
  created_at timestamptz not null default now(),
  unique (company_id, user_id)
);

create index if not exists company_memberships_user_idx
  on public.company_memberships(user_id, status);
create index if not exists company_memberships_company_idx
  on public.company_memberships(company_id, status);

create table if not exists public.expenses (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies(id) on delete cascade,
  user_id uuid not null references public.profiles(id),
  expense_date date not null default current_date,
  category text not null,
  travel_mode text,
  from_location text,
  to_location text,
  description text,
  receipt_number text,
  amount numeric(12,2) not null check (amount > 0),
  status text not null default 'draft'
    check (status in ('draft','submitted','approved','rejected')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists expenses_company_date_idx
  on public.expenses(company_id, expense_date desc);
create index if not exists expenses_company_user_idx
  on public.expenses(company_id, user_id, expense_date desc);

create table if not exists public.attendance_records (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies(id) on delete cascade,
  user_id uuid not null references public.profiles(id),
  work_date date not null default current_date,
  punch_in_at timestamptz not null default now(),
  punch_out_at timestamptz,
  location_consent boolean not null default false,
  punch_in_latitude numeric(9,6),
  punch_in_longitude numeric(9,6),
  punch_out_latitude numeric(9,6),
  punch_out_longitude numeric(9,6),
  created_at timestamptz not null default now(),
  check (punch_out_at is null or punch_out_at >= punch_in_at)
);
create index if not exists attendance_company_date_idx
  on public.attendance_records(company_id, work_date desc);
create index if not exists attendance_company_user_idx
  on public.attendance_records(company_id, user_id, work_date desc);

create table if not exists public.audit_logs (
  id bigint generated always as identity primary key,
  company_id uuid references public.companies(id) on delete set null,
  actor_user_id uuid references public.profiles(id) on delete set null,
  action text not null,
  entity_type text not null,
  entity_id text,
  details jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);
create index if not exists audit_logs_company_created_idx
  on public.audit_logs(company_id, created_at desc);

-- SECURITY DEFINER helpers avoid recursive membership RLS checks.
create or replace function public.is_platform_admin()
returns boolean
language sql stable security definer
set search_path = public, pg_temp
as $$
  select coalesce((
    select p.is_platform_admin
    from public.profiles p
    where p.id = auth.uid()
  ), false);
$$;

create or replace function public.has_active_company_role(
  target_company_id uuid,
  allowed_roles text[] default null
)
returns boolean
language sql stable security definer
set search_path = public, pg_temp
as $$
  select exists (
    select 1
    from public.company_memberships m
    join public.companies c on c.id = m.company_id
    where m.company_id = target_company_id
      and m.user_id = auth.uid()
      and m.status = 'active'
      and c.status = 'active'
      and (allowed_roles is null or m.role = any(allowed_roles))
  );
$$;

alter table public.profiles enable row level security;
alter table public.companies enable row level security;
alter table public.company_memberships enable row level security;
alter table public.expenses enable row level security;
alter table public.attendance_records enable row level security;
alter table public.audit_logs enable row level security;

drop policy if exists profiles_read_self_or_platform on public.profiles;
create policy profiles_read_self_or_platform on public.profiles
  for select to authenticated
  using (id = auth.uid() or public.is_platform_admin());

drop policy if exists profiles_insert_self on public.profiles;
create policy profiles_insert_self on public.profiles
  for insert to authenticated
  with check (id = auth.uid() and is_platform_admin = false);

drop policy if exists profiles_update_self on public.profiles;
create policy profiles_update_self on public.profiles
  for update to authenticated
  using (id = auth.uid() or public.is_platform_admin())
  with check (id = auth.uid() or public.is_platform_admin());

-- Users only see companies where they have an active membership.
-- The platform owner can see and manage all companies.
drop policy if exists companies_read_member_or_platform on public.companies;
create policy companies_read_member_or_platform on public.companies
  for select to authenticated
  using (public.is_platform_admin() or public.has_active_company_role(id));

drop policy if exists companies_platform_insert on public.companies;
create policy companies_platform_insert on public.companies
  for insert to authenticated
  with check (public.is_platform_admin());

drop policy if exists companies_platform_update on public.companies;
create policy companies_platform_update on public.companies
  for update to authenticated
  using (public.is_platform_admin())
  with check (public.is_platform_admin());

drop policy if exists memberships_read_self_admin_or_platform on public.company_memberships;
create policy memberships_read_self_admin_or_platform on public.company_memberships
  for select to authenticated
  using (
    user_id = auth.uid()
    or public.is_platform_admin()
    or public.has_active_company_role(company_id, array['company_owner','company_admin','hr_admin'])
  );

-- Membership creation, role changes and disabling are server-side only.
-- Never allow a browser client to grant itself an admin role.

drop policy if exists expenses_read_scoped on public.expenses;
create policy expenses_read_scoped on public.expenses
  for select to authenticated
  using (
    public.is_platform_admin()
    or (
      public.has_active_company_role(company_id)
      and (
        user_id = auth.uid()
        or public.has_active_company_role(company_id, array['company_owner','company_admin','hr_admin','manager'])
      )
    )
  );

drop policy if exists expenses_insert_self on public.expenses;
create policy expenses_insert_self on public.expenses
  for insert to authenticated
  with check (
    user_id = auth.uid()
    and public.has_active_company_role(company_id)
  );

drop policy if exists expenses_update_scoped on public.expenses;
create policy expenses_update_scoped on public.expenses
  for update to authenticated
  using (
    public.is_platform_admin()
    or (
      public.has_active_company_role(company_id)
      and (
        (user_id = auth.uid() and status in ('draft','rejected'))
        or public.has_active_company_role(company_id, array['company_owner','company_admin','hr_admin'])
      )
    )
  )
  with check (
    public.is_platform_admin()
    or (
      public.has_active_company_role(company_id)
      and (
        user_id = auth.uid()
        or public.has_active_company_role(company_id, array['company_owner','company_admin','hr_admin'])
      )
    )
  );

drop policy if exists expenses_delete_draft_self_or_admin on public.expenses;
create policy expenses_delete_draft_self_or_admin on public.expenses
  for delete to authenticated
  using (
    public.is_platform_admin()
    or (
      public.has_active_company_role(company_id)
      and (
        (user_id = auth.uid() and status = 'draft')
        or public.has_active_company_role(company_id, array['company_owner','company_admin','hr_admin'])
      )
    )
  );

drop policy if exists attendance_read_scoped on public.attendance_records;
create policy attendance_read_scoped on public.attendance_records
  for select to authenticated
  using (
    public.is_platform_admin()
    or (
      public.has_active_company_role(company_id)
      and (
        user_id = auth.uid()
        or public.has_active_company_role(company_id, array['company_owner','company_admin','hr_admin','manager'])
      )
    )
  );

drop policy if exists attendance_insert_self on public.attendance_records;
create policy attendance_insert_self on public.attendance_records
  for insert to authenticated
  with check (
    user_id = auth.uid()
    and public.has_active_company_role(company_id)
  );

drop policy if exists attendance_update_self_or_admin on public.attendance_records;
create policy attendance_update_self_or_admin on public.attendance_records
  for update to authenticated
  using (
    public.is_platform_admin()
    or (
      public.has_active_company_role(company_id)
      and (
        user_id = auth.uid()
        or public.has_active_company_role(company_id, array['company_owner','company_admin','hr_admin'])
      )
    )
  )
  with check (
    public.is_platform_admin()
    or (
      public.has_active_company_role(company_id)
      and (
        user_id = auth.uid()
        or public.has_active_company_role(company_id, array['company_owner','company_admin','hr_admin'])
      )
    )
  );

drop policy if exists audit_logs_read_scoped on public.audit_logs;
create policy audit_logs_read_scoped on public.audit_logs
  for select to authenticated
  using (
    public.is_platform_admin()
    or public.has_active_company_role(company_id, array['company_owner','company_admin','hr_admin'])
  );

-- Protect the platform-admin flag from self-promotion.
revoke update (is_platform_admin) on public.profiles from authenticated;
grant select on public.profiles, public.companies, public.company_memberships,
  public.expenses, public.attendance_records, public.audit_logs to authenticated;
grant insert (id, full_name, mobile, designation, preferred_language)
  on public.profiles to authenticated;
grant update (full_name, mobile, designation, preferred_language)
  on public.profiles to authenticated;
grant insert on public.expenses, public.attendance_records to authenticated;
grant update, delete on public.expenses to authenticated;
grant update on public.attendance_records to authenticated;
