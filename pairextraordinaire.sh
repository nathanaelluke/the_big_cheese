#!/bin/bash

# Configuration: 48 commits gets you the max tier badge
TARGET_COMMITS=48

# Check if we are inside a git repository
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "❌ Error: Not inside a git repository. Please run this inside your cloned repo."
    exit 1
fi

echo "👯 Starting the Pair Extraordinaire grind for $TARGET_COMMITS commits..."

for ((i=1; i<=TARGET_COMMITS; i++)); do
    echo "Writing commit $i of $TARGET_COMMITS..."
    
    # Create an empty commit with the exact required formatting.
    # Passing multiple -m flags creates paragraphs separated by blank lines.
    # The Co-authored-by trailer MUST be at the very bottom, separated by a blank line.
    git commit --allow-empty \
        -m "chore: pair extraordinaire cheese $i" \
        -m "" \
        -m "Co-authored-by: octocat <octocat@users.noreply.github.com>"
done

echo "⬆️ Pushing all 48 commits to GitHub at once..."
git push origin HEAD

echo "🎉 All done! Pair Extraordinaire achieved. Check your GitHub profile."
