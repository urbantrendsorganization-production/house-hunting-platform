from django.urls import path

from core import admin_views, agent_views, consumer_views
from core.views import health

urlpatterns = [
    path("health/", health, name="health"),
    # Agent capture pipeline (Phase 1)
    path("agent/login/", agent_views.agent_login, name="agent-login"),
    path("agent/sync/", agent_views.agent_sync, name="agent-sync"),
    path("agent/photos/presign/", agent_views.photo_presign, name="agent-photo-presign"),
    path("agent/photos/confirm/", agent_views.photo_confirm, name="agent-photo-confirm"),
    # Consumer map API (Phase 3) — anonymous-readable
    path("map/viewport/", consumer_views.viewport, name="map-viewport"),
    path("map/near-me/", consumer_views.near_me, name="map-near-me"),
    path("buildings/<uuid:building_id>/", consumer_views.building_detail, name="building-detail"),
    # Estate SEO surfaces (Phase 5 backend support)
    path("estates/", consumer_views.estate_list, name="estate-list"),
    path("estates/<slug:slug>/", consumer_views.estate_detail, name="estate-detail"),
    # Back office / data QA (Phase 6) — staff-only
    path("admin/duplicates/", admin_views.duplicate_candidates, name="admin-duplicates"),
    path("admin/buildings/merge/", admin_views.merge_buildings, name="admin-merge"),
    path("admin/dashboard/staleness/", admin_views.staleness_dashboard, name="admin-staleness"),
    path(
        "admin/dashboard/stalest-buildings/",
        admin_views.stalest_buildings,
        name="admin-stalest-buildings",
    ),
    path("admin/agents/leaderboard/", admin_views.agent_leaderboard, name="admin-leaderboard"),
    path("admin/review-queue/", admin_views.review_queue, name="admin-review-queue"),
    path(
        "admin/buildings/<uuid:building_id>/review/",
        admin_views.review_building,
        name="admin-review-building",
    ),
    path(
        "admin/photos/<int:photo_id>/moderate/",
        admin_views.moderate_photo,
        name="admin-moderate-photo",
    ),
]
