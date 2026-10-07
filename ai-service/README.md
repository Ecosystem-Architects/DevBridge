# ai-service — ⛔ ADVANCED STRETCH GOAL — DO NOT BUILD YET

This folder is intentionally **empty** of code.

It is reserved for the SWOC **advanced** milestones:

1. **Scraper agent** (Devpost RSS / APIs first — see `docs/scraper-policy.md`)
2. **Verification agent** (confidence score for event authenticity)
3. **Duplicate detection** (fuzzy matching on title/venue/date)
4. **Recommendation model** (country/skill/interest scoring)

Stack (planned): Python 3.12 · FastAPI · Playwright / BeautifulSoup · scikit-learn · Railway/Render deploy.

## Guardrails that survive even after this service exists

- Events produced by any agent go to the **event_sources → scraped_raw** pipeline and **land in the admin approval queue** — never auto-published.
- LinkedIn scraping is **banned** (see `docs/scraper-policy.md`).
- `verification_results` records *confidence + reasons*; below-threshold events are visibly flagged in the admin UI.
- Scraped private data stays out of the repo and out of the database schema's PII columns.

First advanced issue: **Python scraper for Devpost RSS with robots.txt / rate limiting.**
