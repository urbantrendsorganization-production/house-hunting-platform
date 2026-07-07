# consumer_app — Consumer App (Flutter)

Map-first discovery: open → locate → see vacant houses around you → tap →
details → contact/directions. Google Maps SDK (free native loads; best Kenya
data). PLAN Phase 4.

## Architecture

```
lib/src/
├── data/
│   ├── api_client.dart          # viewport / near-me / building detail (anon)
│   ├── models.dart              # markers, clusters, building detail
│   ├── location_service.dart    # fused high-accuracy "near me"
│   └── places_service.dart      # KE-restricted autocomplete, session tokens
├── providers.dart               # Riverpod + freshness/quality filters
└── ui/
    ├── map_screen.dart          # GoogleMap, debounced viewport refetch, list fallback
    ├── building_sheet.dart      # verified badge, units, directions, interest
    ├── filter_sheet.dart        # freshness filters
    └── search_bar.dart          # debounced Places search
```

- **The Bolt moment:** open → location permission → camera flies to the user →
  vacant buildings load from the viewport API.
- **Server-side clusters:** below the zoom threshold the API returns clusters
  (never hundreds of raw pins); tapping a cluster zooms in. Pans are debounced
  before refetch (CLAUDE.md — never query on every pan).
- **Freshness everywhere:** every listing shows a "Verified X days ago" badge;
  demoted (stale-but-visible) listings are marked, and can be filtered out.
- **Directions** deep-link to Google Maps; **"I'm interested"** is the lead hook
  (endpoint intentionally deferred per PLAN — stubbed locally for the pilot).
- **Degrades gracefully:** a list view works without a Maps key or on a low-end
  device.

> **Price / unit-type filters** need a denormalized `min_rent` / `unit_kinds` on
> the viewport API — a small backend follow-up. Current filters use what the
> marker payload carries (verification age, demoted flag). See `MapFilters`.

## Run

```bash
flutter pub get
# Native map tiles need a key in android/local.properties:
#   MAPS_API_KEY=AIza...
flutter run \
  --dart-define=API_BASE_URL=http://10.0.2.2:8000 \
  --dart-define=PLACES_API_KEY=AIza...     # optional, enables search
```

## Test

```bash
flutter test        # viewport parsing (both modes) + freshness filter logic
```
