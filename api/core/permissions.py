from rest_framework.permissions import BasePermission

from core.authentication import AgentUser


class IsAgent(BasePermission):
    message = "Agent authentication required."

    def has_permission(self, request, view) -> bool:
        return isinstance(getattr(request, "user", None), AgentUser)
