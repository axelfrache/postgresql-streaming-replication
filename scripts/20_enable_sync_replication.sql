-- Enable synchronous replication (FIRST 1 among sync2, sync3)
\ir 00_check_primary.sql

ALTER SYSTEM SET synchronous_standby_names = 'FIRST 1 (sync2, sync3)';
SELECT pg_reload_conf();

\echo '=== Verify ==='
SHOW synchronous_standby_names;
SELECT application_name, sync_state FROM pg_stat_replication;
