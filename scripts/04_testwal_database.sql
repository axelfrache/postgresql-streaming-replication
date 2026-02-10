-- 04_testwal_database.sql
-- Creates testwal DB and inserts 1M rows.

\ir 00_check_primary.sql

-- Create database 'testwal' if not exists
SELECT 'CREATE DATABASE testwal'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'testwal')\gexec

\c testwal

-- Ensure we are still on primary
DO $$
BEGIN
    IF pg_is_in_recovery() THEN
        RAISE EXCEPTION 'Run this on primary only. Current node is in recovery.';
    END IF;
END $$;

CREATE TABLE IF NOT EXISTS t1 (
    id integer
);

-- Idempotent Load
TRUNCATE t1;

INSERT INTO t1 (id)
SELECT generate_series(1, 1000000);

RAISE NOTICE 'Initialized testwal database with 1M rows.';
