#!/usr/bin/env bash

set -e

SOURCE_BRANCH=latest
TARGET_BRANCH=main

echo "♻️ Duplicating .env file..."
cp ./.env ./.env-org

echo "==> Fetching remote branches..."
git fetch --all

echo "==> Checking out target branch: $TARGET_BRANCH"
git checkout "$TARGET_BRANCH"

echo "==> Pulling latest changes..."
git pull origin "$TARGET_BRANCH"

echo "==> Merging source branch: $SOURCE_BRANCH"
git merge --no-commit --no-ff "$SOURCE_BRANCH"

echo "🧹 Resetting .gitignore to remote version..."
git checkout -- .gitignore

echo "==> Committing merge..."
git commit -m "Merge branch '$SOURCE_BRANCH' into '$TARGET_BRANCH'"

echo "==> Pushing..."
git push origin "$TARGET_BRANCH"

echo "♻️ Updating .env file..."
cp ./.env-org ./.env

echo "♻️ Generating Prisma client files..."
npm run db:generate
npm run db:deploy

echo "⬇️ Starting Evolution API..."
npm install -f
npm run build
npm run start:prod

echo "✅ Version update complete!"