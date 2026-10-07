# Row Level Security (RLS) - DevBridge

RLS is the **only** real enforcement layer. The UI hiding a button is cosmetic; a stolen anon key must still be safe. This doc describes every policy implemented in [supabase/migrations/0001_init.sql](../supabase/migrations/0001_init.sql).

## Prerequisites

- RLS enabled on all tables (the migration does this next to each `CREATE TABLE`).
- `is_admin()` helper: `exists (select 1 from admin_roles where user_id = auth.uid())`.
- `admin_roles` is writable **only** by the schema owner (never via anon/authenticated). Admins are granted by SQL run with elevated privileges (Supabase dashboard or service_role).
- `handle_new_user` trigger creates a matching `profiles` row on signup.

## Policy decision table

| # | Table | Operation | Who | Condition |
|---|---|---|---|---|
| 1 | profiles | SELECT | anyone | no filter (public directory) |
| 2 | profiles | UPDATE | self or admin | `user_id = auth.uid()` or admin |
| 3 | events | SELECT | everyone + submitter + admin | `status = 'approved'` or `submitted_by = auth.uid()` or admin. Net effect: pending events visible only to their submitter and admins |
| 4 | events | INSERT | authenticated | `submitted_by = auth.uid()` and status forced to `pending` (unless admin) |
| 5 | events | UPDATE | submitter | only while the row is still `pending` |
| 6 | events | UPDATE / DELETE | admin | any row, any status; every change is audited in `admin_actions` |
| 7 | opportunities | SELECT | everyone | `status = 'approved'` (plus admin sees all) |
| 8 | opportunities | INSERT | authenticated | `submitted_by = auth.uid()` and `status = 'pending'` |
| 9 | opportunities | UPDATE / DELETE | admin only | not submitter |
| 10 | notifications | SELECT / UPDATE(read_at) | owner only | `user_id = auth.uid()` |
| 11 | follows | SELECT / INSERT / DELETE | self only | `follower_id = auth.uid()` |
| 12 | messages | SELECT | participants only | `sender_id = auth.uid()` or `recipient_id = auth.uid()` (schema ready, feature is post-skeleton) |
| 13 | event_sources, scraped_raw, verification_results | SELECT | admin only | writes only via service_role / trusted code |
| 14 | admin_actions | SELECT | admin only | writes via trusted triggers or service_role, not client |

## Design rules

1. **Deny by default.** No `USING (true)` on sensitive tables.
2. **Never rely on UI as policy.** Each rule above is a real policy, not a hidden button.
3. **Pending events are submitter/admin-only.** The feed query also filters `status = 'approved'` explicitly - belt and suspenders.
4. **Admin is a table, not a JWT claim**, so admin approval is revocable in one DELETE and does not depend on token refresh.
5. You cannot mark someone else's notification read: the read_at policy is per-row `(id)` + owner check.
6. **follows:** cannot follow yourself; the follow list is visible only to the follower.
7. **messages** table exists for the "basic messaging" MVP line; the walking skeleton ships without it, policies are ready.
8. **scraped_raw** must not contain PII; sources that yield contact email go through a sanitation step before insert.
9. **verification_results** are admin-readable only; publishing raw confidence numbers to end users would be misleading.
10. Policy names follow `tbl_operation_policy` patterns so issues can reference them precisely.

## Testing RLS (concrete recipe)

```sql
-- As anon (no JWT)
select count(*) from events;               -- expect: only approved rows

-- As a non-admin authenticated user (their uuid)
select set_config('request.jwt.claims',
  '{"sub":"<uuid>","role":"authenticated"}', true);
select count(*) from events where status = 'pending';   -- expect 0 (no own pending)

-- As admin
insert into admin_roles (user_id) values ('<uuid>');
select count(*) from events where status = 'pending';   -- expect > 0
```

Contributions touching RLS **must** include a screenshot of this recipe running against a local Supabase instance.

## Change management

- Policies change only via migration files. The dashboard SQL console is for experiments only, never for "quick permanent fixes".
- New tables are created **with RLS enabled in the same migration**, before a single row exists.
- Any PR touching RLS needs review against this decision table.
