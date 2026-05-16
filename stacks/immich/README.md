# immich

Self-hosted photo and video management — [immich.app](https://immich.app/).

| Field | Value |
|---|---|
| **Host** | vagary-core-1 |
| **Portainer stack ID** | 8 |
| **Captured** | 2026-05-16 (OW-17 — first portainer-stacks migration) |
| **Web port** | `2283` (immich-server) |

## Services

| Service | Container | Image |
|---|---|---|
| immich-server | `immich_server` | `ghcr.io/immich-app/immich-server:v2.7.4` |
| immich-machine-learning | `immich_machine_learning` | `ghcr.io/immich-app/immich-machine-learning:v2.7.4` |
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

```sh
PORTAINER_URL=https://portainer.chinmayramraika.in \
PORTAINER_API_TOKEN=<from-Infisical> \
../../scripts/portainer-export.sh 8
```

This README was captured directly from the live Portainer BoltDB compose on
vagary-core-1 (`/var/lib/docker/volumes/portainer_data/_data/compose/8/`) because
a Portainer API token was not available to the capturing session.
