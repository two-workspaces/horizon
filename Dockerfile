# Horizon's prebuilt Linux server release: horizon-server (the supervisor) and horizon-engine (the game,
# built without sound or controllers). No Minecraft files are in the image: the deployer brings their own.
FROM debian:bookworm-slim

# upgrade: github horizon-rust/horizon
ARG HORIZON_VERSION=v0.2.97

RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates curl libarchive-tools \
 && rm -rf /var/lib/apt/lists/* \
 && cd /tmp \
 && base=https://github.com/horizon-rust/horizon/releases/download/$HORIZON_VERSION \
 && curl -fsSLO $base/horizon-server-linux-x86_64.tar.gz -fsSLO $base/SHA256SUMS \
 && grep ' horizon-server-linux-x86_64.tar.gz$' SHA256SUMS | sha256sum -c - \
 && mkdir /opt/horizon \
 && tar xzf horizon-server-linux-x86_64.tar.gz -C /opt/horizon --strip-components=1 \
 && rm -f /tmp/*

# Updates come with the template's image, not horizon-server's own updater.
ENV PATH=/opt/horizon:$PATH \
    HORIZON_NO_AUDIO=1 \
    HORIZON_NO_UPDATE_CHECK=1

COPY --chmod=0755 railway-entrypoint.sh /railway-entrypoint.sh
WORKDIR /data
EXPOSE 25565
ENTRYPOINT ["/railway-entrypoint.sh"]
