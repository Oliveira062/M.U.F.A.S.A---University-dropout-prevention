from sqlalchemy import text

ROWS_LIMIT = 50
RISK_LIST_LIMIT = 10


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

SUBJECT_NAMES = text("""
    SELECT DISTINCT name FROM course_subjects ORDER BY name LIMIT 300
""")


SEARCH_LIMIT = 15
SEARCH_FIELDS = ("attendance", "average", "absences", "pending_items", "semester", "distance")

_SEARCH_FILTERS = """
     WHERE (CAST(:id_professor AS VARCHAR) IS NULL
            OR b.student_id IN (SELECT student_id FROM vw_chat_teacher_link WHERE id_professor = :id_professor))
       AND (CAST(:course_id AS VARCHAR) IS NULL OR b.course_id = :course_id)
       AND (CAST(:levels AS VARCHAR[]) IS NULL OR b.risk_level = ANY(CAST(:levels AS VARCHAR[])))
       AND (NOT CAST(:average_dropped AS BOOLEAN) OR b.average_trend < 0)
       AND (CAST(:attendance_ge AS NUMERIC) IS NULL OR b.attendance_pct >= :attendance_ge)
       AND (CAST(:attendance_gt AS NUMERIC) IS NULL OR b.attendance_pct >  :attendance_gt)
       AND (CAST(:attendance_le AS NUMERIC) IS NULL OR b.attendance_pct <= :attendance_le)
       AND (CAST(:attendance_lt AS NUMERIC) IS NULL OR b.attendance_pct <  :attendance_lt)
       AND (CAST(:average_ge AS NUMERIC) IS NULL OR b.current_average >= :average_ge)
       AND (CAST(:average_gt AS NUMERIC) IS NULL OR b.current_average >  :average_gt)
       AND (CAST(:average_le AS NUMERIC) IS NULL OR b.current_average <= :average_le)
       AND (CAST(:average_lt AS NUMERIC) IS NULL OR b.current_average <  :average_lt)
       AND (CAST(:absences_ge AS NUMERIC) IS NULL OR b.total_absences >= :absences_ge)
       AND (CAST(:absences_gt AS NUMERIC) IS NULL OR b.total_absences >  :absences_gt)
       AND (CAST(:absences_le AS NUMERIC) IS NULL OR b.total_absences <= :absences_le)
       AND (CAST(:absences_lt AS NUMERIC) IS NULL OR b.total_absences <  :absences_lt)
       AND (CAST(:pending_items_ge AS NUMERIC) IS NULL OR b.pending_activities >= :pending_items_ge)
       AND (CAST(:pending_items_gt AS NUMERIC) IS NULL OR b.pending_activities >  :pending_items_gt)
       AND (CAST(:pending_items_le AS NUMERIC) IS NULL OR b.pending_activities <= :pending_items_le)
       AND (CAST(:pending_items_lt AS NUMERIC) IS NULL OR b.pending_activities <  :pending_items_lt)
       AND (CAST(:semester_ge AS NUMERIC) IS NULL OR b.current_semester >= :semester_ge)
       AND (CAST(:semester_gt AS NUMERIC) IS NULL OR b.current_semester >  :semester_gt)
       AND (CAST(:semester_le AS NUMERIC) IS NULL OR b.current_semester <= :semester_le)
       AND (CAST(:semester_lt AS NUMERIC) IS NULL OR b.current_semester <  :semester_lt)
       AND (CAST(:distance_ge AS NUMERIC) IS NULL OR (:see_distance AND d.distance_km >= :distance_ge))
       AND (CAST(:distance_gt AS NUMERIC) IS NULL OR (:see_distance AND d.distance_km >  :distance_gt))
       AND (CAST(:distance_le AS NUMERIC) IS NULL OR (:see_distance AND d.distance_km <= :distance_le))
       AND (CAST(:distance_lt AS NUMERIC) IS NULL OR (:see_distance AND d.distance_km <  :distance_lt))
"""

STUDENT_SEARCH = text("""
    SELECT b.student_id, b.fictitious_name, b.current_semester, b.risk_level, b.attendance_pct, b.current_average,
           b.total_absences, b.pending_activities, b.average_trend,
           CASE WHEN :see_distance THEN d.distance_km END AS distance_km
      FROM vw_chat_students_search b
      LEFT JOIN vw_chat_commute d ON d.student_id = b.student_id AND :see_distance
""" + _SEARCH_FILTERS + """
     ORDER BY CASE b.risk_level WHEN 'Critical' THEN 0 WHEN 'High' THEN 1 WHEN 'Moderate' THEN 2
                                 WHEN 'Low' THEN 3 ELSE 4 END, b.attendance_pct NULLS LAST, b.fictitious_name
     LIMIT :limit
""")

STUDENT_SEARCH_COUNT = text("""
    SELECT COUNT(*) AS total,
           COUNT(*) FILTER (WHERE b.risk_level = 'Critical') AS critical,
           COUNT(*) FILTER (WHERE b.risk_level = 'High') AS high
      FROM vw_chat_students_search b
      LEFT JOIN vw_chat_commute d ON d.student_id = b.student_id AND :see_distance
""" + _SEARCH_FILTERS)

_SUFFIX = {">": ("gt",), ">=": ("ge",), "<": ("lt",), "<=": ("le",), "=": ("ge", "le"), "between": ("ge", "le")}


def search_parameters(filters: list, levels: list[str], average_dropped: bool, see_distance: bool,
                      id_professor: str | None = None, course_id: str | None = None) -> dict:
    params = {f"{c}_{s}": None for c in SEARCH_FIELDS for s in ("ge", "gt", "le", "lt")}
    for f in filters:
        if f.field not in SEARCH_FIELDS or f.operator not in _SUFFIX:
            raise ValueError("filter outside the allowed list")
        suffixes = _SUFFIX[f.operator]
        if f.operator == "between":
            params[f"{f.field}_ge"], params[f"{f.field}_le"] = f.value, f.value2
        else:
            for suffix in suffixes:
                params[f"{f.field}_{suffix}"] = f.value
    params.update({"levels": list(levels) or None, "average_dropped": bool(average_dropped), "see_distance": bool(see_distance),
                   "id_professor": id_professor, "course_id": course_id})
    return params


STUDENT_PROFILE = text("""
    SELECT fictitious_name, risk_level, previous_level, main_factors, academic_period, attendance_pct,
           current_average, previous_semester_average, average_trend, pending_activities
      FROM vw_chat_students_search
     WHERE student_id = :student_id
     LIMIT 1
""")

STUDENT_PENDING_ACTIVITIES = text("""
    SELECT subject, title, kind, deadline_at
      FROM vw_chat_student_activities
     WHERE student_id = :student_id AND delivered_at IS NULL
     ORDER BY deadline_at, subject
     LIMIT :limit
""")

LAST_OF_CONVERSATION = text("""
    SELECT m.redacted_question, m.intent
      FROM chat_messages m
      JOIN chat_conversations c ON c.conversation_id = m.conversation_id
     WHERE m.user_id = :user_id AND c.closed_at IS NULL
     ORDER BY m.moment DESC, m.message_id DESC
     LIMIT :limit
""")
