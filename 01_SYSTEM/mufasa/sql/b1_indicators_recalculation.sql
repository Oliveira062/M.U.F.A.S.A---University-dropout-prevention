BEGIN;

CREATE TABLE IF NOT EXISTS b1_original_indicators (
    student_id        VARCHAR(255) NOT NULL,
    academic_period  VARCHAR(255) NOT NULL,
    attendance_pct  INTEGER,
    current_average     NUMERIC,
    average_trend NUMERIC,
    copied_at      TIMESTAMPTZ  NOT NULL DEFAULT now(),
    PRIMARY KEY (student_id, academic_period),
    FOREIGN KEY (student_id, academic_period) REFERENCES academic_indicators(student_id, academic_period)
);
COMMENT ON TABLE b1_original_indicators IS
    'Average, attendance and trend as they came from the B1 dump, before the recalculation by subject.';
ALTER TABLE b1_original_indicators OWNER TO mufasa_owner;

INSERT INTO b1_original_indicators (student_id, academic_period, attendance_pct, current_average, average_trend)
SELECT student_id, academic_period, attendance_pct, current_average, average_trend FROM academic_indicators
ON CONFLICT (student_id, academic_period) DO NOTHING;

CREATE OR REPLACE FUNCTION student_indicators_recalculate(student VARCHAR) RETURNS void
LANGUAGE sql SECURITY DEFINER SET search_path = public, pg_temp AS $$
    WITH by_subjects AS (
        SELECT m.student_id, t.academic_period,
               round(sum(m.final_grade * mt.workload_h) / sum(mt.workload_h), 2) AS average,
               round(sum(m.attendance_pct * mt.workload_h) / sum(mt.workload_h)) AS attendance
          FROM enrollments m
          JOIN classes t ON t.class_id = m.class_id
          JOIN course_subjects mt ON mt.course_subject_id = t.course_subject_id
         WHERE m.student_id = student AND mt.workload_h > 0 AND m.final_grade IS NOT NULL AND m.attendance_pct IS NOT NULL
         GROUP BY m.student_id, t.academic_period
    )
    UPDATE academic_indicators i
       SET current_average     = d.average,
           attendance_pct  = d.attendance,
           average_trend = CASE WHEN i.previous_semester_average IS NULL THEN NULL
                                  ELSE round(d.average - i.previous_semester_average, 2) END
      FROM by_subjects d
     WHERE d.student_id = i.student_id AND d.academic_period = i.academic_period
       AND (i.current_average IS DISTINCT FROM d.average OR i.attendance_pct IS DISTINCT FROM d.attendance);
$$;

CREATE OR REPLACE FUNCTION tg_indicators_enrollments() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp AS $$
BEGIN
    IF TG_OP IN ('UPDATE', 'DELETE') THEN
        PERFORM student_indicators_recalculate(OLD.student_id);
    END IF;
    IF TG_OP IN ('INSERT', 'UPDATE') AND (TG_OP = 'INSERT' OR NEW.student_id IS DISTINCT FROM OLD.student_id) THEN
        PERFORM student_indicators_recalculate(NEW.student_id);
    END IF;
    RETURN NULL;
END $$;

ALTER FUNCTION student_indicators_recalculate(VARCHAR) OWNER TO mufasa_owner;
ALTER FUNCTION tg_indicators_enrollments() OWNER TO mufasa_owner;

DROP TRIGGER IF EXISTS tg_recalculation_enrollments ON enrollments;
CREATE TRIGGER tg_recalculation_enrollments
    AFTER INSERT OR DELETE OR UPDATE OF final_grade, attendance_pct, student_id, class_id ON enrollments
    FOR EACH ROW EXECUTE FUNCTION tg_indicators_enrollments();

WITH by_subjects AS (
    SELECT m.student_id, t.academic_period,
           round(sum(m.final_grade * mt.workload_h) / sum(mt.workload_h), 2) AS average,
           round(sum(m.attendance_pct * mt.workload_h) / sum(mt.workload_h)) AS attendance
      FROM enrollments m
      JOIN classes t ON t.class_id = m.class_id
      JOIN course_subjects mt ON mt.course_subject_id = t.course_subject_id
     WHERE mt.workload_h > 0 AND m.final_grade IS NOT NULL AND m.attendance_pct IS NOT NULL
     GROUP BY m.student_id, t.academic_period
)
UPDATE academic_indicators i
   SET current_average     = d.average,
       attendance_pct  = d.attendance,
       average_trend = CASE WHEN i.previous_semester_average IS NULL THEN NULL
                              ELSE round(d.average - i.previous_semester_average, 2) END
  FROM by_subjects d
 WHERE d.student_id = i.student_id AND d.academic_period = i.academic_period;

COMMIT;
