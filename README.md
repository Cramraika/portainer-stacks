# portainer-stacks

Git-sync source-of-truth for Portainer stacks per #56 migration (Phase 7 close 2026-04-26).

Per ADR-022 reconciliation-boundary: Portainer's BoltDB historically held compose definitions; Phase 7 migrates to Git-sync mode where this repo is canonical + Portainer pulls.

## Layout

```
stacks/<stack-name>/
├── docker-compose.yml      # canonical compose
├── README.md               # stack purpose + ports + dependencies
└── .env.example            # NON-SECRET defaults; secrets from Portainer's Infisical-rendered env
scripts/
├── portainer-export.sh     # operator helper: export current Portainer stacks
├── portainer-import.sh     # operator helper: re-onboard via Git-sync
└── portainer-verify.sh     # operator helper: verify stack health post-migration
```

## Migration procedure (operator-supervised)

Per `platform-docs/docs/runbooks/portainer-git-sync.md`. Pre-conditions:
- Portainer admin API token (operator-CFR; per kickoff coordinator default: local-admin auth retained)
- This repo accessible from Portainer's environment (HTTPS clone via PAT, or SSH key)

### Per-stack migration steps

1. Export current stack: `scripts/portainer-export.sh <stack-id> > stacks/<name>/docker-compose.yml`
2. Add stack metadata: `stacks/<name>/README.md` + `.env.example` (non-secret only)
3. Commit + push
4. In Portainer UI: Edit stack → switch to "Git Repository" mode
   - URL: this repo
   - Reference: `refs/heads/main`
   - Compose path: `stacks/<name>/docker-compose.yml`
   - Auto-update: enabled (poll interval 5min)
5. Verify: `scripts/portainer-verify.sh <stack-name>`
6. After 2-week confidence period: archive BoltDB stack record

### Rollback per-stack (if migration breaks)

1. In Portainer UI: switch stack back to "Web editor" mode
2. Paste original compose YAML from `/var/lib/docker/volumes/portainer_data/_data/data.db.bak.<date>` (Portainer auto-backups BoltDB)
3. Stack remains in Web-editor mode pending re-attempt

## Stack inventory (populated per-migration)

Pending operator-supervised export. Expected stacks (per Phase 3 D1 inventory):

| Stack | Host | Status |
|---|---|---|
| immich | Main | pending export |
| cronicle | Main | pending export (legacy; may retire) |
| dns-proxy | Main | pending export |
| (others discovered at export time) | — | — |

## Cross-references

- `platform-docs/04-decision-memory/adrs/ADR-022-reconciliation-boundaries.md`
- `platform-docs/04-decision-memory/adrs/ADR-029-ansible-scope-vs-coolify-boundary.md`
- `platform-docs/docs/runbooks/portainer-git-sync.md`
- `platform-docs/09-trackers/discovery-D1-services-20260420.md` § Portainer
