#!/bin/bash

# Exit immediately if any command fails
set -e

# Get the current branch name
current_branch=$(git rev-parse --abbrev-ref HEAD)
updated_branch=latest

echo "🔍 Current branch: $current_branch"

# Step 1: Save (stash) any uncommitted work safely
echo "💾 Stashing local changes..."
git stash push -m "Auto-stash before syncing with remote" || true

# Step 2: Fetch latest changes from remote
echo "⬇️ Fetching latest updates from origin..."
git fetch origin

# Step 3: Rebase current branch with its updated counterpart
echo "🔄 Rebasing $current_branch with origin/$updated_branch..."
git pull --rebase origin "$updated_branch"

# Step 4: Restore the .env.example file to the repository version
echo "🧹 Resetting .env.example to committed version..."
git checkout -- .env.env
git checkout -- .gitignore

# Step 5: Reapply your stashed changes (if any)
echo "♻️ Reapplying local stashed changes (if any)..."
git stash pop || echo "✅ No stashed changes to reapply."

# Step 6: Push your branch to remote
echo "🚀 Pushing $current_branch to origin..."
git push -u origin "$current_branch"

# Step 6: Update .env file
echo "♻️ Updating .env file..."
cp ./.env.env ./.env

# Step 7: Generate prisma files and deploy migration
echo "♻️ Generating Prisma client files..."
npm run db:generate
npm run db:deploy

# Step 8: Start Evolution API
echo "⬇️ Starting Evolution API..."
npm run build
npm run start:prod

echo "✅ Version update complete!"