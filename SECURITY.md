# Security Policy

## Supported versions

This project is in active development; only the `main` branch receives security fixes.

## Reporting a vulnerability

**Do not open a public issue for security vulnerabilities.** Use GitHub's *Report a vulnerability* in the Security tab, or email. Reports are acknowledged within 48 h and triaged within 7 days.

## Security model highlights

| Threat | Current guardrail |
|---|---|
| Unauthenticated moderation | Approval/rejection/edit events are **admin-only** via Postgres RLS, not only UI |
| Leaked secrets | Service keys never ship to the browser; `.env` files gitignored; CI scans |
| Spam submissions | Rate limits + email verification (planned), admin queue regardless |
| Scraped content legality | [Scraper policy](docs/scraper-policy.md): robots.txt, ToS, no LinkedIn scraping |
| AI hallucination | **Never auto-publish** scraped or AI-verified events; admin approves everything |

## What an admin must never do

- Commit the `service_role` key anywhere
- Auto-publish scraped/agent-generated events
- Approve from an unauthenticated context
