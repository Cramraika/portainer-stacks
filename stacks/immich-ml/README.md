# immich-ml

Immich machine-learning (CLIP semantic search + face recognition) — **relocated
to compute-1** (operator override 2026-06-08; see
[ADR-096 Amendment A1](https://github.com/Cramraika/platform-docs/blob/main/04-decision-memory/adrs/ADR-096-fleet-capacity-rebalance-and-reduced-footprint.md#amendment-a1--immich-ml-runs-relocated-to-compute-1-operator-override-2026-06-08)).

| Field | Value |
|---|---|
| **Host** | vagary-compute-1 (8 vCPU / 32 GB) |
| **Deploy mechanism** | Plain docker-compose at `/opt/immich-ml/docker-compose.yml` on compute-1 — **NOT** a Portainer-managed stack today (unlike the core-1 `immich` stack — id 18 per live BoltDB probe 2026-06-08, ids drift on recreate — which is Portainer Git-backed). This file is the Git-backed IaC source; deploy with `docker compose -f /opt/immich-ml/docker-compose.yml up -d`. If onboarded into compute-1's Portainer later, point that endpoint's stack Git source at this dir. |
| **ML port** | `100.64.0.2:3003` — compute-1's **tailnet** IP; reachable only over the Headscale tailnet (never public). |
| **Reached by** | `immich_server` on core-1 via `machineLearning.urls=["http://100.64.0.2:3003"]` in `/etc/immich/config.json` (rendered from `vps-ansible …/main_host/immich-config.tpl`). |
| **History** | Was a service block inside the core-1 `immich` stack until 2026-06-08; split out + relocated to compute-1 per the operator override of ADR-096 D4. |

## Why relocated

ADR-096 D2.2/D4 (2026-06-07) shed Immich-ML OFF core-1 (kept it stopped) and
RULED OUT relocating it to compute-1 on an axis-mismatch argument. The operator
overrode that on 2026-06-08 (ADR-096 Amendment A1): with ~18 GB free on compute-1
at that time and ADR-054-D1 having moved CI/CD off compute-1, the RAM-peak
objection no longer binds. ML runs again — relocated, not shed — so CLIP search +
face recognition are retained.

## From-scratch prerequisites

The **external `monitoring` docker network must already exist on compute-1**
before first `up` (the ML container joins it so compute-1's prometheus/cadvisor
scrape the container). Create it if absent:

```bash
docker network create monitoring   # only if `docker network ls` lacks it
```

## VERSION-PIN RULE

The `immich-machine-learning` image tag here **MUST equal** the
`immich-server` image tag in
[`../immich/docker-compose.yml`](../immich/docker-compose.yml) on **every**
upgrade. Server (core-1) and ML (compute-1) now live in two compose files on two
hosts — an upgrade must touch BOTH, and a server↔ML version skew is an
unsupported Immich configuration.

## Changing the deployed config

This is a plain-compose deployment (not Portainer Git-sync). To change the
running ML deployment:

1. Edit `docker-compose.yml` in this directory
2. Commit + push to `main`
3. On compute-1, pull this repo and `docker compose -f /opt/immich-ml/docker-compose.yml up -d`
   (or copy the updated file into place if `/opt/immich-ml/` is not a checkout)
