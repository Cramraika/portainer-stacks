#!/usr/bin/env bash
# portainer-import.sh — re-onboard a stack from this repo into Portainer via Git-sync.
#
# Counterpart to portainer-export.sh: where export pulls a stack OUT of Portainer's
# BoltDB into stacks/<name>/docker-compose.yml, import POSTS a stack to Portainer
# configured for Git-sync mode (Portainer thereafter pulls from this repo).
#
# Per ADR-022 + Phase 7 migration: this is the operator-supervised re-onboarding
# step after export + commit + push are complete.
#
# Usage:
#   PORTAINER_URL=https://portainer.chinmayramraika.in \
#   PORTAINER_API_TOKEN=<from-Infisical-or-UI> \
#   PORTAINER_ENDPOINT_ID=1 \
#   REPO_URL=https://github.com/Cramraika/portainer-stacks.git \
#   REPO_REF=refs/heads/main \
#   REPO_PAT=<github-pat-if-private> \
#   ./portainer-import.sh <stack-name>
#
# stack-name MUST match the directory under stacks/ (e.g. immich, anjaan_online).
# Compose path is derived as stacks/<stack-name>/docker-compose.yml.
#
# Per universal-claudemd §50.3: secrets stay in Infisical. NEVER paste
# real .env values into the Portainer Stack env-vars panel — Portainer
# persists them to disk on the VPS.

set -euo pipefail

: "${PORTAINER_URL:?PORTAINER_URL required (e.g., https://portainer.chinmayramraika.in)}"
: "${PORTAINER_API_TOKEN:?PORTAINER_API_TOKEN required (operator-CFR)}"
: "${PORTAINER_ENDPOINT_ID:?PORTAINER_ENDPOINT_ID required (Portainer endpoint id; 1 = local)}"
: "${REPO_URL:?REPO_URL required (HTTPS clone URL for this repo)}"
: "${REPO_REF:=refs/heads/main}"

STACK_NAME="${1:-}"
if [[ -z "${STACK_NAME}" ]]; then
    echo "Usage: $0 <stack-name>" >&2
    echo "       stack-name must match a directory under stacks/" >&2
    exit 2
fi

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
COMPOSE_PATH="stacks/${STACK_NAME}/docker-compose.yml"

if [[ ! -f "${REPO_DIR}/${COMPOSE_PATH}" ]]; then
    echo "error: ${COMPOSE_PATH} not found in ${REPO_DIR}" >&2
    echo "       run portainer-export.sh first, or scaffold stacks/${STACK_NAME}/" >&2
    exit 1
fi

curl_pt() {
    curl -sk --fail \
        -H "X-API-Key: ${PORTAINER_API_TOKEN}" \
        -H "Content-Type: application/json" \
        "$@"
}

# Build the create-from-repository payload. method=repository activates Git-sync mode.
PAYLOAD=$(python3 -c "
import json, os
payload = {
    'Name': os.environ['STACK_NAME'],
    'RepositoryURL': os.environ['REPO_URL'],
    'RepositoryReferenceName': os.environ['REPO_REF'],
    'ComposeFile': os.environ['COMPOSE_PATH'],
    'AutoUpdate': {
        'Interval': '5m',
        'ForceUpdate': False,
        'Webhook': '',
    },
    'Env': [],
}
if os.environ.get('REPO_PAT'):
    payload['RepositoryAuthentication'] = True
    payload['RepositoryUsername'] = 'git'
    payload['RepositoryPassword'] = os.environ['REPO_PAT']
print(json.dumps(payload))
" STACK_NAME="${STACK_NAME}" REPO_URL="${REPO_URL}" REPO_REF="${REPO_REF}" COMPOSE_PATH="${COMPOSE_PATH}" REPO_PAT="${REPO_PAT:-}")

# Portainer v2 endpoint: /api/stacks/create/standalone/repository?endpointId=N
RESPONSE=$(curl_pt -X POST \
    -d "${PAYLOAD}" \
    "${PORTAINER_URL}/api/stacks/create/standalone/repository?endpointId=${PORTAINER_ENDPOINT_ID}")

STACK_ID=$(echo "${RESPONSE}" | python3 -c "import json,sys;print(json.load(sys.stdin).get('Id','?'))")

echo "imported stack '${STACK_NAME}' (id=${STACK_ID}) configured for Git-sync"
echo "  repo=${REPO_URL} ref=${REPO_REF}"
echo "  compose=${COMPOSE_PATH}"
echo "  auto-update=5m"
echo ""
echo "verify: ./portainer-verify.sh ${STACK_NAME}"
