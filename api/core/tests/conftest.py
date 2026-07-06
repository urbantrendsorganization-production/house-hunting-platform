import uuid

import pytest
from django.contrib.gis.geos import Point
from django.core.cache import cache
from django.utils.text import slugify

from core.models import Agent, Estate


@pytest.fixture(autouse=True)
def _clear_cache():
    """Viewport cache + throttle counters live in Redis; isolate every test."""
    cache.clear()
    yield
    cache.clear()


@pytest.fixture
def estate(db):
    return Estate.objects.create(
        name="Roysambu",
        slug=slugify("Roysambu"),
        centroid=Point(36.8964, -1.2185, srid=4326),
    )


@pytest.fixture
def agent(db):
    return Agent.objects.create(name="Test Agent", phone="+254712345678")


@pytest.fixture
def building_uuid():
    return str(uuid.uuid4())
