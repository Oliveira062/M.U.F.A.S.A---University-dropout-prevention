from sqlalchemy import text


ENQUEUE_WITHOUT_SCORE = text("""
    INSERT INTO recalculation_queue (student_id, reason)
    SELECT a.student_id, 'initial_load' FROM students a
     WHERE NOT EXISTS (SELECT 1 FROM risk_scores s WHERE s.student_id = a.student_id)
    ON CONFLICT (student_id) DO NOTHING
""")

ENQUEUE_OLD_VERSION = text("""
    INSERT INTO recalculation_queue (student_id, reason)
    SELECT s.student_id, 'parameter' FROM vw_current_score s WHERE s.parameters_version <> :version
    ON CONFLICT (student_id) DO NOTHING
""")

READ_QUEUE = text("""
    SELECT student_id, reason, queued_at
      FROM recalculation_queue
     ORDER BY queued_at
     LIMIT :batch
       FOR UPDATE SKIP LOCKED
""")

REMOVE_FROM_QUEUE = text("""
    DELETE FROM recalculation_queue WHERE student_id = :student_id AND queued_at <= :read_at
""")


CURRENT_PARAMETERS = text("SELECT key, value FROM parameters")
CURRENT_VERSION = text("SELECT max(version) FROM parameter_versions")


STUDENT = text("""
    SELECT student_id, course_id, current_semester, age FROM students WHERE student_id = :student_id
""")

PERIOD_SUBJECTS = text("""
    SELECT mt.name, mt.workload_h, m.final_grade, m.attendance_pct, m.status, t.shift, t.academic_period,
           p.start, p.end_date
      FROM enrollments m
      JOIN classes t   ON t.class_id = m.class_id
      JOIN course_subjects mt ON mt.course_subject_id = t.course_subject_id
      LEFT JOIN academic_periods p ON p.academic_period = t.academic_period
     WHERE m.student_id = :student_id
     ORDER BY t.academic_period DESC, mt.name
""")

INDICATORS = text("""
    SELECT academic_period, previous_semester_average
      FROM academic_indicators
     WHERE student_id = :student_id
     ORDER BY academic_period DESC
     LIMIT 1
""")

SOCIOECONOMIC = text("""
    SELECT per_capita_income, works, daily_work_hours, commute_time_min, scholarship_aid
      FROM socioeconomic
     WHERE student_id = :student_id
""")


RECENT_SCORES = text("""
    SELECT id_score, score, level, origin_level, parameters_version, factors, modifiers, overlap_reason
      FROM risk_scores
     WHERE student_id = :student_id
     ORDER BY calculated_at DESC, id_score DESC
     LIMIT 2
""")

SAVE_SCORE = text("""
    INSERT INTO risk_scores
           (student_id, score, level, completeness, main_factors, breakdown, contributions,
            attendance_overlap, recommendation, origin_level, overlap_reason, partial, factors,
            modifiers, recommendations, trend, previous_score, previous_level, parameters_version,
            model_version, reason, calculated_at)
    VALUES (:student_id, :score, :level, :completeness, CAST(:main_factors AS JSONB), CAST(:breakdown AS JSONB),
            CAST(:contributions AS JSONB), :attendance_overlap, :recommendation, :origin_level,
            :overlap_reason, :partial, CAST(:factors AS JSONB), CAST(:modifiers AS JSONB),
            CAST(:recommendations AS JSONB), :trend, :previous_score, :previous_level, :parameters_version,
            :model_version, :reason, :calculated_at)
    RETURNING id_score
""")


OPEN_ALERT = text("""
    SELECT alert_id, level, deadline_at, status, owner_id
      FROM alerts
     WHERE student_id = :student_id AND kind = :kind AND status <> 'CLOSED'
""")

CREATE_ALERT = text("""
    INSERT INTO alerts (student_id, origin_score_id, kind, level, status, created_at, deadline_at, owner_id,
                         assigned_at, updated_at)
    VALUES (:student_id, :id_score, :kind, :level, 'OPEN', :now, :deadline_at, :owner_id,
            CASE WHEN CAST(:owner_id AS BIGINT) IS NULL THEN NULL ELSE CAST(:now AS TIMESTAMPTZ) END, :now)
    RETURNING alert_id
""")

UPDATE_ALERT_LEVEL = text("""
    UPDATE alerts SET level = :level, deadline_at = :deadline_at, updated_at = :now WHERE alert_id = :alert_id
""")

CLOSE_DATA_TASK = text("""
    UPDATE alerts
       SET status = 'CLOSED', closed_at = :now, cause = 'NOT_IDENTIFIED', outcome = 'FIXED_DATA',
           there_was_contact = FALSE, executed_actions = 'Data completed; the score was calculated.', updated_at = :now
     WHERE alert_id = :alert_id
""")

REGISTER_EVENT = text("""
    INSERT INTO alert_events (alert_id, moment, user_id, kind, description)
    VALUES (:alert_id, :now, NULL, :kind, :description)
""")

AVAILABLE_SSC = text("""
    SELECT u.user_id
      FROM users u
      LEFT JOIN alerts a ON a.owner_id = u.user_id AND a.status <> 'CLOSED'
     WHERE u.profile = 'SUPPORT_CENTER' AND u.active AND u.course_id = :course_id
     GROUP BY u.user_id
    HAVING COUNT(a.alert_id) < :ceiling
     ORDER BY COUNT(a.alert_id), u.user_id
     LIMIT 1
""")

COURSE_TEAM = text("""
    SELECT user_id, profile FROM users
     WHERE active AND profile IN ('COORDINATION', 'SUPPORT_CENTER') AND course_id = :course_id
""")

ADMINISTRATION = text("SELECT user_id FROM users WHERE active AND profile = 'ADMIN'")

CREATE_NOTIFICATION = text("""
    INSERT INTO notifications (user_id, created_at, kind, title, text, alert_id)
    VALUES (:user_id, :now, :kind, :title, :text, :alert_id)
""")

OVERDUE_ALERTS_WITHOUT_NOTICE = text("""
    SELECT a.alert_id, a.student_id, a.level, a.owner_id, al.course_id
      FROM alerts a
      JOIN students al ON al.student_id = a.student_id
     WHERE a.status = 'OPEN' AND a.kind = 'PEDAGOGICAL' AND a.deadline_at < :now
       AND NOT EXISTS (SELECT 1 FROM alert_events e WHERE e.alert_id = a.alert_id AND e.kind = 'OVERDUE_DEADLINE')
     LIMIT 500
""")


CONFIRMED_LOAD = text("""
    SELECT load_id, kind, sent_by FROM loads WHERE status = 'CONFIRMED'
     ORDER BY confirmed_at LIMIT 1 FOR UPDATE SKIP LOCKED
""")

LOAD_ROWS = text("""
    SELECT number, data FROM load_rows WHERE load_id = :load_id AND error IS NULL ORDER BY number
""")

APPLY_GRADES = text("""
    UPDATE enrollments
       SET exam1 = :exam1, exam2 = :exam2, exam3 = :exam3, final_grade = :final_grade, attendance_pct = :attendance_pct,
           status = :status
     WHERE enrollment_id = :enrollment_id
""")

APPLY_INDICATORS = text("""
    INSERT INTO academic_indicators (student_id, academic_period, total_absences, pending_activities,
                                        failed_subjects_history, previous_semester_average)
    VALUES (:student_id, :academic_period, :total_absences, :pending_activities,
            :failed_subjects_history, :previous_semester_average)
    ON CONFLICT (student_id, academic_period) DO UPDATE
       SET total_absences = EXCLUDED.total_absences, pending_activities = EXCLUDED.pending_activities,
           failed_subjects_history = EXCLUDED.failed_subjects_history,
           previous_semester_average = EXCLUDED.previous_semester_average
""")

FINISH_LOAD = text("""
    UPDATE loads SET status = :status, applied_at = :now, result = :result WHERE load_id = :load_id
""")


LIFE_SIGNAL = text("""
    INSERT INTO service_status (service, last_signal, detail) VALUES ('calculation', :now, :detail)
    ON CONFLICT (service) DO UPDATE SET last_signal = EXCLUDED.last_signal, detail = EXCLUDED.detail
""")

REGISTER_LOG = text("""
    INSERT INTO technical_logs (moment, service, level, event, message) VALUES (:now, 'calculation', :level, :event, :message)
""")
