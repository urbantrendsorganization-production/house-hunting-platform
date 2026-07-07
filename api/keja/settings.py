"""Django settings for Keja.

Config is env-driven (django-environ). No secrets live in this file or in the
repo — see .env.example for the shape of the environment.
"""

from pathlib import Path

import environ

BASE_DIR = Path(__file__).resolve().parent.parent

env = environ.Env(
    DEBUG=(bool, False),
    ALLOWED_HOSTS=(list, ["*"]),
)

# Load a local .env if present (dev convenience). In containers the env is
# injected directly, so this is a no-op there.
env_file = BASE_DIR / ".env"
if env_file.exists():
    env.read_env(str(env_file))

SECRET_KEY = env("DJANGO_SECRET_KEY", default="dev-insecure-change-me")
DEBUG = env("DEBUG")
ALLOWED_HOSTS = env("ALLOWED_HOSTS")

INSTALLED_APPS = [
    "django.contrib.admin",
    "django.contrib.auth",
    "django.contrib.contenttypes",
    "django.contrib.sessions",
    "django.contrib.messages",
    "django.contrib.staticfiles",
    # Geo
    "django.contrib.gis",
    # Third-party
    "rest_framework",
    # Local
    "core",
]

MIDDLEWARE = [
    "django.middleware.security.SecurityMiddleware",
    "django.contrib.sessions.middleware.SessionMiddleware",
    "django.middleware.common.CommonMiddleware",
    "django.middleware.csrf.CsrfViewMiddleware",
    "django.contrib.auth.middleware.AuthenticationMiddleware",
    "django.contrib.messages.middleware.MessageMiddleware",
    "django.middleware.clickjacking.XFrameOptionsMiddleware",
]

ROOT_URLCONF = "keja.urls"

TEMPLATES = [
    {
        "BACKEND": "django.template.backends.django.DjangoTemplates",
        "DIRS": [],
        "APP_DIRS": True,
        "OPTIONS": {
            "context_processors": [
                "django.template.context_processors.request",
                "django.contrib.auth.context_processors.auth",
                "django.contrib.messages.context_processors.messages",
            ],
        },
    },
]

WSGI_APPLICATION = "keja.wsgi.application"
ASGI_APPLICATION = "keja.asgi.application"

# --- Database (PostGIS) ---
DATABASES = {
    "default": {
        **env.db("DATABASE_URL", default="postgis://keja:keja@db:5432/keja"),
        "ENGINE": "django.contrib.gis.db.backends.postgis",
    }
}

# --- Cache / Celery (Redis) ---
REDIS_URL = env("REDIS_URL", default="redis://redis:6379/0")
CACHES = {
    "default": {
        "BACKEND": "django.core.cache.backends.redis.RedisCache",
        "LOCATION": REDIS_URL,
    }
}
CELERY_BROKER_URL = env("CELERY_BROKER_URL", default=REDIS_URL)
CELERY_RESULT_BACKEND = env("CELERY_RESULT_BACKEND", default=REDIS_URL)
CELERY_TASK_ALWAYS_EAGER = env.bool("CELERY_TASK_ALWAYS_EAGER", default=False)

# --- Object storage (S3-compatible / minio) ---
AWS_S3_ENDPOINT_URL = env("AWS_S3_ENDPOINT_URL", default="http://minio:9000")
AWS_ACCESS_KEY_ID = env("AWS_ACCESS_KEY_ID", default="minio")
AWS_SECRET_ACCESS_KEY = env("AWS_SECRET_ACCESS_KEY", default="minio12345")
AWS_STORAGE_BUCKET_NAME = env("AWS_STORAGE_BUCKET_NAME", default="keja-media")
AWS_S3_REGION_NAME = env("AWS_S3_REGION_NAME", default="us-east-1")

AUTH_PASSWORD_VALIDATORS = [
    {"NAME": "django.contrib.auth.password_validation.UserAttributeSimilarityValidator"},
    {"NAME": "django.contrib.auth.password_validation.MinimumLengthValidator"},
    {"NAME": "django.contrib.auth.password_validation.CommonPasswordValidator"},
    {"NAME": "django.contrib.auth.password_validation.NumericPasswordValidator"},
]

REST_FRAMEWORK = {
    "DEFAULT_RENDERER_CLASSES": ["rest_framework.renderers.JSONRenderer"],
    "DEFAULT_PERMISSION_CLASSES": ["rest_framework.permissions.AllowAny"],
    "DEFAULT_THROTTLE_RATES": {
        # Anonymous consumer map browsing — generous but bounded.
        "viewport": env("VIEWPORT_THROTTLE_RATE", default="120/min"),
    },
}

# --- Consumer map API (Phase 3) ---
MAP_MAX_MARKERS = env.int("MAP_MAX_MARKERS", default=200)
MAP_CLUSTER_ZOOM_THRESHOLD = env.int("MAP_CLUSTER_ZOOM_THRESHOLD", default=15)
# Grid cell (degrees) at the cluster threshold zoom; coarser as you zoom out.
MAP_CLUSTER_BASE_CELL_DEG = env.float("MAP_CLUSTER_BASE_CELL_DEG", default=0.002)
MAP_MAX_BBOX_AREA_DEG2 = env.float("MAP_MAX_BBOX_AREA_DEG2", default=0.25)
MAP_MAX_RADIUS_KM = env.float("MAP_MAX_RADIUS_KM", default=10.0)
VIEWPORT_CACHE_TTL = env.int("VIEWPORT_CACHE_TTL", default=60)

LANGUAGE_CODE = "en-us"
TIME_ZONE = "Africa/Nairobi"
USE_I18N = True
USE_TZ = True

STATIC_URL = "static/"
STATIC_ROOT = BASE_DIR / "staticfiles"

DEFAULT_AUTO_FIELD = "django.db.models.BigAutoField"

# --- Freshness rules (CLAUDE.md) ---
VACANCY_DEMOTE_DAYS = env.int("VACANCY_DEMOTE_DAYS", default=14)
VACANCY_HIDE_DAYS = env.int("VACANCY_HIDE_DAYS", default=30)

# --- Production hardening (Phase 7) ---
# Behind Caddy, TLS terminates at the proxy and requests arrive over HTTP with
# X-Forwarded-Proto set — trust it so Django knows the original scheme.
SECURE_PROXY_SSL_HEADER = ("HTTP_X_FORWARDED_PROTO", "https")

if not DEBUG:
    # These only bite in real deployments; local dev (DEBUG=true) is unaffected.
    SECURE_SSL_REDIRECT = env.bool("SECURE_SSL_REDIRECT", default=True)
    SESSION_COOKIE_SECURE = True
    CSRF_COOKIE_SECURE = True
    SECURE_HSTS_SECONDS = env.int("SECURE_HSTS_SECONDS", default=60 * 60 * 24 * 30)
    SECURE_HSTS_INCLUDE_SUBDOMAINS = True
    SECURE_HSTS_PRELOAD = True
    SECURE_CONTENT_TYPE_NOSNIFF = True
    # Caddy needs the API's public origin(s) for CSRF on the admin/back office.
    CSRF_TRUSTED_ORIGINS = env.list("CSRF_TRUSTED_ORIGINS", default=[])

# Requests slower than this (ms) are logged as a slow-query warning. 0 disables.
SLOW_REQUEST_MS = env.int("SLOW_REQUEST_MS", default=500)
MIDDLEWARE.insert(0, "core.middleware.SlowRequestLoggerMiddleware")

LOGGING = {
    "version": 1,
    "disable_existing_loggers": False,
    "formatters": {
        "verbose": {"format": "%(asctime)s %(levelname)s %(name)s %(message)s"},
    },
    "handlers": {
        "console": {"class": "logging.StreamHandler", "formatter": "verbose"},
    },
    "root": {"handlers": ["console"], "level": env("LOG_LEVEL", default="INFO")},
    "loggers": {
        # Slow requests + optional SQL logging for pilot-scale profiling.
        "keja.slow": {"handlers": ["console"], "level": "WARNING", "propagate": False},
        "django.db.backends": {
            "handlers": ["console"],
            "level": env("DB_LOG_LEVEL", default="WARNING"),
            "propagate": False,
        },
    },
}

# --- Error monitoring (Sentry / self-hosted GlitchTip) ---
# Fully optional: with no DSN the SDK is never imported, so it's a no-op locally
# and in CI. Point SENTRY_DSN at Sentry or a self-hosted GlitchTip in prod.
SENTRY_DSN = env("SENTRY_DSN", default="")
if SENTRY_DSN:
    import sentry_sdk
    from sentry_sdk.integrations.celery import CeleryIntegration
    from sentry_sdk.integrations.django import DjangoIntegration

    sentry_sdk.init(
        dsn=SENTRY_DSN,
        integrations=[DjangoIntegration(), CeleryIntegration()],
        environment=env("SENTRY_ENVIRONMENT", default="production"),
        traces_sample_rate=env.float("SENTRY_TRACES_SAMPLE_RATE", default=0.0),
        send_default_pii=False,
    )
