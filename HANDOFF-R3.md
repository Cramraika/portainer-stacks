# HANDOFF-R3 — portainer-stacks self-rebase

Session-bridge artefact per §38.5. Delete via `git rm` once §B + §C close.

R-anchor: **R3** (per `~/.claude/specs/benchmark-last-run.json`).
Session mode: INTERACTIVE.
Repo state at close: 2 file changes committed, 1 new file (`HANDOFF-R3.md`) pending.

---

## §A — Read-first reference

| Priority | File | Gives | When to read |
|---|---|---|---|
| 1 | `CLAUDE.md` | Live contract; preamble at universal v45; VPS-infra cluster playbook inlined | Always |
| 2 | `README.md` | Migration procedure + expected-stacks inventory + cross-refs to platform-docs ADRs | Before adding any stack |
| 3 | `scripts/portainer-{export,import,verify}.sh` | Operator helpers; env-var-driven | When migrating a stack |
| 4 | `platform-docs/docs/runbooks/portainer-git-sync.md` | Detailed runbook for Phase 7 migration | When uncertain about flow |
| 5 | `~/.claude/specs/2026-05-07-master-pending.md` (P1-10 + §1) | 2 stale entries for this repo (see §C below) | Before triaging master-pending |
| 6 | `vps-ansible/roles/observability/` | Prometheus scrape config + Grafana — the actual /metrics consumer for stacks-deployed apps | When wiring per-stack metrics |
| 7 | `.serena/memories/*.md` | 7 onboarding memories from v31 bulk-onboarding (stack, cluster, license, etc.) | If returning after long absence |
| 8 | `~/.claude/conventions/repo-inventory.md` §VPS-infra | Cluster membership table | Cross-repo work |
| 9 | `~/.claude/conventions/playbooks/vps-infra.md` | DNS authority XOR (Cloudflare vs Hostinger) | When touching DNS for stacks |
| 10 | This HANDOFF | Session state for next opener | Session start |
| 11 | `git log --oneline -5` | Recent commit cadence | Confirm what shipped |

---

## §B — Live blockers (P0/P1)

**None unique to this repo.** Fleet-level blockers carried from doctor sweep (NOT this repo's responsibility to fix):

1. **`uptime-kuma` MCP ✗ Failed to connect** — fleet-level; surfaced in `claude mcp list`. Not in any per-repo routing for this repo (CLAUDE.md External Services lists only coolify / hostinger / infisical). Defer to fleet master-pending.

2. **Infisical MCP `! Needs authentication`** — fleet-level; `INFISICAL_UNIVERSAL_AUTH_CLIENT_ID/SECRET` revoke / re-auth pending per master-pending P0. Per CLAUDE.md routing, infisical IS in scope for this repo (secrets rendering at deploy time). When infisical comes back online, scripts/portainer-import.sh can be wrapped with `infisical run --` for the actual deploy.

---

## §C — Carry-forward findings (4 closed at R3 follow-up; 1 still in-progress)

1. **`stacks/` partially populated** — `stacks/immich/` captured 2026-05-16 (OW-17): compose + README + .env.example, captured directly from the live Portainer BoltDB compose dir. `cronicle` / `dns-proxy` still pending operator-supervised export per README. This remains in-progress core work. **STATUS: in-progress — immich done, cronicle + dns-proxy outstanding (the pinnacle work itself).**

2. ~~**master-pending P1-10 `/metrics` entry for portainer-stacks**~~ — **CLOSED at R3 follow-up.** Operator-blessed reframe applied to `~/.claude/specs/2026-05-07-master-pending.md` line 271: portainer-stacks struck from P1-10 header, disposition note appended pointing back to this HANDOFF §C.2. Per-stack /metrics + prometheus.io labels become per-stack PR work when stacks/<name>/ land. Per-stack lane is tracked implicitly in §35 "Future" of CLAUDE.md.

3. ~~**master-pending §1 graphify Pass-3 entry for portainer-stacks**~~ — **CLOSED at R3 follow-up.** Operator chose "mark RESOLVED-as-NA" after seeing empirical evidence:
   - Pass-1 (`graphify update .`, no LLM): `[graphify watch] No code files found - nothing to rebuild.`
   - Pass-3 (`graphify extract .`, semantic LLM): `error: no LLM API key found. Set MOONSHOT_API_KEY (kimi) or ANTHROPIC_API_KEY (claude)`.
   - graphify doesn't recognize bash/YAML as "code" for AST extraction; multimodal LLM pass would have nothing to chew on (no images / videos / PDFs / dense docs).
   - **Disposition**: master-pending P1-7 line 252 portainer-stacks struck; "the 3 of 26" → "the 2 of 26 still pending" with RESOLVED-as-NA note pointing back to this HANDOFF §C.3.

4. ~~**`lychee.toml` regex error**~~ — **CLOSED at R3 follow-up.** Operator chose "Fix locally + fleet-grep". Findings:
   - lychee 0.23.0 `--exclude-path` takes **regex** (verified via `lychee --help`); pattern `"**/node_modules/**"` is a regex parse error
   - This repo's `lychee.toml` fixed locally: glob patterns replaced with anchored regex equivalents (`"/dist/"`, `"/\\.next/"`, etc.). `lychee --config lychee.toml README.md CLAUDE.md` now exits cleanly.
   - File is gitignored in this repo per project-hygiene §3 (agent-tool-hidden-dirs convention), so fix doesn't propagate via commit
   - **Fleet sweep result**: 22 other repos have the identical broken pattern. New master-pending **P1-12** entry surfaced (`~/.claude/specs/2026-05-07-master-pending.md` after P1-11 closure) — fleet-wide `lychee.toml` `exclude_path` regex syntax error, all 22 repos listed with operator-decision deferred (sweep-now vs project-template re-bootstrap).

5. ~~**CLAUDE.md has no §35 "Future" section**~~ — **CLOSED at R3 follow-up.** Operator chose "Add full §35 block with cross-refs to platform-docs ADRs". Added to CLAUDE.md before `## Deviations from Universal Laws` — Past (3 commits + Phase 7 close + ADR-022/029 lineage), Present (3 scripts + empty stacks/ awaiting export + v45 preamble + 7 Serena memories + Tier C), Future (concrete sequence-anchored progress markers toward pinnacle, NOT date-anchored per `feedback_no_timeframes_or_etas.md`), Cross-references (ADR-022 + ADR-029 + portainer-git-sync runbook + discovery-D1 tracker + vps-ansible observability role).

---

## §D — Pain-points + resolutions

| Pain | Resolution this session |
|---|---|
| Universe of arsenal items is large; tiny YAML repo doesn't justify spawning 5 parallel agents | **Parsimony collapse**: Phase 3 multi-agent fan-out → single in-context synthesis pass. Phase 4 autonomy probes + Phase 9 verification benchmark SKIPPED (uninformative on YAML-only Tier C repo). Documented in §F below. |
| audit-signal flagging CLAUDE.md drift | Prior session ran `sync-preambles.py` and updated to v45 but didn't commit. Committed cleanly via cascade-commit exception §4.5 (script-driven). Audit-signal will clear next session. |
| README.md cited a script that didn't exist (`portainer-import.sh`) | Operator confirmed: write it now. Authored 92-line script using Portainer's `POST /api/stacks/create/standalone/repository` Git-sync endpoint; syntax-validated via `bash -n`. |
| graphify Pass-3 forced run | Required API key; Pass-1 yielded "No code files found". Logged empirical evidence — this is the right disposition signal for master-pending. |
| Cost-awareness: `claude usage` not surfaced | Did not query — INTERACTIVE mode, user driving. If next session is UNATTENDED + 7-day budget low, skip Phase 3 fan-out and Phase 9 entirely per Phase 1.5 cost-budget rule. |
| Read-counter throttle fired once | Interleaved with Bash for heredoc-style file reads. Working pattern. |

---

## §E — What changed this session

| Commit | What | Why |
|---|---|---|
| `02fea3e` | `CLAUDE.md` preamble v43 → v45 | §4.5 cascade-commit; script-driven sync output |
| `1393417` | New `scripts/portainer-import.sh` (92 lines) | Closes README §Layout doc-vs-code drift; operator-blessed |
| (pending) | `HANDOFF-R3.md` (this file) | Session-bridge artefact |

No body changes to CLAUDE.md, README.md, or other scripts.

---

## §F — Tool routing observations

| Tool | Observation |
|---|---|
| `claude mcp list` | 11 of 13 connected; 2 fleet issues (uptime-kuma fail, infisical needs auth). Per-repo routing healthy. |
| `~/.claude/scripts/hooks-sanity-check.sh` | Silent — clean. |
| `~/.claude/scripts/audit-signal-check.sh` | Flagged 1 CLAUDE.md sync drift (this repo's uncommitted v45 bump). Cleared by Commit `02fea3e`. |
| `~/.claude/scripts/sync-preambles.py --dry-run` | Returned no portainer hits (already in sync; prior session had run it). |
| `gitnexus list` / `gitnexus status` | Not invoked — single-repo scope, no cross-repo question. §48 parsimony. |
| Serena MCP | Connected; not invoked — no symbol-precise read needed (2 bash scripts + 1 README). §48 parsimony. |
| Bash `semgrep --config p/secrets` | Not invoked — no application code; just shell scripts validated against §50 (no hardcoded creds — all env-var-driven). |
| `graphify update .` | Returned "No code files found." Empirical evidence that Pass-3 master-pending entry is unactionable. |
| `lychee --config lychee.toml` | FAILED on regex syntax error in `exclude_path`. Fleet config issue (see §C.4). |
| **Multi-agent Phase 3 fan-out** | **SKIPPED per §48 parsimony.** Justification: 2 shell scripts + 1 README + empty stacks/ would yield ≤5 findings per agent × 5 agents = duplicative noise. Single in-context synthesis surfaced 7 findings with full coverage. |
| **Ensemble judges (compass §5.6)** | **SKIPPED.** No BLOCKER or CRITICAL_FAIL or HALLUCINATED-PASS findings — single-judge synthesis is acceptable per Phase 3.4. |
| **§51.5 confirmation triangle** | **N/A this session** — no delete proposed. |
| **Phase 4 autonomy probes** | **SKIPPED per §48 parsimony.** 5 sequential `claude -p` probes on a YAML-only Tier C repo would test routing for questions the repo cannot answer (no entry-point function, no orphan code, no symbol queries). Probe budget conserved for repos where signal:noise is higher. |
| **Phase 9 verification benchmark** | **SKIPPED per §48 parsimony.** No CLEAN-declaration to verify; trivially-reversible commits don't warrant 5 sequential `claude -p` validations. |

---

## §G — Cross-session feedback codified

Applied directly this session (no re-litigation):

- **Build-don't-deride**: empty `stacks/` is in-progress migration work — preserved untouched.
- **§29.5 protected paths**: no migrations/, .env, lock, generated, vendored files touched.
- **§51.5 triangle**: no deletes; rule honored vacuously.
- **No half-hand methods**: `portainer-import.sh` is full-shape (env-validation, payload-build, private-repo PAT support, verify-pointer) — not a stub.
- **No new helper scripts in `~/.claude/scripts/`**: HANDOFF is the only new file outside the repo's own tree; everything else used existing Bash / Read / Edit.
- **No timeframes / ETAs**: filename uses R3 anchor (not date); §C carry-forwards reference R3 + condition-anchored sequencing.
- **Confirm-before-strategy**: opening AskUserQuestion confirmed scope before kicking off; mid-session AskUserQuestion confirmed 3 disposition points.
- **§48 parsimony**: 4 phases (3 fan-out, 4 probe, 9 verify) collapsed/skipped with explicit rationale per phase.
- **§52 INTERACTIVE mode**: single mid-session AskUserQuestion with 3 batched questions; no piecemeal interruptions.
- **Vision-at-pinnacle lane activation**: Designer / Tester / Architect lanes correctly idle (Tier C, no UI surface).

---

## §H — Landmines unique to this repo

1. **`stacks/` is the deliverable** — the repo looks dead from a code-graph perspective (no functions, no symbols, no imports) but it's nascent infrastructure-as-data. graphify will keep returning empty for code-extraction passes. Any "audit found 0 nodes" report on this repo is correctly interpreted as "nothing to graphify yet", not "repo is dead."

2. **Master-pending mentions need careful disambiguation** — this repo gets mentioned in fleet sweeps for things that don't apply to it (e.g., `/metrics` endpoint — there's no app; graphify Pass-3 — there's no multimodal content). Future sessions should check the repo's actual code surface before treating master-pending lines as actionable.

3. **`lychee.toml` is gitignored** in this repo (project-hygiene §3 agent-tool-hidden-dirs convention). Fixes to lychee config don't propagate to the repo. Either keep it as a local-only convention OR remove from `.gitignore` to track it (fleet decision).

4. **No Roadmap section in CLAUDE.md** — by design (project-template variant for Tier C infra) but creates a §35 Past/Present/Future coverage gap. If future fleet audits flag this, surface back to §C.5 disposition.

5. **`scripts/portainer-import.sh` references env vars not yet rendered through Infisical** — the operator-CFR `PORTAINER_API_TOKEN` + optional `REPO_PAT` should be wired through `infisical run --env=prod --` when used in CI / automation. Until Infisical auth is back (fleet P0), the script runs interactively with operator-pasted token (acceptable for one-off Phase 7 migration; not for automation).

6. **Post-commit hook runs cluster-wide graphify** — `[graphify hook] launching background rebuild` after each commit launches an AST scan over 3011 files (much wider than this repo). This is the cluster-merge behavior — useful but slow. If commit-cadence picks up, consider scoping the hook to per-repo.

---

## §I — Verification benchmark

**Phase 9: SKIPPED per §48 parsimony.** See §F entry above.

If next session wants to re-verify: change touched 2 files + added 1 file. Validations needed:
- `bash -n scripts/portainer-import.sh` — already passed this session
- `bash -n scripts/portainer-export.sh` + `bash -n scripts/portainer-verify.sh` — not re-validated this session (unchanged)
- `~/.claude/scripts/audit-signal-check.sh` should now return silent (this repo's CLAUDE.md preamble in sync)
- README cross-link to `platform-docs/docs/runbooks/portainer-git-sync.md` — exists, verified

---

## §J — Closing protocol for next session

### §J.1 First action on session-open in this repo

If both §B and §C are closed:
```bash
git rm HANDOFF-R3.md
git commit -m "chore: retire HANDOFF-R3 (closed: §B fleet-only, §C all dispositioned)"
```

If §C carry-forwards still pending: update §C inline; **leave file in place**.

### §J.2 If multiple HANDOFF-*.md files appear

Drift signal per §38.5. Only one active at a time. Retire the oldest (or merge into the newest) immediately as first action.

### §J.3 Pinnacle progress check (Vision Lens)

The repo advances toward pinnacle when:
- `stacks/<name>/{docker-compose.yml, README.md, .env.example}` lands for one of: immich, cronicle, dns-proxy
- That stack's compose has prometheus.io labels for vps-ansible scrape
- The `Stack inventory` table in README.md gets an entry: "migrated R<n>" with a verify timestamp

The repo is **at-pinnacle** when:
- Every Portainer-managed stack across vagary-core-1 + vagary-compute-1 has a `stacks/<name>/` entry
- Zero stacks remain in BoltDB
- `scripts/portainer-verify.sh` returns clean for all

### §J.4 If operator wants `master-pending` cleanups

The 2 stale-for-this-repo entries (P1-10 /metrics + §1 graphify Pass-3) are dispositioned in §C above with operator-blessed reframings. Operator can edit `~/.claude/specs/2026-05-07-master-pending.md` to mark them per §C.2 + §C.3 — but those edits are operator-decision, not auto-applied this session.

---

**HANDOFF-R3 close.** Next opener: read §A.1-3 + this file's §B + §C; act.

---

## §K — Phase 9 doc-coherence audit pass (2026-05-15 by Subagent S5)

Doc-coherence audit pass conducted under META-OVERWATCHER Phase 9 campaign (`platform-docs/02-governance/phase-9/PHASE-9.0-framework.md`). HANDOFF-R3 retained per §38.5 rule 4 — §C.1 (`stacks/` empty pending operator-supervised export) remains in-progress; §C.2-§C.5 stay closed.

**Changes applied this audit:**

1. `README.md` rewritten for public-OSS clarity — added status banner, scripts table, expanded migration procedure, secrets discipline section, forking guidance, and HTTPS cross-links to companion repos
2. `CLAUDE.md` preamble synced from v45 → v46 (committed; was uncommitted carry-over from sync-preambles run); broken cross-link `platform-docs/09-trackers/discovery-D1-services-20260420.md` corrected to `.archived/` path
3. `lychee.toml` unchanged — already fixed locally per §C.4; gitignored per project-hygiene §3
4. `scripts/` unchanged — all 3 scripts re-validated (`bash -n`); no doc-vs-code drift
5. Per-repo audit memo at `platform-docs/docs/audits/phase-9/2026-05-15-phase-9-portainer-stacks-doc-audit.md`

**Cross-link integrity** (Phase 9 verification): all platform-docs paths resolve (ADR-022, ADR-029, portainer-git-sync.md runbook, discovery-D1 archive); all vps-ansible/observability paths resolve.

**Stacks/ status unchanged:** still in-progress pending operator-supervised export. Vision-pinnacle markers in CLAUDE.md §35 Future remain accurate.
