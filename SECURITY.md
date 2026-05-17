# Security Policy

Security issues in this repo usually fall into one of two categories:

- Secrets or internal endpoints were committed to a stack manifest or helper
  script.
- The documented Portainer Git-sync workflow would leak or persist secrets in a
  non-canonical place.

## Reporting

Report vulnerabilities privately to `chinu.ramraika@gmail.com`.

## Security posture

- `.env.example` contains non-secret defaults only.
- Real deploy-time secrets come from Infisical.
- Portainer API tokens, repo PATs, and registry credentials must never be
  committed here.
- Avoid the Portainer UI env-var panel for long-lived secrets because it writes
  values to persistent VPS storage.

## Cross-references

- `README.md`
- `platform-docs/docs/runbooks/portainer-git-sync.md`
- `platform-docs/04-decision-memory/adrs/ADR-022-reconciliation-boundaries.md`

