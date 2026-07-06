"""Consumer-facing read serializers. Every listing carries verified age."""

from django.utils import timezone
from rest_framework import serializers

from core.models import Building, UnitType


def _verified_days_ago(building: Building):
    if not building.latest_verified_at:
        return None
    delta = timezone.now() - building.latest_verified_at
    return delta.days


class UnitTypeSerializer(serializers.ModelSerializer):
    kind_display = serializers.CharField(source="get_kind_display", read_only=True)

    class Meta:
        model = UnitType
        fields = ["id", "kind", "kind_display", "rent_kes", "deposit_kes", "amenities"]


class BuildingMarkerSerializer(serializers.ModelSerializer):
    """Lightweight payload for map markers."""

    lng = serializers.SerializerMethodField()
    lat = serializers.SerializerMethodField()
    verified_days_ago = serializers.SerializerMethodField()
    estate = serializers.CharField(source="estate.name", read_only=True)

    class Meta:
        model = Building
        fields = [
            "id",
            "name",
            "estate",
            "lng",
            "lat",
            "verified_days_ago",
            "is_demoted",
        ]

    def get_lng(self, obj):
        return obj.location.x

    def get_lat(self, obj):
        return obj.location.y

    def get_verified_days_ago(self, obj):
        return _verified_days_ago(obj)


class BuildingDetailSerializer(BuildingMarkerSerializer):
    """Full detail for the bottom sheet / building page."""

    unit_types = serializers.SerializerMethodField()

    class Meta(BuildingMarkerSerializer.Meta):
        fields = BuildingMarkerSerializer.Meta.fields + [
            "floors",
            "parking",
            "water_notes",
            "power_notes",
            "security_notes",
            "caretaker_name",
            "unit_types",
        ]

    def get_unit_types(self, obj):
        return UnitTypeSerializer(obj.unit_types.all(), many=True).data
