#!/bin/bash

MAIN_BRANCH="main"
BRANCH_NAME="yolo-cheese-branch"

# Check if GitHub CLI is authenticated
if ! gh auth status >/dev/null 2>&1; then
    echo "❌ Error: GitHub CLI is not authenticated. Please run 'gh auth login' first."
    exit 1
fi

echo "🚀 Securing the YOLO badge..."

# Ensure we are on the main branch and up to date
git checkout "$MAIN_BRANCH"
git pull origin "$MAIN_BRANCH"

# 1. Create and switch to a new branch
git checkout -b "$BRANCH_NAME"

# 2. Make an empty commit
git commit --allow-empty -m "chore: yolo badge cheese"

# 3. Push the branch to GitHub
git push origin "$BRANCH_NAME"

# 4. Create the Pull Request using GitHub CLI
gh pr create --title "YOLO Badge PR" --body "Merging without review!" --base "$MAIN_BRANCH" --head "$BRANCH_NAME"

# Pause to let GitHub process the PR
sleep 3

# 5. Merge the PR immediately (This is what triggers the badge)
gh pr merge "$BRANCH_NAME" --merge --delete-branch

# 6. Switch back to main, pull, and clean up local branch
git checkout "$MAIN_BRANCH"
git pull origin "$MAIN_BRANCH"
git branch -d "$BRANCH_NAME"

echo "✅ YOLO achieved! Check your GitHub profile."
