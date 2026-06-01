#!/bin/bash

TARGET_PRS=48
MAIN_BRANCH="main"

if ! gh auth status >/dev/null 2>&1; then
    echo " error: github cli is not authenticated."
    exit 1
fi

echo " generating $TARGET_PRS co-authored prs for pair extraordinaire gold..."

git checkout "$MAIN_BRANCH"
git pull origin "$MAIN_BRANCH"

for ((i=1; i<=TARGET_PRS; i++)); do
    BRANCH_NAME="pair-cheese-$i"

    echo "------------------------------------------------"
    echo " processing pair extraordinaire pr $i of $TARGET_PRS..."

    git checkout -b "$BRANCH_NAME"
    
    echo "pair cheese $i: $(date +%s)" > PAIR_CHEESE.txt
    git add PAIR_CHEESE.txt
    
    git commit \
        -m "chore: pair extraordinaire cheese $i" \
        -m "" \
        -m "co-authored-by: orthogonalmind <carrot-seer.6g@icloud.com>"

    git push origin "$BRANCH_NAME"

    gh pr create --title "pair extraordinaire pr $i" --body "grinding the pair extraordinaire badge" --base "$MAIN_BRANCH" --head "$BRANCH_NAME"

    sleep 3

    gh pr merge "$BRANCH_NAME" --merge --delete-branch

    git checkout "$MAIN_BRANCH"
    git pull origin "$MAIN_BRANCH"
    git branch -d "$BRANCH_NAME"

    echo " pr $i merged successfully!"
    sleep 5
done

echo " pair extraordinaire gold complete!"
