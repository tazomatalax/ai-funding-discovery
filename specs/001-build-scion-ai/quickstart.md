# Quickstart: Scion AI Funding Discovery

This quickstart validates the contract-first design and basic flows without full implementation.

## Prerequisites
- Node.js 20+
- Docker (for Postgres/Redis during integration later)

## Steps
1. Review API contract at `/specs/001-build-scion-ai/contracts/openapi.yaml`.
2. Validate OpenAPI schema using your preferred validator.
3. Smoke test the core flows with placeholder endpoints:
   - Trigger search queue: POST /search/run → 202
   - Check status: GET /search/status → 200 with status and progress
   - List opportunities with filters and pagination
   - Export CSV for current filters
   - Watch, assign, and pipeline updates
   - Alerts list, ack, snooze
   - Admin: list and update sources; list/add themes
4. Confirm deterministic ordering: matchScore desc → recency desc → source priority desc.
5. Confirm URL-preserved filters at the frontend layer (to be implemented) and server-side pagination/filters at API.

## Notes
- Use contract tests (to be generated) to enforce schemas. Implementation should only proceed after RED tests exist.
- ICS export and Slack/email digests will be verified in integration tests in later phases.

---
Refer back to `spec.md` for acceptance scenarios while testing.