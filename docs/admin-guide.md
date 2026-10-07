# Admin Guide (maintainer handbook)

How to run the moderation side of DevBridge. Pair this with [rls.md](rls.md) for the exact database guarantees.

## Making someone an admin

Admin is a table row, not a JWT claim (revocable, shared, and easy to audit):

```sql
-- run in Supabase dashboard (elevated) or via service_role
insert into admin_roles (user_id) values ('<uuid-of-profile>');
```

Never paste this into the app; never grant via an issue-comment request without verifying identity.

## The approval queue

The queue is the admin-only view of `events where status = 'pending'`, ordered by `submitted_at`.

For each submission, decide: **approve / reject / edit / mark duplicate**.

### Approve

Use when the event is real, correctly dated, correctly country-tagged, and not spam.

- Server-side action (RPC `admin_event_action` or Edge Function `admin-event-action`), **never** a raw client `update`.
- The action sets `status='approved'`, stamps `approved_by` + `decided_at`, writes an `admin_actions` audit row, and fans out in-app notifications to users in that country.
- If `verification_results` show `confidence < 0.7`, pause and double-check manually before approving.

### Reject

Use for spam, dead links, wrong info the submitter ignored, fabricated events.

- Also applies `status='rejected'` (not visible to the feed, **visible to the submitter**) plus a human reason so contributors learn.
- Rejection reason is mandatory; "no reason" is a policy smell.

### Edit

Prefer fixing **small** issues (typo in title, wrong city) rather than rejecting.

- `action: 'edit'` with a JSON patch; audited with before/after in `admin_actions`.

### Mark duplicate

- `action: 'duplicate'` hides one of two identical submissions (manual, keep the richer one).
- Future: fuzzy-matching agent will *suggest* duplicates; admins still confirm.

## Cross-checking before approving (verification checklist)

- [ ] Event URL opens and the project is real (or a trust anchor answers for it)
- [ ] Date/timezone makes sense for the tagged country
- [ ] Country/city tags match the event's actual audience
- [ ] Not already in the board (duplicate scan on title + date + country)
- [ ] Rewards/eligibility claims are consistent with the source page

## Moderation load and escalation

- One admin cannot handle approval alone: add country co-admins as sub/regional moderators grow.
- Admins approve in **< 48 h** per item; stale queue > 10 items triggers a triage thread.
- Report/flag system (advanced milestone) will let users flag false events; until then route reports to the `#devbridge-report` Discord channel.

## What admins must never do

- Never auto-publish a scraped or AI-verified event (policy: [scraper-policy.md](scraper-policy.md))
- Never approve an event with failing URL or unknown host **without a trust anchor**
- Never grant admin in response to a DM
- Never bypass the audit log (every action writes `admin_actions`)
