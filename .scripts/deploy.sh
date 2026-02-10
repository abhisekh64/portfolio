#!/bin/bash

set -e

APP_DIR="/home/ec2-user/projects/portfolio"
GIT_BRANCH="main"
GITHUB_PAT="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"   # 🔴 replace
GITHUB_REPO="github.com/username/repo.git"

echo "🚀 Starting Deployment..."

cd $APP_DIR || exit 1

echo "🔐 Setting Git remote with PAT"
git remote set-url origin https://${GITHUB_PAT}@${GITHUB_REPO}

echo "⬇️ Pulling latest code"
git pull origin $GIT_BRANCH

if [ ! -f "requirements.txt" ]; then
  echo "❌ requirements.txt not found!"
  exit 1
fi

echo "🐳 Building Docker images"
docker compose build

echo "🧹 Stopping old containers"
docker compose down

echo "🚀 Starting containers"
docker compose up -d

echo "📦 Running migrations"
docker exec portfolio_dev python manage.py migrate --noinput

echo "🎨 Collecting static files"
docker exec portfolio_dev python manage.py collectstatic --noinput

echo "✅ Deployment Finished Successfully"
