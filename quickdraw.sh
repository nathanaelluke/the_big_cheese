#!/bin/bash

# Check if GitHub CLI is authenticated
if ! gh auth status >/dev/null 2>&1; then
    echo "❌ Error: GitHub CLI is not authenticated. Please run 'gh auth login' first."
    exit 1
fi

echo "🔫 Fastest closer in the West. Getting Quickdraw..."

# 1. Create the issue and capture its URL
echo "Creating issue..."
ISSUE_URL=$(gh issue create --title "Quickdraw Badge Cheese" --body "This issue exists only to be closed instantly.")

if [ -z "$ISSUE_URL" ]; then
    echo "❌ Failed to create issue. Make sure you are in a GitHub repository."
    exit 1
fi

echo "✅ Issue created: $ISSUE_URL"

# Brief pause to ensure GitHub's database registers the open issue
sleep 2

# 2. Close the issue immediately
echo "Closing issue..."
gh issue close "$ISSUE_URL" --reason "not planned"

echo "🎉 Quickdraw achieved! Check your GitHub profile."
