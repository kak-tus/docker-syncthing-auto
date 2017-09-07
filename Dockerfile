FROM golang:alpine AS build

COPY heartbeat.go /go/src/heartbeat/heartbeat.go

RUN \
  apk add --no-cache --virtual .build-deps \
    git \

  && cd /go/src/heartbeat \
  && go get && go build \

  && apk del .build-deps

FROM tianon/syncthing:0.14

ENV CONSUL_TEMPLATE_VERSION=0.18.2
ENV CONSUL_TEMPLATE_SHA256=6fee6ab68108298b5c10e01357ea2a8e4821302df1ff9dd70dd9896b5c37217c

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
COPY syncthing.hcl /etc/syncthing.hcl
COPY config.xml.template /home/user/config.xml.template
COPY --from=build /go/bin/heartbeat /etc/periodic/hourly/heartbeat

ENV USER_UID=1000
ENV USER_GID=1000

ENV SET_CONTAINER_TIMEZONE=true
ENV CONTAINER_TIMEZONE=Europe/Moscow

ENV CONSUL_HTTP_ADDR=
ENV CONSUL_TOKEN=

ENV SYNC_SERVICE=
ENV SYNC_FOLDERS=
ENV SYNC_IP=
ENV SYNC_PORT=22000
ENV SYNC_IGNORE_DELETE=

CMD ["/usr/local/bin/start.sh"]
