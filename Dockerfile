FROM alpine:3.20

ARG FRP_VERSION=0.65.0

RUN apk add --no-cache ca-certificates wget tar gettext && \
    mkdir -p /tmp/frp && \
    cd /tmp/frp && \
    wget -q "https://github.com/fatedier/frp/releases/download/v${FRP_VERSION}/frp_${FRP_VERSION}_linux_amd64.tar.gz" && \
    tar -xzf "frp_${FRP_VERSION}_linux_amd64.tar.gz" && \
    install -m 0755 "frp_${FRP_VERSION}_linux_amd64/frps" /usr/bin/frps && \
    rm -rf /tmp/frp && \
    mkdir -p /etc/frp /var/frp

EXPOSE 7200 7500

COPY frps.ini /etc/frp/frps.ini
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

VOLUME ["/etc/frp", "/var/frp"]

ENTRYPOINT ["/entrypoint.sh"]
