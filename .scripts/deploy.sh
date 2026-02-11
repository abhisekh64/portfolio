#!/bin/bash
set -e  # Exit on any error

# -----------------------------
# CONFIGURATION
# -----------------------------
REQUIREMENTS_FILE="requirements.txt"
DOCKER_COMPOSE_FILE="docker-compose.yml"

# -----------------------------
# CHECK REQUIREMENTS FILE
# -----------------------------
if [ ! -f "$REQUIREMENTS_FILE" ]; then
    echo "❌ ERROR: $REQUIREMENTS_FILE not found! Cannot proceed."
    exit 1
else
    echo "📄 Found $REQUIREMENTS_FILE. Installing packages..."
fi

# -----------------------------
# INSTALL PACKAGES LOCALLY
# -----------------------------
echo "💻 Installing Python packages locally..."
pip install -r $REQUIREMENTS_FILE --no-input

# -----------------------------
# DOCKER: Build and Run
# -----------------------------
if [ -f "$DOCKER_COMPOSE_FILE" ]; then
    echo "🐳 Building and running Docker containers..."
    docker-compose -f $DOCKER_COMPOSE_FILE build
    docker-compose -f $DOCKER_COMPOSE_FILE up -d

    echo "📦 Running Django migrations..."
    docker-compose exec web python manage.py migrate

    echo "📂 Collecting static files inside Docker..."
    docker-compose exec web python manage.py collectstatic --noinput

    echo "🧪 Running Django tests..."
    docker-compose exec web python manage.py test
else
    echo "⚠️  Docker compose file not found. Skipping Docker steps."
fi

echo "✅ Script completed successfully!"
