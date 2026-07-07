"""Data-QA read models for the back office (Phase 6).

Everything here answers one question a founder/ops person asks daily: *is an
estate's data healthy, and where is it rotting?* The gate is that an estate's
health is assessable in under a minute — so these are cheap aggregate reads over
the same denormalized freshness flags the consumer surfaces use.
"""

from datetime import timedelta

from django.conf import settings
from django.db.models import Count, F, Max, Min, Q
from django.utils import timezone

from core.models import Agent, Building, Estate


def estate_staleness_dashboard() -> list[dict]:
    """Per-estate freshness health, worst (stalest) estates first.

    For each estate: total buildings, how many currently surface a vacancy, how
    many are demoted (>14d) or hidden (>30d) by the sweep, and the oldest /
    newest verification timestamps — the "where is it rotting" signal.
    """
    now = timezone.now()
    demote_cutoff = now - timedelta(days=settings.VACANCY_DEMOTE_DAYS)
    hide_cutoff = now - timedelta(days=settings.VACANCY_HIDE_DAYS)

    rows = []
    estates = Estate.objects.annotate(
        buildings_total=Count("buildings", distinct=True),
        active_count=Count(
            "buildings", filter=Q(buildings__has_active_vacancy=True), distinct=True
        ),
        demoted_count=Count("buildings", filter=Q(buildings__is_demoted=True), distinct=True),
        stale_count=Count(
            "buildings",
            filter=Q(buildings__latest_verified_at__lt=demote_cutoff),
            distinct=True,
        ),
        hidden_count=Count(
            "buildings",
            filter=Q(
                buildings__latest_verified_at__lt=hide_cutoff,
                buildings__has_active_vacancy=False,
            ),
            distinct=True,
        ),
        never_verified=Count(
            "buildings", filter=Q(buildings__latest_verified_at__isnull=True), distinct=True
        ),
        oldest_verified_at=Min("buildings__latest_verified_at"),
        newest_verified_at=Max("buildings__latest_verified_at"),
    )

    for e in estates:
        oldest = e.oldest_verified_at
        rows.append(
            {
                "estate": e.name,
                "slug": e.slug,
                "buildings_total": e.buildings_total,
                "active_count": e.active_count,
                "demoted_count": e.demoted_count,
                "stale_count": e.stale_count,
                "hidden_count": e.hidden_count,
                "never_verified": e.never_verified,
                "oldest_verified_at": oldest,
                "oldest_verified_days_ago": (now - oldest).days if oldest else None,
                "newest_verified_at": e.newest_verified_at,
            }
        )

    # Stalest first: most days since the oldest verification, unknowns on top
    # (an estate with never-verified buildings is the worst kind of stale).
    rows.sort(
        key=lambda r: (
            r["oldest_verified_days_ago"] is not None,
            -(r["oldest_verified_days_ago"] or 0),
        )
    )
    return rows


def stalest_buildings(*, estate_slug: str | None = None, limit: int = 25) -> list[Building]:
    """Individual buildings ordered by oldest verification — the work queue for
    'go re-verify these'. Never-verified buildings sort first.
    """
    qs = Building.objects.select_related("estate")
    if estate_slug:
        qs = qs.filter(estate__slug=estate_slug)
    # NULLs (never verified) are the stalest, but Postgres sorts them LAST on ASC
    # — force them first.
    return list(qs.order_by(F("latest_verified_at").asc(nulls_first=True))[:limit])


def agent_leaderboard() -> list[dict]:
    """Capture stats per agent — feeds the future agent-payment model.

    Buildings captured, unit types, and total verifications (snapshots) made,
    most productive first.
    """
    agents = Agent.objects.annotate(
        buildings_captured=Count("buildings", distinct=True),
        verifications=Count("snapshots", distinct=True),
        last_capture_at=Max("buildings__created_at"),
        last_verified_at=Max("snapshots__verified_at"),
    ).order_by("-buildings_captured", "-verifications")

    return [
        {
            "id": a.id,
            "name": a.name,
            "phone": a.phone,
            "is_active": a.is_active,
            "buildings_captured": a.buildings_captured,
            "verifications": a.verifications,
            "last_capture_at": a.last_capture_at,
            "last_verified_at": a.last_verified_at,
        }
        for a in agents
    ]


def review_queue(*, limit: int = 50) -> list[Building]:
    """Captured-but-unreviewed buildings, oldest capture first (FIFO QA queue)."""
    return list(
        Building.objects.filter(reviewed_at__isnull=True)
        .select_related("estate", "created_by_agent")
        .prefetch_related("photos")
        .order_by("created_at")[:limit]
    )


def mark_reviewed(building: Building, *, reviewed_by=None) -> Building:
    """Sign a building off the QA review queue. Does not touch visibility —
    freshness owns that; this is a data-quality checkpoint only.
    """
    building.reviewed_at = timezone.now()
    building.reviewed_by = reviewed_by
    building.save(update_fields=["reviewed_at", "reviewed_by", "updated_at"])
    return building
