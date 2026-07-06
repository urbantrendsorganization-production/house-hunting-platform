# agent_app — Field Agent App (Flutter, offline-first)

Placeholder. Built in **Phase 2**.

Field agents capture buildings, unit types, photos and vacancy counts. All
capture writes to a local Drift db first; a sync worker drains the queue to the
idempotent API sync endpoint. UI must never block on network.

See `PLAN.md` Phase 2 and `CLAUDE.md` → "Agent app rules".
