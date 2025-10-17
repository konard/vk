var requests = API.friends.getRequests({ count: 23 }).items;
var users = API.users.get({ user_ids: requests, fields: "deactivated" });
var i = 0;
var addedUsers = [];
while(i < users.length)
{
  var user = users[i];
  if (!user.deactivated) {
    API.friends.add({ user_id: user.id });
    addedUsers.push(user.id);
  }
  i = i + 1;
}
return addedUsers;
