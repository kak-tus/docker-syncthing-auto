#!/usr/bin/env sh

deluser user 2>/dev/null
delgroup user 2>/dev/null
addgroup -g $USER_GID user
adduser -h /home/user -G user -D -u $USER_UID user

device_id=$( su-exec user syncthing -generate="/home/user/.config/syncthing" | grep 'Device ID' | awk '{print $5}' )

ip=$SYNC_IP
if [ -z "$ip" ]; then
  ip=$( hostname -i | awk '{print $1}' )
fi

dt=$( date +%Y )

curl -X PUT -d "1" http://$CONSUL_HTTP_ADDR/v1/kv/service/syncthing-auto/$SYNC_SERVICE/devices/list/$ip

curl -X PUT -d "$device_id" http://$CONSUL_HTTP_ADDR/v1/kv/service/syncthing-auto/$SYNC_SERVICE/devices/$ip/device_id
curl -X PUT -d "$dt" http://$CONSUL_HTTP_ADDR/v1/kv/service/syncthing-auto/$SYNC_SERVICE/devices/$ip/time

for folder in $SYNC_FOLDERS; do
  id=$( echo $folder | awk -F ':' '{print $1}' )
  path=$( echo $folder | awk -F ':' '{print $2}' )

  if [ -n "$id" ]; then
    mkdir -p $path
    touch "$path/.stfolder"
    chown -R user:user $path

    curl -X PUT -d "$path" http://$CONSUL_HTTP_ADDR/v1/kv/service/syncthing-auto/$SYNC_SERVICE/folders/list/$id
  fi
done

su-exec user consul-template -config /etc/syncthing.hcl >/proc/1/fd/1 2>/proc/1/fd/2 &
child=$!

trap "kill $child" SIGTERM
wait "$child"
