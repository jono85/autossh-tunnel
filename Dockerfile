FROM alpine:latest

WORKDIR /

COPY entrypoint.sh /entrypoint.sh
COPY restart-tunnels.sh /restart-tunnels.sh

RUN apk --update add bash autossh jq && rm -rf /var/cache/apk/*

RUN mkdir /config
RUN chmod +x /entrypoint.sh
RUN chmod +x /restart-tunnels.sh

CMD /entrypoint.sh
