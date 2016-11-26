FROM tianon/syncthing:0.14

ENV CONSUL_HTTP_ADDR=
ENV CONSUL_TOKEN=

ENV SYNC_SERVICE=
ENV SYNC_NAME=
ENV SYNC_FOLDERS=

COPY consul-template_0.18.0-rc1_SHA256SUMS /usr/local/bin/consul-template_0.18.0-rc1_SHA256SUMS

USER root

RUN \
  apk add --update-cache curl unzip

RUN \
  cd /usr/local/bin \

  && curl -L https://releases.hashicorp.com/consul-template/0.18.0-rc1/consul-template_0.18.0-rc1_linux_amd64.zip -o consul-template_0.18.0-rc1_linux_amd64.zip \
  && sha256sum -c consul-template_0.18.0-rc1_SHA256SUMS \
  && unzip consul-template_0.18.0-rc1_linux_amd64.zip \
  && rm consul-template_0.18.0-rc1_linux_amd64.zip consul-template_0.18.0-rc1_SHA256SUMS

RUN \
  apk del unzip && rm -rf /var/cache/apk/*

COPY start.sh /usr/local/bin/start.sh

USER user

COPY config.xml.template /home/user/config.xml.template

CMD /usr/local/bin/start.sh
