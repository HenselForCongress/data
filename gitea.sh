#!/bin/bash

# Ensure the script stops on any error
set -e

# Fetch all branches
echo "Fetching all branches from origin..."
git fetch origin

# Push each local branch to Gitea remote
for branch in $(git for-each-ref --format='%(refname:short)' refs/heads/); do
    echo "Pushing branch $branch to Gitea"
    git push Gitea $branch || {
        echo "Failed to push branch $branch. Retrying..."
        # Retry mechanism to handle transient failures
        git push Gitea $branch
    }
done

# Push all tags to Gitea
echo "Pushing tags to Gitea"
git push Gitea --tags

# Update remote references (e.g., HEAD)
echo "Updating remote references"
git push Gitea refs/remotes/origin/HEAD:refs/heads/main