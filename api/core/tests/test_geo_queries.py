"""Phase 0 gate: a `dwithin` query returns correct, distance-sorted results.

Runs against real PostGIS (not mocks) per CLAUDE.md test policy.
"""

import pytest
from django.contrib.gis.db.models.functions import Distance
from django.contrib.gis.geos import Point
from django.contrib.gis.measure import D
from django.utils.text import slugify

from core.models import Building, Estate

pytestmark = pytest.mark.django_db


# Nairobi CBD-ish reference point the user is standing at.
USER_POINT = Point(36.8964, -1.2185, srid=4326)


def _estate():
    return Estate.objects.create(
        name="TestEstate",
        slug=slugify("TestEstate"),
        centroid=USER_POINT,
    )


def test_dwithin_returns_only_nearby_and_sorted_by_distance():
    estate = _estate()

    # ~0km (same point), ~0.9km east, ~3.5km away.
    Building.objects.create(name="Near", location=Point(36.8964, -1.2185, srid=4326), estate=estate)
    Building.objects.create(name="Mid", location=Point(36.9045, -1.2185, srid=4326), estate=estate)
    far = Building.objects.create(
        name="Far", location=Point(36.9280, -1.2185, srid=4326), estate=estate
    )

    within_2km = list(
        Building.objects.filter(location__dwithin=(USER_POINT, D(km=2)))
        .annotate(dist=Distance("location", USER_POINT))
        .order_by("dist")
    )

    # `far` (~3.5km) must be excluded; the two nearby returned nearest-first.
    assert [b.name for b in within_2km] == ["Near", "Mid"]
    assert far not in within_2km
    assert within_2km[0].dist <= within_2km[1].dist


def test_has_active_vacancy_flag_filters_viewport():
    estate = _estate()
    vacant = Building.objects.create(
        name="Vacant",
        location=USER_POINT,
        estate=estate,
        has_active_vacancy=True,
    )
    Building.objects.create(
        name="Full",
        location=USER_POINT,
        estate=estate,
        has_active_vacancy=False,
    )

    results = Building.objects.filter(
        location__dwithin=(USER_POINT, D(km=1)),
        has_active_vacancy=True,
    )
    assert list(results) == [vacant]
