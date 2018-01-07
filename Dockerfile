FROM golang:alpine AS build

COPY heartbeat.go /go/src/heartbeat/heartbeat.go

RUN \
  apk add --no-cache --virtual .build-deps \
    git \

  && cd /go/src/heartbeat \
  && go get \

  && apk del .build-deps

FROM syncthing/syncthing:v0.14.42

ENV \
  CONSUL_TEMPLATE_VERSION=0.19.4 \
  CONSUL_TEMPLATE_SHA256=5f70a7fb626ea8c332487c491924e0a2d594637de709e5b430ecffc83088abc0 \

  USER_UID=1000 \
  USER_GID=1000 \

  SET_CONTAINER_TIMEZONE=true \
  CONTAINER_TIMEZONE=Europe/Moscow \

  CONSUL_HTTP_ADDR= \
  CONSUL_TOKEN= \

  SYNC_SERVICE= \
  SYNC_FOLDERS= \
  SYNC_IP= \
  SYNC_PORT=22000 \
  SYNC_IGNORE_DELETE=

USER root

RUN \
  apk add --no-cache --virtual .build-deps \
    unzip \

  && apk add --no-cache \
    curl \
    su-exec \

  && cd /usr/local/bin \
  && curl -L https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip -o consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip \
  && echo -n "$CONSUL_TEMPLATE_SHA256  consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip" | sha256sum -c - \
  && unzip consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip \
  && rm consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip \

  && apk del .build-deps

COPY start.sh /usr/local/bin/start.sh
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY syncthing.hcl /etc/syncthing.hcl
COPY config.xml.template /etc/config.xml.template
COPY --from=build /go/bin/heartbeat /etc/periodic/hourly/heartbeat

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
