"""Estate SEO endpoints backing the SSR website (Phase 5 support)."""

import uuid

import pytest
from django.contrib.gis.geos import Point
from django.utils import timezone
from rest_framework.test import APIClient

from core.models import Building, UnitType

pytestmark = pytest.mark.django_db


def _active_building(estate, rent):
    b = Building.objects.create(
        id=uuid.uuid4(),
        location=Point(36.895, -1.218, srid=4326),
        estate=estate,
        has_active_vacancy=True,
        latest_verified_at=timezone.now() - timezone.timedelta(days=2),
    )
    UnitType.objects.create(building=b, kind="1BR", rent_kes=rent)
    return b


def test_estate_list_reports_active_counts(estate):
    _active_building(estate, 15000)
    body = APIClient().get("/api/v1/estates/").json()
    row = next(r for r in body["results"] if r["slug"] == "roysambu")
    assert row["active_building_count"] == 1
    assert "lng" in row and "lat" in row


def test_estate_detail_lists_buildings_with_price_and_age(estate):
    _active_building(estate, 15000)
    _active_building(estate, 9000)
    body = APIClient().get("/api/v1/estates/roysambu/").json()
    assert body["estate"]["active_building_count"] == 2
    assert len(body["buildings"]) == 2
    first = body["buildings"][0]
    assert first["min_rent_kes"] in (9000, 15000)
    assert first["verified_days_ago"] == 2
    assert first["unit_kinds"] == ["1BR"]


def test_unknown_estate_404():
    assert APIClient().get("/api/v1/estates/nowhere/").status_code == 404
