from django.contrib.gis import admin

from core.models import (
    Agent,
    Building,
    BuildingMergeLog,
    BuildingPhoto,
    Estate,
    Lead,
    UnitType,
    VacancySnapshot,
)


@admin.register(BuildingPhoto)
class BuildingPhotoAdmin(admin.ModelAdmin):
    list_display = ("storage_key", "building", "confirmed", "rejected")
    list_filter = ("confirmed", "rejected")


@admin.register(Estate)
class EstateAdmin(admin.GISModelAdmin):
    list_display = ("name", "slug")
    prepopulated_fields = {"slug": ("name",)}


@admin.register(Agent)
class AgentAdmin(admin.ModelAdmin):
    list_display = ("name", "phone", "is_active")
    list_filter = ("is_active",)


@admin.register(Building)
class BuildingAdmin(admin.GISModelAdmin):
    list_display = ("__str__", "estate", "has_active_vacancy", "reviewed_at", "created_at")
    list_filter = ("has_active_vacancy", "is_demoted", "estate")
    search_fields = ("name", "caretaker_name", "caretaker_phone")
    readonly_fields = ("reviewed_at", "reviewed_by")


@admin.register(UnitType)
class UnitTypeAdmin(admin.ModelAdmin):
    list_display = ("building", "kind", "rent_kes")
    list_filter = ("kind",)


@admin.register(VacancySnapshot)
class VacancySnapshotAdmin(admin.ModelAdmin):
    list_display = ("unit_type", "vacant_count", "verified_at", "source")
    list_filter = ("source",)

    # Append-only: no edits/deletes from the admin.
    def has_change_permission(self, request, obj=None):
        return False

    def has_delete_permission(self, request, obj=None):
        return False


@admin.register(Lead)
class LeadAdmin(admin.ModelAdmin):
    list_display = ("building", "unit_type", "created_at")


@admin.register(BuildingMergeLog)
class BuildingMergeLogAdmin(admin.ModelAdmin):
    """Read-only audit trail — merges happen via the API, never hand-edited."""

    list_display = ("source_id", "source_name", "target", "merged_by", "created_at")
    readonly_fields = ("target", "source_id", "source_name", "merged_by", "summary")

    def has_add_permission(self, request):
        return False

    def has_change_permission(self, request, obj=None):
        return False

    def has_delete_permission(self, request, obj=None):
        return False
