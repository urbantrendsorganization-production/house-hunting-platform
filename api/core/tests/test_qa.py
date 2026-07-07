"""Phase 6 gate: the staleness dashboard identifies the oldest verifications."""

from datetime import timedelta

import pytest
from django.contrib.gis.geos import Point
from django.utils import timezone
from django.utils.text import slugify

from core.models import Building, Estate, UnitType
from core.services import qa
from core.services.freshness import append_vacancy_snapshot

pytestmark = pytest.mark.django_db


def _building(estate, agent, lat=-1.2185):
    return Building.objects.create(
        location=Point(36.8964, lat, srid=4326), estate=estate, created_by_agent=agent
    )


def _verify(building, agent, days_ago, count=2):
    unit = UnitType.objects.create(building=building, kind="1BR", rent_kes=15000)
    append_vacancy_snapshot(
        unit_type=unit,
        vacant_count=count,
        verified_at=timezone.now() - timedelta(days=days_ago),
        verified_by=agent,
    )


def test_dashboard_ranks_stalest_estate_first(agent):
    fresh = Estate.objects.create(
        name="Fresh", slug=slugify("Fresh"), centroid=Point(36.9, -1.2, srid=4326)
    )
    stale = Estate.objects.create(
        name="Stale", slug=slugify("Stale"), centroid=Point(36.8, -1.3, srid=4326)
    )
    _verify(_building(fresh, agent), agent, days_ago=1)
    _verify(_building(stale, agent), agent, days_ago=45)

    dashboard = qa.estate_staleness_dashboard()
    slugs = [row["slug"] for row in dashboard]

    assert slugs[0] == "stale"  # oldest verification surfaces first
    stale_row = next(r for r in dashboard if r["slug"] == "stale")
    assert stale_row["oldest_verified_days_ago"] >= 45
    assert stale_row["hidden_count"] == 1  # >30d → hidden by freshness


def test_stalest_buildings_lists_never_verified_first(estate, agent):
    _verify(_building(estate, agent), agent, days_ago=5)
    never = _building(estate, agent)  # captured, never verified

    stalest = qa.stalest_buildings(estate_slug=estate.slug)
    assert stalest[0].id == never.id


def test_agent_leaderboard_counts_captures(estate, agent):
    b = _building(estate, agent)
    _verify(b, agent, days_ago=1)
    _building(estate, agent)  # a second capture, no verification

    board = qa.agent_leaderboard()
    row = next(r for r in board if r["id"] == agent.id)
    assert row["buildings_captured"] == 2
    assert row["verifications"] == 1


def test_review_queue_and_signoff(estate, agent):
    b = _building(estate, agent)
    assert [x.id for x in qa.review_queue()] == [b.id]

    qa.mark_reviewed(b, reviewed_by=None)
    b.refresh_from_db()
    assert b.reviewed_at is not None
    assert qa.review_queue() == []
