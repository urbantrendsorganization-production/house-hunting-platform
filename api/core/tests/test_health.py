import pytest
from rest_framework.test import APIClient

pytestmark = pytest.mark.django_db


def test_health_endpoint_reports_ok_and_postgis():
    client = APIClient()
    resp = client.get("/api/v1/health/")
    assert resp.status_code == 200
    body = resp.json()
    assert body["status"] == "ok"
    assert body["db"] is True
    assert body["postgis"]  # PostGIS lib version string present
