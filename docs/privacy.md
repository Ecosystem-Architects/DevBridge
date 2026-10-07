# Privacy Notes

What DevBridge collects, why, and what you can do about it. Plain language.

## What we collect

| Data | Where | Why |
|---|---|---|
| Email (from auth) | Supabase Auth | Sign in, notify about approved events, security |
| Country (required), city | `profiles` | The **entire product** is country-aware event discovery |
| Skills, interests | `profiles` | Feed filters + directory search |
| GitHub / LinkedIn handles | `profiles` | Profile enrichment for networking |
| Directory visibility | `profiles` SELECT policy | Your profile is viewable by others in the developer directory |
| Event submissions | `events` | Shown to others only **after** admin approval |
| Follows / messages | `follows`, `messages` | Visible only to you and your contact |

Collection is minimized; we do not track analytics inside the app, and we do not scrape **behavioral** data.

## Guardrails already in schema/RLS

- Pending events visible only to submitter + admins.
- Notifications only by owner; `read_at` is owner-write.
- Scraped data is stripped of personal contact fields before storage (PII policy; see also [scraper-policy.md](scraper-policy.md)).
- Verification confidence scores are not shown to end users; the queue is the only surface.
- Every moderation action is logged in `admin_actions` for accountability.

## Your rights

- **Access / export:** your profile and submissions are yours; export copies are possible via a Supabase query run by the admin on request.
- **Rectification:** edit your profile / pending submissions directly in the app or via the admin queue.
- **Deletion:** request account deletion via `#devbridge` or the admin email; we delete from `profiles`, `follows`, `notifications` and cascade-delete your pending `events`; audit-log rows keep minimal, non-personal entries.
- **Objection:** you can ask to be excluded from the developer directory; we flip a profile flag.

ToS and privacy policy live in the production deployment; this doc is the engineering source of truth. Local/demo instances should use **obviously fake** profile data (see [../supabase/seed.sql](../supabase/seed.sql)) and demo emails only.
