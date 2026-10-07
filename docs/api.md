# API

DevBridge has no bespoke REST API in the MVP. The "API" is **typed Supabase queries** from the frontend plus a few Edge Functions. The Python AI service gets a small REST surface only when it becomes real (stretch).

## 1. Supabase client (frontend)

One shared client in `frontend/src/lib/supabase.ts` - import it, never create one per component.

```ts
import { createClient } from '@supabase/supabase-js'

export const supabase = createClient(
  import.meta.env.VITE_SUPABASE_URL as string,
  import.meta.env.VITE_SUPABASE_ANON_KEY as string,
)
```

## 2. Query cookbook

Sign up / sign in:

```ts
await supabase.auth.signUp({ email, password })
await supabase.auth.signInWithPassword({ email, password })
```

Profile upsert:

```ts
await supabase.from('profiles').upsert({
  user_id, full_name, country, city, skills, interests,
})
```

Country feed (filters: online, in-person, hackathon, conference, scholarship, job, cfp):

```ts
const { data } = await supabase.from('events')
  .select('*, profiles(full_name, country)')
  .eq('status', 'approved')
  .eq('country', 'IN')
  .order('event_date', { ascending: true })
// optional: .contains('tags', [filter])
```

Submit event:

```ts
await supabase.from('events').insert({
  title, description, country, city, event_date, url, tags,
  submitted_by: user.id,
})
// RLS forces status = 'pending'
```

Admin queue:

```ts
const { data } = await supabase.from('events')
  .select('*')
  .eq('status', 'pending')
  .order('submitted_at')
```

Approve/reject (through an RPC or Edge Function - never a raw client write to status):

```ts
await supabase.rpc('admin_event_action', {
  p_event_id: id,
  p_action: 'approve',           // approve | reject | duplicate
  p_reason: 'confirmed by host page',
})
```

Notifications: realtime channel on `events`, filter `status=approved` and own `country`, for live toasts.

## 3. Edge Functions (trusted server code)

| Endpoint | Method | Purpose | Auth |
|---|---|---|---|
| `/functions/v1/admin-event-action` | POST | approve / reject / edit / duplicate + audit row + notifications | JWT + `is_admin()` |
| `/functions/v1/scrape-trigger` | POST | start a crawl (stretch) | service bearer token |
| `/functions/v1/email-digest` | POST | weekly digest (stretch) | scheduled cron |

Admin event action contract:

```jsonc
POST /functions/v1/admin-event-action
{
  "event_id": "uuid",
  "action": "approve" | "reject" | "edit" | "duplicate",
  "reason": "why",
  "patch": { "title": "new title" }   // for action = edit
}
```

Responses: `200 {ok:true}` - `400` bad payload - `401` no JWT - `403` not admin - `404` no event - `409` already decided.

## 4. Python AI service (stretch - do not build yet)

FastAPI, JSON over HTTPS, internal use only:

```
POST /extract   { raw: jsonb }      -> { events: ExtractedEvent[] }
POST /verify    { event: Event }    -> { confidence: "0..1", reasons: ["..."] }
POST /dedupe    { events: Event[] } -> { duplicates: [{ a, b, score }] }
GET  /health                        -> { status: "ok" }
```

Guardrails baked into the contract:

- Never returns `status: approved` - output always lands in `scraped_raw` / admin queue.
- `confidence < 0.7` is visibly flagged "low confidence" in the admin UI.
- Dedupe only **suggests**; admins confirm duplicates.
- Rate limits: respect `robots.txt`, max 1 request per second per host, custom `User-Agent: DevBridgeBot/0.1 (+repo-url)`.
- No LinkedIn scraping, period (see [scraper-policy.md](scraper-policy.md)).
