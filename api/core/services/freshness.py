"""The freshness engine.

Current vacancy = the latest `VacancySnapshot` per unit type. This module owns
the denormalized flags on `Building` that every consumer surface reads:

  * has_active_vacancy — any unit type whose latest snapshot is vacant AND
    verified within VACANCY_HIDE_DAYS. Drives viewport/radius filtering.
  * is_demoted — freshest snapshot older than VACANCY_DEMOTE_DAYS (ranked down
    but still visible).
  * latest_verified_at — age source for the "verified X days ago" badge.

Recomputed on snapshot insert and by the hourly Celery sweep. Never join through
snapshots in a query hot path — read these flags instead.
"""

from datetime import timedelta

from django.conf import settings
from django.db import transaction
from django.utils import timezone

from core.models import Building, UnitType, VacancySnapshot


def latest_snapshot_for(unit_type: UnitType) -> VacancySnapshot | None:
    return unit_type.snapshots.order_by("-verified_at").first()


def recompute_building_freshness(building: Building, *, now=None) -> Building:
    """Recompute the denormalized freshness flags for one building.

    Idempotent and side-effect-free beyond the single UPDATE. Safe to call from
    the snapshot-insert path and the sweep.
    """
    now = now or timezone.now()
    hide_cutoff = now - timedelta(days=settings.VACANCY_HIDE_DAYS)
    demote_cutoff = now - timedelta(days=settings.VACANCY_DEMOTE_DAYS)

    has_active = False
    latest_verified_at = None

    for unit_type in building.unit_types.all():
        snap = latest_snapshot_for(unit_type)
        if snap is None:
            continue
        if latest_verified_at is None or snap.verified_at > latest_verified_at:
            latest_verified_at = snap.verified_at
        if snap.vacant_count > 0 and snap.verified_at >= hide_cutoff:
            has_active = True

    is_demoted = latest_verified_at is not None and latest_verified_at < demote_cutoff

    building.has_active_vacancy = has_active
    building.is_demoted = is_demoted
    building.latest_verified_at = latest_verified_at
    building.save(
        update_fields=["has_active_vacancy", "is_demoted", "latest_verified_at", "updated_at"]
    )
    return building


@transaction.atomic
def append_vacancy_snapshot(
    *,
    unit_type: UnitType,
    vacant_count: int,
    verified_at=None,
    verified_by=None,
    source: str = VacancySnapshot.Source.AGENT_VISIT,
    client_uuid=None,
) -> VacancySnapshot:
    """Append-only snapshot insert that also refreshes the building flags.

    Idempotent on client_uuid: replaying the same logical snapshot returns the
    existing row instead of appending a duplicate.
    """
    verified_at = verified_at or timezone.now()

    defaults = {
        "vacant_count": vacant_count,
        "verified_at": verified_at,
        "verified_by": verified_by,
        "source": source,
    }
    if client_uuid is not None:
        snapshot, _created = VacancySnapshot.objects.get_or_create(
            client_uuid=client_uuid, unit_type=unit_type, defaults=defaults
        )
    else:
        snapshot = VacancySnapshot.objects.create(unit_type=unit_type, **defaults)

    # Freshness is always relative to wall-clock now, not the snapshot's
    # verified_at (a backfilled old snapshot should read as demoted immediately).
    recompute_building_freshness(unit_type.building)
    return snapshot
