# Horizon's prebuilt Linux server release: horizon-server (the supervisor) and horizon-engine (the game,
# built without sound or controllers). No Minecraft files are in the image: the deployer brings their own.
FROM debian:bookworm-slim

# upgrade: github horizon-rust/horizon
ARG HORIZON_VERSION=v0.2.97
# GitHub's own digest of the upstream asset. A version bump must change it too.
ARG HORIZON_SHA256=57422db46533e077277ef1505dcc03805d52d15f3a213200569118c36c5f7cc9

# The upstream repo has returned 404 since 2026-11-25, so the build falls back to our unmodified mirror of
# the same file (MIT). Either source must match the pinned digest.
RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates curl libarchive-tools \
 && rm -rf /var/lib/apt/lists/* \
 && cd /tmp \
 && asset=horizon-server-linux-x86_64.tar.gz \
 && { curl -fsSL -o $asset https://github.com/horizon-rust/horizon/releases/download/$HORIZON_VERSION/$asset \
   || curl -fsSL -o $asset https://github.com/two-workspaces/horizon/releases/download/upstream-$HORIZON_VERSION/$asset; } \
 && echo "$HORIZON_SHA256  $asset" | sha256sum -c - \
 && mkdir /opt/horizon \
 && tar xzf $asset -C /opt/horizon --strip-components=1 \
 && rm -f /tmp/*

# Updates come with the template's image, not horizon-server's own updater.
ENV PATH=/opt/horizon:$PATH \
    HORIZON_NO_AUDIO=1 \
    HORIZON_NO_UPDATE_CHECK=1

COPY --chmod=0755 railway-entrypoint.sh /railway-entrypoint.sh
WORKDIR /data
EXPOSE 25565
ENTRYPOINT ["/railway-entrypoint.sh"]
