#!/bin/bash

GH_TOKEN="github_personal_token"
SOURCE_USER="source_username"
TARGET_USER="target_username"

# List all repositories from the source user
repos=$(curl -s -H "Authorization: token $GH_TOKEN" \
  https://api.github.com/users/$SOURCE_USER/repos?per_page=100 | jq -r '.[].name')

for repo in $repos; do
  echo "Transferring $repo to $TARGET_USER..."

  # Transfer repo ownership
  curl -X POST -H "Authorization: token $GH_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    https://api.github.com/repos/$SOURCE_USER/$repo/transfer \
    -d "{\"new_owner\":\"$TARGET_USER\"}"
done
