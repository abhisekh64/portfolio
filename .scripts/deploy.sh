#!/bin/bash
set -e  # Exit immediately on error
set -o pipefail  # Fail if any command in a pipe fails

# -----------------------------
# CONFIGURATION
# -----------------------------
REQUIREMENTS_FILE="requirements.txt"
DOCKER_COMPOSE_FILE="docker-compose.yml"
WEB_SERVICE_NAME="web"   # Name of the service in docker-compose.yml
LOG_PREFIX="[DEPLOY]"

# -----------------------------
# FUNCTIONS
# -----------------------------
log() {
    echo -e "\033[1;34m$LOG_PREFIX\033[0m $1"
}

error_exit() {
    echo -e "\033[1;31m$LOG_PREFIX ERROR:\033[0m $1"
    exit 1
}

check_file_exists() {
    if [ ! -f "$1" ]; then
        error_exit "$1 not found!"
    fi
}

docker_compose_up() {
    log "Building and starting Docker containers..."
    docker-compose -f $DOCKER_COMPOSE_FILE build
    docker-compose -f $DOCKER_COMPOSE_FILE up -d
}

docker_exec() {
    local CMD="$1"
    docker-compose exec $WEB_SERVICE_NAME bash -c "$CMD"
}


# -----------------------------
# MAIN FLOW
# -----------------------------
log "Starting deployment script..."

# 1️⃣ Check requirements
check_file_exists $REQUIREMENTS_FILE

# 2️⃣ Check docker-compose
check_file_exists $DOCKER_COMPOSE_FILE

# 3️⃣ Build and run containers
docker_compose_up

# 4️⃣ Install Python packages inside container (only if requirements changed)
log "Installing Python packages inside container..."
docker_exec "python3 -m pip install --upgrade pip"
docker_exec "python3 -m pip install -r $REQUIREMENTS_FILE"

# 5️⃣ Run Django migrations
log "Running Django migrations..."
docker_exec "python3 manage.py migrate --noinput"

# 6️⃣ Collect static files
log "Collecting static files..."
docker_exec "python3 manage.py collectstatic --noinput"

# 7️⃣ Run tests
log "Running Django tests..."
docker_exec "python3 manage.py test"

log "✅ Deployment completed successfully!"
