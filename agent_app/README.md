# agent_app — Field Agent App (Flutter, offline-first)

Field agents capture buildings, unit types, photos and vacancy counts. **All
capture writes to a local Drift db first**; a sync worker drains the queue to the
idempotent API. The UI never blocks on the network (CLAUDE.md → "Agent app
rules", PLAN Phase 2).

## Architecture

```
lib/src/
├── data/
│   ├── local/database.dart      # Drift — the offline source of truth (queue)
│   ├── api/api_client.dart      # login / sync / photo presign+upload
│   ├── auth_repository.dart     # device-bound JWT + stable device_id
│   ├── capture_repository.dart  # all capture writes (client_uuid stamped)
│   ├── location_service.dart    # GPS with a ≤15m accuracy gate
│   └── photo_service.dart       # camera + client-side compression
├── sync/sync_service.dart       # drains the queue; idempotent; connectivity-driven
├── providers.dart               # Riverpod wiring
└── ui/                          # login, my-buildings, capture, re-verify
```

- **Offline-first:** every record is born `pending` and only becomes `synced`
  once the API confirms it, keyed by a client-generated `client_uuid` — the same
  idempotency key the server upserts on, so retries never duplicate.
- **GPS gate:** the "pin" button unlocks only at accuracy ≤ 15m; the accepted
  fix is frozen so later drift doesn't move the gate.
- **Sync ordering:** photos upload to object storage first (bytes never touch the
  API), then a dependency-ordered batch (building → unit type → snapshot → photo)
  is POSTed to `/agent/sync/`.
- **Re-verify loop:** open a building → set vacancy counts → save. Appends new
  snapshots and syncs (PLAN gate: < 30s in the field).

## Run

```bash
flutter pub get
dart run build_runner build          # generates database.g.dart (Drift)
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

`10.0.2.2` reaches the host's Django dev server from the Android emulator.

## Test

```bash
flutter test        # offline-queue + append-only re-verify logic (no device)
```
