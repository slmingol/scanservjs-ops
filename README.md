# scanservjs-ops

![Build](https://img.shields.io/github/actions/workflow/status/slmingol/scanservjs-ops/build-push.yml?label=build&logo=github)
![GitHub last commit](https://img.shields.io/github/last-commit/slmingol/scanservjs-ops)
![GitHub repo size](https://img.shields.io/github/repo-size/slmingol/scanservjs-ops)
![Container](https://img.shields.io/badge/ghcr.io-slmingol%2Fscanservjs--ops-blue?logo=docker)
![Platform](https://img.shields.io/badge/platform-linux%2Famd64-lightgrey)

Web-based scanning for a Brother MFC-8480DN over WiFi on macOS, using a Debian Docker host as the scan relay.

## Architecture

```
Mac (macOS Tahoe)
    |
    | HTTP  :8088
    v
Debian x86 @ 192.168.7.38
  Docker container (scanservjs + brscan4)
    |
    | TCP/IP  brscan4 native protocol
    v
Brother MFC-8480DN @ 192.168.13.13
```

macOS has no working Brother SANE driver for Tahoe. The Debian Docker host runs [scanservjs](https://github.com/sbs20/scanservjs) with the Brother `brscan4` driver installed, exposing a web UI on port 8088. The Mac accesses it over the LAN.

## Files

| File | Purpose |
|------|---------|
| `Dockerfile.scanservjs` | Extends `sbs20/scanservjs:latest`, installs `brscan4` |
| `entrypoint.scanservjs.sh` | Registers scanner via `brsaneconfig4`, then launches scanservjs |
| `docker-compose.yaml` | Wires it together: port 8088, scanner IP env var, privileged mode |

## How it works

1. Container starts, `entrypoint.scanservjs.sh` runs as root
2. `brsaneconfig4 -a` registers the Brother scanner by IP with the SANE `brother4` backend
3. `scanimage -L` confirms the scanner is visible (logged to container stdout)
4. Original scanservjs entrypoint (`/entrypoint.sh`) takes over, starts the Node.js web server on port 8080
5. Web UI is available at `http://192.168.7.38:8088`

## Deploy

On the Debian host:

```bash
git clone https://github.com/slmingol/scanservjs-ops.git
cd scanservjs-ops
docker compose -f docker-compose.yaml up -d
```

`docker-compose.yaml` pulls `ghcr.io/slmingol/scanservjs-ops:latest` directly — no local build needed.

To pin a specific version, edit the `image:` line:

```yaml
image: ghcr.io/slmingol/scanservjs-ops:1.0.0
```

### Versioning

Images are tagged by CI on every push to `main` (`latest`) and on `v*.*.*` git tags (semver). To cut a release:

```bash
git tag v1.1.0
git push origin v1.1.0
```

Verify scanner detected:

```bash
docker logs scanservjs | grep -A5 "Detected scanners"
```

Expected output:

```
=== Detected scanners ===
device `brother4:net1;dev0' is a Brother MFC-8480DN
```

Open `http://192.168.7.38:8088` in a browser to scan.

## Troubleshoot

**Scanner not found at startup:**

```bash
docker exec -it scanservjs /opt/brother/scanner/brscan4/brsaneconfig4 -q
```

Should list `MFC-8480DN` with IP `192.168.13.13`. If missing, check scanner is powered on and reachable from the Debian host:

```bash
ping 192.168.13.13
```

**Re-register scanner without rebuild:**

```bash
docker exec -it scanservjs \
  /opt/brother/scanner/brscan4/brsaneconfig4 \
  -a name=MFC-8480DN model=MFC-8480DN ip=192.168.13.13
```

