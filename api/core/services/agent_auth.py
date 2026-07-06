"""Agent authentication: JWT bound to a single device.

The device is the credential. First login binds `agent.device_id`; any later
login from a different device is rejected until an admin clears the binding.
Tokens carry the bound `device_id` so a stolen token can't be replayed from
another device without also matching the binding.

Note: for the closed pilot the phone+device pair is the login. Password/OTP
hardening is a deliberate later step — see CLAUDE.md auth notes.
"""

from datetime import timedelta

import jwt
from django.conf import settings
from django.utils import timezone

from core.models import Agent
from core.services.phone import normalize_phone

ALGORITHM = "HS256"
TOKEN_TTL = timedelta(days=30)


class AgentAuthError(Exception):
    pass


def bind_and_issue_token(*, phone: str, device_id: str) -> tuple[Agent, str]:
    """Authenticate an agent by phone, binding the device on first use."""
    if not device_id:
        raise AgentAuthError("device_id required")

    normalized = normalize_phone(phone)
    try:
        agent = Agent.objects.get(phone=normalized)
    except Agent.DoesNotExist as exc:
        raise AgentAuthError("unknown agent") from exc

    if not agent.is_active:
        raise AgentAuthError("agent disabled")

    if not agent.device_id:
        agent.device_id = device_id
        agent.save(update_fields=["device_id", "updated_at"])
    elif agent.device_id != device_id:
        raise AgentAuthError("agent bound to a different device")

    return agent, issue_token(agent)


def issue_token(agent: Agent) -> str:
    now = timezone.now()
    payload = {
        "agent_id": agent.id,
        "device_id": agent.device_id,
        "iat": int(now.timestamp()),
        "exp": int((now + TOKEN_TTL).timestamp()),
    }
    return jwt.encode(payload, settings.SECRET_KEY, algorithm=ALGORITHM)


def decode_token(token: str) -> dict:
    try:
        return jwt.decode(token, settings.SECRET_KEY, algorithms=[ALGORITHM])
    except jwt.PyJWTError as exc:
        raise AgentAuthError("invalid or expired token") from exc
