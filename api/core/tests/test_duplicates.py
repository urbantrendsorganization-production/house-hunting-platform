"""Phase 6 gate: a flagged duplicate merges without breaking snapshots/photos."""

from datetime import timedelta

import pytest
from django.contrib.gis.geos import Point
from django.utils import timezone

from core.models import (
    Building,
    BuildingMergeLog,
    BuildingPhoto,
    Lead,
    UnitType,
    VacancySnapshot,
)
from core.services import duplicates

pytestmark = pytest.mark.django_db


def _building(estate, agent, *, name="", lng=36.8964, lat=-1.2185):
    return Building.objects.create(
        name=name,
        location=Point(lng, lat, srid=4326),
        estate=estate,
        created_by_agent=agent,
    )


def _snap(unit, count, days_ago, agent):
    return VacancySnapshot.objects.create(
        unit_type=unit,
        vacant_count=count,
        verified_at=timezone.now() - timedelta(days=days_ago),
        verified_by=agent,
    )


def test_finds_nearby_similar_named_pair(estate, agent):
    _building(estate, agent, name="Green Court", lng=36.89640, lat=-1.21850)
    # ~11 m east, near-identical name → flagged.
    _building(estate, agent, name="Green Courts", lng=36.89650, lat=-1.21850)
    # Same gate but a clearly different name → proximity alone must NOT flag it.
    _building(estate, agent, name="Riverside Towers", lng=36.89641, lat=-1.21850)

    candidates = duplicates.find_duplicate_candidates(proximity_m=30)

    assert len(candidates) == 1
    pair = candidates[0]
    names = {side["name"] for side in pair["buildings"]}
    assert names == {"Green Court", "Green Courts"}
    assert pair["distance_m"] <= 30


def test_far_apart_not_flagged(estate, agent):
    _building(estate, agent, name="Green Court", lng=36.8964, lat=-1.2185)
    # ~1 km away — same name, but not the same building.
    _building(estate, agent, name="Green Court", lng=36.9064, lat=-1.2185)

    assert duplicates.find_duplicate_candidates(proximity_m=30) == []


def test_merge_preserves_snapshots_photos_and_leads(estate, agent):
    target = _building(estate, agent, name="Green Court")
    source = _building(estate, agent, name="Green Courts")

    # target has a 1BR; source has a 1BR (folds) and a 2BR (re-parents).
    t_1br = UnitType.objects.create(building=target, kind="1BR", rent_kes=15000)
    s_1br = UnitType.objects.create(building=source, kind="1BR", rent_kes=15500)
    s_2br = UnitType.objects.create(building=source, kind="2BR", rent_kes=25000)

    _snap(t_1br, 1, 2, agent)
    _snap(s_1br, 2, 1, agent)  # folds into t_1br
    _snap(s_2br, 3, 1, agent)  # rides along with the re-parented 2BR

    BuildingPhoto.objects.create(
        building=source, unit_type=s_1br, storage_key="a.jpg", confirmed=True
    )
    BuildingPhoto.objects.create(building=source, storage_key="b.jpg", confirmed=True)
    Lead.objects.create(building=source, unit_type=s_1br, contact_phone="+254712345678")

    snaps_before = VacancySnapshot.objects.count()
    photos_before = BuildingPhoto.objects.count()
    leads_before = Lead.objects.count()

    log = duplicates.merge_buildings(target=target, source=source, merged_by=None)

    # Nothing lost.
    assert VacancySnapshot.objects.count() == snaps_before
    assert BuildingPhoto.objects.count() == photos_before
    assert Lead.objects.count() == leads_before

    # Source gone; everything now hangs off the target.
    assert not Building.objects.filter(id=source.id).exists()
    assert VacancySnapshot.objects.filter(unit_type__building=target).count() == snaps_before
    assert BuildingPhoto.objects.filter(building=target).count() == photos_before
    assert Lead.objects.filter(building=target).count() == leads_before

    # 1BR folded (one surviving 1BR with both snapshots); 2BR re-parented.
    kinds = sorted(target.unit_types.values_list("kind", flat=True))
    assert kinds == ["1BR", "2BR"]
    surviving_1br = target.unit_types.get(kind="1BR")
    assert surviving_1br.snapshots.count() == 2

    # Audit trail recorded.
    assert BuildingMergeLog.objects.filter(id=log.id).exists()
    assert log.summary["snapshots"] == 2

    # Freshness recomputed on the survivor.
    target.refresh_from_db()
    assert target.has_active_vacancy is True


def test_self_merge_rejected(estate, agent):
    b = _building(estate, agent, name="Green Court")
    with pytest.raises(duplicates.MergeError):
        duplicates.merge_buildings(target=b, source=b)
