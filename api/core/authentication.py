"""DRF authentication for agent endpoints: JWT + live device-binding check."""

from rest_framework import authentication, exceptions

from core.models import Agent
from core.services.agent_auth import AgentAuthError, decode_token


class AgentUser:
    """Lightweight principal wrapping an Agent (Agent is not a Django user)."""

    is_authenticated = True

    def __init__(self, agent: Agent):
        self.agent = agent

    def __str__(self) -> str:
        return str(self.agent)


class AgentJWTAuthentication(authentication.BaseAuthentication):
    keyword = "Bearer"

    def authenticate(self, request):
        header = authentication.get_authorization_header(request).split()
        if not header or header[0].lower() != self.keyword.lower().encode():
            return None
        if len(header) != 2:
            raise exceptions.AuthenticationFailed("Malformed Authorization header")

        token = header[1].decode()
        try:
            payload = decode_token(token)
        except AgentAuthError as exc:
            raise exceptions.AuthenticationFailed(str(exc)) from exc

        try:
            agent = Agent.objects.get(id=payload.get("agent_id"), is_active=True)
        except Agent.DoesNotExist as exc:
            raise exceptions.AuthenticationFailed("agent not found") from exc

        # Device binding must still match — revoking the binding invalidates tokens.
        if agent.device_id != payload.get("device_id"):
            raise exceptions.AuthenticationFailed("device binding mismatch")

        return (AgentUser(agent), token)
