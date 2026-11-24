from sqlalchemy import text


USER_BY_LOGIN = text("""
    SELECT user_id, login, password_hash, profile, student_id, id_professor, course_id,
           active, login_failures, blocked_until, demo
      FROM users
     WHERE login = :login
""")

USER_BY_ID = text("""
    SELECT user_id, login, profile, student_id, id_professor, course_id, active, name,
           must_change_password, version_term
      FROM users
     WHERE user_id = :user_id
""")

REGISTER_LOGIN_FAILURE = text("""
    UPDATE users
       SET login_failures = login_failures + 1,
           blocked_until = CASE WHEN login_failures + 1 >= :failures_max
                                THEN :block_until ELSE blocked_until END
     WHERE user_id = :user_id
""")

RESET_LOGIN_FAILURES = text("""
    UPDATE users
       SET login_failures = 0, blocked_until = NULL, last_login = :now
     WHERE user_id = :user_id
""")

REVOKED_TOKEN = text("SELECT 1 FROM revoked_tokens WHERE jti = :jti")

REVOKE_TOKEN = text("""
    INSERT INTO revoked_tokens (jti, expires_at) VALUES (:jti, :expires_at)
""")


STUDENT_OF_TEACHER_CLASSES = text("""
    SELECT 1
      FROM enrollments m
      JOIN classes t ON t.class_id = m.class_id
     WHERE m.student_id = :student_id
       AND t.id_professor = :id_professor
     LIMIT 1
""")

COURSE_STUDENT = text("""
    SELECT 1 FROM students WHERE student_id = :student_id AND course_id = :course_id
""")

STUDENT_OPEN_ALERT = text("""
    SELECT a.alert_id, a.owner_id, a.level, a.status, a.deadline_at, s.main_factors
      FROM alerts a
      LEFT JOIN vw_current_score s ON s.student_id = a.student_id
     WHERE a.student_id = :student_id AND a.kind = 'PEDAGOGICAL' AND a.status <> 'CLOSED'
""")

CURRENT_SCORE = text("""
    SELECT id_score, score, level, origin_level, overlap_reason, partial, completeness,
           factors, main_factors, modifiers, recommendations, recommendation,
           trend, previous_score, previous_level, model_version, parameters_version, calculated_at
      FROM vw_current_score
     WHERE student_id = :student_id
""")


_BASE_LIST = """
    SELECT a.student_id, a.fictitious_name, a.current_semester, s.level, s.score
      FROM students a
      LEFT JOIN vw_current_score s ON s.student_id = a.student_id
     WHERE (CAST(:semester AS INTEGER) IS NULL OR a.current_semester = :semester)
       AND (CAST(:level AS VARCHAR) IS NULL OR s.level = :level)
       AND (CAST(:search AS VARCHAR) IS NULL OR lower(a.fictitious_name) LIKE :search OR lower(a.student_id) LIKE :search)
"""

_FILTER_BY_PROFILE = {
    "TEACHER": """
       AND EXISTS (SELECT 1 FROM enrollments m JOIN classes t ON t.class_id = m.class_id
                    WHERE m.student_id = a.student_id AND t.id_professor = :id_professor)
    """,
    "COORDINATION": "AND a.course_id = :course_id",
    "SUPPORT_CENTER": """AND EXISTS (SELECT 1 FROM alerts al WHERE al.student_id = a.student_id
                                       AND al.status <> 'CLOSED' AND al.owner_id = :user_id)""",
}

ORDERINGS = {
    "name": "ORDER BY a.fictitious_name, a.student_id",
    "semester": "ORDER BY a.current_semester, a.student_id",
    "enrollment": "ORDER BY a.student_id",
    "risk": "ORDER BY s.score DESC NULLS LAST, a.student_id",
}


def students_total_query(profile: str):
    return text("SELECT count(*) FROM (" + _BASE_LIST + _FILTER_BY_PROFILE[profile] + ") q")


def students_list_query(profile: str, order: str):
    return text(
        _BASE_LIST
        + _FILTER_BY_PROFILE[profile]
        + "\n" + ORDERINGS[order]
        + "\n LIMIT :limit OFFSET :commute"
    )


BASIC_STUDENT = text("""
    SELECT a.student_id, a.fictitious_name, a.course_id, c.name AS course, a.current_semester
      FROM students a
      LEFT JOIN courses c ON c.course_id = a.course_id
     WHERE a.student_id = :student_id
""")


CURRENT_INDICATORS = text("""
    SELECT academic_period, total_absences, attendance_pct, failed_subjects_history,
           pending_activities, previous_semester_average, current_average, average_trend
      FROM academic_indicators
     WHERE student_id = :student_id
     ORDER BY academic_period DESC
     LIMIT 1
""")

RESTRICTED_SOCIOECONOMIC = text("""
    SELECT per_capita_income, works, daily_work_hours, commute_time_min, scholarship_aid
      FROM socioeconomic
     WHERE student_id = :student_id
""")

SOCIOECONOMIC_FOR_SCORE = text("""
    SELECT per_capita_income, works, daily_work_hours, commute_time_min
      FROM socioeconomic
     WHERE student_id = :student_id
""")

SUPPORT_SENSITIVE_DATA = text("""
    SELECT encrypted_data FROM student_support WHERE student_id = :student_id
""")

SCORE_HISTORY = text("""
    SELECT calculated_at, score, level, origin_level, completeness, model_version, parameters_version
      FROM risk_scores
     WHERE student_id = :student_id
     ORDER BY calculated_at, id_score
     LIMIT :limit
""")

RISK_HISTORY = text("""
    SELECT academic_period, kind, assessment_date, dropout_risk_pct, risk_level
      FROM risk_assessments
     WHERE student_id = :student_id
     ORDER BY assessment_date, assessment_id
     LIMIT :limit
""")


AGGREGATES_BY_SEMESTER = text("""
    SELECT a.current_semester AS semester, s.level AS risk_level, COUNT(*) AS total
      FROM students a
      JOIN vw_current_score s ON s.student_id = a.student_id
     WHERE (CAST(:course_id AS VARCHAR) IS NULL OR a.course_id = :course_id)
     GROUP BY a.current_semester, s.level
    HAVING COUNT(*) >= :group_minimum
     ORDER BY a.current_semester, s.level
""")
STUDENT_AGE = text("SELECT age FROM students WHERE student_id = :student_id")


STUDENT_CONSENTS = text("""
    SELECT purpose, granted, granted_by, term_version, registered_at
      FROM consents
     WHERE student_id = :student_id
     ORDER BY registered_at, consent_id
""")

REGISTER_CONSENT = text("""
    INSERT INTO consents
           (student_id, purpose, granted, granted_by, term_version, registered_at, user_id)
    VALUES (:student_id, :purpose, :granted, :granted_by, :term_version, :registered_at, :user_id)
""")

MY_DATA_REGISTRATION = text("""
    SELECT student_id, fictitious_name, course_id, current_semester, age, neighborhood, high_school_type
      FROM students
     WHERE student_id = :student_id
""")

MY_DATA_SOCIOECONOMIC = text("""
    SELECT monthly_family_income, household_residents, per_capita_income, scholarship_aid, works,
           daily_work_hours, weekly_study_hours, weekly_family_responsibilities_h,
           distance_km, commute_time_min, transport_mode, prouni, fies, employee_discount
      FROM socioeconomic
     WHERE student_id = :student_id
""")

MY_DATA_ENROLLMENTS = text("""
    SELECT m.class_id, mt.name AS course_subject, m.final_grade, m.attendance_pct, m.status
      FROM enrollments m
      JOIN classes t ON t.class_id = m.class_id
      JOIN course_subjects mt ON mt.course_subject_id = t.course_subject_id
     WHERE m.student_id = :student_id
     ORDER BY m.class_id
""")

REGISTER_DATA_SUBJECT_REQUEST = text("""
    INSERT INTO data_subject_requests (student_id, kind, description, status, registered_at)
    VALUES (:student_id, :kind, :description, 'OPENED', :registered_at)
""")

LIST_DATA_SUBJECT_REQUESTS = text("""
    SELECT subject_request_id, student_id, kind, status, registered_at
      FROM data_subject_requests
     ORDER BY registered_at DESC, subject_request_id DESC
     LIMIT :limit OFFSET :commute
""")


REGISTER_AUDIT = text("""
    INSERT INTO access_audit
           (moment, request_id, user_id, profile, operation, resource, target_student_id, result, origin)
    VALUES (:moment, :request_id, :user_id, :profile, :operation, :resource, :target_student_id, :result, :origin)
""")

LIST_AUDIT = text("""
    SELECT moment, request_id, user_id, profile, operation, resource, target_student_id, result
      FROM access_audit
     WHERE (CAST(:student_id AS VARCHAR) IS NULL OR target_student_id = :student_id)
       AND (CAST(:profile AS VARCHAR) IS NULL OR profile = :profile)
       AND (CAST(:result AS VARCHAR) IS NULL OR result = :result)
       AND (CAST(:operation AS VARCHAR) IS NULL OR operation = :operation)
       AND (CAST(:de AS TIMESTAMP) IS NULL OR moment >= :de)
       AND (CAST(:until AS TIMESTAMP) IS NULL OR moment < :until)
     ORDER BY moment DESC, audit_id DESC
     LIMIT :limit OFFSET :commute
""")
