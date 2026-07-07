"""Phase 6: back-office endpoints are staff-only, never anonymous-readable."""

import pytest
from django.contrib.auth import get_user_model
from django.urls import reverse
from rest_framework.test import APIClient

pytestmark = pytest.mark.django_db


def test_dashboard_denies_anonymous():
    resp = APIClient().get(reverse("admin-staleness"))
    assert resp.status_code in (401, 403)


def test_dashboard_denies_non_staff():
    user = get_user_model().objects.create_user("bob", password="x", is_staff=False)
    client = APIClient()
    client.force_authenticate(user=user)
    assert client.get(reverse("admin-staleness")).status_code == 403


def test_dashboard_allows_staff(estate):
    staff = get_user_model().objects.create_user("admin", password="x", is_staff=True)
    client = APIClient()
    client.force_authenticate(user=staff)
    resp = client.get(reverse("admin-staleness"))
    assert resp.status_code == 200
    assert "estates" in resp.json()


def test_merge_endpoint_requires_staff():
    resp = APIClient().post(reverse("admin-merge"), {"target": "x", "source": "y"}, format="json")
    assert resp.status_code in (401, 403)
