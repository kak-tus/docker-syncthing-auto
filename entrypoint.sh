#!/usr/bin/env sh

if [ "$SET_CONTAINER_TIMEZONE" = "true" ]; then
    echo "$CONTAINER_TIMEZONE" > /etc/timezone \
    && ln -sf "/usr/share/zoneinfo/$CONTAINER_TIMEZONE" /etc/localtime
    echo "Container timezone set to: $CONTAINER_TIMEZONE"
else
    echo "Container timezone not modified"
fi

deluser syncthing 2>/dev/null
delgroup syncthing 2>/dev/null
addgroup -g $USER_GID user
adduser -h /home/user -G user -D -u $USER_UID user

device_id=$( su-exec user /bin/syncthing -generate="/home/user/config" 2>&1 | grep 'Device ID' | awk '{print $5}' )
export DEVICE_ID="$device_id"

/usr/local/bin/init
if [ $? != "0" ]; then
  echo "Unsuccess init"
  exit 1
fi

su-exec user consul-template -config /etc/syncthing.hcl &
child1=$!

crond -f &
child2=$!

trap "kill $child1 $child2" SIGTERM SIGINT

while true; do

  kill -0 "$child1"
  if [ "$?" = "0" ]; then
    sleep 5
  else
    echo "Exited syncthing"
    exit
  fi

  kill -0 "$child2"
  if [ "$?" = "0" ]; then
    sleep 5
  else
    echo "Exited cron"
    exit
  fi

done
