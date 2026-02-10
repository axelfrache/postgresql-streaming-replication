-- WAL load: 1M rows in music.rows (truncate + insert for idempotence)
\ir 00_check_primary.sql

\c music

CREATE TABLE IF NOT EXISTS rows (
    id integer
);

TRUNCATE rows;

INSERT INTO rows (id)
SELECT generate_series(1, 1000000);
