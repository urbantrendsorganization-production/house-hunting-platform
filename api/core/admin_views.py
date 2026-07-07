"""Back-office / data-QA API (Phase 6) — staff-only.

Thin views over the `duplicates` and `qa` services: duplicate detection + merge,
per-estate staleness dashboards, the capture review queue, agent leaderboard,
and photo moderation. Auth is Django staff (session or basic); none of this is
anonymous-readable like the consumer map.
"""

from django.shortcuts import get_object_or_404
from rest_framework import status
from rest_framework.authentication import BasicAuthentication, SessionAuthentication
from rest_framework.decorators import (
    api_view,
    authentication_classes,
    permission_classes,
)
from rest_framework.response import Response

from core.models import Building, BuildingPhoto
from core.permissions import IsStaff
from core.services import duplicates, qa

# Applied to every endpoint in this module.
STAFF_AUTH = [SessionAuthentication, BasicAuthentication]


def _building_brief(b: Building) -> dict:
    days = None
    if b.latest_verified_at:
        from django.utils import timezone

        days = (timezone.now() - b.latest_verified_at).days
    return {
        "id": str(b.id),
        "name": b.name or "",
        "estate": b.estate.name,
        "lng": b.location.x,
        "lat": b.location.y,
        "has_active_vacancy": b.has_active_vacancy,
        "is_demoted": b.is_demoted,
        "latest_verified_at": b.latest_verified_at,
        "verified_days_ago": days,
        "reviewed_at": b.reviewed_at,
        "captured_by": b.created_by_agent.name if b.created_by_agent else None,
        "created_at": b.created_at,
    }


@api_view(["GET"])
@authentication_classes(STAFF_AUTH)
@permission_classes([IsStaff])
def duplicate_candidates(request):
    """Flagged duplicate pairs. Optional ?estate=<slug>&proximity_m=&name_ratio=."""
    p = request.query_params
    kwargs = {"estate_slug": p.get("estate")}
    try:
        if "proximity_m" in p:
            kwargs["proximity_m"] = float(p["proximity_m"])
        if "name_ratio" in p:
            kwargs["name_ratio"] = float(p["name_ratio"])
    except ValueError:
        return Response({"detail": "proximity_m and name_ratio must be numbers"}, status=400)

    candidates = duplicates.find_duplicate_candidates(**kwargs)
    return Response({"count": len(candidates), "candidates": candidates})


@api_view(["POST"])
@authentication_classes(STAFF_AUTH)
@permission_classes([IsStaff])
def merge_buildings(request):
    """Merge `source` into `target` (both building UUIDs). Snapshots/photos/leads
    are preserved; `source` is deleted.
    """
    target_id = request.data.get("target")
    source_id = request.data.get("source")
    if not (target_id and source_id):
        return Response({"detail": "target and source are required"}, status=400)

    target = get_object_or_404(Building, id=target_id)
    source = get_object_or_404(Building, id=source_id)
    try:
        log = duplicates.merge_buildings(target=target, source=source, merged_by=request.user)
    except duplicates.MergeError as exc:
        return Response({"detail": str(exc)}, status=status.HTTP_400_BAD_REQUEST)

    return Response(
        {
            "merged": True,
            "target": str(target.id),
            "absorbed": str(log.source_id),
            "summary": log.summary,
        }
    )


@api_view(["GET"])
@authentication_classes(STAFF_AUTH)
@permission_classes([IsStaff])
def staleness_dashboard(request):
    """Per-estate freshness health, stalest estate first."""
    return Response({"estates": qa.estate_staleness_dashboard()})


@api_view(["GET"])
@authentication_classes(STAFF_AUTH)
@permission_classes([IsStaff])
def stalest_buildings(request):
    """Oldest-verified buildings (the re-verify work queue). Optional ?estate=."""
    buildings = qa.stalest_buildings(estate_slug=request.query_params.get("estate"))
    return Response({"results": [_building_brief(b) for b in buildings]})


@api_view(["GET"])
@authentication_classes(STAFF_AUTH)
@permission_classes([IsStaff])
def agent_leaderboard(request):
    """Agent capture stats, most productive first."""
    return Response({"agents": qa.agent_leaderboard()})


@api_view(["GET"])
@authentication_classes(STAFF_AUTH)
@permission_classes([IsStaff])
def review_queue(request):
    """Captured-but-unreviewed buildings, oldest first."""
    buildings = qa.review_queue()
    results = []
    for b in buildings:
        brief = _building_brief(b)
        brief["photo_count"] = b.photos.count()
        results.append(brief)
    return Response({"count": len(results), "results": results})


@api_view(["POST"])
@authentication_classes(STAFF_AUTH)
@permission_classes([IsStaff])
def review_building(request, building_id):
    """Sign a building off the QA review queue."""
    building = get_object_or_404(Building, id=building_id)
    qa.mark_reviewed(building, reviewed_by=request.user)
    return Response({"id": str(building.id), "reviewed_at": building.reviewed_at})


@api_view(["POST"])
@authentication_classes(STAFF_AUTH)
@permission_classes([IsStaff])
def moderate_photo(request, photo_id):
    """Moderate a photo: {"rejected": true|false}. Rejected photos are hidden
    from consumer surfaces.
    """
    photo = get_object_or_404(BuildingPhoto, id=photo_id)
    rejected = request.data.get("rejected", True)
    photo.rejected = bool(rejected)
    photo.save(update_fields=["rejected", "updated_at"])
    return Response({"id": photo.id, "rejected": photo.rejected})
