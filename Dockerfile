FROM alpine:latest

WORKDIR /

RUN apk --update add bash autossh jq && rm -rf /var/cache/apk/*

COPY entrypoint.sh /entrypoint.sh
COPY restart-tunnels.sh /restart-tunnels.sh

RUN mkdir /config

CMD /entrypoint.sh
