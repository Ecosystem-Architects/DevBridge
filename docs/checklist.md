# Submission Checklist (SWOC admin package)

Tick every box before submitting to the SWOC team. This file is the **final gate**.

## Repo basics

- [ ] Public GitHub repo (`your-org/devbridge`)
- [ ] MIT `LICENSE`
- [ ] `README.md` with problem, solution, stack, setup, architecture
- [ ] `PROPOSAL.md` one-pager (problem/solution/MVP/stack/impact)
- [ ] `.env.example` committed (no real keys)

## Community & governance

- [ ] `CONTRIBUTING.md`
- [ ] `CODE_OF_CONDUCT.md`
- [ ] `SECURITY.md`
- [ ] Issue templates + PR template (.github/ISSUE_TEMPLATE)
- [ ] Labels configured (`good first issue`, `SWOC`, `frontend`, `backend`, `ai`, `docs`, `bug`, `help wanted`, `blocked`, `needs review`)
- [ ] Project board URL live with Backlog / Ready / In Progress / Review / Blocked / Done
- [ ] Milestones: Foundation → MVP → Notifications → Networking → AI & Scraping → Polish & Docs

## Issues

- [ ] 15-25+ issues open (**target: 28** - see [issue-list.md](issue-list.md))
- [ ] ≥ 8-10 labeled `good first issue`
- [ ] 8-10 intermediate, 5+ advanced
- [ ] Every issue has: context, expected outcome, files, acceptance criteria, difficulty, labels, mentor hint

## Technical docs

- [ ] [architecture.md](architecture.md)
- [ ] [database.md](database.md) - ERD + tables
- [ ] [rls.md](rls.md) - security decision table
- [ ] [api.md](api.md)
- [ ] [scraper-policy.md](scraper-policy.md)
- [ ] [admin-guide.md](admin-guide.md)
- [ ] [privacy.md](privacy.md)
- [ ] [ml.md](ml.md) (stretch-only scoping)
- [ ] [board-setup.md](board-setup.md) (runbook)

## Engineering container

- [ ] CI workflow (lint → typecheck → build -> audit)
- [ ] Supabase migration: schema + RLS + seed
- [ ] Walking-skeleton frontend: auth + profile (country) + events + submit + admin queue + country feed
- [ ] Seed data installs cleanly
- [ ] `ai-service/` stub with "do not build yet" README

## Admin commitments (put in README + Discussions welcome post)

- [ ] Admin contact published (email + Discord handle)
- [ ] SLA: PR review 24-48 h; weekly issue triage
- [ ] Statement: "I will maintain, review, and mentor; I will not implement all features myself"
- [ ] Module leads declared once contributors onboard: frontend / Supabase / docs / AI

## Anti-risks double-check

- [ ] No `.env` or service keys committed (CI also guards)
- [ ] No LinkedIn scraping anywhere in plans; [scraper-policy.md](scraper-policy.md) is binding
- [ ] "Never auto-publish" stated in [architecture.md](architecture.md), [admin-guide.md](admin-guide.md), [ml.md](ml.md) and MIN scope
- [ ] No 2-week timeline anywhere; only phase-based milestones

When everything is ticked: submit the one-pager + repo link to the SWOC form.
