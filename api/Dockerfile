FROM python:3.12-slim

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1

# GeoDjango needs GDAL/GEOS/PROJ; postgresql-client for entrypoint waits & pg_dump.
RUN apt-get update && apt-get install -y --no-install-recommends \
        binutils \
        gdal-bin \
        libgdal-dev \
        libgeos-dev \
        libproj-dev \
        postgresql-client \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install deps first for layer caching. Dev deps included so the same image runs tests in CI.
COPY requirements.txt requirements-dev.txt ./
ARG INSTALL_DEV=true
RUN if [ "$INSTALL_DEV" = "true" ]; then \
        pip install -r requirements-dev.txt; \
    else \
        pip install -r requirements.txt; \
    fi

COPY . .

EXPOSE 8000

CMD ["gunicorn", "keja.wsgi:application", "--bind", "0.0.0.0:8000", "--workers", "3"]
