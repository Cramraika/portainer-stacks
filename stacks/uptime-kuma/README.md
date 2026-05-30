# uptime-kuma — Portainer Git-backed stack

Codifies the production uptime-kuma deploy on `vagary-core-1`. Companion to the
existing immich Git-backed stack (this repo IS the single source of truth).

## Why this stack exists

Pre-2026-05-30, uptime-kuma was running via raw `docker run` (no compose).
A Portainer-driven restart caused the container to be recreated as `bridge`-only
— it silently dropped its `monitoring` + `portainer-net` attachments. Symptoms:

- `host_page` `/api/status` returned **502** (in-pane probe could not reach uptime-kuma over the `monitoring` network).
- Portainer's container-detail page lost the live exec / log stream (`portainer-net` was gone).

Operator did a live `docker network connect` to restore both, but that fix is
**not durable** — the next recreate would revert it. This stack closes the gap
by declaring all three networks in compose, so any rebuild restores the full
network surface automatically.

§53.5 recurrence-watchlist tag: `R-NETATTACH-DRIFT-AFTER-RECREATE` (path-(b)
architectural codification).

## Migration path (operator)

1. In Portainer UI → **Stacks** → **Add stack**.
2. **Name**: `uptime-kuma`. **Build method**: Repository.
3. **Repository URL**: `https://github.com/Cramraika/portainer-stacks` (public).
4. **Repository reference**: `refs/heads/main`.
5. **Compose path**: `stacks/uptime-kuma/docker-compose.yml`.
6. Enable **GitOps updates** with 5-min polling (matches the immich stack).
7. **Pre-flight before deploy**: confirm `/opt/uptime-kuma` on the host is
   non-empty (this is the persistent data dir; the stack mounts it as
   `/app/data` inside the container). Loss of `/opt/uptime-kuma` = loss of
   all monitor history.
8. **Deploy the stack.** Portainer will recreate the container under stack
   management, attaching all three networks per the compose declaration.

## §27.5 LIVE-PROBE: post-migration verification

```
ssh vagary-core-1 'docker inspect uptime-kuma --format "{{json .NetworkSettings.Networks}}" | jq keys'
# expect: ["bridge", "monitoring", "portainer-net"]

curl -sf https://host.chinmayramraika.in/api/status
# expect: HTTP 200 with JSON body containing monitor count

ssh vagary-core-1 'curl -sf http://127.0.0.1:3001/api/entry-page'
# expect: HTTP 200 (uptime-kuma serving locally)
```

## §27.7 re-probe-due

After any Portainer-driven recreate (image bump, host reboot, manual stack
redeploy), re-run the three commands above to confirm all networks still
attached and host_page `/api/status` still 200. Symptom of regression =
host_page status panel goes red.

## Cross-references

- `~/.claude/specs/recurrence-watchlist.md` row `R-NETATTACH-DRIFT-AFTER-RECREATE`
- master-pending OW for R-NETATTACH closure (filed concurrent with this stack)
- host_page `server/services/uptime-kuma-adapter.ts` (consumer of `/api/status`)
