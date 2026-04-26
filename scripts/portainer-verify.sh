#!/usr/bin/env bash
# portainer-verify.sh — verify stack health post-migration.
#
# Usage: ./portainer-verify.sh <stack-name>

set -euo pipefail

STACK="${1:?stack-name required}"

echo "=== Containers for stack: $STACK ==="
docker ps -a --filter "label=com.docker.compose.project=${STACK}" \
    --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "=== Health summary ==="
TOTAL=$(docker ps -aq --filter "label=com.docker.compose.project=${STACK}" | wc -l)
RUNNING=$(docker ps -q --filter "label=com.docker.compose.project=${STACK}" | wc -l)
HEALTHY=$(docker ps --filter "label=com.docker.compose.project=${STACK}" --filter "health=healthy" -q | wc -l)
echo "Total: ${TOTAL}, Running: ${RUNNING}, Healthy: ${HEALTHY}"

if [ "$RUNNING" -lt "$TOTAL" ]; then
    echo "WARNING: ${TOTAL}-${RUNNING}=$((TOTAL-RUNNING)) container(s) not running"
    exit 1
fi

echo "OK: stack $STACK healthy post-migration"
