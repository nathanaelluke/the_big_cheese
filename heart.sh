#!/bin/bash

# Configuration
REPO_FULL=$(gh repo view --json nameWithOwner -q .nameWithOwner)

if [ -z "$REPO_FULL" ]; then
    echo "❌ Error: Could not determine current repository. Are you in a git repo?"
    exit 1
fi

echo "❤️ Securing the Heart On Your Sleeve badge..."

# 1. Create a dummy issue
echo "Creating a temporary issue..."
ISSUE_URL=$(gh issue create --title "Heart Reaction Cheese" --body "This issue is for the Heart On Your Sleeve badge.")
ISSUE_NUMBER=$(echo "$ISSUE_URL" | grep -oE '[0-9]+$')

if [ -z "$ISSUE_NUMBER" ]; then
    echo "❌ Failed to create issue."
    exit 1
fi

echo "✅ Issue #$ISSUE_NUMBER created."
sleep 2

# 2. Add the Heart reaction
echo "Adding Heart reaction..."
gh api --method POST \
  -H "Accept: application/vnd.github+json" \
  "/repos/$REPO_FULL/issues/$ISSUE_NUMBER/reactions" \
  -f content='heart' > /dev/null

if [ $? -eq 0 ]; then
    echo "✅ Heart reaction added!"
else
    echo "❌ Failed to add reaction."
fi

sleep 2

# 3. Close the issue
echo "Closing temporary issue..."
gh issue close "$ISSUE_NUMBER" --reason "completed"

echo "🎉 Heart On Your Sleeve attempt complete! (Note: This badge is experimental and may not appear immediately)"
