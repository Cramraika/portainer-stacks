# portainer-stacks

Git-sync source-of-truth for Portainer stacks (per ADR-022 reconciliation-boundary; Phase 7 close 2026-04-26).

---

## Claude Preamble
<!-- VERSION: 2026-06-20-v53 -->
<!-- SYNC-SOURCE: ~/.claude/conventions/universal-claudemd.md -->

**Universal laws (§1–§55) load via user-level `~/.claude/conventions/` and are ALWAYS in context** — `universal-claudemd.summary.md` (≤50-line salient view, read FIRST) → `universal-claudemd.md` (full) + `project-hygiene.md`. Do **NOT** assume their content from memory; consult + verify before asserting (§34 / §43.6 / §43.7). The `## Active Cluster Playbooks` block below names this repo's situational playbooks **read-on-demand** (§49.10): Read the named playbook when its trigger fires — never guess its contents; always-load guardrails are inline. Sync: `~/.claude/scripts/sync-preambles.py` (manual cadence; run after any source edit).

## Active Cluster Playbooks (read-on-demand — §49.10; bodies at ~/.claude/conventions/playbooks/)
<!-- BEGIN PLAYBOOKS BLOCK (managed by sync-preambles.py — read-on-demand pointers per §49.10; bodies at ~/.claude/conventions/playbooks/) -->

These cluster playbooks apply to this repo. You do NOT know their contents from memory —
**Read the named file when its trigger fires; never assume** (§49.10, §34, §43.6). Bodies are
NOT inlined and NOT @-imported; the always-load GUARDRAILs below are the only parts that must
hold without a Read.

- `vps-infra.md` — when: DNS / VPS-infra / reverse-proxy work. GUARDRAIL: DNS authority is XOR — verify the canonical provider in vps-infra.md before any DNS change.
- `brand-registry.md` — when: brand / positioning / brand-canon / cross-repo brand work.
- `commercial-bound.md` — when: license / sponsor-readiness / graph-tool-output / white-label work. GUARDRAIL: never commit/ship GitNexus (PolyForm-NC) graph output from a commercial-bound repo — CGC is the canonical graph source.

<!-- END PLAYBOOKS BLOCK -->

## License classification: personal/private

## Cluster: VPS-infra

Part of the §45 VPS-infra cluster: vps_host, vps-ansible, platform-docs, portainer-stacks, host_page.

## §2 Stack naming + compose env-var conventions

Authored 2026-05-19 (W7 of platform-orchestration campaign). This repo flipped private → public 2026-05-18 (Portainer audit §14.5) so Portainer can clone the Git-backed stacks credential-free. Public-OSS posture requires explicit conventions so external readers (and forkers) understand the contract.

### §2.1 Stack directory naming

- **Path:** `stacks/<name>/` — one directory per Portainer Git-backed stack.
- **`<name>`:** kebab-case; MUST match the **Portainer stack name** registered in the Portainer UI (case-sensitive). Mismatch breaks Git-sync.
- **Files per stack:** `docker-compose.yml` (canonical), `README.md` (purpose + ops notes), `.env.example` (non-secret defaults only).
- **Currently live:** `stacks/immich/` is the **SOLE** Git-backed Portainer stack on `vagary-core-1` (immich stack id 18 per live BoltDB probe 2026-06-08 — ids drift on recreate, see playbook §7 expected-output; hourly auto-update poll). `stacks/uptime-kuma/` is **authored but NOT onboarded** into Portainer (operator-pending — Lane-D; live `docker inspect` shows no portainer stack labels and BoltDB has no record). (immich id re-probed 2026-06-08 after the ML-split recreate.)

### §2.2 Compose env-var conventions

- **Naming:** `<STACK_UPPER>_<NOUN>` where `<STACK_UPPER>` is the SCREAMING_SNAKE_CASE form of the stack name (e.g. `IMMICH_DB_PASSWORD`, `IMMICH_UPLOAD_PATH`).
- **Rationale:** prefix prevents collisions when Portainer surfaces multiple stacks' env-vars in the same UI; matches the `<role>_<noun>` Ansible pattern used in `vps-ansible/roles/`.
- **Rendering:** real secret values are rendered into Portainer at deploy time via Infisical per the platform's secrets authority (§50.3 Infisical canonical). `.env.example` carries the **var names + placeholder defaults only** — never real values.
- **Public-OSS hard rule:** No plaintext secret, token, DB URL, or API key may land in any file in this repo. Pre-push grep gate (see `scripts/`) enforces.

### §2.3 README per stack

Each `stacks/<name>/README.md` documents:
- One-line purpose
- Live target host (`vagary-core-1` or `vagary-compute-1`)
- Cross-link to relevant ADR or runbook in `platform-docs/`
- Backup posture (restic? snapshot? N/A?) per the canonical backup matrix

## References
- `~/.claude/conventions/universal-claudemd.md` — universal laws, MCP routing
- `~/.claude/conventions/project-hygiene.md` — doc/scratch placement
- `platform-docs/docs/runbooks/portainer-git-sync.md` — migration procedure

## Stack
- **Stack**: Docker Compose (declarative stack manifests for Portainer Git-sync)
- **Tier**: C (Stable / Infrastructure config)
- **Description**: Canonical compose definitions; Portainer pulls from this repo via Git-sync. Replaces BoltDB-stored stacks.

## Build / Test / Deploy
```bash
# Add a new stack
mkdir -p stacks/<name>
# write docker-compose.yml + README.md + .env.example (non-secret only)
git add stacks/<name>/ && git commit -m "feat: add <name> stack" && git push

# Verify post-deploy
scripts/portainer-verify.sh <stack-name>
```

## Key Directories
- `stacks/<name>/` — one directory per stack (compose + README + .env.example)
- `scripts/` — operator helpers (export/import/verify)

## Security & Secrets
- `.env.example` files contain **non-secret defaults only**.
- Real secrets are rendered into Portainer at deploy time via Infisical (per §50.3 secrets authority is Infisical-only).
- Never commit `.env`, real tokens, real DB URLs.
- **NEVER paste secret values into the Portainer Stack env-vars panel.** Reference Infisical-rendered values only — the Portainer UI persists pasted values to disk/DB on the VPS, which violates the Infisical-canonical rule and cannot be revoked centrally if leaked.

## External Services (MCPs, integrations)
- **coolify** MCP — applications deployed via Coolify (separate from Portainer-managed infra)
- **hostinger** MCP — VPS-level operations
- **infisical** MCP — secrets injection at deploy time

## Past / Present / Future (per universal §35)

### Past
- `4ab86fb feat: bootstrap portainer-stacks repo for #56 BoltDB → Git-sync migration` — initial scaffold, README + scripts skeletons
- `abc5826 sync(pre-wave-2): bootstrap CLAUDE.md + .gitignore for VPS-infra cluster compliance` — first preamble + cluster-playbook inline
- Phase 7 close declared 2026-04-26 per ADR-022 — the *reconciliation-boundary* boundary between Portainer's runtime state and this repo's declarative source-of-truth was named on that date; export+import migration of live stacks remains in-flight beyond Phase 7 close
- ADR-029 (`ansible-scope-vs-coolify-boundary`) settled the *what-goes-where* between vps-ansible, Coolify, and Portainer — Portainer's lane is "pre-built images + infrastructure stacks the operator wants visible in a UI"

### Present
- 3 operator-helper scripts wired against Portainer API: `portainer-export.sh` (extract from BoltDB), `portainer-import.sh` (re-onboard via Git-sync), `portainer-verify.sh` (post-deploy health check)
- `stacks/immich/` is **Git-backed** (W8 2026-05-17 — `docker-compose.yml` + `README.md` + `.env.example`): the immich Portainer stack (id 18 per live BoltDB probe 2026-06-08; was 8 at W8, then 17 — ids drift on recreate) pulls the compose from this repo on an hourly auto-update poll; this repo is the live source of truth. `env_file` is the absolute Infisical-rendered path `/root/.infisical-rendered/immich.env`.
- Live Portainer (`vagary-core-1`) was API-enumerated 2026-05-17 — then exactly **two** stacks: `immich-app` (Git-backed, above) + `anjaan_online` (git-deployed from the `anjaan-app` repo). `cronicle` / `dns-proxy` from the early discovery inventory were **never created as Portainer stacks** — not pending exports.
- **2026-06-07 reconcile:** `stacks/immich/` is the **SOLE** Git-backed stack; `stacks/uptime-kuma/` compose was authored (#3, to codify the 3-network attach) but is **NOT onboarded** into Portainer (operator-pending — Lane-D). `anjaan_online` was dropped: its orphan stack 14 (leaked PAT) was deleted live and the stale `stacks/anjaan_online/` dir removed at the public-flip (`7c6dc92`); per the playbook §5 live-probe the immich stack was re-created as id 17 (and re-drifted to id 18 on the 2026-06-08 ML-split recreate — live BoltDB probe 2026-06-08; ids drift on recreate).
- **Exporters scope-note** (per `platform-docs/docs/audits/_archive-2026-05/exporters-fleet-session-worklog-2026-05-18.md`): the 8 observability exporters (blackbox, cAdvisor, node, postgres, mysqld, mongo, redis, elasticsearch) are Ansible-managed via `vps-ansible/roles/observability/`, **NOT** Git-backed Portainer stacks. Portainer is not their host; do not add `stacks/<exporter>/` directories here.
- CLAUDE.md preamble at universal **v52** (in sync; see the managed VERSION tag above, which is authoritative and self-updates via sync-preambles.py); VPS-infra + brand-registry cluster playbooks are read-on-demand pointers per §49.10 (v50), not inlined
- 7 Serena memories at `.serena/memories/*.md` from v31 bulk-onboarding (covers stack / cluster / license / external services / deviations / build-test-deploy / project facts)
- Tier C — no UI, no app, no telemetry surface of its own; just declarative compose YAML targets

### Future (pinnacle)

Vision at pinnacle: **every Portainer-managed stack across both VPSes (vagary-core-1 + vagary-compute-1) is declared canonically here, secrets render via Infisical at deploy time, zero stacks remain in BoltDB, and `scripts/portainer-verify.sh` returns clean for the full set.**

Concrete progress markers (sequence-anchored, not date-anchored per `feedback_no_timeframes_or_etas.md`):
- First marker: ✓ `stacks/immich/{docker-compose.yml,README.md,.env.example}` Git-backed (W8 2026-05-17) — Portainer stack ID 8 migrated to Git-sync mode (hourly auto-update poll) [W8 fact; the stack was later re-created as id 17, then id 18 — live BoltDB probe 2026-06-08; ids drift on recreate]; `immich_server` is on the external `monitoring` docker network for Prometheus scrape.
- Per-stack labels: each compose carries `prometheus.io/scrape` + service-discovery labels for `vps-ansible/roles/observability` Prometheus scrape (closes the per-stack lane of master-pending P1-10's reframed shape)
- Cron-able verify: `scripts/portainer-verify.sh --all` returns clean for every entry in `stacks/`
- BoltDB-stack count reaches zero on both VPSes (the reconciliation-boundary lands as an audit invariant, not just a declared posture)
- Auto-update cadence validated by an intentional repo-side compose-update propagating to the running container within the poll SLA

### Cross-references (Past+Present+Future supporting docs)
- `platform-docs/04-decision-memory/adrs/ADR-022-reconciliation-boundaries.md` — the *why* of Git-sync as canonical
- `platform-docs/04-decision-memory/adrs/ADR-029-ansible-scope-vs-coolify-boundary.md` — the *what-goes-where* between vps-ansible / Coolify / Portainer
- `platform-docs/docs/runbooks/portainer-git-sync.md` — operator-supervised migration procedure (per-stack steps + rollback)
- `platform-docs/02-governance/service-playbooks/substrate/portainer.md` § Stack inventory — canonical list of expected/live Portainer stacks (today: SOLE Git-backed stack `immich`; `uptime-kuma` compose authored but NOT onboarded). Supersedes the former `09-trackers/.archived/discovery-D1-services-*` tracker, removed in the 2026-05-17 governance consolidation (commit `d328bb4`).
- `vps-ansible/roles/observability/` — the Prometheus scrape config that will consume per-stack `/metrics` endpoints once stacks ship

## VPS Service Navigation

`portainer-stacks` holds Git-backed Docker Compose stacks that Portainer pulls. This index points CC at the canonical service playbooks for headless operation (operator does no UI work — CC handles 99% via API / CLI / MCP). Full playbook set: `platform-docs/02-governance/service-playbooks/`.

| Service | This repo's resource | How CC leverages it | Canonical playbook |
|---|---|---|---|
| **Portainer** (stack host) | `stacks/immich/` is the SOLE Git-backed Portainer stack on **vagary-core-1** (id 18 per live BoltDB probe 2026-06-08; ids drift on recreate), hourly auto-update poll; `stacks/uptime-kuma/` authored but NOT onboarded (operator-pending) | Stack ops via Portainer API at `portainer.chinmayramraika.in`; never paste secrets into the Portainer UI env panel | `service-playbooks/substrate/portainer.md` |
| **Infisical** (secrets) | Stack `env_file` points at the Infisical-rendered absolute path `/root/.infisical-rendered/immich.env` on core-1 | Secrets render at deploy time via the on-VM `infisical-agent`; never inline secret values in compose | `service-playbooks/substrate/infisical.md` §9.5 |
| **Reverse proxy** | Caddy on core-1 — `gallery` vhost fronts Immich | Vhost via `vps-ansible` Caddyfile.j2 | `service-playbooks/substrate/caddy.md` §5.2 |
| **Observability** | Per-stack `/metrics` endpoints scraped by Prometheus (once stacks expose them) | `vps-ansible/roles/observability/` scrape config | `service-playbooks/observability/prometheus.md` |

## Deviations from Universal Laws
- None.
