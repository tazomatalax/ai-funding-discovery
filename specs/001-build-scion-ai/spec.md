# Feature Specification: Scion AI Funding Discovery System

**Feature Branch**: `001-build-scion-ai`  
**Created**: 2025-09-09  
**Status**: Draft  
**Input**: User description: "Build Scion AI Funding Discovery System, a production-grade full‑stack TypeScript app that continuously discovers, ranks, and tracks research funding opportunities for a New Zealand forestry research institute. Enable ingestion, scoring, search, alerts, analytics, and admin controls."

## Execution Flow (main)
```
1. Parse user description from Input
   → If empty: ERROR "No feature description provided"
2. Extract key concepts from description
   → Identify: actors, actions, data, constraints
3. For each unclear aspect:
   → Mark with [NEEDS CLARIFICATION: specific question]
4. Fill User Scenarios & Testing section
   → If no clear user flow: ERROR "Cannot determine user scenarios"
5. Generate Functional Requirements
   → Each requirement must be testable
   → Mark ambiguous requirements
6. Identify Key Entities (if data involved)
7. Run Review Checklist
   → If any [NEEDS CLARIFICATION]: WARN "Spec has uncertainties"
   → If implementation details found: ERROR "Remove tech details"
8. Return: SUCCESS (spec ready for planning)
```

---

## ⚡ Quick Guidelines
- ✅ Focus on WHAT users need and WHY
- ❌ Avoid HOW to implement (no tech stack, APIs, code structure)
- 👥 Written for business stakeholders, not developers

### Section Requirements
- **Mandatory sections**: Must be completed for every feature
- **Optional sections**: Include only when relevant to the feature
- When a section doesn't apply, remove it entirely (don't leave as "N/A")

### For AI Generation
When creating this spec from a user prompt:
1. **Mark all ambiguities**: Use [NEEDS CLARIFICATION: specific question] for any assumption you'd need to make
2. **Don't guess**: If the prompt doesn't specify something (e.g., "login system" without auth method), mark it
3. **Think like a tester**: Every vague requirement should fail the "testable and unambiguous" checklist item
4. **Common underspecified areas**:
   - User types and permissions
   - Data retention/deletion policies  
   - Performance targets and scale
   - Error handling behaviors
   - Integration requirements
   - Security/compliance needs

---

## User Scenarios & Testing *(mandatory)*

### Primary User Story
As an Analyst at a NZ forestry research institute, I can run an AI-powered search that ingests funding opportunities from priority sources, normalizes and scores them for institutional relevance, and surfaces the highest‑value opportunities with alerts so that my team can act in time.

### Acceptance Scenarios
1. Given no search is running, when an Analyst clicks “Run AI Search,” then the system enqueues a crawl, updates status to SEARCHING with a visible progress indicator, and, upon completion, appends newly discovered opportunities to the list.
2. Given a set of discovered opportunities, when a Researcher applies filters for research area, funding amount bucket, deadline window, and text query, then the system returns a server‑filtered, paginated, and sortable list that matches the filters and preserves them in the URL.
3. Given an opportunity with a near deadline (≤30 days), when the system processes alerts, then the opportunity is flagged as urgent and appears in the Alerts view and optional daily/weekly digests.
4. Given an Admin updates a source’s schedule or disables a connector, when changes are saved, then the system records the change in an audit log with actor, action, and before/after details.

### Edge Cases
- Source endpoints change format or are temporarily unavailable → the system records the error, retries with backoff, and surfaces a non‑blocking warning to Admins.
- Duplicate listings for the same opportunity (e.g., mirrored pages or title variants) → the system deduplicates by stable hash of URL/title+deadline and keeps the most complete/recent record.
- Amounts provided in different currencies and formats → amounts are normalized and bucketed (small/medium/large); exact normalization policy requires clarification.
- Very high volume of results in a single run → the system paginates server‑side and maintains performance targets for list responses.
- Deadlines in past or missing → past‑due are excluded from default views; missing deadlines are labeled and excluded from urgent alerts.

## Requirements *(mandatory)*

### Functional Requirements
- **FR-001**: The system MUST continuously ingest funding opportunities from priority sources (MBIE, Royal Society Te Apārangi/Marsden, Horizon Europe, Callaghan Innovation) and configurable industry sources.
- **FR-002**: The system MUST normalize ingested records: deduplicate by URL/title+deadline, parse deadlines, extract tags via keywords + embeddings, and normalize funding amount (value + currency) into buckets.
- **FR-003**: The system MUST compute a matchScore from 0–100 per opportunity using a weighted blend of research‑area alignment, tag overlap, embedding similarity to institute themes, recency, and source priority.
- **FR-004**: The system MUST store timestamps for matchScore generation and an explanation of the score’s key drivers per opportunity.
- **FR-005**: Users MUST be able to search and filter opportunities by research area, funding amount bucket, funding source, deadline windows (30d/3m/6m), and free‑text query.
- **FR-006**: The opportunities list MUST support server‑side pagination and sorting, and provide CSV export for the current filter set.
- **FR-007**: The system MUST persist search/filter state in the URL to enable sharing and returning to the same view.
- **FR-008**: The system MUST provide a “Run AI Search” action that triggers crawl → normalize → score, with a visible status indicator (SEARCHING/ACTIVE), last run time, queue depth, and progress animation.
- **FR-009**: The system MUST display opportunities in cards and a table view with columns: title, amount, currency, deadline, matchScore, source, and tags; rows open a detail drawer with description, eligibility, and link‑out.
- **FR-010**: Users MUST be able to Watch an opportunity, Assign owner/team, and Add it to a pipeline stage from the detail view or row actions.
- **FR-011**: The system MUST generate alerts for urgent deadlines (≤30 days), newly added/updated opportunities, and user‑defined reminders.
- **FR-012**: The system MUST support one‑click iCalendar (.ics) export for opportunities and reminders.
- **FR-013**: The system MUST support daily and weekly digest notifications via email and Slack (or equivalent team channel) for alerts and updates.
- **FR-014**: The system MUST provide analytics: Active Opportunities count, Total Available (currency‑normalized), Success Rate (% won vs submitted), Secured vs Target, and a trend sparkline; include a simple cohort by source.
- **FR-015**: Admins MUST be able to manage source connectors (enable/disable), edit crawl schedules (cron‑like expressions), configure tagging rules, adjust match‑score weights, and manage user roles and notification channels.
- **FR-016**: The system MUST record an audit log of changes to admin‑managed settings including actor, action, entity, before/after diff, and timestamp.
- **FR-017**: Access MUST be role‑based: Admin, Analyst, Researcher; write operations (e.g., settings changes, pipeline edits) MUST be restricted to appropriate roles.
- **FR-018**: The system MUST highlight urgent opportunities and new items in the UI and allow users to acknowledge or snooze alerts.
- **FR-019**: The system MUST ensure deterministic ordering of scored results when matchScore ties occur (e.g., secondary sort by recency and source priority).
- **FR-020**: The system MUST provide export of filtered opportunities to CSV with consistent columns and escaping rules.
- **FR-021**: The system MUST support institute focus areas (forestry science, biomaterials, industrial biotechnology, advanced manufacturing, climate/sustainability) as first‑class attributes for matching and filtering.
- **FR-022**: The system MUST allow Admins to add and maintain institute themes/taxonomy used for tag extraction and embedding similarity.
- **FR-023**: The system MUST surface data quality issues (e.g., missing deadline, unparseable amount) for Admin review without blocking normal user workflows.

Ambiguities to resolve (leave as is until clarified):
- **FR-A01**: Currency normalization policy [NEEDS CLARIFICATION: target currency, exchange rate source, and as‑of date handling].
- **FR-A02**: Digest delivery windows and quiet hours [NEEDS CLARIFICATION: default send times, timezone handling].
- **FR-A03**: Retention and deletion policies for opportunities, alerts, and audit logs [NEEDS CLARIFICATION: legal/compliance requirements].
- **FR-A04**: Exact industry source onboarding process [NEEDS CLARIFICATION: format expectations, review/approval flow].
- **FR-A05**: Accessibility targets beyond general keyboard/screen‑reader support [NEEDS CLARIFICATION: WCAG level, language/localization].

### Key Entities *(include if feature involves data)*
- **Source**: Represents an external origin of funding opportunities (e.g., MBIE, Marsden, Horizon Europe, Callaghan, industry). Key attributes: name, type, URL, schedule, enabled/disabled.
- **Opportunity**: A single funding opportunity record with title, summary, amount (value + currency), deadline, source, link, area, and tags; may include eligibility and description.
- **Tag**: A label derived from keywords or embeddings; used for filtering and scoring.
- **Embedding/Theme Similarity**: Numerical representation used to compare opportunities to institute themes to inform matchScore.
- **Alert**: A time‑bounded notification for urgent deadlines, updates, or user‑defined reminders; can be included in digests and ICS exports.
- **Watchlist**: A user’s saved set of opportunities of interest.
- **Pipeline Item**: Tracks an opportunity through stages (e.g., triage, drafting, submitted, won/lost) with ownership and notes.
- **Audit Log Entry**: Records administrative changes with actor, action, entity, diff, timestamp.
- **User & Role**: Represents authenticated users with roles Admin, Analyst, Researcher, governing access.

---

## Review & Acceptance Checklist
*GATE: Automated checks run during main() execution*

### Content Quality
- [ ] No implementation details (languages, frameworks, APIs)
- [ ] Focused on user value and business needs
- [ ] Written for non-technical stakeholders
- [ ] All mandatory sections completed

### Requirement Completeness
- [ ] No [NEEDS CLARIFICATION] markers remain
- [ ] Requirements are testable and unambiguous  
- [ ] Success criteria are measurable
- [ ] Scope is clearly bounded
- [ ] Dependencies and assumptions identified

---

## Execution Status
*Updated by main() during processing*

- [ ] User description parsed
- [ ] Key concepts extracted
- [ ] Ambiguities marked
- [ ] User scenarios defined
- [ ] Requirements generated
- [ ] Entities identified
- [ ] Review checklist passed

---
