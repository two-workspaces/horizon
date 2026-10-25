# Deploy and Host Horizon Minecraft Server on Railway

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/horizon-minecraft-server?referralCode=sLjDXb&utm_medium=integration&utm_source=button&utm_campaign=horizon-minecraft-server)

[Horizon](https://github.com/ludovic111/horizon) is Minecraft: Java Edition 26.3 rewritten in Rust. It is one native program with no Java, checked against vanilla by 281 differential harnesses. This template runs its dedicated server, `horizon-server`, on Railway. Vanilla 26.3 clients join it like any other server, it is ready a few seconds after boot, and it idles at about 0.6 GB of memory, where a Java server with a 4 GB heap uses 3 to 4 GB.

## About Hosting Horizon Minecraft Server

It's one service, a Railway volume for the world, and a TCP proxy for players.

- **Your own game files.** Horizon contains nothing of Mojang's and never downloads it, so the server runs on the files your Horizon launcher prepared from your own copy of Minecraft. Zip that folder, put it at a download link, and the server copies it onto its volume on first boot (about 15 MB to download).
- **Whitelisted from the start.** The server is created with your Minecraft names on the whitelist and the first one as operator, so strangers who find the address can't join.
- **Cheap when nobody plays.** With no players online the world pauses after 60 seconds, and memory stays around 0.6 GB.
- **Safe redeploys.** On a redeploy the server saves the world and stops cleanly first. Automatic backups run every 6 hours, and the last 12 are kept.

## Common Use Cases

- A survival world for friends on vanilla Minecraft 26.3, for less memory than a Java server
- A server for players of the Horizon client (in offline mode, see below)
- Trying Horizon's server on a real public address before running it at home

## Dependencies for Horizon Minecraft Server Hosting

- Minecraft: Java Edition 26.3, and the Horizon launcher, which prepares the game files from it
- Railway's Trial plan or above: the server idles at about 0.6 GB and uses 0.7 to 1.1 GB with players

### Deployment Dependencies

- [Horizon on GitHub](https://github.com/ludovic111/horizon)
- [Host a server (Horizon docs)](https://playhorizon.dev/docs/hosting)
- [Template source on GitHub](https://github.com/two-workspaces/horizon)

### Implementation Details

**1. Prepare the game files.** Install the [Horizon launcher](https://playhorizon.dev) and press Prepare on its Play page. It reads your own Minecraft 26.3 install (play 26.3 once in the official launcher first). The prepared folder is `26.3`, in:

- Linux: `~/.local/share/horizon-launcher/versions/<version>/.local/horizon-client/26.3`
- macOS: `~/Library/Application Support/horizon-launcher/versions/<version>/.local/horizon-client/26.3`
- Windows: `%APPDATA%\horizon-launcher\versions\<version>\.local\horizon-client\26.3`

The folder has `horizon-resources.json` in it. Zip the folder (or `tar czf 26.3.tar.gz 26.3`).

**2. Give the server a link to it.** Upload the archive anywhere that gives a direct download link: a Dropbox link ending in `?dl=1`, a presigned S3 or R2 URL, or your own web server. The link must download the file itself, not a page about it. Keep it private: the files are derived from Minecraft and are yours, not for sharing. Paste the link into `HORIZON_RESOURCES_URL`. The server downloads it once onto its volume, so you can delete the upload afterwards.

**3. Accept the EULA and add players.** Set `HORIZON_EULA` to `true` to accept [Mojang's EULA](https://aka.ms/MinecraftEULA). Put your Minecraft name in `HORIZON_PLAYERS`, and your friends' names after it, separated by commas. These three values are only read on the first start. Until all three are set, the deploy logs say what's missing and the server waits.

**Join.** The address is in the service's Settings → Networking, under TCP Proxy (like `xyz.proxy.rlwy.net:12345`), and in the deploy logs on the line starting "Players join at". In Minecraft 26.3, go to Multiplayer → Add Server and paste it.

**Online and offline mode.** With `HORIZON_ONLINE=true`, the default, the server checks Minecraft accounts as vanilla's does: players join with the official launcher and their own account. Horizon's own client can't sign in to a Microsoft account yet, so it only joins offline servers. `HORIZON_ONLINE=false` lets it join, but an offline server never checks accounts: anyone who has the address can join under any name that's on the whitelist. Only do that for a private address you share with people you trust.

**Run the server.** Open a shell with `railway ssh --service Horizon` (Railway CLI), then `cd /data` and use `horizon-server`: `status` (TPS, players, RAM), `whitelist add NAME`, `op NAME`, `cmd say Hello` (any console command), `logs -n 100`, `backup`, `backups` and `restore NAME`. Settings live in `/data/server.toml`: `horizon-server config set world.difficulty=hard server.max_players=10`, then redeploy. Horizon's web panel is kept on 127.0.0.1 inside the container, because it isn't meant for the open internet.

**Updates.** The template pins Horizon v0.2.57. A newer template version updates the server program. If a new release asks for newly prepared files, prepare again in the launcher, upload the new archive and change `HORIZON_RESOURCES_URL` to its link: a changed link is downloaded again on the next start, and the world is left alone.

**Limits.** No mods with Java code, and no Bedrock players (Railway's TCP proxy can't carry UDP). Horizon is young and moves fast. Its [known issues](https://github.com/ludovic111/horizon#known-issues) apply here too.

Horizon is not an official Minecraft product, and is not approved by or associated with Mojang or Microsoft.

## Why Deploy Horizon Minecraft Server on Railway?

Railway is a singular platform to deploy your infrastructure stack. Railway will host your infrastructure so you don't have to deal with configuration, while allowing you to vertically and horizontally scale it.

By deploying Horizon Minecraft Server on Railway, you are one step closer to supporting a complete full-stack application with minimal burden. Host your servers, databases, AI agents, and more on Railway.
