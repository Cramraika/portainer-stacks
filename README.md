# portainer-stacks

> **Public OSS** | Tier C infra-config | Vagary Labs / VPS-infra cluster

Git-sync source-of-truth for [Portainer](https://www.portainer.io/) Docker Compose stacks. Per ADR-022 reconciliation-boundary, Portainer's BoltDB historically held compose definitions in-band; this repo is the canonical out-of-band declarative source from which Portainer pulls.

**Companion repos** (VPS-infra cluster): [`vps_host`](https://github.com/Cramraika/vps_host) (runtime ops, live scripts, cron) · [`vps-ansible`](https://github.com/Cramraika/vps-ansible) (substrate IaC) · [`platform-docs`](https://github.com/Cramraika/platform-docs) (authoritative VPS docs SSOT) · [`host_page`](https://github.com/Cramraika/host_page) (admin landing).

## Status

**All live Portainer stacks captured (2026-05-17).** The live Portainer host
(`vagary-core-1`) was enumerated via the API: it has exactly two stacks —
`immich-app` (**Git-backed from this repo** — Portainer auto-polls
`stacks/immich/docker-compose.yml` hourly) and `anjaan_online` (git-deployed;
compose lives in the `anjaan-app` repo, documented at `stacks/anjaan_online/`).
`cronicle` and `dns-proxy` — named in an early discovery inventory — were never
created as Portainer stacks; they are not pending exports. See
[Stack inventory](#stack-inventory).

The 3 operator-helper scripts under `scripts/` are stable and Portainer-API-validated.

**Not-in-scope: Traefik (coolify-proxy).** Traefik on `vagary-compute-1` is
Coolify-substrate (ADR-029 / Principle #12 — never hand-edit `/data/coolify/proxy/*`),
**not** a Portainer stack. Portainer manages `vagary-core-1` stacks only (e.g. `immich`).
For Traefik edge config see the platform-docs appendix
[`05-architecture/part-B-service-appendices/vps-admin/substrate/traefik.md`](https://github.com/Cramraika/platform-docs/blob/main/05-architecture/part-B-service-appendices/vps-admin/substrate/traefik.md).

## Layout

```
stacks/<stack-name>/             # populated per-migration (see "Stack inventory")
├── docker-compose.yml           # canonical compose
├── README.md                    # purpose + image + ports + env vars + dependencies
└── .env.example                 # NON-SECRET defaults; secrets render via Infisical at deploy
scripts/
├── portainer-export.sh          # extract a stack from Portainer's BoltDB → compose YAML
├── portainer-import.sh          # POST a stack to Portainer in Git-sync mode
└── portainer-verify.sh          # verify stack health post-deploy
lychee.toml                      # link-checker config (gitignored per project-hygiene §3)
```

## Scripts

All scripts read configuration from environment variables; no hard-coded credentials. Run from repo root.

| Script | Purpose | Required env |
|---|---|---|
| `scripts/portainer-export.sh <stack-id>` | Dump a stack's compose YAML to stdout. Use `--list` to enumerate stacks first. | `PORTAINER_URL`, `PORTAINER_API_TOKEN` |
| `scripts/portainer-import.sh <stack-name>` | Re-onboard a stack into Portainer in Git-sync mode (Portainer thereafter pulls from this repo on a 5-minute auto-update interval). | `PORTAINER_URL`, `PORTAINER_API_TOKEN`, `PORTAINER_ENDPOINT_ID`, `REPO_URL`; optional `REPO_REF` (default `refs/heads/main`), `REPO_PAT` (for private repos) |
| `scripts/portainer-verify.sh <stack-name>` | Container-health summary for a Compose project (run on the VPS where the stack runs). | none — uses local `docker` |

## Migration procedure (operator-supervised)

Authoritative runbook: [`platform-docs/docs/runbooks/portainer-git-sync.md`](https://github.com/Cramraika/platform-docs/blob/main/docs/runbooks/portainer-git-sync.md).

**Pre-conditions:**
- Portainer admin API token (operator-CFR; local-admin auth retained per kickoff coordinator default)
- This repo accessible from Portainer's environment (HTTPS clone via PAT, or SSH key)

**Per-stack migration steps:**

1. Export current stack:
   ```bash
   scripts/portainer-export.sh <stack-id> > stacks/<name>/docker-compose.yml
   ```
2. Add stack metadata: `stacks/<name>/README.md` + `stacks/<name>/.env.example` (non-secret only)
3. Commit + push
4. Re-onboard via Git-sync:
   ```bash
   scripts/portainer-import.sh <name>
   ```
   Or via the Portainer UI: Edit stack → switch to "Git Repository" mode (URL = this repo, Reference = `refs/heads/main`, Compose path = `stacks/<name>/docker-compose.yml`, Auto-update enabled at 5-minute poll).
5. Verify:
   ```bash
   scripts/portainer-verify.sh <name>
   ```
6. After a confidence period of clean verifies, archive the BoltDB stack record.

**Per-stack rollback (if migration breaks):**

1. Portainer UI: switch the stack back to "Web editor" mode
2. Paste original compose YAML from `/var/lib/docker/volumes/portainer_data/_data/data.db.bak.<date>` (Portainer auto-backups BoltDB)
3. Stack stays in Web-editor mode pending re-attempt

## Secrets

`.env.example` files contain **non-secret defaults only**. Real secrets render into Portainer at deploy time via Infisical (see [`platform-docs`](https://github.com/Cramraika/platform-docs) §50.3 — Infisical is the canonical secrets surface).

**Never paste real secret values into the Portainer Stack env-vars panel.** The Portainer UI persists pasted values to disk on the VPS, which violates the Infisical-canonical rule and cannot be revoked centrally if leaked. Reference Infisical-rendered values only.

## Stack inventory

Populated per-migration. Live Portainer (`vagary-core-1`) was enumerated via the
API on 2026-05-17 — it currently has exactly **two** stacks:

| Stack | Portainer ID | Host | Status |
|---|---|---|---|
| immich-app | 8 | `vagary-core-1` | **Git-backed** — `stacks/immich/docker-compose.yml` is the live source; Portainer auto-polls this repo hourly (migrated to Git-sync 2026-05-17, W8) |
| anjaan_online | 14 | `vagary-core-1` | git-deployed — compose lives in the `anjaan-app` repo, not exportable; documented at `stacks/anjaan_online/` |

The early discovery inventory (since retired) named `cronicle` and `dns-proxy`
— **neither was ever created as a Portainer stack** on the live host (confirmed
by API enumeration 2026-05-17). They are not pending exports; the inventory item
is closed. Current canonical home for this finding:
[`platform-docs/02-governance/service-playbooks/substrate/portainer.md`](https://github.com/Cramraika/platform-docs/blob/main/02-governance/service-playbooks/substrate/portainer.md).

## Forking / reuse

This is a **public** repo — the compose definitions carry only non-secret VPS
config (host paths, image tags/digests, network names). All secrets render at
deploy time via Infisical and never live here. The operator-helper scripts
under `scripts/` are generic; to reuse them in your own setup:

1. Replace this README's references with your own org / Portainer URL
2. Replace `REPO_URL` defaults in scripts with your own repo
3. Provision an Infisical (or comparable secrets manager) instance to render `.env` at deploy time — never inline secrets in compose
4. Keep any compose that genuinely must carry product-internal config in a separate private repo

## Cross-references

- [`platform-docs/04-decision-memory/adrs/ADR-022-reconciliation-boundaries.md`](https://github.com/Cramraika/platform-docs/blob/main/04-decision-memory/adrs/ADR-022-reconciliation-boundaries.md) — *why* Git-sync is canonical
- [`platform-docs/04-decision-memory/adrs/ADR-029-ansible-scope-vs-coolify-boundary.md`](https://github.com/Cramraika/platform-docs/blob/main/04-decision-memory/adrs/ADR-029-ansible-scope-vs-coolify-boundary.md) — *what goes where* between vps-ansible / Coolify / Portainer
- [`platform-docs/docs/runbooks/portainer-git-sync.md`](https://github.com/Cramraika/platform-docs/blob/main/docs/runbooks/portainer-git-sync.md) — operator-supervised migration runbook
- [`vps-ansible/roles/observability/`](https://github.com/Cramraika/vps-ansible/tree/main/roles/observability) — Prometheus scrape config that will consume per-stack `/metrics` endpoints once stacks ship
- [`CONTRIBUTING.md`](CONTRIBUTING.md) — stack-authoring and migration rules
- [`SECURITY.md`](SECURITY.md) — secret-handling and reporting posture

## License

See repository LICENSE. Scripts are operational helpers — provided as-is; review before running against your own Portainer instance.
