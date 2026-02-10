-- 01_replication_setup.sql
-- Sets up replication role and slots idempotently.

\ir 00_check_primary.sql

-- Create replication role 'repluser'
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'repluser') THEN
        CREATE ROLE repluser WITH REPLICATION LOGIN PASSWORD 'replication';
        RAISE NOTICE 'Role repluser created';
    ELSE
        RAISE NOTICE 'Role repluser already exists, skipping';
    END IF;
END $$;

-- Create physical replication slots for pg1, pg2, pg3 idempotently
DO $$
DECLARE
    slot_name text;
BEGIN
    FOR slot_name IN SELECT unnest(ARRAY['pg1_slot', 'pg2_slot', 'pg3_slot']) LOOP
        IF NOT EXISTS (SELECT 1 FROM pg_replication_slots WHERE msg_slot_name = slot_name) THEN
            PERFORM pg_create_physical_replication_slot(slot_name);
            RAISE NOTICE 'Replication slot % created', slot_name;
        ELSE
            RAISE NOTICE 'Replication slot % already exists, skipping', slot_name;
        END IF;
    END LOOP;
END $$;
