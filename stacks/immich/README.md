# immich

Self-hosted photo and video management — [immich.app](https://immich.app/).

| Field | Value |
|---|---|
| **Host** | vagary-core-1 |
| **Portainer stack ID** | 8 |
| **Stack mode** | **Git-backed** — Portainer pulls this `docker-compose.yml` from this repo (hourly auto-update poll). This repo IS the live source of truth, not a mirror/export. |
| **History** | Captured 2026-05-16 (OW-17 — first portainer-stacks migration); migrated to Portainer Git-sync 2026-05-17 (W8) |
| **Web port** | `2283` (immich-server) |

## Services

| Service | Container | Image |
|---|---|---|
| immich-server | `immich_server` | `ghcr.io/immich-app/immich-server:v2.7.5` |
| immich-machine-learning | `immich_machine_learning` | `ghcr.io/immich-app/immich-machine-learning:v2.7.5` |
| redis | `immich_redis` | `docker.io/valkey/valkey:8-bookworm` (sha-pinned) |
| database | `immich_postgres` | `ghcr.io/immich-app/postgres:18-vectorchord0.5.3-pgvector0.8.1` |

## Environment variables

See [`.env.example`](./.env.example). The compose `env_file` points at the
**absolute Infisical-rendered path** `/root/.infisical-rendered/immich.env` —
this survives Portainer's git-redeploy (which rewrites `stack.env`) and keeps
`DB_PASSWORD` out of the Portainer BoltDB (ADR-012 Mechanism-A preserved).

- **Storage paths** — `UPLOAD_LOCATION` (rclone union mount, external storage),
  `LOCAL_STORAGE` (fast local storage for thumbs/encoded-video/cache/backups),
  `DB_DATA_LOCATION` (Postgres data dir).
- **DB credentials** — `DB_PASSWORD` (secret), `DB_USERNAME`, `DB_DATABASE_NAME`.

## Dependencies

`immich-server` depends on `redis` and `database`. The original library is
served from an rclone union mount; all transient/derived data lives on fast
local storage to avoid rclone overhead.

## Changing the deployed config

This stack is **Git-backed** — Portainer auto-polls this repo and redeploys on
change. To change the running immich deployment:

1. Edit `docker-compose.yml` in this directory
2. Commit + push to `main`
3. Portainer picks up the change on its next poll (or trigger a manual redeploy
   in the Portainer UI: stack → "Pull and redeploy")

Do **not** edit the stack in the Portainer web editor — Git-sync mode would
overwrite editor changes on the next poll. The repo is the source of truth.
