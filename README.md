> [!TIP]
> 👋 This is a **Social Winter of Code (SWOC)'26** project. New here? Read [CONTRIBUTING.md](CONTRIBUTING.md), then pick an issue labeled `good first issue`.

# DevBridge 🔗

**Country-aware, admin-verified feed of developer events & opportunities.** One place instead of a dozen WhatsApp groups, LinkedIn posts, and newsletter scraps.

A developer submits an event → an admin approves it → developers in that country get notified. Everything goes through the approval queue; nothing is auto-published.

| Problem | DevBridge answer |
|---|---|
| Opportunities scattered across 10 channels | Single country-aware feed |
| Spam / fake events | Admin approval queue + verification policy |
| Missed deadlines | In-app notifications (email digest = stretch) |

## Status: Walking skeleton 🚧

The **scope is frozen to the MVP**. This repo currently ships the container — docs, governance, issues, schema — plus a minimal authenticated skeleton frontend. Contributors build the features ([see the board](https://github.com/your-org/devbridge/projects)).

## Tech Stack

- **Frontend:** React 18 + Vite + Tailwind CSS + shadcn/ui
- **Backend:** Supabase (Postgres, Auth, Realtime, Edge Functions, Storage) with **Row Level Security**
- **Stretch:** Python + FastAPI + Playwright/BeautifulSoup + scikit-learn (`ai-service/` — do **not** build yet)

## Architecture (30-second version)

```
React (Vercel) ──► Supabase (Postgres + RLS, Auth, Realtime, Edge Functions)
        options: RSS/APIs            │
                                     └──► optional Python AI service (stretch)
```

Details: [docs/architecture.md](docs/architecture.md)

## Contributing

We welcome first-time contributors. Read [CONTRIBUTING.md](CONTRIBUTING.md) and [docs/admin-guide.md](docs/admin-guide.md). Before opening a PR, run:

```bash
npm ci
npm run lint
npm run typecheck
npm run build
```

## Community & Support

- 🐛 Issues — use the [templates](.github/ISSUE_TEMPLATE)
- 💬 Discussions / `#devbridge` Discord channel for questions
- 🛡 See [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) and [SECURITY.md](SECURITY.md)
- 📅 Review SLA: PRs in 24–48 h, issue triage weekly

## Documentation

| Doc | Covers |
|---|---|
| [docs/architecture.md](docs/architecture.md) | React ↔ Supabase ↔ optional Python service |
| [docs/database.md](docs/database.md) | ERD, tables, relationships |
| [docs/rls.md](docs/rls.md) | Row Level Security rules |
| [docs/api.md](docs/api.md) | Supabase queries + future Python endpoints |
| [docs/scraper-policy.md](docs/scraper-policy.md) | Robots.txt / ToS / what we will not scrape |
| [docs/admin-guide.md](docs/admin-guide.md) | Approve / reject / edit / mark duplicate |
| [docs/privacy.md](docs/privacy.md) | Country & profile data, consent, deletion |
| [docs/ml.md](docs/ml.md) | Stretch goals only (agents, models) |
