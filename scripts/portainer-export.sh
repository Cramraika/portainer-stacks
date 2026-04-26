#!/usr/bin/env bash
# portainer-export.sh — export a Portainer stack's compose definition.
#
# Usage:
#   PORTAINER_URL=https://portainer.chinmayramraika.in \
#   PORTAINER_API_TOKEN=<from-Infisical-or-UI> \
#   ./portainer-export.sh <stack-id>
#
# Or list all stacks first:
#   PORTAINER_URL=... PORTAINER_API_TOKEN=... ./portainer-export.sh --list

set -euo pipefail

: "${PORTAINER_URL:?PORTAINER_URL required (e.g., https://portainer.chinmayramraika.in)}"
: "${PORTAINER_API_TOKEN:?PORTAINER_API_TOKEN required (operator-CFR)}"

curl_pt() {
    curl -sk --fail \
        -H "X-API-Key: ${PORTAINER_API_TOKEN}" \
        -H "Content-Type: application/json" \
        "$@"
}

case "${1:-}" in
    --list)
        curl_pt "${PORTAINER_URL}/api/stacks" | \
            python3 -c "
import json, sys
stacks = json.load(sys.stdin)
print(f'{\"ID\":>4} {\"Name\":40} {\"Type\":8} {\"Status\":10}')
for s in stacks:
    typ = {1: 'swarm', 2: 'compose', 3: 'kubernetes'}.get(s.get('Type'), '?')
    status = {1: 'active', 2: 'inactive'}.get(s.get('Status'), '?')
    print(f\"{s['Id']:>4} {s['Name']:40} {typ:8} {status:10}\")
"
        ;;
    --help|"")
        echo "Usage: $0 <stack-id>     # export compose YAML"
        echo "       $0 --list         # list all stacks"
        exit 0
        ;;
    *)
        STACK_ID="$1"
        # Get stack metadata
        STACK=$(curl_pt "${PORTAINER_URL}/api/stacks/${STACK_ID}")
        STACK_NAME=$(echo "$STACK" | python3 -c "import json,sys;print(json.load(sys.stdin)['Name'])")
        # Get compose file content
        FILE=$(curl_pt "${PORTAINER_URL}/api/stacks/${STACK_ID}/file")
        echo "$FILE" | python3 -c "import json,sys;print(json.load(sys.stdin)['StackFileContent'])"
        echo "# Exported from Portainer stack ID=${STACK_ID} name=${STACK_NAME} on $(date -u +%FT%TZ)" >&2
        ;;
esac
