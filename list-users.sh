#!/bin/bash

#############
# About:
# This script interacts with the GitHub API to list all users who have read access 
# (pull permission) to a specified GitHub repository. It uses a personal access 
# token for authentication and outputs the list of collaborators with read access.
#
# Input:
# - $1: Repository owner (e.g., GitHub username or organization name)
# - $2: Repository name
# - Environment Variables:
#   - $username: Your GitHub username
#   - $token: Your GitHub personal access token (must have repo scope for private repositories)
#
# Requirements:
# - curl: Used to make HTTP requests to the GitHub API.
#############

helper() {
    expected_cmd_args=2
    if [ $# -ne $expected_cmd_args ]; then
        echo "Error: Please execute the script with the required $expected_cmd_args arguments."
        echo "Usage: ./list-users.sh <repository_owner> <repository_name>"
        exit 1
    fi
}

# GitHub API URL
API_URL="https://api.github.com"

# GitHub username and personal access token
USERNAME=$username
TOKEN=$token

# User and Repository information
REPO_OWNER=$1
REPO_NAME=$2

# Function to make a GET request to the GitHub API
function github_api_get {
    local endpoint="$1"
    local url="${API_URL}/${endpoint}"

    # Send a GET request to the GitHub API with authentication
    curl -s -u "${USERNAME}:${TOKEN}" "$url"
}

# Function to list users with read access to the repository
function list_users_with_read_access {
    local endpoint="repos/${REPO_OWNER}/${REPO_NAME}/collaborators"

    # Fetch the list of collaborators on the repository
    collaborators="$(github_api_get "$endpoint" | jq -r '.[] | select(.permissions.pull == true) | .login')"

    # Display the list of collaborators with read access
    if [[ -z "$collaborators" ]]; then
        echo "No users with read access found for ${REPO_OWNER}/${REPO_NAME}."
    else
        echo "Users with read access to ${REPO_OWNER}/${REPO_NAME}:"
        echo "$collaborators"
    fi
}


# Main script

echo "Listing users with read access to ${REPO_OWNER}/${REPO_NAME}..."
list_users_with_read_access
