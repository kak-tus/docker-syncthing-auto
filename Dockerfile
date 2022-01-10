FROM golang:1.17.6-alpine3.15 AS build

WORKDIR /go/src/heartbeat

COPY heartbeat/heartbeat.go ./
COPY heartbeat/go.mod ./
COPY heartbeat/go.sum ./

RUN go build -o /go/bin/heartbeat

WORKDIR /go/src/init

COPY init/main.go ./
COPY init/go.mod ./
COPY init/go.sum ./

RUN go build -o /go/bin/init

FROM hashicorp/consul-template:0.27.2 as consul-template

FROM syncthing/syncthing:1.18.5

ENV \
  USER_UID=1000 \
  USER_GID=1000 \
  \
  SET_CONTAINER_TIMEZONE=true \
  CONTAINER_TIMEZONE=Europe/Moscow \
  \
  CONSUL_HTTP_ADDR= \
  CONSUL_TOKEN= \
  \
  SYNC_SERVICE= \
  SYNC_FOLDERS= \
  SYNC_IP= \
  SYNC_PORT=22000 \
  SYNC_IGNORE_DELETE= \
  SYNC_MASTER_MODE=1 \
  SYNC_SEND_LIMIT=0 \
  SYNC_RECV_LIMIT=0 \
  SYNC_NEED_LOW_PERFOMANCE=

USER root

RUN \
  apk add --no-cache \
    curl \
    su-exec

COPY start.sh /usr/local/bin/start.sh
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY syncthing.hcl /etc/syncthing.hcl
COPY config.xml.template /etc/config.xml.template
COPY --from=build /go/bin/heartbeat /etc/periodic/hourly/heartbeat
COPY --from=build /go/bin/init /usr/local/bin/init
COPY --from=consul-template /bin/consul-template /usr/local/bin/consul-template

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
