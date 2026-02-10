-- Replication role and slots setup (idempotent)
\ir 00_check_primary.sql

DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'repluser') THEN
        CREATE ROLE repluser WITH REPLICATION LOGIN PASSWORD 'replication';
        RAISE NOTICE 'Role repluser created';
    ELSE
        RAISE NOTICE 'Role repluser already exists, skipping';
    END IF;
END $$;

DO $$
DECLARE
  s text;
BEGIN
  FOREACH s IN ARRAY ARRAY['pg1_slot', 'pg2_slot', 'pg3_slot']
  LOOP
    IF NOT EXISTS (
      SELECT 1
      FROM pg_replication_slots
      WHERE slot_name = s
    ) THEN
      PERFORM pg_create_physical_replication_slot(s);
      RAISE NOTICE 'Slot % created', s;
    ELSE
      RAISE NOTICE 'Slot % already exists', s;
    END IF;
  END LOOP;
END $$;
