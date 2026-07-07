"""Phase 1 gate: snapshot append flips the flag; the sweep demotes/hides stale."""

from datetime import timedelta

import pytest
from django.contrib.gis.geos import Point
from django.utils import timezone

from core.models import Building, UnitType, VacancySnapshot
from core.services.freshness import append_vacancy_snapshot
from core.tasks import sweep_staleness

pytestmark = pytest.mark.django_db


def _building(estate, agent):
    return Building.objects.create(
        location=Point(36.8964, -1.2185, srid=4326), estate=estate, created_by_agent=agent
    )


def test_snapshot_append_flips_active_flag(estate, agent):
    building = _building(estate, agent)
    unit = UnitType.objects.create(building=building, kind="1BR", rent_kes=15000)
    assert building.has_active_vacancy is False

    append_vacancy_snapshot(unit_type=unit, vacant_count=2, verified_by=agent)

    building.refresh_from_db()
    assert building.has_active_vacancy is True
    assert building.is_demoted is False
    assert building.latest_verified_at is not None


def test_zero_vacancy_snapshot_keeps_flag_off(estate, agent):
    building = _building(estate, agent)
    unit = UnitType.objects.create(building=building, kind="1BR", rent_kes=15000)

    append_vacancy_snapshot(unit_type=unit, vacant_count=0, verified_by=agent)

    building.refresh_from_db()
    assert building.has_active_vacancy is False


def test_sweep_demotes_stale_but_keeps_visible(estate, agent):
    building = _building(estate, agent)
    unit = UnitType.objects.create(building=building, kind="1BR", rent_kes=15000)
    now = timezone.now()

    # Latest snapshot 20 days ago: vacant, past the 14d demote line but within
    # the 30d hide line → visible-but-demoted.
    VacancySnapshot.objects.create(
        unit_type=unit, vacant_count=3, verified_at=now - timedelta(days=20), verified_by=agent
    )
    assert sweep_staleness() == 1
    building.refresh_from_db()
    assert building.has_active_vacancy is True
    assert building.is_demoted is True


def test_sweep_hides_expired(estate, agent):
    building = _building(estate, agent)
    unit = UnitType.objects.create(building=building, kind="1BR", rent_kes=15000)
    now = timezone.now()

    # Latest (only) snapshot 40 days ago → past the 30d hide line → hidden.
    VacancySnapshot.objects.create(
        unit_type=unit, vacant_count=3, verified_at=now - timedelta(days=40), verified_by=agent
    )
    assert sweep_staleness() == 1
    building.refresh_from_db()
    assert building.has_active_vacancy is False  # hidden from consumer surfaces
    assert building.is_demoted is True
