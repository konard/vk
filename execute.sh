#!/bin/bash

TOKEN_EXPIRED_ERROR_MESSAGE="User authorization failed: access_token has expired."
TOKEN_WAS_GIVEN_TO_ANOTHER_IP_ERROR_MESSAGE="User authorization failed: access_token was given to another ip address."
NO_TOKEN_PASSED_ERROR_MESSAGE="User authorization failed: no access_token passed."
INTERNAL_SERVER_ERROR_MESSAGE="Internal server error: Unknown error, try later"

MAX_RETRIES=3
RETRY_DELAY=5

for ((attempt=1; attempt<=MAX_RETRIES; attempt++)); do
  QUERY_RESULT=$(curl -s "$1")

  ERROR_MESSAGE=$(echo "$QUERY_RESULT" | jq -r '.error.error_msg // empty')
  ERROR_CODE=$(echo "$QUERY_RESULT" | jq -r '.error.error_code // empty')

  echo "$QUERY_RESULT" | jq

  # Check for internal server error (error_code 10)
  if [ "$ERROR_CODE" = "10" ] || [ "$ERROR_MESSAGE" = "$INTERNAL_SERVER_ERROR_MESSAGE" ]; then
    if [ $attempt -lt $MAX_RETRIES ]; then
      echo "Internal server error (code 10). Retrying in ${RETRY_DELAY}s... (attempt $attempt/$MAX_RETRIES)"
      sleep $RETRY_DELAY
      continue
    else
      echo "Max retries reached. VK server is experiencing issues."
      exit 1
    fi
  fi

  # Check for token errors
  if [ "$ERROR_MESSAGE" = "$TOKEN_EXPIRED_ERROR_MESSAGE" ] || [ "$ERROR_MESSAGE" = "$TOKEN_WAS_GIVEN_TO_ANOTHER_IP_ERROR_MESSAGE" ] || [ "$ERROR_MESSAGE" = "$NO_TOKEN_PASSED_ERROR_MESSAGE" ]; then
    # Get new access token
    EMAIL=`cat email`
    PASS=`cat pass`
    cat vk_auth_token.side | jq '.tests[0].commands[2].value="'"$EMAIL"'" | .tests[0].commands[4].value="'"$PASS"'"' > vk_auth_token.temp
    selenium-side-runner vk_auth_token.temp | grep -o "https.*" | sed -r "s|.*access_token=([^&]+)&.*|\1|" > access-token
    rm vk_auth_token.temp
    echo "Token is updated"
  fi

  # If no error or error handled, break the loop
  break
done