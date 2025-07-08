#!/bin/bash

# Define API URL and Authorization Token
BASE_URL="https://api.mediashuttle.com/v1/portals"
AUTH_TOKEN="3431b439-91e6-4b73-82ea-85515eab07f3"

# List of Portal IDs
PORTAL_IDS=(
    "00025fb1-3341-403d-81f1-390a0e9bb5a1"
    "012c9821-c571-459c-bcc6-452ce52d965d"
    "081e5263-1252-4308-a4c7-a104b7b06608"
    "0d41c54e-73d9-44cf-a675-dd389acee909"
    "15f97660-64d5-4140-9a2c-a40aa1d29b88"
    "1b0540c8-1c50-444b-87a2-722e6757f2a4"
    "20269046-18b1-458c-8b25-22b822a4bed2"
    "2ffa2e41-f53d-421e-93ed-a8ea8695eac5"
    # Add more IDs as needed
)

# Loop through each portal ID and fetch storage path
for ID in "${PORTAL_IDS[@]}"; do
    echo "Fetching storage info for Portal ID: $ID"
    
    # Run curl request
    RESPONSE=$(curl -s -X 'GET' \
        "$BASE_URL/$ID/storage" \
        -H "accept: application/json" \
        -H "Authorization: $AUTH_TOKEN")
    
    # Extract storage path using jq (if installed)
    STORAGE_PATH=$(echo "$RESPONSE" | jq -r '.storagePath // "No storage path found"')

    # Print result
    echo "Portal ID: $ID"
    echo "Storage Path: $STORAGE_PATH"
    echo "--------------------------------"
done

