Build “Scion AI Funding Discovery System,” a production-grade full‑stack TypeScript app that continuously discovers, ranks, and tracks research funding opportunities for a New Zealand forestry research institute. Do not generate static HTML. Produce a complete, maintainable codebase with components, server logic, database schema, background jobs, and tests.

Product mission:

Continuously ingest and normalize funding opportunities from NZ and international sources, compute a 0–100 match score per opportunity, and surface actionable alerts, reminders, and analytics.

Enable analysts and researchers to filter, watch, and pipeline opportunities; give admins control over sources, schedules, and roles.

Users and roles:

Admin: manage sources, schedules, roles, and system settings.

Analyst: run searches, review results, manage alerts, assign opportunities.

Researcher: browse, filter, watch, and export opportunities; receive reminders.

Core features:

Source ingestion and normalization: connectors for MBIE, Royal Society Te Apārangi (Marsden), Horizon Europe, Callaghan Innovation, and configurable industry sources (RSS/HTML/API); deduplicate by URL/title+deadline, normalize amount (value + currency), parse deadlines, and extract tags via keywords + embeddings.

Matching and scoring: compute matchScore (0–100) using weighted blend of research-area alignment, tag overlap, embedding similarity to institute themes, recency, and source priority; store timestamps and explanations.

Search and filters: researchArea, fundingAmount bucket (small/medium/large), fundingSource, deadline windows (30d/3m/6m), free-text query; server-side pagination/sorting; CSV export; URL/search param persistence.

“Run AI Search”: button triggers crawl → normalize → score; AI Status card shows state (SEARCHING/ACTIVE), last run time, queue depth, and progress animation.

Opportunities UI: cards and a table view; columns: title, amount, currency, deadline, matchScore, source, tags; row detail drawer with description, eligibility, link-out, and actions: Watch, Assign owner/team, Add to pipeline stage.

Alerts and reminders: urgent-deadline detection (e.g., ≤30 days), newly added/updated opportunities, custom reminders; one-click ICS calendar export; daily/weekly email/Slack digests.

Analytics: tiles for Active Opportunities, Total Available (currency-normalized sum), Success Rate (% won vs submitted), Secured vs Target; sparkline for trend over time; simple cohort by source.

Admin console: manage source connectors, crawl schedules (cron), tagging rules, match-score weights, user roles, and notification channels; view audit log of changes.

Architecture and stack:

Next.js (App Router) + TypeScript; Tailwind + shadcn/ui for consistent UI; TanStack Table for the grid; Zod for validation; React Server Components plus client hooks where needed.

Database: Postgres with migrations and seed; pgvector for embeddings; background worker for crawl/score; job queue and scheduler; API routes + Server Actions for CRUD.

Auth: NextAuth (email/password or enterprise-ready provider) with RBAC: admin, analyst, researcher; scoped access in routes and server actions.

AI provider abstraction: single service with adapters for litellm, Ollama, or OpenAI via env flags; used for tag assistance and embedding generation.

Delivery: Dockerfile + docker-compose for app, worker, Postgres (with pgvector); healthchecks; one-command local start.

Tests: Vitest unit tests (normalization, scoring, API handlers) and Playwright e2e (filters, table behaviors, watchlist flow).

Data model (create schema + migrations + seeds):

sources(id, name, type, url, schedule_cron, enabled, created_at, updated_at)

opportunities(id, title, amount_value, currency, deadline, description, source_id, area, funding_level, url, created_at, updated_at, hash_dedupe)

opportunity_tags(opportunity_id, tag)

embeddings(opportunity_id, vector, dim, provider, created_at)

alerts(id, title, body, severity, due_at, opportunity_id, created_by, created_at)

user_watchlist(user_id, opportunity_id, created_at)

pipeline(id, opportunity_id, stage, owner_id, notes, updated_at)

audit_log(id, actor_id, action, entity, entity_id, diff_json, created_at)

APIs and server actions:

GET /api/opportunities: server-side filters, sort, pagination; CSV export.

POST /api/search/run: enqueue crawl; GET /api/search/status: queue depth, last run, last error.

POST /api/watchlist, DELETE /api/watchlist/:id; GET /api/alerts; PATCH /api/pipeline/:id.

Admin endpoints for sources, schedules, score weights; all inputs validated with Zod; typed responses end-to-end.

Jobs and workflows:

connectors/: fetchers for MBIE, Marsden, Horizon, Callaghan, configurable industry; return normalized JSON.

normalizer/: parse amount and currency, deadline, tags; dedupe by stable hash; attach metadata.

scorer/: compute matchScore with configurable weights; persist score + explanation; “recompute all” script.

scheduler/: cron-based kicks; safe re-entrancy; per-source rate limits and backoff.

Non-functional requirements:

Performance: server list endpoint p95 under 200ms for 10k rows with index strategy; streaming responses where feasible.

Accessibility: keyboard and screen-reader support for filters, table, drawers, dialogs.

Security: role checks on write ops, audit logging on admin changes, rate limits on mutation endpoints; secrets never exposed to clients.

Configuration:

.env.example: DATABASE_URL, VECTOR_DIM, AI_PROVIDER=("litellm"|"ollama"|"openai"), LITELLM_BASE_URL, OLLAMA_BASE_URL, OPENAI_API_KEY, NEXTAUTH_SECRET, CRON_SECRET, NOTIFY_SLACK_WEBHOOK(optional).

Scripts: dev, build, start, seed, test, e2e, lint, typecheck, start:docker, recompute:scores.

Acceptance criteria:

Filters, table, and cards operate against server-side data with URL persistence and CSV export.

“Run AI Search” transitions status from SEARCHING to ACTIVE with realistic progress and new items appended.

Scoring pipeline writes numeric matchScore (0–100) with deterministic ordering; explanations visible in row detail.

Alerts highlight urgent deadlines and new items; ICS export and digest notifications function in dev.

Admin can enable/disable sources, edit cron, and adjust score weights with changes recorded in audit_log.

Tests pass in CI; typechecks and lints are clean; Docker composition runs end-to-end locally.

Notes to model:

Treat this spec as authoritative. Do not emit static HTML. Use shadcn/ui and TanStack Table for UI primitives and grid. Keep styling cohesive (greens/blues, subtle glass blur). Provide concise inline comments and a README with setup, env, and common tasks.

Assumptions
The institute’s focus areas include forestry science, biomaterials, industrial biotechnology, advanced manufacturing, and climate/sustainability; funding amount buckets are small/medium/large with currency normalization.

NZ sources (MBIE, Marsden, Callaghan) and EU Horizon are top priority; industry sources are configurable and can be added by admins over time.

One-line north star
Build an end-to-end system to continuously discover funding, compute a reliable match score, and turn results into actionable alerts and workflows for analysts and researchers.