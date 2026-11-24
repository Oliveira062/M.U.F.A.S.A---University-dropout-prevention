"""
All of B3's SQL queries, in a single place for review.

Each constant uses only named parameters (:name). None is built with
user data. Where the query needs to vary (ordering), the variation comes
from an allowlist of fixed fragments, never from the text received.

The optional filters use CAST(:x AS type) IS NULL so PostgreSQL knows
the parameter's type even when it arrives empty.

Minimization (LGPD art. 6, III): each query selects only the columns
the endpoint returns. No SELECT *.
"""

from sqlalchemy import text

# ---------------------------------------------------------------------------
# Users and session
# ---------------------------------------------------------------------------

USER_BY_LOGIN = text("""
    SELECT user_id, login, password_hash, profile, student_id, id_professor, course_id,
           active, login_failures, blocked_until
      FROM users
     WHERE login = :login
""")

USER_BY_ID = text("""
    SELECT user_id, login, profile, student_id, id_professor, course_id, active
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

# ---------------------------------------------------------------------------
# Access scope (RN07, RN17)
# ---------------------------------------------------------------------------

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

MORE_RECENT_LEVEL = text("""
    SELECT risk_level
      FROM risk_assessments
     WHERE student_id = :student_id
     ORDER BY assessment_date DESC, assessment_id DESC
     LIMIT 1
""")

# ---------------------------------------------------------------------------
# Listing. The level comes from the last stored assessment, in a single query:
# no calculating the score student by student inside a loop (N+1).
# ---------------------------------------------------------------------------

_SUBCONSULTA_LEVEL = """
    (SELECT r.risk_level FROM risk_assessments r
      WHERE r.student_id = a.student_id
      ORDER BY r.assessment_date DESC, r.assessment_id DESC
      LIMIT 1)
"""

_BASE_LIST = f"""
    SELECT a.student_id, a.fictitious_name, a.current_semester, {_SUBCONSULTA_LEVEL} AS risk_level
      FROM students a
     WHERE (CAST(:semester AS INTEGER) IS NULL OR a.current_semester = :semester)
"""

_FILTER_BY_PROFILE = {
    "TEACHER": """
       AND EXISTS (SELECT 1 FROM enrollments m JOIN classes t ON t.class_id = m.class_id
                    WHERE m.student_id = a.student_id AND t.id_professor = :id_professor)
    """,
    "COORDINATION": "AND a.course_id = :course_id",
    "SUPPORT_CENTER": f"AND a.course_id = :course_id AND {_SUBCONSULTA_LEVEL} IN ('High', 'Critical')",
}

# Sorting allowlist: the URL parameter picks the KEY, never the SQL.
ORDERINGS = {
    "name": "ORDER BY a.fictitious_name, a.student_id",
    "semester": "ORDER BY a.current_semester, a.student_id",
    "enrollment": "ORDER BY a.student_id",
}


def students_list_query(profile: str, order: str):
    """Builds the listing only from constant fragments in this file."""
    return text(
        _BASE_LIST
        + _FILTER_BY_PROFILE[profile]
        + "\n" + ORDERINGS[order]
        + "\n LIMIT :limit OFFSET :commute"
    )


# ---------------------------------------------------------------------------
# Student profile, split by degree of sensitivity
# ---------------------------------------------------------------------------

BASIC_STUDENT = text("""
    SELECT a.student_id, a.fictitious_name, a.course_id, c.name AS course, a.current_semester
      FROM students a
      LEFT JOIN courses c ON c.course_id = a.course_id
     WHERE a.student_id = :student_id
""")

# Age only for the minor rule (RN16, LGPD art. 14); it is not returned.
STUDENT_AGE = text("SELECT age FROM students WHERE student_id = :student_id")

CURRENT_INDICATORS = text("""
    SELECT academic_period, total_absences, attendance_pct, failed_subjects_history,
           pending_activities, previous_semester_average, current_average, average_trend
      FROM academic_indicators
     WHERE student_id = :student_id
     ORDER BY academic_period DESC
     LIMIT 1
""")

# No total family income, number of residents, ProUni, FIES or discount:
# the score uses only per capita income, and no profile needs the others.
RESTRICTED_SOCIOECONOMIC = text("""
    SELECT per_capita_income, works, daily_work_hours, commute_time_min, scholarship_aid
      FROM socioeconomic
     WHERE student_id = :student_id
""")

SUPPORT_SENSITIVE_DATA = text("""
    SELECT requested_psychosocial_support, accessibility_need
      FROM students
     WHERE student_id = :student_id
""")

RISK_HISTORY = text("""
    SELECT academic_period, kind, assessment_date, dropout_risk_pct, risk_level
      FROM risk_assessments
     WHERE student_id = :student_id
     ORDER BY assessment_date, assessment_id
     LIMIT :limit
""")

# ---------------------------------------------------------------------------
# Aggregates (CA19): groups with fewer than 5 students do not leave the database.
# ---------------------------------------------------------------------------

AGGREGATES_BY_SEMESTER = text(f"""
    SELECT a.current_semester AS semester, {_SUBCONSULTA_LEVEL} AS risk_level, COUNT(*) AS total
      FROM students a
     WHERE (CAST(:course_id AS VARCHAR) IS NULL OR a.course_id = :course_id)
     GROUP BY a.current_semester, risk_level
    HAVING COUNT(*) >= :group_minimum
     ORDER BY a.current_semester, risk_level
""")

# ---------------------------------------------------------------------------
# Data subject rights and consent (LGPD arts. 8, 11, 14, 18)
# ---------------------------------------------------------------------------

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
    SELECT student_id, fictitious_name, course_id, current_semester, age, neighborhood, high_school_type,
           requested_psychosocial_support, accessibility_need
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

# ---------------------------------------------------------------------------
# Audit (LGPD art. 37). Insert-only table: the mufasa_api user has no
# has UPDATE or DELETE on it (sql/b3_complement.sql).
# ---------------------------------------------------------------------------

REGISTER_AUDIT = text("""
    INSERT INTO access_audit
           (moment, request_id, user_id, profile, operation, resource, target_student_id, result, origin)
    VALUES (:moment, :request_id, :user_id, :profile, :operation, :resource, :target_student_id, :result, :origin)
""")

LIST_AUDIT = text("""
    SELECT moment, request_id, user_id, profile, operation, resource, target_student_id, result
      FROM access_audit
     WHERE (CAST(:student_id AS VARCHAR) IS NULL OR target_student_id = :student_id)
     ORDER BY moment DESC, audit_id DESC
     LIMIT :limit OFFSET :commute
""")
