# DevBridge — SWOC Project Proposal

**Project Admin:** Shanaya Mahendran
**Repo:** https://github.com/your-org/devbridge (public, MIT)
**License:** MIT
**Communication:** GitHub Discussions + Discord channel

---

## Problem

Developer events and opportunities are fragmented across WhatsApp groups, friends' posts, LinkedIn, Meetup, Eventbrite, university emails, and Discord servers. Developers in underrepresented regions routinely miss hackathons, scholarships, and CFPs simply because the information never reaches them. There is no unified, country-aware, verified feed.

## Solution

DevBridge is a country-aware platform that aggregates and **verifies** developer events and opportunities. Anyone can submit an event; an admin approves it; developers get notified about approved events in their country. Verification + admin approval kills spam and hallucinated events before they reach the feed.

## MVP Scope (in)

- Auth + profiles (country, city, skills, interests, GitHub, LinkedIn)
- Event submission form
- Admin approval dashboard: approve / reject / edit / mark duplicate
- Country-based event feed with filters: online, in-person, hackathon, conference, scholarship, job, CFP
- In-app notifications for approved events in your country
- Developer directory with search by country, skill, interest
- Follow / connect / basic messaging
- Opportunities board: jobs, internships, scholarships, open-source programs, CFPs
- Supabase RLS, seed data, docs, CI

## Out of scope for MVP

- Scraper agent, verification agent with confidence score, recommendation agent
- Duplicate detection, auto-publishing, LinkedIn scraping
- Email digest (stretch), mobile apps

Scope is **frozen** — new features go to the backlog, not into the MVP.

## Tech Stack

React + Vite + Tailwind + shadcn/ui · Supabase (Postgres, Auth, Realtime, Edge Functions, Storage) · Python + FastAPI + Playwright/BeautifulSoup + scikit-learn (advanced stretch only) · Vercel + Supabase + Railway/Render

## Impact

Helps developers in underrepresented regions discover opportunities they currently miss. Reduces fragmentation and spam by adding verification and admin approval.

## Contributor Fit

| Level | Fit |
|---|---|
| Beginner | UI components, docs, empty states, forms, seed data |
| Intermediate | Supabase RLS, CRUD, realtime notifications, search, admin dashboard |
| Advanced | Scraper, verification agent, duplicate detection, recommendation model, queue/cron |

## Admin Commitment

I will maintain the repo, review PRs within **24–48 h**, triage issues **weekly**, mentor contributors, and keep the MVP scope frozen. **I will not implement all the features myself** — contributors own modules.

## Milestones (phase-based, no 2-week timeline)

1. Foundation → 2. MVP → 3. Notifications → 4. Developer Networking → 5. AI & Scraping → 6. Polish & Docs
