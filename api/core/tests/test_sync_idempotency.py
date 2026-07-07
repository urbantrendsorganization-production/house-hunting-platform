"""Phase 1 gate: replaying the same sync batch N times = identical DB state."""

import uuid

import pytest

from core.models import Building, UnitType, VacancySnapshot
from core.services.sync import apply_sync_batch

pytestmark = pytest.mark.django_db


def _batch(building_uuid, unit_uuid, snap_uuid):
    return [
        {
            "type": "building",
            "client_uuid": building_uuid,
            "data": {
                "estate": "roysambu",
                "lat": -1.2185,
                "lng": 36.8964,
                "name": "Lumumba Court",
                "caretaker_phone": "0712000111",
            },
        },
        {
            "type": "unit_type",
            "client_uuid": unit_uuid,
            "data": {"building": building_uuid, "kind": "1BR", "rent_kes": 15000},
        },
        {
            "type": "vacancy_snapshot",
            "client_uuid": snap_uuid,
            "data": {"unit_type": unit_uuid, "vacant_count": 2, "source": "AGENT_VISIT"},
        },
    ]


def test_replaying_batch_five_times_is_idempotent(estate, agent):
    building_uuid = str(uuid.uuid4())
    unit_uuid = str(uuid.uuid4())
    snap_uuid = str(uuid.uuid4())
    batch = _batch(building_uuid, unit_uuid, snap_uuid)

    for _ in range(5):
        results = apply_sync_batch(agent, batch)
        assert all(r["status"] == "synced" for r in results), results

    # Exactly one of each — no duplicates from the retries.
    assert Building.objects.count() == 1
    assert UnitType.objects.count() == 1
    assert VacancySnapshot.objects.count() == 1

    building = Building.objects.get()
    assert building.name == "Lumumba Court"
    assert building.caretaker_phone == "+254712000111"  # normalized at boundary
    assert building.has_active_vacancy is True  # fresh + vacant


def test_unknown_record_type_fails_alone(estate, agent):
    building_uuid = str(uuid.uuid4())
    batch = [
        {
            "type": "building",
            "client_uuid": building_uuid,
            "data": {"estate": "roysambu", "lat": -1.2, "lng": 36.8},
        },
        {"type": "bogus", "client_uuid": str(uuid.uuid4()), "data": {}},
    ]
    results = apply_sync_batch(agent, batch)
    assert results[0]["status"] == "synced"
    assert results[1]["status"] == "failed"
    # The good record still landed.
    assert Building.objects.count() == 1
