"""
All of the chatbot's SQL queries, in a single place for review.

Same rule as B3 (app/api/database.py): only constants with named
parameters, none built with user text. The chatbot does not generate SQL: the
intent picks ONE of these constants and the server fills in the parameters
with the logged-in user's scope (RN06).

Every query has a LIMIT (Annex D.2: mandatory row limit) and reads only
the vw_chat_* views created in sql/chatbot.sql.
"""

from sqlalchemy import text

ROWS_LIMIT = 50
RISK_LIST_LIMIT = 10

# ---------------------------------------------------------------------------
# Student's own data
# ---------------------------------------------------------------------------

STUDENT_SUBJECTS = text("""
    SELECT subject, academic_period, exam1, exam2, exam3, final_grade, attendance_pct, status,
           minimum_attendance_pct
      FROM vw_chat_student_subjects
     WHERE student_id = :student_id
     ORDER BY subject
     LIMIT :limit
""")

STUDENT_INDICATORS = text("""
    SELECT academic_period, total_absences, attendance_pct, previous_semester_average, current_average,
           average_trend, pending_activities
      FROM vw_chat_indicators
     WHERE student_id = :student_id
     ORDER BY academic_period DESC
     LIMIT 1
""")

STUDENT_RISK = text("""
    SELECT student_id, fictitious_name, risk_level, assessment_date, academic_period
      FROM vw_chat_current_risk
     WHERE student_id = :student_id
     LIMIT 1
""")

# ---------------------------------------------------------------------------
# Staff: counts and lists within the profile's scope
# ---------------------------------------------------------------------------

COURSE_RISK_SUMMARY = text("""
    SELECT risk_level, COUNT(*) AS total
      FROM vw_chat_current_risk
     WHERE course_id = :course_id
     GROUP BY risk_level
     LIMIT 10
""")

TEACHER_RISK_SUMMARY = text("""
    SELECT risk_level, COUNT(*) AS total
      FROM vw_chat_current_risk
     WHERE student_id IN (SELECT student_id FROM vw_chat_teacher_link WHERE id_professor = :id_professor)
     GROUP BY risk_level
     LIMIT 10
""")

COURSE_LARGEST_RISK = text("""
    SELECT student_id, fictitious_name, current_semester, risk_level, assessment_date
      FROM vw_chat_current_risk
     WHERE course_id = :course_id
       AND risk_level IN (:critical, :high)
     ORDER BY CASE WHEN risk_level = :critical THEN 0 ELSE 1 END, assessment_date DESC, fictitious_name
     LIMIT :limit
""")

TEACHER_LARGEST_RISK = text("""
    SELECT student_id, fictitious_name, current_semester, risk_level, assessment_date
      FROM vw_chat_current_risk
     WHERE student_id IN (SELECT student_id FROM vw_chat_teacher_link WHERE id_professor = :id_professor)
       AND risk_level IN (:critical, :high)
     ORDER BY CASE WHEN risk_level = :critical THEN 0 ELSE 1 END, assessment_date DESC, fictitious_name
     LIMIT :limit
""")

# ---------------------------------------------------------------------------
# Conversation and history (RN13, Annex D.2 audit)
# ---------------------------------------------------------------------------

OPEN_CONVERSATION = text("""
    SELECT conversation_id, last_interaction
      FROM chat_conversations
     WHERE user_id = :user_id AND closed_at IS NULL
     ORDER BY conversation_id DESC
     LIMIT 1
""")

NEW_CONVERSATION = text("""
    INSERT INTO chat_conversations (user_id, started_at, last_interaction)
    VALUES (:user_id, :now, :now)
    RETURNING conversation_id
""")

PLAY_CONVERSATION = text("""
    UPDATE chat_conversations SET last_interaction = :now
     WHERE conversation_id = :conversation_id AND user_id = :user_id
""")

CLOSE_CONVERSATION = text("""
    UPDATE chat_conversations SET closed_at = :now, closing_reason = :reason
     WHERE conversation_id = :conversation_id AND user_id = :user_id AND closed_at IS NULL
""")

REGISTER_MESSAGE = text("""
    INSERT INTO chat_messages
           (conversation_id, user_id, moment, redacted_question, intent, executed_query,
            records, answer, redacted_by_ai, bypass_attempt)
    VALUES (:conversation_id, :user_id, :moment, :redacted_question, :intent, :executed_query,
            :records, :answer, :redacted_by_ai, :bypass_attempt)
""")

USER_HISTORY = text("""
    SELECT conversation_id, moment, redacted_question, intent, answer
      FROM chat_messages
     WHERE user_id = :user_id
     ORDER BY moment DESC, message_id DESC
     LIMIT :limit
""")

# Subject catalog: only used to recognize the name mentioned in the
# question and say "you are not enrolled in it", instead of making it up.
SUBJECT_NAMES = text("""
    SELECT DISTINCT name FROM course_subjects ORDER BY name LIMIT 300
""")
