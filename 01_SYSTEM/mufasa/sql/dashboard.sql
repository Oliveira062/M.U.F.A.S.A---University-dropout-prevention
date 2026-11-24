BEGIN;

ALTER TABLE users
    ADD COLUMN IF NOT EXISTS name              VARCHAR(120),
    ADD COLUMN IF NOT EXISTS email             VARCHAR(160),
    ADD COLUMN IF NOT EXISTS must_change_password BOOLEAN     NOT NULL DEFAULT TRUE,
    ADD COLUMN IF NOT EXISTS changed_password_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS version_term      VARCHAR(10),
    ADD COLUMN IF NOT EXISTS accepted_term_at   TIMESTAMPTZ,

    ADD COLUMN IF NOT EXISTS demo      BOOLEAN     NOT NULL DEFAULT FALSE;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_student_users') THEN
        ALTER TABLE users ADD CONSTRAINT fk_student_users FOREIGN KEY (student_id) REFERENCES students(student_id);
        ALTER TABLE users ADD CONSTRAINT fk_professor_users FOREIGN KEY (id_professor) REFERENCES professors(id_professor);
        ALTER TABLE users ADD CONSTRAINT fk_course_users FOREIGN KEY (course_id) REFERENCES courses(course_id);
        ALTER TABLE users ADD CONSTRAINT ck_email_users CHECK (email IS NULL OR email ~ '^[^@\s]+@[^@\s]+\.[^@\s]+$');
        ALTER TABLE users ADD CONSTRAINT ck_course_users
            CHECK (profile NOT IN ('COORDINATION', 'SUPPORT_CENTER') OR course_id IS NOT NULL);
    END IF;
END $$;

CREATE TABLE IF NOT EXISTS risk_scores (
    id_score                BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    student_id                VARCHAR(255) NOT NULL REFERENCES students(student_id),
    score                   SMALLINT     CHECK (score BETWEEN 0 AND 100),
    level                   VARCHAR(14)  NOT NULL CHECK (level IN ('LOW','MODERATE','HIGH','CRITICAL','UNDETERMINED')),
    completeness              NUMERIC(4,3) NOT NULL CHECK (completeness BETWEEN 0 AND 1),
    main_factors      JSONB        NOT NULL DEFAULT '[]',
    breakdown            JSONB        NOT NULL DEFAULT '{}',
    contributions           JSONB        NOT NULL DEFAULT '{}',
    attendance_overlap BOOLEAN      NOT NULL DEFAULT FALSE,
    recommendation            VARCHAR(400) NOT NULL DEFAULT '',

    origin_level            VARCHAR(16)  NOT NULL DEFAULT 'BAND'
                                         CHECK (origin_level IN ('BAND','PARTIAL_BAND','OVERLAP','COMPLETENESS')),
    overlap_reason     VARCHAR(400),
    partial                 BOOLEAN      NOT NULL DEFAULT FALSE,
    factors                 JSONB        NOT NULL DEFAULT '[]',
    modifiers           JSONB        NOT NULL DEFAULT '[]',
    recommendations           JSONB        NOT NULL DEFAULT '[]',
    trend               VARCHAR(18)  CHECK (trend IN ('IMPROVEMENT','STABLE','DECLINE','SUSTAINED_DECLINE')),
    previous_score          SMALLINT,
    previous_level          VARCHAR(14),
    parameters_version       INTEGER      NOT NULL,
    model_version           VARCHAR(30)  NOT NULL,
    reason                  VARCHAR(40)  NOT NULL DEFAULT 'initial_load',
    calculated_at            TIMESTAMPTZ  NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS ix_moment_student_scores ON risk_scores(student_id, calculated_at DESC, id_score DESC);
CREATE INDEX IF NOT EXISTS ix_moment_scores ON risk_scores(calculated_at);

CREATE OR REPLACE VIEW vw_current_score WITH (security_barrier = true) AS
SELECT DISTINCT ON (s.student_id)
       s.id_score, s.student_id, s.score, s.level, s.completeness, s.main_factors, s.breakdown,
       s.contributions, s.attendance_overlap, s.recommendation, s.model_version, s.calculated_at,
       s.origin_level, s.overlap_reason, s.partial, s.factors, s.modifiers, s.recommendations,
       s.trend, s.previous_score, s.previous_level, s.parameters_version
  FROM risk_scores s
 ORDER BY s.student_id, s.calculated_at DESC, s.id_score DESC;

CREATE TABLE IF NOT EXISTS alerts (
    alert_id             BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    student_id              VARCHAR(255) NOT NULL REFERENCES students(student_id),
    origin_score_id       BIGINT       NOT NULL REFERENCES risk_scores(id_score),

    kind                  VARCHAR(12)  NOT NULL DEFAULT 'PEDAGOGICAL' CHECK (kind IN ('PEDAGOGICAL','DATA')),

    level                 VARCHAR(14)  NOT NULL CHECK (level IN ('LOW','MODERATE','HIGH','CRITICAL','UNDETERMINED')),
    status              VARCHAR(16)  NOT NULL DEFAULT 'OPEN'
                                       CHECK (status IN ('OPEN','IN_SERVICE','CLOSED')),
    created_at             TIMESTAMPTZ  NOT NULL DEFAULT now(),
    deadline_at              TIMESTAMPTZ  NOT NULL,
    owner_id        BIGINT       REFERENCES users(user_id),
    assigned_at          TIMESTAMPTZ,
    first_action_at      TIMESTAMPTZ,
    closed_at          TIMESTAMPTZ,

    cause                 VARCHAR(20)  CHECK (cause IN ('FINANCIAL','ACADEMIC','WORK','HEALTH','FAMILY',
                                                      'TRANSPORT','COURSE_CHOICE','INSTITUTIONAL',
                                                      'NOT_IDENTIFIED')),
    outcome              VARCHAR(20)  CHECK (outcome IN ('REMAINED','LOCKED','DROPPED_OUT','TRANSFERRED',
                                                         'IN_FOLLOWUP','FIXED_DATA')),
    there_was_contact         BOOLEAN,
    contact_channel         VARCHAR(20)  CHECK (contact_channel IN ('VIRTUAL_ENVIRONMENT','IN_PERSON','INSTITUTIONAL_EMAIL',
                                                              'RN19_EMERGENCY')),
    executed_actions      VARCHAR(1000),
    score_in_closing SMALLINT,
    updated_at         TIMESTAMPTZ  NOT NULL DEFAULT now(),

    CHECK (status <> 'CLOSED' OR (closed_at IS NOT NULL AND cause IS NOT NULL AND outcome IS NOT NULL
                                       AND there_was_contact IS NOT NULL AND executed_actions IS NOT NULL))
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_open_alerts ON alerts(student_id, kind) WHERE status <> 'CLOSED';
CREATE INDEX IF NOT EXISTS ix_deadline_status_alerts ON alerts(status, deadline_at);
CREATE INDEX IF NOT EXISTS ix_owner_alerts ON alerts(owner_id) WHERE status <> 'CLOSED';

CREATE TABLE IF NOT EXISTS alert_events (
    event_id     BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    alert_id     BIGINT        NOT NULL REFERENCES alerts(alert_id),
    moment       TIMESTAMPTZ   NOT NULL DEFAULT now(),
    user_id    BIGINT        REFERENCES users(user_id),
    kind          VARCHAR(16)   NOT NULL CHECK (kind IN ('CREATED','CHANGED_LEVEL','ASSIGNED','ACTION',
                                                         'OVERDUE_DEADLINE','DIVERGENCE','CLOSED')),
    action_type     VARCHAR(24)   CHECK (action_type IN ('CONVERSATION','ACADEMIC_GUIDANCE','SSC_REFERRAL',
                                                     'FINANCE_REFERRAL','CONTACT_WITHOUT_RETURN','OTHER')),
    description     VARCHAR(1000) NOT NULL DEFAULT '',
    visible_to_student BOOLEAN       NOT NULL DEFAULT FALSE
);
CREATE INDEX IF NOT EXISTS ix_alert_events_alert ON alert_events(alert_id, moment);

CREATE TABLE IF NOT EXISTS notifications (
    notification_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id     BIGINT       NOT NULL REFERENCES users(user_id),
    created_at      TIMESTAMPTZ  NOT NULL DEFAULT now(),
    kind           VARCHAR(20)  NOT NULL CHECK (kind IN ('NEW_ALERT','LEVEL_ALERT','ASSIGNED_ALERT',
                                                         'OVERDUE_DEADLINE','DIVERGENCE','PARAMETER','LOAD',
                                                         'DATA_TASK')),
    title         VARCHAR(120) NOT NULL,
    text          VARCHAR(300) NOT NULL,
    alert_id      BIGINT       REFERENCES alerts(alert_id),
    read_at        TIMESTAMPTZ
);
CREATE INDEX IF NOT EXISTS ix_user_notifications ON notifications(user_id, created_at DESC);

CREATE TABLE IF NOT EXISTS parameters (
    key          VARCHAR(40)    PRIMARY KEY CHECK (key ~ '^[A-Z0-9_]{3,40}$'),
    value          NUMERIC(12,4)  NOT NULL,
    minimum         NUMERIC(12,4)  NOT NULL,
    maximum         NUMERIC(12,4)  NOT NULL,
    unit        VARCHAR(30)    NOT NULL,

    editable       BOOLEAN        NOT NULL DEFAULT TRUE,
    description      VARCHAR(300)   NOT NULL,
    updated_at  TIMESTAMPTZ    NOT NULL DEFAULT now(),
    CHECK (value BETWEEN minimum AND maximum)
);

INSERT INTO parameters (key, value, minimum, maximum, unit, editable, description) VALUES
 ('WEIGHT_I1_PERFORMANCE', 0.2, 0, 1, 'fraction', FALSE, 'Weight of academic performance (I1).'),
 ('WEIGHT_I2_ATTENDANCE', 0.18, 0, 1, 'fraction', FALSE, 'Weight of attendance (I2).'),
 ('WEIGHT_I3_FAILURE', 0.09, 0, 1, 'fraction', FALSE, 'Weight of the accumulated failure rate (I3).'),
 ('WEIGHT_I4_LMS', 0.08, 0, 1, 'fraction', FALSE, 'Weight of engagement in the LMS (I4).'),
 ('WEIGHT_I5_FINANCE', 0.11, 0, 1, 'fraction', FALSE, 'Weight of the financial situation (I5).'),
 ('WEIGHT_I6_WORK', 0.07, 0, 1, 'fraction', FALSE, 'Weight of work (I6).'),
 ('WEIGHT_I7_COMMUTE', 0.05, 0, 1, 'fraction', FALSE, 'Weight of commute (I7).'),
 ('WEIGHT_I8_MENTAL_HEALTH', 0.08, 0, 1, 'fraction', FALSE, 'Weight of mental health (I8).'),
 ('WEIGHT_I9_PHYSICAL_HEALTH', 0.05, 0, 1, 'fraction', FALSE, 'Weight of physical health (I9).'),
 ('WEIGHT_I10_HOUSING', 0.05, 0, 1, 'fraction', FALSE, 'Weight of housing (I10).'),
 ('WEIGHT_I11_DEPENDENTS', 0.04, 0, 1, 'fraction', FALSE, 'Weight of dependents under care (I11).'),
 ('MINIMUM_GRADE', 6.0, 0, 10, 'grade 0 to 10', TRUE, 'Minimum passing grade. Institutional autonomy (CF art. 207; LDB art. 53).'),
 ('COMFORTABLE_GRADE', 8.0, 0, 10, 'grade 0 to 10', TRUE, 'Grade from which performance does not generate risk.'),
 ('CRITICAL_GRADE', 4.0, 0, 10, 'grade 0 to 10', TRUE, 'Grade below which the I1 curve enters the last segment.'),
 ('MINIMUM_ATTENDANCE', 75.0, 0, 100, '%', TRUE, 'Minimum attendance to pass (LDB art. 47, §3; regulatory practice of 75%).'),
 ('COMFORTABLE_ATTENDANCE', 90.0, 0, 100, '%', TRUE, 'Attendance from which there is no risk.'),
 ('CRITICAL_ATTENDANCE', 60.0, 0, 100, '%', TRUE, 'Attendance below which the I2 curve enters the last segment.'),
 ('INCOME_EXTREME', 0.25, 0, 10, 'MW per person', TRUE, 'Up to this value: extreme vulnerability (I5 = 100).'),
 ('INCOME_VULNERABLE', 0.5, 0, 10, 'MW per person', TRUE, 'CadÚnico low-income cutoff (Decree No. 6,135/2007).'),
 ('INCOME_ONE_MW', 1.0, 0, 10, 'MW per person', TRUE, 'Below one minimum wage per person.'),
 ('INCOME_AID', 1.5, 0, 10, 'MW per person', TRUE, 'PNAES priority ceiling (Decree No. 7,234/2010, art. 5).'),
 ('MINIMUM_WAGE', 1621.0, 1000, 10000, 'reais', TRUE, 'Current national minimum wage (R$ 1,621.00 in 2026). Update with each annual decree.'),
 ('WORK_HOURS_LIMIT', 20.0, 0, 80, 'hours per week', TRUE, 'Working hours above which work competes with study (Law No. 11,788/2008 as reference).'),
 ('COMMUTE_LIMIT', 60.0, 0, 300, 'minutes per trip', TRUE, 'Reference commute per trip (IBGE bands).'),
 ('LMS_DAYS_WITHOUT_ACCESS', 21.0, 1, 90, 'days', TRUE, 'Days without LMS access that take I4 to 100 (Astin, 1984).'),
 ('LOW_CUTOFF', 25.0, 0, 100, 'points', TRUE, 'Score up to this value: Low level.'),
 ('MODERATE_CUTOFF', 50.0, 0, 100, 'points', TRUE, 'Score up to this value: Moderate level.'),
 ('HIGH_CUTOFF', 75.0, 0, 100, 'points', TRUE, 'Score up to this value: High level; above it, Critical.'),
 ('MINIMUM_COMPLETENESS', 40.0, 0, 100, '% of the weights', TRUE, 'Below this the level is Undetermined (RN01).'),
 ('FULL_COMPLETENESS', 70.0, 0, 100, '% of the weights', TRUE, 'Below this the score is partial and only reaches Critical by overlap.'),
 ('SLA_CRITICAL_HOURS', 48.0, 12, 168, 'hours', TRUE, 'Deadline for the first service of a Critical alert.'),
 ('SLA_HIGH_BUSINESS_DAYS', 5.0, 1, 15, 'business days', TRUE, 'Deadline for the first service of a High alert (Saturday and Sunday do not count; holidays are not registered).'),
 ('SLA_DATA_BUSINESS_DAYS', 10.0, 1, 30, 'business days', TRUE, 'Deadline for the data correction task of an Undetermined student.'),
 ('GROUP_MINIMUM', 5.0, 3, 50, 'students', TRUE, 'Smaller groups are suppressed in aggregates (RN07, CA19).'),
 ('SERVICE_INTERVAL', 15.0, 1, 60, 'days', TRUE, 'Minimum interval between services (RN14).'),
 ('OWNER_ALERT_CEILING', 30.0, 1, 500, 'alerts', TRUE, 'Limit of open alerts per owner (value to be confirmed in Sprint 1).')
ON CONFLICT (key) DO NOTHING;

CREATE TABLE IF NOT EXISTS parameter_versions (
    version        INTEGER      PRIMARY KEY,
    created_at     TIMESTAMPTZ  NOT NULL DEFAULT now(),
    author         BIGINT       REFERENCES users(user_id),
    approver     BIGINT       REFERENCES users(user_id),
    justification VARCHAR(500) NOT NULL,
    values       JSONB        NOT NULL
);
INSERT INTO parameter_versions (version, justification, values)
SELECT 1, 'SRS v1.1 default values (Annex B, table C.2).', jsonb_object_agg(key, value) FROM parameters
ON CONFLICT (version) DO NOTHING;

CREATE TABLE IF NOT EXISTS academic_periods (
    academic_period VARCHAR(10) PRIMARY KEY CHECK (academic_period ~ '^\d{4}/[12]$'),
    start         DATE        NOT NULL,
    end_date            DATE,
    CHECK (end_date IS NULL OR end_date > start)
);
INSERT INTO academic_periods (academic_period, start)
SELECT DISTINCT academic_period, DATE '2026-08-17' FROM classes WHERE academic_period = '2026/2'
ON CONFLICT (academic_period) DO NOTHING;

CREATE TABLE IF NOT EXISTS parameter_proposals (
    proposal_id    BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    key          VARCHAR(40)   NOT NULL REFERENCES parameters(key),
    previous_value NUMERIC(12,4) NOT NULL,
    new_value     NUMERIC(12,4) NOT NULL,
    justification  VARCHAR(500)  NOT NULL,
    proposed_by   BIGINT        NOT NULL REFERENCES users(user_id),
    proposed_at    TIMESTAMPTZ   NOT NULL DEFAULT now(),
    status       VARCHAR(10)   NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING','APPROVED','REJECTED')),
    decided_by   BIGINT        REFERENCES users(user_id),
    decided_at    TIMESTAMPTZ,
    generated_version  INTEGER       REFERENCES parameter_versions(version),

    CHECK (decided_by IS NULL OR decided_by <> proposed_by)
);
CREATE UNIQUE INDEX IF NOT EXISTS ux_pending_proposal ON parameter_proposals(key) WHERE status = 'PENDING';

CREATE TABLE IF NOT EXISTS loads (
    load_id       BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    kind           VARCHAR(20)  NOT NULL CHECK (kind IN ('INDICATORS','GRADES')),
    file_name   VARCHAR(120) NOT NULL,
    bytes_size  INTEGER      NOT NULL CHECK (bytes_size BETWEEN 1 AND 20971520),

    hash_sha256    CHAR(64)     NOT NULL CHECK (hash_sha256 ~ '^[0-9a-f]{64}$'),
    sent_by    BIGINT       NOT NULL REFERENCES users(user_id),
    sent_at     TIMESTAMPTZ  NOT NULL DEFAULT now(),
    status       VARCHAR(12)  NOT NULL CHECK (status IN ('VALIDATED','WITH_ERRORS','CONFIRMED','APPLIED',
                                                           'FAILED','CANCELED')),
    total_rows   INTEGER      NOT NULL DEFAULT 0,
    valid_rows INTEGER      NOT NULL DEFAULT 0,
    confirmed_by BIGINT       REFERENCES users(user_id),
    confirmed_at  TIMESTAMPTZ,
    applied_at    TIMESTAMPTZ,
    result      VARCHAR(300)
);

CREATE TABLE IF NOT EXISTS load_rows (
    load_id BIGINT  NOT NULL REFERENCES loads(load_id),
    number   INTEGER NOT NULL,
    data    JSONB,
    error     VARCHAR(300),
    PRIMARY KEY (load_id, number)
);

CREATE TABLE IF NOT EXISTS technical_logs (
    id_log        BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    moment       TIMESTAMPTZ  NOT NULL DEFAULT now(),
    service       VARCHAR(20)  NOT NULL CHECK (service IN ('api','chat','calculation','dashboard')),
    level         VARCHAR(6)   NOT NULL CHECK (level IN ('INFO','NOTICE','ERROR')),
    event        VARCHAR(60)  NOT NULL,
    message      VARCHAR(500) NOT NULL DEFAULT '',
    request_id VARCHAR(32)
);
CREATE INDEX IF NOT EXISTS ix_moment_logs ON technical_logs(moment DESC);

CREATE TABLE IF NOT EXISTS service_status (
    service      VARCHAR(20)  PRIMARY KEY,
    last_signal TIMESTAMPTZ  NOT NULL,
    detail      VARCHAR(200) NOT NULL DEFAULT ''
);

CREATE TABLE IF NOT EXISTS recalculation_queue (
    student_id       VARCHAR(255) PRIMARY KEY REFERENCES students(student_id),
    reason         VARCHAR(40)  NOT NULL,
    queued_at TIMESTAMPTZ  NOT NULL DEFAULT now()
);

CREATE OR REPLACE FUNCTION enqueue_recalculation() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp AS $$
DECLARE
    student VARCHAR;
BEGIN
    student := CASE WHEN TG_OP = 'DELETE' THEN OLD.student_id ELSE NEW.student_id END;
    INSERT INTO recalculation_queue (student_id, reason) VALUES (student, TG_TABLE_NAME)
    ON CONFLICT (student_id) DO UPDATE SET reason = EXCLUDED.reason, queued_at = now();
    PERFORM pg_notify('mufasa_recalculation', '');
    RETURN NULL;
END $$;

DROP TRIGGER IF EXISTS tg_indicators_recalculation ON academic_indicators;
CREATE TRIGGER tg_indicators_recalculation
    AFTER INSERT OR UPDATE OR DELETE ON academic_indicators
    FOR EACH ROW EXECUTE FUNCTION enqueue_recalculation();

DROP TRIGGER IF EXISTS tg_socioeconomic_recalculation ON socioeconomic;
CREATE TRIGGER tg_socioeconomic_recalculation
    AFTER INSERT OR UPDATE OR DELETE ON socioeconomic
    FOR EACH ROW EXECUTE FUNCTION enqueue_recalculation();

CREATE OR REPLACE FUNCTION all_recalculate_by_parameter() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp AS $$
BEGIN
    IF NEW.value IS DISTINCT FROM OLD.value
       AND NEW.key NOT IN ('SLA_CRITICAL_HOURS','SLA_HIGH_BUSINESS_DAYS','SLA_DATA_BUSINESS_DAYS','GROUP_MINIMUM',
                             'SERVICE_INTERVAL','OWNER_ALERT_CEILING') THEN
        INSERT INTO recalculation_queue (student_id, reason)
        SELECT student_id, 'parameter' FROM students
        ON CONFLICT (student_id) DO UPDATE SET reason = 'parameter', queued_at = now();
        PERFORM pg_notify('mufasa_recalculation', '');
    END IF;
    RETURN NULL;
END $$;

DROP TRIGGER IF EXISTS tg_parameter_recalculation ON parameters;
CREATE TRIGGER tg_parameter_recalculation
    AFTER UPDATE ON parameters
    FOR EACH ROW EXECUTE FUNCTION all_recalculate_by_parameter();

CREATE OR REPLACE FUNCTION history_change_block() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
    RAISE EXCEPTION '% is insert-only', TG_TABLE_NAME;
END $$;

DROP TRIGGER IF EXISTS tg_immutable_events_alert ON alert_events;
CREATE TRIGGER tg_immutable_events_alert BEFORE UPDATE OR DELETE ON alert_events
    FOR EACH ROW EXECUTE FUNCTION history_change_block();
DROP TRIGGER IF EXISTS tg_immutable_scores ON risk_scores;
CREATE TRIGGER tg_immutable_scores BEFORE UPDATE OR DELETE ON risk_scores
    FOR EACH ROW EXECUTE FUNCTION history_change_block();

CREATE TABLE IF NOT EXISTS appointments (
    appointment_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    student_id       VARCHAR(255) NOT NULL REFERENCES students(student_id),
    start         TIMESTAMPTZ  NOT NULL,
    requested_by BIGINT       NOT NULL REFERENCES users(user_id),
    requested_at  TIMESTAMPTZ  NOT NULL DEFAULT now(),
    status       VARCHAR(12)  NOT NULL DEFAULT 'SCHEDULED' CHECK (status IN ('SCHEDULED','HELD','CANCELED')),

    exception_reason VARCHAR(300),
    alert_id      BIGINT       REFERENCES alerts(alert_id),
    updated_at  TIMESTAMPTZ  NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS ix_student_appointments ON appointments(student_id, start) WHERE status <> 'CANCELED';

CREATE TABLE IF NOT EXISTS appointment_refusals (
    refusal_id      BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    student_id       VARCHAR(255) NOT NULL REFERENCES students(student_id),
    request_for    TIMESTAMPTZ  NOT NULL,
    next_date   TIMESTAMPTZ  NOT NULL,
    requested_by BIGINT       NOT NULL REFERENCES users(user_id),
    moment        TIMESTAMPTZ  NOT NULL DEFAULT now()
);

DO $$
DECLARE
    table_name TEXT;
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'mufasa_calculation') THEN
        CREATE ROLE mufasa_calculation LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT;
    END IF;
    FOREACH table_name IN ARRAY ARRAY['risk_scores', 'alerts', 'alert_events', 'notifications', 'parameters',
                                  'parameter_proposals', 'parameter_versions', 'academic_periods', 'loads', 'load_rows', 'technical_logs',
                                  'service_status', 'recalculation_queue', 'appointments', 'appointment_refusals']
    LOOP
        EXECUTE format('ALTER TABLE %I OWNER TO mufasa_owner', table_name);
    END LOOP;
END $$;
ALTER FUNCTION enqueue_recalculation() OWNER TO mufasa_owner;
ALTER FUNCTION all_recalculate_by_parameter() OWNER TO mufasa_owner;
ALTER VIEW vw_current_score OWNER TO mufasa_owner;

GRANT USAGE ON SCHEMA public TO mufasa_calculation;

GRANT SELECT ON risk_scores, vw_current_score, alerts, alert_events, parameters, parameter_proposals,
               parameter_versions, academic_periods,
               loads, load_rows, technical_logs, service_status, student_support TO mufasa_api;
GRANT SELECT ON risk_rules TO mufasa_api;

GRANT INSERT (login, password_hash, profile, student_id, id_professor, course_id, name, email, must_change_password)
      ON users TO mufasa_api;
GRANT UPDATE (password_hash, must_change_password, changed_password_at, version_term, accepted_term_at, active, name, email)
      ON users TO mufasa_api;

GRANT UPDATE (status, owner_id, assigned_at, first_action_at, closed_at, cause, outcome,
              there_was_contact, contact_channel, executed_actions, score_in_closing, updated_at)
      ON alerts TO mufasa_api;
GRANT INSERT ON alert_events TO mufasa_api;
GRANT SELECT, INSERT ON notifications TO mufasa_api;
GRANT UPDATE (read_at) ON notifications TO mufasa_api;
GRANT UPDATE (value, updated_at) ON parameters TO mufasa_api;
GRANT INSERT ON parameter_versions TO mufasa_api;
GRANT INSERT ON parameter_proposals TO mufasa_api;
GRANT UPDATE (status, decided_by, decided_at, generated_version) ON parameter_proposals TO mufasa_api;
GRANT INSERT ON loads, load_rows TO mufasa_api;
GRANT UPDATE (status, confirmed_by, confirmed_at) ON loads TO mufasa_api;
GRANT INSERT ON technical_logs TO mufasa_api;
GRANT SELECT, INSERT ON appointments, appointment_refusals TO mufasa_api;
GRANT UPDATE (status, updated_at) ON appointments TO mufasa_api;

GRANT SELECT, INSERT, UPDATE (reason, queued_at) ON recalculation_queue TO mufasa_api;
GRANT SELECT, INSERT, UPDATE ON service_status TO mufasa_api;
GRANT UPDATE (status, answered_at) ON data_subject_requests TO mufasa_api;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO mufasa_api;

GRANT SELECT (student_id, course_id) ON students TO mufasa_calculation;
GRANT SELECT ON academic_indicators TO mufasa_calculation;
GRANT SELECT (student_id, per_capita_income, works, daily_work_hours, commute_time_min, scholarship_aid)
      ON socioeconomic TO mufasa_calculation;
GRANT SELECT, DELETE ON recalculation_queue TO mufasa_calculation;
GRANT INSERT (student_id, reason) ON recalculation_queue TO mufasa_calculation;
GRANT UPDATE (reason, queued_at) ON recalculation_queue TO mufasa_calculation;
GRANT SELECT, INSERT ON risk_scores TO mufasa_calculation;
GRANT SELECT ON vw_current_score, parameters, parameter_versions, academic_periods TO mufasa_calculation;

GRANT SELECT (student_id, class_id, final_grade, attendance_pct, status) ON enrollments TO mufasa_calculation;
GRANT SELECT (class_id, course_subject_id, academic_period, shift) ON classes TO mufasa_calculation;
GRANT SELECT (course_subject_id, name, workload_h) ON course_subjects TO mufasa_calculation;
GRANT SELECT (student_id, current_semester) ON students TO mufasa_calculation;

GRANT SELECT (age) ON students TO mufasa_calculation;
GRANT SELECT, INSERT ON alerts TO mufasa_calculation;
GRANT UPDATE (level, deadline_at, updated_at, status, closed_at, cause, outcome, there_was_contact,
              executed_actions) ON alerts TO mufasa_calculation;
GRANT SELECT, INSERT ON alert_events TO mufasa_calculation;
GRANT INSERT ON notifications TO mufasa_calculation;
GRANT SELECT (user_id, profile, course_id, active) ON users TO mufasa_calculation;

GRANT SELECT ON loads, load_rows TO mufasa_calculation;
GRANT UPDATE (status, applied_at, result) ON loads TO mufasa_calculation;
GRANT INSERT, UPDATE ON academic_indicators TO mufasa_calculation;
GRANT SELECT (enrollment_id) ON enrollments TO mufasa_calculation;
GRANT UPDATE (exam1, exam2, exam3, final_grade, attendance_pct, status) ON enrollments TO mufasa_calculation;
GRANT SELECT, INSERT, UPDATE ON service_status TO mufasa_calculation;
GRANT INSERT ON technical_logs TO mufasa_calculation;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO mufasa_calculation;
ALTER ROLE mufasa_calculation SET statement_timeout = '30s';
ALTER ROLE mufasa_api SET statement_timeout = '10s';

COMMIT;
