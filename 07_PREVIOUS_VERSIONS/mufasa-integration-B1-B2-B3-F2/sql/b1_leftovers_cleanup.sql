-- MUFASA — cleanup of the B1 import leftovers (approved by Joao on 28/10/2026)
--
-- For whoever ALREADY loaded the original B1 dump. Whoever loads from scratch
-- can use "database/Samuel Part BackEnd B1 - clean.sql", which already comes without them.
--     psql -d mufasa -f sql/b1_leftovers_cleanup.sql
--
-- What it removes: the 2,000 enrollment rows without enrollment_id, without student_id
-- and with a nonexistent class_id (IA1000-A, IA997-A...). They do not belong to
-- no student, and no API or chatbot query uses them.
-- What it does NOT touch: no other row, no grade, no metric.
-- If the count is different from 2,000, the transaction is rolled back.

BEGIN;

DO $$
DECLARE
    removed integer;
BEGIN
    DELETE FROM enrollments m
     WHERE m.student_id IS NULL
       AND m.enrollment_id IS NULL
       AND NOT EXISTS (SELECT 1 FROM classes t WHERE t.class_id = m.class_id);
    GET DIAGNOSTICS removed = ROW_COUNT;
    IF removed NOT IN (0, 2000) THEN
        RAISE EXCEPTION 'Expected 2000 leftover rows, found %. Nothing was removed.', removed;
    END IF;
    RAISE NOTICE 'Leftover rows removed: %', removed;
END $$;

COMMIT;
