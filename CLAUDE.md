# portainer-stacks

Git-sync source-of-truth for Portainer stacks (per ADR-022 reconciliation-boundary; Phase 7 close 2026-04-26).

---

## Claude Preamble
<!-- VERSION: 2026-05-14-v46 -->
<!-- SYNC-SOURCE: ~/.claude/conventions/universal-claudemd.md -->

**Universal laws** (§4), **MCP routing** (§6), **Drift protocol** (§11), **Dynamic maintenance** (§14), **Capability resolution** (§15), **Subagent SKILL POLICY** (§16), **Session continuity** (§17), **Decision queue** (§17.a), **Attestation** (§18), **Cite format** (§19), **Three-way disagreement** (§20), **Pre-conditions** (§21), **Provenance markers** (§22), **Redaction rules** (§23), **Token budget** (§24), **Tool-failure fallback** (§25), **Prompt-injection rule** (§26), **Append-only discipline** (§27), **BLOCKED_BY markers** (§28), **Stop-loss ladder** (§29), **Business-invariant checks** (§30), **Plugin rent rubric** (§31), **Context ceilings** (§32), **Doc reference graph** (§33), **Anti-hallucination** (§34), **Past+Present+Future body** (§35), **Project trackers** (§36), **Doc ownership** (§37), **Archive-on-delete** (§38), **Sponsor + white-label** (§39 — moved to `playbooks/commercial-bound.md`), **Doc-vs-code drift** (§40), **Brand architecture** (§41), **Design system integration** (§42 — moved to `playbooks/tier-a-design.md`), **Session cognition** (§43), **Plugin dispatch** (§44), **Cross-repo clusters** (§45), **Tool-cascade workflow** (§46), **Multi-role agent matrix** (§47), **Parsimony / smallest-tool-first** (§48), **Audit triage discipline** (§49), **Source-of-truth matrix** (§50 — universal rows only; cluster-specific rows moved to playbooks), **Composite cascade catalog** (§51 — §51.2/51.4/51.6 moved to playbooks), **Session launch context + unattended-mode contract** (§52), **Recurrence detection + root-cause escalation** (§53). Sub-sections new in v44: **§4.5 cascade-commit exception**, **§17.b stale-P0 escalation**, **§32.5 canonical-doc size ceiling**, **§38.5 HANDOFF lifecycle enforcement**.

**Cluster playbooks** (per-repo `@-import` based on cluster membership): `~/.claude/conventions/playbooks/vps-infra.md` (DNS XOR for VPS-infra repos), `~/.claude/conventions/playbooks/deployed-service.md` (Sentry/Glitchtip XOR + production-incident triage + time-window correlation for repos with prod telemetry), `~/.claude/conventions/playbooks/tier-a-design.md` (Figma/Stitch + design system for Tier A/B), `~/.claude/conventions/playbooks/multi-lang.md` (cross-language refactor cascade for multi-language repos), `~/.claude/conventions/playbooks/commercial-bound.md` (sponsor-readiness + license-aware code-graph routing), `~/.claude/conventions/playbooks/brand-registry.md` (Vagary brand architecture for Vagary-family repos), `~/.claude/conventions/playbooks/bellring-cluster.md` (Bellring server↔extension; v1-stub), `~/.claude/conventions/playbooks/pulseboard-cluster.md` (Pulseboard Android↔Windows; v1-stub), `~/.claude/conventions/playbooks/vagary-cluster.md` (Vagary product cross-repo; v1-stub). **`tech-debt-audit.md`** is Read-on-demand (NOT @-imported) per ENTRY #169 §49 audit-triage discipline — invoked when user requests audit / tech-debt / dead-code work.

**Sources**: `~/.claude/conventions/universal-claudemd.md` (laws, MCP routing, lifecycle, rent rubric, doc-graph, anti-hallucination, brand architecture) + `~/.claude/conventions/project-hygiene.md` (doc placement, cleanup, archive-on-delete, ownership matrix) + cluster playbooks under `~/.claude/conventions/playbooks/` (loaded per-repo via `@-import` in `## Active Cluster Playbooks` section; see list above). Read relevant sections before significant work. Sync: `~/.claude/scripts/sync-preambles.py` (manual cadence; run after any source edit).

## Active Cluster Playbooks (per v40 cluster-split — content auto-inlined)
<!-- BEGIN PLAYBOOKS BLOCK (managed by sync-preambles.py — content inlined; source at ~/.claude/conventions/playbooks/) -->

Source @-imports (declarative pointer; content inlined below since Claude Code does not recursively expand `@-imports` in per-repo CLAUDE.md):
- `@~/.claude/conventions/playbooks/vps-infra.md`
- `@~/.claude/conventions/playbooks/brand-registry.md`

### Playbook: vps-infra.md (verbatim from `~/.claude/conventions/playbooks/vps-infra.md`)

# VPS-Infra Playbook

**VERSION: 2026-05-06-v1**
Loaded only in VPS-infra cluster repos (per `~/.claude/conventions/repo-inventory.md` §45 cluster: `vps_host`, `vps-ansible`, `platform-docs`, `host_page`, `portainer-stacks`). Per-repo `CLAUDE.md` `@-imports` this file when applicable.

Source: extracted verbatim from `~/.claude/conventions/universal-claudemd.md` v39 §50.1 (DNS XOR rows only) during v40 cluster-split refactor. No content changes — only relocation so non-VPS-infra repos (e.g. `aakhara`, `bellring-server`) don't see DNS-authority rules they could mis-apply.

**Applies to repos**: `vps_host`, `vps-ansible`, `platform-docs`, `host_page`, `portainer-stacks`.

---

## DNS authority XOR (originally part of §50.1 authority table)

| Domain | Source of truth | Secondary (read/derivative only) | Anti-pattern |
|---|---|---|---|
| **DNS for product domains** (vagaryvoice.cloud, anjaan.online, aakhara.com, bellring.io, pulseboard.build) | **Cloudflare** Zone DNS | — | Hostinger DNS holding the same zone |
| **DNS for VPS-host management** | **Hostinger** (where the VPS is hosted) | — | Cloudflare Zone for non-product host records |

### Rule

Product domains live in Cloudflare; VPS-host management records (where the VPS itself sits) live in Hostinger. NEVER hold the same zone in both providers — that's the "dual authority" anti-pattern.

When uncertain which side a record belongs on:
- Is the record about reaching a deployed product (web app, API, CDN)? → Cloudflare
- Is the record about reaching the VPS itself for ops (SSH, panel access, mail server hostnames for the VPS)? → Hostinger

### Playbook: brand-registry.md (verbatim from `~/.claude/conventions/playbooks/brand-registry.md`)

# Brand Registry Playbook

**VERSION: 2026-05-07-v1**
Loaded only in Vagary-family repos (per `~/.claude/conventions/repo-inventory.md` §45). Per-repo `CLAUDE.md` `@-imports` this file when applicable.

Source: extracted verbatim from `~/.claude/conventions/universal-claudemd.md` §41 (Brand architecture) during 2026-05-07 cluster-split refinement (ENTRY #168). No content changes — only relocation so non-Vagary repos (e.g. `metabase-cn`, `tldv_downloader`, `torn-smart-scripts`) don't load 64 lines of Vagary brand registry they have no use for.

**Applies to repos**: `vagary-platform`, `vagary-voice`, `anjaan-app`, `aakhara`, `bellring-server`, `bellring-extension`, `bulk`, `pulseboard`, `pulseboard-desktop`, `project-template`, `portfolio` (cross-link only), `host_page`, `vps_host`, `vps-ansible`, `platform-docs`, `vagary-earnings`.

---

## 41. Brand architecture (originally §41 of universal-claudemd.md)

Vagary Life Pvt Ltd is the **corporate parent**. Below it, product and tech activity is organized into named divisions. As of 2026-04-19, one division is formalized: **Vagary Labs** (tech/R&D/platform).

### Structure

```
Vagary Life Pvt Ltd (parent company; registered entity)
└── Vagary Labs (tech/R&D/platform division — vagarylabs.com [PENDING])
    ├── Platform
    │   └── vagary-platform (20-vertical substrate; repo renamed from `index-of-news` 2026-04-19)
    │       └── Index of News (flagship vertical; keeps its own news sub-brand + 6 domains)
    ├── Product brands (each lives as an independent product under its own domain)
    │   ├── Vagary Voice (vagaryvoice.cloud) — commercial voice-AI SaaS
    │   ├── Anjaan (anjaan.online) — Hinglish consumer chat
    │   ├── Bellring (.io/.app/.ai TBD) — whitelabel sale-celebration SaaS; repos `bellring-server` + `bellring-extension` (renamed from `sales-notification-*` 2026-04-19; formerly codenamed Salvo)
    │   ├── Aakhara (aakhara.com pending) — voice sales-training roleplay for BDEs (Sanskrit "आखाड़ा" = practice arena; repo renamed from `training-bot` 2026-04-19). Positioning TBD: could sit as Vagary Voice sub-product or stand alone
    │   └── Hype / Mockline / Kohort (legacy proposed names, superseded by Bellring/Aakhara above)
    └── OSS Utilities
        ├── bulk (renamed from `bulk_api_trigger` 2026-04-19)
        ├── tldv_downloader
        ├── pulseboard (renamed from `NetworkMonitorCN` 2026-04-19; Android OSS, `pulseboard.build` pending)
        └── project-template
```

Additional divisions (media, ops, consulting, etc.) may be added later. Keep Vagary Labs scoped to **tech/platform/R&D**.

### Domain strategy

- **vagarylife.com / vagarylife.in** — corporate parent marketing + investor/careers. TO BE BUILT.
- **vagarylabs.com** — tech/R&D division site. Domain **PENDING PURCHASE** (user flagged). Will host platform docs + OSS index + R&D blog once acquired.
- **Per-product domains** — each commercial product keeps its own brand domain (`vagaryvoice.cloud`, `anjaan.online`, future `hype.sh`, etc.). Product domains do NOT nest under `vagarylabs.com`.
- **chinmayramraika.in** — founder's personal hub; cross-links each Vagary Life / Vagary Labs product in a "projects" section.

### Repo-to-brand mapping (authoritative)

| Repo | Vagary Labs home | Product / sub-brand |
|---|---|---|
| `vagary-platform` | Platform | Holds all 20 verticals; flagship vertical = **Index of News** (news sub-brand, 6 domains) |
| `vagary-voice` | Product brands | **Vagary Voice** (commercial product, `vagaryvoice.cloud`) |
| `anjaan-app` | Product brands | **Anjaan** (consumer product, `anjaan.online`) |
| `aakhara` | Product brands | **Aakhara** (voice sales-training roleplay; `aakhara.com` pending). Renamed from `training-bot` 2026-04-19. Positioning TBD (standalone OR Vagary Voice sub-product) |
| `bellring-server` | Product brands | **Bellring** server (whitelabel sale-celebration SaaS backend; `.io/.app/.ai` TBD). Renamed from `sales-notification-backend` 2026-04-19 (formerly codenamed Salvo) |
| `bellring-extension` | Product brands | **Bellring** extension (Chrome MV3 + Firefox/Edge portable; pairs with `bellring-server`). Renamed from `sales-notification-extension` 2026-04-19 |
| `bulk`, `tldv_downloader`, `pulseboard`, `project-template` | OSS Utilities | Each with its own GitHub + README brand. `pulseboard` renamed from `NetworkMonitorCN` 2026-04-19 (Android OSS; `pulseboard.build` pending) |
| `portfolio` | Personal hub (OUTSIDE Vagary Labs) | `chinmayramraika.in` founder site |
| `host_page`, `platform-docs`, `vps_host`, `n8n-workflows`, `metabase-cn` | Infrastructure (internal to Vagary Labs) | No external product brand |
| `Automated-sales-manager-main` | Client work (CN-internal) | ASM — CN-branded; Cadre whitelabel TBD |
| `google-sheet-sales-manager` | Client work (CN-internal) | Sheetpilot whitelabel TBD |
| `Expense tracker` | Absorbing → Platform (`budget` vertical) | No standalone brand going forward |

### How Claude uses this

- When a repo's description says "product," check the brand table above for positioning.
- The **platform repo** (`vagary-platform`) is *not* a product. It is substrate. Individual verticals (news, budget, …) are the products that ship.
- Don't reinvent brand positioning in per-repo CLAUDE.md — reference this section and defer details to `~/.claude/specs/2026-04-19-brand-rename-proposal.md` (for rationale) + `~/.claude/conventions/repo-inventory.md` (for current state).
- For any new repo: declare its division home in its CLAUDE.md § Status / Brand section and cross-reference here.

### Caveats

- `vagarylabs.com` is **not yet purchased** (2026-04-19). Until acquired, Vagary Labs is an internal organizational concept; do not publish external references to `vagarylabs.com` until DNS is live.
- Additional divisions (media, ops, consulting) may emerge. When they do, add a sibling subtree here + bump VERSION.

<!-- END PLAYBOOKS BLOCK -->

## License classification: personal/private

## Cluster: VPS-infra

Part of the §45 VPS-infra cluster: vps_host, vps-ansible, platform-docs, portainer-stacks, host_page.

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
- `stacks/immich/` is **Git-backed** (W8 2026-05-17 — `docker-compose.yml` + `README.md` + `.env.example`): Portainer stack ID 8 pulls the compose from this repo on an hourly auto-update poll; this repo is the live source of truth. `env_file` is the absolute Infisical-rendered path `/root/.infisical-rendered/immich.env`.
- Live Portainer (`vagary-core-1`) was API-enumerated 2026-05-17 — exactly **two** stacks: `immich-app` (Git-backed, above) + `anjaan_online` (git-deployed from the `anjaan-app` repo; documented at `stacks/anjaan_online/`). `cronicle` / `dns-proxy` from the early discovery inventory were **never created as Portainer stacks** — not pending exports.
- CLAUDE.md preamble at universal **v46** (in sync); both VPS-infra + brand-registry cluster playbooks inlined per v40 cluster-split
- 7 Serena memories at `.serena/memories/*.md` from v31 bulk-onboarding (covers stack / cluster / license / external services / deviations / build-test-deploy / project facts)
- Tier C — no UI, no app, no telemetry surface of its own; just declarative compose YAML targets

### Future (pinnacle)

Vision at pinnacle: **every Portainer-managed stack across both VPSes (vagary-core-1 + vagary-compute-1) is declared canonically here, secrets render via Infisical at deploy time, zero stacks remain in BoltDB, and `scripts/portainer-verify.sh` returns clean for the full set.**

Concrete progress markers (sequence-anchored, not date-anchored per `feedback_no_timeframes_or_etas.md`):
- First marker: ✓ `stacks/immich/{docker-compose.yml,README.md,.env.example}` Git-backed (W8 2026-05-17) — Portainer stack ID 8 migrated to Git-sync mode (hourly auto-update poll); `immich_server` is on the external `monitoring` docker network for Prometheus scrape.
- Per-stack labels: each compose carries `prometheus.io/scrape` + service-discovery labels for `vps-ansible/roles/observability` Prometheus scrape (closes the per-stack lane of master-pending P1-10's reframed shape)
- Cron-able verify: `scripts/portainer-verify.sh --all` returns clean for every entry in `stacks/`
- BoltDB-stack count reaches zero on both VPSes (the reconciliation-boundary lands as an audit invariant, not just a declared posture)
- Auto-update cadence validated by an intentional repo-side compose-update propagating to the running container within the poll SLA

### Cross-references (Past+Present+Future supporting docs)
- `platform-docs/04-decision-memory/adrs/ADR-022-reconciliation-boundaries.md` — the *why* of Git-sync as canonical
- `platform-docs/04-decision-memory/adrs/ADR-029-ansible-scope-vs-coolify-boundary.md` — the *what-goes-where* between vps-ansible / Coolify / Portainer
- `platform-docs/docs/runbooks/portainer-git-sync.md` — operator-supervised migration procedure (per-stack steps + rollback)
- `platform-docs/09-trackers/.archived/discovery-D1-services-20260420.md` § Portainer — service inventory that names the expected stacks (archived; methodology preserved as historical reference)
- `vps-ansible/roles/observability/` — the Prometheus scrape config that will consume per-stack `/metrics` endpoints once stacks ship

## VPS Service Navigation

`portainer-stacks` holds Git-backed Docker Compose stacks that Portainer pulls. This index points CC at the canonical service playbooks for headless operation (operator does no UI work — CC handles 99% via API / CLI / MCP). Full playbook set: `platform-docs/02-governance/service-playbooks/`.

| Service | This repo's resource | How CC leverages it | Canonical playbook |
|---|---|---|---|
| **Portainer** (stack host) | `stacks/immich/` is a Git-backed Portainer stack (id 8 on **vagary-core-1**), hourly auto-update poll | Stack ops via Portainer API at `portainer.chinmayramraika.in`; never paste secrets into the Portainer UI env panel | `service-playbooks/substrate/portainer.md` |
| **Infisical** (secrets) | Stack `env_file` points at the Infisical-rendered absolute path `/root/.infisical-rendered/immich.env` on core-1 | Secrets render at deploy time via the on-VM `infisical-agent`; never inline secret values in compose | `service-playbooks/substrate/infisical.md` §9.5 |
| **Reverse proxy** | Caddy on core-1 — `gallery` vhost fronts Immich | Vhost via `vps-ansible` Caddyfile.j2 | `service-playbooks/substrate/caddy.md` §5.2 |
| **Observability** | Per-stack `/metrics` endpoints scraped by Prometheus (once stacks expose them) | `vps-ansible/roles/observability/` scrape config | `service-playbooks/observability/prometheus.md` |

## Deviations from Universal Laws
- None.
