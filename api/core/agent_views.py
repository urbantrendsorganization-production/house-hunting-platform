"""Agent-facing API: login (device binding), idempotent sync, photo presign."""

from rest_framework import status
from rest_framework.decorators import (
    api_view,
    authentication_classes,
    permission_classes,
)
from rest_framework.permissions import AllowAny
from rest_framework.response import Response

from core.authentication import AgentJWTAuthentication
from core.models import BuildingPhoto
from core.permissions import IsAgent
from core.services import storage
from core.services.agent_auth import AgentAuthError, bind_and_issue_token
from core.services.sync import apply_sync_batch
from core.tasks import generate_thumbnail


@api_view(["POST"])
@authentication_classes([])
@permission_classes([AllowAny])
def agent_login(request):
    """Bind device + issue a 30-day agent JWT."""
    phone = request.data.get("phone")
    device_id = request.data.get("device_id")
    if not phone:
        return Response({"detail": "phone required"}, status=400)
    try:
        agent, token = bind_and_issue_token(phone=phone, device_id=device_id or "")
    except AgentAuthError as exc:
        return Response({"detail": str(exc)}, status=status.HTTP_403_FORBIDDEN)
    return Response(
        {"token": token, "agent": {"id": agent.id, "name": agent.name, "phone": agent.phone}}
    )


@api_view(["POST"])
@authentication_classes([AgentJWTAuthentication])
@permission_classes([IsAgent])
def agent_sync(request):
    """Idempotent batch upsert. Response tells the client what to mark synced."""
    records = request.data.get("records")
    if not isinstance(records, list):
        return Response({"detail": "records must be a list"}, status=400)
    results = apply_sync_batch(request.user.agent, records)
    synced = sum(1 for r in results if r["status"] == "synced")
    return Response({"synced": synced, "total": len(results), "results": results})


@api_view(["POST"])
@authentication_classes([AgentJWTAuthentication])
@permission_classes([IsAgent])
def photo_presign(request):
    """Return a presigned PUT URL + the storage key to upload directly to."""
    building_id = request.data.get("building")
    content_type = request.data.get("content_type", "image/jpeg")
    if not building_id:
        return Response({"detail": "building required"}, status=400)
    key = storage.build_object_key(building_id, content_type)
    url = storage.presign_put(key, content_type)
    return Response({"upload_url": url, "storage_key": key, "method": "PUT"})


@api_view(["POST"])
@authentication_classes([AgentJWTAuthentication])
@permission_classes([IsAgent])
def photo_confirm(request):
    """Confirm an uploaded key; enqueue thumbnail generation."""
    from core.models import Building

    building_id = request.data.get("building")
    storage_key = request.data.get("storage_key")
    client_uuid = request.data.get("client_uuid")
    if not (building_id and storage_key):
        return Response({"detail": "building and storage_key required"}, status=400)
    try:
        building = Building.objects.get(id=building_id)
    except Building.DoesNotExist:
        return Response({"detail": "building not found"}, status=404)

    defaults = {"building": building, "storage_key": storage_key, "confirmed": True}
    if client_uuid:
        photo, _ = BuildingPhoto.objects.update_or_create(
            client_uuid=client_uuid, defaults=defaults
        )
    else:
        photo = BuildingPhoto.objects.create(**defaults)
    generate_thumbnail.delay(photo.id)
    return Response({"id": photo.id, "confirmed": True}, status=status.HTTP_201_CREATED)
