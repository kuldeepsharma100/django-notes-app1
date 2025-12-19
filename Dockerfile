
# syntax=docker/dockerfile:1
FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# System deps for mysqlclient (and basic build tools)
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       gcc \
       default-libmysqlclient-dev \
       pkg-config \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app/backend

# Install Python deps
COPY requirements.txt /app/backend/
RUN pip install --no-cache-dir -r requirements.txt \
    && pip install --no-cache-dir gunicorn

# Copy application code
COPY . /app/backend

# Optional: add an entrypoint to run migrations & collectstatic before starting
COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8000

# Run entrypoint (does migrations/collectstatic) and then start Gunicorn
ENTRYPOINT ["/entrypoint.sh"]
CMD ["gunicorn", "notes_app.wsgi:application", "--bind", "0.0.0.0:8000", "--workers", "3", "--timeout", "120"]

