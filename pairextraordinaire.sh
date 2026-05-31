#!/bin/bash

# Configuration
TARGET_COMMITS=48
MAIN_BRANCH="main"
BRANCH_NAME="pair-cheese-branch"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "❌ Error: Not inside a git repository."
    exit 1
fi

echo "👯 Generating $TARGET_COMMITS co-authored commits..."

git checkout "$MAIN_BRANCH"
git pull origin "$MAIN_BRANCH"

# 1. Create a dedicated branch for the PR
git checkout -b "$BRANCH_NAME"

# 2. Generate the commits locally
for ((i=1; i<=TARGET_COMMITS; i++)); do
    echo "Writing commit $i of $TARGET_COMMITS..."
    git commit --allow-empty \
        -m "chore: pair extraordinaire cheese $i" \
        -m "" \
        -m "Co-authored-by: octocat <octocat@users.noreply.github.com>"
done

# 3. Push the branch
echo "⬆️ Pushing branch to GitHub..."
git push origin "$BRANCH_NAME"

# 4. Open the Pull Request
echo "Creating Pull Request..."
gh pr create \
    --title "Pair Extraordinaire Cheese" \
    --body "Merging 48 co-authored commits at once." \
    --base "$MAIN_BRANCH" \
    --head "$BRANCH_NAME"

sleep 4

# 5. Merge the Pull Request
echo "Merging Pull Request to trigger badge..."
gh pr merge "$BRANCH_NAME" --merge --delete-branch

# Cleanup
git checkout "$MAIN_BRANCH"
git pull origin "$MAIN_BRANCH"
git branch -d "$BRANCH_NAME"

echo "🎉 Pair Extraordinaire PR merged!"
