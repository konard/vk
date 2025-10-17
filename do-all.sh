#!/bin/bash
set -e

# Initial run with friends limit management
./manage-friends-limit.sh

sleep 16

./delete-first-deactivated-friend.sh

sleep 16

# Main loop with friends limit checks
while :
do
  sleep 600

  ./manage-friends-limit.sh

  sleep 600

  ./delete-first-deactivated-friend.sh

  sleep 600
done
