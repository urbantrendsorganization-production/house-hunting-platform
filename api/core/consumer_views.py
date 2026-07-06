"""Consumer map API (anonymous-readable). Viewport, near-me, detail.

Abuse guards: DRF anon throttling + a max-bbox-area cap. Viewport responses are
cached in Redis keyed by a quantized bbox + zoom (60s TTL).
"""

import hashlib

from django.conf import settings
from django.core.cache import cache
from django.shortcuts import get_object_or_404
from rest_framework import status
from rest_framework.decorators import api_view, permission_classes, throttle_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework.throttling import AnonRateThrottle

from core.consumer_serializers import BuildingDetailSerializer, BuildingMarkerSerializer
from core.models import Building
from core.services import map_queries
from core.services.map_queries import BboxTooLarge


class ViewportThrottle(AnonRateThrottle):
    scope = "viewport"


def _float(params, key):
    try:
        return float(params[key])
    except (KeyError, TypeError, ValueError) as exc:
        raise ValueError(f"missing or invalid {key}") from exc


def _cluster_cell_size(zoom: int) -> float:
    """Grid cell in degrees, coarser as you zoom out. Roughly halves per level."""
    base = settings.MAP_CLUSTER_BASE_CELL_DEG
    steps = max(0, settings.MAP_CLUSTER_ZOOM_THRESHOLD - zoom)
    return base * (2**steps)


@api_view(["GET"])
@permission_classes([AllowAny])
@throttle_classes([ViewportThrottle])
def viewport(request):
    """bbox=w,s,e,n & zoom. Returns markers when zoomed in, clusters when out."""
    p = request.query_params
    try:
        w, s, e, n = (_float(p, k) for k in ("w", "s", "e", "n"))
        zoom = int(p.get("zoom", 15))
    except ValueError as exc:
        return Response({"detail": str(exc)}, status=400)

    # Quantize the bbox for a stable cache key (avoids a fresh entry per pixel-pan).
    q = 4
    key_src = f"{round(w, q)},{round(s, q)},{round(e, q)},{round(n, q)}:{zoom}"
    cache_key = "viewport:" + hashlib.sha1(key_src.encode()).hexdigest()
    cached = cache.get(cache_key)
    if cached is not None:
        return Response(cached)

    try:
        if zoom < settings.MAP_CLUSTER_ZOOM_THRESHOLD:
            clusters = map_queries.clusters_in_bbox(w, s, e, n, cell_size=_cluster_cell_size(zoom))
            payload = {
                "mode": "clusters",
                "clusters": clusters,
                "count": sum(c["count"] for c in clusters),
            }
        else:
            buildings = map_queries.markers_in_bbox(w, s, e, n)
            payload = {
                "mode": "markers",
                "markers": BuildingMarkerSerializer(buildings, many=True).data,
                "count": len(buildings),
                "capped": len(buildings) >= settings.MAP_MAX_MARKERS,
            }
    except BboxTooLarge as exc:
        return Response({"detail": str(exc)}, status=status.HTTP_422_UNPROCESSABLE_ENTITY)

    cache.set(cache_key, payload, settings.VIEWPORT_CACHE_TTL)
    return Response(payload)


@api_view(["GET"])
@permission_classes([AllowAny])
@throttle_classes([ViewportThrottle])
def near_me(request):
    """lng, lat, radius_km (default 2). Distance-sorted active buildings."""
    p = request.query_params
    try:
        lng, lat = _float(p, "lng"), _float(p, "lat")
        radius_km = min(float(p.get("radius_km", 2)), settings.MAP_MAX_RADIUS_KM)
    except ValueError as exc:
        return Response({"detail": str(exc)}, status=400)

    buildings = map_queries.buildings_near(lng, lat, radius_km)
    data = BuildingMarkerSerializer(buildings, many=True).data
    for item, b in zip(data, buildings, strict=False):
        item["distance_m"] = round(b.dist.m)
    return Response({"count": len(data), "results": data})


@api_view(["GET"])
@permission_classes([AllowAny])
def building_detail(request, building_id):
    """Full building detail. Hidden (no active vacancy) buildings 404."""
    building = get_object_or_404(
        Building.objects.select_related("estate").prefetch_related("unit_types"),
        id=building_id,
        has_active_vacancy=True,
    )
    return Response(BuildingDetailSerializer(building).data)
