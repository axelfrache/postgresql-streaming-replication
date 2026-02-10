-- 05_checkpoint.sql
-- Forces a checkpoint.

\ir 00_check_primary.sql

CHECKPOINT;
RAISE NOTICE 'Checkpoint complete.';
