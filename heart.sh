#!/bin/bash

REPO_FULL=$(gh repo view --json nameWithOwner -q .nameWithOwner)

if [ -z "$REPO_FULL" ]; then
    echo "error: could not determine current repository. are you in a git repo?"
    exit 1
fi

echo " heart on your sleeve badge"

echo "creating a temporary issue..."
ISSUE_URL=$(gh issue create --title "heart reaction cheese" --body "this issue is for the heart on your sleeve badge.")
ISSUE_NUMBER=$(echo "$ISSUE_URL" | grep -oE '[0-9]+$')

if [ -z "$ISSUE_NUMBER" ]; then
    echo "failed to create issue."
    exit 1
fi

echo " issue #$ISSUE_NUMBER created."
sleep 2

echo "adding heart reaction..."
gh api --method POST \
  -H "Accept: application/vnd.github+json" \
  "/repos/$REPO_FULL/issues/$ISSUE_NUMBER/reactions" \
  -f content='heart' > /dev/null

if [ $? -eq 0 ]; then
    echo " heart reaction added!"
else
    echo " failed to add reaction."
fi

sleep 2

echo "closing temporary issue..."
gh issue close "$ISSUE_NUMBER" --reason "completed"

echo " heart on your sleeve attempt complete! (note: this badge is experimental and may not appear immediately)"
