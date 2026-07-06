"""Agent auth: device binding on login + enforcement on API calls."""

import pytest
from rest_framework.test import APIClient

from core.services.agent_auth import AgentAuthError, bind_and_issue_token

pytestmark = pytest.mark.django_db


def test_first_login_binds_device_second_device_rejected(agent):
    _, token = bind_and_issue_token(phone="0712345678", device_id="device-A")
    assert token
    agent.refresh_from_db()
    assert agent.device_id == "device-A"

    # Same device logs in fine.
    bind_and_issue_token(phone="0712345678", device_id="device-A")

    # A different device is rejected.
    with pytest.raises(AgentAuthError):
        bind_and_issue_token(phone="0712345678", device_id="device-B")


def test_sync_requires_agent_token(agent):
    client = APIClient()
    # No token → rejected.
    resp = client.post("/api/v1/agent/sync/", {"records": []}, format="json")
    assert resp.status_code in (401, 403)

    # With token → allowed.
    _, token = bind_and_issue_token(phone="0712345678", device_id="device-A")
    client.credentials(HTTP_AUTHORIZATION=f"Bearer {token}")
    resp = client.post("/api/v1/agent/sync/", {"records": []}, format="json")
    assert resp.status_code == 200
    assert resp.json()["total"] == 0


def test_login_unknown_agent_rejected(db):
    client = APIClient()
    resp = client.post(
        "/api/v1/agent/login/",
        {"phone": "0700000000", "device_id": "d1"},
        format="json",
    )
    assert resp.status_code == 403
