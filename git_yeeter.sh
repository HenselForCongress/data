#!/bin/bash

# Ensure the script stops on any error
set -e

# Variables
MAX_SIZE=$((45 * 1024 * 1024))  # 45MB
COMMIT_MESSAGE="Adding new files up to 45MB"
NEW_FILES=()

# Function to get the size of a file
get_file_size() {
    stat -f%z "$1"
}

# Get new/modified files while respecting .gitignore
NEW_FILES=$(git status --porcelain=v1 | grep '^??' | awk '{print $2}')
NEW_FILES_ARRAY=($NEW_FILES)

commit_and_push() {
    local files=("$@")
    if [ ${#files[@]} -gt 0 ]; then
        git add "${files[@]}"
        git commit -S -m "$COMMIT_MESSAGE"
        git push origin main
        echo "Pushed ${#files[@]} files to the repository."
    else
        echo "No new files to commit or total file size exceeds 45MB."
    fi
}

# Commit and push new files in batches of MAX_SIZE
while [ ${#NEW_FILES_ARRAY[@]} -gt 0 ]; do
    CUMULATIVE_SIZE=0
    FILES_TO_COMMIT=()
    for ((i=0; i<${#NEW_FILES_ARRAY[@]}; i++)); do
        FILE=${NEW_FILES_ARRAY[$i]}
        FILE_SIZE=$(get_file_size "$FILE")

        if (( CUMULATIVE_SIZE + FILE_SIZE <= MAX_SIZE )); then
            FILES_TO_COMMIT+=("$FILE")
            CUMULATIVE_SIZE=$((CUMULATIVE_SIZE + FILE_SIZE))
        else
            break
        fi
    done

    # Commit and push this batch
    commit_and_push "${FILES_TO_COMMIT[@]}"

    # Remove committed files from the array
    NEW_FILES_ARRAY=("${NEW_FILES_ARRAY[@]:$i}")
done
