"""Phase 7: the slow-request logger flags only over-threshold requests."""

from django.http import HttpResponse
from django.test import RequestFactory

from core.middleware import SlowRequestLoggerMiddleware


def _mw(threshold_ms, sleep_ms=0):
    import time

    def get_response(request):
        if sleep_ms:
            time.sleep(sleep_ms / 1000)
        return HttpResponse("ok")

    mw = SlowRequestLoggerMiddleware(get_response)
    mw.threshold_ms = threshold_ms
    return mw


def test_fast_request_not_flagged():
    mw = _mw(threshold_ms=1000)
    resp = mw(RequestFactory().get("/api/v1/health/"))
    assert "X-Response-Time-ms" not in resp


def test_slow_request_flagged():
    # keja.slow has propagate=False (goes straight to console), so we attach our
    # own handler to capture the warning rather than relying on pytest's caplog.
    import logging

    records = []

    class _Capture(logging.Handler):
        def emit(self, record):
            records.append(record)

    handler = _Capture()
    logger = logging.getLogger("keja.slow")
    logger.addHandler(handler)
    try:
        mw = _mw(threshold_ms=5, sleep_ms=20)
        resp = mw(RequestFactory().get("/api/v1/map/viewport/"))
    finally:
        logger.removeHandler(handler)

    assert "X-Response-Time-ms" in resp
    assert any("slow request" in r.getMessage() for r in records)


def test_disabled_when_threshold_zero():
    mw = _mw(threshold_ms=0, sleep_ms=20)
    resp = mw(RequestFactory().get("/api/v1/health/"))
    assert "X-Response-Time-ms" not in resp
