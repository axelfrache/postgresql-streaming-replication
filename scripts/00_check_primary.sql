-- Guard: ensure this runs on the primary only
DO $$
BEGIN
    IF pg_is_in_recovery() THEN
        RAISE EXCEPTION 'Run this on primary only. Current node is in recovery.';
    END IF;
END $$;
