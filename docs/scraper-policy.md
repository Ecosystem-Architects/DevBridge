# Scraper & Automation Policy

DevBridge will crawl **only** with explicit respect for the source. This policy scopes the advanced milestone (Python scraper in `ai-service/`). It is binding for every contributor and admin.

## Allowed sources (target list)

1. Official public **APIs** - always preferred over scraping.
2. Public **RSS/Atom feeds** (e.g. Devpost RSS, conference feeds, university calendars).
3. Public listing pages whose **robots.txt allows** our path and whose Terms of Service permit automated access.

## Hard rules

- **No LinkedIn scraping. Ever. Not via bots, not via browser automation, not via purchased data.** LinkedIn's User Agreement forbids it; risk stays with the project. If LinkedIn content matters, users submit it manually and admins verify.
- Respect `robots.txt` (parse, cache, honor). If a path is disallowed, we do not fetch it.
- Respect ToS of every source. If automated access is ambiguous - **ask first**, in the issue thread.
- Rate limit: max **1 request/second per host**, exponential backoff on 429/5xx, sensible crawl budgets.
- Identify honestly: `User-Agent: DevBridgeBot/0.1 (+https://github.com/your-org/devbridge)`.
- Do not fetch content behind logins, paywalls, or anti-bot warnings - signals of "keep out".
- Fetch text/metadata only. Do not store personal contact data (emails, phone numbers) - sanitize before persisting to `scraped_raw` (RLS doc rule 8).
- No reproducable rapid crawls in CI or demo videos; crawls run from the queue, never from a laptop loop.

## Pipeline rules

1. Scraper output goes to `event_sources` -> `scraped_raw` (raw, untouched payload).
2. `scraped_raw.processed` flips only after parsing stash + dedupe + verification stages.
3. Extracted events become `events` rows with `status = 'pending'` **always**.
4. `verification_results` adds a `confidence` (0-1) + `reasons`; below 0.7 is flagged visibly in the admin queue.
5. **Nothing auto-publishes.** Only a human admin's approve action flips a row to `approved`.

## Exceptions and takedowns

- Source owners may request exclusion: open an issue or email the admin; we remove the source from `event_sources` and purge its `scraped_raw` rows.
- If a source complains about rate or content, we pause it first and discuss later.
