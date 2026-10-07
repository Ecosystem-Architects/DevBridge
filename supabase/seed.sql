-- seed.sql - DevBridge demo data (idempotent; fixed UUIDs, safe to re-run)
-- Runs automatically after migrations:  supabase db reset
-- Demo logins: alexa@example.com / bree@example.com / casey@example.com / devon@example.com
-- Password for all: devbridge-demo   (casey@example.com is an ADMIN)
-- Never run this against production.

begin;

create extension if not exists pgcrypto;

-- ----------------------------------------------------------------
-- 1. Demo auth users (fixed UUIDs; re-running is a no-op)
-- ----------------------------------------------------------------
insert into auth.users (
  instance_id, id, aud, role, email,
  encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) values
  ('00000000-0000-0000-0000-000000000000', 'e0000000-0000-0000-0000-0000000000a1',
   'authenticated', 'authenticated', 'alexa@example.com',
   crypt('devbridge-demo', gen_salt('bf')), now(),
   '{"provider":"email","providers":["email"]}', '{"full_name":"Alexa Dev"}', now(), now()),
  ('00000000-0000-0000-0000-000000000000', 'e0000000-0000-0000-0000-0000000000b2',
   'authenticated', 'authenticated', 'bree@example.com',
   crypt('devbridge-demo', gen_salt('bf')), now(),
   '{"provider":"email","providers":["email"]}', '{"full_name":"Bree Okafor"}', now(), now()),
  ('00000000-0000-0000-0000-000000000000', 'e0000000-0000-0000-0000-0000000000c3',
   'authenticated', 'authenticated', 'casey@example.com',
   crypt('devbridge-demo', gen_salt('bf')), now(),
   '{"provider":"email","providers":["email"]}', '{"full_name":"Casey Admin"}', now(), now()),
  ('00000000-0000-0000-0000-000000000000', 'e0000000-0000-0000-0000-0000000000d4',
   'authenticated', 'authenticated', 'devon@example.com',
   crypt('devbridge-demo', gen_salt('bf')), now(),
   '{"provider":"email","providers":["email"]}', '{"full_name":"Devon Rao"}', now(), now())
on conflict (id) do nothing;

-- Casey is the project admin (revocable with a single delete)
insert into public.admin_roles (user_id)
values ('e0000000-0000-0000-0000-0000000000c3')
on conflict (user_id) do nothing;

-- ----------------------------------------------------------------
-- 2. Profiles (handle_new_user already created rows; enrich here)
-- ----------------------------------------------------------------
insert into public.profiles (user_id, full_name, country, city, skills, interests, github, linkedin) values
  ('e0000000-0000-0000-0000-0000000000a1', 'Alexa Dev',    'IN', 'Bengaluru', '{react, typescript, tailwind}', '{hackathons, oss}',            'alexa-dev',    'in/alexa-dev'),
  ('e0000000-0000-0000-0000-0000000000b2', 'Bree Okafor',  'NG', 'Lagos',     '{python, fastapi, postgres}',   '{scholarships, conferences, ai}', 'breeokafor', 'in/breeokafor'),
  ('e0000000-0000-0000-0000-0000000000c3', 'Casey Admin',  'XX', null,        '{moderation, community}',       '{oss}',                        'casey-admin',  null),
  ('e0000000-0000-0000-0000-0000000000d4', 'Devon Rao',    'US', 'Seattle',   '{go, kubernetes, ml}',          '{meetups, cfp}',               'devonrao',     'in/devonrao')
on conflict (user_id) do update set
  full_name = excluded.full_name,
  country   = excluded.country,
  city      = excluded.city,
  skills    = excluded.skills,
  interests = excluded.interests,
  github    = excluded.github,
  linkedin  = excluded.linkedin;

-- ----------------------------------------------------------------
-- 3. Events - approved (visible to feed) across 4 countries
-- ----------------------------------------------------------------
insert into public.events
  (id, title, description, country, city, event_date, url, tags, status, submitted_by, approved_by, submitted_at, decided_at)
values
  ('f0000000-0000-0000-0000-0000000000e1',
   'Bengaluru OSS Sprint Weekend',
   'Two-day open-source contribution sprint with mentors from local foundations. Good for first-time contributors.',
   'IN', 'Bengaluru', current_date + 14, 'https://example.org/blr-oss-sprint',
   '{in-person, hackathon, oss}', 'approved',
   'e0000000-0000-0000-0000-0000000000a1', 'e0000000-0000-0000-0000-0000000000c3',
   now() - interval '4 days', now() - interval '3 days'),

  ('f0000000-0000-0000-0000-0000000000e2',
   'India Online Accessibility Jam',
   '48-hour online jam: build accessible UI patterns with screen-reader users as co-designers.',
   'IN', null, current_date + 21, 'https://example.org/a11y-jam',
   '{online, hackathon, accessibility}', 'approved',
   'e0000000-0000-0000-0000-0000000000b2', 'e0000000-0000-0000-0000-0000000000c3',
   now() - interval '5 days', now() - interval '3 days'),

  ('f0000000-0000-0000-0000-0000000000e3',
   'Lagos Python Meetup: FastAPI in Production',
   'Lightning talks on deploying FastAPI, RLS with Postgres, and scaling tips from Nigerian teams.',
   'NG', 'Lagos', current_date + 10, 'https://example.org/lagos-py',
   '{in-person, meetup}', 'approved',
   'e0000000-0000-0000-0000-0000000000b2', 'e0000000-0000-0000-0000-0000000000c3',
   now() - interval '6 days', now() - interval '4 days'),

  ('f0000000-0000-0000-0000-0000000000e4',
   'CSVPHack: Lagos Community Hackathon',
   'Beginner-friendly hackathon with a health data track. Team building on Friday night.',
   'NG', 'Lagos', current_date + 30, 'https://example.org/lagos-hack',
   '{in-person, hackathon}', 'approved',
   'e0000000-0000-0000-0000-0000000000a1', 'e0000000-0000-0000-0000-0000000000c3',
   now() - interval '7 days', now() - interval '5 days'),

  ('f0000000-0000-0000-0000-0000000000e5',
   'DevOps Days Seattle',
   'Community conference on CI/CD, platform engineering, and observability.',
   'US', 'Seattle', current_date + 45, 'https://example.org/devops-sea',
   '{in-person, conference, cfp}', 'approved',
   'e0000000-0000-0000-0000-0000000000d4', 'e0000000-0000-0000-0000-0000000000c3',
   now() - interval '8 days', now() - interval '6 days'),

  ('f0000000-0000-0000-0000-0000000000e6',
   'AI for Good - Global Online Summit',
   'Free online summit: applied ML for public interest projects, with English + Hindi tracks.',
   'US', null, current_date + 18, 'https://example.org/ai-for-good',
   '{online, conference, ai}', 'approved',
   'e0000000-0000-0000-0000-0000000000d4', 'e0000000-0000-0000-0000-0000000000c3',
   now() - interval '9 days', now() - interval '6 days'),

  ('f0000000-0000-0000-0000-0000000000e7',
   'Berlin JS: Typescript Patterns Night',
   'TypeScript type-level patterns and TS-to-migration war stories.',
   'DE', 'Berlin', current_date + 12, 'https://example.org/berlin-js',
   '{in-person, meetup}', 'approved',
   'e0000000-0000-0000-0000-0000000000a1', 'e0000000-0000-0000-0000-0000000000c3',
   now() - interval '10 days', now() - interval '7 days'),

  ('f0000000-0000-0000-0000-0000000000e8',
   'Deadline Alert: Fellowship CFP (India focus)',
   'Not a talk - a call for proposals. Community micro-fellowship, 6-week projects,INR 50k grants.',
   'IN', null, current_date + 25, 'https://example.org/micro-fellowship-cfp',
   '{online, cfp, scholarship}', 'approved',
   'e0000000-0000-0000-0000-0000000000b2', 'e0000000-0000-0000-0000-0000000000c3',
   now() - interval '10 days', now() - interval '7 days');

-- ----------------------------------------------------------------
-- 4. Events - pending (visible only to submitter + admins)
-- ----------------------------------------------------------------
insert into public.events
  (id, title, description, country, city, event_date, url, tags, status, submitted_by, submitted_at)
values
  ('f0000000-0000-0000-0000-0000000000f1',
   'Rust Lagos Study Group Launch',
   'Weekly Rust study group for students; organiser shared the semester schedule.',
   'NG', 'Lagos', current_date + 9, 'https://example.org/rust-lagos',
   '{in-person, meetup, study-group}', 'pending',
   'e0000000-0000-0000-0000-0000000000b2', now() - interval '2 days'),

  ('f0000000-0000-0000-0000-0000000000f2',
   'Bangalore Product Engineering Unconference',
   'Unconference, one day, crowdsourced sessions. Organiser asked for help finishing the venue page.',
   'IN', 'Bengaluru', current_date + 33, 'https://example.org/blr-unconf',
   '{in-person, unconference}', 'pending',
   'e0000000-0000-0000-0000-0000000000a1', now() - interval '1 days');

-- ----------------------------------------------------------------
-- 5. Opportunities board demo rows (jobs / scholarships / CFPs)
-- ----------------------------------------------------------------
insert into public.opportunities
  (id, title, type, country, url, deadline, status, submitted_by, submitted_at)
values
  ('a0000000-0000-0000-0000-0000000001a1',
   'Frontend Intern - Accessibility-first fintech (Remote India)', 'internship', 'IN',
   'https://example.org/jobs/a11y-fintech-int', current_date + 20, 'approved',
   'e0000000-0000-0000-0000-0000000000a1', now() - interval '5 days'),
  ('a0000000-0000-0000-0000-0000000001a2',
   'Scholarship: Women in Open Source (Nigeria cohort)', 'scholarship', 'NG',
   'https://example.org/scholarships/wios-ng', current_date + 28, 'approved',
   'e0000000-0000-0000-0000-0000000000b2', now() - interval '6 days'),
  ('a0000000-0000-0000-0000-0000000001a3',
   'Maintainer-in-training program (global, remote)', 'program', 'US',
   'https://example.org/programs/mit-global', current_date + 40, 'approved',
   'e0000000-0000-0000-0000-0000000000d4', now() - interval '7 days'),
  ('a0000000-0000-0000-0000-0000000001a4',
   'CFP: Regional DevOps Days (Berlin)', 'cfp', 'DE',
   'https://example.org/cfp/devops-berlin', current_date + 22, 'approved',
   'e0000000-0000-0000-0000-0000000000a1', now() - interval '8 days'),
  ('a0000000-0000-0000-0000-0000000001b1',
   'Graduate Backend Engineer - Lagos', 'job', 'NG',
   'https://example.org/jobs/lagos-backend', current_date + 35, 'pending',
   'e0000000-0000-0000-0000-0000000000b2', now() - interval '2 days');

-- ----------------------------------------------------------------
-- 6. Event sources (placeholders for the stretch scraper)
-- ----------------------------------------------------------------
insert into public.event_sources (id, name, type, url) values
  ('b0000000-0000-0000-0000-0000000001s1', 'Devpost RSS (stretch)', 'rss', 'https://devpost.com/rss.xml'),
  ('b0000000-0000-0000-0000-0000000001s2', 'Manual submissions',      'manual', 'https://example.org/manual')
on conflict (id) do nothing;

-- ----------------------------------------------------------------
-- 7. A couple of demo notifications for Alexa
-- ----------------------------------------------------------------
insert into public.notifications (user_id, type, payload, read_at, created_at) values
  ('e0000000-0000-0000-0000-0000000000a1', 'new_in_country',
   '{"event_id": "f0000000-0000-0000-0000-0000000000e1"}',
   null, now() - interval '3 days'),
  ('e0000000-0000-0000-0000-0000000000a1', 'new_in_country',
   '{"event_id": "f0000000-0000-0000-0000-0000000000e2"}',
   now() - interval '2 days', now() - interval '3 days');

commit;

-- Done. Try it:
--   * Feed as anon:            select * from events where status = 'approved';
--   * Sign in as casey@example.com (admin) and call
--     select admin_event_action('f0000000-0000-0000-0000-0000000000f1', 'approve', 'seed demo');
