#!/bin/bash

echo "🌌 Galaxy Brain Cheese Script 🌌"
echo "Since you CANNOT accept your own answers to get the badge, this script"
echo "automates the process between your main account and an alt account."
echo ""
echo "Requirements:"
echo "1. Your main account must be authenticated via GitHub CLI ('gh auth login')."
echo "2. You need a Personal Access Token (PAT) from an ALT account."
echo "3. You need a public repository with Discussions enabled and an 'Answerable' category (like Q&A)."
echo ""

if ! command -v jq &> /dev/null; then
    echo "❌ Error: 'jq' is not installed. Please install it first."
    exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
    echo "❌ Error: GitHub CLI is not authenticated for your MAIN account."
    exit 1
fi

read -p "Enter your public repository (format: owner/repo): " REPO_FULL
read -p "Enter the ALT account's Personal Access Token (PAT): " ALT_TOKEN

if [ -z "$REPO_FULL" ] || [ -z "$ALT_TOKEN" ]; then
    echo "❌ Repository and Alt Token are required."
    exit 1
fi

OWNER=$(echo "$REPO_FULL" | cut -d'/' -f1)
REPO=$(echo "$REPO_FULL" | cut -d'/' -f2)

echo "🔍 Fetching Repository and Category IDs..."

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

REPO_DATA=$(gh api graphql -f query="$REPO_QUERY" -f owner="$OWNER" -f name="$REPO" 2>/dev/null)
REPO_ID=$(echo "$REPO_DATA" | jq -r '.data.repository.id // empty')

if [ -z "$REPO_ID" ]; then
    echo "❌ Could not find repository. Is it public and spelled correctly?"
    exit 1
fi

CAT_ID=$(echo "$REPO_DATA" | jq -r '.data.repository.discussionCategories.nodes[] | select(.isAnswerable == true) | .id' | head -n 1)

if [ -z "$CAT_ID" ]; then
    echo "❌ No answerable discussion category found in $REPO_FULL."
    echo "Please go to the repo settings, enable Discussions, and ensure a category like 'Q&A' exists."
    exit 1
fi

echo "✅ Repository ID: $REPO_ID"
echo "✅ Category ID: $CAT_ID"
echo "🚀 Starting the grind for 32 accepted answers (Galaxy Brain Gold)..."

for ((i=1; i<=32; i++)); do
    echo "------------------------------------------------"
    echo "Processing Discussion $i of 32..."

    # 1. Alt account creates discussion
    CREATE_DISC_MUTATION='
    mutation($repoId: ID!, $catId: ID!, $title: String!, $body: String!) {
      createDiscussion(input: {repositoryId: $repoId, categoryId: $catId, title: $title, body: $body}) {
        discussion { id }
      }
    }'
    
    DISC_RES=$(GITHUB_TOKEN="$ALT_TOKEN" gh api graphql -f query="$CREATE_DISC_MUTATION" \
        -f repoId="$REPO_ID" \
        -f catId="$CAT_ID" \
        -f title="Galaxy Brain Cheese $i" \
        -f body="Can you help me with this cheese?")
    
    DISC_ID=$(echo "$DISC_RES" | jq -r '.data.createDiscussion.discussion.id // empty')

    if [ -z "$DISC_ID" ]; then
        echo "❌ Failed to create discussion. Check your alt token permissions."
        echo "$DISC_RES"
        exit 1
    fi
    echo "✅ Alt account created discussion."
    sleep 2

    # 2. Main account replies
    ADD_COMMENT_MUTATION='
    mutation($discussionId: ID!, $body: String!) {
      addDiscussionComment(input: {discussionId: $discussionId, body: $body}) {
        comment { id }
      }
    }'

    COMMENT_RES=$(gh api graphql -f query="$ADD_COMMENT_MUTATION" \
        -f discussionId="$DISC_ID" \
        -f body="Here is the solution to your cheese: $i")

    COMMENT_ID=$(echo "$COMMENT_RES" | jq -r '.data.addDiscussionComment.comment.id // empty')

    if [ -z "$COMMENT_ID" ]; then
        echo "❌ Failed to add comment."
        echo "$COMMENT_RES"
        exit 1
    fi
    echo "✅ Main account answered."
    sleep 2

    # 3. Alt account marks as answer
    MARK_ANSWER_MUTATION='
    mutation($id: ID!) {
      markDiscussionCommentAsAnswer(input: {id: $id}) {
        clientMutationId
      }
    }'

    GITHUB_TOKEN="$ALT_TOKEN" gh api graphql -f query="$MARK_ANSWER_MUTATION" -f id="$COMMENT_ID" > /dev/null
    
    echo "✅ Alt account marked answer as accepted!"
    sleep 3
done

echo "🎉 Galaxy Brain Gold complete! Check your GitHub profile."
