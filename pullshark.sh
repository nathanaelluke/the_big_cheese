#!/bin/bash

TARGET_PRS=1028
MAIN_BRANCH="main"
SLOP_FILE="synergy_cache.yaml"

if ! gh auth status >/dev/null 2>&1; then
    echo " error: github cli is not authenticated."
    exit 1
fi

if [ ! -f "$SLOP_FILE" ]; then
    echo " error: $SLOP_FILE not found. please ensure it is in the same directory."
    exit 1
fi

mapfile -t CORPORATE_SLOP < "$SLOP_FILE"
TOTAL_SLOP=${#CORPORATE_SLOP[@]}

echo " loaded $TOTAL_SLOP jargon"
echo " starting the sprint for $TARGET_PRS prs."

git checkout "$MAIN_BRANCH"
git pull origin "$MAIN_BRANCH"

for ((i=1; i<=TARGET_PRS; i++)); do
    BRANCH_NAME="pull-shark-cheese-$i"

    echo "------------------------------------------------"
    echo " processing pr $i of $TARGET_PRS..."
    
    git checkout -b "$BRANCH_NAME"
    
    echo "shark cheese $i: $(date +%s)" > SHARK_CHEESE.txt
    git add SHARK_CHEESE.txt
    
    git commit -m "chore: pull shark cheese commit $i"
    git push origin "$BRANCH_NAME"

    RANDOM_INDEX=$((RANDOM % TOTAL_SLOP))
    RANDOM_SLOP="${CORPORATE_SLOP[$RANDOM_INDEX]}"

    gh pr create \
        --title "pull shark pr $i" \
        --body "$RANDOM_SLOP" \
        --base "$MAIN_BRANCH" \
        --head "$BRANCH_NAME"

    sleep 3

    gh pr merge "$BRANCH_NAME" --merge --delete-branch

    git checkout "$MAIN_BRANCH"
    git pull origin "$MAIN_BRANCH"
    git branch -d "$BRANCH_NAME"

    echo " pr $i merged successfully"
    sleep 5
done

echo " pull shark gold complete"
