# Contributing to portainer-stacks

This repo is the Git-sync source-of-truth for Portainer-managed Docker Compose
stacks. It is intentionally small: stack manifests, per-stack readmes, and a
few operator helper scripts.

## Core rules

- `stacks/<name>/docker-compose.yml` is the canonical manifest for a migrated
  stack.
- `stacks/<name>/README.md` explains purpose, ports, dependencies, and expected
  secrets handling.
- `stacks/<name>/.env.example` may contain non-secret defaults only.
- Real secrets must come from Infisical at deploy time. Never commit `.env`,
  tokens, passwords, or private registry credentials.

## Migration discipline

- Do not invent stack state from memory. Export from live Portainer first, then
  normalize the compose into this repo.
- Keep rollback notes and verification steps in the stack readme or linked
  runbook, not in commit-message-only lore.
- If a stack is still runtime-only and not yet exported, leave it out of
  `stacks/` rather than creating a speculative placeholder.

## Cross-references

- `README.md` — repo role, migration flow, and stack inventory
- `platform-docs/docs/runbooks/portainer-git-sync.md` — canonical migration
  runbook
- `platform-docs/04-decision-memory/adrs/ADR-022-reconciliation-boundaries.md`
  — reconciliation boundary rationale

