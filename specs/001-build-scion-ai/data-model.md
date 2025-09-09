# Data Model: Scion AI Funding Discovery

This document lists core entities, key fields, and relationships derived from the feature spec and research decisions. It is technology-agnostic and will guide schema and contract generation.

## Entity: Source
- id (uuid)
- name (string, unique)
- type (enum: government, council, industry, international)
- url (string)
- schedule (cron string)
- enabled (boolean)
- parserType (enum: html, rss, api)
- authConfig (json, optional)
- createdAt, updatedAt (timestamp)

## Entity: Opportunity
- id (uuid)
- sourceId (fk → Source)
- title (string)
- summary (text)
- link (string)
- deadline (date, nullable)
- amountValue (decimal, nullable)
- amountCurrency (string, nullable)
- amountBucket (enum: small, medium, large, unknown)
- researchAreas (string[])
- tags (string[])
- normalized (boolean)
- dedupeKey (string, unique)
- duplicateOf (uuid, nullable)
- matchScore (int 0–100)
- matchScoreAt (timestamp, nullable)
- matchExplanation (json: drivers/weights)
- dataQuality (json: flags array)
- createdAt, updatedAt (timestamp)

## Entity: Tag
- id (uuid)
- name (string, unique)
- type (enum: keyword, theme)
- createdAt, updatedAt (timestamp)

## Entity: Theme
- id (uuid)
- name (string, unique)
- embedding (vector or float[])
- description (text)
- createdAt, updatedAt (timestamp)

## Entity: Watchlist
- id (uuid)
- userId (fk → User)
- name (string)
- createdAt, updatedAt (timestamp)

## Entity: WatchlistItem
- id (uuid)
- watchlistId (fk → Watchlist)
- opportunityId (fk → Opportunity)
- createdAt (timestamp)

## Entity: PipelineItem
- id (uuid)
- opportunityId (fk → Opportunity)
- ownerUserId (fk → User)
- stage (enum: triage, drafting, submitted, won, lost)
- notes (text)
- createdAt, updatedAt (timestamp)

## Entity: Alert
- id (uuid)
- userId (fk → User, nullable for system alerts)
- opportunityId (fk → Opportunity, nullable for digests)
- type (enum: urgentDeadline, newOrUpdated, reminder)
- dueAt (timestamp)
- deliveredChannels (string[])
- status (enum: pending, sent, snoozed, acknowledged)
- snoozeUntil (timestamp, nullable)
- createdAt, updatedAt (timestamp)

## Entity: DigestPreference
- id (uuid)
- userId (fk → User)
- cadence (enum: daily, weekly)
- sendHourLocal (int 0–23)
- timezone (IANA string)
- quietHoursStart (int 0–23)
- quietHoursEnd (int 0–23)
- channels (string[]: email, slack)
- createdAt, updatedAt (timestamp)

## Entity: AuditLog
- id (uuid)
- actorUserId (fk → User)
- action (string)
- entity (string)
- entityId (string)
- before (json, nullable)
- after (json)
- createdAt (timestamp)
- requestId (string)

## Entity: User
- id (uuid)
- email (string, unique)
- name (string)
- role (enum: admin, analyst, researcher)
- createdAt, updatedAt (timestamp)

## Relationships
- Source 1—* Opportunity
- User 1—* Watchlist; Watchlist 1—* WatchlistItem; WatchlistItem *—1 Opportunity
- Opportunity 1—* PipelineItem
- Opportunity *—* Tag (materialized as tags array for now; optional join table later)
- Theme used to generate Tag assignments and matchScore
- User 1—* Alert
- User 1—* DigestPreference (1 per user typical)
- User 1—* AuditLog

## Validation Rules
- Opportunity.deadline must be in the future for urgent alerts; past deadlines excluded from default views
- amountBucket derived from amountValue (normalized to NZD): small (< NZD 100k), medium (100k–1m), large (> 1m); unknown when missing
- dedupeKey required and unique when normalized=true
- matchScore must be 0–100; if set, matchScoreAt required
- role-based writes enforced for admin-only entities (Source, Theme, weights config)

## State Transitions
- PipelineItem.stage transitions: triage → drafting → submitted → won/lost
- Alert.status transitions: pending → sent OR snoozed; snoozed → pending; any → acknowledged

---
This model is the baseline for contract and schema generation.