#!/usr/bin/env sh

device_id=$( syncthing -generate="/home/user/.config/syncthing" | grep 'Device ID' | awk '{print $5}' )
export DEVICE_ID=$device_id

ip=$( hostname -i | awk '{print $1}' )
dt=$( date +%Y )

curl -X PUT -d "1" http://$CONSUL_HTTP_ADDR/v1/kv/service/syncthing-auto/$SYNC_SERVICE/devices/list/$device_id

curl -X PUT -d "$ip" http://$CONSUL_HTTP_ADDR/v1/kv/service/syncthing-auto/$SYNC_SERVICE/devices/$device_id/ip
curl -X PUT -d "$dt" http://$CONSUL_HTTP_ADDR/v1/kv/service/syncthing-auto/$SYNC_SERVICE/devices/$device_id/time
curl -X PUT -d "$SYNC_NAME" http://$CONSUL_HTTP_ADDR/v1/kv/service/syncthing-auto/$SYNC_SERVICE/devices/$device_id/name

for folder in $SYNC_FOLDERS; do
  id=$( echo $folder | awk -F ':' '{print $1}' )
  path=$( echo $folder | awk -F ':' '{print $2}' )

  curl -X PUT -d "$path" http://$CONSUL_HTTP_ADDR/v1/kv/service/syncthing-auto/$SYNC_SERVICE/folders/list/$id
done

consul-template \
  -template "/home/user/config.xml.template:/home/user/.config/syncthing/config.xml" \
  -exec "syncthing"
