#!/usr/bin/env bash
# Full failover: stop old primary, promote standby, re-clone old primary as new standby
# Usage: ./12_failover.sh <old_primary> <new_primary> <slot>
# Example: ./12_failover.sh pg0 pg1 pg1_slot
set -euo pipefail

OLD_PRIMARY="${1:?Usage: $0 <old_primary> <new_primary> <slot>}"
NEW_PRIMARY="${2:?Usage: $0 <old_primary> <new_primary> <slot>}"
SLOT="${3:?Usage: $0 <old_primary> <new_primary> <slot>}"

echo "=== Failover: ${OLD_PRIMARY} → ${NEW_PRIMARY} ==="

echo "[1/4] Stopping ${OLD_PRIMARY}..."
docker compose stop "${OLD_PRIMARY}"

echo "[2/4] Promoting ${NEW_PRIMARY}..."
IS_RECOVERY=$(docker exec "${NEW_PRIMARY}" psql -U postgres -tAc "SELECT pg_is_in_recovery()")
if [ "$IS_RECOVERY" = "t" ]; then
    docker exec "${NEW_PRIMARY}" psql -U postgres -c "SELECT pg_promote();"
else
    echo "Notice: ${NEW_PRIMARY} is already a primary (skipping promotion)."
fi
sleep 2
docker exec "${NEW_PRIMARY}" psql -U postgres -c "SELECT pg_is_in_recovery() AS still_in_recovery;"

echo "[3/4] Creating replication slot on ${NEW_PRIMARY}..."
docker exec "${NEW_PRIMARY}" psql -U postgres -c "
DO \$\$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_replication_slots WHERE slot_name = '${SLOT}') THEN
        PERFORM pg_create_physical_replication_slot('${SLOT}');
        RAISE NOTICE 'Slot ${SLOT} created';
    ELSE
        RAISE NOTICE 'Slot ${SLOT} already exists';
    END IF;
END \$\$;
"

echo "[4/4] Re-cloning ${OLD_PRIMARY} as standby of ${NEW_PRIMARY}..."
docker compose run --rm -u root "${OLD_PRIMARY}" \
  chown -R postgres:postgres /var/lib/postgresql/data

docker compose run --rm -u postgres "${OLD_PRIMARY}" \
  bash -c "rm -rf /var/lib/postgresql/data/*"

docker compose run --rm -e PGPASSWORD=replication -u postgres "${OLD_PRIMARY}" \
  pg_basebackup \
    -h "${NEW_PRIMARY}" -U repluser \
    -D /var/lib/postgresql/data \
    -Fp -Xs -P -R -S "${SLOT}"

docker compose run --rm -u postgres "${OLD_PRIMARY}" \
  bash -c "cat >> /var/lib/postgresql/data/postgresql.auto.conf <<EOF

primary_conninfo = 'host=${NEW_PRIMARY} port=5432 user=repluser password=replication'
primary_slot_name = '${SLOT}'
EOF"

docker compose start "${OLD_PRIMARY}"

echo "=== Failover complete: ${NEW_PRIMARY} is primary, ${OLD_PRIMARY} is standby ==="
