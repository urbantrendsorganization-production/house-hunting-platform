"""Phase 3 gate: consumer surfaces never leak stale/hidden listings; clusters
kick in when zoomed out; markers are capped; every listing carries verified age.
"""

import uuid

import pytest
from django.contrib.gis.geos import Point
from django.utils import timezone
from rest_framework.test import APIClient

from core.models import Building

pytestmark = pytest.mark.django_db


def _building(estate, *, lng, lat, active=True, verified_days=1, demoted=False):
    return Building.objects.create(
        id=uuid.uuid4(),
        location=Point(lng, lat, srid=4326),
        estate=estate,
        has_active_vacancy=active,
        is_demoted=demoted,
        latest_verified_at=timezone.now() - timezone.timedelta(days=verified_days),
    )


# A small bbox around Roysambu, zoomed in (markers mode).
BBOX = {"w": 36.88, "s": -1.23, "e": 36.91, "n": -1.20, "zoom": 16}


def test_viewport_returns_active_markers_with_verified_age(estate):
    _building(estate, lng=36.895, lat=-1.218, verified_days=3)
    client = APIClient()
    resp = client.get("/api/v1/map/viewport/", BBOX)
    assert resp.status_code == 200
    body = resp.json()
    assert body["mode"] == "markers"
    assert body["count"] == 1
    marker = body["markers"][0]
    assert marker["verified_days_ago"] == 3
    assert "lng" in marker and "lat" in marker


def test_hidden_buildings_absent_from_viewport(estate):
    _building(estate, lng=36.895, lat=-1.218, active=True)
    _building(estate, lng=36.896, lat=-1.219, active=False)  # stale/hidden
    client = APIClient()
    body = client.get("/api/v1/map/viewport/", BBOX).json()
    assert body["count"] == 1  # the hidden one is gone


def test_zoomed_out_returns_clusters(estate):
    # Many buildings, zoomed way out → clusters, not raw markers.
    for i in range(30):
        _building(estate, lng=36.88 + i * 0.001, lat=-1.22 + i * 0.0005)
    client = APIClient()
    body = client.get("/api/v1/map/viewport/", {**BBOX, "zoom": 11}).json()
    assert body["mode"] == "clusters"
    assert body["count"] == 30
    # Clustered into far fewer points than raw buildings.
    assert len(body["clusters"]) < 30


def test_oversized_bbox_rejected(estate):
    client = APIClient()
    resp = client.get("/api/v1/map/viewport/", {"w": 30, "s": -5, "e": 40, "n": 5, "zoom": 16})
    assert resp.status_code == 422


def test_near_me_is_distance_sorted_and_excludes_hidden(estate):
    _building(estate, lng=36.8964, lat=-1.2185, verified_days=1)  # ~0 m
    _building(estate, lng=36.9045, lat=-1.2185, verified_days=1)  # ~0.9 km
    _building(estate, lng=36.8964, lat=-1.2185, active=False)  # hidden, at origin
    client = APIClient()
    body = client.get(
        "/api/v1/map/near-me/", {"lng": 36.8964, "lat": -1.2185, "radius_km": 2}
    ).json()
    assert body["count"] == 2  # hidden excluded
    dists = [r["distance_m"] for r in body["results"]]
    assert dists == sorted(dists)


def test_building_detail_404_when_hidden(estate):
    hidden = _building(estate, lng=36.895, lat=-1.218, active=False)
    active = _building(estate, lng=36.896, lat=-1.219, active=True)
    client = APIClient()
    assert client.get(f"/api/v1/buildings/{hidden.id}/").status_code == 404
    assert client.get(f"/api/v1/buildings/{active.id}/").status_code == 200
