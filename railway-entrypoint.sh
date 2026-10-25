#!/bin/sh
# Railway gives the service one volume at /data: the server folder (server.toml, world, backups) and
# resources/, the deployer's own prepared Minecraft 26.3 files, which horizon-server finds there by itself.
set -eu
cd /data

wait_for() {
  echo "$1"
  echo "Set the variable in the service's Variables tab; Railway redeploys and the server starts then."
  # Sleeping instead of exiting: a crash loop would only repeat this message.
  exec sleep infinity
}

# Fetched again whenever the URL changes, so new files (after a Horizon update) are one variable away.
if [ -n "${HORIZON_RESOURCES_URL:-}" ] && [ "$(cat resources/.source-url 2>/dev/null)" != "$HORIZON_RESOURCES_URL" ]; then
  echo "Fetching your prepared game files from HORIZON_RESOURCES_URL"
  rm -rf .resources-download && mkdir -p .resources-download/files
  curl -fL --retry 3 -o .resources-download/archive "$HORIZON_RESOURCES_URL" \
    || wait_for "Couldn't download HORIZON_RESOURCES_URL (above). Check the link opens without signing in."
  bsdtar -xf .resources-download/archive -C .resources-download/files \
    || wait_for "HORIZON_RESOURCES_URL isn't a .zip or .tar.gz archive (a share page instead of the file itself?)."
  found=$(find .resources-download/files -name horizon-resources.json -print | head -n 1)
  if [ -z "$found" ]; then
    rm -rf .resources-download
    wait_for "The archive at HORIZON_RESOURCES_URL has no horizon-resources.json: zip the prepared 26.3 folder itself (see the template README)."
  fi
  rm -rf resources && mv "$(dirname "$found")" resources && rm -rf .resources-download
  printf '%s' "$HORIZON_RESOURCES_URL" > resources/.source-url
  echo "Game files ready in /data/resources"
fi

[ -f resources/horizon-resources.json ] || wait_for \
  "No game files yet. Horizon runs on your own copy of Minecraft 26.3: zip the 26.3 folder your Horizon launcher prepared, put it at a link this server can download, and set HORIZON_RESOURCES_URL to that link."

if [ ! -f server.toml ]; then
  case "${HORIZON_EULA:-}" in
    [Tt][Rr][Uu][Ee]) export HORIZON_EULA=true ;;
    *) wait_for "Set HORIZON_EULA to true to accept the Minecraft EULA (https://aka.ms/MinecraftEULA)." ;;
  esac
  # The first player is the operator unless HORIZON_OP names someone else.
  first=${HORIZON_PLAYERS:-}
  first=${first%%,*}
  [ -n "${HORIZON_OP:-}" ] || [ -z "$first" ] || export HORIZON_OP="$first"
  horizon-server init --yes
fi

[ -z "${RAILWAY_TCP_PROXY_DOMAIN:-}" ] || echo "Players join at $RAILWAY_TCP_PROXY_DOMAIN:$RAILWAY_TCP_PROXY_PORT"
exec horizon-server run
