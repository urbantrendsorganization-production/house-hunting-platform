"""Lightweight request-timing middleware (Phase 7 monitoring).

Logs any request that takes longer than `SLOW_REQUEST_MS` to the `keja.slow`
logger — a cheap, always-on profiler for the viewport hot path without needing
an APM. Sentry (if configured) picks these up as breadcrumbs/traces separately.
"""

import logging
import time

from django.conf import settings

logger = logging.getLogger("keja.slow")


class SlowRequestLoggerMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response
        self.threshold_ms = getattr(settings, "SLOW_REQUEST_MS", 0)

    def __call__(self, request):
        if not self.threshold_ms:
            return self.get_response(request)

        start = time.perf_counter()
        response = self.get_response(request)
        elapsed_ms = (time.perf_counter() - start) * 1000

        if elapsed_ms >= self.threshold_ms:
            logger.warning(
                "slow request %.0fms %s %s -> %s",
                elapsed_ms,
                request.method,
                request.get_full_path(),
                response.status_code,
            )
            response["X-Response-Time-ms"] = f"{elapsed_ms:.0f}"
        return response
