#!/bin/bash

NUM_REPOS=5
BASE_NAME="open-sourcerer-cheese"

if ! gh auth status >/dev/null 2>&1; then
    echo " error: github cli is not authenticated."
    exit 1
fi

echo " starting open sourcerer grind across $NUM_REPOS repositories..."

START_DIR=$(pwd)

for ((i=1; i<=NUM_REPOS; i++)); do
    REPO_NAME="${BASE_NAME}-$i"
    echo "------------------------------------------------"
    echo " processing repository $i ($REPO_NAME)..."

    echo "creating and cloning public repository..."
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    
    gh repo create "$REPO_NAME" --public --confirm --clone > /dev/null 2>&1
    
    if [ ! -d "$REPO_NAME" ]; then
        echo " failed to clone. checking if it already exists..."
        gh repo clone "$REPO_NAME" > /dev/null 2>&1
    fi

    if [ ! -d "$REPO_NAME" ]; then
         echo " could not access repository $REPO_NAME. skipping..."
         cd "$START_DIR"
         continue
    fi

    cd "$REPO_NAME"

    echo "# $REPO_NAME" > README.md
    git add README.md
    git commit -m "initial commit" > /dev/null
    git push origin main > /dev/null 2>&1

    BRANCH_NAME="contribution-branch"
    git checkout -b "$BRANCH_NAME" > /dev/null
    echo "contributing to $REPO_NAME" >> README.md
    git add README.md
    git commit -m "feat: contribution for open sourcerer" > /dev/null
    git push origin "$BRANCH_NAME" > /dev/null 2>&1

    echo "creating and merging pr..."
    gh pr create --title "open sourcerer contribution" --body "contributing across multiple repos" --base main --head "$BRANCH_NAME" > /dev/null
    sleep 3
    gh pr merge "$BRANCH_NAME" --merge --delete-branch > /dev/null

    echo " pr merged in $REPO_NAME!"
    
    cd "$START_DIR"
    rm -rf "$TEMP_DIR"
    
    echo " sleeping for 5 seconds to avoid rate limits..."
    sleep 5
done

echo " open sourcerer grind complete!"
