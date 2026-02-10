-- 00_check_primary.sql
-- Force execution on primary node only.

DO $$
BEGIN
    IF pg_is_in_recovery() THEN
        RAISE EXCEPTION 'Run this on primary only. Current node is in recovery.';
    END IF;
END $$;
