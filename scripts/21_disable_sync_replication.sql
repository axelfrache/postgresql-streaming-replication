-- Disable synchronous replication (back to async)
\ir 00_check_primary.sql

ALTER SYSTEM SET synchronous_standby_names = '';
SELECT pg_reload_conf();

\echo '=== Verify ==='
SHOW synchronous_standby_names;
SELECT application_name, sync_state FROM pg_stat_replication;
