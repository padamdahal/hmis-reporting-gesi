#!/bin/bash

# Exit on error
set -e

# Prompt user for DHIS2 server details
read -p "Enter DHIS2 Base URL: " BASE_URL
read -p "Enter DHIS2 Username: " USERNAME
# -s hides the password input for security
read -s -p "Enter DHIS2 Password: " PASSWORD
echo "" # Print newline after password entry
read -p "Enter path to app ZIP file: " ZIP_PATH

# Remove trailing slash from URL if present
BASE_URL="${BASE_URL%/}"

# Validate file existence
if [ ! -f "$ZIP_PATH" ]; then
    echo "Error: File $ZIP_PATH not found."
    exit 1
fi

echo "Deploying app to $BASE_URL..."

# Send POST request to the DHIS2 Apps API
RESPONSE=$(curl -s -w "\n%{http_code}" \
  -u "$USERNAME:$PASSWORD" \
  -F "file=@$ZIP_PATH" \
  "$BASE_URL/api/apps")

# Separate the HTTP status code from the response body
HTTP_STATUS=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

# Check response status
if [ "$HTTP_STATUS" -eq 200 ] || [ "$HTTP_STATUS" -eq 201 ]; then
    echo "Success! App deployed successfully."
else
    echo "Deployment failed with HTTP Status: $HTTP_STATUS"
    echo "Server Response: $BODY"
    exit 1
fi