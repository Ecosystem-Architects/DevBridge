# Issue Library (copy-paste source)

Every issue: **context → expected outcome → files → acceptance criteria → difficulty → labels → mentor hint**.

## Good first issues (.github → hooks to build first-week)

### Issue 1 - Add dark mode toggle
- **Context:** The app currently renders one fixed light theme; contributors should ship user-visible polish early.
- **Expected outcome:** Toggle in the header persists across reloads.
- **Files:** `frontend/src/components/ThemeToggle.tsx` (new), `frontend/src/App.tsx`
- **AC:**
  1. Works with `prefers-color-scheme` as default
  2. Choice stored in `localStorage('devbridge-theme')`
  3. Keyboard accessible (`aria-pressed`)
- **Difficulty:** good first issue · **Labels:** `good first issue`, `frontend`, `SWOC`
- **Mentor hint:** Use the `dark:` variant strategy described in Tailwind docs; no extra library necessary.

### Issue 2 - Build event card component
- **Context:** Feed and admin queue both render event rows; a shared card avoids drift.
- **Expected outcome:** `<EventCard>` rendering title, date, country flag, tags, CTA.
- **Files:** `frontend/src/components/EventCard.tsx` (new)
- **AC:**
  1. Props: `event`, `isAdmin`, `onAction?`
  2. Tag pills for up to 4 tags + "+N" overflow
  3. Storybook-style preview in a `/dev/card` route OR screenshot in the PR
- **Difficulty:** good first issue · **Labels:** `good first issue`, `frontend`, `SWOC`
- **Mentor hint:** Keep it a pure presentational component; data fetching stays in page components.

### Issue 3 - Add country selector to profile
- **context prod:** Country powers the whole feed; profile must have a correct country field.
- **Expected outcome:** Profile pageosition includes an accessible country dropdown.
- **Files:** `frontend/src/pages/Profile.tsx`
- **AC:**
  1. ISO alpha-2 codes; searchable dropdown
  2. Default value from existing profile if present
  3. Keyboard navigation + visible focus ring
- **Difficulty:** good first issue · **Labels:** `good first issue`, `frontend`, `SWOC`
- **Mentor hint:** Consider `cmdk`-style list, but a `<select>` is fine if styled well - no new heavy deps.

### Issue 4 - Create empty state for feed
- **Context:** New countries / new users see a blank feed - the top drop-off point.
- **Expected outcome:** Empty state with illustration/emoji, explanation, and CTA to submit an event.
- **Files:** `frontend/src/components/EmptyState.tsx` (new), `frontend/src/pages/Feed.tsx`
- **AC:** 1. Shown when query returns 0 rows 2. Skippable via keyboard 3. Screenshot in PR
- **Difficulty:** good first issue · **Labels:** `good first issue`, `frontend`, `docs`, `SWOC`

### Issue 5 - Write setup guide in README
- **Context:** New contributors currently need to read source to run the project.
- **Expected outcome:** Zero-to-running in under 10 minutes.
- **Files:** `README.md`.
- **AC:**
  1. Prerequisites (Node 20+, npm, Supabase account)
  2. Steps: clone, install, `.env`, `npm run dev`
  3. Troubleshooting for the 3 most common errors
- **Difficulty:** good first issue · **Labels:** `good first issue`, `docs`, `SWOC`

### Issue 6 - Add loading skeletons
- **Context:** Feed and admin queue flash blank while Supabase queries run.
- **Expected outcome:** Skeleton cards while loading.
- **Feed skeleton:** `frontend/src/pages/Feed.tsx`
- **AC:** 1. Skeleton for cards and form fields 2. Respects reduced-motion media query 3. Screenshot in PR
- **Difficulty:** good first issue · **Labels:** `good first issue`, `frontend`, `SWOC`

### Issue 7 - Add 404 page
- **Context:** Unknown routes currently show a blank page.
- **Expected outcome:** Friendly 404 with link back to feed.
- **Files:** `frontend/src/pages/NotFound.tsx` (new), `frontend/src/App.tsx`
- **AC:** 1. Route `*` renders it 2. Screenshot in PR 3. Link back home
- **Difficulty:** good first issue · **Labels:** `good first issue`, `frontend`, `SWOC`

### Issue 8 - Accessibility labels for forms
- **Context:** Submission form lacks labels/ARIA for screen readers.
- **Expected outcome:** Every input has a programmatic label + error announcements.
- **Files:** `frontend/src/components/EventForm.tsx`
- **AC:**
  1. Label/`htmlFor` on all fields
  2. `aria-invalid` + error text linked via `aria-describedby`
  3. Keyboard-only walkthrough documented in PR
- **Difficulty:** good first issue · **Labels:** `good first issue`, `frontend`, `SWOC`

### Issue 9 - Add GitHub issue templates
- **Context:** A swim-lane of low-quality issues slows triage.
- **Expected outcome:** Bug + feature request templates in `.github/ISSUE_TEMPLATE`.
- **Files:** `.github/ISSUE_TEMPLATE/bug.yml`, `feature.yml`, `config.yml`
- **AC:** 1. New-issue page shows the chooser 2. Required fields enforced 3. Mentions the contributing doc
- **Difficulty:** good first issue · **Labels:** `good first issue`, `docs`, `infra / CI`, `SWOC`

### Issue 10 - Create seed data for events
- **Context:** Feed feels empty for demo/screenshots.
- **Expected outcome:** Realistic events across 4+ countries in `supabase/seed.sql`.
- **Files:** `supabase/seed.sql`
- **AC:** 1. Four countries, ≥12 events mixed approved/pending 2. Includes online + in-person + hackathon/conference/CFP tags 3. Idempotent (uses fixed UUIDs, `ON CONFLICT DO NOTHING`)
- **Difficulty:** good first issue · **Labels:** `good first issue`, `supabase`, `SWOC`

### Issue 11 - Add README badges and screenshots
- **Context:** Project health signals are the first screening for SWOC participants.
- **Expected outcome:** Badges (build, license, good-first-issues count) + screenshots of the feed.
- **Files:** `README.md`
- **AC:** 1. CI badge from GitHub Actions 2. Screenshot of the app, not a mockup 3. Alt text present
- **Difficulty:** good first issue · **Labels:** `good first issue`, `docs`, `SWOC`

### Issue 12 - 48h response tracker (help wanted label for triage)
- **Context:** SLA is PR review in 24-48 h; contributors need to know if it slipped.
- **PR detection:** Maintainer-only, can be a `help wanted` issue explaining the triage cadence.
- **AC:** 1. Explain the SLA and where to ping if over the SLA 2. Link from CONTRIBUTING
- **Difficulty:** good first issue · **Labels:** `help wanted`, `docs`, `SWOC`

## Intermediate issues

### Issue 13 - Event submission form with validation
- **Context:** `events` insert path exists but no user-facing form.
- **Expected outcome:** `/submit` route with form + client-side validation + RLS-backed insert.
- **Files:** `frontend/src/pages/Submit.tsx` (new), `frontend/src/lib/supabase.ts`
- **AC:**
  1. Fields: title, description, country, city, date, url, tags
  2. Country restricted to ISO alpha-2; date = future; URL valid
  3. On success: "pending review" screen (status forced to pending by RLS)
  4. Error states: duplicate URL warning (stretch), network failure
- **Difficulty:** intermediate · **Labels:** `intermediate`, `frontend`, `supabase`, `SWOC`
- **Mentor hint:** Read [../docs/rls.md](../docs/rls.md) rule 4; the RLS policy forces status to `pending`, don't trust client status.

### Issue 14 - Admin approval table with filters
- **Context:** Admins need a queue with triage filters.
- **Expected outcome:** `/admin` route, admin-only by RLS + redirect.
- **Files:** `frontend/src/pages/Admin.tsx` (new)
- **AC:**
  1. Lists pending events via `status = 'pending'`
  2. Filters: country, tag, submitted date, confidence flag
  3. Actions: approve / reject (reason required) / edit / duplicate via RPC
  4. Non-admin URL access shows "not authorized" (RLS blocks data, not just UI)
- **Difficulty:** intermediate · **Labels:** `intermediate`, `frontend`, `supabase`, `SWOC`
- **Mentor hint:** Check `is_admin()` via profiles/admin_roles, not a hardcoded email list.

### Issue 15 - Supabase Realtime notifications
- **Context:** Approved events should notify users in that country instantly.
- ** Expected outcome:** Toast + in-app bell with unread count.
- **Files:** `frontend/src/components/NotificationBell.tsx`, `frontend/src/lib/realtime.ts`
- **AC:**
  1. Subscribe to `events` changes where `status` becomes `approved`; match user country
  2. Bell with unread count from `notifications` table
  3. Mark-as-read updates `read_at` (policy: owner-only)
- **Difficulty:** intermediate · **Labels:** `intermediate`, `supabase`, `frontend`, `SWOC`

### Issue 16 - Email digest Edge Function (stretch)
- **Context:** Not everyone logs in daily; a weekly digest helps.
- **Expected outcome:** Scheduled Edge Function emails approved events grouped by country.
- **Files:** `supabase/functions/email-digest/index.ts` (new)
  - Supabase secret: `RESEND_API_KEY` (or SMTP)
- **AC:**
  1. Runs on cron (weekly)
  2. Groups approved events by country; users can unsubscribe (from `profiles` flag)
  3. Respects unsubscribe in every send
- **Difficulty:** intermediate · **Labels:** `intermediate`, `supabase`, `SWOC`
- **Mentor hint:** This is a **stretch**; do not start before milestone 3 is done.

### Issue 17 - Calendar export (.ics)
- **Context:** Users want events in their calendar.
- **Expected outcome:** "Add to calendar" button on event cards.
- **Files:** `frontend/src/components/EventCard/ICSButton.tsx`
- **AC:** 1. Valid ICS 2.0 file (RFC 5545 DateTime UTC) 3. Download works offline
- **Difficulty:** intermediate · **Labels:** `intermediate`, `frontend`, `SWOC`

### Issue 18 - Developer directory with search
- **Context:** MVP includes dev directory; needs search by country, skill, interest.
- **Expected outcome:** `/directory` route with search + pagination.
- **Files:** `frontend/src/pages/Directory.tsx`, `lib/supabase.ts`
- **AC:**
  1. Search by country (dropdown), skill, interest (freetext)
  2. GIN-index queries via `profiles.skills && query`
   overlap operator. 3. Paginate (>50 profiles)
- **Difficulty:** intermediate · **Labels:** `intermediate`, `frontend`, `supabase`, `SWOC`

### Issue 19 - Follow / connect buttons
- **Context:** Networking milestone MVP line: follow/connect.
- **Expected outcome:** Follow buttons on directory cards; "network" page for your follows.
- **Files:** `frontend/src/components/FollowButton.tsx`, `frontend/src/pages/Network.tsx`
- **AC:** 1. Insert/delete `follows` rows (policy: self only) 2. Anonymous users see login prompt 3. Optimistic UI
- **Difficulty:** intermediate · **Labels:** `intermediate`, `frontend`, `supabase`, `SWOC`

### Issue 20 - Implement country-based feed query
- **Context:** The feed is the product core.
- **Expected outcome:** `/` shows approved events for the user's country + filters.
- **Files:** `frontend/src/pages/Feed.tsx`, `lib/supabase.ts`
- **AC:**
  1. Guest: default country picker; logged-in: profile country
  _b. 2. Filters: online, in-person, hackathon, conference, scholarship, job, cfp
  3. Sorted by event_date ASC; future events only
  4. Realtime update on newly approved
- **Difficulty:** intermediate · **Labels:** `intermediate`, `frontend`, `supabase`, `SWOC`

### Issue 21 - RLS policy tests + hardening
- **Context:** RLS is the security core; contributors must prove it works.
- **Expected outcome:** SQL test script proving each rule in the decision table.
- **Files:** `supabase/tests/rls-tests.sql` (new)
- **AC:**
  1. For each of the 14 rules: a passing test screenshot/README entry
  2. Attempt a malicious update as non-admin - must fail
  3. Docs update if you add a policy
- **Difficulty:** intermediate · **Labels:** `intermediate`, `supabase`, `security`, `SWOC`
- **Mentor hint:** Use `set_config('request.jwt.claims', ...)` trick in [../docs/rls.md](../docs/rls.md).

### Issue 22 - Opportunities board CRUD
- **Context:** MVP line: jobs, internships, scholarships, programs, CFPs.
- **Expected outcome:** `/opportunities` listing + submit + admin queue.
- **Files:** `frontend/src/pages/Opportunities.tsx`, `frontend/src/pages/AdminOpportunities.tsx`
- **AC:** 1. Public approved list 2. Submit requires auth 3. RLS keeps pending private 4. Admin approve/reject
- **Difficulty:** intermediate · **Labels:** `intermediate`, `frontend`, `supabase`, `SWOC`

## Advanced issues

### Issue 23 - Python scraper for Devpost RSS
- **Context:** Fragmentation is the problem; crawling official RSS is the safest source.
- **Expected outcome:** `ai-service` FastAPI service + a queue bridge.
- **Files:** `ai-service/` (new code), `supabase/functions/scrape-trigger`
- **AC:**
  1. Fetch Devpost RSS (respect robots.txt, ToS)
  2. Rate-limited (1 rps/host), custom User-Agent
  3. Writes to `event_sources` → `scraped_raw` via service_role - **never** writes `events.status`
  4. Unit tests for the parser (recorded fixture, no live calls in CI)
  5. README in `ai-service/` updated from "do not build" to "how it works"
- **Difficulty:** advanced · **Labels:** `advanced`, `ai`, `backend`, `SWOC`
- **Mentor hint:** Non-destructive parser. Fixture-based tests; no live crawling in CI, ever.

### Issue 24 - Verification agent with confidence score
- **Context:** Admins need a signal, not a decision.
- **Expected outcome:** Given event + provenance, return a 0-1 confidence + reasons.
- **Files:** `ai-service/`, `verification_results`
- **AC:** 1. `POST /verify` endpoint 2. Reasons are human-readable strings 3. Writes verify rows tagged `verified_by_agent` 4. `< 0.7` flagged in admin UI (needs #14)
- **Difficulty:** advanced · **Labels:** `advanced`, `ai`, `SWOC`
- **Mentor hint:** Start heuristic (URL resolves, date plausibility, source trust) before any ML.

### Issue 25 - Duplicate detection (fuzzy)
- **Context:** Same event will be submitted twice.
- **Expected outcome:** Suggest duplicates in admin queue.
- ****Files:** `ai-service/`, admin UI badge
- **AC:** 1. `POST /dedupe` returns pairs + score 2. UI: "possible duplicate" badge; one click "mark as duplicate" 3. Admin confirms every merge
- **Difficulty:** advanced · **Labels:** `advanced`, `ai`, `backend`, `SWOC`
- **Mentor hint:** `rapidfuzz` on title + numeric date/venue equality. Threshold tuned on real data; recall > precision is wrong here - precision first.

### Issue 26 - Recommendation model for events
- **Context:** Flat country feed works; personalization is a bonus.
- **Expected outcome:** Ranked feed variant behind a flag.
- **Files:** `ai-service/`, `frontend` feed toggle
- **AC:** 1. Rank = f(country, skills, interests, past RSVPs) 2. Ranked variant NEVER hides admin-approved content 3. A/B toggle per user; default is country feed
- **Difficulty:** advanced · **Labels:** `advanced`, `ai`, `SWOC`
- **Mentor hint:** scikit-learn TF-IDF on skills vs event tags; no LLM needed for MVP+.

### Issue 27 - Queue for scraped events
- **Context:** Scraped items need an ordered, retryable pipeline.
- **Expected outcome:** scrape-trigger → enqueue → parse → dedupe → verify → `events(pending)`, all queued behind Supabase cron.
- **Files:** `supabase/functions/scrape-trigger`, `ai-service/`
- **AC:** 1. Idempotent (re-run does not duplicate) 2. Failure alerting to Discord webhook 3. Mapping table source→parser registered
- **Difficulty:** advanced · **Labels:** `advanced`, `backend`, `ai`, `infra / CI`, `SWOC`

### Issue 28 - Moderation report / flag system
- **Context:** Users need to report a fake/inaccurate event.
- **Expected outcome:** "Report" button → `reports` table → admin queue section.
- **Files:** migration + admin UI + report button component
- **AC:** 1. New table + RLS (reporter-visible, admin-visible) 2. Rate limited per user 3. Admin resolves report (action + reason) 4. Reporter notified on resolution
- **Difficulty:** advanced · **Labels:** `advanced`, `backend`, `supabase`, `SWOC`

---

## Count summary

- Good first issues: 12
- Intermediate: 10 (issues 13-22)
- Advanced: 6 (issues 23-28)
- **Total: 28 issues** - above the 15-25 requirement; ship the top 20 if overloaded.

## Writing new issues

Template + mentor hint guidance in [admin-guide.md](admin-guide.md). New issues follow the same section order exactly.