# Shipping the Keja mobile apps to production

The apps are functionally complete but a **release** build needs three things
that are intentionally NOT in the repo (secrets / your infra). This is the exact
checklist to go from "works on the emulator" to "agents installing a signed app
that writes to the prod DB".

> Nothing here should be run with the `seed_demo` data or the local dev API.
> Prod is a separate, empty database behind HTTPS.

## 0. Prerequisite: the prod API must be live first
Confirm the Django API is deployed (Phase 7 `ops/compose/docker-compose.prod.yml`
+ Caddy) and reachable over HTTPS at your real domain, e.g.:

```bash
curl -fsS https://api.keja.urbantrends.dev/api/v1/health/    # must return 200
```

If that fails, the apps have nothing to talk to — stop and finish the deploy.

## 1. Create an upload keystore (once per app, keep FOREVER)
```bash
keytool -genkey -v -keystore ~/keja-consumer-upload.jks -keyalg RSA \
        -keysize 2048 -validity 10000 -alias keja
keytool -genkey -v -keystore ~/keja-agent-upload.jks    -keyalg RSA \
        -keysize 2048 -validity 10000 -alias keja-agent
```
Back the `.jks` files up somewhere safe. **Lose them and you can never update the
app.** Then in each app copy `android/key.properties.example` →
`android/key.properties` and fill in the real values. These files are git-ignored.

## 2. Consumer app needs a Google Maps SDK key
Create an Android-restricted Maps SDK key in Google Cloud (billing enabled),
restricted to the app package `com.urbantrends.consumer_app` + your release
SHA-1 (`keytool -list -v -keystore ~/keja-consumer-upload.jks`). Put it in
`consumer_app/android/local.properties`:
```
MAPS_API_KEY=AIza...
```
Without it the map tiles are blank and the app uses the list fallback.

## 3. Build the signed releases, POINTED AT PROD
The API base URL is a compile-time define. If you forget it, the app defaults to
`http://10.0.2.2:8000` (emulator localhost) and will reach nothing in the field.

```bash
# Consumer (Play Store bundle)
cd consumer_app
flutter build appbundle --release \
  --dart-define=API_BASE_URL=https://api.keja.urbantrends.dev \
  --dart-define=PLACES_API_KEY=AIza...        # optional, enables search

# Agent (distribute the APK directly to field agents' devices)
cd ../agent_app
flutter build apk --release \
  --dart-define=API_BASE_URL=https://api.keja.urbantrends.dev
```
The build auto-signs with your keystore because `key.properties` now exists.

## 4. Provision REAL agents in prod (not the Demo Agent)
The only agent that exists is `seed_demo`'s Demo Agent, in your LOCAL db. Create
real ones against the prod DB (phone in E.164). Device binds on first login:
```bash
# on the prod host
docker compose -f ops/compose/docker-compose.prod.yml exec api \
  python manage.py shell -c "from core.models import Agent; \
  Agent.objects.create(name='Jane Wanjiru', phone='+2547XXXXXXXX')"
```
(Or add a small management command / admin flow for the ops team.)

## 5. Smoke test before handing out
Install the signed agent APK on ONE real phone, log in as a real agent, capture
one building at an actual gate, confirm it syncs, and confirm it appears in the
consumer app. Only then distribute to the marketing/field team.

## What is deliberately NOT automated here
Keystores, the Maps key, the domain, and the prod deploy all require your
credentials and infrastructure access. Everything in code (signing wiring,
cleartext scoped to debug only, prod URL via define) is already done.
