"""Celery tasks: the hourly staleness sweep and media post-processing."""

from celery import shared_task

from core.models import Building, BuildingPhoto
from core.services.freshness import recompute_building_freshness


@shared_task(name="core.sweep_staleness")
def sweep_staleness() -> int:
    """Recompute freshness flags across all buildings.

    Enforces the demote (>14d) / hide (>30d) rules on a schedule so listings rot
    even when no new snapshot arrives. Runs hourly (see keja/celery.py beat).
    Returns the number of buildings swept.
    """
    count = 0
    qs = Building.objects.prefetch_related("unit_types__snapshots")
    for building in qs.iterator(chunk_size=500):
        recompute_building_freshness(building)
        count += 1
    return count


@shared_task(name="core.generate_thumbnail")
def generate_thumbnail(photo_id: int) -> None:
    """Generate a thumbnail for a confirmed photo.

    Stub for Phase 1 — real image processing (pull from object storage, resize,
    push thumbnail_key) lands with the media pipeline. Kept as a task so the
    presigned-confirm flow can enqueue it now.
    """
    try:
        BuildingPhoto.objects.get(pk=photo_id, confirmed=True)
    except BuildingPhoto.DoesNotExist:
        return
