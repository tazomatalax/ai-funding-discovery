# Research and Decisions: Scion AI Funding Discovery

Date: 2025-09-09  
Branch: 001-build-scion-ai  
Spec: /home/tasman/projects/ai-funding-discovery/specs/001-build-scion-ai/spec.md

This document consolidates key unknowns, options, and selected decisions to enable Phase 1 design and contracts. Each decision includes rationale and alternatives considered.

## 1. Currency Normalization Policy (FR-A01)
- Decision: Normalize amounts to NZD using RBNZ daily rates; fallback to ECB rates if RBNZ unavailable. Store source, rate, and as-of date per normalization.
- Rationale: NZ institute context; RBNZ is authoritative. Storing meta ensures auditability and reproducibility of totals/analytics.
- Alternatives: Always ECB (broader coverage) — rejected due to local context; On-demand conversion at query time — rejected due to inconsistent analytics and cost.

## 2. Digest Windows and Quiet Hours (FR-A02)
- Decision: Daily at 09:00 NZ local time; Weekly Monday 09:00 NZ local time; quiet hours 22:00–07:00 NZ local time. Timezone resolved via user profile; default to institute timezone.
- Rationale: Aligns with workday starts; avoids off-hours notifications.
- Alternatives: UTC-fixed scheduling — rejected for local user experience; Immediate push only — rejected for noise.

## 3. Retention and Deletion (FR-A03)
- Decision: Opportunities retained 24 months; Alerts retained 6 months; Audit logs retained 24 months. Soft-delete flags plus archival tasks for long-term storage if required.
- Rationale: Balances analytics trends and storage costs; audit requirements.
- Alternatives: Indefinite retention — rejected for cost/compliance risk; 12 months — rejected as too short for funding cycles.

## 4. Industry Source Onboarding (FR-A04)
- Decision: Admin can create a Source connector with fields: name, type, URL, schedule (cron), enabled flag, parser type (html/rss/api), optional auth. New connector starts disabled until first successful dry run; changes audited.
- Rationale: Minimizes bad data ingress; provides governance.
- Alternatives: Open self-serve source submission — rejected due to quality risks.

## 5. Accessibility Targets (FR-A05)
- Decision: WCAG 2.1 AA; keyboard navigation; ARIA roles; sufficient color contrast; readable fonts; focus management.
- Rationale: Standard institutional requirement; ensures usability.
- Alternatives: A-level only — rejected; AAA — deferred due to effort vs benefit now.

## 6. Architecture and Technology
- Decision: Web application architecture with API-first approach (OpenAPI). Backend: Node.js 20 with TypeScript; HTTP framework TBD (Fastify or NestJS). Queue: Redis + BullMQ; DB: PostgreSQL 16; ORM: Prisma; optional pgvector for embeddings. Frontend framework TBD (React/Next.js vs Vue/Nuxt) — to be confirmed in Phase 1 contracts usage examples.
- Rationale: TypeScript end-to-end increases consistency; Postgres rich types; Redis common for queues; OpenAPI enables contract-first and tests.
- Alternatives: Python (FastAPI), Go (Fiber), Java (Spring) — viable but reduce TS unification.

## 7. Scoring Model (FR-003, FR-004)
- Decision: Weighted blend (0–100) from: research-area alignment (taxonomy match), tag overlap, embedding similarity to institute themes, recency (log decay), and source priority. Persist score, breakdown, and explanation fields (top drivers and weights).
- Rationale: Transparent scoring with explainability for analysts; deterministic ordering tie-breakers.
- Alternatives: Black-box ML model — rejected initially; can iterate later.

## 8. Deduplication (FR-002)
- Decision: Stable dedupe key = hash(normalized_url OR (title_norm + deadline_date)). Keep most complete/recent record; maintain `duplicateOf` reference if merged.
- Rationale: Common mirror/variant cases; preserves data lineage.
- Alternatives: URL-only — insufficient; fuzzy only — too risky.

## 9. Tag Extraction
- Decision: Hybrid: keyword rules from Admin-managed taxonomy + embedding-based similarity thresholds to themes. Store tags with confidence score.
- Rationale: Deterministic plus semantic coverage.
- Alternatives: Only keywords — misses nuance; only embeddings — less controllable.

## 10. Filters, Pagination, Sorting (FR-005–FR-007, FR-019)
- Decision: Server-side filtering and pagination with stable cursor or offset/limit; sorting by matchScore desc, then recency desc, then source priority desc to break ties.
- Rationale: Performance and deterministic ordering.
- Alternatives: Client-side — rejected for large datasets.

## 11. Alerts and Digests (FR-011–FR-013)
- Decision: Alert types: urgent deadlines (≤30d), newly added/updated, user reminders. Delivery channels: email and Slack. One-click ICS export for opportunities/reminders. Snooze/acknowledge stored per user.
- Rationale: Meets core user needs from spec.
- Alternatives: Push/mobile — future.

## 12. Analytics (FR-014)
- Decision: Precompute daily aggregates for dashboard: Active Opportunities, Total Available (in NZD), Success Rate, Secured vs Target, trends; cohort by source.
- Rationale: Performance and consistency.
- Alternatives: On-the-fly queries — may be slow at volume.

## 13. RBAC and Audit (FR-015–FR-017)
- Decision: Roles: Admin, Analyst, Researcher. Enforce in API. Audit log captures actor, action, entity, before/after diff, timestamp and requestId.
- Rationale: Governance and traceability.

## 14. Data Quality (FR-023)
- Decision: Track data quality flags per opportunity (missing deadline, amount parse issues). Surface non-blocking warnings to Admin UI and logs.
- Rationale: Operational visibility without blocking users.

---
All critical NEEDS CLARIFICATION items have decisions recorded to unblock Phase 1 design.
