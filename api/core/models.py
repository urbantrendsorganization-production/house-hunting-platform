"""Core domain model for Keja.

Anchored on `Building` (captured at the gate by a field agent) with an
append-only `VacancySnapshot` freshness engine. See CLAUDE.md for the rules
that must never be violated — notably: snapshots are never UPDATEd, and
`Building.location` is only writable by agent capture or admin correction.
"""

import uuid

from django.contrib.gis.db import models as gis_models
from django.db import models


class TimestampedModel(models.Model):
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        abstract = True


class Estate(TimestampedModel):
    """A named area: 'Roysambu', 'Kilimani' — centroid plus optional polygon."""

    name = models.CharField(max_length=120, unique=True)
    slug = models.SlugField(max_length=140, unique=True)
    centroid = gis_models.PointField(srid=4326, geography=False)
    boundary = gis_models.PolygonField(srid=4326, null=True, blank=True)

    class Meta:
        ordering = ["name"]

    def __str__(self) -> str:
        return self.name


class Agent(TimestampedModel):
    """Field agent — device-bound. Auth/device-binding lands in Phase 1."""

    name = models.CharField(max_length=120)
    phone = models.CharField(max_length=16, unique=True)  # E.164
    device_id = models.CharField(max_length=128, blank=True, default="")
    is_active = models.BooleanField(default=True)
    coverage = models.ManyToManyField(Estate, related_name="agents", blank=True)

    def __str__(self) -> str:
        return f"{self.name} ({self.phone})"


class Building(TimestampedModel):
    """THE anchor entity. Pinned AT THE GATE by agent GPS."""

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    name = models.CharField(max_length=200, blank=True, default="")
    # SRID 4326 geography, GiST-indexed. geography=True so `dwithin`/`Distance`
    # take metric units (D(km=2)) — the radius/near-me pattern in CLAUDE.md.
    # Every viewport and radius query rides this index.
    location = gis_models.PointField(srid=4326, geography=True, spatial_index=True)

    estate = models.ForeignKey(Estate, on_delete=models.PROTECT, related_name="buildings")
    created_by_agent = models.ForeignKey(
        Agent, on_delete=models.SET_NULL, null=True, blank=True, related_name="buildings"
    )

    floors = models.PositiveSmallIntegerField(null=True, blank=True)
    water_notes = models.CharField(max_length=255, blank=True, default="")
    power_notes = models.CharField(max_length=255, blank=True, default="")
    security_notes = models.CharField(max_length=255, blank=True, default="")
    parking = models.BooleanField(default=False)

    caretaker_name = models.CharField(max_length=120, blank=True, default="")
    caretaker_phone = models.CharField(max_length=16, blank=True, default="")  # E.164

    # Denormalized flags maintained by snapshot insert + the staleness sweep.
    # Viewport queries filter on these and MUST NEVER join through snapshots.
    has_active_vacancy = models.BooleanField(default=False, db_index=True)
    # Latest verification > VACANCY_DEMOTE_DAYS old → still visible but ranked
    # down. > VACANCY_HIDE_DAYS old → has_active_vacancy forced False (hidden).
    is_demoted = models.BooleanField(default=False, db_index=True)
    # Age of the freshest snapshot across this building's unit types. Denormalized
    # so consumer surfaces render "verified X days ago" without a snapshot join.
    latest_verified_at = models.DateTimeField(null=True, blank=True, db_index=True)

    class Meta:
        ordering = ["-created_at"]

    def __str__(self) -> str:
        return self.name or f"Building {self.pk}"


class UnitType(TimestampedModel):
    class Kind(models.TextChoices):
        BEDSITTER = "BEDSITTER", "Bedsitter"
        ONE_BR = "1BR", "1 Bedroom"
        TWO_BR = "2BR", "2 Bedroom"
        THREE_BR = "3BR", "3 Bedroom"
        SINGLE = "SINGLE", "Single Room"

    # Client-generated idempotency key: the agent app assigns this offline so
    # retries of the sync queue never create duplicates.
    client_uuid = models.UUIDField(default=uuid.uuid4, unique=True, editable=False)
    building = models.ForeignKey(Building, on_delete=models.CASCADE, related_name="unit_types")
    kind = models.CharField(max_length=16, choices=Kind.choices)
    rent_kes = models.PositiveIntegerField()
    deposit_kes = models.PositiveIntegerField(null=True, blank=True)
    amenities = models.JSONField(default=dict, blank=True)

    class Meta:
        constraints = [
            models.UniqueConstraint(fields=["building", "kind"], name="uniq_unit_type_per_building")
        ]

    def __str__(self) -> str:
        return f"{self.get_kind_display()} @ {self.building}"


class VacancySnapshot(TimestampedModel):
    """Append-only. Current vacancy = latest snapshot per unit type.

    NEVER UPDATE a row here. The freshness engine reads `verified_at`.
    """

    class Source(models.TextChoices):
        AGENT_VISIT = "AGENT_VISIT", "Agent visit"
        CARETAKER_CALL = "CARETAKER_CALL", "Caretaker call"
        CARETAKER_SELF_REPORT = "CARETAKER_SELF_REPORT", "Caretaker self-report"

    # Idempotency key (see UnitType.client_uuid). Replaying a sync batch with the
    # same client_uuid must not append a second snapshot.
    client_uuid = models.UUIDField(default=uuid.uuid4, unique=True, editable=False)
    unit_type = models.ForeignKey(UnitType, on_delete=models.CASCADE, related_name="snapshots")
    vacant_count = models.PositiveSmallIntegerField()
    verified_at = models.DateTimeField(db_index=True)
    verified_by = models.ForeignKey(
        Agent, on_delete=models.SET_NULL, null=True, blank=True, related_name="snapshots"
    )
    source = models.CharField(max_length=24, choices=Source.choices, default=Source.AGENT_VISIT)

    class Meta:
        ordering = ["-verified_at"]
        indexes = [
            models.Index(fields=["unit_type", "-verified_at"]),
        ]

    def __str__(self) -> str:
        return f"{self.unit_type}: {self.vacant_count} vacant @ {self.verified_at:%Y-%m-%d}"


class BuildingPhoto(TimestampedModel):
    """A photo stored in object storage. The API never touches image bytes —
    the client uploads directly via a presigned PUT, then confirms the key here.
    """

    client_uuid = models.UUIDField(default=uuid.uuid4, unique=True, editable=False)
    building = models.ForeignKey(Building, on_delete=models.CASCADE, related_name="photos")
    unit_type = models.ForeignKey(
        UnitType, on_delete=models.CASCADE, null=True, blank=True, related_name="photos"
    )
    storage_key = models.CharField(max_length=512)
    thumbnail_key = models.CharField(max_length=512, blank=True, default="")
    confirmed = models.BooleanField(default=False)

    def __str__(self) -> str:
        return self.storage_key


class Lead(TimestampedModel):
    """Consumer expressed interest. Business-model hook — kept generic."""

    building = models.ForeignKey(Building, on_delete=models.CASCADE, related_name="leads")
    unit_type = models.ForeignKey(
        UnitType, on_delete=models.SET_NULL, null=True, blank=True, related_name="leads"
    )
    contact_phone = models.CharField(max_length=16, blank=True, default="")  # E.164
    note = models.TextField(blank=True, default="")

    def __str__(self) -> str:
        return f"Lead on {self.building}"
