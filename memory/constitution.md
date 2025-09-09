# Scion AI Funding Discovery Constitution

## Core Principles

### I. Library-First
Every feature starts as a standalone library within the backend project structure. Libraries must be:
- Self-contained with clear domain boundaries (scoring, normalization, connectors, alerts)
- Independently testable with their own test suites
- Documented with purpose, API contracts, and usage examples in llms.txt format
- Exposable via CLI entry points for debugging and operations

### II. CLI Interface
Every library exposes core functionality via CLI commands accessible through backend scripts:
- Text in/out protocol: configuration via args/env → structured output to stdout, errors to stderr
- Support both JSON (machine-readable) and human-readable formats
- Examples: `npm run script:search`, `npm run script:score`, `npm run script:export`

### III. Test-First (NON-NEGOTIABLE)
TDD methodology strictly enforced across all development:
- Contract tests → Integration tests → E2E tests → Unit tests (in that order)
- Red-Green-Refactor cycle: tests written and approved → tests fail → then implement
- Real dependencies in integration tests (Postgres/Redis in containers)
- Test approval gates before any implementation begins

### IV. Integration Testing
Focus areas requiring comprehensive integration test coverage:
- Source connector changes and new parser implementations
- Scoring algorithm modifications affecting matchScore calculations
- Shared schema changes between frontend and backend
- Inter-service communication (API ↔ Queue ↔ Database)
- Currency normalization and data transformation pipelines

### V. Observability
Structured logging and error tracking across all tiers:
- Request IDs and correlation IDs for tracing API → Queue → Processing flows
- Frontend error logs forwarded to backend via dedicated endpoint
- Error context includes: source name, crawl ID, retry count, user context
- Performance monitoring for list API (p95 ≤ 300ms), crawl throughput (≥ 100 pages/min)

### VI. Versioning & Breaking Changes
Semantic-like versioning during development (0.y.BUILD):
- Breaking changes controlled via contract tests and database migration scripts
- OpenAPI schema changes require backward compatibility or explicit migration path
- Database schema changes must include rollback procedures

### VII. Simplicity
Start simple and avoid premature optimization:
- Maximum 3 projects: backend, frontend, tests
- Use frameworks directly without custom wrappers (Fastify, Next.js, Prisma)
- Single shared data model - DTOs only for wire format differences
- Avoid repository/unit-of-work patterns - use ORM directly
- YAGNI principle - implement only what the current spec requires

## Technical Constraints

### Architecture Requirements
- API-first design with OpenAPI contracts defining frontend ↔ backend communication
- PostgreSQL primary store with Redis for queues/cache
- TypeScript end-to-end for consistency and type safety
- Web application structure (frontend + backend) deployed to Linux servers

### Performance Standards
- List API responses: p95 ≤ 300ms for 10k opportunities
- Crawl pipeline: sustained throughput ≥ 100 pages/min with backoff
- End-to-end scoring: ≤ 15 minutes for 5k opportunities
- Deterministic result ordering with tie-breaking rules

### Security & Compliance
- Role-based access control (Admin, Analyst, Researcher) enforced at API layer
- Audit logging for all administrative changes with before/after diffs
- WCAG 2.1 AA accessibility compliance for frontend
- No secrets in code or logs - use environment variables and secure storage

## Development Workflow

### Constitution Check Gates
Every plan must pass constitutional review at two stages:
1. **Initial Check**: Before Phase 0 research begins
2. **Post-Design Check**: After Phase 1 contracts completed

Required compliance verification:
- Project count ≤ 3
- Framework usage without custom wrappers
- Library-first architecture documented
- Test-first ordering planned

### Quality Gates
- All NEEDS CLARIFICATION items resolved before design phase
- Contract tests passing before implementation
- Integration tests with real dependencies (not mocks)
- Performance benchmarks met for list operations and crawl throughput

### Change Management
- Complexity deviations must be documented with justification in plan.md
- Breaking changes require migration scripts and rollback procedures
- Constitution amendments require update to all templates and commands

## Governance

This constitution supersedes all other development practices and coding conventions. All planning documents, task generation, and implementation reviews must verify constitutional compliance.

Constitution violations require either:
1. Refactoring the approach to achieve compliance, or
2. Documented justification with mitigation plan in the complexity tracking section

**Version**: 2.1.1 | **Ratified**: 2025-09-09 | **Last Amended**: 2025-09-09