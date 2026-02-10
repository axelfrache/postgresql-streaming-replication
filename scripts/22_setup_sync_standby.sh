#!/usr/bin/env bash
# Clone a standby with application_name for synchronous replication
# Usage: ./22_setup_sync_standby.sh <standby> <slot> <app_name> <primary>
# Example: ./22_setup_sync_standby.sh pg2 pg2_slot sync2 pg0
set -euo pipefail

STANDBY="${1:?Usage: $0 <standby> <slot> <app_name> <primary>}"
SLOT="${2:?Usage: $0 <standby> <slot> <app_name> <primary>}"
APP_NAME="${3:?Usage: $0 <standby> <slot> <app_name> <primary>}"
PRIMARY="${4:?Usage: $0 <standby> <slot> <app_name> <primary>}"

echo "=== Setting up ${STANDBY} as SYNC standby of ${PRIMARY} (app: ${APP_NAME}, slot: ${SLOT}) ==="

echo "[1/5] Stopping ${STANDBY}..."
docker compose stop "${STANDBY}"

echo "[2/5] Wiping data directory..."
docker compose run --rm -u postgres "${STANDBY}" \
  bash -c "rm -rf /var/lib/postgresql/data/*"

echo "[3/5] Running pg_basebackup..."
docker compose run --rm -u postgres "${STANDBY}" \
  pg_basebackup \
    -h "${PRIMARY}" -U repluser \
    -D /var/lib/postgresql/data \
    -Fp -Xs -P -R -S "${SLOT}"

echo "[4/5] Injecting primary_conninfo with application_name=${APP_NAME}..."
docker compose run --rm -u postgres "${STANDBY}" \
  bash -c "cat >> /var/lib/postgresql/data/postgresql.auto.conf <<EOF

primary_conninfo = 'host=${PRIMARY} port=5432 user=repluser password=replication application_name=${APP_NAME}'
primary_slot_name = '${SLOT}'
EOF"

echo "[5/5] Starting ${STANDBY}..."
docker compose start "${STANDBY}"

echo "=== ${STANDBY} replicating from ${PRIMARY} with application_name=${APP_NAME} ==="
