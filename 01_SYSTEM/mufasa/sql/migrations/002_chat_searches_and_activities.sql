CREATE TABLE IF NOT EXISTS student_activities (
    activity_id  BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    student_id      VARCHAR(255) NOT NULL REFERENCES students(student_id),
    class_id      VARCHAR(255) NOT NULL REFERENCES classes(class_id),
    title        VARCHAR(120) NOT NULL,
    kind          VARCHAR(30)  NOT NULL,
    deadline_at      DATE         NOT NULL,
    delivered_at   DATE,
    simulated      BOOLEAN      NOT NULL DEFAULT FALSE
);
CREATE INDEX IF NOT EXISTS ix_deadline_student_activities ON student_activities (student_id, deadline_at);

ALTER TABLE student_activities OWNER TO mufasa_owner;

CREATE OR REPLACE VIEW vw_chat_student_activities WITH (security_barrier = true) AS
SELECT a.student_id, mt.name AS subject, a.title, a.kind, a.deadline_at, a.delivered_at
  FROM student_activities a
  JOIN classes   t  ON t.class_id   = a.class_id
  JOIN course_subjects mt ON mt.course_subject_id = t.course_subject_id;

CREATE OR REPLACE VIEW vw_chat_students_search WITH (security_barrier = true) AS
SELECT a.student_id, a.fictitious_name, a.course_id, a.current_semester,
       CASE s.level WHEN 'CRITICAL' THEN 'Critical' WHEN 'HIGH' THEN 'High'
                    WHEN 'MODERATE' THEN 'Moderate' WHEN 'LOW' THEN 'Low' END AS risk_level,
       CASE s.previous_level WHEN 'CRITICAL' THEN 'Critical' WHEN 'HIGH' THEN 'High'
                    WHEN 'MODERATE' THEN 'Moderate' WHEN 'LOW' THEN 'Low' END AS previous_level,
       s.main_factors,
       s.calculated_at::date AS assessment_date,
       i.academic_period, i.attendance_pct, i.total_absences, i.current_average, i.previous_semester_average,
       i.average_trend, i.pending_activities
  FROM students a
  LEFT JOIN vw_current_score s ON s.student_id = a.student_id AND s.level <> 'UNDETERMINED'
  LEFT JOIN LATERAL (SELECT * FROM academic_indicators x WHERE x.student_id = a.student_id
                      ORDER BY x.academic_period DESC LIMIT 1) i ON TRUE;

CREATE OR REPLACE VIEW vw_chat_commute WITH (security_barrier = true) AS
SELECT student_id, distance_km, commute_time_min
  FROM socioeconomic;

ALTER VIEW vw_chat_student_activities OWNER TO mufasa_owner;
ALTER VIEW vw_chat_students_search OWNER TO mufasa_owner;
ALTER VIEW vw_chat_commute OWNER TO mufasa_owner;

GRANT SELECT ON vw_chat_student_activities, vw_chat_students_search, vw_chat_commute TO mufasa_chat;
