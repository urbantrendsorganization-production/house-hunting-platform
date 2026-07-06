"""Consumer map read models: viewport, clustering, radius.

All queries filter on the denormalized `has_active_vacancy` flag and NEVER join
through snapshots (CLAUDE.md). Stale (>30d) listings have that flag forced False
by the sweep, so they are provably absent from every consumer surface here.
"""

from django.conf import settings
from django.contrib.gis.db.models.functions import Distance
from django.contrib.gis.geos import Point, Polygon
from django.db import connection

from core.models import Building


class BboxTooLarge(ValueError):
    pass


def _envelope(w: float, s: float, e: float, n: float) -> Polygon:
    area = abs(e - w) * abs(n - s)
    if area > settings.MAP_MAX_BBOX_AREA_DEG2:
        raise BboxTooLarge(f"bbox area {area:.4f} exceeds cap")
    return Polygon.from_bbox((w, s, e, n))


def markers_in_bbox(w, s, e, n, *, limit=None):
    """Raw active-vacancy buildings inside the bbox, capped at MAX_MARKERS."""
    limit = limit or settings.MAP_MAX_MARKERS
    poly = _envelope(w, s, e, n)
    qs = (
        Building.objects.filter(has_active_vacancy=True, location__intersects=poly)
        .select_related("estate")
        .order_by("is_demoted", "-latest_verified_at")
    )
    return list(qs[:limit])


def clusters_in_bbox(w, s, e, n, *, cell_size):
    """Server-side clustering via ST_SnapToGrid.

    Groups active buildings into grid cells of `cell_size` degrees and returns
    one point (the cell centroid) + count per cell — so a phone never receives
    hundreds of raw markers when zoomed out.
    """
    _envelope(w, s, e, n)  # enforce the bbox-area cap here too
    sql = """
        SELECT
            ST_X(ST_Centroid(ST_Collect(loc))) AS lng,
            ST_Y(ST_Centroid(ST_Collect(loc))) AS lat,
            COUNT(*) AS n
        FROM (
            SELECT location::geometry AS loc,
                   ST_SnapToGrid(location::geometry, %(cell)s) AS cell
            FROM core_building
            WHERE has_active_vacancy
              AND location::geometry && ST_MakeEnvelope(%(w)s, %(s)s, %(e)s, %(n)s, 4326)
        ) grid
        GROUP BY cell
        ORDER BY n DESC;
    """
    params = {"cell": cell_size, "w": w, "s": s, "e": e, "n": n}
    with connection.cursor() as cur:
        cur.execute(sql, params)
        rows = cur.fetchall()
    return [{"lng": r[0], "lat": r[1], "count": r[2]} for r in rows]


def count_active_in_bbox(w, s, e, n) -> int:
    poly = _envelope(w, s, e, n)
    return Building.objects.filter(has_active_vacancy=True, location__intersects=poly).count()


def buildings_near(lng: float, lat: float, radius_km: float, *, limit=None):
    """Radius / 'near me' query, distance-sorted (rides the GiST index)."""
    limit = limit or settings.MAP_MAX_MARKERS
    point = Point(lng, lat, srid=4326)
    from django.contrib.gis.measure import D

    qs = (
        Building.objects.filter(has_active_vacancy=True, location__dwithin=(point, D(km=radius_km)))
        .select_related("estate")
        .annotate(dist=Distance("location", point))
        .order_by("dist")
    )
    return list(qs[:limit])
