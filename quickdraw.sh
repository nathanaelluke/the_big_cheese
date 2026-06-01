#!/bin/bash

if ! gh auth status >/dev/null 2>&1; then
    echo "❌ Error: GitHub CLI is not authenticated."
    exit 1
fi

echo "🔫 Securing the Quickdraw badge..."

echo "Creating issue..."
ISSUE_URL=$(gh issue create --title "Quickdraw Badge Cheese" --body "This issue exists only to be closed instantly.")

if [ -z "$ISSUE_URL" ]; then
    echo "❌ Failed to create issue."
    exit 1
fi

echo "✅ Issue created: $ISSUE_URL"
sleep 2

echo "Closing issue immediately..."
gh issue close "$ISSUE_URL" --reason "not planned"

echo "🎉 Quickdraw achieved!"
