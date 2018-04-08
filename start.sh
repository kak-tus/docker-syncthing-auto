#!/usr/bin/env sh

/bin/syncthing -home /home/user/config &
child=$!

trap "kill $child" SIGTERM SIGINT
wait "$child"
trap - SIGTERM SIGINT
wait "$child"
