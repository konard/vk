var count = 25;
var currentUserId = API.users.get()[0].id;
var suggestions = API.friends.getSuggestions({ filter: "mutual", fields: "online,last_seen,blacklisted", count: count, offset: count * Args.offset }).items;
var maxItem = [0, 0];
var i = 0;
while(i < suggestions.length)
{
  var suggestion = suggestions[i];
  if (suggestion.online && !suggestion.blacklisted) {
    var mutualFriendsCount = API.friends.getMutual({ source_uid: currentUserId, target_uid: suggestion.id }).length;
    if (mutualFriendsCount > maxItem[1]) {
      maxItem = [suggestion.id, mutualFriendsCount];
    }
  }
  i = i + 1;
}
if (maxItem[0] > 0) {
  API.friends.add({ user_id: maxItem[0] });
}
return maxItem;
