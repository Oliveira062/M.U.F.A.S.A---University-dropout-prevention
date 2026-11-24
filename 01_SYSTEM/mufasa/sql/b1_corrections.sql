BEGIN;

DROP VIEW IF EXISTS vw_chat_student_subjects, vw_chat_indicators, vw_chat_current_risk,
                    vw_chat_teacher_link;

ALTER TABLE universities          ALTER COLUMN university_id SET NOT NULL, ADD PRIMARY KEY (university_id);
ALTER TABLE courses                 ALTER COLUMN course_id        SET NOT NULL, ADD PRIMARY KEY (course_id);
ALTER TABLE professors            ALTER COLUMN id_professor    SET NOT NULL, ADD PRIMARY KEY (id_professor);
ALTER TABLE course_subjects               ALTER COLUMN course_subject_id      SET NOT NULL, ADD PRIMARY KEY (course_subject_id);
ALTER TABLE classes                 ALTER COLUMN class_id        SET NOT NULL, ADD PRIMARY KEY (class_id);
ALTER TABLE students                 ALTER COLUMN student_id        SET NOT NULL, ADD PRIMARY KEY (student_id);
ALTER TABLE socioeconomic         ALTER COLUMN student_id        SET NOT NULL, ADD PRIMARY KEY (student_id);
ALTER TABLE enrollments             ALTER COLUMN enrollment_id    SET NOT NULL, ADD PRIMARY KEY (enrollment_id);
ALTER TABLE risk_assessments       ALTER COLUMN assessment_id    SET NOT NULL, ADD PRIMARY KEY (assessment_id);
ALTER TABLE risk_rules           ALTER COLUMN rule_id        SET NOT NULL, ADD PRIMARY KEY (rule_id);
ALTER TABLE academic_indicators ALTER COLUMN student_id        SET NOT NULL,
                                   ALTER COLUMN academic_period  SET NOT NULL,
                                   ADD PRIMARY KEY (student_id, academic_period);

ALTER TABLE enrollments ALTER COLUMN student_id SET NOT NULL, ALTER COLUMN class_id SET NOT NULL,
                       ADD CONSTRAINT uq_class_student_enrollment UNIQUE (student_id, class_id);

ALTER TABLE courses                 ADD FOREIGN KEY (university_id) REFERENCES universities(university_id);
ALTER TABLE course_subjects               ADD FOREIGN KEY (course_id)        REFERENCES courses(course_id);
ALTER TABLE classes                 ADD FOREIGN KEY (course_subject_id)      REFERENCES course_subjects(course_subject_id),
                                   ADD FOREIGN KEY (id_professor)    REFERENCES professors(id_professor);
ALTER TABLE students                 ADD FOREIGN KEY (course_id)        REFERENCES courses(course_id);
ALTER TABLE socioeconomic         ADD FOREIGN KEY (student_id)        REFERENCES students(student_id);
ALTER TABLE academic_indicators ADD FOREIGN KEY (student_id)        REFERENCES students(student_id);
ALTER TABLE enrollments             ADD FOREIGN KEY (student_id)        REFERENCES students(student_id),
                                   ADD FOREIGN KEY (class_id)        REFERENCES classes(class_id);
ALTER TABLE risk_assessments       ADD FOREIGN KEY (student_id)        REFERENCES students(student_id);

ALTER TABLE risk_assessments ALTER COLUMN assessment_date TYPE DATE USING assessment_date::date;
ALTER TABLE professors      ALTER COLUMN hire_date  TYPE DATE USING hire_date::date;

CREATE TABLE IF NOT EXISTS b1_original_grades (
    enrollment_id VARCHAR(255) PRIMARY KEY REFERENCES enrollments(enrollment_id),
    exam1 NUMERIC, exam2 NUMERIC, exam3 NUMERIC, final_grade NUMERIC,
    copied_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
COMMENT ON TABLE b1_original_grades IS
    'Grades as they came from the B1 dump (scale 0 to 100), before the conversion to 0 to 10.';

INSERT INTO b1_original_grades (enrollment_id, exam1, exam2, exam3, final_grade)
SELECT enrollment_id, exam1, exam2, exam3, final_grade FROM enrollments
ON CONFLICT (enrollment_id) DO NOTHING;

UPDATE enrollments
   SET exam1 = round(exam1 / 10, 2), exam2 = round(exam2 / 10, 2), exam3 = round(exam3 / 10, 2),
       final_grade = round(final_grade / 10, 2)
 WHERE EXISTS (SELECT 1 FROM enrollments WHERE GREATEST(exam1, exam2, exam3, final_grade) > 10);

ALTER TABLE enrollments
    ADD CONSTRAINT ck_grades_enrollments CHECK (
        (exam1 IS NULL OR exam1 BETWEEN 0 AND 10) AND (exam2 IS NULL OR exam2 BETWEEN 0 AND 10) AND
        (exam3 IS NULL OR exam3 BETWEEN 0 AND 10) AND (final_grade IS NULL OR final_grade BETWEEN 0 AND 10)),
    ADD CONSTRAINT ck_attendance_enrollments CHECK (attendance_pct IS NULL OR attendance_pct BETWEEN 0 AND 100),
    ADD CONSTRAINT ck_status_enrollments CHECK (status IS NULL OR status IN ('Approved', 'Failed', 'Enrolled'));

ALTER TABLE academic_indicators
    ADD CONSTRAINT ck_attendance_ind CHECK (attendance_pct IS NULL OR attendance_pct BETWEEN 0 AND 100),
    ADD CONSTRAINT ck_averages_ind CHECK (
        (current_average IS NULL OR current_average BETWEEN 0 AND 10) AND
        (previous_semester_average IS NULL OR previous_semester_average BETWEEN 0 AND 10)),
    ADD CONSTRAINT ck_counts_ind CHECK (
        (total_absences IS NULL OR total_absences >= 0) AND
        (failed_subjects_history IS NULL OR failed_subjects_history >= 0) AND
        (pending_activities IS NULL OR pending_activities >= 0));

ALTER TABLE socioeconomic
    ADD CONSTRAINT ck_values_socio CHECK (
        (monthly_family_income IS NULL OR monthly_family_income >= 0) AND
        (per_capita_income IS NULL OR per_capita_income >= 0) AND
        (daily_work_hours IS NULL OR daily_work_hours BETWEEN 0 AND 24) AND
        (commute_time_min IS NULL OR commute_time_min BETWEEN 0 AND 1440));

ALTER TABLE students
    ADD CONSTRAINT ck_semester_students CHECK (current_semester IS NULL OR current_semester BETWEEN 1 AND 20),
    ADD CONSTRAINT ck_age_students CHECK (age IS NULL OR age BETWEEN 10 AND 120);

ALTER TABLE risk_assessments
    ADD CONSTRAINT ck_assessments_pct CHECK (dropout_risk_pct IS NULL OR dropout_risk_pct BETWEEN 0 AND 100);

CREATE TABLE IF NOT EXISTS student_support (
    student_id       VARCHAR(255) PRIMARY KEY REFERENCES students(student_id),
    encrypted_data TEXT        NOT NULL CHECK (encrypted_data LIKE 'gAAAAA%'),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
COMMENT ON TABLE student_support IS
    'Psychosocial support and accessibility (LGPD art. 11). Encrypted with SUPPORT_KEY, which stays outside the database.';

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'mufasa_owner') THEN
        CREATE ROLE mufasa_owner NOLOGIN;
    END IF;
END $$;

GRANT USAGE, CREATE ON SCHEMA public TO mufasa_owner;

DO $$
DECLARE
    table_name TEXT;
BEGIN
    FOREACH table_name IN ARRAY ARRAY['universities', 'courses', 'professors', 'course_subjects', 'classes', 'students',
                                  'socioeconomic', 'enrollments', 'risk_assessments', 'risk_rules',
                                  'academic_indicators', 'b1_original_grades', 'student_support']
    LOOP
        EXECUTE format('ALTER TABLE %I OWNER TO mufasa_owner', table_name);
    END LOOP;
END $$;

COMMIT;
