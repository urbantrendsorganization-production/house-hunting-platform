// Viewport load test for k6 (Phase 7) — the "50x pilot traffic" gate.
//
//   k6 run -e BASE_URL=https://api.keja.example ops/loadtest/viewport.k6.js
//
// Ramps to 50 virtual users, pans random bounding boxes, and fails the run if
// p95 latency or the error rate blow past the thresholds.
import http from "k6/http";
import { check, sleep } from "k6";

const BASE_URL = __ENV.BASE_URL || "http://localhost:8000";
const CENTER = { lng: 36.8964, lat: -1.2185 };

export const options = {
  stages: [
    { duration: "30s", target: 50 }, // ramp up
    { duration: "2m", target: 50 }, // hold at ~50x pilot load
    { duration: "30s", target: 0 }, // ramp down
  ],
  thresholds: {
    http_req_failed: ["rate<0.01"], // <1% errors
    http_req_duration: ["p(95)<400"], // p95 under 400ms
  },
};

function randomViewport() {
  const dlng = (Math.random() - 0.5) * 0.06;
  const dlat = (Math.random() - 0.5) * 0.06;
  const half = [0.01, 0.02, 0.04][Math.floor(Math.random() * 3)];
  const zoom = 11 + Math.floor(Math.random() * 6);
  return {
    w: CENTER.lng + dlng - half,
    s: CENTER.lat + dlat - half,
    e: CENTER.lng + dlng + half,
    n: CENTER.lat + dlat + half,
    zoom,
  };
}

export default function () {
  const q = randomViewport();
  const url =
    `${BASE_URL}/api/v1/map/viewport/?w=${q.w}&s=${q.s}&e=${q.e}&n=${q.n}&zoom=${q.zoom}`;
  const res = http.get(url);
  check(res, { "status 200": (r) => r.status === 200 });
  sleep(Math.random() * 0.5);
}
