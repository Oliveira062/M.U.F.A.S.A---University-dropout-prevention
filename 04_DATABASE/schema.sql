-- MUFASA — relational schema of the dropout database (PostgreSQL)
-- Mirrors the tabs of Dropout_Database_AI_Normalized.xlsx.

CREATE TABLE universities (
    university_id    VARCHAR(10) PRIMARY KEY,
    name             VARCHAR(120) NOT NULL,
    city             VARCHAR(80)  NOT NULL,
    uf               CHAR(2)      NOT NULL
);

CREATE TABLE courses (
    course_id             VARCHAR(10) PRIMARY KEY,
    university_id         VARCHAR(10) NOT NULL REFERENCES universities(university_id),
    name                  VARCHAR(120) NOT NULL,
    degree                VARCHAR(30)  NOT NULL,
    duration_semesters    SMALLINT     NOT NULL,
    passing_average       NUMERIC(3,1) NOT NULL DEFAULT 6,
    minimum_attendance_pct SMALLINT     NOT NULL DEFAULT 75
);

CREATE TABLE professors (
    id_professor        VARCHAR(10) PRIMARY KEY,
    name                VARCHAR(120) NOT NULL,
    degree              VARCHAR(30),
    expertise_area      VARCHAR(60),
    work_regime         VARCHAR(20),
    institutional_email VARCHAR(120) UNIQUE,
    hire_date           DATE
);

CREATE TABLE course_subjects (
    course_subject_id     VARCHAR(10) PRIMARY KEY,
    course_id             VARCHAR(10) NOT NULL REFERENCES courses(course_id),
    name                  VARCHAR(120) NOT NULL,
    curriculum_semester   SMALLINT     NOT NULL CHECK (curriculum_semester BETWEEN 1 AND 12),
    workload_h            SMALLINT     NOT NULL,
    passing_average       NUMERIC(3,1) NOT NULL DEFAULT 6,
    minimum_attendance_pct SMALLINT     NOT NULL DEFAULT 75
);

CREATE TABLE classes (
    class_id       VARCHAR(16) PRIMARY KEY,
    course_subject_id VARCHAR(10) NOT NULL REFERENCES course_subjects(course_subject_id),
    id_professor   VARCHAR(10) NOT NULL REFERENCES professors(id_professor),
    academic_period VARCHAR(7)  NOT NULL,          -- e.g.: 2026/2
    class_value    CHAR(1)     NOT NULL,
    shift          VARCHAR(12) NOT NULL,
    UNIQUE (course_subject_id, academic_period, class_value)
);

CREATE TABLE students (
    student_id                    VARCHAR(10) PRIMARY KEY,
    fictitious_name               VARCHAR(120) NOT NULL,
    course_id                     VARCHAR(10)  NOT NULL REFERENCES courses(course_id),
    current_semester              SMALLINT     NOT NULL,
    age                           SMALLINT,
    neighborhood                  VARCHAR(80),
    high_school_type              VARCHAR(30),
    requested_psychosocial_support BOOLEAN NOT NULL DEFAULT FALSE,  -- sensitive data
    accessibility_need            BOOLEAN NOT NULL DEFAULT FALSE   -- sensitive data
);

-- Sensitive data (LGPD): separate table to restrict access by profile.
CREATE TABLE socioeconomic (
    student_id                            VARCHAR(10) PRIMARY KEY REFERENCES students(student_id) ON DELETE CASCADE,
    monthly_family_income                 NUMERIC(10,2),
    household_residents                   SMALLINT,
    per_capita_income                     NUMERIC(10,2),
    scholarship_aid                       VARCHAR(30),
    works                                 VARCHAR(20),
    daily_work_hours                      SMALLINT,
    weekly_study_hours                    NUMERIC(4,1),
    weekly_family_responsibilities_h      SMALLINT,
    distance_km                           NUMERIC(5,1),
    commute_time_min                      SMALLINT,
    transport_mode                        VARCHAR(20)
);

CREATE TABLE academic_indicators (
    student_id                       VARCHAR(10) NOT NULL REFERENCES students(student_id) ON DELETE CASCADE,
    academic_period                  VARCHAR(7)  NOT NULL,
    total_absences                   SMALLINT,
    attendance_pct                   SMALLINT,
    failed_subjects_history          SMALLINT,
    pending_activities               SMALLINT,
    previous_semester_average        NUMERIC(3,1),
    current_average                  NUMERIC(3,1),
    average_trend                    NUMERIC(3,1),
    PRIMARY KEY (student_id, academic_period)
);

CREATE TABLE risk_assessments (
    assessment_id    VARCHAR(10) PRIMARY KEY,
    student_id       VARCHAR(10) NOT NULL REFERENCES students(student_id) ON DELETE CASCADE,
    academic_period  VARCHAR(7)  NOT NULL,
    kind             VARCHAR(20) NOT NULL,         -- Initial, Recalculated...
    assessment_date  DATE        NOT NULL,
    dropout_risk_pct NUMERIC(4,1) NOT NULL,
    risk_level       VARCHAR(10)  NOT NULL CHECK (risk_level IN ('Low','Moderate','High','Critical'))
);

CREATE TABLE enrollments (
    enrollment_id  VARCHAR(10) PRIMARY KEY,
    student_id     VARCHAR(10) NOT NULL REFERENCES students(student_id) ON DELETE CASCADE,
    class_id       VARCHAR(16) NOT NULL REFERENCES classes(class_id),
    final_grade    NUMERIC(3,1) CHECK (final_grade BETWEEN 0 AND 10),
    attendance_pct SMALLINT     CHECK (attendance_pct BETWEEN 0 AND 100),
    status         VARCHAR(40),
    UNIQUE (student_id, class_id)
);

CREATE TABLE risk_rules (
    rule_id        VARCHAR(10) PRIMARY KEY,
    rule           VARCHAR(40) NOT NULL UNIQUE,
    condition      VARCHAR(120) NOT NULL,
    points         SMALLINT,                       -- NULL in the "bands" row
    interpretation VARCHAR(160)
);

CREATE INDEX ix_class_enrollments   ON enrollments(class_id);
CREATE INDEX ix_professor_classes   ON classes(id_professor);
CREATE INDEX ix_student_assessments ON risk_assessments(student_id);
