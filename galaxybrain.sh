#!/bin/bash

echo "requirements:"
echo "1. your main account must be authenticated via github cli ('gh auth login')."
echo "2. you need a personal access token (pat) from an alt account."
echo "3. you need a public repository with discussions enabled and an 'answerable' category (like q&a)."
echo ""

QA_FILE="./jira_ticket_padding.yaml"

if [ ! -f "$QA_FILE" ]; then
    echo " error: $QA_FILE not found. please ensure it is in the same directory."
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo " error: 'jq' is not installed. please install it first."
    exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
    echo " error: github cli is not authenticated for your main account."
    exit 1
fi

read -p "enter your public repository (format: owner/repo): " REPO_FULL
read -p "enter the alt account's personal access token (pat): " ALT_TOKEN

if [ -z "$REPO_FULL" ] || [ -z "$ALT_TOKEN" ]; then
    echo " repository and alt token are required."
    exit 1
fi

owner=$(echo "$REPO_FULL" | cut -d'/' -f1)
repo=$(echo "$REPO_FULL" | cut -d'/' -f2)

echo " fetching repository and category ids."

REPO_QUERY='
query($owner: String!, $name: String!) {
  repository(owner: $owner, name: $name) {
    id
    discussionCategories(first: 10) {
      nodes {
        id
        name
        isAnswerable
      }
    }
  }
}'

REPO_DATA=$(gh api graphql -f query="$REPO_QUERY" -f owner="$owner" -f name="$repo" 2>/dev/null)
REPO_ID=$(echo "$REPO_DATA" | jq -r '.data.repository.id // empty')

if [ -z "$REPO_ID" ]; then
    echo " could not find repository. is it public and spelled correctly?"
    exit 1
fi

CAT_ID=$(echo "$REPO_DATA" | jq -r '.data.repository.discussionCategories.nodes[] | select(.isAnswerable == true) | .id' | head -n 1)

if [ -z "$CAT_ID" ]; then
    echo " no answerable discussion category found in $REPO_FULL."
    echo "please go to the repo settings, enable discussions, and ensure a category like 'q&a' exists."
    exit 1
fi

mapfile -t QA_ARRAY < "$QA_FILE"
TOTAL_QA=${#QA_ARRAY[@]}

echo " loaded $TOTAL_QA robust synergistic questions."
echo " repository id: $REPO_ID"
echo " category id: $CAT_ID"
echo " beginning pretense of knowledge."

for ((i=1; i<=32; i++)); do
    echo "------------------------------------------------"
    echo "processing discussion $i of 32."

    QA_PAIR="${QA_ARRAY[$(( (i-1) % TOTAL_QA ))]}"
    
    IFS='|' read -r TITLE BODY ANSWER <<< "$QA_PAIR"

    CREATE_DISC_MUTATION='
    mutation($repoId: ID!, $catId: ID!, $title: String!, $body: String!) {
      createDiscussion(input: {repositoryId: $repoId, categoryId: $catId, title: $title, body: $body}) {
        discussion { id }
      }
    }'
    
    DISC_RES=$(GITHUB_TOKEN="$ALT_TOKEN" gh api graphql -f query="$CREATE_DISC_MUTATION" \
        -f repoId="$REPO_ID" \
        -f catId="$CAT_ID" \
        -f title="$TITLE" \
        -f body="$BODY")
    
    DISC_ID=$(echo "$DISC_RES" | jq -r '.data.createDiscussion.discussion.id // empty')

    if [ -z "$DISC_ID" ]; then
        echo " failed to create discussion. check your alt token permissions."
        echo "$DISC_RES"
        exit 1
    fi
    echo " alt account created discussion."
    sleep 2

    ADD_COMMENT_MUTATION='
    mutation($discussionId: ID!, $body: String!) {
      addDiscussionComment(input: {discussionId: $discussionId, body: $body}) {
        comment { id }
      }
    }'

    COMMENT_RES=$(gh api graphql -f query="$ADD_COMMENT_MUTATION" \
        -f discussionId="$DISC_ID" \
        -f body="$ANSWER")

    COMMENT_ID=$(echo "$COMMENT_RES" | jq -r '.data.addDiscussionComment.comment.id // empty')

    if [ -z "$COMMENT_ID" ]; then
        echo " failed to add comment."
        echo "$COMMENT_RES"
        exit 1
    fi
    echo " main account answered."
    sleep 2

    MARK_ANSWER_MUTATION='
    mutation($id: ID!) {
      markDiscussionCommentAsAnswer(input: {id: $id}) {
        clientMutationId
      }
    }'

    GITHUB_TOKEN="$ALT_TOKEN" gh api graphql -f query="$MARK_ANSWER_MUTATION" -f id="$COMMENT_ID" > /dev/null
    
    echo " alt account marked answer as accepted!"
    sleep 3
done

echo " galaxy brain gold complete"
