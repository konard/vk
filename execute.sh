#!/bin/bash

TOKEN_EXPIRED_ERROR_MESSAGE="User authorization failed: access_token has expired."
TOKEN_WAS_GIVEN_TO_ANOTHER_IP_ERROR_MESSAGE="User authorization failed: access_token was given to another ip address."
NO_TOKEN_PASSED_ERROR_MESSAGE="User authorization failed: no access_token passed."
INTERNAL_SERVER_ERROR_MESSAGE="Internal server error: Unknown error, try later"

# Retry configuration
MAX_RETRIES=3
RETRY_DELAY=2

# Function to execute API call with retry logic
execute_with_retry() {
  local url="$1"
  local attempt=1

  while [ $attempt -le $MAX_RETRIES ]; do
    QUERY_RESULT=$(curl -s "$url")
    ERROR_CODE=$(echo "$QUERY_RESULT" | jq -r '.error.error_code // empty')
    ERROR_MESSAGE=$(echo "$QUERY_RESULT" | jq -r '.error.error_msg // empty')

    # Check if the request was successful (no error field)
    if [ -z "$ERROR_CODE" ]; then
      echo "$QUERY_RESULT" | jq
      return 0
    fi

    # Check for error code 10 (Internal server error)
    if [ "$ERROR_CODE" = "10" ]; then
      if [ $attempt -lt $MAX_RETRIES ]; then
        echo "Internal server error detected (attempt $attempt/$MAX_RETRIES). Retrying in ${RETRY_DELAY}s..." >&2
        sleep $RETRY_DELAY
        # Exponential backoff
        RETRY_DELAY=$((RETRY_DELAY * 2))
        attempt=$((attempt + 1))
        continue
      else
        echo "Max retries reached. VK API is still returning internal server error." >&2
        echo "$QUERY_RESULT" | jq
        return 1
      fi
    fi

    # For other errors, break the loop and handle below
    echo "$QUERY_RESULT" | jq
    break
  done

  # Handle token-related errors
  if [ "$ERROR_MESSAGE" = "$TOKEN_EXPIRED_ERROR_MESSAGE" ] || [ "$ERROR_MESSAGE" = "$TOKEN_WAS_GIVEN_TO_ANOTHER_IP_ERROR_MESSAGE" ] || [ "$ERROR_MESSAGE" = "$NO_TOKEN_PASSED_ERROR_MESSAGE" ]; then
    # Get new access token
    EMAIL=`cat email`
    PASS=`cat pass`
    cat vk_auth_token.side | jq '.tests[0].commands[2].value="'"$EMAIL"'" | .tests[0].commands[4].value="'"$PASS"'"' > vk_auth_token.temp
    selenium-side-runner vk_auth_token.temp | grep -o "https.*" | sed -r "s|.*access_token=([^&]+)&.*|\1|" > access-token
    rm vk_auth_token.temp
    echo "Token is updated"
  fi
}

execute_with_retry "$1"