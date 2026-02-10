-- WAL receiver status (run on standby)

\echo '=== pg_stat_wal_receiver ==='
SELECT pid, status, sender_host, sender_port, slot_name,
       received_lsn, last_msg_send_time, last_msg_receipt_time, conninfo
FROM pg_stat_wal_receiver;

\echo '=== Recovery status ==='
SELECT pg_is_in_recovery() AS is_standby;
SELECT pg_last_wal_receive_lsn() AS last_received_lsn;
SELECT pg_last_wal_replay_lsn() AS last_replayed_lsn;
SELECT pg_last_xact_replay_timestamp() AS last_replay_timestamp;
