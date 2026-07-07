from django.db import connection
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.request import Request
from rest_framework.response import Response


@api_view(["GET"])
@permission_classes([AllowAny])
def health(request: Request) -> Response:
    """Liveness + DB reachability. Also confirms PostGIS is installed."""
    db_ok = True
    postgis_version = None
    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT PostGIS_Lib_Version();")
            row = cursor.fetchone()
            postgis_version = row[0] if row else None
    except Exception:  # pragma: no cover - reported via db_ok
        db_ok = False

    status_code = 200 if db_ok else 503
    return Response(
        {
            "status": "ok" if db_ok else "degraded",
            "db": db_ok,
            "postgis": postgis_version,
        },
        status=status_code,
    )
