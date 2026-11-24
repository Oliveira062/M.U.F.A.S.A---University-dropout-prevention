BEGIN;

CREATE OR REPLACE VIEW vw_chat_student_subjects WITH (security_barrier = true) AS
SELECT m.student_id,
       mt.name                  AS subject,
       t.academic_period,
       m.exam1, m.exam2, m.exam3,
       m.final_grade,
       m.attendance_pct,
       m.status,
       mt.minimum_attendance_pct
  FROM enrollments m
  JOIN classes   t  ON t.class_id   = m.class_id
  JOIN course_subjects mt ON mt.course_subject_id = t.course_subject_id
 WHERE m.student_id IS NOT NULL;

CREATE OR REPLACE VIEW vw_chat_indicators WITH (security_barrier = true) AS
SELECT student_id, academic_period, total_absences, attendance_pct, previous_semester_average,
       current_average, average_trend, pending_activities
  FROM academic_indicators;

CREATE OR REPLACE VIEW vw_chat_current_risk WITH (security_barrier = true) AS
SELECT a.student_id, a.fictitious_name, a.course_id, a.current_semester,
       CASE s.level WHEN 'CRITICAL' THEN 'Critical' WHEN 'HIGH' THEN 'High'
                    WHEN 'MODERATE' THEN 'Moderate' WHEN 'LOW' THEN 'Low' END AS risk_level,
       s.calculated_at::date AS assessment_date,
       (SELECT max(i.academic_period) FROM academic_indicators i WHERE i.student_id = a.student_id) AS academic_period
  FROM students a
  JOIN vw_current_score s ON s.student_id = a.student_id
 WHERE s.level <> 'UNDETERMINED';

CREATE OR REPLACE VIEW vw_chat_teacher_link WITH (security_barrier = true) AS
SELECT DISTINCT m.student_id, t.id_professor
  FROM enrollments m
  JOIN classes t ON t.class_id = m.class_id
 WHERE m.student_id IS NOT NULL;

CREATE TABLE IF NOT EXISTS chat_conversations (
    conversation_id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id           BIGINT      NOT NULL REFERENCES users(user_id),
    started_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    last_interaction     TIMESTAMPTZ NOT NULL DEFAULT now(),
    closed_at         TIMESTAMPTZ,
    closing_reason  VARCHAR(12) CHECK (closing_reason IN ('INACTIVITY', 'USER'))
);
CREATE INDEX IF NOT EXISTS ix_chat_open_conversations ON chat_conversations(user_id) WHERE closed_at IS NULL;

CREATE TABLE IF NOT EXISTS chat_messages (
    message_id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    conversation_id          BIGINT       NOT NULL REFERENCES chat_conversations(conversation_id),
    user_id           BIGINT       NOT NULL REFERENCES users(user_id),
    moment              TIMESTAMPTZ  NOT NULL DEFAULT now(),
    redacted_question    VARCHAR(600) NOT NULL,
    intent             VARCHAR(40)  NOT NULL,
    executed_query   VARCHAR(80),
    records            INTEGER      NOT NULL DEFAULT 0,
    answer             VARCHAR(4000) NOT NULL,
    redacted_by_ai      BOOLEAN      NOT NULL DEFAULT FALSE,
    bypass_attempt      BOOLEAN      NOT NULL DEFAULT FALSE
);
CREATE INDEX IF NOT EXISTS ix_chat_user_messages ON chat_messages(user_id, moment DESC);
CREATE INDEX IF NOT EXISTS ix_chat_bypass_messages ON chat_messages(moment) WHERE bypass_attempt;

REVOKE ALL ON courses, course_subjects, classes FROM mufasa_chat;

GRANT SELECT ON vw_chat_student_subjects, vw_chat_indicators, vw_chat_current_risk,
               vw_chat_teacher_link TO mufasa_chat;

GRANT SELECT (name) ON course_subjects TO mufasa_chat;

GRANT SELECT, INSERT ON chat_conversations TO mufasa_chat;
GRANT UPDATE (last_interaction, closed_at, closing_reason) ON chat_conversations TO mufasa_chat;
GRANT SELECT, INSERT ON chat_messages TO mufasa_chat;

GRANT INSERT ON technical_logs TO mufasa_chat;
GRANT SELECT, INSERT, UPDATE ON service_status TO mufasa_chat;
GRANT USAGE ON SEQUENCE chat_conversations_conversation_id_seq, chat_messages_message_id_seq TO mufasa_chat;

DO $$
DECLARE
    view TEXT;
BEGIN
    FOREACH view IN ARRAY ARRAY['vw_chat_student_subjects', 'vw_chat_indicators', 'vw_chat_current_risk',
                                 'vw_chat_teacher_link']
    LOOP
        EXECUTE format('ALTER VIEW %I OWNER TO mufasa_owner', view);
    END LOOP;
END $$;

ALTER ROLE mufasa_chat SET statement_timeout = '3s';

COMMIT;
