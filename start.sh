#!/usr/bin/env sh

/syncthing/syncthing -home /home/user/config &
child=$!

trap "kill $child" SIGTERM SIGINT
wait "$child"
trap - SIGTERM SIGINT
wait "$child"
