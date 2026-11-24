BEGIN;

CREATE TABLE IF NOT EXISTS users (
    user_id     BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    login          VARCHAR(64)  NOT NULL UNIQUE CHECK (login ~ '^[A-Za-z0-9._@-]{3,64}$'),
    password_hash     VARCHAR(100) NOT NULL CHECK (password_hash LIKE '$2b$%'),
    profile         VARCHAR(20)  NOT NULL CHECK (profile IN ('STUDENT','TEACHER','COORDINATION','SUPPORT_CENTER',
                                                           'FINANCE','BOARD','ADMIN','DPO')),
    student_id       VARCHAR(10),
    id_professor   VARCHAR(10),
    course_id       VARCHAR(10),
    active          BOOLEAN      NOT NULL DEFAULT TRUE,
    login_failures   SMALLINT     NOT NULL DEFAULT 0,
    blocked_until  TIMESTAMPTZ,
    last_login   TIMESTAMPTZ,
    created_at      TIMESTAMPTZ  NOT NULL DEFAULT now(),

    CHECK (profile <> 'STUDENT'   OR student_id IS NOT NULL),
    CHECK (profile <> 'TEACHER' OR id_professor IS NOT NULL)
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_student_users ON users(student_id) WHERE student_id IS NOT NULL;

CREATE TABLE IF NOT EXISTS revoked_tokens (
    jti        VARCHAR(64) PRIMARY KEY,
    expires_at  TIMESTAMPTZ NOT NULL
);

CREATE TABLE IF NOT EXISTS access_audit (
    audit_id   BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    moment        TIMESTAMPTZ  NOT NULL DEFAULT now(),
    request_id  VARCHAR(32),
    user_id     BIGINT,
    profile         VARCHAR(20),
    operation       VARCHAR(40)  NOT NULL,
    resource        VARCHAR(200) NOT NULL,
    target_student_id  VARCHAR(10),
    result      VARCHAR(12)  NOT NULL CHECK (result IN ('ALLOWED','DENIED','BLOCKED')),
    origin         VARCHAR(45)
);
CREATE INDEX IF NOT EXISTS ix_student_audit   ON access_audit(target_student_id, moment);
CREATE INDEX IF NOT EXISTS ix_moment_audit ON access_audit(moment);

CREATE TABLE IF NOT EXISTS consents (
    consent_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    student_id         VARCHAR(10)  NOT NULL,
    purpose       VARCHAR(30)  NOT NULL CHECK (purpose IN ('HEALTH_DATA')),
    granted        BOOLEAN      NOT NULL,
    granted_by    VARCHAR(12)  NOT NULL CHECK (granted_by IN ('DATA_SUBJECT','GUARDIAN')),
    term_version     VARCHAR(10)  NOT NULL,
    registered_at    TIMESTAMPTZ  NOT NULL DEFAULT now(),
    user_id       BIGINT       NOT NULL
);
CREATE INDEX IF NOT EXISTS ix_student_consents ON consents(student_id, purpose, registered_at);

CREATE TABLE IF NOT EXISTS data_subject_requests (
    subject_request_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    student_id       VARCHAR(10)   NOT NULL,
    kind           VARCHAR(40)   NOT NULL,
    description      VARCHAR(1000) NOT NULL DEFAULT '',
    status       VARCHAR(12)   NOT NULL DEFAULT 'OPENED' CHECK (status IN ('OPENED','IN_ANALYSIS','HANDLED','DENIED')),
    registered_at  TIMESTAMPTZ   NOT NULL DEFAULT now(),
    answered_at  TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS ix_b3_data_student_assessments ON risk_assessments(student_id, assessment_date DESC);
CREATE INDEX IF NOT EXISTS ix_b3_student_enrollments      ON enrollments(student_id);
CREATE INDEX IF NOT EXISTS ix_b3_professor_classes      ON classes(id_professor);
CREATE INDEX IF NOT EXISTS ix_b3_student_indicators     ON academic_indicators(student_id, academic_period DESC);
CREATE INDEX IF NOT EXISTS ix_b3_course_students          ON students(course_id);

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'mufasa_api') THEN
        CREATE ROLE mufasa_api LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'mufasa_chat') THEN
        CREATE ROLE mufasa_chat LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT;
    END IF;
END $$;

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC;
GRANT USAGE ON SCHEMA public TO mufasa_api, mufasa_chat;

GRANT SELECT ON students, courses, course_subjects, classes, enrollments, academic_indicators,
               socioeconomic, risk_assessments, professors TO mufasa_api;

GRANT SELECT ON users TO mufasa_api;
GRANT UPDATE (login_failures, blocked_until, last_login) ON users TO mufasa_api;
GRANT SELECT, INSERT ON revoked_tokens TO mufasa_api;
GRANT SELECT, INSERT ON access_audit TO mufasa_api;
GRANT SELECT, INSERT ON consents TO mufasa_api;
GRANT SELECT, INSERT ON data_subject_requests TO mufasa_api;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO mufasa_api;

GRANT SELECT ON courses, course_subjects, classes TO mufasa_chat;

CREATE OR REPLACE FUNCTION audit_change_block() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
    RAISE EXCEPTION 'access_audit is insert-only';
END $$;

DROP TRIGGER IF EXISTS tg_immutable_audit ON access_audit;
CREATE TRIGGER tg_immutable_audit
    BEFORE UPDATE OR DELETE ON access_audit
    FOR EACH ROW EXECUTE FUNCTION audit_change_block();

COMMIT;
