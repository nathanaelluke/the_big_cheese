#!/bin/bash

MAIN_BRANCH="main"
BRANCH_NAME="yolo-cheese-branch-$(date +%s)"

if ! gh auth status >/dev/null 2>&1; then
    echo "❌ Error: GitHub CLI is not authenticated."
    exit 1
fi

echo "🚀 Securing the YOLO badge..."

git checkout "$MAIN_BRANCH"
git pull origin "$MAIN_BRANCH"

git checkout -b "$BRANCH_NAME"
git commit --allow-empty -m "chore: yolo badge cheese"
git push origin "$BRANCH_NAME"

echo "Creating Pull Request..."
gh pr create \
    --title "YOLO Badge PR" \
    --body "Merging without review to trigger YOLO!" \
    --base "$MAIN_BRANCH" \
    --head "$BRANCH_NAME"

sleep 3

echo "Merging immediately..."
gh pr merge "$BRANCH_NAME" --merge --delete-branch

git checkout "$MAIN_BRANCH"
git pull origin "$MAIN_BRANCH"
git branch -d "$BRANCH_NAME"

echo "✅ YOLO achieved!"
