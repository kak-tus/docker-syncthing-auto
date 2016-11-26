# docker-syncthing-auto

Automated syncthing: just run container and it automagically discover other containers, connects to them and start syncing. No need to any manual configuration to start syncing.

You need running instance of [Consul](https://www.consul.io) to discovery.

## Run example

```
sudo docker run --rm -it -e CONSUL_HTTP_ADDR=consul.service.consul:8500 -e CONSUL_TOKEN=<SOME_CONSUL_TOKEN> -e SYNC_SERVICE=sync -e SYNC_FOLDERS='test:/home/user/test' -v /tmp/sync1:/home/user/test kaktuss/syncthing-auto:latest

sudo docker run --rm -it -e CONSUL_HTTP_ADDR=consul.service.consul:8500 -e CONSUL_TOKEN=<SOME_CONSUL_TOKEN> -e SYNC_SERVICE=sync -e SYNC_FOLDERS='test:/home/user/test' -v /tmp/sync2:/home/user/test kaktuss/syncthing-auto:latest
```

Copy file to /tmp/sync1 at host system and then it appear at /tmp/sync2.


## Configuration

CONSUL_HTTP_ADDR - address of consul. Required.

CONSUL_TOKEN - Consul ACL token. Required.

SYNC_SERVICE - some service name. Must be identical thru syncthing-auto cluster. Required.

SYNC_FOLDERS - folders to sync. Required. Format:

```
SYNC_FOLDERS="
<uniq_folder_tag_in_syncthing_auto_cluster_1:folder_path_in_container_1>
<uniq_folder_tag_in_syncthing_auto_cluster_2:folder_path_in_container_2>
...
"
```

SYNC_IP - external IP of container. Optional. If not set, service got internal container IP.

## Run in production

In most cases you need to pass SYNC_IP to each container and expose 22000 port to connectivity containers to each other. You can expose 8384 port to connect to GUI. Don't expose GUI port to worldwide access.

If you use weave networking, SYNC_IP is not required. Service detect IP automatically and connect to each other thru weave network.
