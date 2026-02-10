-- Test read-only on standby: SELECT must work, INSERT must fail

\echo '=== Confirm standby is in recovery ==='
SELECT pg_is_in_recovery() AS is_standby;

\echo '=== Read test ==='
\c music
SELECT * FROM Artists;

\echo '=== Write test (should fail with read-only error) ==='
\set ON_ERROR_STOP off
INSERT INTO Artists VALUES (99, 'Test', 'Test', 'Test', 'test');
\set ON_ERROR_STOP on
