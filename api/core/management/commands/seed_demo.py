"""Seed demo data: 3 estates + 20 buildings with real Nairobi coordinates.

Idempotent-ish: pass --fresh to wipe demo rows first. Coordinates are genuine
gate-ish points in Roysambu, Kilimani, and Kasarani so map/geo queries look
realistic during development.
"""

import random
from datetime import timedelta

from django.contrib.gis.geos import Point
from django.core.management.base import BaseCommand
from django.utils import timezone
from django.utils.text import slugify

from core.models import (
    Agent,
    Building,
    Estate,
    UnitType,
    VacancySnapshot,
)
from core.services.freshness import recompute_building_freshness

# (name, centroid lng, centroid lat)
ESTATES = [
    ("Roysambu", 36.8964, -1.2185),
    ("Kilimani", 36.7856, -1.2905),
    ("Kasarani", 36.8990, -1.2205),
]

# Real-ish gate points clustered around each estate centroid.
BUILDINGS = [
    # Roysambu
    ("Roysambu", "Lumumba Court", 36.8971, -1.2178),
    ("Roysambu", "TRM View Apartments", 36.8952, -1.2192),
    ("Roysambu", "Zimmerman Heights", 36.8988, -1.2160),
    ("Roysambu", "Mirema Gardens", 36.8935, -1.2140),
    ("Roysambu", "Kahawa West Villas", 36.9005, -1.2205),
    ("Roysambu", "Thome Springs", 36.8949, -1.2211),
    ("Roysambu", "USIU Court", 36.8801, -1.2141),
    # Kilimani
    ("Kilimani", "Yaya Residence", 36.7822, -1.2938),
    ("Kilimani", "Kirichwa Towers", 36.7889, -1.2921),
    ("Kilimani", "Argwings Kodhek Court", 36.7901, -1.2955),
    ("Kilimani", "Wood Avenue Suites", 36.7845, -1.2889),
    ("Kilimani", "Lenana Heights", 36.7867, -1.2970),
    ("Kilimani", "Ngong Road Gardens", 36.7790, -1.2985),
    ("Kilimani", "Dennis Pritt Place", 36.7912, -1.2901),
    # Kasarani
    ("Kasarani", "Sunton Court", 36.9012, -1.2189),
    ("Kasarani", "Hunters Villas", 36.8975, -1.2231),
    ("Kasarani", "Mwiki Road Apartments", 36.9050, -1.2170),
    ("Kasarani", "Seasons Estate", 36.8961, -1.2258),
    ("Kasarani", "Clay City Homes", 36.9034, -1.2242),
    ("Kasarani", "Santon Gardens", 36.8998, -1.2211),
]

UNIT_MIX = [
    (UnitType.Kind.BEDSITTER, 8000, 8000),
    (UnitType.Kind.ONE_BR, 15000, 15000),
    (UnitType.Kind.TWO_BR, 28000, 28000),
]


class Command(BaseCommand):
    help = "Seed 3 estates and 20 buildings with Nairobi coordinates."

    def add_arguments(self, parser):
        parser.add_argument(
            "--fresh",
            action="store_true",
            help="Delete existing demo estates/buildings first.",
        )

    def handle(self, *args, **options):
        rng = random.Random(42)

        if options["fresh"]:
            Building.objects.all().delete()
            Estate.objects.all().delete()
            Agent.objects.filter(phone="+254700000000").delete()
            self.stdout.write("Wiped existing buildings/estates.")

        agent, _ = Agent.objects.get_or_create(
            phone="+254700000000",
            defaults={"name": "Demo Agent", "device_id": "seed-device"},
        )

        estates: dict[str, Estate] = {}
        for name, lng, lat in ESTATES:
            estate, _ = Estate.objects.get_or_create(
                slug=slugify(name),
                defaults={"name": name, "centroid": Point(lng, lat, srid=4326)},
            )
            agent.coverage.add(estate)
            estates[name] = estate

        now = timezone.now()
        created = 0
        for estate_name, bname, lng, lat in BUILDINGS:
            building, was_created = Building.objects.get_or_create(
                estate=estates[estate_name],
                name=bname,
                defaults={
                    "location": Point(lng, lat, srid=4326),
                    "created_by_agent": agent,
                    "floors": rng.randint(2, 8),
                    "parking": rng.random() > 0.5,
                    "caretaker_name": "Caretaker",
                    "caretaker_phone": "+2547" + str(rng.randint(10000000, 99999999)),
                },
            )
            if not was_created:
                continue
            created += 1

            for kind, rent, deposit in UNIT_MIX:
                if rng.random() > 0.7:
                    continue  # not every building has every unit type
                unit = UnitType.objects.create(
                    building=building,
                    kind=kind,
                    rent_kes=rent + rng.randint(-2000, 4000),
                    deposit_kes=deposit,
                )
                # Spread verification ages so staleness demos have something to chew on.
                age_days = rng.choice([0, 1, 3, 7, 12, 20, 40])
                VacancySnapshot.objects.create(
                    unit_type=unit,
                    vacant_count=rng.randint(0, 4),
                    verified_at=now - timedelta(days=age_days),
                    verified_by=agent,
                    source=VacancySnapshot.Source.AGENT_VISIT,
                )

            # Let the freshness engine set has_active_vacancy / is_demoted /
            # latest_verified_at exactly as the real pipeline would.
            recompute_building_freshness(building)

        self.stdout.write(
            self.style.SUCCESS(f"Seeded {len(estates)} estates, {created} new buildings.")
        )
