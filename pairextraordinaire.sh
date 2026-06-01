#!/bin/bash

# Configuration
TARGET_PRS=48
MAIN_BRANCH="main"

if ! gh auth status >/dev/null 2>&1; then
    echo "❌ Error: GitHub CLI is not authenticated."
    exit 1
fi

echo "👯 Generating $TARGET_PRS co-authored PRs for Pair Extraordinaire Gold..."

git checkout "$MAIN_BRANCH"
git pull origin "$MAIN_BRANCH"

for ((i=1; i<=TARGET_PRS; i++)); do
    BRANCH_NAME="pair-cheese-$i"

    echo "------------------------------------------------"
    echo "🚀 Processing Pair Extraordinaire PR $i of $TARGET_PRS..."

    git checkout -b "$BRANCH_NAME"
    
    # Using a REAL file change instead of --allow-empty to be safer
    echo "Pair Cheese $i: $(date +%s)" > PAIR_CHEESE.txt
    git add PAIR_CHEESE.txt
    
    git commit \
        -m "chore: pair extraordinaire cheese $i" \
        -m "" \
        -m "Co-authored-by: orthogonalmind <carrot-seer.6g@icloud.com>"

    git push origin "$BRANCH_NAME"

    gh pr create --title "Pair Extraordinaire PR $i" --body "Grinding the Pair Extraordinaire badge" --base "$MAIN_BRANCH" --head "$BRANCH_NAME"

    sleep 3

    gh pr merge "$BRANCH_NAME" --merge --delete-branch

    git checkout "$MAIN_BRANCH"
    git pull origin "$MAIN_BRANCH"
    git branch -d "$BRANCH_NAME"

    echo "✅ PR $i merged successfully!"
    sleep 5
done

echo "🎉 Pair Extraordinaire Gold complete!"
