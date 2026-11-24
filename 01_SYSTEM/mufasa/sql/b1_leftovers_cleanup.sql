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
