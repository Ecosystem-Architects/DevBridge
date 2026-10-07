-- 0001_init.sql - DevBridge schema + Row Level Security
-- Policy reference table: docs/rls.md. Apply with Supabase CLI (supabase db reset)
-- or paste into the Supabase SQL editor in order.
-- RLS-first: every table is created with RLS enabled and its policies in the same block.

begin;

create extension if not exists pgcrypto; -- gen_random_uuid, crypt for seed passwords

-- ============================================================
-- 1. admin_roles - grants admin power; writable only by elevated SQL
-- ============================================================
create table if not exists public.admin_roles (
  user_id    uuid primary key references auth.users (id) on delete cascade,
  created_at timestamptz not null default now()
);

alter table public.admin_roles enable row level security;

create policy admin_roles_select_policy
  on public.admin_roles for select
  to authenticated
  using (user_id = auth.uid());

-- Grants: insert into public.admin_roles (user_id) values (...);
-- from the dashboard / service_role only. No client policies on purpose.

-- ============================================================
-- 2. Helper functions
-- ============================================================

create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (select 1 from public.admin_roles where user_id = auth.uid())
$$;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- Auto-create a profile row for every new auth user
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (user_id, full_name)
  values (new.id, coalesce(new.raw_user_meta_data ->> 'full_name', ''));
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ============================================================
-- 3. profiles (rule 1-2)
-- ============================================================
create table if not exists public.profiles (
  user_id     uuid primary key references auth.users (id) on delete cascade,
  full_name   text,
  country     text not null default 'XX' check (country ~ '^[A-Z]{2}$'), -- 'XX' = unset
  city        text,
  skills      text[]    not null default '{}',
  interests   text[]    not null default '{}',
  github      text,
  linkedin    text,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create index if not exists profiles_country_idx on public.profiles (country);
create index if not exists profiles_skills_idx    on public.profiles using gin (skills);
create index if not exists profiles_interests_idx on public.profiles using gin (interests);

drop trigger if exists profiles_updated_at on public.profiles;
create trigger profiles_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();

alter table public.profiles enable row level security;

-- Rule 1: everyone can read the directory
create policy profiles_select_policy
  on public.profiles for select
  to anon, authenticated
  using (true);

-- Rule 2: users edit their own profile; admins can edit any
create policy profiles_update_policy
  on public.profiles for update
  to authenticated
  using (user_id = auth.uid() or public.is_admin())
  with check (user_id = auth.uid() or public.is_admin());

-- No client INSERT policy on purpose: rows are born via handle_new_user() only.

-- ============================================================
-- 4. events (rules 3-6)
-- ============================================================
create table if not exists public.events (
  id           uuid primary key default gen_random_uuid(),
  title        text not null check (char_length(title) between 3 and 200),
  description  text,
  country      text not null check (country ~ '^[A-Z]{2}$'),
  city         text,
  event_date   date not null,
  url          text check (url is null or url ~* '^https?://'),
  tags         text[] not null default '{}',
  status       text not null default 'pending'
               check (status in ('draft', 'pending', 'approved', 'rejected', 'duplicate')),
  submitted_by uuid not null references public.profiles (user_id) on delete cascade,
  approved_by  uuid references public.profiles (user_id) on delete set null,
  submitted_at timestamptz not null default now(),
  decided_at   timestamptz
);

create index if not exists events_country_status_idx on public.events (country, status);
create index if not exists events_event_date_idx     on public.events (event_date);
create index if not exists events_status_submitted   on public.events (status, submitted_by);
create index if not exists events_tags_idx           on public.events using gin (tags);

alter table public.events enable row level security;

-- Rule 3: approved visible to everyone; pending visible to submitter and admins only
create policy events_select_policy
  on public.events for select
  to anon, authenticated
  using (
    status = 'approved'
    or submitted_by = auth.uid()
    or public.is_admin()
  );

-- Rule 4: authenticated users submit for themselves; status forced to pending
create policy events_insert_policy
  on public.events for insert
  to authenticated
  with check (
    submitted_by = auth.uid()
    and (status = 'pending' or public.is_admin())
  );

-- Rule 5: submitter may edit only while still pending (cannot self-approve)
create policy events_update_submitter_policy
  on public.events for update
  to authenticated
  using (submitted_by = auth.uid() and status = 'pending')
  with check (submitted_by = auth.uid() and status = 'pending');

-- Rule 6: admins can update/delete any event (audit trail is written by admin_event_action)
create policy events_update_admin_policy
  on public.events for update
  to authenticated
  using (public.is_admin())
  with check (public.is_admin());

create policy events_delete_admin_policy
  on public.events for delete
  to authenticated
  using (public.is_admin());

-- ============================================================
-- 5. opportunities (rules 7-9)
-- ============================================================
create table if not exists public.opportunities (
  id           uuid primary key default gen_random_uuid(),
  title        text not null check (char_length(title) between 3 and 200),
  type         text not null check (type in ('job', 'internship', 'scholarship', 'program', 'cfp')),
  country      text not null check (country ~ '^[A-Z]{2}$'),
  url          text not null check (url ~* '^https?://'),
  deadline     date,
  status       text not null default 'pending' check (status in ('pending', 'approved', 'rejected')),
  submitted_by uuid not null references public.profiles (user_id) on delete cascade,
  submitted_at timestamptz not null default now()
);

create index if not exists opportunities_country_status_idx on public.opportunities (country, status);
create index if not exists opportunities_type_idx           on public.opportunities (type);

alter table public.opportunities enable row level security;

create policy opportunities_select_policy
  on public.opportunities for select
  to anon, authenticated
  using (status = 'approved' or public.is_admin());

create policy opportunities_insert_policy
  on public.opportunities for insert
  to authenticated
  with check (submitted_by = auth.uid() and status = 'pending');

-- Rule 9: moderation is admin-only (submitters cannot alter after submission)
create policy opportunities_update_admin_policy
  on public.opportunities for update
  to authenticated
  using (public.is_admin())
  with check (public.is_admin());

create policy opportunities_delete_admin_policy
  on public.opportunities for delete
  to authenticated
  using (public.is_admin());

-- ============================================================
-- 6. follows (rule 11)
-- ============================================================
create table if not exists public.follows (
  follower_id  uuid not null references public.profiles (user_id) on delete cascade,
  following_id uuid not null references public.profiles (user_id) on delete cascade,
  created_at   timestamptz not null default now(),
  primary key (follower_id, following_id),
  constraint no_self_follow check (follower_id <> following_id)
);

alter table public.follows enable row level security;

create policy follows_select_policy
  on public.follows for select
  to authenticated
  using (follower_id = auth.uid());

create policy follows_insert_policy
  on public.follows for insert
  to authenticated
  with check (follower_id = auth.uid());

create policy follows_delete_policy
  on public.follows for delete
  to authenticated
  using (follower_id = auth.uid());

-- ============================================================
-- 7. notifications (rule 10)
-- ============================================================
create table if not exists public.notifications (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references public.profiles (user_id) on delete cascade,
  type       text not null,
  payload    jsonb not null default '{}'::jsonb,
  read_at    timestamptz,
  created_at timestamptz not null default now()
);

create index if not exists notifications_user_read_idx on public.notifications (user_id, read_at);

alter table public.notifications enable row level security;

create policy notifications_select_policy
  on public.notifications for select
  to authenticated
  using (user_id = auth.uid());

-- owner marks own as read (read_at) - cannot touch another user's rows
create policy notifications_update_policy
  on public.notifications for update
  to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

create policy notifications_delete_policy
  on public.notifications for delete
  to authenticated
  using (user_id = auth.uid());

-- No INSERT policy: notification rows are born from admin_event_action / service_role only.

-- ============================================================
-- 8. messages (rule 12) - schema ready; feature is post-skeleton
-- ============================================================
create table if not exists public.messages (
  id           uuid primary key default gen_random_uuid(),
  sender_id    uuid not null references public.profiles (user_id) on delete cascade,
  recipient_id uuid not null references public.profiles (user_id) on delete cascade,
  body         text not null check (char_length(body) between 1 and 2000),
  read_at      timestamptz,
  created_at   timestamptz not null default now(),
  constraint no_self_message check (sender_id <> recipient_id)
);

create index if not exists messages_recipient_idx on public.messages (recipient_id, read_at);

alter table public.messages enable row level security;

create policy messages_select_policy
  on public.messages for select
  to authenticated
  using (sender_id = auth.uid() or recipient_id = auth.uid());

create policy messages_insert_policy
  on public.messages for insert
  to authenticated
  with check (sender_id = auth.uid());

create policy messages_update_policy
  on public.messages for update
  to authenticated
  -- only the recipient marks incoming messages read
  using (recipient_id = auth.uid())
  with check (recipient_id = auth.uid());

-- ============================================================
-- 9. event_sources / scraped_raw / verification_results (rule 13)
--    Admin-readable; writes via service_role / trusted code only.
-- ============================================================
create table if not exists public.event_sources (
  id              uuid primary key default gen_random_uuid(),
  name            text not null,
  type            text not null check (type in ('rss', 'api', 'manual')),
  url             text not null,
  last_scraped_at timestamptz
);

create table if not exists public.scraped_raw (
  id         uuid primary key default gen_random_uuid(),
  source_id  uuid not null references public.event_sources (id) on delete cascade,
  raw_data   jsonb not null default '{}'::jsonb,
  scraped_at timestamptz not null default now(),
  processed  boolean not null default false
);

create index if not exists scraped_raw_source_processed_idx
  on public.scraped_raw (source_id, processed);

create table if not exists public.verification_results (
  id                uuid primary key default gen_random_uuid(),
  event_id          uuid not null references public.events (id) on delete cascade,
  confidence        numeric not null check (confidence >= 0 and confidence <= 1),
  reasons           text[] not null default '{}',
  verified_by_agent text not null,
  created_at        timestamptz not null default now()
);

create index if not exists verification_results_event_idx on public.verification_results (event_id);

alter table public.event_sources         enable row level security;
alter table public.scraped_raw           enable row level security;
alter table public.verification_results  enable row level security;

create policy event_sources_select_policy
  on public.event_sources for select
  to authenticated
  using (public.is_admin());

create policy scraped_raw_select_policy
  on public.scraped_raw for select
  to authenticated
  using (public.is_admin());

create policy verification_results_select_policy
  on public.verification_results for select
  to authenticated
  using (public.is_admin());

-- ============================================================
-- 10. admin_actions (rule 14) - audit log; insert happens inside
--     admin_event_action() which runs as security definer.
-- ============================================================
create table if not exists public.admin_actions (
  id         uuid primary key default gen_random_uuid(),
  admin_id   uuid not null references public.profiles (user_id) on delete cascade,
  event_id   uuid not null references public.events (id) on delete cascade,
  action     text not null check (action in ('approve', 'reject', 'edit', 'duplicate')),
  reason     text,
  created_at timestamptz not null default now()
);

create index if not exists admin_actions_event_idx on public.admin_actions (event_id, created_at);

alter table public.admin_actions enable row level security;

create policy admin_actions_select_policy
  on public.admin_actions for select
  to authenticated
  using (public.is_admin());

-- No client insert/update/delete policies on purpose.

-- ============================================================
-- 11. admin_event_action(p_event_id, p_action, p_reason)
--     Frontend calls: supabase.rpc('admin_event_action', {...})
--     approve / reject / duplicate + audit row + notification fan-out.
--     (Free-form edit stays in the admin-event-action Edge Function.)
-- ============================================================
create or replace function public.admin_event_action(
  p_event_id uuid,
  p_action   text,           -- 'approve' | 'reject' | 'duplicate'
  p_reason   text default null
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_admin uuid := auth.uid();
begin
  if v_admin is null or not public.is_admin() then
    raise exception 'admin only' using errcode = '42501';
  end if;

  if p_action not in ('approve', 'reject', 'duplicate') then
    raise exception 'invalid action "%"; expected approve | reject | duplicate', p_action
      using errcode = '22023';
  end if;

  if p_action = 'approve' then
    update public.events
      set status = 'approved', approved_by = v_admin, decided_at = now()
      where id = p_event_id and status = 'pending';
  elsif p_action = 'reject' then
    update public.events
      set status = 'rejected', approved_by = null, decided_at = now()
      where id = p_event_id and status = 'pending';
  else
    update public.events
      set status = 'duplicate', approved_by = v_admin, decided_at = now()
      where id = p_event_id and status = 'pending';
  end if;

  if not found then
    raise exception 'event % not found or not pending', p_event_id using errcode = 'P0002';
  end if;

  insert into public.admin_actions (admin_id, event_id, action, reason)
  values (v_admin, p_event_id, p_action, p_reason);

  if p_action = 'approve' then
    insert into public.notifications (user_id, type, payload)
    select p.user_id, 'new_in_country', jsonb_build_object('event_id', p_event_id)
    from public.events e
    join public.profiles p on p.country = e.country
    where e.id = p_event_id
      and p.user_id <> e.submitted_by; -- submitters know; do not self-notify
  end if;
end;
$$;

revoke execute on function public.admin_event_action(uuid, text, text) from anon;
grant execute on function public.admin_event_action(uuid, text, text) to authenticated;

-- ============================================================
-- 12. Realtime: broadcast events changes (feed toasts)
-- ============================================================
do $$
begin
  alter publication supabase_realtime add table public.events;
exception
  when duplicate_object then null; -- already added
  when undefined_object then null; -- not on a plain postgres (local tests)
end $$;

commit;
