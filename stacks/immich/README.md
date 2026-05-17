# immich

Self-hosted photo and video management — [immich.app](https://immich.app/).

| Field | Value |
|---|---|
| **Host** | vagary-core-1 |
| **Portainer stack ID** | 8 |
| **Captured** | 2026-05-16 (OW-17 — first portainer-stacks migration); refreshed 2026-05-17 via Portainer API |
| **Web port** | `2283` (immich-server) |

## Services

| Service | Container | Image |
|---|---|---|
| immich-server | `immich_server` | `ghcr.io/immich-app/immich-server:v2.7.5` |
| immich-machine-learning | `immich_machine_learning` | `ghcr.io/immich-app/immich-machine-learning:v2.7.5` |
| redis | `immich_redis` | `docker.io/valkey/valkey:8-bookworm` (sha-pinned) |
| database | `immich_postgres` | `ghcr.io/immich-app/postgres:18-vectorchord0.5.3-pgvector0.8.1` |

## Environment variables

See [`.env.example`](./.env.example). At deploy time, secrets render via Infisical
into `immich.env` (symlinked as `.env` / `stack.env` in the Portainer compose dir).

- **Storage paths** — `UPLOAD_LOCATION` (rclone union mount, external storage),
  `LOCAL_STORAGE` (fast local storage for thumbs/encoded-video/cache/backups),
  `DB_DATA_LOCATION` (Postgres data dir).
- **DB credentials** — `DB_PASSWORD` (secret), `DB_USERNAME`, `DB_DATABASE_NAME`.

## Dependencies

`immich-server` depends on `redis` and `database`. The original library is
served from an rclone union mount; all transient/derived data lives on fast
local storage to avoid rclone overhead.

## Re-capture

The compose file is exported from the live Portainer stack via the API.
Portainer's public hostname sits behind a Cloudflare Access gate, so the
export runs against the container directly on the host:

```sh
ssh vagary-core-1
BASE=https://127.0.0.1:9443
TOK=$(curl -sk -X POST $BASE/api/auth \
  -H 'Content-Type: application/json' \
  -d "{\"username\":\"cadmin\",\"password\":\"<PORTAINER_PASSWORD from vps_host/.env>\"}" \
  | python3 -c 'import sys,json;print(json.load(sys.stdin)["jwt"])')
curl -sk $BASE/api/stacks/8/file -H "Authorization: Bearer $TOK" \
  | python3 -c 'import sys,json;print(json.load(sys.stdin)["StackFileContent"],end="")'
```

`docker-compose.yml` here was refreshed 2026-05-17 from the live stack
(immich `v2.7.4` → `v2.7.5` drift corrected).
