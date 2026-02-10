#!/usr/bin/env bash
# Clone a standby from the primary via pg_basebackup
# Usage: ./10_setup_standby.sh <standby> <slot>
# Example: ./10_setup_standby.sh pg1 pg1_slot
set -euo pipefail

STANDBY="${1:?Usage: $0 <standby> <slot>}"
SLOT="${2:?Usage: $0 <standby> <slot>}"
PRIMARY="pg0"

echo "=== Setting up ${STANDBY} as standby of ${PRIMARY} (slot: ${SLOT}) ==="

echo "[1/5] Stopping ${STANDBY}..."
docker compose stop "${STANDBY}"

echo "[2/5] Wiping data directory..."
docker compose run --rm -u root "${STANDBY}" \
  chown -R postgres:postgres /var/lib/postgresql/data

docker compose run --rm -u postgres "${STANDBY}" \
  bash -c "rm -rf /var/lib/postgresql/data/*"

echo "[3/5] Running pg_basebackup..."
docker compose run --rm -e PGPASSWORD=replication -u postgres "${STANDBY}" \
  pg_basebackup \
    -h "${PRIMARY}" -U repluser \
    -D /var/lib/postgresql/data \
    -Fp -Xs -P -R -S "${SLOT}"

echo "[4/5] Injecting primary_conninfo..."
docker compose run --rm -u postgres "${STANDBY}" \
  bash -c "cat >> /var/lib/postgresql/data/postgresql.auto.conf <<EOF

primary_conninfo = 'host=${PRIMARY} port=5432 user=repluser password=replication'
primary_slot_name = '${SLOT}'
EOF"

echo "[5/5] Starting ${STANDBY}..."
docker compose start "${STANDBY}"

echo "=== ${STANDBY} is now replicating from ${PRIMARY} ==="
