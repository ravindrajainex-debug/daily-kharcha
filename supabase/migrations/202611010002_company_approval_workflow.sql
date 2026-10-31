-- Daily Kharcha: trusted company approval workflow
-- Apply after 202611010001_saas_foundation.sql on the same Supabase project.
-- This function is the only intended path to create the first Company Admin.

create or replace function public.review_company_application(
  p_application_id uuid,
  p_decision text,
  p_review_note text default null
)
returns uuid
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_app public.company_applications%rowtype;
  v_company_id uuid;
begin
  if auth.uid() is null or not public.is_platform_owner() then
    raise exception 'Only the platform owner can review company applications'
      using errcode = '42501';
  end if;

  if p_decision not in ('approved','rejected') then
    raise exception 'Decision must be approved or rejected'
      using errcode = '22023';
  end if;

  select * into v_app
  from public.company_applications
  where id = p_application_id
  for update;

  if not found then
    raise exception 'Application not found' using errcode = 'P0002';
  end if;

  if v_app.status <> 'pending' then
    raise exception 'Only pending applications can be reviewed'
      using errcode = '55000';
  end if;

  if p_decision = 'rejected' then
    update public.company_applications
      set status = 'rejected',
          reviewed_by = auth.uid(),
          reviewed_at = now(),
          review_note = p_review_note
    where id = p_application_id;
    return null;
  end if;

  insert into public.companies (
    name, legal_name, email, phone, address, gstin,
    approval_status, approved_at, approved_by, subscription_status
  )
  values (
    v_app.company_name, v_app.company_name, v_app.email, v_app.mobile,
    v_app.address, v_app.gstin, 'approved', now(), auth.uid(), 'inactive'
  )
  returning id into v_company_id;

  insert into public.profiles (
    id, company_id, full_name, designation, mobile, role, active
  )
  values (
    v_app.applicant_user_id, v_company_id, v_app.contact_name,
    v_app.designation, v_app.mobile, 'admin', true
  );

  update public.company_applications
    set status = 'approved',
        reviewed_by = auth.uid(),
        reviewed_at = now(),
        review_note = p_review_note,
        created_company_id = v_company_id
  where id = p_application_id;

  return v_company_id;
end;
$$;

revoke all on function public.review_company_application(uuid,text,text) from public;
grant execute on function public.review_company_application(uuid,text,text) to authenticated;

comment on function public.review_company_application(uuid,text,text) is
'Platform-owner-only atomic approval/rejection. Approval creates the company and its first admin profile in one database transaction.';

-- Ensure customers cannot directly create or alter platform approval state.
drop policy if exists company_read on public.companies;
create policy company_read on public.companies
  for select to authenticated
  using (id = public.current_company_id() or public.is_platform_owner());

-- The platform owner can see application status; applicants can see only their own.
-- Company rows and first-admin profiles are created only by the function above.
