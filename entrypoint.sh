#!/bin/sh

# Wait for PostgreSQL
until nc -z db 5432; do
  echo "Waiting for PostgreSQL..."
  sleep 1
done

echo "PostgreSQL is up. Running migrations..."

# Run migrations and collect static files
python manage.py migrate
python manage.py collectstatic --noinput || true

# Start Django dev server
python manage.py runserver 0.0.0.0:8000
