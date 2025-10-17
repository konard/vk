var requests = API.friends.getRequests({ count: 23 }).items;
var i = 0;
var accepted = [];
var errors = [];
while(i < requests.length)
{
  var result = API.friends.add({ user_id: requests[i] });
  if (result == 1 || result == 2 || result == 4) {
    accepted.push(requests[i]);
  }
  i = i + 1;
}
return { "accepted": accepted, "total_requests": requests.length };
