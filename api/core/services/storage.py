"""Presigned object-storage uploads.

The API never proxies image bytes: it hands the client a presigned PUT URL, the
client uploads straight to S3/minio, then confirms the key back to the API.
"""

import uuid

import boto3
from botocore.client import Config
from django.conf import settings


def _client():
    return boto3.client(
        "s3",
        endpoint_url=settings.AWS_S3_ENDPOINT_URL,
        aws_access_key_id=settings.AWS_ACCESS_KEY_ID,
        aws_secret_access_key=settings.AWS_SECRET_ACCESS_KEY,
        region_name=settings.AWS_S3_REGION_NAME,
        config=Config(signature_version="s3v4"),
    )


def build_object_key(building_id, content_type: str) -> str:
    ext = {"image/jpeg": "jpg", "image/png": "png", "image/webp": "webp"}.get(content_type, "bin")
    return f"buildings/{building_id}/{uuid.uuid4()}.{ext}"


def presign_put(key: str, content_type: str, expires: int = 900) -> str:
    """Presigned PUT URL the client uploads to directly."""
    return _client().generate_presigned_url(
        "put_object",
        Params={
            "Bucket": settings.AWS_STORAGE_BUCKET_NAME,
            "Key": key,
            "ContentType": content_type,
        },
        ExpiresIn=expires,
    )


def presign_get(key: str, expires: int = 3600) -> str:
    """Presigned GET URL for reading a stored object (thumbnails, previews)."""
    return _client().generate_presigned_url(
        "get_object",
        Params={"Bucket": settings.AWS_STORAGE_BUCKET_NAME, "Key": key},
        ExpiresIn=expires,
    )
