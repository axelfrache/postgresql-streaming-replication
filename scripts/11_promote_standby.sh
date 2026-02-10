#!/usr/bin/env bash
# Promote a standby to primary
# Usage: ./11_promote_standby.sh <standby>
set -euo pipefail

STANDBY="${1:?Usage: $0 <standby>}"

echo "=== Promoting ${STANDBY} ==="
docker exec "${STANDBY}" psql -U postgres -c "SELECT pg_promote();"

sleep 2

echo "=== Verifying ==="
docker exec "${STANDBY}" psql -U postgres -c "SELECT pg_is_in_recovery() AS still_in_recovery;"
