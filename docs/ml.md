# ML & Agents (stretch goals only)

This document scoping exists so contributors do not cite "AI" as a reason to break MVP scope. **Do not build in MVP.** See [scraper-policy.md](scraper-policy.md) for the automation/ethics part.

## Planned components (advanced milestones only)

| Agent | What it does | Input | Output | Danger | Mitigation |
|---|---|---|---|---|---|
| Scraper | Devpost RSS / public APIs -> raw items | feed URL | `scraped_raw` rows | politeness/legality | robots.txt, rate limit, no LinkedIn |
| Extractor | raw JSON -> clean events | scraped items | candidate `events` | wrong dates/fields | non-destructive drafts |
| Verification | confidence + reasons | event object | 0-1 score + text list | false trust | visible flag only; admin decides |
| Duplicate detector | fuzzy match title/venue/date | candidate pairs | pair + similarity | false merges | admin confirms, never auto-merge |
| Recommendation | relevance per user | profile + country + interests | ranked feed | echo chamber | flat country feed stays the default |

## Non-negotiable invariants (even after these agents exist)

1. **No auto-publishing.** Every event path ends at the human admin queue. (ADR-001)
2. **"Verified" = admin-approved + policy checks passed**, never ML truth. (ADR-004)
3. A low-confidence event is **flagged, never silently rejected**; high-confidence is **flagged, never auto-approved**.
4. Agent writes only touch `scraped_raw` / `verification_results`; never `events.status`.
5. Agents are idempotent and replay-safe; a re-run must not duplicate rows.

## Tech notes for whoever builds it (later)

- Python 3.12, FastAPI, uvicorn; stateless hourly jobs driven by Supabase cron / GitHub Actions scheduler.
- `scikit-learn` first (TF-IDF on titles + date/venue simliarity) before any LLM - cheaper and auditable.
- Everything logged with `verified_by_agent` = name + version + config hash, so results are reproducible.
- Keep `ai-service/` a **separate deploy** from frontend/Supabase; talk to it via the `scrape-trigger` Edge Function only.

If any of this changes behavior visible to users, update `docs/architecture.md` first.
