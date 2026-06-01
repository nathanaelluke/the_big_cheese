#!/bin/bash

# Configuration
# Targeting 128 for Silver or 1024 for Gold
TARGET_PRS=128 
MAIN_BRANCH="main"

if ! gh auth status >/dev/null 2>&1; then
    echo "❌ Error: GitHub CLI is not authenticated."
    exit 1
fi

echo "🦈 Starting the Pull Shark grind for $TARGET_PRS PRs..."

git checkout "$MAIN_BRANCH"
git pull origin "$MAIN_BRANCH"

for ((i=1; i<=TARGET_PRS; i++)); do
    BRANCH_NAME="pull-shark-cheese-$i"

    echo "------------------------------------------------"
    echo "🚀 Processing PR $i of $TARGET_PRS..."
    
    git checkout -b "$BRANCH_NAME"
    
    # Using a REAL file change instead of --allow-empty
    echo "Shark Cheese $i: $(date +%s)" > SHARK_CHEESE.txt
    git add SHARK_CHEESE.txt
    
    git commit -m "chore: pull shark cheese commit $i"
    git push origin "$BRANCH_NAME"

    gh pr create --title "Pull Shark PR $i" --body "Grinding the Pull Shark badge" --base "$MAIN_BRANCH" --head "$BRANCH_NAME"

    sleep 3

    gh pr merge "$BRANCH_NAME" --merge --delete-branch

    git checkout "$MAIN_BRANCH"
    git pull origin "$MAIN_BRANCH"
    git branch -d "$BRANCH_NAME"

    echo "✅ PR $i merged successfully!"
    sleep 5
done

echo "🎉 Pull Shark Silver complete!"
