# Database

Postgres 15+ (Supabase). Schema is versioned as plain SQL in [supabase/migrations](../supabase/migrations). **RLS is enabled on every table** - see [rls.md](rls.md).

## ERD (text form)

```
profiles 1---* events            (submitted_by)
profiles 1---* opportunities     (submitted_by)
profiles 1---* notifications     (user_id)
profiles 1---* follows           (follower_id, following_id)
events   1---* admin_actions     (event_id)
event_sources 1---* scraped_raw  (source_id)
scraped_raw 0---1 events         (promoted after admin approval)
events   1---* verification_results (event_id)
```

## Tables

### profiles
| column | type | notes |
|---|---|---|
| user_id | uuid PK | = `auth.users.id`, FK cascade |
| full_name | text | |
| country | text | ISO 3166-1 alpha-2 ("IN", "NG", ...), not null |
| city | text | |
| skills | text[] | e.g. `{react, python}` |
| interests | text[] | e.g. `{hackathons, oss}` |
| github | text | handle or link |
| linkedin | text | handle or link |
| created_at | timestamptz | default now() |

### events
| column | type | notes |
|---|---|---|
| id | uuid PK | |
| title | text | not null |
| description | text | |
| country | text | alpha-2, not null, indexed |
| city | text | |
| event_date | date | indexed |
| url | text | |
| tags | text[] | online, in-person, hackathon, conference, scholarship, job, cfp |
| status | text | draft / pending / approved / rejected / duplicate; default `pending` |
| submitted_by | uuid | FK profiles, indexed |
| approved_by | uuid | FK profiles, nullable |
| submitted_at | timestamptz | default now() |
| decided_at | timestamptz | nullable |

### event_sources
| column | type | notes |
|---|---|---|
| id | uuid PK | |
| name | text | e.g. "Devpost RSS" |
| type | text | rss / api / manual |
| url | text | |
| last_scraped_at | timestamptz | nullable |

### scraped_raw
| column | type | notes |
|---|---|---|
| id | uuid PK | |
| source_id | uuid FK | event_sources |
| raw_data | jsonb | untouched payload |
| scraped_at | timestamptz | |
| processed | boolean | default false |

### verification_results
| column | type | notes |
|---|---|---|
| id | uuid PK | |
| event_id | uuid FK | events |
| confidence | numeric | 0 to 1 |
| reasons | text[] | e.g. "url resolves", "date matches source" |
| verified_by_agent | text | agent name / version |
| created_at | timestamptz | |

### opportunities
| column | type | notes |
|---|---|---|
| id | uuid PK | |
| title | text | not null |
| type | text | job / internship / scholarship / program / cfp |
| country | text | alpha-2, or the special value `online` |
| url | text | |
| deadline | date | nullable |
| status | text | pending / approved / rejected, default `pending` |
| submitted_by | uuid | FK profiles |

### follows
| column | type | notes |
|---|---|---|
| follower_id | uuid | PK part, FK profiles |
| following_id | uuid | PK part, FK profiles |
| created_at | timestamptz | |
| constraint | - | follower_id <> following_id |

### notifications
| column | type | notes |
|---|---|---|
| id | uuid PK | |
| user_id | uuid FK | profiles |
| type | text | event_approved / new_in_country / ... |
| payload | jsonb | e.g. `{"event_id": "..."}` |
| read_at | timestamptz | nullable |
| created_at | timestamptz | |

### admin_actions (audit log)
| column | type | notes |
|---|---|---|
| id | uuid PK | |
| admin_id | uuid FK | profiles |
| event_id | uuid FK | events |
| action | text | approve / reject / edit / duplicate |
| reason | text | |
| created_at | timestamptz | |

## Indexes

- `events(country, status)`, `events(event_date)`, `events(status, submitted_by)`
- `profiles(country)`; GIN on `profiles.skills` and `profiles.interests`
- `scraped_raw(source_id, processed)`
- `notifications(user_id, read_at)`
- unique: `follows(follower_id, following_id)`

## Conventions

- All PKs are `uuid` with `gen_random_uuid()`.
- `updated_at` is maintained by a trigger.
- Status-like fields are `text` with a CHECK constraint, so extension is easy.
- Seed data uses fixed UUIDs so it can be re-applied idempotently.
