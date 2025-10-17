#!/bin/bash
set -e

# Configuration
FRIENDS_LIMIT=10000
STATE_FILE="friends-state.json"
SAFETY_MARGIN=50  # Keep some room below the limit

# Get current friends count from VK API
get_friends_count() {
  local result=$(./get-friends-count.sh 2>/dev/null | jq -r '.response // 0')
  echo "$result"
}

# Save state to file
save_state() {
  local count=$1
  local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  echo "{\"friends_count\": $count, \"last_updated\": \"$timestamp\"}" > "$STATE_FILE"
}

# Load state from file
load_state() {
  if [ -f "$STATE_FILE" ]; then
    cat "$STATE_FILE" | jq -r '.friends_count // 0'
  else
    echo "0"
  fi
}

# Check if we're at or near the limit
is_at_limit() {
  local count=$1
  if [ "$count" -ge $((FRIENDS_LIMIT - SAFETY_MARGIN)) ]; then
    return 0  # true, at limit
  else
    return 1  # false, not at limit
  fi
}

# Main logic
echo "Checking friends count..."
CURRENT_COUNT=$(get_friends_count)
echo "Current friends count: $CURRENT_COUNT"

# Save state
save_state "$CURRENT_COUNT"

if is_at_limit "$CURRENT_COUNT"; then
  echo "⚠️  Friends limit reached ($CURRENT_COUNT >= $((FRIENDS_LIMIT - SAFETY_MARGIN)))"
  echo "Starting cleanup process..."

  echo "Step 1: Canceling outgoing friend requests..."
  ./delete-out-friend-request.sh

  echo "Step 2: Deleting inactive friends..."
  # Try to delete inactive friends in batches
  for offset in {0..9}; do
    echo "  Deleting inactive friends batch $offset..."
    ./delete-inactive-friends.sh "$offset" || true
    sleep 2
  done

  # Update count after cleanup
  echo "Updating friends count after cleanup..."
  CURRENT_COUNT=$(get_friends_count)
  echo "Friends count after cleanup: $CURRENT_COUNT"
  save_state "$CURRENT_COUNT"

  if is_at_limit "$CURRENT_COUNT"; then
    echo "⚠️  Still at limit after cleanup. Skipping friend request acceptance."
    exit 0
  else
    echo "✓ Cleanup successful. Below limit now."
  fi
else
  echo "✓ Friends count is below limit."
fi

# Only accept friend requests if we're below the limit
echo "Accepting friend requests..."
./accept-all-friend-requests-once.sh

# Final count update
FINAL_COUNT=$(get_friends_count)
echo "Final friends count: $FINAL_COUNT"
save_state "$FINAL_COUNT"
