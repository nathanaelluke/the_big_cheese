#!/bin/bash

# Configuration
# Change this number to however many PRs you need (up to 1024 for the max tier)
TARGET_PRS=1024 
MAIN_BRANCH="main"

# Check if GitHub CLI is authenticated
if ! gh auth status >/dev/null 2>&1; then
    echo "❌ Error: GitHub CLI is not authenticated. Please run 'gh auth login' first."
    exit 1
fi

echo "🦈 Starting the Pull Shark grind for $TARGET_PRS PRs..."

# Ensure we are on the main branch and up to date
git checkout "$MAIN_BRANCH"
git pull origin "$MAIN_BRANCH"

for ((i=1; i<=TARGET_PRS; i++)); do
    BRANCH_NAME="pull-shark-cheese-$i"

    echo "------------------------------------------------"
    echo "🚀 Processing PR $i of $TARGET_PRS..."
    
    # 1. Create and switch to a new branch
    git checkout -b "$BRANCH_NAME"

    # 2. Make an empty commit (no need to actually change files)
    git commit --allow-empty -m "chore: pull shark cheese commit $i"

    # 3. Push the branch to GitHub
    git push origin "$BRANCH_NAME"

    # 4. Create the Pull Request using GitHub CLI
    gh pr create --title "Pull Shark PR $i" --body "Grinding the Pull Shark badge" --base "$MAIN_BRANCH" --head "$BRANCH_NAME"

    # Brief pause to let GitHub's backend process the PR creation
    sleep 3

    # 5. Merge the PR and delete the remote branch to keep the repo clean
    gh pr merge "$BRANCH_NAME" --merge --delete-branch

    # 6. Switch back to main and pull the newly merged changes
    git checkout "$MAIN_BRANCH"
    git pull origin "$MAIN_BRANCH"

    # 7. Delete the local branch
    git branch -d "$BRANCH_NAME"

    echo "✅ PR $i merged successfully!"
    
    # CRITICAL: Sleep to avoid triggering GitHub's API abuse detection
    echo "💤 Sleeping for 5 seconds to respect API limits..."
    sleep 5
done

echo "🎉 All done! Go check your GitHub profile."
