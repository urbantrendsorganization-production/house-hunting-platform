from rest_framework.permissions import BasePermission

from core.authentication import AgentUser


class IsAgent(BasePermission):
    message = "Agent authentication required."

    def has_permission(self, request, view) -> bool:
        return isinstance(getattr(request, "user", None), AgentUser)


class IsStaff(BasePermission):
    """Back-office endpoints (Phase 6): authenticated Django staff users only."""

    message = "Staff authentication required."

    def has_permission(self, request, view) -> bool:
        user = getattr(request, "user", None)
        return bool(user and user.is_authenticated and user.is_staff)
