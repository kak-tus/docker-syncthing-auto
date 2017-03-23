FROM tianon/syncthing:0.14

ENV CONSUL_TEMPLATE_VERSION=0.16.0
ENV CONSUL_TEMPLATE_SHA256=064b0b492bb7ca3663811d297436a4bbf3226de706d2b76adade7021cd22e156

USER root

RUN \
  apk add --no-cache --virtual .build-deps \
  curl unzip \

  && apk add --no-cache su-exec \

  && cd /usr/local/bin \
  && curl -L https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip -o consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip \
  && echo -n "$CONSUL_TEMPLATE_SHA256  consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip" | sha256sum -c - \
  && unzip consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip \
  && rm consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip \

  && apk del .build-deps

COPY start.sh /usr/local/bin/start.sh
COPY syncthing.hcl /etc/syncthing.hcl
COPY skip.sh /usr/local/bin/skip.sh
COPY config.xml.template /home/user/config.xml.template

ENV USER_UID=1000
ENV USER_GID=1000

ENV CONSUL_HTTP_ADDR=
ENV CONSUL_TOKEN=

ENV SYNC_SERVICE=
ENV SYNC_FOLDERS=
ENV SYNC_IP=

CMD [ "/usr/local/bin/start.sh" ]
