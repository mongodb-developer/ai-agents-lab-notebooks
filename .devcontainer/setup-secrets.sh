read -p "Enter LLM provider. Value should be one of aws, google or microsoft: " provider
PROVIDER=$provider

# Configuration
SERVERLESS_URL="https://vtqjvgchmwcjwsrela2oyhlegu0hwqnw.lambda-url.us-west-2.on.aws/"

# Fetch secrets from the proxy service
echo "Fetching secrets from the proxy service..."
response=$(curl -s -w "\n%{http_code}" -X POST \
    -H "Content-Type: application/json" \
    -d "{\"task\": \"get_secrets\", \"data\": {\"token\": \"devday\", \"provider\": \"$PROVIDER\"}}" \
    "$SERVERLESS_URL")

http_code=$(echo "$response" | tail -n1)
response_body=$(echo "$response" | sed '$d')

# Check for errors
if [[ $http_code -ne 200 ]]; then
    echo "Error: Failed to fetch secrets from the proxy service."
    exit 1
fi

# Save secrets to an environment file
echo "$response_body" | jq -r 'to_entries | .[] | "\(.key)=\(.value)"' > .env
echo "SERVERLESS_URL=$SERVERLESS_URL" >> .env

echo "Environment variables successfully configured."