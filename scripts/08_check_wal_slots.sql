-- WAL files and slots retention analysis (run on primary)
\ir 00_check_primary.sql

\echo '=== Current WAL position ==='
SELECT pg_current_wal_lsn() AS current_wal_lsn;

\echo '=== WAL files on disk ==='
SELECT * FROM pg_ls_waldir() ORDER BY modification DESC LIMIT 20;

\echo '=== Slots retention ==='
SELECT slot_name, active, restart_lsn,
       pg_current_wal_lsn() AS current_lsn,
       pg_wal_lsn_diff(pg_current_wal_lsn(), restart_lsn) AS retained_bytes
FROM pg_replication_slots ORDER BY slot_name;

\echo '=== WAL stats ==='
SELECT * FROM pg_stat_wal;
