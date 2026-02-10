-- Test synchronous write behavior
-- Succeeds quickly if sync standby is up, HANGS if sync standby is down
\ir 00_check_primary.sql

\c music

\timing on
INSERT INTO Artists VALUES (99, 'Sync Test', 'Test', 'Test', 'test')
ON CONFLICT (artistID) DO UPDATE SET name = 'Sync Test';
\timing off
