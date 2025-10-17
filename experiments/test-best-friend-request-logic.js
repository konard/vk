// Test script to validate the best friend request selection logic
// This simulates the VK API behavior without making actual API calls

// Mock API responses
const mockRequests = [
  { id: 1001, online: false, deactivated: false, name: "User A (offline)" },
  { id: 1002, online: true, deactivated: false, name: "User B (online, 5 mutual)" },
  { id: 1003, online: true, deactivated: true, name: "User C (online but deactivated)" },
  { id: 1004, online: true, deactivated: false, name: "User D (online, 10 mutual)" },
  { id: 1005, online: true, deactivated: false, name: "User E (online, 3 mutual)" }
];

const mockMutualFriends = {
  1001: 15, // Offline, so should be ignored even with most mutual friends
  1002: 5,
  1003: 20, // Deactivated, should be ignored
  1004: 10, // Should be selected (online, not deactivated, max mutual friends)
  1005: 3
};

// Simulate the algorithm
let maxItem = [0, 0];
let i = 0;

console.log("Testing friend request selection algorithm:\n");
console.log("Criteria:");
console.log("1. User is online");
console.log("2. User is not blocked or deactivated");
console.log("3. User has maximum common friends");
console.log("\nAnalyzing requests:\n");

while(i < mockRequests.length) {
  const request = mockRequests[i];
  console.log(`- ${request.name} (ID: ${request.id})`);
  console.log(`  Online: ${request.online}, Deactivated: ${request.deactivated}, Mutual friends: ${mockMutualFriends[request.id]}`);

  if (!request.deactivated && request.online) {
    const mutualFriendsCount = mockMutualFriends[request.id];
    console.log(`  ✓ Eligible candidate with ${mutualFriendsCount} mutual friends`);
    if (mutualFriendsCount > maxItem[1]) {
      maxItem = [request.id, mutualFriendsCount];
      console.log(`  ✓✓ New best match!`);
    }
  } else {
    console.log(`  ✗ Not eligible (${!request.online ? 'offline' : 'deactivated'})`);
  }
  console.log();
  i = i + 1;
}

console.log("Result:");
if (maxItem[0] > 0) {
  const selected = mockRequests.find(r => r.id === maxItem[0]);
  console.log(`Selected: ${selected.name} (ID: ${maxItem[0]}) with ${maxItem[1]} mutual friends`);
  console.log(`Would accept friend request from user ${maxItem[0]}`);
} else {
  console.log("No eligible friend request found");
}
