"""Duplicate-building detection and merge (Phase 6 back office).

Two agents can pin the same block on separate visits — same gate, near-identical
name. This module finds those candidate pairs (spatial proximity + name
similarity) and merges one into the other **without ever losing a snapshot,
photo, or lead**. The append-only snapshot rule (CLAUDE.md) means a merge only
ever *re-parents* snapshots; it never rewrites their history.
"""

from difflib import SequenceMatcher

from django.conf import settings
from django.contrib.gis.db.models.functions import Distance
from django.contrib.gis.measure import D
from django.db import transaction

from core.models import Building, BuildingMergeLog, VacancySnapshot
from core.services.freshness import recompute_building_freshness

# Two pins closer than this, with similar-enough names, are flagged as one.
DEFAULT_PROXIMITY_M = getattr(settings, "DUP_PROXIMITY_M", 30.0)
DEFAULT_NAME_RATIO = getattr(settings, "DUP_NAME_RATIO", 0.6)


class MergeError(ValueError):
    """A merge that cannot be performed (e.g. a building into itself)."""


def _name_ratio(a: str, b: str) -> float:
    """Fuzzy name closeness in [0, 1].

    Two *unnamed* buildings at the same gate are very likely the same block, so
    they score a perfect match; a named vs. unnamed pair is left to proximity
    alone and scores 0 (the name signal is simply absent, not contradictory).
    """
    a = (a or "").strip().lower()
    b = (b or "").strip().lower()
    if not a and not b:
        return 1.0
    if not a or not b:
        return 0.0
    return SequenceMatcher(None, a, b).ratio()


def find_duplicate_candidates(
    *,
    estate_slug: str | None = None,
    proximity_m: float = DEFAULT_PROXIMITY_M,
    name_ratio: float = DEFAULT_NAME_RATIO,
    limit: int = 200,
) -> list[dict]:
    """Candidate duplicate pairs, closest first.

    Each building's near neighbours are found with a `dwithin` query (rides the
    GiST index); a pair qualifies when the name similarity clears `name_ratio`.
    Pairs are de-duplicated so (A, B) and (B, A) appear once.
    """
    qs = Building.objects.select_related("estate")
    if estate_slug:
        qs = qs.filter(estate__slug=estate_slug)

    pairs: list[dict] = []
    seen: set[tuple[str, str]] = set()

    for b in qs:
        neighbours = (
            Building.objects.filter(location__dwithin=(b.location, D(m=proximity_m)))
            .exclude(id=b.id)
            .select_related("estate")
            .annotate(dist=Distance("location", b.location))
        )
        if estate_slug:
            neighbours = neighbours.filter(estate__slug=estate_slug)

        for other in neighbours:
            key = tuple(sorted((str(b.id), str(other.id))))
            if key in seen:
                continue
            ratio = _name_ratio(b.name, other.name)
            if ratio < name_ratio:
                continue
            seen.add(key)
            pairs.append(
                {
                    "distance_m": round(other.dist.m, 1),
                    "name_ratio": round(ratio, 2),
                    "estate": b.estate.name,
                    "buildings": [_pair_side(b), _pair_side(other)],
                }
            )

    pairs.sort(key=lambda p: (p["distance_m"], -p["name_ratio"]))
    return pairs[:limit]


def _pair_side(b: Building) -> dict:
    return {
        "id": str(b.id),
        "name": b.name,
        "lng": b.location.x,
        "lat": b.location.y,
        "has_active_vacancy": b.has_active_vacancy,
        "latest_verified_at": b.latest_verified_at,
        "created_at": b.created_at,
    }


@transaction.atomic
def merge_buildings(*, target: Building, source: Building, merged_by=None) -> BuildingMergeLog:
    """Fold `source` into `target`, then delete `source`.

    Reparenting rules — nothing is ever dropped:
      * A source unit type whose kind is absent on the target is re-pointed to
        the target (its snapshots ride along, FK unchanged).
      * A source unit type whose kind already exists on the target is *folded*:
        its snapshots, photos and leads move to the surviving target unit type,
        then the now-empty source unit type is deleted.
      * Any remaining source photos / leads (building-level or on moved unit
        types) are re-pointed to the target.

    Returns the audit-log row. Raises MergeError for a self-merge.
    """
    if target.pk == source.pk:
        raise MergeError("cannot merge a building into itself")

    summary = {
        "unit_types": source.unit_types.count(),
        "snapshots": VacancySnapshot.objects.filter(unit_type__building=source).count(),
        "photos": source.photos.count(),
        "leads": source.leads.count(),
    }

    target_ut_by_kind = {ut.kind: ut for ut in target.unit_types.all()}

    for ut in source.unit_types.all():
        existing = target_ut_by_kind.get(ut.kind)
        if existing is None:
            # Kind not on target — re-parent the whole unit type (snapshots follow).
            ut.building = target
            ut.save(update_fields=["building"])
            target_ut_by_kind[ut.kind] = ut
            continue
        # Fold into the surviving unit type. Move children BEFORE deleting the
        # source unit type, or CASCADE would take its photos/snapshots with it.
        ut.snapshots.update(unit_type=existing)
        ut.photos.update(unit_type=existing, building=target)
        ut.leads.update(unit_type=existing, building=target)
        ut.delete()

    # Sweep up whatever is still hanging off the source (building-level photos,
    # leads with no unit type, photos on re-parented unit types).
    source.photos.update(building=target)
    source.leads.update(building=target)

    log = BuildingMergeLog.objects.create(
        target=target,
        source_id=source.id,
        source_name=source.name,
        merged_by=merged_by,
        summary=summary,
    )

    source.delete()
    recompute_building_freshness(target)
    return log
