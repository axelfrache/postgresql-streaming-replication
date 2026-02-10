-- Replication status (run on primary)
\ir 00_check_primary.sql

\echo '=== pg_stat_replication ==='
SELECT pid, usename, application_name, client_addr, state, sync_state,
       sent_lsn, write_lsn, flush_lsn, replay_lsn,
       sent_lsn - replay_lsn AS replay_lag_bytes
FROM pg_stat_replication;

\echo '=== Replication Slots ==='
SELECT slot_name, slot_type, active, restart_lsn, confirmed_flush_lsn
FROM pg_replication_slots;
