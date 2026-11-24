-- MUFASA — chatbot database (F2), on top of B1 and the B3 complement (PostgreSQL 16)
--
-- Apply AFTER sql/b3_complement.sql, connected as the database owner:
--     psql -d mufasa -f sql/chatbot.sql
--     psql -d mufasa -c "ALTER ROLE mufasa_chat PASSWORD 'choose-a-strong-password'"
--
-- What this file does (RN06, Annex D.2):
--   1. Creates read-only VIEWS with the minimum the chatbot answers.
--      None has socioeconomic, health, accessibility, age,
--      neighborhood, password or user data.
--   2. Creates the conversation and history tables (RN13).
--   3. Gives the mufasa_chat role access ONLY to these views and tables.
-- What it does NOT do: it does not change any B1 table or data.
-- The views also ignore enrollment rows without student_id. The 2,000 import
-- leftovers from the original dump are removed by sql/b1_leftovers_cleanup.sql
-- (or do not even exist in the clean dump in ../database/).

BEGIN;

-- ---------------------------------------------------------------------------
-- 1. Chatbot views
-- security_barrier prevents a function in the querier's WHERE from seeing
-- rows before the view's filter.
-- ---------------------------------------------------------------------------

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

-- Last assessment of each student, with the fictitious name for the staff lists.
CREATE OR REPLACE VIEW vw_chat_current_risk WITH (security_barrier = true) AS
SELECT a.student_id, a.fictitious_name, a.course_id, a.current_semester,
       r.risk_level, r.assessment_date, r.academic_period
  FROM students a
  JOIN LATERAL (
        SELECT r2.risk_level, r2.assessment_date, r2.academic_period
          FROM risk_assessments r2
         WHERE r2.student_id = a.student_id
         ORDER BY r2.assessment_date DESC, r2.assessment_id DESC
         LIMIT 1) r ON TRUE;

-- Student-teacher link, for the TEACHER profile scope.
CREATE OR REPLACE VIEW vw_chat_teacher_link WITH (security_barrier = true) AS
SELECT DISTINCT m.student_id, t.id_professor
  FROM enrollments m
  JOIN classes t ON t.class_id = m.class_id
 WHERE m.student_id IS NOT NULL;

-- ---------------------------------------------------------------------------
-- 2. Conversation and history
-- ---------------------------------------------------------------------------

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
    redacted_question    VARCHAR(600) NOT NULL,   -- no CPF, email, phone or student ID
    intent             VARCHAR(40)  NOT NULL,
    executed_query   VARCHAR(80),
    records            INTEGER      NOT NULL DEFAULT 0,
    answer             VARCHAR(4000) NOT NULL,
    redacted_by_ai      BOOLEAN      NOT NULL DEFAULT FALSE,
    bypass_attempt      BOOLEAN      NOT NULL DEFAULT FALSE
);
CREATE INDEX IF NOT EXISTS ix_chat_user_messages ON chat_messages(user_id, moment DESC);
CREATE INDEX IF NOT EXISTS ix_chat_bypass_messages ON chat_messages(moment) WHERE bypass_attempt;

-- ---------------------------------------------------------------------------
-- 3. Permissions of the mufasa_chat role (created in b3_complement.sql)
-- ---------------------------------------------------------------------------

-- Takes back what the B3 complement had given: the chatbot does not need the tables.
REVOKE ALL ON courses, course_subjects, classes FROM mufasa_chat;

GRANT SELECT ON vw_chat_student_subjects, vw_chat_indicators, vw_chat_current_risk,
               vw_chat_teacher_link TO mufasa_chat;
-- Subject names, to recognize the one mentioned in the question.
GRANT SELECT (name) ON course_subjects TO mufasa_chat;

GRANT SELECT, INSERT ON chat_conversations TO mufasa_chat;
GRANT UPDATE (last_interaction, closed_at, closing_reason) ON chat_conversations TO mufasa_chat;
GRANT SELECT, INSERT ON chat_messages TO mufasa_chat;   -- history: no UPDATE or DELETE
GRANT USAGE ON SEQUENCE chat_conversations_conversation_id_seq, chat_messages_message_id_seq TO mufasa_chat;
-- REFERENCES users requires the database to check the key; the role does not read the table.

-- Time ceiling per query, so a question never locks up the database.
ALTER ROLE mufasa_chat SET statement_timeout = '3s';

COMMIT;
