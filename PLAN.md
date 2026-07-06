# PLAN.md — Keja

Phase-gated, not time-boxed. A phase is complete when its **gate** passes — no calendar pressure, no skipping gates. Same discipline as OnboardKit.

Ordering principle: **data before demand.** The consumer experience is worthless until we have verified buildings in the database, so the agent pipeline ships first and gets battle-tested in one estate before any consumer surface exists.

---

## Phase 0 — Foundations

**Build:**
- Repo scaffold: monorepo (`api/`, `agent_app/`, `consumer_app/`, `web/`, `ops/`) or split repos — decide and commit.
- Docker Compose for local dev: `postgis`, `redis`, `api`, `minio`.
- Django project with GeoDjango wired to PostGIS; health endpoint; CI pipeline (lint + test + image build to GHCR).
- Core migrations: `Estate`, `Building`, `UnitType`, `VacancySnapshot`, `Agent` — including GiST index on `Building.location`.
- Seed script: 3 fake estates, 20 fake buildings with real Nairobi coordinates.

**Gate:**
- `docker compose up` on a clean machine gives a working API.
- A `dwithin` query against seeded data returns correct, distance-sorted results in a test.
- CI green on main; image pushed to GHCR.

---

## Phase 1 — Agent capture pipeline (API side)

**Build:**
- Agent auth: JWT + device binding (one active device per agent).
- Endpoints: create/update building, unit types, append vacancy snapshot, presigned photo upload flow.
- **Idempotent sync endpoint**: batch of records with `client_uuid`s; server upserts; response tells the client exactly what to mark as synced.
- E.164 phone normalization at the boundary (port from OTP module).
- `has_active_vacancy` denormalization: recomputed on snapshot insert.
- Celery staleness sweep: hourly; demote >14d, hide >30d, recompute flags.

**Gate:**
- Replaying the same sync batch 5× produces identical db state (test-proven).
- Snapshot append → flag flips correctly; sweep demotes a stale fixture correctly.
- Photo flow works end-to-end against minio without bytes touching the API.

---

## Phase 2 — Agent app (Flutter, offline-first)

**Build:**
- Auth + device binding flow.
- Capture flow: stand at gate → GPS pin (block save until accuracy ≤ 15m, show accuracy circle) → building form → unit types → vacancy counts → photos (client-side compression).
- Drift local db as source of truth; background sync worker drains queue; visible sync-status UI (pending / synced / failed per record).
- "My buildings" list with re-verify action (append new snapshot in 2 taps — this is the daily-use loop).

**Gate:**
- Full capture of a real building **in airplane mode**, then sync succeeds on reconnect with zero data loss and zero duplicates.
- Re-verifying a vacancy takes < 30 seconds in the field.
- One agent (you) captures **an entire pilot estate — every building on 3–5 streets in e.g. Roysambu — using only the app**. Friction found here is fixed here.

> This gate is the most important one in the plan. If capture is annoying, the whole business fails quietly.

---

## Phase 3 — Consumer map API

**Build:**
- Anonymous-readable endpoints: viewport (bbox) query, near-me (radius) query, building detail, unit-type detail.
- Server-side clustering above zoom threshold (`ST_SnapToGrid` grid-snap).
- Redis viewport cache (quantized bbox + zoom key, 60s TTL).
- Every response carries `verified_days_ago` per listing.
- Basic abuse guards: rate limiting on anonymous endpoints, max bbox area.

**Gate:**
- Viewport query over the pilot-estate dataset: p95 < 150ms warm, < 400ms cold (measured, on staging hardware).
- Panning across the whole pilot estate never returns > MAX_MARKERS raw points — clusters kick in.
- Stale/hidden listings provably absent from all consumer responses.

---

## Phase 4 — Consumer app (Flutter)

**Build:**
- Open → location permission → fused high-accuracy location → camera animates to user pin (the Bolt moment).
- Markers + clusters rendered from viewport API; smooth pan/zoom refetch (debounced).
- Search mode: Places Autocomplete (KE-restricted, session tokens) → fly to location → same flow.
- Tap marker → bottom sheet: photos, unit types + prices, **"Verified X days ago"** badge, directions deep-link to Google Maps.
- Contact/interest action stubbed behind auth → creates `Lead` (generic — business model decided later plugs in here).
- Filters: price range, unit type.

**Gate:**
- Cold open to "I can see vacant houses around me" < 5 seconds on a mid-range Android over 4G.
- 5 non-technical testers (not devs — actual house hunters) each find a real unit they'd call about, unassisted.
- Map feel check: pan/zoom smooth on a Tecno/Infinix-class device, not just your test phone.

---

## Phase 5 — Website (Next.js)

**Build:**
- Map experience (Maps JS API) mirroring the app.
- SEO surfaces: server-rendered estate pages (`/vacant-houses/kilimani`), building pages, structured data.
- Permanent geocode caching; autocomplete discipline per CLAUDE.md.

**Gate:**
- Estate pages indexed and rendering full content with JS disabled (SSR verified).
- Lighthouse ≥ 90 performance on estate pages.
- Same "5 strangers find a house" test passes on web.

---

## Phase 6 — Back office + data QA

**Build:**
- Admin (Next.js or Django admin hardened): agent management, capture review queue, photo moderation, duplicate-building detection (spatial proximity + name similarity), staleness dashboard per estate.
- Agent leaderboard / capture stats (feeds future agent-payment model).
- Manual merge tool for duplicate buildings.

**Gate:**
- A flagged duplicate can be merged without breaking snapshots or photos.
- Staleness dashboard correctly identifies the estate's oldest verifications.
- An estate's data health is assessable in < 1 minute.

---

## Phase 7 — Pilot hardening & scale-out readiness

**Build:**
- Deploy prod on Hetzner behind Caddy; backups (pg_dump + object storage sync) into existing `/srv` structure.
- Monitoring: uptime checks, slow-query logging, Sentry (or self-hosted GlitchTip).
- Recruit + onboard 1–2 real field agents with the app; expand to a second estate.
- Load test viewport endpoint at 50× pilot traffic.

**Gate:**
- Two estates live with < 10% listings older than 7 days verification age.
- A non-founder agent captures buildings successfully with zero hand-holding after a 15-minute onboarding.
- Restore-from-backup rehearsed once, successfully.

---

## Explicitly deferred (do not build yet)

- Business model mechanics (lead fees / listing fees / featured placement) — `Lead` model is the hook; decide after pilot demand data exists.
- Caretaker self-service portal (let them update their own vacancies) — powerful, but only after trust + QA tooling exists.
- iOS release (Android-first; Kenya market reality).
- In-app chat, payments, booking — not MVP.
- Rust viewport service — only if Phase 7 load test fails on tuned Django.