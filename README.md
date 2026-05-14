# portainer-stacks

> **Public OSS** | Tier C infra-config | Vagary Labs / VPS-infra cluster

Git-sync source-of-truth for [Portainer](https://www.portainer.io/) Docker Compose stacks. Per ADR-022 reconciliation-boundary, Portainer's BoltDB historically held compose definitions in-band; this repo is the canonical out-of-band declarative source from which Portainer pulls.

**Companion repos** (VPS-infra cluster): [`vps_host`](https://github.com/Cramraika/vps_host) (runtime ops, live scripts, cron) · [`vps-ansible`](https://github.com/Cramraika/vps-ansible) (substrate IaC) · [`platform-docs`](https://github.com/Cramraika/platform-docs) (authoritative VPS docs SSOT) · [`host_page`](https://github.com/Cramraika/host_page) (admin landing).

## Status

**Phase 7 migration in-flight.** The `stacks/` directory is intentionally empty pending operator-supervised export from live Portainer BoltDB. Expected first migrations: `immich`, `dns-proxy`, and (legacy) `cronicle`. See [Migration procedure](#migration-procedure-operator-supervised) below.

The 3 operator-helper scripts under `scripts/` are stable and Portainer-API-validated.

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

Populated per-migration. Expected stacks (per the discovery inventory archived at `platform-docs/09-trackers/.archived/discovery-D1-services-20260420.md`):

| Stack | Host | Status |
|---|---|---|
| immich | `vagary-core-1` | pending export |
| cronicle | `vagary-core-1` | pending export (legacy; may retire) |
| dns-proxy | `vagary-core-1` | pending export |
| (others discovered at export time) | — | — |

## Forking / reuse

This repo is public to make the operator-helper scripts reusable. To fork:

1. Replace this README's references with your own org / Portainer URL
2. Replace `REPO_URL` defaults in scripts with your fork
3. Decide whether your stacks are public — if any compose carries product-internal config, keep the fork private
4. Provision an Infisical (or comparable secrets manager) instance to render `.env` at deploy time — never inline secrets in compose

## Cross-references

- [`platform-docs/04-decision-memory/adrs/ADR-022-reconciliation-boundaries.md`](https://github.com/Cramraika/platform-docs/blob/main/04-decision-memory/adrs/ADR-022-reconciliation-boundaries.md) — *why* Git-sync is canonical
- [`platform-docs/04-decision-memory/adrs/ADR-029-ansible-scope-vs-coolify-boundary.md`](https://github.com/Cramraika/platform-docs/blob/main/04-decision-memory/adrs/ADR-029-ansible-scope-vs-coolify-boundary.md) — *what goes where* between vps-ansible / Coolify / Portainer
- [`platform-docs/docs/runbooks/portainer-git-sync.md`](https://github.com/Cramraika/platform-docs/blob/main/docs/runbooks/portainer-git-sync.md) — operator-supervised migration runbook
- [`vps-ansible/roles/observability/`](https://github.com/Cramraika/vps-ansible/tree/main/roles/observability) — Prometheus scrape config that will consume per-stack `/metrics` endpoints once stacks ship

## License

See repository LICENSE. Scripts are operational helpers — provided as-is; review before running against your own Portainer instance.
