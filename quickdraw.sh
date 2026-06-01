#!/bin/bash

if ! gh auth status >/dev/null 2>&1; then
    echo " error: github cli is not authenticated."
    exit 1
fi

echo " securing the quickdraw badge..."

echo "creating issue..."
ISSUE_URL=$(gh issue create --title "quickdraw badge cheese" --body "this issue exists only to be closed instantly.")

if [ -z "$ISSUE_URL" ]; then
    echo " failed to create issue."
    exit 1
fi

echo " issue created: $ISSUE_URL"
sleep 2

echo "closing issue immediately..."
gh issue close "$ISSUE_URL" --reason "not planned"

echo " quickdraw achieved!"
