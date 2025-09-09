# Implementation Plan: Scion AI Funding Discovery System

**Branch**: `001-build-scion-ai` | **Date**: 2025-09-09 | **Spec**: /home/tasman/projects/ai-funding-discovery/specs/001-build-scion-ai/spec.md
**Input**: Feature specification from `/specs/001-build-scion-ai/spec.md`

## Execution Flow (/plan command scope)
```
1. Load feature spec from Input path
   → If not found: ERROR "No feature spec at {path}"
2. Fill Technical Context (scan for NEEDS CLARIFICATION)
   → Detect Project Type from context (web=frontend+backend, mobile=app+api)
   → Set Structure Decision based on project type
3. Evaluate Constitution Check section below
   → If violations exist: Document in Complexity Tracking
   → If no justification possible: ERROR "Simplify approach first"
   → Update Progress Tracking: Initial Constitution Check
4. Execute Phase 0 → research.md
   → If NEEDS CLARIFICATION remain: ERROR "Resolve unknowns"
5. Execute Phase 1 → contracts, data-model.md, quickstart.md, agent-specific template file (e.g., `.github/copilot-instructions.md`).
6. Re-evaluate Constitution Check section
   → If new violations: Refactor design, return to Phase 1
   → Update Progress Tracking: Post-Design Constitution Check
7. Plan Phase 2 → Describe task generation approach
8. Generate tasks.md per repository prompt
```

## Summary
Build a production-grade full‑stack TypeScript system that continuously ingests, normalizes, deduplicates, scores (0–100), and surfaces research funding opportunities for a NZ forestry research institute with filtering, alerts/digests, analytics, and admin controls. Technical approach: web application architecture (frontend + backend) with PostgreSQL primary store, Redis-backed queues for ingestion, and OpenAPI contracts for UI↔API.

## Technical Context
**Language/Version**: TypeScript (Node.js 20 LTS), Browser JS ES2023  
**Primary Dependencies**: Frontend: Next.js 14 + React 18; Backend: Fastify 4; Queue: BullMQ; ORM: Prisma; Validation: Zod  
**Storage**: PostgreSQL 16 (primary), Redis 7 (queue/cache), optional pgvector for embeddings  
**Testing**: Vitest (unit/contract), Playwright (E2E), k6 (perf)  
**Target Platform**: Linux server for API/queues; modern browsers for frontend  
**Project Type**: web (frontend + backend)  
**Performance Goals**: List API p95 ≤ 300ms at 10k opportunities; crawl throughput ≥ 100 pages/min sustained with backoff; scoring pipeline end-to-end ≤ 15 min for 5k items  
**Constraints**: Deterministic ordering on ties; robust retry/backoff; auditability; CSV/ICS export correctness  
**Scale/Scope**: Initial data volume 10–100k opportunities, 10–100 users; Alert digests daily/weekly

Resolved for planning (from spec ambiguities):
- Currency normalization: Target NZD using RBNZ daily rate (fallback ECB); store exchange rate and as-of date per record.
- Digest windows: Default daily 09:00 and weekly Monday 09:00 NZST/NZDT; quiet hours 22:00–07:00 local.
- Retention: Opportunities retained 24 months; alerts 6 months; audit log 24 months.
- Industry source onboarding: Admin adds source with URL, type, parser; change goes through audit; connector disabled by default until first successful run.
- Accessibility: Target WCAG 2.1 AA; support keyboard and screen-reader labels.

## Constitution Check
*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

**Simplicity**:
- Projects: 3 (backend, frontend, tests) — within limit
- Using framework directly: Yes (no custom wrappers)
- Single data model: Yes (shared schema, DTOs only for wire formats)
- Avoiding patterns: Yes (no Repository/UoW; use ORM directly)

**Architecture**:
- EVERY feature as library: Core domain packaged as modules within backend; UI consumes API contracts
- Libraries listed: scoring (weights + explanation), normalization (parse/dedupe), connectors (per source), alerts (scheduler/digest)
- CLI per library: Provide CLI entry points via backend scripts for run-search, re-score, export
- Library docs: To be documented in llms.txt-style within each lib

**Testing (NON-NEGOTIABLE)**:
- Enforce RED-GREEN-Refactor in tasks.md ordering
- Order: Contract → Integration → E2E → Unit affirmed
- Real dependencies for integration (Postgres/Redis in containers)
- Integration tests planned for connectors, scoring changes, shared schemas

**Observability**:
- Structured logging with request IDs and correlation IDs
- Frontend error logs forwarded to backend via endpoint
- Error context: include source name, crawl id, retry count

**Versioning**:
- Semantic-like Version (0.y.BUILD during development)
- Breaking changes controlled via contract tests and migration scripts

## Project Structure

### Documentation (this feature)
```
specs/001-build-scion-ai/
├── plan.md              # This file (/plan command output)
├── research.md          # Phase 0 output (/plan command)
├── data-model.md        # Phase 1 output (/plan command)
├── quickstart.md        # Phase 1 output (/plan command)
├── contracts/           # Phase 1 output (/plan command)
└── tasks.md             # Phase 2 output (per repository prompt)
```

### Source Code (repository root)
```
backend/
├── src/
│   ├── models/
│   ├── services/
│   └── api/
└── tests/

frontend/
├── src/
│   ├── components/
│   ├── pages/
│   └── services/
└── tests/
```

**Structure Decision**: Web application (frontend + backend)

## Phase 0: Outline & Research
See `/home/tasman/projects/ai-funding-discovery/specs/001-build-scion-ai/research.md` for detailed decisions and rationale.

Key topics researched and set for planning:
- Currency normalization policy, exchange rates, as-of dates
- Digest schedule, timezone, quiet hours
- Retention windows for opportunities, alerts, audit
- Source onboarding flow and connector lifecycle
- Accessibility target (WCAG 2.1 AA)
- Architecture choices: API-first with OpenAPI; Postgres + Redis; queueing; embeddings option

**Output**: research.md with all critical NEEDS CLARIFICATION resolved for planning

## Phase 1: Design & Contracts
- Entities and relationships extracted to `data-model.md`
- API endpoints defined in `contracts/openapi.yaml` aligned to FR-001…FR-023
- Quickstart created to validate environment and contract-first flow

**Output**: data-model.md, /contracts/*, quickstart.md

## Phase 2: Task Planning Approach
- tasks.md generated to drive TDD: contract tests → integration → E2E → unit
- Ordering respects dependencies (models → services → UI)

## Phase 3+: Future Implementation
Out of scope for this plan document.

## Complexity Tracking
No deviations at this stage.

## Progress Tracking
**Phase Status**:
- [x] Phase 0: Research complete (/plan command)
- [x] Phase 1: Design complete (/plan command)
- [x] Phase 2: Task planning complete (/plan command)
- [ ] Phase 3: Tasks generated (/tasks command)
- [ ] Phase 4: Implementation complete
- [ ] Phase 5: Validation passed

**Gate Status**:
- [x] Initial Constitution Check: PASS
- [x] Post-Design Constitution Check: PASS
- [x] All NEEDS CLARIFICATION resolved for planning
- [x] Complexity deviations documented (none)

---
*Based on Constitution v2.1.1 - See `/memory/constitution.md`*