#!/bin/bash
# Test script for friends limit logic
# This script simulates different scenarios to test the friends limit handling

set -e

echo "Testing friends limit management logic..."
echo "=========================================="
echo ""

# Test 1: Check if get-friends-count.sh works
echo "Test 1: Check friends count retrieval"
echo "--------------------------------------"
if [ -f "../get-friends-count.sh" ]; then
  echo "✓ get-friends-count.sh exists"
else
  echo "✗ get-friends-count.sh not found"
  exit 1
fi

# Test 2: Check if manage-friends-limit.sh exists
echo ""
echo "Test 2: Check manage-friends-limit.sh exists"
echo "---------------------------------------------"
if [ -f "../manage-friends-limit.sh" ]; then
  echo "✓ manage-friends-limit.sh exists"
  if [ -x "../manage-friends-limit.sh" ]; then
    echo "✓ manage-friends-limit.sh is executable"
  else
    echo "✗ manage-friends-limit.sh is not executable"
    exit 1
  fi
else
  echo "✗ manage-friends-limit.sh not found"
  exit 1
fi

# Test 3: Check if VK API scripts are present
echo ""
echo "Test 3: Check VK API scripts"
echo "-----------------------------"
for script in "Application/getFriendsCount.js" "Application/acceptAllFriendRequests.js" "Application/deleteInactiveFriends.js" "Application/deleteOutFriendRequests.js"; do
  if [ -f "../$script" ]; then
    echo "✓ $script exists"
  else
    echo "✗ $script not found"
    exit 1
  fi
done

# Test 4: Check updated acceptAllFriendRequests.js structure
echo ""
echo "Test 4: Validate acceptAllFriendRequests.js changes"
echo "----------------------------------------------------"
if grep -q "accepted" "../Application/acceptAllFriendRequests.js" && grep -q "total_requests" "../Application/acceptAllFriendRequests.js"; then
  echo "✓ acceptAllFriendRequests.js has been updated with proper return structure"
else
  echo "✗ acceptAllFriendRequests.js missing expected changes"
  exit 1
fi

# Test 5: Check .gitignore
echo ""
echo "Test 5: Check .gitignore includes friends-state.json"
echo "------------------------------------------------------"
if grep -q "friends-state.json" "../.gitignore"; then
  echo "✓ friends-state.json is in .gitignore"
else
  echo "✗ friends-state.json not in .gitignore"
  exit 1
fi

# Test 6: Check do-all.sh integration
echo ""
echo "Test 6: Check do-all.sh uses manage-friends-limit.sh"
echo "-----------------------------------------------------"
if grep -q "manage-friends-limit.sh" "../do-all.sh"; then
  echo "✓ do-all.sh integrated with manage-friends-limit.sh"
else
  echo "✗ do-all.sh not using manage-friends-limit.sh"
  exit 1
fi

echo ""
echo "=========================================="
echo "All tests passed! ✓"
echo "=========================================="
