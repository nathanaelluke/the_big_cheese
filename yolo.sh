#!/bin/bash

MAIN_BRANCH="main"
BRANCH_NAME="yolo-cheese-branch-$(date +%s)"

if ! gh auth status >/dev/null 2>&1; then
    echo " error: github cli is not authenticated."
    exit 1
fi

echo " securing the yolo badge..."

git checkout "$MAIN_BRANCH"
git pull origin "$MAIN_BRANCH"

git checkout -b "$BRANCH_NAME"
git commit --allow-empty -m "chore: yolo badge cheese"
git push origin "$BRANCH_NAME"

echo "creating pull request..."
gh pr create \
    --title "yolo badge pr" \
    --body "merging without review to trigger yolo!" \
    --base "$MAIN_BRANCH" \
    --head "$BRANCH_NAME"

sleep 3

echo "merging immediately..."
gh pr merge "$BRANCH_NAME" --merge --delete-branch

git checkout "$MAIN_BRANCH"
git pull origin "$MAIN_BRANCH"
git branch -d "$BRANCH_NAME"

echo " yolo achieved!"
