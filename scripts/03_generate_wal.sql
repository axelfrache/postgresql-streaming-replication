-- 03_generate_wal.sql
-- Generates WAL activity by inserting 1M rows into music.rows.

\ir 00_check_primary.sql

\c music

CREATE TABLE IF NOT EXISTS rows (
    id integer
);

-- Idempotent Load: Truncate then Insert
TRUNCATE rows;

INSERT INTO rows (id)
SELECT generate_series(1, 1000000);

RAISE NOTICE 'Inserted 1,000,000 rows into music.rows';
