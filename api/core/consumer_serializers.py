"""Consumer-facing read serializers. Every listing carries verified age."""

from django.utils import timezone
from rest_framework import serializers

from core.models import Building, BuildingPhoto, UnitType
from core.services import storage
from core.services.freshness import latest_snapshot_for


def _verified_days_ago(building: Building):
    if not building.latest_verified_at:
        return None
    delta = timezone.now() - building.latest_verified_at
    return delta.days


def _photo_url(photo: BuildingPhoto) -> str:
    """Presigned GET for a stored photo. Bucket is private, so consumer surfaces
    read through short-lived signed URLs (prefer the thumbnail when present)."""
    return storage.presign_get(photo.thumbnail_key or photo.storage_key)


def _visible_photos(qs):
    """Only confirmed, un-rejected photos ever reach a consumer surface."""
    return [_photo_url(p) for p in qs.filter(confirmed=True, rejected=False)]


class UnitTypeSerializer(serializers.ModelSerializer):
    kind_display = serializers.CharField(source="get_kind_display", read_only=True)
    vacant_count = serializers.SerializerMethodField()
    photos = serializers.SerializerMethodField()

    class Meta:
        model = UnitType
        fields = [
            "id",
            "kind",
            "kind_display",
            "rent_kes",
            "deposit_kes",
            "amenities",
            "vacant_count",
            "photos",
        ]

    def get_vacant_count(self, obj):
        snap = latest_snapshot_for(obj)
        return snap.vacant_count if snap else None

    def get_photos(self, obj):
        return _visible_photos(obj.photos)


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


class BuildingListSerializer(BuildingMarkerSerializer):
    """Building summary for estate listing pages: adds price + unit kinds."""

    min_rent_kes = serializers.SerializerMethodField()
    unit_kinds = serializers.SerializerMethodField()

    class Meta(BuildingMarkerSerializer.Meta):
        fields = BuildingMarkerSerializer.Meta.fields + ["min_rent_kes", "unit_kinds"]

    def get_min_rent_kes(self, obj):
        rents = [ut.rent_kes for ut in obj.unit_types.all()]
        return min(rents) if rents else None

    def get_unit_kinds(self, obj):
        return sorted({ut.kind for ut in obj.unit_types.all()})


class EstateSerializer(serializers.Serializer):
    name = serializers.CharField()
    slug = serializers.CharField()
    lng = serializers.SerializerMethodField()
    lat = serializers.SerializerMethodField()
    active_building_count = serializers.IntegerField(read_only=True)

    def get_lng(self, obj):
        return obj.centroid.x

    def get_lat(self, obj):
        return obj.centroid.y


class BuildingDetailSerializer(BuildingMarkerSerializer):
    """Full detail for the bottom sheet / building page.

    Note: `caretaker_phone` is deliberately NOT here — contact reveal is the
    Lead-gated business hook (see the building-contact endpoint). Only the
    caretaker's name is public.
    """

    unit_types = serializers.SerializerMethodField()
    photos = serializers.SerializerMethodField()

    class Meta(BuildingMarkerSerializer.Meta):
        fields = BuildingMarkerSerializer.Meta.fields + [
            "floors",
            "parking",
            "water_notes",
            "power_notes",
            "security_notes",
            "caretaker_name",
            "photos",
            "unit_types",
        ]

    def get_unit_types(self, obj):
        return UnitTypeSerializer(obj.unit_types.all(), many=True).data

    def get_photos(self, obj):
        # Building-level shots (a unit's own photos ride on that unit_type).
        return _visible_photos(obj.photos.filter(unit_type__isnull=True))
