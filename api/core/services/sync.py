"""Idempotent offline-sync ingestion.

The agent app queues capture records offline, each stamped with a
client-generated `client_uuid`, and drains the queue when online. The network is
unreliable, so the same batch may arrive several times — duplicates are a bug in
*our* design, not the agent's problem (CLAUDE.md). Every writer here upserts on
`client_uuid`, so replaying a batch N times converges to identical DB state.

Batch shape::

    {"records": [
        {"type": "building",         "client_uuid": "<uuid>", "data": {...}},
        {"type": "unit_type",        "client_uuid": "<uuid>", "data": {...}},
        {"type": "vacancy_snapshot", "client_uuid": "<uuid>", "data": {...}},
        {"type": "photo",            "client_uuid": "<uuid>", "data": {...}}
    ]}

References inside a batch are by client_uuid: a unit_type's ``data.building`` is
the building's client_uuid (which is also its server id), and a snapshot's
``data.unit_type`` is the unit_type's client_uuid.
"""

from django.contrib.gis.geos import Point
from django.db import transaction

from core.models import Agent, Building, BuildingPhoto, Estate, UnitType
from core.services.freshness import append_vacancy_snapshot
from core.services.phone import normalize_phone_or_blank


class SyncError(Exception):
    pass


def _apply_building(agent: Agent, client_uuid, data: dict):
    estate = Estate.objects.get(slug=data["estate"])
    location = Point(float(data["lng"]), float(data["lat"]), srid=4326)
    building, _ = Building.objects.update_or_create(
        id=client_uuid,
        defaults={
            "estate": estate,
            "location": location,
            "created_by_agent": agent,
            "name": data.get("name", ""),
            "floors": data.get("floors"),
            "water_notes": data.get("water_notes", ""),
            "power_notes": data.get("power_notes", ""),
            "security_notes": data.get("security_notes", ""),
            "parking": data.get("parking", False),
            "caretaker_name": data.get("caretaker_name", ""),
            "caretaker_phone": normalize_phone_or_blank(data.get("caretaker_phone", "")),
        },
    )
    return building.id


def _apply_unit_type(agent: Agent, client_uuid, data: dict):
    building = Building.objects.get(id=data["building"])
    unit_type, _ = UnitType.objects.update_or_create(
        client_uuid=client_uuid,
        defaults={
            "building": building,
            "kind": data["kind"],
            "rent_kes": data["rent_kes"],
            "deposit_kes": data.get("deposit_kes"),
            "amenities": data.get("amenities", {}),
        },
    )
    return unit_type.client_uuid


def _apply_vacancy_snapshot(agent: Agent, client_uuid, data: dict):
    unit_type = UnitType.objects.get(client_uuid=data["unit_type"])
    snapshot = append_vacancy_snapshot(
        unit_type=unit_type,
        vacant_count=data["vacant_count"],
        verified_at=data.get("verified_at"),
        verified_by=agent,
        source=data.get("source", "AGENT_VISIT"),
        client_uuid=client_uuid,
    )
    return snapshot.client_uuid


def _apply_photo(agent: Agent, client_uuid, data: dict):
    building = Building.objects.get(id=data["building"])
    unit_type = None
    if data.get("unit_type"):
        unit_type = UnitType.objects.get(client_uuid=data["unit_type"])
    photo, _ = BuildingPhoto.objects.update_or_create(
        client_uuid=client_uuid,
        defaults={
            "building": building,
            "unit_type": unit_type,
            "storage_key": data["storage_key"],
            "confirmed": data.get("confirmed", True),
        },
    )
    return photo.client_uuid


_HANDLERS = {
    "building": _apply_building,
    "unit_type": _apply_unit_type,
    "vacancy_snapshot": _apply_vacancy_snapshot,
    "photo": _apply_photo,
}


def apply_sync_batch(agent: Agent, records: list[dict]) -> list[dict]:
    """Apply a batch; return a per-record result the client uses to mark synced.

    Each record is committed in its own savepoint, so one malformed record fails
    alone instead of poisoning the whole batch. Records must be ordered so
    dependencies (building → unit_type → snapshot/photo) precede their referents.
    """
    results: list[dict] = []
    for rec in records:
        client_uuid = rec.get("client_uuid")
        rtype = rec.get("type")
        handler = _HANDLERS.get(rtype)
        if handler is None:
            results.append(
                {"client_uuid": client_uuid, "status": "failed", "error": f"unknown type {rtype!r}"}
            )
            continue
        try:
            with transaction.atomic():
                server_id = handler(agent, client_uuid, rec.get("data", {}))
            results.append(
                {"client_uuid": client_uuid, "status": "synced", "server_id": str(server_id)}
            )
        except Exception as exc:  # noqa: BLE001 - surfaced back to the client
            results.append({"client_uuid": client_uuid, "status": "failed", "error": str(exc)})
    return results
