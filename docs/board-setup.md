# Board, Milestones & Label Setup (maintainer runbook)

One-time GitHub setup for the DevBridge repo. Do this **before** the first contributor signup.

## 1. Labels

Create (or rename to) exactly these labels. `good first issue` already ships with rough default colors - adjust to the palette:

```
good first issue   #7057ff
help wanted        #008672
intermediate       #fbca04
advanced           #d93f0b
SWOC               #0e8a16
frontend           #23d1ac
backend            #1d76db
supabase           #3e6dcc
ai                 #b60205
docs               #0075ca
bug                #ee0701
enhancement        #84b6eb
blocked            #b60205
needs review       #c2e0c6
in progress        #ededed
duplicate          #cdef11
security           #5319e7
infra / CI         #e99695
```

Apply **size + area + SWOC** to every issue; `blocked` / `needs review` / `in progress` are workflow labels a maintainer moves, never applied at creation.

## 2. Milestones (phase-based - no 2-week timeline)

Order matters. Ship the walking skeleton inside milestone 1.

| Milestone | Contains | Est. phase |
|---|---|---|
| **1. Foundation** | Repo skeleton, docs, CI, RLS migration, seed data, auth flow, profile page | weeks 1-2 (soft) |
| **2. MVP core** | Submit form, admin queue + approve/reject/edit/duplicate, approved country feed + filters | soft |
| **3. Notifications** | Realtime feed toasts + in-app notifications page/handler | soft |
| **4. Developer Networking** | Directory search, follow/connect, basic messaging | soft |
| **4.5 Opportunities board** | CRUD + filters for jobs/internships/scholarships/programs/CFPs | soft |
| **5. AI & Scraping** | Devpost RSS scraper, verification agent, dedupe (queue only) | soft |
| **6. Polish & Docs** | Empty/loading/error states, accessibility pass, digest (stretch), launch post | soft |

Each milestone gets **its own issues at authoring time** - do not retro-agenda.

## 3. Project board

One board: **DevBridge Delivery** (backlog + active).

Columns (add a workflow rule to auto-add new issues):

1. **Backlog** - created issues, not yet ready
2. **Ready** - has acceptance criteria, unassigned, start-here column
3. **In Progress** - max 2 columns per contributor; mention issue # in PR
4. **Review** - PR open; reviewer assigned (maintainer/mentor)
5. **Blocked** - set `blocked` label + comment explaining what is needed
6. **Done** - merged; close linked issue automatically

Weekly triage: empty `Blocked`, re-assign stale `In Progress`, review every PR in `Review`.

## 4. First-week issue wave (minimum today)

Create these **before** accepting the first contributor:

- 15-25 issues total, split roughly: 8-10 `good first issue`, 8-10 intermediate, 5 advanced
- Every issue has: context, expected outcome, files likely involved, acceptance criteria, difficulty label, mentor hint
- See [issue-list.md](issue-list.md) (the copy-paste source for every issue body)

## 5. Admin commitments (paste into every onboarding thread)

- PR review within **24-48 h**
- Issue triage **weekly** (fixed day)
- Mentors answer `good first issue` questions in-thread
- MVP scope is frozen; new ideas -> backlog, not scope creep
- The admin does **not** implement all features - module leads: frontend / Supabase / docs / AI
