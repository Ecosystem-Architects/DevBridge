# Architecture

DevBridge separates concerns: the browser React app can only talk to Supabase **through RLS-guarded queries and public Edge Function endpoints** - it never holds a privileged key. The Python AI service is optional and stretch-only.

```
React SPA (Vite / Vercel) ----anon key over HTTPS---- Supabase
                                        |
                                        +-- Auth: email/password, magic link later
                                        +-- Postgres with Row Level Security
                                        +-- Realtime: feed/notify subscriptions
                                        +-- Edge Functions (trusted server code)
                                                       |
                                                       v (stretch)
                                            Python ai-service (FastAPI)
                                                       |
                                            RSS / public APIs only
                                                       |
                                     ALWAYS into admin approval queue - never auto-published
```

## Rule 1: browser privilege level

The React app ships only the **public** `anon` key. Every table is RLS-protected, so a stolen anon key cannot read pending events, other users' notifications, or anything beyond what any visitor could see.

## Rule 2: privileged operations stay server-side

Writes that need elevated rights happen in **Supabase Edge Functions** with `SUPABASE_SERVICE_ROLE_KEY` stored as a Supabase secret, never in the frontend bundle:

- approve / reject / edit / mark-duplicate events (admin-only, checked server-side)
- marking `scraped_raw` rows processed, creating `verification_results`
- inserting notification batches after approvals

## Supabase wiring

- **Auth:** email + password first; magic-link and OAuth later. `auth.users` and `profiles` are 1:1 via a trigger on user creation.
- **RLS:** see [rls.md](rls.md). A policy is never "just the UI hiding it".
- **Realtime:** subscribe to `events` changes; the feed shows live toasts for newly approved events in your country.
- **Storage:** not needed for the MVP (no uploads in MVP scope).

## Layers for a contributor

| Layer | Where | Rules |
|---|---|---|
| UI | `frontend/src` | React + Tailwind; TypeScript strict; Supabase access only via `lib/supabase.ts` |
| Data | `supabase/migrations` | RLS policies in the same migration as the table; no dashboard hot-fixes |
| Server | `supabase/functions` | Validate input; verify JWT + admin claim server-side |
| AI | `ai-service` | Do not build yet. When built: RSS/APIs only, respect robots.txt, no LinkedIn |

## Deployment targets

| Piece | Target |
|---|---|
| Frontend | Vercel (Vite preset) |
| Database / Auth / Realtime | Supabase cloud |
| Edge Functions | Supabase |
| AI service | Railway / Render (stretch, after MVP) |

## Architecture decision records (short form)

- **ADR-001:** all event approval goes through the admin queue; no auto-publish. (accepted)
- **ADR-002:** country is the primary feed sharding dimension. (accepted)
- **ADR-003:** notifications are in-app first; email digest is a stretch goal. (accepted)
- **ADR-004:** "verified" means "admin approved + policy checks passed", never ML truth. (accepted)
- **ADR-005:** RLS is the enforcement layer; the UI is a convenience on top. (accepted)
