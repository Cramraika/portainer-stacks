# anjaan_online

Anjaan — Hinglish consumer chat product ([anjaan.online](https://anjaan.online)).

| Field | Value |
|---|---|
| **Host** | vagary-core-1 |
| **Portainer stack ID** | 14 |
| **Stack type** | Git-deployed (Portainer pulls the compose from a Git repo) |
| **Captured** | 2026-05-17 via Portainer API |

## Why there is no `docker-compose.yml` here

This stack is **not** a Portainer editor-managed stack — Portainer deploys it
by pulling the compose file directly from a Git repository. Portainer keeps no
local copy of the compose, so there is nothing to export via
`/api/stacks/14/file` (the API returns *"Unable to retrieve Compose file from
disk"* for git-backed stacks).

The compose source of truth lives in the application repo, not here.
Duplicating it into `portainer-stacks` would create a drift-prone second copy.

| Git config field | Value |
|---|---|
| **Git URL** (as registered in Portainer) | `https://github.com/SMPL562/chat-bot` |
| **Reference** | default branch |
| **Compose path** | `docker-compose.yml` (repo root) |
| **Auto-update** | disabled |

> **Note on the Git URL.** Portainer still has the *old* repo path
> `SMPL562/chat-bot`. That repo was renamed to `anjaan-app` and migrated to the
> `Cramraika` account during the 2026-04-19 fleet rename. GitHub's old-URL
> redirect keeps the pull working, but the stack's Git URL in Portainer should
> be updated to `https://github.com/Cramraika/anjaan-app` to remove reliance on
> the redirect. — operator action.

## Source of truth

- Compose: `anjaan-app` repo → `docker-compose.yml`
- To change the deployed config, edit the compose in the `anjaan-app` repo and
  redeploy the stack in Portainer (or re-pull from Git).

## Environment variables

One stack env var is set in Portainer (not in Git): `GEMINI_API_KEY` (secret).
