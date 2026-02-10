-- testwal database: table t1 with 1M rows
\ir 00_check_primary.sql

SELECT 'CREATE DATABASE testwal'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'testwal')\gexec

\c testwal

DO $$
BEGIN
    IF pg_is_in_recovery() THEN
        RAISE EXCEPTION 'Run this on primary only. Current node is in recovery.';
    END IF;
END $$;

CREATE TABLE IF NOT EXISTS t1 (
    id integer
);

TRUNCATE t1;

INSERT INTO t1 (id)
SELECT generate_series(1, 1000000);
