import os

from celery import Celery

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "keja.settings")

app = Celery("keja")
app.config_from_object("django.conf:settings", namespace="CELERY")
app.autodiscover_tasks()

# Freshness rules are enforced hourly even without new captures (CLAUDE.md).
app.conf.beat_schedule = {
    "sweep-staleness-hourly": {
        "task": "core.sweep_staleness",
        "schedule": 60 * 60,
    },
}
