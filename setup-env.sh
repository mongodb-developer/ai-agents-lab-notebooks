#!/bin/bash
if [ -n "$1" ]; then
    LLM_PROVIDER="$1"
else
    LLM_PROVIDER="aws"
fi
export LLM_PROVIDER

# Configuration
SERVERLESS_URL="https://vtqjvgchmwcjwsrela2oyhlegu0hwqnw.lambda-url.us-west-2.on.aws/"
export SERVERLESS_URL

# Fetch environment variables from the proxy service
echo "Fetching secrets from the proxy service..."
response=$(curl -s -w "\n%{http_code}" -X POST \
    -H "Content-Type: application/json" \
    -d "{\"task\": \"get_secrets\", \"data\": {\"token\": \"devday\", \"provider\": \"$LLM_PROVIDER\"}}" \
    "$SERVERLESS_URL")

http_code=$(echo "$response" | tail -n1)
response_body=$(echo "$response" | sed '$d')

# Check for errors
if [[ $http_code -ne 200 ]]; then
    echo "Error: Failed to fetch secrets from the proxy service."
    exit 1
fi

# Set environment variables
echo "$response_body" | jq -r 'to_entries | .[] | "\(.key)=\(.value)"' | while IFS= read -r line; do
    export "$line"
done

echo "Environment variables successfully configured."