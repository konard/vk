var count = 100;
var currentUserId = API.users.get()[0].id;
var requests = API.friends.getRequests({ count: count, extended: 1, fields: "online,last_seen,deactivated" }).items;
var maxItem = [0, 0];
var i = 0;
while(i < requests.length)
{
  var request = requests[i];
  if (!request.deactivated && request.online) {
    var mutualFriendsCount = API.friends.getMutual({ source_uid: currentUserId, target_uid: request.id }).length;
    if (mutualFriendsCount > maxItem[1]) {
      maxItem = [request.id, mutualFriendsCount];
    }
  }
  i = i + 1;
}
if (maxItem[0] > 0) {
  API.friends.add({ user_id: maxItem[0] });
}
return maxItem;
