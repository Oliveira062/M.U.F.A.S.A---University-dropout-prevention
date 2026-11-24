from sqlalchemy import text


ACCOUNT = text("""
    SELECT u.user_id, u.login, u.name, u.email, u.profile, u.student_id, u.id_professor, u.course_id,
           c.name AS course, u.must_change_password, u.version_term, u.accepted_term_at, u.last_login,
           (SELECT count(*) FROM notifications n WHERE n.user_id = u.user_id AND n.read_at IS NULL)
               AS not_read_notifications
      FROM users u
      LEFT JOIN courses c ON c.course_id = u.course_id
     WHERE u.user_id = :user_id
""")

USER_PASSWORD = text("SELECT login, password_hash FROM users WHERE user_id = :user_id")

CHANGE_PASSWORD = text("""
    UPDATE users
       SET password_hash = :password_hash, must_change_password = FALSE, changed_password_at = :now
     WHERE user_id = :user_id
""")

ACCEPT_TERM = text("""
    UPDATE users SET version_term = :version, accepted_term_at = :now WHERE user_id = :user_id
""")

NOTIFICATIONS = text("""
    SELECT notification_id, created_at, kind, title, text, alert_id, read_at
      FROM notifications
     WHERE user_id = :user_id
       AND (NOT CAST(:only_unread AS BOOLEAN) OR read_at IS NULL)
     ORDER BY created_at DESC, notification_id DESC
     LIMIT :limit OFFSET :commute
""")

MARK_READ = text("""
    UPDATE notifications SET read_at = :now
     WHERE notification_id = :notification_id AND user_id = :user_id AND read_at IS NULL
""")

MARK_ALL_READ = text("""
    UPDATE notifications SET read_at = :now WHERE user_id = :user_id AND read_at IS NULL
""")

CREATE_NOTIFICATION = text("""
    INSERT INTO notifications (user_id, created_at, kind, title, text, alert_id)
    VALUES (:user_id, :now, :kind, :title, :text, :alert_id)
""")

PROFILE_ACTIVE_USERS = text("""
    SELECT user_id FROM users
     WHERE profile = :profile AND active
       AND (CAST(:course_id AS VARCHAR) IS NULL OR course_id = :course_id)
""")


_BASE_QUEUE = """
    SELECT a.alert_id, a.student_id, al.fictitious_name, al.current_semester, al.course_id, a.kind, a.level,
           a.status, a.created_at, a.deadline_at, a.owner_id, u.name AS owner, a.first_action_at,
           a.closed_at, a.cause, a.outcome, s.score, s.trend, s.main_factors,
           ult.moment AS last_action_at, (a.status <> 'CLOSED' AND a.deadline_at < :now) AS overdue
      FROM alerts a
      JOIN students al ON al.student_id = a.student_id
      LEFT JOIN vw_current_score s ON s.student_id = a.student_id
      LEFT JOIN users u ON u.user_id = a.owner_id
      LEFT JOIN LATERAL (SELECT max(e.moment) AS moment FROM alert_events e
                          WHERE e.alert_id = a.alert_id AND e.kind = 'ACTION') ult ON TRUE
     WHERE ((CAST(:status AS VARCHAR) IS NULL AND a.status <> 'CLOSED') OR a.status = :status)
       AND (CAST(:kind AS VARCHAR) IS NULL OR a.kind = :kind)
       AND (CAST(:level AS VARCHAR) IS NULL OR a.level = :level)
       AND (CAST(:owner AS BIGINT) IS NULL OR a.owner_id = :owner)
       AND (NOT CAST(:without_owner AS BOOLEAN) OR a.owner_id IS NULL)
       AND (NOT CAST(:only_overdue AS BOOLEAN) OR (a.status <> 'CLOSED' AND a.deadline_at < :now))
"""

_ALERT_SCOPE = {
    "COORDINATION": "AND al.course_id = :course_id",
    "SUPPORT_CENTER": "AND a.owner_id = :user_id",
    "TEACHER": """AND a.kind = 'PEDAGOGICAL'
       AND EXISTS (SELECT 1 FROM enrollments m JOIN classes t ON t.class_id = m.class_id
                    WHERE m.student_id = a.student_id AND t.id_professor = :id_professor)""",
    "FINANCE": """AND a.kind = 'PEDAGOGICAL' AND s.main_factors @> '["finance"]'::jsonb""",
}

_QUEUE_ORDER = """
     ORDER BY CASE a.level WHEN 'CRITICAL' THEN 0 WHEN 'HIGH' THEN 1 WHEN 'UNDETERMINED' THEN 3 ELSE 2 END,
              a.deadline_at,
              s.score DESC NULLS LAST,
              CASE s.trend WHEN 'SUSTAINED_DECLINE' THEN 0 WHEN 'DECLINE' THEN 1 WHEN 'STABLE' THEN 2 ELSE 3 END,
              COALESCE(ult.moment, a.created_at),
              a.alert_id
"""


def queue_query(profile: str):
    return text(_BASE_QUEUE + _ALERT_SCOPE[profile] + _QUEUE_ORDER + " LIMIT :limit OFFSET :commute")


def queue_total_query(profile: str):
    return text("SELECT count(*) FROM (" + _BASE_QUEUE + _ALERT_SCOPE[profile] + ") q")


def alert_query_in_scope(profile: str):
    return text("""
    SELECT a.alert_id, a.student_id, al.fictitious_name, al.course_id, al.age, a.kind, a.level, a.status,
           a.created_at, a.deadline_at, a.owner_id, u.name AS owner, a.assigned_at, a.first_action_at,
           a.closed_at, a.cause, a.outcome, a.there_was_contact, a.contact_channel, a.executed_actions,
           a.score_in_closing, a.origin_score_id
      FROM alerts a
      JOIN students al ON al.student_id = a.student_id
      LEFT JOIN vw_current_score s ON s.student_id = a.student_id
      LEFT JOIN users u ON u.user_id = a.owner_id
     WHERE a.alert_id = :alert_id
    """ + _ALERT_SCOPE[profile] + " FOR UPDATE OF a")


ALERT_EVENTS = text("""
    SELECT e.event_id, e.moment, e.kind, e.action_type, e.description, e.visible_to_student, e.user_id,
           u.name AS author, u.profile AS author_profile
      FROM alert_events e
      LEFT JOIN users u ON u.user_id = e.user_id
     WHERE e.alert_id = :alert_id
     ORDER BY e.moment, e.event_id
""")

REGISTER_EVENT = text("""
    INSERT INTO alert_events (alert_id, moment, user_id, kind, action_type, description, visible_to_student)
    VALUES (:alert_id, :now, :user_id, :kind, :action_type, :description, :visible_to_student)
""")

ASSIGN_ALERT = text("""
    UPDATE alerts SET owner_id = :owner_id, assigned_at = :now, updated_at = :now
     WHERE alert_id = :alert_id
""")

ASSUME_ALERT = text("""
    UPDATE alerts SET status = 'IN_SERVICE', updated_at = :now
     WHERE alert_id = :alert_id AND status = 'OPEN'
""")

FIRST_ACTION = text("""
    UPDATE alerts
       SET first_action_at = COALESCE(first_action_at, :now),
           status = CASE WHEN status = 'OPEN' THEN 'IN_SERVICE' ELSE status END,
           updated_at = :now
     WHERE alert_id = :alert_id
""")

CLOSE_ALERT = text("""
    UPDATE alerts
       SET status = 'CLOSED', closed_at = :now, cause = :cause, outcome = :outcome,
           there_was_contact = :there_was_contact, contact_channel = :contact_channel, executed_actions = :executed_actions,
           score_in_closing = :score, updated_at = :now
     WHERE alert_id = :alert_id AND status <> 'CLOSED'
""")

SCORE_AND_OVERLAP = text("""
    SELECT score, level, overlap_reason FROM vw_current_score WHERE student_id = :student_id
""")

OWNERS = text("""
    SELECT u.user_id, u.name, u.profile,
           (SELECT count(*) FROM alerts a WHERE a.owner_id = u.user_id AND a.status <> 'CLOSED')
               AS open_alerts
      FROM users u
     WHERE u.active AND u.profile IN ('SUPPORT_CENTER', 'COORDINATION') AND u.course_id = :course_id
     ORDER BY u.profile DESC, u.name
""")

VALID_OWNER = text("""
    SELECT u.user_id, u.profile,
           (SELECT count(*) FROM alerts a WHERE a.owner_id = u.user_id AND a.status <> 'CLOSED')
               AS open_alerts
      FROM users u
     WHERE u.user_id = :user_id AND u.active AND u.profile IN ('SUPPORT_CENTER', 'COORDINATION')
       AND u.course_id = :course_id
""")

STUDENT_ALERTS = text("""
    SELECT alert_id, kind, level, status, created_at, deadline_at, closed_at, cause, outcome
      FROM alerts
     WHERE student_id = :student_id
     ORDER BY created_at DESC, alert_id DESC
     LIMIT 50
""")

EVENTS_VISIBLE_TO_STUDENT = text("""
    SELECT e.moment, e.action_type, e.description
      FROM alert_events e
      JOIN alerts a ON a.alert_id = e.alert_id
     WHERE a.student_id = :student_id AND e.visible_to_student
     ORDER BY e.moment DESC, e.event_id DESC
     LIMIT 100
""")


_SLICE_STUDENTS = """
      FROM students al
      LEFT JOIN vw_current_score s ON s.student_id = al.student_id
     WHERE (CAST(:course_id AS VARCHAR) IS NULL OR al.course_id = :course_id)
       AND (CAST(:semester AS INTEGER) IS NULL OR al.current_semester = :semester)
       AND (CAST(:shift AS VARCHAR) IS NULL OR EXISTS (
             SELECT 1 FROM enrollments m JOIN classes t ON t.class_id = m.class_id
              WHERE m.student_id = al.student_id AND t.shift = :shift))
       AND (CAST(:factor AS VARCHAR) IS NULL OR s.main_factors ->> 0 = :factor)
       AND (CAST(:trend AS VARCHAR) IS NULL OR s.trend = :trend)
"""

DISTRIBUTION_DASHBOARD = text("""
    SELECT COALESCE(s.level, 'PENDING') AS level, count(*) AS total
""" + _SLICE_STUDENTS + """
     GROUP BY COALESCE(s.level, 'PENDING')
""")

SCORE_BANDS_DASHBOARD = text("""
    SELECT CASE WHEN s.score <= 25 THEN '0-25' WHEN s.score <= 50 THEN '26-50'
                WHEN s.score <= 75 THEN '51-75' ELSE '76-100' END AS band, count(*) AS total
""" + _SLICE_STUDENTS + """
       AND s.score IS NOT NULL
     GROUP BY 1
""")

ALERTS_DASHBOARD = text("""
    SELECT count(*) FILTER (WHERE a.status <> 'CLOSED' AND a.kind = 'PEDAGOGICAL') AS open_count,
           count(*) FILTER (WHERE a.status <> 'CLOSED' AND a.kind = 'PEDAGOGICAL' AND a.deadline_at < :now)
               AS overdue,
           count(*) FILTER (WHERE a.status <> 'CLOSED' AND a.kind = 'PEDAGOGICAL' AND a.owner_id IS NULL)
               AS without_owner,
           count(*) FILTER (WHERE a.status = 'IN_SERVICE') AS in_service,
           count(*) FILTER (WHERE a.status <> 'CLOSED' AND a.kind = 'DATA') AS data_tasks,
           count(*) FILTER (WHERE a.status = 'CLOSED') AS closed
      FROM alerts a
      JOIN students al ON al.student_id = a.student_id
     WHERE (CAST(:course_id AS VARCHAR) IS NULL OR al.course_id = :course_id)
""")

AT_RISK_IN = text("""
    SELECT count(*) FILTER (WHERE ult.level IN ('HIGH', 'CRITICAL')) AS at_risk, count(ult.level) AS with_score
      FROM students al
      LEFT JOIN LATERAL (SELECT sr.level FROM risk_scores sr
                          WHERE sr.student_id = al.student_id AND sr.calculated_at <= :moment
                          ORDER BY sr.calculated_at DESC, sr.id_score DESC LIMIT 1) ult ON TRUE
     WHERE (CAST(:course_id AS VARCHAR) IS NULL OR al.course_id = :course_id)
""")

RISK_EVOLUTION = text("""
    SELECT day::date AS day,
           count(*) FILTER (WHERE ult.level IN ('HIGH', 'CRITICAL')) AS at_risk,
           count(*) FILTER (WHERE ult.level = 'CRITICAL') AS critical,
           count(ult.level) AS with_score
      FROM generate_series(CAST(:start AS date), CAST(:end_date AS date), interval '1 day') day
     CROSS JOIN students al
      LEFT JOIN LATERAL (SELECT sr.level FROM risk_scores sr
                          WHERE sr.student_id = al.student_id AND sr.calculated_at < day + interval '1 day'
                          ORDER BY sr.calculated_at DESC, sr.id_score DESC LIMIT 1) ult ON TRUE
     WHERE (CAST(:course_id AS VARCHAR) IS NULL OR al.course_id = :course_id)
     GROUP BY day
     ORDER BY day
""")

FIRST_CALCULATION = text("SELECT min(calculated_at), max(calculated_at) FROM risk_scores")

FREQUENT_FACTORS = text("""
    SELECT f.factor, count(*) AS total
      FROM students al
      JOIN vw_current_score s ON s.student_id = al.student_id
     CROSS JOIN LATERAL jsonb_array_elements_text(s.main_factors) f(factor)
     WHERE s.level IN ('HIGH', 'CRITICAL')
       AND (CAST(:course_id AS VARCHAR) IS NULL OR al.course_id = :course_id)
       AND (CAST(:semester AS INTEGER) IS NULL OR al.current_semester = :semester)
       AND (CAST(:shift AS VARCHAR) IS NULL OR EXISTS (
             SELECT 1 FROM enrollments m JOIN classes t ON t.class_id = m.class_id
              WHERE m.student_id = al.student_id AND t.shift = :shift))
       AND (CAST(:factor AS VARCHAR) IS NULL OR s.main_factors ->> 0 = :factor)
       AND (CAST(:trend AS VARCHAR) IS NULL OR s.trend = :trend)
     GROUP BY f.factor
     ORDER BY total DESC, f.factor
""")

BY_COURSE = text("""
    SELECT c.course_id, c.name AS course, COALESCE(s.level, 'PENDING') AS level, count(*) AS total
      FROM students al
      JOIN courses c ON c.course_id = al.course_id
      LEFT JOIN vw_current_score s ON s.student_id = al.student_id
     GROUP BY c.course_id, c.name, COALESCE(s.level, 'PENDING')
     ORDER BY c.name
""")

BY_SEMESTER = text("""
    SELECT al.current_semester AS semester, COALESCE(s.level, 'PENDING') AS level, count(*) AS total
""" + _SLICE_STUDENTS + """
     GROUP BY al.current_semester, COALESCE(s.level, 'PENDING')
     ORDER BY al.current_semester
""")

EFFECTIVENESS = text("""
    SELECT a.there_was_contact, a.outcome, count(*) AS total
      FROM alerts a
      JOIN students al ON al.student_id = a.student_id
     WHERE a.status = 'CLOSED' AND a.kind = 'PEDAGOGICAL'
       AND (CAST(:course_id AS VARCHAR) IS NULL OR al.course_id = :course_id)
     GROUP BY a.there_was_contact, a.outcome
""")

CAUSES = text("""
    SELECT a.cause, count(*) AS total
      FROM alerts a
      JOIN students al ON al.student_id = a.student_id
     WHERE a.status = 'CLOSED' AND a.kind = 'PEDAGOGICAL'
       AND (CAST(:course_id AS VARCHAR) IS NULL OR al.course_id = :course_id)
     GROUP BY a.cause
     ORDER BY total DESC
""")

DIVERGENCES = text("""
    SELECT count(*) FROM alert_events e
      JOIN alerts a ON a.alert_id = e.alert_id
      JOIN students al ON al.student_id = a.student_id
     WHERE e.kind = 'DIVERGENCE' AND (CAST(:course_id AS VARCHAR) IS NULL OR al.course_id = :course_id)
""")

FIRST_ACTION_TIME = text("""
    SELECT a.level, count(*) AS total,
           count(*) FILTER (WHERE a.first_action_at <= a.deadline_at) AS in_deadline,
           avg(EXTRACT(EPOCH FROM (a.first_action_at - a.created_at)) / 3600.0) AS average_hours
      FROM alerts a
      JOIN students al ON al.student_id = a.student_id
     WHERE a.kind = 'PEDAGOGICAL' AND a.first_action_at IS NOT NULL
       AND (CAST(:course_id AS VARCHAR) IS NULL OR al.course_id = :course_id)
     GROUP BY a.level
""")

LAST_CALCULATION = text("""
    SELECT max(calculated_at) AS last, count(DISTINCT parameters_version) AS versions FROM vw_current_score
""")

CALCULATION_SIGNAL = text("SELECT last_signal, detail FROM service_status WHERE service = 'calculation'")

QUEUE_SIZE = text("SELECT count(*) FROM recalculation_queue")


TEACHER_CLASSES = text("""
    SELECT t.class_id, mt.name AS course_subject, t.academic_period, t.shift, mt.workload_h,
           count(m.student_id) AS students,
           count(*) FILTER (WHERE s.level = 'CRITICAL') AS critical,
           count(*) FILTER (WHERE s.level = 'HIGH') AS high,
           avg(m.final_grade) AS class_average, avg(m.attendance_pct) AS class_attendance
      FROM classes t
      JOIN course_subjects mt ON mt.course_subject_id = t.course_subject_id
      LEFT JOIN enrollments m ON m.class_id = t.class_id
      LEFT JOIN vw_current_score s ON s.student_id = m.student_id
     WHERE t.id_professor = :id_professor
     GROUP BY t.class_id, mt.name, t.academic_period, t.shift, mt.workload_h
     ORDER BY t.academic_period DESC, mt.name
""")

TEACHER_CLASS = text("""
    SELECT t.class_id, mt.name AS course_subject, t.academic_period, t.shift
      FROM classes t JOIN course_subjects mt ON mt.course_subject_id = t.course_subject_id
     WHERE t.class_id = :class_id AND t.id_professor = :id_professor
""")

CLASS_STUDENTS = text("""
    SELECT al.student_id, al.fictitious_name, al.current_semester, m.final_grade, m.attendance_pct, m.status,
           s.level, s.score, s.main_factors
      FROM enrollments m
      JOIN students al ON al.student_id = m.student_id
      LEFT JOIN vw_current_score s ON s.student_id = al.student_id
     WHERE m.class_id = :class_id
     ORDER BY CASE s.level WHEN 'CRITICAL' THEN 0 WHEN 'HIGH' THEN 1 WHEN 'MODERATE' THEN 2 ELSE 3 END,
              s.score DESC NULLS LAST, al.fictitious_name
""")


STUDENT_SUBJECTS = text("""
    SELECT t.class_id, mt.name AS course_subject, t.academic_period, t.shift, mt.workload_h,
           m.exam1, m.exam2, m.exam3, m.final_grade, m.attendance_pct, m.status, p.name AS professor
      FROM enrollments m
      JOIN classes t ON t.class_id = m.class_id
      JOIN course_subjects mt ON mt.course_subject_id = t.course_subject_id
      LEFT JOIN professors p ON p.id_professor = t.id_professor
     WHERE m.student_id = :student_id
     ORDER BY t.academic_period DESC, mt.name
""")


FINANCE_STUDENTS = text("""
    SELECT al.student_id, al.fictitious_name, a.alert_id, a.level, a.status, a.deadline_at, s.score,
           s.recommendations, so.per_capita_income, so.scholarship_aid
      FROM alerts a
      JOIN students al ON al.student_id = a.student_id
      JOIN vw_current_score s ON s.student_id = a.student_id
      LEFT JOIN socioeconomic so ON so.student_id = a.student_id
     WHERE a.kind = 'PEDAGOGICAL' AND a.status <> 'CLOSED'
       AND s.main_factors @> '["finance"]'::jsonb
     ORDER BY CASE a.level WHEN 'CRITICAL' THEN 0 ELSE 1 END, a.deadline_at, al.student_id
     LIMIT :limit OFFSET :commute
""")


STUDENT_APPOINTMENTS = text("""
    SELECT g.appointment_id, g.start, g.status, g.exception_reason, g.requested_at, u.name AS requested_by
      FROM appointments g
      LEFT JOIN users u ON u.user_id = g.requested_by
     WHERE g.student_id = :student_id
     ORDER BY g.start DESC
     LIMIT 50
""")

NEXT_APPOINTMENT = text("""
    SELECT start FROM appointments
     WHERE student_id = :student_id AND status <> 'CANCELED'
       AND start > :payload - make_interval(days => :interval)
       AND start < :payload + make_interval(days => :interval)
     ORDER BY start DESC
     LIMIT 1
""")

ACTIVE_LAST_APPOINTMENT = text("""
    SELECT max(start) FROM appointments WHERE student_id = :student_id AND status <> 'CANCELED'
""")

CREATE_APPOINTMENT = text("""
    INSERT INTO appointments (student_id, start, requested_by, requested_at, exception_reason, alert_id)
    VALUES (:student_id, :start, :requested_by, :now, :exception_reason, :alert_id)
    RETURNING appointment_id
""")

REGISTER_APPOINTMENT_REFUSAL = text("""
    INSERT INTO appointment_refusals (student_id, request_for, next_date, requested_by, moment)
    VALUES (:student_id, :request_for, :next_date, :requested_by, :now)
""")

APPOINTMENT_BY_ID = text("""
    SELECT appointment_id, student_id, status FROM appointments WHERE appointment_id = :appointment_id
""")

CHANGE_APPOINTMENT = text("""
    UPDATE appointments SET status = :status, updated_at = :now WHERE appointment_id = :appointment_id
""")


LIST_USERS = text("""
    SELECT user_id, login, name, profile, course_id, active, last_login, must_change_password, demo,
           (blocked_until IS NOT NULL AND blocked_until > :now) AS blocked
      FROM users
     WHERE (CAST(:profile AS VARCHAR) IS NULL OR profile = :profile)
       AND (CAST(:search AS VARCHAR) IS NULL OR lower(login) LIKE :search OR lower(COALESCE(name, '')) LIKE :search)
     ORDER BY profile, login
     LIMIT :limit OFFSET :commute
""")

COUNT_USERS = text("""
    SELECT profile, count(*) AS total, count(*) FILTER (WHERE active) AS active,
           count(*) FILTER (WHERE must_change_password) AS first_access
      FROM users GROUP BY profile ORDER BY profile
""")

CREATE_USER = text("""
    INSERT INTO users (login, password_hash, profile, student_id, id_professor, course_id, name, email, must_change_password)
    VALUES (:login, :password_hash, :profile, :student_id, :id_professor, :course_id, :name, :email, TRUE)
    RETURNING user_id
""")

LOGIN_EXISTS = text("SELECT 1 FROM users WHERE lower(login) = lower(:login)")

USER_FOR_ADMIN = text("SELECT user_id, login, profile, active FROM users WHERE user_id = :user_id")

ENABLE_USER = text("UPDATE users SET active = :active WHERE user_id = :user_id")

RESET_PASSWORD = text("""
    UPDATE users SET password_hash = :password_hash, must_change_password = TRUE WHERE user_id = :user_id
""")

UNLOCK = text("UPDATE users SET login_failures = 0, blocked_until = NULL WHERE user_id = :user_id")

STUDENT_EXISTS = text("SELECT 1 FROM students WHERE student_id = :student_id")
PROFESSOR_EXISTS = text("SELECT 1 FROM professors WHERE id_professor = :id_professor")
COURSE_EXISTS = text("SELECT 1 FROM courses WHERE course_id = :course_id")

TECHNICAL_RECORDS = text("""
    SELECT moment, service, level, event, message, request_id
      FROM technical_logs
     WHERE (CAST(:service AS VARCHAR) IS NULL OR service = :service)
       AND (CAST(:level AS VARCHAR) IS NULL OR level = :level)
     ORDER BY moment DESC, id_log DESC
     LIMIT :limit OFFSET :commute
""")

REGISTER_LOG = text("""
    INSERT INTO technical_logs (moment, service, level, event, message, request_id)
    VALUES (:now, :service, :level, :event, :message, :request_id)
""")

SERVICES = text("SELECT service, last_signal, detail FROM service_status ORDER BY service")

LIFE_SIGNAL = text("""
    INSERT INTO service_status (service, last_signal, detail) VALUES (:service, :now, :detail)
    ON CONFLICT (service) DO UPDATE SET last_signal = EXCLUDED.last_signal, detail = EXCLUDED.detail
""")

ENQUEUE_ALL = text("""
    INSERT INTO recalculation_queue (student_id, reason)
    SELECT student_id, 'manual' FROM students
     WHERE (CAST(:course_id AS VARCHAR) IS NULL OR course_id = :course_id)
       AND (CAST(:semester AS INTEGER) IS NULL OR current_semester = :semester)
    ON CONFLICT (student_id) DO UPDATE SET reason = 'manual', queued_at = now()
""")

WAKE_CALCULATION = text("SELECT pg_notify('mufasa_recalculation', '')")

LOAD_WITH_HASH = text("""
    SELECT load_id, status FROM loads
     WHERE hash_sha256 = :hash AND status IN ('VALIDATED', 'CONFIRMED', 'APPLIED')
     LIMIT 1
""")

CREATE_LOAD = text("""
    INSERT INTO loads (kind, file_name, bytes_size, hash_sha256, sent_by, sent_at, status,
                        total_rows, valid_rows)
    VALUES (:kind, :file_name, :bytes_size, :hash, :sent_by, :now, :status, :total_rows,
            :valid_rows)
    RETURNING load_id
""")

CREATE_LOAD_ROW = text("""
    INSERT INTO load_rows (load_id, number, data, error) VALUES (:load_id, :number, CAST(:data AS jsonb), :error)
""")

LIST_LOADS = text("""
    SELECT c.load_id, c.kind, c.file_name, c.bytes_size, c.hash_sha256, c.sent_at, c.status,
           c.total_rows, c.valid_rows, c.confirmed_at, c.applied_at, c.result, u.login AS sent_by
      FROM loads c
      LEFT JOIN users u ON u.user_id = c.sent_by
     ORDER BY c.sent_at DESC, c.load_id DESC
     LIMIT :limit OFFSET :commute
""")

LOAD_BY_ID = text("""
    SELECT c.load_id, c.kind, c.file_name, c.bytes_size, c.hash_sha256, c.sent_at, c.status,
           c.total_rows, c.valid_rows, c.confirmed_at, c.applied_at, c.result, c.sent_by
      FROM loads c
     WHERE c.load_id = :load_id
""")

LOAD_REJECTIONS = text("""
    SELECT number, error FROM load_rows WHERE load_id = :load_id AND error IS NOT NULL ORDER BY number
     LIMIT 5000
""")

CHANGE_LOAD = text("""
    UPDATE loads SET status = :new, confirmed_by = :user_id, confirmed_at = :now
     WHERE load_id = :load_id AND status = 'VALIDATED'
""")

CLASSES_AND_ENROLLMENTS = text("""
    SELECT m.enrollment_id, m.student_id, m.class_id FROM enrollments m
""")

STUDENT_IDS = text("SELECT student_id FROM students")


LIST_PARAMETERS = text("""
    SELECT key, value, minimum, maximum, unit, editable, description, updated_at
      FROM parameters ORDER BY key
""")

PARAMETER = text("""
    SELECT key, value, minimum, maximum, editable FROM parameters WHERE key = :key FOR UPDATE
""")

PARAMETERS_VALUES = text("SELECT key, value FROM parameters")

VERSIONS = text("""
    SELECT v.version, v.created_at, v.justification, ua.login AS author, ub.login AS approver
      FROM parameter_versions v
      LEFT JOIN users ua ON ua.user_id = v.author
      LEFT JOIN users ub ON ub.user_id = v.approver
     ORDER BY v.version DESC
     LIMIT 50
""")

LOCK_VERSIONS = text("SELECT pg_advisory_xact_lock(7302201)")
NEXT_VERSION = text("SELECT COALESCE(max(version), 0) + 1 FROM parameter_versions")

APPLY_PARAMETER = text("UPDATE parameters SET value = :value, updated_at = :now WHERE key = :key")

CREATE_VERSION = text("""
    INSERT INTO parameter_versions (version, created_at, author, approver, justification, values)
    SELECT :version, :now, :author, :approver, :justification, jsonb_object_agg(key, value) FROM parameters
""")

PROPOSALS = text("""
    SELECT p.proposal_id, p.key, p.previous_value, p.new_value, p.justification, p.proposed_at, p.status,
           p.decided_at, p.generated_version, up.login AS proposed_by, ud.login AS decided_by
      FROM parameter_proposals p
      LEFT JOIN users up ON up.user_id = p.proposed_by
      LEFT JOIN users ud ON ud.user_id = p.decided_by
     ORDER BY CASE p.status WHEN 'PENDING' THEN 0 ELSE 1 END, p.proposed_at DESC
     LIMIT 100
""")

CREATE_PROPOSAL = text("""
    INSERT INTO parameter_proposals (key, previous_value, new_value, justification, proposed_by, proposed_at)
    VALUES (:key, :previous_value, :new_value, :justification, :proposed_by, :now)
    RETURNING proposal_id
""")

PENDING_PROPOSAL = text("""
    SELECT proposal_id, key, new_value, justification, proposed_by
      FROM parameter_proposals WHERE proposal_id = :proposal_id AND status = 'PENDING' FOR UPDATE
""")

KEY_PENDING = text("SELECT 1 FROM parameter_proposals WHERE key = :key AND status = 'PENDING'")

DECIDE_PROPOSAL = text("""
    UPDATE parameter_proposals
       SET status = :status, decided_by = :decided_by, decided_at = :now, generated_version = :version
     WHERE proposal_id = :proposal_id
""")


REQUEST_BY_ID = text("SELECT subject_request_id, status FROM data_subject_requests WHERE subject_request_id = :id")

ANSWER_REQUEST = text("""
    UPDATE data_subject_requests SET status = :status, answered_at = :now WHERE subject_request_id = :id
""")

STUDENT_REQUESTS = text("""
    SELECT subject_request_id, kind, status, registered_at, answered_at
      FROM data_subject_requests WHERE student_id = :student_id ORDER BY registered_at DESC LIMIT 50
""")
