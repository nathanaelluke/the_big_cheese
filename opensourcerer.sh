#!/bin/bash

# Configuration
NUM_REPOS=5
BASE_NAME="open-sourcerer-cheese"

if ! gh auth status >/dev/null 2>&1; then
    echo "❌ Error: GitHub CLI is not authenticated."
    exit 1
fi

echo "🧙 Starting Open Sourcerer grind across $NUM_REPOS repositories..."

# Store the current directory to return to it later
START_DIR=$(pwd)

for ((i=1; i<=NUM_REPOS; i++)); do
    REPO_NAME="${BASE_NAME}-$i"
    echo "------------------------------------------------"
    echo "🚀 Processing Repository $i ($REPO_NAME)..."

    # 1. Create a public repository and clone it locally
    # This uses gh's internal auth so it won't ask for a password
    echo "Creating and cloning public repository..."
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    
    gh repo create "$REPO_NAME" --public --confirm --clone > /dev/null 2>&1
    
    if [ ! -d "$REPO_NAME" ]; then
        echo "⚠️ Failed to clone. Checking if it already exists..."
        gh repo clone "$REPO_NAME" > /dev/null 2>&1
    fi

    if [ ! -d "$REPO_NAME" ]; then
         echo "❌ Could not access repository $REPO_NAME. Skipping..."
         cd "$START_DIR"
         continue
    fi

    cd "$REPO_NAME"

    # 2. Create initial content
    echo "# $REPO_NAME" > README.md
    git add README.md
    git commit -m "Initial commit" > /dev/null
    git push origin main > /dev/null 2>&1

    # 3. Create a branch and a PR
    BRANCH_NAME="contribution-branch"
    git checkout -b "$BRANCH_NAME" > /dev/null
    echo "Contributing to $REPO_NAME" >> README.md
    git add README.md
    git commit -m "feat: contribution for open sourcerer" > /dev/null
    git push origin "$BRANCH_NAME" > /dev/null 2>&1

    # 4. Create and Merge PR
    echo "Creating and merging PR..."
    gh pr create --title "Open Sourcerer contribution" --body "Contributing across multiple repos" --base main --head "$BRANCH_NAME" > /dev/null
    sleep 3
    gh pr merge "$BRANCH_NAME" --merge --delete-branch > /dev/null

    echo "✅ PR merged in $REPO_NAME!"
    
    # Cleanup local temp dir
    cd "$START_DIR"
    rm -rf "$TEMP_DIR"
    
    echo "💤 Sleeping for 5 seconds to avoid rate limits..."
    sleep 5
done

echo "🎉 Open Sourcerer grind complete!"
