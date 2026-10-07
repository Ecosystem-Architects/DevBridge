# Contributing to DevBridge

First off, **thanks** for considering to contribute — this project exists for SWOC participants like you. Every contribution level is welcome: docs, icons, RLS policies, scrapers.

## Project governance (how work happens)

- **Everything starts as an issue.** If it isn't an issue, you don't build it.
- **MVP scope is frozen.** If the feature is not in the MVP list in [PROPOSAL.md](PROPOSAL.md) or the README, it goes to the backlog.
- The admin reviews PRs within **24–48 h** and triages issues **weekly**; maintainers/mentors comment, request changes, and guide — they don't rewrite your code.
- Milestones are phase-based: **Foundation → MVP → Notifications → Developer Networking → AI & Scraping → Polish & Docs**. No fixed dates.

## Getting started (first-time contributors)

Fork the repository

```bash
git clone https://github.com/your-username/devbridge
cd devbridge/frontend
cp ../.env.example .env        # fill VITE_SUPABASE_URL / VITE_SUPABASE_ANON_KEY
npm ci
npm run dev
```

The app runs on <http://localhost:5173>. Seed data lives in [supabase/seed.sql](../supabase/seed.sql).

**First PR ideas:** `good first issue` label — dark mode toggle, empty states, loading skeletons, 404 page, accessibility labels on forms.

## Pull request checklist (Definition of Done)

- [ ] Linked to an issue (`Closes #NN`)
- [ ] Scope matches the issue — no drive-by features
- [ ] `npm run lint` and `npm run typecheck` pass
- [ ] `npm run build` succeeds
- [ ] Screenshot/GIF attached for UI changes
- [ ] Docs updated if behavior/tables/modules changed
- [ ] **No secrets** (`.env`, service keys, scraped private data) — CI blocks commits containing `.env`
- [ ] No `VITE_`-prefixed secret in frontend code; browser-exposed values are public by design
- [ ] Tests where reasonable

## Branching & commits

- Branches: `feat/<short-name>`, `fix/<short-name>`, `docs/<short-name>`
- Commits: [Conventional Commits](https://www.conventionalcommits.org) — `feat:`, `fix:`, `docs:`, `chore:`

## Issue levels & mentorship

| Label | What to expect |
|---|---|
| `good first issue` | Step-by-step acceptance criteria; ask questions in the issue thread |
| `intermediate` | Read [docs/rls.md](docs/rls.md) / [docs/api.md](docs/api.md) first |
| `advanced` | Scoping discussion required before coding |
| `mentored` | A maintainer will pair with you — say hi in the thread |

 mentoring rule: a mentor will **never** reject you for asking questions; we reject silent scope creep instead.

## Code style

- TypeScript strict mode; no `any` unless justified in a comment
- Tailwind classes for styling; shadcn/ui components over bespoke CSS
- Supabase access goes through RLS — a client must never use the `service_role` key
