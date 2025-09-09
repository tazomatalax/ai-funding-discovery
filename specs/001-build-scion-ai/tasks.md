# Tasks: Scion AI Funding Discovery (TDD-ordered)

Note: Generated to unblock implementation. Follow RED→GREEN→REFACTOR strictly. Mark [P] for parallelizable tasks.

## Contract Tests (RED)
1. Contract test: Validate OpenAPI schema loads and basic lint passes
2. Contract test: GET /opportunities returns Page schema with deterministic sorting
3. Contract test: GET /opportunities supports filters (area, amountBucket, source, deadlineWindow, q)
4. Contract test: CSV export responds with text/csv and correct headers
5. Contract test: POST /search/run returns 202 and status progresses in /search/status
6. Contract test: GET /opportunities/{id} returns Opportunity schema
7. Contract test: POST /opportunities/{id}/watch returns 204 and watch recorded
8. Contract test: POST /opportunities/{id}/assign validates payload and returns 204
9. Contract test: POST /opportunities/{id}/pipeline stage update validates enum and returns 204
10. Contract test: Alerts — list/ack/snooze endpoints respect schemas
11. Contract test: Admin sources — list/create/update endpoints and audit behavior
12. Contract test: Admin taxonomy themes — list/create
13. Contract test: Analytics summary returns expected fields

## Integration Tests (RED)
14. Seed Postgres/Redis containers; migration for core tables [P]
15. Ingestion pipeline: enqueue source crawl, handle backoff, write normalized opportunities, dedupe behavior
16. Scoring pipeline: compute score, store breakdown, deterministic tie-breakers
17. Filters/pagination/sorting: performance target p95 ≤ 300ms at 10k rows (basic dataset)
18. Alerts processor: urgent deadlines ≤30d; new/updated; reminders; snooze/ack logic
19. Digests: daily/weekly generation windows; quiet hours enforced; email/Slack delivery mocks
20. CSV/ICS export correctness (escaping, timezone handling)
21. Audit log captures admin changes with actor, before/after
22. RBAC enforcement: Admin vs Analyst vs Researcher across write operations

## E2E Tests (RED)
23. User story 1: "Run AI Search" enqueues and updates status; new opportunities appear
24. User story 2: Filtered list preserves state in URL and server-side filters match
25. User story 3: Urgent opportunity appears in Alerts and digest
26. User story 4: Admin updates source schedule; audit log records change

## Unit Tests (RED)
27. Deduplication key generation from url/title+deadline
28. Deadline parsing and amount normalization to NZD with rate metadata
29. Tag extraction: keywords and embedding similarity thresholds
30. Score calculation: weighted blend and explanation generation

## Implementation (Make RED tests GREEN)
31. Minimal API server scaffolding (auth, routing, error handling) [P]
32. Data access layer via ORM; migrations for entities [P]
33. Search status tracking; run queue integration; progress metrics
34. Ingestion connectors for MBIE, Royal Society/Marsden, Horizon Europe, Callaghan; industry connector template
35. Normalization/deduplication pipeline; data quality flags
36. Scoring module with weights and explainability
37. Filtering, pagination, sorting, and CSV export
38. Alerts processor and snooze/ack endpoints; digest scheduler and channels
39. Analytics aggregates and summary endpoint
40. Admin: sources CRUD, schedules, tagging rules, match-score weights; audit log
41. RBAC middleware and permission checks
42. ICS export for opportunities and reminders

## Observability and Ops
43. Structured logging with request IDs and correlation IDs
44. Basic metrics (requests, queue sizes, processing durations)
45. Error handling and retries with backoff

## Documentation
46. Update quickstart with run instructions and test execution
47. Add README for backend/frontend setup (later when scaffolded)

---
Execute tasks in order, honoring test-first. Parallelize [P] where safe.
