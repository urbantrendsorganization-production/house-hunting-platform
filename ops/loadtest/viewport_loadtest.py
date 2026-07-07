#!/usr/bin/env python3
"""Viewport load test (Phase 7) — stdlib only, no install needed.

Hammers /api/v1/map/viewport with concurrent clients over a randomised set of
bounding boxes (a realistic mix of cache hits and misses) and reports latency
percentiles, throughput and error rate. This is the endpoint the whole product
rides on, so it is the one we load test.

    python ops/loadtest/viewport_loadtest.py \
        --base-url http://localhost:8000 --concurrency 50 --requests 2000

Point --base-url at staging/prod to validate the "50x pilot traffic" gate.
"""

import argparse
import random
import statistics
import time
import urllib.error
import urllib.request
from concurrent.futures import ThreadPoolExecutor
from urllib.parse import urlencode

# Nairobi-ish bounding boxes to pan across (w, s, e, n). Kept small so they pass
# the server's max-bbox-area cap; zoom varies to hit both marker + cluster paths.
CENTER_LNG, CENTER_LAT = 36.8964, -1.2185


def _random_viewport() -> dict:
    # Jitter the center so keys spread across the Redis viewport cache.
    dlng = random.uniform(-0.03, 0.03)
    dlat = random.uniform(-0.03, 0.03)
    half = random.choice([0.01, 0.02, 0.04])
    w, e = CENTER_LNG + dlng - half, CENTER_LNG + dlng + half
    s, n = CENTER_LAT + dlat - half, CENTER_LAT + dlat + half
    zoom = random.choice([11, 12, 13, 14, 15, 16])
    return {"w": w, "s": s, "e": e, "n": n, "zoom": zoom}


def _one_request(base_url: str, timeout: float) -> tuple[float, int]:
    url = f"{base_url}/api/v1/map/viewport/?" + urlencode(_random_viewport())
    start = time.perf_counter()
    try:
        with urllib.request.urlopen(url, timeout=timeout) as resp:
            resp.read()
            code = resp.getcode()
    except urllib.error.HTTPError as exc:
        code = exc.code
    except Exception:
        code = 0  # connection error / timeout
    return (time.perf_counter() - start) * 1000, code


def _pct(values: list[float], p: float) -> float:
    if not values:
        return 0.0
    k = max(0, min(len(values) - 1, int(round(p / 100 * (len(values) - 1)))))
    return sorted(values)[k]


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--base-url", default="http://localhost:8000")
    ap.add_argument("--concurrency", type=int, default=50)
    ap.add_argument("--requests", type=int, default=2000)
    ap.add_argument("--timeout", type=float, default=10.0)
    args = ap.parse_args()

    print(
        f"load test {args.base_url} — {args.requests} requests, "
        f"{args.concurrency} concurrent clients\n"
    )

    latencies: list[float] = []
    codes: list[int] = []
    wall_start = time.perf_counter()
    with ThreadPoolExecutor(max_workers=args.concurrency) as pool:
        futures = [
            pool.submit(_one_request, args.base_url, args.timeout)
            for _ in range(args.requests)
        ]
        for fut in futures:
            ms, code = fut.result()
            latencies.append(ms)
            codes.append(code)
    wall = time.perf_counter() - wall_start

    ok = sum(1 for c in codes if 200 <= c < 300)
    throttled = sum(1 for c in codes if c == 429)  # rate limit working, not a fault
    server_err = sum(1 for c in codes if c >= 500 or c == 0)
    rps = len(codes) / wall if wall else 0.0

    print(f"  throughput : {rps:8.1f} req/s over {wall:.1f}s")
    print(f"  2xx ok     : {ok}/{len(codes)}")
    print(f"  429 throttled : {throttled}   (anon rate limit — expected under burst)")
    print(f"  5xx/conn err  : {server_err}")
    print(f"  latency ms : p50={_pct(latencies, 50):.0f}  "
          f"p95={_pct(latencies, 95):.0f}  p99={_pct(latencies, 99):.0f}  "
          f"max={max(latencies):.0f}")
    if latencies:
        print(f"  mean ms    : {statistics.mean(latencies):.0f}")

    # Only *server* errors fail the run; 429s mean the throttle is doing its job.
    return 1 if server_err > len(codes) * 0.01 else 0


if __name__ == "__main__":
    raise SystemExit(main())
