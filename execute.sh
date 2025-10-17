#!/bin/bash

TOKEN_EXPIRED_ERROR_MESSAGE="User authorization failed: access_token has expired."
TOKEN_WAS_GIVEN_TO_ANOTHER_IP_ERROR_MESSAGE="User authorization failed: access_token was given to another ip address."
NO_TOKEN_PASSED_ERROR_MESSAGE="User authorization failed: no access_token passed."

QUERY_RESULT=$(curl -s "$1")

ERROR_MESSAGE=$(echo "$QUERY_RESULT" | jq .error.error_msg | tr -d '"')

echo "$QUERY_RESULT" | jq

if [ "$ERROR_MESSAGE" = "$TOKEN_EXPIRED_ERROR_MESSAGE" ] || [ "$ERROR_MESSAGE" = "$TOKEN_WAS_GIVEN_TO_ANOTHER_IP_ERROR_MESSAGE" ] || [ "$ERROR_MESSAGE" = "$NO_TOKEN_PASSED_ERROR_MESSAGE" ]; then
  # Check if Google Chrome is installed, install if needed
  if ! command -v google-chrome &> /dev/null; then
    echo "Google Chrome not found. Installing..."
    ./install-google-chrome.sh
  fi

  # Get new access token
  EMAIL=`cat email`
  PASS=`cat pass`
  cat vk_auth_token.side | jq '.tests[0].commands[2].value="'"$EMAIL"'" | .tests[0].commands[4].value="'"$PASS"'"' > vk_auth_token.temp
  selenium-side-runner vk_auth_token.temp | grep -o "https.*" | sed -r "s|.*access_token=([^&]+)&.*|\1|" > access-token
  rm vk_auth_token.temp
  echo "Token is updated"
fi;