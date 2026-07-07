# Load testing (Phase 7)

The viewport endpoint (`/api/v1/map/viewport`) is what the whole product rides
on, so it's the one we load test — the gate is "50x pilot traffic without falling
over."

## stdlib harness (no install)

```bash
python3 ops/loadtest/viewport_loadtest.py \
    --base-url http://localhost:8000 --concurrency 50 --requests 2000
```

Reports throughput and p50/p95/p99 latency, and buckets responses into 2xx /
429-throttled / 5xx. It exits non-zero only on **server** errors — 429s mean the
anonymous rate limit is doing its job.

## k6 (real ramped load)

```bash
k6 run -e BASE_URL=https://api.keja.example ops/loadtest/viewport.k6.js
```

Ramps to 50 VUs and fails the run if p95 ≥ 400ms or error rate ≥ 1%.

## Caveats

- **Raise the anon throttle for a true throughput test.** With the default
  `VIEWPORT_THROTTLE_RATE=120/min`, a burst is (correctly) throttled to 429s and
  you're measuring the rate limiter, not the endpoint. Set a high
  `VIEWPORT_THROTTLE_RATE` (or test from an allow-listed origin) when measuring
  capacity.
- **Measure against gunicorn, not the dev `runserver`.** The dev server is
  single-threaded; its latencies are not representative. Run the gate on staging
  hardware with the prod compose stack.
- The Redis viewport cache (60s TTL) means a realistic hit/miss mix matters — the
  harness jitters the bbox center so keys spread across the cache.
