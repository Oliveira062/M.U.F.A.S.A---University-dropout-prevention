\restrict ZQ4gFzwVffDWmS8gylf1GFMpyqbPefQVkBsYJIEpmeavYsOpNohTvwzLS5gRDnU

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

CREATE TABLE public.students (
    student_id character varying(255),
    fictitious_name character varying(255),
    course_id character varying(255),
    current_semester integer,
    age integer,
    neighborhood character varying(255),
    high_school_type character varying(255),
    requested_psychosocial_support character varying(255),
    accessibility_need character varying(255)
);

ALTER TABLE public.students OWNER TO postgres;

CREATE TABLE public.risk_assessments (
    assessment_id character varying(255),
    student_id character varying(255),
    academic_period character varying(255),
    kind character varying(255),
    assessment_date character varying(255),
    dropout_risk_pct numeric,
    risk_level character varying(255)
);

ALTER TABLE public.risk_assessments OWNER TO postgres;

CREATE TABLE public.courses (
    course_id character varying(255),
    university_id character varying(255),
    name character varying(255),
    degree character varying(255),
    duration_semesters integer,
    passing_average integer,
    minimum_attendance_pct integer
);

ALTER TABLE public.courses OWNER TO postgres;

CREATE TABLE public.academic_indicators (
    student_id character varying(255),
    academic_period character varying(255),
    total_absences integer,
    attendance_pct integer,
    failed_subjects_history integer,
    pending_activities integer,
    previous_semester_average numeric,
    current_average numeric,
    average_trend numeric
);

ALTER TABLE public.academic_indicators OWNER TO postgres;

CREATE TABLE public.course_subjects (
    course_subject_id character varying(255),
    course_id character varying(255),
    name character varying(255),
    curriculum_semester integer,
    workload_h integer,
    passing_average integer,
    minimum_attendance_pct integer
);

ALTER TABLE public.course_subjects OWNER TO postgres;

CREATE TABLE public.enrollments (
    enrollment_id character varying(255),
    student_id character varying(255),
    class_id character varying(255),
    final_grade numeric,
    attendance_pct integer,
    status character varying(255),
    exam1 numeric,
    exam2 numeric,
    exam3 numeric
);

ALTER TABLE public.enrollments OWNER TO postgres;

CREATE TABLE public.professors (
    id_professor character varying(255),
    name character varying(255),
    degree character varying(255),
    expertise_area character varying(255),
    work_regime character varying(255),
    institutional_email character varying(255),
    hire_date character varying(255)
);

ALTER TABLE public.professors OWNER TO postgres;

CREATE TABLE public.risk_rules (
    rule_id character varying(255),
    rule character varying(255),
    condition character varying(255),
    points character varying(255),
    interpretation character varying(255)
);

ALTER TABLE public.risk_rules OWNER TO postgres;

CREATE TABLE public.socioeconomic (
    student_id character varying(255),
    monthly_family_income integer,
    household_residents integer,
    per_capita_income numeric,
    scholarship_aid character varying(255),
    works character varying(255),
    daily_work_hours integer,
    weekly_study_hours numeric,
    weekly_family_responsibilities_h integer,
    distance_km numeric,
    commute_time_min integer,
    transport_mode character varying(255),
    prouni character varying(255),
    fies character varying(255),
    employee_discount character varying(255)
);

ALTER TABLE public.socioeconomic OWNER TO postgres;

CREATE TABLE public.classes (
    class_id character varying(255),
    course_subject_id character varying(255),
    id_professor character varying(255),
    academic_period character varying(255),
    class_value character varying(255),
    shift character varying(255)
);

ALTER TABLE public.classes OWNER TO postgres;

CREATE TABLE public.universities (
    university_id character varying(255),
    name character varying(255),
    city character varying(255),
    uf character varying(255)
);

ALTER TABLE public.universities OWNER TO postgres;

COPY public.students (student_id, fictitious_name, course_id, current_semester, age, neighborhood, high_school_type, requested_psychosocial_support, accessibility_need) FROM stdin;
ALU0001	Julia Araújo Silva	CUR01	2	23	Recanto do Sol	Regular in-person	No	No
ALU0002	Camila Mendes Carvalho	CUR01	1	21	Anápolis City	Regular in-person	Yes	Yes
ALU0003	Isabela Araújo Ribeiro	CUR01	3	17	Maracanã	Regular in-person	No	No
ALU0004	Beatriz Ribeiro Santos	CUR01	7	31	Jardim Alexandrina	Regular in-person	No	No
ALU0005	Isabela Gomes Gomes	CUR01	4	29	Paraíso	Regular in-person	No	No
ALU0006	Gabriel Ribeiro Teixeira	CUR01	1	23	Setor Industrial	Regular in-person	No	No
ALU0007	João Araújo Silva	CUR01	5	26	Setor Industrial	EJA	No	No
ALU0008	Letícia Rocha Silva	CUR01	2	18	Jardim Alexandrina	Regular in-person	No	No
ALU0009	João Pereira Costa	CUR01	2	26	Boa Vista	Regular in-person	No	No
ALU0010	Ana Gomes Ferreira	CUR01	7	17	Boa Vista	Regular in-person	No	No
ALU0011	Victor Almeida Gomes	CUR01	1	19	Setor Central	Regular in-person	No	No
ALU0012	Amanda Lima Souza	CUR01	5	21	Anápolis City	Regular in-person	No	No
ALU0013	Eduardo Santos Mendes	CUR01	7	26	Setor Central	Regular in-person	No	No
ALU0014	Lucas Lima Santos	CUR01	3	27	Jibran El Hadj	Regular hybrid	No	No
ALU0015	Gabriel Silva Pereira	CUR01	2	20	Anápolis City	Regular in-person	No	No
ALU0016	Maria Rocha Silva	CUR01	2	20	Jardim Alexandrina	Regular in-person	No	No
ALU0017	Matheus Carvalho Rodrigues	CUR01	5	26	São Carlos	Regular in-person	Yes	No
ALU0018	Rafael Lima Teixeira	CUR01	6	28	Setor Industrial	EJA	No	No
ALU0019	Felipe Lima Almeida	CUR01	1	20	São Carlos	EJA	No	No
ALU0020	Thiago Carvalho Silva	CUR01	7	26	Setor Central	Regular in-person	No	No
ALU0021	Luana Ferreira Lima	CUR01	1	20	Anápolis City	Regular in-person	No	No
ALU0022	Amanda Mendes Carvalho	CUR01	4	26	Setor Central	Regular in-person	No	No
ALU0023	Rafael Almeida Souza	CUR01	6	31	Setor Industrial	Regular in-person	No	No
ALU0024	Renato Rocha Nunes	CUR01	2	20	Maracanã	Regular in-person	No	No
ALU0025	Carlos Santos Ferreira	CUR01	7	27	Jardim Alexandrina	Regular in-person	No	No
ALU0026	Rafael Silva Rodrigues	CUR01	4	25	Jardim Alexandrina	Regular in-person	No	Yes
ALU0027	Eduardo Barbosa Almeida	CUR01	2	17	Anápolis City	Regular in-person	No	No
ALU0028	Mariana Mendes Carvalho	CUR01	3	24	Recanto do Sol	Regular in-person	No	No
ALU0029	Felipe Pereira Ribeiro	CUR01	8	17	Vila Jaiara	Regular in-person	No	No
ALU0030	Pedro Martins Souza	CUR01	7	23	Vivian Parque	Regular hybrid	No	No
ALU0031	Lucas Araújo Ribeiro	CUR01	6	19	Boa Vista	Regular in-person	No	No
ALU0032	Matheus Ribeiro Santos	CUR01	1	17	São Carlos	Regular in-person	No	No
ALU0033	Letícia Costa Lima	CUR01	2	20	São Carlos	Regular in-person	No	No
ALU0034	Julia Oliveira Rocha	CUR01	4	21	Boa Vista	Regular in-person	No	Yes
ALU0035	Renato Teixeira Nunes	CUR01	5	26	Maracanã	Regular in-person	No	No
ALU0036	Lucas Gomes Mendes	CUR01	2	17	Jundiaí	Regular in-person	No	No
ALU0037	Gustavo Teixeira Gomes	CUR01	3	24	Paraíso	Regular in-person	No	No
ALU0038	Mariana Ferreira Martins	CUR01	7	27	Setor Industrial	Regular in-person	No	No
ALU0039	Isabela Gomes Pereira	CUR01	2	24	Setor Central	Regular hybrid	Yes	No
ALU0040	Felipe Martins Mendes	CUR01	3	17	Vila Jaiara	Regular in-person	No	No
ALU0041	Thiago Gomes Lima	CUR01	3	17	Jibran El Hadj	Regular in-person	No	No
ALU0042	Amanda Souza Oliveira	CUR01	5	21	Residencial das Rosas	Regular in-person	No	No
ALU0043	Lucas Martins Souza	CUR01	3	21	Residencial das Rosas	Regular in-person	No	No
ALU0044	Ana Carvalho Barbosa	CUR01	3	23	Setor Industrial	Regular hybrid	No	No
ALU0045	Letícia Barbosa Santos	CUR01	1	17	Vivian Parque	Regular in-person	No	No
ALU0046	Amanda Teixeira Almeida	CUR01	5	22	Paraíso	Regular in-person	No	No
ALU0047	Larissa Silva Carvalho	CUR01	4	17	Filostro Machado	Regular in-person	Yes	No
ALU0048	Letícia Costa Rodrigues	CUR01	8	21	Vila Jaiara	Regular in-person	No	No
ALU0049	Maria Ribeiro Santos	CUR01	5	32	Jundiaí	Regular in-person	Yes	No
ALU0050	Lucas Barbosa Almeida	CUR01	3	19	Filostro Machado	Regular in-person	No	No
ALU0051	Amanda Pereira Silva	CUR01	1	25	São Carlos	Regular in-person	No	No
ALU0052	Rafael Teixeira Oliveira	CUR01	7	29	Jundiaí	Regular in-person	No	No
ALU0053	Carlos Mendes Costa	CUR01	8	31	Boa Vista	Regular hybrid	No	No
ALU0054	Isabela Barbosa Souza	CUR01	4	17	Vila Jaiara	Regular in-person	No	No
ALU0055	Ana Nunes Santos	CUR01	2	20	São Carlos	Regular in-person	No	No
ALU0056	Isabela Rocha Rocha	CUR01	1	20	Vila Jaiara	Regular in-person	No	No
ALU0057	Felipe Rodrigues Nunes	CUR01	3	17	Jardim Alexandrina	Regular in-person	No	No
ALU0058	Gabriel Carvalho Almeida	CUR01	1	17	Jibran El Hadj	Regular in-person	No	No
ALU0059	Matheus Carvalho Ribeiro	CUR01	4	25	Recanto do Sol	Regular in-person	No	No
ALU0060	Maria Costa Teixeira	CUR01	1	23	Boa Vista	EJA	No	Yes
ALU0061	Mariana Silva Pereira	CUR01	8	19	Setor Central	EJA	No	No
ALU0062	Matheus Pereira Rocha	CUR01	2	24	Maracanã	Regular hybrid	No	No
ALU0063	Lucas Rocha Ribeiro	CUR01	8	26	Residencial das Rosas	Regular in-person	No	No
ALU0064	Renato Barbosa Silva	CUR01	5	18	Maracanã	Regular in-person	No	No
ALU0065	Eduardo Almeida Rocha	CUR01	7	21	Vivian Parque	Regular hybrid	No	No
ALU0066	Renato Lima Pereira	CUR01	3	22	Residencial das Rosas	Regular in-person	No	No
ALU0067	Rafael Mendes Souza	CUR01	6	19	Jibran El Hadj	Regular in-person	No	No
ALU0068	Lucas Almeida Araújo	CUR01	1	19	São Carlos	Regular in-person	No	No
ALU0069	Rafael Oliveira Silva	CUR01	1	21	Maracanã	EJA	No	No
ALU0070	Carlos Carvalho Silva	CUR01	1	17	Recanto do Sol	Regular in-person	No	No
ALU0071	Matheus Souza Gomes	CUR01	4	17	Boa Vista	Regular in-person	No	No
ALU0072	Eduardo Mendes Costa	CUR01	4	23	Jundiaí	Regular in-person	No	No
ALU0073	Beatriz Costa Souza	CUR01	6	25	Jardim Alexandrina	Regular in-person	Yes	No
ALU0074	Carlos Pereira Almeida	CUR01	3	22	Anápolis City	Regular hybrid	No	Yes
ALU0075	Victor Carvalho Almeida	CUR01	5	23	Jibran El Hadj	Regular in-person	Yes	No
ALU0076	Renato Souza Almeida	CUR01	8	27	Maracanã	Regular in-person	No	No
ALU0077	Bruno Almeida Oliveira	CUR01	4	18	Anápolis City	Regular in-person	No	No
ALU0078	Victor Barbosa Mendes	CUR01	1	23	Vila Jaiara	Regular hybrid	No	No
ALU0079	Lucas Santos Souza	CUR01	4	27	Jibran El Hadj	Regular in-person	No	No
ALU0080	Rafael Mendes Ribeiro	CUR01	2	17	Setor Central	Regular in-person	No	No
ALU0081	Renato Mendes Oliveira	CUR01	4	22	São Carlos	EJA	No	Yes
ALU0082	Isabela Carvalho Araújo	CUR01	1	27	Setor Industrial	Regular in-person	No	No
ALU0083	Gabriel Carvalho Rodrigues	CUR01	1	24	Maracanã	Regular in-person	Yes	No
ALU0084	Bruno Almeida Carvalho	CUR01	2	25	Residencial das Rosas	Regular in-person	No	Yes
ALU0085	Ana Costa Barbosa	CUR01	3	25	Filostro Machado	EJA	No	No
ALU0086	Larissa Rodrigues Gomes	CUR01	8	27	Filostro Machado	Regular in-person	No	No
ALU0087	Gabriel Rodrigues Rodrigues	CUR01	8	24	Jardim Alexandrina	Regular in-person	No	No
ALU0088	Victor Silva Martins	CUR01	8	28	Setor Central	Regular in-person	No	No
ALU0089	Beatriz Souza Carvalho	CUR01	2	25	Anápolis City	Regular in-person	No	No
ALU0090	João Santos Souza	CUR01	1	23	Boa Vista	Regular hybrid	No	No
ALU0091	Bruno Pereira Ferreira	CUR01	6	17	Paraíso	Regular in-person	No	No
ALU0092	Thiago Nunes Ribeiro	CUR01	1	18	Maracanã	Regular in-person	No	No
ALU0093	Rafael Almeida Ribeiro	CUR01	4	18	Jardim Alexandrina	Regular in-person	No	No
ALU0094	Rafael Barbosa Martins	CUR01	6	17	Boa Vista	Regular in-person	No	No
ALU0095	Letícia Ferreira Rocha	CUR01	3	29	Boa Vista	Regular in-person	No	No
ALU0096	Rafael Santos Gomes	CUR01	1	18	Vivian Parque	Regular in-person	No	No
ALU0097	Camila Lima Souza	CUR01	6	28	São Carlos	Regular in-person	No	No
ALU0098	Julia Silva Santos	CUR01	2	17	Maracanã	Regular in-person	Yes	No
ALU0099	Matheus Mendes Araújo	CUR01	4	23	Vivian Parque	EJA	No	No
ALU0100	Maria Costa Araújo	CUR01	4	19	Jundiaí	Regular in-person	No	No
ALU0101	Lucas Silva Araújo	CUR01	2	23	Recanto do Sol	Regular in-person	No	No
ALU0102	Larissa Silva Oliveira	CUR01	5	21	Filostro Machado	EJA	No	No
ALU0103	Camila Carvalho Silva	CUR01	8	24	Paraíso	Regular in-person	No	No
ALU0104	Victor Mendes Gomes	CUR01	7	24	Jibran El Hadj	Regular in-person	No	No
ALU0105	Renato Ferreira Carvalho	CUR01	8	17	Jundiaí	Regular in-person	No	No
ALU0106	Victor Mendes Pereira	CUR01	5	24	Setor Industrial	Regular in-person	No	No
ALU0107	Eduardo Araújo Nunes	CUR01	3	26	Filostro Machado	EJA	No	No
ALU0108	Larissa Oliveira Martins	CUR01	4	20	Anápolis City	Regular in-person	No	No
ALU0109	Pedro Rodrigues Silva	CUR01	2	17	Maracanã	Regular in-person	No	No
ALU0110	Rafael Costa Ribeiro	CUR01	2	21	Setor Industrial	Regular in-person	No	No
ALU0111	Lucas Ribeiro Barbosa	CUR01	8	26	Setor Central	Regular in-person	No	Yes
ALU0112	Eduardo Costa Santos	CUR01	4	19	Anápolis City	EJA	Yes	No
ALU0113	Rafael Costa Souza	CUR01	7	24	Filostro Machado	Regular in-person	No	No
ALU0114	Victor Carvalho Santos	CUR01	8	22	Recanto do Sol	Regular in-person	No	No
ALU0115	Camila Carvalho Oliveira	CUR01	3	25	Residencial das Rosas	Regular in-person	No	No
ALU0116	Lucas Nunes Silva	CUR01	7	17	Vivian Parque	Regular in-person	Yes	No
ALU0117	Ana Martins Lima	CUR01	5	18	Anápolis City	Regular hybrid	No	No
ALU0118	Letícia Silva Pereira	CUR01	8	21	Boa Vista	EJA	No	No
ALU0119	Larissa Ribeiro Nunes	CUR01	4	20	Paraíso	EJA	Yes	No
ALU0120	Thiago Ferreira Rodrigues	CUR01	8	27	Maracanã	Regular in-person	No	No
ALU0121	Letícia Ferreira Martins	CUR01	5	25	Jundiaí	Regular in-person	Yes	No
ALU0122	Renato Carvalho Santos	CUR01	5	20	Vila Jaiara	Regular in-person	Yes	No
ALU0123	Matheus Ribeiro Nunes	CUR01	1	22	Setor Industrial	Regular in-person	Yes	No
ALU0124	Ana Teixeira Ferreira	CUR01	8	31	Jibran El Hadj	Regular hybrid	No	No
ALU0125	Victor Lima Araújo	CUR01	3	17	Anápolis City	Regular hybrid	No	No
ALU0126	Luana Silva Nunes	CUR01	7	28	Setor Industrial	Regular in-person	No	No
ALU0127	João Mendes Ferreira	CUR01	8	29	Jibran El Hadj	Regular in-person	Yes	No
ALU0128	Julia Teixeira Nunes	CUR01	3	17	Setor Central	Regular in-person	No	No
ALU0129	Lucas Rocha Martins	CUR01	6	19	Vila Jaiara	Regular in-person	No	No
ALU0130	Gustavo Costa Gomes	CUR01	7	25	Paraíso	Regular in-person	No	Yes
ALU0131	Felipe Oliveira Rocha	CUR01	8	27	São Carlos	Regular in-person	No	No
ALU0132	Luana Santos Mendes	CUR01	6	18	Residencial das Rosas	Regular hybrid	Yes	No
ALU0133	Pedro Pereira Silva	CUR01	7	27	Setor Industrial	Regular in-person	No	No
ALU0134	Mariana Oliveira Costa	CUR01	5	22	Filostro Machado	Regular in-person	No	No
ALU0135	Carlos Ribeiro Martins	CUR01	3	24	Boa Vista	EJA	No	No
ALU0136	Luana Ribeiro Ribeiro	CUR01	3	24	Vivian Parque	Regular in-person	Yes	No
ALU0137	Rafael Martins Teixeira	CUR01	2	17	Setor Central	Regular hybrid	No	No
ALU0138	Thiago Santos Gomes	CUR01	2	21	Vivian Parque	Regular in-person	No	No
ALU0139	João Araújo Ribeiro	CUR01	5	23	Setor Central	Regular in-person	No	No
ALU0140	Eduardo Ribeiro Souza	CUR01	2	29	Boa Vista	Regular in-person	Yes	No
ALU0141	Victor Ferreira Araújo	CUR01	8	20	Vivian Parque	Regular in-person	No	No
ALU0142	Ana Carvalho Ribeiro	CUR01	6	17	Setor Central	Regular in-person	No	No
ALU0143	Isabela Martins Martins	CUR01	2	24	Setor Central	Regular in-person	No	No
ALU0144	Beatriz Silva Araújo	CUR01	6	25	Residencial das Rosas	Regular in-person	No	No
ALU0145	Gabriel Ribeiro Rocha	CUR01	7	25	Boa Vista	Regular in-person	No	No
ALU0146	Isabela Nunes Souza	CUR01	2	21	Maracanã	Regular hybrid	No	No
ALU0147	Carlos Nunes Araújo	CUR01	2	32	Jundiaí	Regular in-person	No	No
ALU0148	Felipe Lima Rodrigues	CUR01	2	24	Setor Industrial	Regular in-person	No	No
ALU0149	Amanda Almeida Ferreira	CUR01	4	23	Vivian Parque	Regular in-person	Yes	No
ALU0150	Gabriel Souza Almeida	CUR01	6	20	Vila Jaiara	Regular in-person	No	No
ALU0151	Carlos Costa Nunes	CUR01	7	22	Jardim Alexandrina	Regular in-person	Yes	No
ALU0152	Mariana Nunes Teixeira	CUR01	4	17	Jibran El Hadj	Regular in-person	No	No
ALU0153	Isabela Mendes Araújo	CUR01	2	24	Filostro Machado	Regular in-person	No	No
ALU0154	Carlos Lima Souza	CUR01	6	17	São Carlos	Regular in-person	Yes	No
ALU0155	Pedro Lima Santos	CUR01	1	21	Boa Vista	Regular in-person	No	No
ALU0156	Bruno Carvalho Ferreira	CUR01	6	27	Maracanã	Regular in-person	Yes	No
ALU0157	Felipe Martins Ferreira	CUR01	2	19	Vivian Parque	Regular in-person	No	No
ALU0158	Beatriz Teixeira Gomes	CUR01	1	21	Paraíso	EJA	Yes	No
ALU0159	Carlos Costa Teixeira	CUR01	3	17	Paraíso	Regular in-person	No	No
ALU0160	Beatriz Ribeiro Gomes	CUR01	5	18	Maracanã	EJA	No	No
ALU0161	Mariana Araújo Mendes	CUR01	2	19	Setor Central	EJA	Yes	No
ALU0162	Rafael Costa Lima	CUR01	4	28	São Carlos	Regular hybrid	No	No
ALU0163	Bruno Barbosa Pereira	CUR01	6	22	Maracanã	Regular in-person	Yes	Yes
ALU0164	Carlos Ribeiro Gomes	CUR01	5	20	Boa Vista	EJA	No	No
ALU0165	Eduardo Carvalho Rocha	CUR01	5	21	Filostro Machado	Regular in-person	No	No
ALU0166	João Rodrigues Gomes	CUR01	1	25	Paraíso	Regular in-person	No	No
ALU0167	Julia Lima Nunes	CUR01	7	25	Vila Jaiara	Regular hybrid	Yes	No
ALU0168	Felipe Souza Ferreira	CUR01	4	23	Paraíso	Regular in-person	No	No
ALU0169	João Martins Oliveira	CUR01	2	21	Residencial das Rosas	Regular in-person	No	No
ALU0170	Pedro Oliveira Rodrigues	CUR01	4	22	Setor Industrial	Regular in-person	No	No
ALU0171	Amanda Lima Pereira	CUR01	1	28	Anápolis City	Regular in-person	No	No
ALU0172	Gustavo Santos Costa	CUR01	5	25	Setor Industrial	EJA	Yes	Yes
ALU0173	Camila Araújo Pereira	CUR01	3	24	Jundiaí	Regular in-person	No	No
ALU0174	Pedro Martins Rocha	CUR01	7	17	São Carlos	EJA	No	No
ALU0175	Gustavo Ferreira Araújo	CUR01	3	18	Jardim Alexandrina	Regular in-person	No	No
ALU0176	Julia Silva Santos	CUR01	2	19	Jundiaí	Regular in-person	No	No
ALU0177	Thiago Carvalho Araújo	CUR01	7	20	Residencial das Rosas	Regular in-person	No	No
ALU0178	Bruno Souza Oliveira	CUR01	6	17	Vivian Parque	Regular in-person	No	No
ALU0179	Pedro Costa Pereira	CUR01	1	24	Vivian Parque	Regular hybrid	Yes	No
ALU0180	Eduardo Santos Carvalho	CUR01	5	22	Paraíso	Regular in-person	No	Yes
ALU0181	João Oliveira Santos	CUR01	7	17	Jibran El Hadj	Regular in-person	Yes	No
ALU0182	Luana Martins Araújo	CUR01	8	24	Maracanã	Regular in-person	No	No
ALU0183	Felipe Pereira Pereira	CUR01	8	30	Vivian Parque	Regular hybrid	No	No
ALU0184	Renato Nunes Mendes	CUR01	3	19	Setor Industrial	Regular in-person	No	No
ALU0185	Victor Ferreira Rocha	CUR01	3	19	Jardim Alexandrina	Regular in-person	No	No
ALU0186	Luana Barbosa Ferreira	CUR01	2	17	Vila Jaiara	Regular in-person	No	No
ALU0187	Isabela Rodrigues Costa	CUR01	1	25	Residencial das Rosas	Regular in-person	No	No
ALU0188	Beatriz Ribeiro Carvalho	CUR01	8	21	Setor Central	Regular in-person	No	No
ALU0189	Maria Rodrigues Mendes	CUR01	8	28	Anápolis City	Regular in-person	Yes	No
ALU0190	Victor Teixeira Almeida	CUR01	4	17	Jundiaí	Regular in-person	No	No
ALU0191	Pedro Teixeira Carvalho	CUR01	6	22	Boa Vista	Regular in-person	No	No
ALU0192	Amanda Nunes Almeida	CUR01	4	25	Residencial das Rosas	Regular in-person	No	No
ALU0193	Eduardo Souza Souza	CUR01	5	30	Recanto do Sol	EJA	No	No
ALU0194	Gabriel Oliveira Teixeira	CUR01	5	35	Jardim Alexandrina	Regular hybrid	Yes	No
ALU0195	Bruno Gomes Pereira	CUR01	3	29	Paraíso	Regular in-person	No	Yes
ALU0196	Maria Carvalho Teixeira	CUR01	1	22	Jardim Alexandrina	Regular in-person	No	No
ALU0197	Matheus Barbosa Nunes	CUR01	4	23	Vila Jaiara	Regular in-person	No	No
ALU0198	João Souza Teixeira	CUR01	4	27	Vivian Parque	Regular in-person	No	No
ALU0199	Carlos Costa Araújo	CUR01	3	22	São Carlos	Regular in-person	Yes	Yes
ALU0200	Luana Ferreira Carvalho	CUR01	6	18	Recanto do Sol	Regular hybrid	No	Yes
ALU0201	Rafael Pereira Ferreira	CUR01	4	24	Residencial das Rosas	Regular hybrid	No	No
ALU0202	João Santos Teixeira	CUR01	6	17	Anápolis City	Regular in-person	No	No
ALU0203	Ana Gomes Rocha	CUR01	1	23	Jundiaí	Regular in-person	No	No
ALU0204	Larissa Teixeira Rocha	CUR01	8	30	Maracanã	Regular in-person	Yes	No
ALU0205	Beatriz Teixeira Rocha	CUR01	6	29	Residencial das Rosas	Regular in-person	No	No
ALU0206	Thiago Carvalho Carvalho	CUR01	5	20	Paraíso	Regular in-person	Yes	No
ALU0207	Beatriz Lima Almeida	CUR01	3	18	Vivian Parque	Regular hybrid	No	No
ALU0208	Victor Almeida Gomes	CUR01	1	22	Maracanã	Regular in-person	No	No
ALU0209	Rafael Martins Mendes	CUR01	3	26	Anápolis City	Regular in-person	No	No
ALU0210	Letícia Nunes Teixeira	CUR01	2	27	Boa Vista	Regular in-person	No	No
ALU0211	Lucas Rodrigues Rocha	CUR01	2	30	Boa Vista	Regular hybrid	No	No
ALU0212	João Nunes Rodrigues	CUR01	4	23	Filostro Machado	Regular in-person	No	No
ALU0213	Thiago Carvalho Teixeira	CUR01	2	17	Maracanã	Regular hybrid	No	No
ALU0214	Julia Martins Ribeiro	CUR01	5	27	Anápolis City	Regular in-person	No	No
ALU0215	Pedro Ferreira Araújo	CUR01	6	17	Jardim Alexandrina	Regular in-person	No	No
ALU0216	Gabriel Gomes Nunes	CUR01	2	27	Maracanã	Regular in-person	Yes	Yes
ALU0217	Gabriel Silva Rocha	CUR01	5	18	Setor Industrial	Regular in-person	No	No
ALU0218	Felipe Almeida Oliveira	CUR01	4	21	Vivian Parque	Regular in-person	No	No
ALU0219	Pedro Almeida Mendes	CUR01	1	26	Setor Central	Regular in-person	No	No
ALU0220	Gustavo Carvalho Gomes	CUR01	6	19	São Carlos	EJA	No	No
ALU0221	Gustavo Barbosa Araújo	CUR01	8	19	Boa Vista	EJA	No	No
ALU0222	Eduardo Gomes Mendes	CUR01	7	23	Setor Industrial	Regular in-person	No	No
ALU0223	Mariana Mendes Carvalho	CUR01	4	26	Residencial das Rosas	Regular in-person	No	No
ALU0224	João Nunes Ribeiro	CUR01	7	23	Jundiaí	Regular hybrid	No	No
ALU0225	Thiago Lima Araújo	CUR01	3	21	Jundiaí	Regular in-person	No	No
ALU0226	Eduardo Souza Gomes	CUR01	3	27	Filostro Machado	Regular in-person	No	No
ALU0227	Eduardo Teixeira Carvalho	CUR01	5	17	Anápolis City	EJA	Yes	No
ALU0228	Camila Carvalho Almeida	CUR01	4	19	Vivian Parque	Regular in-person	No	No
ALU0229	Bruno Oliveira Carvalho	CUR01	2	20	Vivian Parque	Regular in-person	No	Yes
ALU0230	Larissa Santos Oliveira	CUR01	8	26	Setor Central	EJA	No	Yes
ALU0231	Larissa Rodrigues Silva	CUR01	5	27	Setor Industrial	Regular in-person	No	No
ALU0232	Renato Costa Oliveira	CUR01	4	22	Anápolis City	Regular hybrid	No	No
ALU0233	Bruno Lima Martins	CUR01	4	17	Filostro Machado	Regular in-person	No	No
ALU0234	Amanda Souza Nunes	CUR01	2	26	Setor Industrial	Regular in-person	No	No
ALU0235	Lucas Silva Carvalho	CUR01	6	28	Anápolis City	Regular in-person	No	No
ALU0236	Amanda Barbosa Carvalho	CUR01	6	21	São Carlos	Regular in-person	No	No
ALU0237	Victor Martins Oliveira	CUR01	3	25	Jundiaí	Regular in-person	Yes	No
ALU0238	Letícia Pereira Souza	CUR01	8	21	Residencial das Rosas	Regular in-person	No	No
ALU0239	Camila Carvalho Lima	CUR01	1	27	Vila Jaiara	Regular in-person	No	No
ALU0240	Ana Costa Silva	CUR01	2	28	Vila Jaiara	EJA	No	No
ALU0241	Eduardo Souza Almeida	CUR01	2	17	São Carlos	Regular in-person	No	No
ALU0242	Luana Araújo Araújo	CUR01	4	17	Anápolis City	Regular in-person	No	No
ALU0243	Camila Oliveira Rocha	CUR01	3	21	Residencial das Rosas	Regular hybrid	No	No
ALU0244	Larissa Ferreira Barbosa	CUR01	3	28	São Carlos	Regular in-person	No	No
ALU0245	Thiago Nunes Teixeira	CUR01	4	17	Residencial das Rosas	Regular in-person	Yes	No
ALU0246	Camila Carvalho Gomes	CUR01	8	22	Jardim Alexandrina	Regular hybrid	No	No
ALU0247	Bruno Martins Silva	CUR01	2	17	Jardim Alexandrina	Regular in-person	No	No
ALU0248	Julia Mendes Santos	CUR01	4	20	Anápolis City	Regular in-person	No	No
ALU0249	Bruno Rodrigues Almeida	CUR01	2	27	São Carlos	Regular in-person	No	No
ALU0250	Matheus Araújo Lima	CUR01	3	23	Residencial das Rosas	Regular in-person	No	No
ALU0251	Mariana Martins Gomes	CUR01	5	17	Recanto do Sol	Regular in-person	No	No
ALU0252	Matheus Silva Araújo	CUR01	7	21	Setor Central	Regular in-person	No	No
ALU0253	Julia Silva Gomes	CUR01	6	17	São Carlos	Regular in-person	No	No
ALU0254	Gabriel Lima Ribeiro	CUR01	6	25	Paraíso	Regular in-person	No	No
ALU0255	Felipe Nunes Gomes	CUR01	5	24	Jundiaí	Regular hybrid	No	No
ALU0256	Beatriz Souza Ribeiro	CUR01	5	23	Jardim Alexandrina	Regular in-person	No	No
ALU0257	Gustavo Nunes Lima	CUR01	4	25	Jundiaí	Regular in-person	No	No
ALU0258	Isabela Teixeira Carvalho	CUR01	1	19	Jibran El Hadj	Regular in-person	No	No
ALU0259	Rafael Nunes Santos	CUR01	4	23	Maracanã	Regular in-person	No	No
ALU0260	Rafael Ferreira Lima	CUR01	8	18	Setor Central	Regular in-person	No	No
ALU0261	Luana Almeida Rodrigues	CUR01	1	17	Jibran El Hadj	Regular in-person	No	No
ALU0262	Rafael Martins Costa	CUR01	4	17	Boa Vista	Regular in-person	No	No
ALU0263	Pedro Pereira Martins	CUR01	8	20	São Carlos	Regular hybrid	No	Yes
ALU0264	Amanda Barbosa Rodrigues	CUR01	1	25	Setor Industrial	Regular in-person	No	No
ALU0265	Eduardo Ferreira Ribeiro	CUR01	3	21	Residencial das Rosas	Regular in-person	No	No
ALU0266	Felipe Rodrigues Pereira	CUR01	8	17	Vila Jaiara	EJA	No	Yes
ALU0267	Maria Araújo Nunes	CUR01	6	24	Maracanã	Regular in-person	No	No
ALU0268	Ana Mendes Barbosa	CUR01	2	19	Maracanã	Regular in-person	Yes	No
ALU0269	Beatriz Teixeira Lima	CUR01	6	27	Setor Central	Regular in-person	No	No
ALU0270	Luana Oliveira Gomes	CUR01	8	23	Jardim Alexandrina	Regular in-person	No	No
ALU0271	Maria Martins Rocha	CUR01	1	17	Jardim Alexandrina	Regular in-person	No	No
ALU0272	Gustavo Gomes Mendes	CUR01	4	19	Jardim Alexandrina	Regular in-person	No	No
ALU0273	Thiago Silva Teixeira	CUR01	4	27	Vila Jaiara	Regular in-person	No	Yes
ALU0274	Matheus Oliveira Lima	CUR01	2	23	Setor Central	Regular in-person	No	No
ALU0275	Thiago Souza Ribeiro	CUR01	2	17	Residencial das Rosas	Regular in-person	No	Yes
ALU0276	Bruno Araújo Teixeira	CUR01	6	17	Filostro Machado	Regular in-person	No	No
ALU0277	Isabela Costa Mendes	CUR01	1	21	São Carlos	Regular in-person	No	No
ALU0278	Maria Mendes Carvalho	CUR01	5	29	Filostro Machado	Regular in-person	No	No
ALU0279	Lucas Araújo Martins	CUR01	2	18	São Carlos	Regular in-person	No	Yes
ALU0280	Carlos Araújo Ferreira	CUR01	7	23	Boa Vista	Regular hybrid	No	No
ALU0281	Amanda Barbosa Silva	CUR01	1	25	Setor Industrial	Regular in-person	No	No
ALU0282	Mariana Barbosa Rocha	CUR01	8	17	Anápolis City	Regular in-person	Yes	No
ALU0283	Renato Carvalho Oliveira	CUR01	7	26	Recanto do Sol	Regular in-person	No	No
ALU0284	Gabriel Souza Carvalho	CUR01	6	24	Recanto do Sol	Regular in-person	No	No
ALU0285	Felipe Martins Rodrigues	CUR01	5	27	Residencial das Rosas	Regular in-person	No	No
ALU0286	Lucas Gomes Almeida	CUR01	2	23	Anápolis City	Regular hybrid	No	No
ALU0287	Rafael Mendes Gomes	CUR01	5	25	Residencial das Rosas	Regular in-person	No	No
ALU0288	Lucas Pereira Rodrigues	CUR01	2	20	Filostro Machado	Regular in-person	No	No
ALU0289	Luana Silva Carvalho	CUR01	4	19	Paraíso	Regular hybrid	No	No
ALU0290	Mariana Pereira Pereira	CUR01	4	18	Jardim Alexandrina	Regular in-person	No	No
ALU0291	Amanda Ferreira Costa	CUR01	1	20	Recanto do Sol	Regular in-person	No	No
ALU0292	Felipe Martins Ferreira	CUR01	7	17	Recanto do Sol	Regular in-person	No	No
ALU0293	Thiago Martins Gomes	CUR01	8	17	Maracanã	Regular hybrid	No	No
ALU0294	Bruno Teixeira Martins	CUR01	5	21	Vila Jaiara	Regular in-person	No	No
ALU0295	Larissa Rodrigues Lima	CUR01	4	17	Boa Vista	Regular in-person	No	No
ALU0296	Lucas Silva Oliveira	CUR01	8	20	Setor Industrial	Regular in-person	No	No
ALU0297	Maria Ribeiro Gomes	CUR01	8	17	Setor Central	Regular in-person	Yes	No
ALU0298	Isabela Almeida Oliveira	CUR01	8	23	Setor Industrial	Regular in-person	No	No
ALU0299	Eduardo Mendes Mendes	CUR01	2	20	Setor Industrial	EJA	Yes	No
ALU0300	Camila Costa Silva	CUR01	7	22	Paraíso	Regular in-person	No	No
ALU0301	Letícia Pereira Ferreira	CUR01	1	21	Setor Industrial	Regular in-person	No	No
ALU0302	Bruno Rocha Ferreira	CUR01	8	28	Paraíso	Regular in-person	Yes	No
ALU0303	Isabela Silva Barbosa	CUR01	5	20	Jundiaí	Regular in-person	No	Yes
ALU0304	João Lima Oliveira	CUR01	8	17	Jardim Alexandrina	Regular in-person	No	Yes
ALU0305	Luana Barbosa Ribeiro	CUR01	3	25	Vila Jaiara	Regular in-person	No	No
ALU0306	João Rocha Ribeiro	CUR01	5	25	Residencial das Rosas	Regular in-person	Yes	No
ALU0307	Camila Teixeira Rocha	CUR01	4	22	Recanto do Sol	Regular in-person	No	No
ALU0308	Gabriel Rocha Teixeira	CUR01	1	24	Boa Vista	EJA	No	No
ALU0309	Julia Ribeiro Lima	CUR01	1	22	Jardim Alexandrina	Regular in-person	Yes	No
ALU0310	Bruno Rodrigues Almeida	CUR01	5	25	São Carlos	Regular in-person	No	No
ALU0311	Felipe Teixeira Oliveira	CUR01	4	22	Recanto do Sol	Regular in-person	No	No
ALU0312	Ana Mendes Santos	CUR01	8	17	Recanto do Sol	Regular in-person	Yes	Yes
ALU0313	Ana Ribeiro Martins	CUR01	8	25	Maracanã	Regular in-person	No	No
ALU0314	Letícia Oliveira Almeida	CUR01	1	17	Setor Central	Regular in-person	No	No
ALU0315	Matheus Gomes Santos	CUR01	2	22	Anápolis City	Regular hybrid	No	No
ALU0316	Matheus Pereira Mendes	CUR01	8	23	Paraíso	Regular in-person	No	No
ALU0317	Ana Rocha Rodrigues	CUR01	8	26	São Carlos	Regular hybrid	No	No
ALU0318	Gustavo Teixeira Rodrigues	CUR01	4	21	Anápolis City	Regular in-person	No	Yes
ALU0319	Larissa Silva Teixeira	CUR01	3	20	Vila Jaiara	EJA	No	No
ALU0320	Felipe Oliveira Mendes	CUR01	7	26	Residencial das Rosas	Regular hybrid	No	No
ALU0321	Eduardo Souza Mendes	CUR01	2	24	Maracanã	EJA	Yes	No
ALU0322	Bruno Araújo Nunes	CUR01	5	27	Vila Jaiara	Regular in-person	No	No
ALU0323	Victor Teixeira Silva	CUR01	4	21	Recanto do Sol	Regular in-person	No	No
ALU0324	Pedro Oliveira Pereira	CUR01	6	18	Paraíso	Regular in-person	No	No
ALU0325	Luana Rodrigues Carvalho	CUR01	6	23	São Carlos	EJA	No	No
ALU0326	Matheus Araújo Costa	CUR01	7	17	Setor Central	Regular in-person	No	No
ALU0327	Matheus Araújo Silva	CUR01	1	21	Anápolis City	Regular in-person	No	No
ALU0328	Pedro Rocha Teixeira	CUR01	2	18	Setor Industrial	Regular in-person	Yes	Yes
ALU0329	Camila Teixeira Pereira	CUR01	1	26	Jibran El Hadj	EJA	No	No
ALU0330	Rafael Gomes Lima	CUR01	6	23	Residencial das Rosas	Regular in-person	No	No
ALU0331	Julia Barbosa Oliveira	CUR01	4	23	Maracanã	Regular in-person	No	No
ALU0332	Larissa Barbosa Araújo	CUR01	7	24	Vila Jaiara	Regular in-person	Yes	No
ALU0333	Letícia Mendes Ferreira	CUR01	1	20	Maracanã	Regular in-person	No	No
ALU0334	Lucas Souza Araújo	CUR01	2	32	Setor Central	Regular in-person	No	No
ALU0335	Ana Martins Ribeiro	CUR01	5	17	Boa Vista	Regular hybrid	No	No
ALU0336	Letícia Santos Carvalho	CUR01	5	18	Paraíso	Regular in-person	No	No
ALU0337	Matheus Rocha Araújo	CUR01	3	19	Setor Industrial	Regular in-person	No	No
ALU0338	Thiago Carvalho Mendes	CUR01	1	22	Jundiaí	Regular hybrid	No	No
ALU0339	João Mendes Almeida	CUR01	3	21	Residencial das Rosas	Regular in-person	No	No
ALU0340	Amanda Rodrigues Teixeira	CUR01	1	22	Maracanã	Regular in-person	No	No
ALU0341	Camila Gomes Rodrigues	CUR01	4	17	Anápolis City	Regular in-person	Yes	No
ALU0342	Eduardo Martins Araújo	CUR01	2	25	Recanto do Sol	Regular hybrid	Yes	No
ALU0343	Felipe Rodrigues Ribeiro	CUR01	4	25	Vila Jaiara	Regular in-person	No	No
ALU0344	Amanda Ribeiro Araújo	CUR01	4	21	Setor Central	Regular in-person	No	No
ALU0345	Isabela Almeida Lima	CUR01	7	18	Boa Vista	Regular in-person	No	No
ALU0346	Renato Silva Souza	CUR01	7	17	Jardim Alexandrina	Regular in-person	No	No
ALU0347	Gustavo Barbosa Rodrigues	CUR01	3	18	Anápolis City	Regular in-person	No	No
ALU0348	Mariana Costa Silva	CUR01	7	17	São Carlos	Regular hybrid	Yes	No
ALU0349	Gustavo Lima Lima	CUR01	8	20	Jibran El Hadj	Regular in-person	No	No
ALU0350	Eduardo Lima Rocha	CUR01	8	21	Setor Central	Regular in-person	No	No
ALU0351	Camila Barbosa Rodrigues	CUR01	5	24	Setor Central	Regular in-person	No	No
ALU0352	Gustavo Gomes Almeida	CUR01	2	22	Recanto do Sol	Regular in-person	No	Yes
ALU0353	Bruno Almeida Carvalho	CUR01	3	17	Setor Industrial	Regular in-person	No	No
ALU0354	Letícia Teixeira Rodrigues	CUR01	7	23	São Carlos	Regular in-person	No	No
ALU0355	Amanda Oliveira Gomes	CUR01	5	31	Paraíso	Regular hybrid	No	No
ALU0356	Luana Carvalho Rocha	CUR01	8	22	Setor Central	Regular in-person	Yes	No
ALU0357	Larissa Martins Lima	CUR01	8	22	Residencial das Rosas	Regular in-person	No	No
ALU0358	Victor Araújo Rodrigues	CUR01	7	18	Boa Vista	Regular in-person	No	No
ALU0359	Pedro Barbosa Mendes	CUR01	4	20	São Carlos	EJA	No	Yes
ALU0360	Letícia Santos Souza	CUR01	2	24	Vila Jaiara	Regular hybrid	Yes	No
ALU0361	Beatriz Araújo Gomes	CUR01	2	17	Setor Central	Regular in-person	No	No
ALU0362	Gustavo Ferreira Costa	CUR01	4	20	São Carlos	EJA	No	No
ALU0363	Luana Souza Ribeiro	CUR01	8	20	Setor Central	Regular in-person	No	No
ALU0364	João Souza Ferreira	CUR01	1	19	Paraíso	EJA	No	No
ALU0365	Maria Lima Martins	CUR01	2	17	Vivian Parque	Regular in-person	Yes	No
ALU0366	Isabela Nunes Barbosa	CUR01	3	19	Vila Jaiara	Regular hybrid	No	No
ALU0367	Gabriel Carvalho Martins	CUR01	8	25	Jibran El Hadj	Regular in-person	No	No
ALU0368	Amanda Almeida Silva	CUR01	4	22	Jundiaí	EJA	No	No
ALU0369	Julia Almeida Costa	CUR01	3	25	São Carlos	Regular in-person	No	No
ALU0370	Maria Pereira Costa	CUR01	6	28	Setor Industrial	Regular in-person	No	No
ALU0371	Maria Costa Almeida	CUR01	7	23	Setor Industrial	Regular in-person	No	No
ALU0372	Renato Ferreira Nunes	CUR01	8	22	Paraíso	Regular in-person	No	No
ALU0373	Felipe Barbosa Silva	CUR01	6	20	Vila Jaiara	Regular in-person	No	No
ALU0374	Luana Lima Santos	CUR01	3	18	Vivian Parque	Regular in-person	Yes	No
ALU0375	Maria Martins Martins	CUR01	6	24	Residencial das Rosas	Regular hybrid	No	No
ALU0376	Eduardo Rocha Rocha	CUR01	8	18	Jibran El Hadj	Regular in-person	No	No
ALU0377	Bruno Silva Oliveira	CUR01	1	33	São Carlos	Regular in-person	Yes	No
ALU0378	Carlos Almeida Pereira	CUR01	6	27	Anápolis City	Regular in-person	No	No
ALU0379	Renato Costa Mendes	CUR01	7	27	Vivian Parque	Regular hybrid	No	No
ALU0380	Pedro Teixeira Pereira	CUR01	1	29	Vila Jaiara	Regular in-person	No	Yes
ALU0381	Pedro Lima Almeida	CUR01	7	26	Setor Industrial	Regular in-person	No	No
ALU0382	Gabriel Barbosa Rodrigues	CUR01	2	19	Anápolis City	Regular in-person	No	No
ALU0383	João Martins Mendes	CUR01	5	21	Filostro Machado	Regular in-person	No	No
ALU0384	Larissa Lima Rocha	CUR01	2	24	Anápolis City	Regular in-person	No	No
ALU0385	Amanda Nunes Rocha	CUR01	5	28	Boa Vista	Regular hybrid	No	No
ALU0386	João Mendes Oliveira	CUR01	6	23	Paraíso	Regular in-person	No	No
ALU0387	Camila Nunes Lima	CUR01	3	17	Jardim Alexandrina	Regular in-person	No	No
ALU0388	Ana Costa Rodrigues	CUR01	8	22	Vivian Parque	Regular in-person	No	No
ALU0389	Eduardo Barbosa Gomes	CUR01	7	21	Maracanã	Regular in-person	No	No
ALU0390	Renato Lima Teixeira	CUR01	7	19	Boa Vista	Regular in-person	Yes	No
ALU0391	Letícia Rocha Martins	CUR01	7	28	Paraíso	EJA	No	No
ALU0392	Gabriel Gomes Barbosa	CUR01	5	24	Vila Jaiara	Regular in-person	No	No
ALU0393	Beatriz Costa Gomes	CUR01	4	24	Jundiaí	Regular in-person	No	No
ALU0394	Gabriel Oliveira Gomes	CUR01	4	18	Maracanã	Regular hybrid	No	No
ALU0395	Mariana Souza Martins	CUR01	3	27	Jundiaí	Regular in-person	No	No
ALU0396	Amanda Teixeira Carvalho	CUR01	5	20	Jibran El Hadj	Regular in-person	No	No
ALU0397	Carlos Nunes Martins	CUR01	3	25	Vila Jaiara	Regular in-person	No	No
ALU0398	Bruno Rocha Oliveira	CUR01	6	23	Vivian Parque	Regular in-person	No	No
ALU0399	Gustavo Martins Rodrigues	CUR01	8	17	Paraíso	Regular in-person	Yes	No
ALU0400	Beatriz Rodrigues Souza	CUR01	4	21	Anápolis City	Regular in-person	No	No
ALU0401	Gustavo Ribeiro Almeida	CUR01	3	17	Setor Central	Regular in-person	Yes	No
ALU0402	Julia Nunes Santos	CUR01	3	22	Residencial das Rosas	Regular in-person	No	No
ALU0403	Mariana Nunes Gomes	CUR01	1	17	Setor Central	Regular in-person	No	No
ALU0404	Isabela Nunes Almeida	CUR01	3	23	Boa Vista	Regular in-person	No	No
ALU0405	Amanda Martins Rocha	CUR01	8	30	Jibran El Hadj	Regular in-person	No	No
ALU0406	Gabriel Oliveira Santos	CUR01	4	25	Vivian Parque	Regular in-person	No	No
ALU0407	Larissa Teixeira Ferreira	CUR01	4	20	Residencial das Rosas	Regular in-person	No	No
ALU0408	Maria Silva Martins	CUR01	6	17	Maracanã	Regular in-person	No	No
ALU0409	Beatriz Costa Pereira	CUR01	4	20	Filostro Machado	EJA	No	No
ALU0410	Thiago Oliveira Martins	CUR01	8	18	Boa Vista	Regular in-person	No	No
ALU0411	Ana Ribeiro Silva	CUR01	4	18	Jundiaí	Regular in-person	No	No
ALU0412	Luana Silva Teixeira	CUR01	6	19	Setor Industrial	Regular in-person	No	No
ALU0413	Carlos Rocha Rodrigues	CUR01	2	23	São Carlos	Regular in-person	Yes	No
ALU0414	Camila Pereira Silva	CUR01	5	18	Jibran El Hadj	Regular in-person	No	No
ALU0415	Ana Mendes Rocha	CUR01	8	20	Setor Central	Regular in-person	No	No
ALU0416	Victor Nunes Barbosa	CUR01	8	23	Boa Vista	Regular in-person	No	No
ALU0417	Gabriel Silva Oliveira	CUR01	5	26	Anápolis City	Regular in-person	No	No
ALU0418	Beatriz Souza Santos	CUR01	6	25	Filostro Machado	Regular in-person	No	No
ALU0419	Larissa Carvalho Souza	CUR01	5	17	Filostro Machado	Regular hybrid	No	Yes
ALU0420	Letícia Mendes Santos	CUR01	6	20	Jardim Alexandrina	Regular in-person	No	No
ALU0421	Eduardo Santos Silva	CUR01	3	26	Setor Industrial	Regular in-person	No	No
ALU0422	Gabriel Rodrigues Costa	CUR01	4	26	Jundiaí	Regular in-person	No	No
ALU0423	Thiago Lima Gomes	CUR01	6	23	Vila Jaiara	Regular in-person	No	No
ALU0424	Beatriz Santos Mendes	CUR01	6	19	Recanto do Sol	Regular in-person	No	No
ALU0425	Rafael Santos Teixeira	CUR01	8	18	São Carlos	Regular in-person	No	No
ALU0426	Camila Santos Carvalho	CUR01	5	25	Jibran El Hadj	Regular in-person	Yes	No
ALU0427	Rafael Martins Rocha	CUR01	4	28	Maracanã	Regular in-person	No	No
ALU0428	Carlos Ferreira Barbosa	CUR01	2	17	Filostro Machado	Regular in-person	No	No
ALU0429	Pedro Santos Teixeira	CUR01	4	26	Vivian Parque	Regular in-person	No	No
ALU0430	Luana Ferreira Mendes	CUR01	1	17	Vila Jaiara	Regular hybrid	No	No
ALU0431	Larissa Araújo Lima	CUR01	2	27	Setor Industrial	Regular in-person	No	No
ALU0432	Carlos Araújo Silva	CUR01	2	20	Filostro Machado	Regular in-person	No	No
ALU0433	Bruno Araújo Santos	CUR01	8	25	Residencial das Rosas	EJA	No	No
ALU0434	Julia Martins Martins	CUR01	7	20	Anápolis City	Regular in-person	No	Yes
ALU0435	Victor Rodrigues Costa	CUR01	6	23	Setor Industrial	Regular in-person	No	No
ALU0436	Rafael Mendes Ribeiro	CUR01	2	22	Vivian Parque	Regular in-person	No	No
ALU0437	Mariana Gomes Souza	CUR01	2	30	Recanto do Sol	Regular hybrid	No	No
ALU0438	Victor Costa Mendes	CUR01	1	30	Anápolis City	Regular in-person	No	No
ALU0439	Pedro Costa Martins	CUR01	8	17	Residencial das Rosas	Regular in-person	Yes	No
ALU0440	Mariana Souza Teixeira	CUR01	5	19	Setor Industrial	Regular in-person	Yes	No
ALU0441	Camila Silva Ribeiro	CUR01	6	19	Recanto do Sol	Regular in-person	No	No
ALU0442	Gustavo Costa Mendes	CUR01	3	17	Jardim Alexandrina	Regular in-person	No	No
ALU0443	Thiago Gomes Silva	CUR01	1	22	Paraíso	Regular in-person	Yes	No
ALU0444	Renato Gomes Costa	CUR01	8	20	Setor Industrial	Regular in-person	No	No
ALU0445	Bruno Mendes Ferreira	CUR01	8	33	Vivian Parque	Regular in-person	No	No
ALU0446	Mariana Teixeira Rocha	CUR01	2	23	Jibran El Hadj	Regular in-person	No	No
ALU0447	Beatriz Rocha Ferreira	CUR01	1	22	Anápolis City	Regular in-person	Yes	No
ALU0448	Pedro Carvalho Santos	CUR01	5	23	Anápolis City	Regular in-person	No	No
ALU0449	Bruno Souza Almeida	CUR01	8	26	Setor Industrial	EJA	No	No
ALU0450	Beatriz Nunes Santos	CUR01	5	27	São Carlos	Regular in-person	No	No
ALU0451	Carlos Nunes Souza	CUR01	4	17	Filostro Machado	Regular in-person	No	Yes
ALU0452	Camila Barbosa Costa	CUR01	4	26	Filostro Machado	Regular in-person	No	No
ALU0453	Renato Costa Pereira	CUR01	8	18	Vila Jaiara	Regular in-person	No	Yes
ALU0454	Victor Teixeira Martins	CUR01	6	17	Jundiaí	Regular hybrid	No	Yes
ALU0455	Felipe Ferreira Gomes	CUR01	8	24	Anápolis City	Regular in-person	No	No
ALU0456	João Barbosa Carvalho	CUR01	6	17	Vivian Parque	Regular in-person	No	No
ALU0457	Julia Teixeira Barbosa	CUR01	7	19	Jundiaí	EJA	No	No
ALU0458	Gustavo Rocha Martins	CUR01	2	24	Jardim Alexandrina	Regular in-person	No	No
ALU0459	Camila Oliveira Rocha	CUR01	7	25	Filostro Machado	Regular in-person	No	Yes
ALU0460	Eduardo Santos Pereira	CUR01	5	20	Jardim Alexandrina	Regular hybrid	No	No
ALU0461	Bruno Teixeira Almeida	CUR01	1	22	Boa Vista	Regular in-person	No	No
ALU0462	João Oliveira Barbosa	CUR01	6	26	Jundiaí	Regular in-person	No	No
ALU0463	Bruno Lima Silva	CUR01	6	17	São Carlos	EJA	No	No
ALU0464	Beatriz Costa Silva	CUR01	3	19	Boa Vista	Regular in-person	No	No
ALU0465	Eduardo Mendes Ferreira	CUR01	5	19	Anápolis City	Regular in-person	No	No
ALU0466	Mariana Ferreira Lima	CUR01	6	17	Setor Industrial	Regular in-person	Yes	Yes
ALU0467	Beatriz Barbosa Teixeira	CUR01	3	22	Anápolis City	Regular in-person	No	Yes
ALU0468	Felipe Nunes Silva	CUR01	2	18	Vivian Parque	Regular in-person	No	No
ALU0469	Camila Carvalho Carvalho	CUR01	6	19	Jibran El Hadj	Regular in-person	No	No
ALU0470	João Araújo Almeida	CUR01	2	30	Jardim Alexandrina	EJA	No	No
ALU0471	Matheus Carvalho Rocha	CUR01	3	20	Setor Industrial	Regular in-person	Yes	No
ALU0472	Amanda Almeida Santos	CUR01	7	21	Setor Central	Regular in-person	No	No
ALU0473	Maria Araújo Nunes	CUR01	6	20	Recanto do Sol	Regular in-person	No	No
ALU0474	Letícia Ribeiro Rodrigues	CUR01	2	17	São Carlos	Regular hybrid	No	No
ALU0475	Ana Rodrigues Barbosa	CUR01	8	22	Paraíso	Regular in-person	No	No
ALU0476	Beatriz Lima Costa	CUR01	4	21	Maracanã	Regular in-person	No	No
ALU0477	João Costa Almeida	CUR01	3	19	Jibran El Hadj	Regular in-person	No	No
ALU0478	Isabela Oliveira Ribeiro	CUR01	4	21	Paraíso	EJA	No	No
ALU0479	Felipe Silva Mendes	CUR01	4	20	Setor Central	Regular in-person	No	No
ALU0480	Maria Souza Pereira	CUR01	3	17	Recanto do Sol	Regular in-person	No	No
ALU0481	Larissa Silva Lima	CUR01	2	17	Vila Jaiara	Regular in-person	No	No
ALU0482	Rafael Mendes Martins	CUR01	8	22	Setor Industrial	Regular in-person	No	No
ALU0483	Victor Gomes Mendes	CUR01	5	22	Jibran El Hadj	Regular in-person	No	Yes
ALU0484	Gabriel Teixeira Teixeira	CUR01	2	20	São Carlos	Regular in-person	No	No
ALU0485	Carlos Almeida Almeida	CUR01	3	23	Jibran El Hadj	Regular in-person	No	No
ALU0486	Carlos Lima Gomes	CUR01	4	30	Anápolis City	Regular in-person	No	No
ALU0487	João Ribeiro Santos	CUR01	8	18	Filostro Machado	Regular in-person	No	No
ALU0488	Camila Souza Costa	CUR01	4	21	Setor Industrial	Regular in-person	No	No
ALU0489	Carlos Costa Nunes	CUR01	6	20	Maracanã	Regular in-person	No	No
ALU0490	Gabriel Araújo Barbosa	CUR01	4	22	Vila Jaiara	EJA	Yes	No
ALU0491	Victor Souza Rocha	CUR01	2	17	Filostro Machado	Regular hybrid	No	No
ALU0492	Amanda Araújo Martins	CUR01	7	23	Jardim Alexandrina	Regular hybrid	No	No
ALU0493	Thiago Ribeiro Carvalho	CUR01	3	22	Recanto do Sol	Regular in-person	No	No
ALU0494	Victor Carvalho Costa	CUR01	5	17	Paraíso	Regular in-person	No	No
ALU0495	Thiago Rodrigues Teixeira	CUR01	4	18	Setor Industrial	EJA	No	No
ALU0496	Lucas Nunes Mendes	CUR01	4	28	Anápolis City	Regular hybrid	No	No
ALU0497	Maria Mendes Mendes	CUR01	6	19	Vivian Parque	Regular in-person	No	No
ALU0498	Thiago Pereira Souza	CUR01	3	23	Jardim Alexandrina	Regular in-person	No	No
ALU0499	Bruno Almeida Ferreira	CUR01	3	20	Vila Jaiara	Regular in-person	No	No
ALU0500	Mariana Rocha Mendes	CUR01	7	22	Jibran El Hadj	EJA	No	No
ALU0501	Isabela Ribeiro Barbosa	CUR01	7	28	Jibran El Hadj	Regular in-person	No	No
ALU0502	Rafael Almeida Teixeira	CUR01	1	22	Boa Vista	Regular in-person	No	No
ALU0503	Gustavo Lima Gomes	CUR01	7	24	Paraíso	Regular in-person	No	No
ALU0504	Pedro Martins Almeida	CUR01	5	17	Jundiaí	Regular in-person	No	No
ALU0505	Victor Gomes Silva	CUR01	6	22	Recanto do Sol	Regular in-person	Yes	No
ALU0506	Rafael Teixeira Lima	CUR01	6	23	Vivian Parque	EJA	Yes	No
ALU0507	Matheus Teixeira Costa	CUR01	3	18	Paraíso	Regular hybrid	No	No
ALU0508	Bruno Oliveira Oliveira	CUR01	5	26	Anápolis City	Regular in-person	No	No
ALU0509	Matheus Almeida Pereira	CUR01	8	17	Setor Industrial	Regular hybrid	No	No
ALU0510	Lucas Mendes Teixeira	CUR01	6	23	Vila Jaiara	Regular in-person	No	No
ALU0511	Lucas Mendes Araújo	CUR01	6	17	São Carlos	Regular in-person	No	No
ALU0512	João Mendes Mendes	CUR01	2	17	Jundiaí	Regular in-person	No	Yes
ALU0513	Carlos Pereira Nunes	CUR01	2	21	Setor Central	Regular hybrid	No	No
ALU0514	Mariana Nunes Carvalho	CUR01	2	27	Maracanã	Regular in-person	No	No
ALU0515	Eduardo Lima Gomes	CUR01	2	22	Residencial das Rosas	Regular in-person	No	No
ALU0516	Matheus Mendes Almeida	CUR01	6	22	Boa Vista	Regular hybrid	No	No
ALU0517	Luana Carvalho Santos	CUR01	6	19	Boa Vista	Regular hybrid	No	No
ALU0518	João Ferreira Carvalho	CUR01	1	17	Setor Industrial	Regular in-person	No	No
ALU0519	Amanda Silva Gomes	CUR01	5	20	Recanto do Sol	Regular in-person	No	No
ALU0520	Rafael Lima Oliveira	CUR01	3	30	Vila Jaiara	Regular in-person	No	No
ALU0521	Felipe Costa Carvalho	CUR01	5	17	Maracanã	Regular hybrid	No	No
ALU0522	Renato Mendes Barbosa	CUR01	4	29	Residencial das Rosas	Regular in-person	No	No
ALU0523	Ana Araújo Lima	CUR01	5	18	Paraíso	Regular hybrid	No	No
ALU0524	Carlos Almeida Araújo	CUR01	2	25	Jibran El Hadj	Regular in-person	No	No
ALU0525	Maria Barbosa Rodrigues	CUR01	8	25	Setor Industrial	Regular in-person	Yes	No
ALU0526	Maria Mendes Souza	CUR01	5	25	Jibran El Hadj	Regular in-person	No	No
ALU0527	Rafael Almeida Almeida	CUR01	2	21	Boa Vista	EJA	No	No
ALU0528	Ana Rocha Costa	CUR01	3	20	Residencial das Rosas	Regular in-person	No	No
ALU0529	Bruno Almeida Nunes	CUR01	2	27	Vivian Parque	Regular in-person	No	No
ALU0530	Isabela Nunes Nunes	CUR01	8	23	Vila Jaiara	Regular in-person	No	No
ALU0531	Mariana Silva Ribeiro	CUR01	3	26	Vivian Parque	Regular hybrid	No	No
ALU0532	Carlos Barbosa Nunes	CUR01	2	17	São Carlos	Regular hybrid	Yes	Yes
ALU0533	Luana Almeida Pereira	CUR01	7	17	Jibran El Hadj	Regular in-person	No	No
ALU0534	Amanda Oliveira Mendes	CUR01	6	31	São Carlos	Regular hybrid	No	No
ALU0535	Luana Ferreira Pereira	CUR01	1	25	Setor Central	EJA	No	No
ALU0536	Ana Nunes Lima	CUR01	3	24	São Carlos	Regular in-person	Yes	No
ALU0537	Amanda Almeida Mendes	CUR01	4	29	Vivian Parque	Regular in-person	No	No
ALU0538	Felipe Carvalho Carvalho	CUR01	2	19	Setor Industrial	Regular in-person	No	No
ALU0539	Letícia Rodrigues Almeida	CUR01	7	21	Jardim Alexandrina	Regular in-person	No	No
ALU0540	Renato Oliveira Ribeiro	CUR01	4	27	Filostro Machado	Regular in-person	No	No
ALU0541	Bruno Costa Silva	CUR01	6	17	Paraíso	Regular in-person	Yes	No
ALU0542	Ana Costa Nunes	CUR01	4	17	São Carlos	Regular in-person	No	No
ALU0543	Rafael Ribeiro Silva	CUR01	2	17	Boa Vista	Regular in-person	No	No
ALU0544	Camila Carvalho Pereira	CUR01	5	19	Maracanã	Regular in-person	No	No
ALU0545	Camila Gomes Silva	CUR01	4	22	São Carlos	Regular in-person	No	No
ALU0546	João Silva Lima	CUR01	2	21	Jundiaí	EJA	No	No
ALU0547	Isabela Ribeiro Rocha	CUR01	6	32	Paraíso	Regular in-person	Yes	No
ALU0548	Luana Lima Nunes	CUR01	1	19	Jundiaí	Regular in-person	No	No
ALU0549	Lucas Pereira Nunes	CUR01	1	20	Jardim Alexandrina	Regular in-person	No	No
ALU0550	João Carvalho Silva	CUR01	5	20	Residencial das Rosas	Regular in-person	No	No
ALU0551	Amanda Santos Martins	CUR01	4	25	Boa Vista	Regular in-person	No	No
ALU0552	Gustavo Ribeiro Araújo	CUR01	4	17	Jibran El Hadj	Regular in-person	Yes	No
ALU0553	Eduardo Rodrigues Rocha	CUR01	8	24	Paraíso	Regular in-person	Yes	No
ALU0554	Bruno Nunes Rodrigues	CUR01	3	21	Jardim Alexandrina	Regular in-person	No	No
ALU0555	Bruno Souza Araújo	CUR01	3	19	Recanto do Sol	Regular in-person	No	No
ALU0556	Camila Araújo Teixeira	CUR01	6	17	Vila Jaiara	Regular in-person	No	No
ALU0557	Amanda Araújo Mendes	CUR01	4	23	Filostro Machado	EJA	Yes	No
ALU0558	João Rodrigues Ferreira	CUR01	1	18	Jardim Alexandrina	Regular in-person	Yes	No
ALU0559	Felipe Santos Souza	CUR01	4	29	São Carlos	Regular in-person	Yes	No
ALU0560	Thiago Martins Souza	CUR01	6	25	Setor Central	Regular in-person	No	No
ALU0561	Beatriz Souza Martins	CUR01	8	24	Recanto do Sol	Regular in-person	No	No
ALU0562	Bruno Pereira Gomes	CUR01	4	21	Maracanã	Regular hybrid	No	No
ALU0563	Isabela Oliveira Carvalho	CUR01	2	26	Maracanã	Regular in-person	No	No
ALU0564	Mariana Costa Nunes	CUR01	2	20	Residencial das Rosas	Regular hybrid	No	No
ALU0565	Larissa Araújo Ferreira	CUR01	7	20	Recanto do Sol	Regular in-person	No	No
ALU0566	Mariana Rodrigues Santos	CUR01	6	27	Jardim Alexandrina	Regular in-person	No	No
ALU0567	Beatriz Costa Ribeiro	CUR01	1	18	Anápolis City	Regular in-person	No	No
ALU0568	Gabriel Souza Nunes	CUR01	7	25	Setor Industrial	Regular in-person	No	No
ALU0569	Julia Carvalho Almeida	CUR01	1	17	Jundiaí	Regular in-person	No	No
ALU0570	Isabela Lima Lima	CUR01	4	26	Anápolis City	Regular in-person	No	No
ALU0571	Eduardo Rodrigues Barbosa	CUR01	8	22	Vivian Parque	Regular in-person	Yes	No
ALU0572	Rafael Araújo Lima	CUR01	2	24	Vivian Parque	EJA	No	No
ALU0573	Gustavo Gomes Silva	CUR01	3	21	Anápolis City	Regular in-person	No	No
ALU0574	Thiago Pereira Gomes	CUR01	5	24	Filostro Machado	Regular in-person	No	No
ALU0575	Ana Mendes Oliveira	CUR01	4	24	Residencial das Rosas	Regular in-person	No	No
ALU0576	Eduardo Gomes Teixeira	CUR01	5	21	Residencial das Rosas	EJA	No	Yes
ALU0577	Victor Souza Araújo	CUR01	8	23	Vila Jaiara	Regular in-person	No	No
ALU0578	Lucas Mendes Mendes	CUR01	2	22	Maracanã	Regular hybrid	No	No
ALU0579	Renato Barbosa Ferreira	CUR01	1	17	Residencial das Rosas	Regular in-person	No	No
ALU0580	Luana Carvalho Carvalho	CUR01	3	17	Recanto do Sol	Regular in-person	No	No
ALU0581	Lucas Souza Mendes	CUR01	3	19	Maracanã	Regular hybrid	No	No
ALU0582	Matheus Barbosa Ferreira	CUR01	2	18	Setor Central	Regular in-person	Yes	No
ALU0583	Luana Araújo Araújo	CUR01	1	27	Jardim Alexandrina	Regular in-person	Yes	No
ALU0584	Renato Almeida Pereira	CUR01	1	24	Jardim Alexandrina	Regular in-person	No	No
ALU0585	Thiago Rodrigues Santos	CUR01	7	22	Jardim Alexandrina	Regular hybrid	No	No
ALU0586	Julia Araújo Rodrigues	CUR01	2	17	Recanto do Sol	Regular hybrid	No	No
ALU0587	Isabela Costa Almeida	CUR01	8	26	Vivian Parque	Regular hybrid	No	No
ALU0588	Renato Pereira Gomes	CUR01	4	20	Recanto do Sol	Regular in-person	No	No
ALU0589	Isabela Almeida Gomes	CUR01	7	24	Setor Central	Regular in-person	No	No
ALU0590	Gabriel Teixeira Almeida	CUR01	1	23	Jundiaí	Regular in-person	No	No
ALU0591	Bruno Mendes Teixeira	CUR01	6	19	Paraíso	Regular in-person	No	No
ALU0592	João Carvalho Rocha	CUR01	6	26	São Carlos	Regular in-person	No	No
ALU0593	Larissa Ferreira Martins	CUR01	5	26	Paraíso	Regular in-person	No	No
ALU0594	Felipe Lima Gomes	CUR01	4	17	Filostro Machado	Regular hybrid	No	No
ALU0595	Letícia Almeida Rodrigues	CUR01	4	25	Residencial das Rosas	Regular in-person	No	No
ALU0596	Carlos Rodrigues Oliveira	CUR01	1	25	Filostro Machado	EJA	Yes	No
ALU0597	Carlos Barbosa Silva	CUR01	7	21	Anápolis City	Regular hybrid	No	No
ALU0598	Julia Oliveira Almeida	CUR01	1	24	Vivian Parque	Regular in-person	No	No
ALU0599	Luana Gomes Barbosa	CUR01	7	21	Jundiaí	Regular hybrid	No	No
ALU0600	Julia Souza Ribeiro	CUR01	1	22	Boa Vista	Regular in-person	No	No
ALU0601	Bruno Costa Teixeira	CUR01	6	17	Anápolis City	Regular in-person	No	No
ALU0602	Renato Gomes Mendes	CUR01	5	29	Vila Jaiara	Regular in-person	No	No
ALU0603	Larissa Rocha Rocha	CUR01	8	17	Jundiaí	Regular in-person	No	No
ALU0604	Felipe Martins Pereira	CUR01	4	33	Residencial das Rosas	Regular hybrid	No	No
ALU0605	Letícia Carvalho Almeida	CUR01	3	24	Paraíso	Regular in-person	No	No
ALU0606	Felipe Carvalho Mendes	CUR01	3	19	Maracanã	Regular in-person	No	No
ALU0607	Larissa Silva Costa	CUR01	3	17	Maracanã	Regular in-person	No	Yes
ALU0608	Lucas Costa Araújo	CUR01	5	18	Maracanã	Regular in-person	No	Yes
ALU0609	Camila Rocha Carvalho	CUR01	3	24	Setor Central	Regular in-person	Yes	No
ALU0610	Letícia Teixeira Mendes	CUR01	3	25	Paraíso	Regular in-person	No	No
ALU0611	João Rocha Pereira	CUR01	3	17	Setor Central	EJA	No	Yes
ALU0612	Luana Lima Oliveira	CUR01	3	29	Setor Industrial	Regular in-person	No	No
ALU0613	Eduardo Teixeira Rodrigues	CUR01	1	18	Maracanã	Regular in-person	No	No
ALU0614	Matheus Ferreira Lima	CUR01	7	28	Paraíso	Regular in-person	No	No
ALU0615	Carlos Rocha Rodrigues	CUR01	3	27	Vivian Parque	Regular in-person	No	No
ALU0616	Pedro Barbosa Rodrigues	CUR01	3	30	Jardim Alexandrina	Regular in-person	No	No
ALU0617	Larissa Silva Rocha	CUR01	7	18	Boa Vista	Regular in-person	No	No
ALU0618	Luana Lima Barbosa	CUR01	2	27	Filostro Machado	Regular in-person	Yes	No
ALU0619	Camila Araújo Souza	CUR01	2	22	Anápolis City	Regular in-person	No	Yes
ALU0620	João Teixeira Barbosa	CUR01	4	21	Jundiaí	Regular in-person	No	Yes
ALU0621	Gabriel Rocha Ferreira	CUR01	4	24	Jibran El Hadj	Regular in-person	No	No
ALU0622	Camila Carvalho Santos	CUR01	1	29	São Carlos	Regular in-person	No	No
ALU0623	Beatriz Silva Nunes	CUR01	6	28	São Carlos	Regular hybrid	No	No
ALU0624	João Souza Rodrigues	CUR01	7	24	Jundiaí	Regular in-person	Yes	No
ALU0625	Julia Barbosa Teixeira	CUR01	6	26	Vila Jaiara	Regular in-person	No	No
ALU0626	Luana Carvalho Ribeiro	CUR01	7	22	Maracanã	Regular in-person	No	No
ALU0627	Bruno Araújo Almeida	CUR01	1	28	Residencial das Rosas	Regular in-person	No	No
ALU0628	Mariana Rocha Oliveira	CUR01	4	23	Paraíso	Regular in-person	No	No
ALU0629	Matheus Almeida Mendes	CUR01	4	23	Maracanã	Regular in-person	No	No
ALU0630	Pedro Pereira Ferreira	CUR01	1	29	Recanto do Sol	Regular in-person	No	No
ALU0631	Camila Oliveira Araújo	CUR01	3	17	Jibran El Hadj	EJA	No	No
ALU0632	Gustavo Martins Nunes	CUR01	8	26	Setor Industrial	Regular in-person	No	No
ALU0633	Felipe Mendes Carvalho	CUR01	3	22	Boa Vista	Regular in-person	No	Yes
ALU0634	Carlos Costa Rocha	CUR01	3	22	Boa Vista	Regular in-person	No	No
ALU0635	Ana Gomes Oliveira	CUR01	4	21	Jibran El Hadj	Regular in-person	No	No
ALU0636	Pedro Araújo Araújo	CUR01	3	23	Maracanã	Regular in-person	No	No
ALU0637	Gabriel Lima Costa	CUR01	6	24	Maracanã	Regular in-person	No	No
ALU0638	Gustavo Gomes Martins	CUR01	4	29	Anápolis City	Regular in-person	No	No
ALU0639	Isabela Mendes Carvalho	CUR01	3	26	Filostro Machado	Regular in-person	No	Yes
ALU0640	Victor Ribeiro Martins	CUR01	1	24	Vila Jaiara	Regular in-person	No	No
ALU0641	Rafael Rodrigues Pereira	CUR01	8	24	Vivian Parque	Regular in-person	No	No
ALU0642	João Lima Rodrigues	CUR01	4	27	Recanto do Sol	Regular in-person	No	No
ALU0643	Eduardo Souza Pereira	CUR01	4	20	Boa Vista	Regular in-person	No	No
ALU0644	Carlos Ferreira Lima	CUR01	5	26	Jundiaí	Regular in-person	No	No
ALU0645	Rafael Santos Lima	CUR01	6	29	Paraíso	Regular in-person	No	No
ALU0646	Lucas Ribeiro Araújo	CUR01	5	17	Paraíso	Regular in-person	No	Yes
ALU0647	Renato Martins Martins	CUR01	5	25	Recanto do Sol	Regular in-person	No	No
ALU0648	Victor Ribeiro Ferreira	CUR01	7	17	Setor Central	Regular in-person	No	No
ALU0649	Luana Barbosa Ferreira	CUR01	3	28	Jibran El Hadj	Regular in-person	No	Yes
ALU0650	Amanda Lima Oliveira	CUR01	8	17	Residencial das Rosas	Regular in-person	No	No
ALU0651	Matheus Teixeira Ferreira	CUR01	2	22	São Carlos	EJA	No	No
ALU0652	Pedro Almeida Costa	CUR01	5	18	Residencial das Rosas	Regular in-person	No	No
ALU0653	Letícia Martins Pereira	CUR01	6	25	Residencial das Rosas	Regular in-person	No	No
ALU0654	Gabriel Barbosa Nunes	CUR01	4	24	São Carlos	Regular in-person	Yes	No
ALU0655	Felipe Ferreira Lima	CUR01	8	25	Maracanã	EJA	No	No
ALU0656	Amanda Nunes Teixeira	CUR01	4	24	Filostro Machado	EJA	Yes	No
ALU0657	Thiago Lima Souza	CUR01	8	26	Paraíso	Regular hybrid	No	No
ALU0658	Isabela Lima Souza	CUR01	8	24	Vivian Parque	Regular in-person	Yes	No
ALU0659	Lucas Araújo Souza	CUR01	6	20	Vila Jaiara	EJA	No	No
ALU0660	Eduardo Ribeiro Araújo	CUR01	4	25	Maracanã	Regular in-person	No	No
ALU0661	Beatriz Rocha Rocha	CUR01	4	17	Setor Central	EJA	No	No
ALU0662	Maria Rodrigues Rocha	CUR01	1	17	Maracanã	Regular in-person	No	No
ALU0663	Eduardo Ribeiro Rocha	CUR01	8	30	Setor Industrial	Regular hybrid	No	No
ALU0664	Julia Gomes Costa	CUR01	1	24	Jardim Alexandrina	Regular in-person	No	No
ALU0665	Gabriel Souza Rodrigues	CUR01	6	17	Filostro Machado	Regular in-person	Yes	No
ALU0666	Rafael Rodrigues Ribeiro	CUR01	8	23	São Carlos	Regular in-person	No	No
ALU0667	Bruno Almeida Mendes	CUR01	6	31	Anápolis City	Regular in-person	No	No
ALU0668	Maria Ribeiro Almeida	CUR01	3	20	Anápolis City	Regular in-person	Yes	Yes
ALU0669	Victor Oliveira Teixeira	CUR01	3	28	Setor Central	Regular in-person	No	No
ALU0670	Eduardo Almeida Araújo	CUR01	2	30	Paraíso	Regular in-person	No	No
ALU0671	Eduardo Souza Martins	CUR01	8	17	Vivian Parque	Regular in-person	No	No
ALU0672	Maria Araújo Santos	CUR01	8	21	Jibran El Hadj	Regular hybrid	No	No
ALU0673	Larissa Almeida Teixeira	CUR01	4	22	São Carlos	Regular in-person	No	No
ALU0674	Bruno Carvalho Oliveira	CUR01	3	27	Filostro Machado	Regular in-person	No	No
ALU0675	Carlos Barbosa Rodrigues	CUR01	3	20	Setor Industrial	Regular in-person	No	No
ALU0676	Isabela Souza Almeida	CUR01	1	31	São Carlos	Regular in-person	No	No
ALU0677	Beatriz Ribeiro Teixeira	CUR01	1	27	Boa Vista	Regular in-person	No	No
ALU0678	Thiago Silva Araújo	CUR01	2	21	Filostro Machado	Regular in-person	No	No
ALU0679	Matheus Costa Almeida	CUR01	1	22	Paraíso	Regular in-person	Yes	No
ALU0680	Carlos Nunes Santos	CUR01	3	27	Setor Industrial	Regular hybrid	No	No
ALU0681	Matheus Mendes Silva	CUR01	6	27	Jibran El Hadj	Regular in-person	No	No
ALU0682	Matheus Teixeira Pereira	CUR01	4	21	Jardim Alexandrina	EJA	Yes	No
ALU0683	Larissa Martins Ferreira	CUR01	6	26	Jundiaí	Regular in-person	No	No
ALU0684	Camila Pereira Barbosa	CUR01	7	23	Residencial das Rosas	Regular in-person	No	No
ALU0685	Eduardo Almeida Costa	CUR01	2	17	Vivian Parque	Regular hybrid	No	No
ALU0686	Julia Rocha Silva	CUR01	3	23	Paraíso	Regular in-person	No	Yes
ALU0687	Victor Nunes Nunes	CUR01	2	19	Jardim Alexandrina	Regular in-person	No	No
ALU0688	Camila Oliveira Ribeiro	CUR01	3	29	Vivian Parque	EJA	No	No
ALU0689	Rafael Nunes Oliveira	CUR01	6	25	Vila Jaiara	EJA	No	No
ALU0690	Isabela Gomes Pereira	CUR01	3	20	Anápolis City	EJA	No	No
ALU0691	Luana Oliveira Mendes	CUR01	5	24	Vila Jaiara	Regular in-person	No	No
ALU0692	Pedro Nunes Rocha	CUR01	2	31	Filostro Machado	EJA	No	No
ALU0693	Carlos Santos Santos	CUR01	2	29	Boa Vista	Regular in-person	Yes	Yes
ALU0694	Felipe Rodrigues Souza	CUR01	3	22	Jibran El Hadj	Regular hybrid	No	No
ALU0695	Amanda Araújo Ribeiro	CUR01	2	24	Vila Jaiara	Regular hybrid	No	No
ALU0696	Luana Rodrigues Pereira	CUR01	7	17	Setor Central	EJA	No	Yes
ALU0697	Isabela Gomes Araújo	CUR01	2	25	Boa Vista	Regular in-person	No	No
ALU0698	Gustavo Barbosa Barbosa	CUR01	6	20	Anápolis City	Regular in-person	No	No
ALU0699	Pedro Teixeira Lima	CUR01	8	23	Anápolis City	Regular hybrid	No	No
ALU0700	Carlos Mendes Araújo	CUR01	5	25	Vila Jaiara	Regular in-person	No	No
ALU0701	Lucas Teixeira Carvalho	CUR01	7	18	Setor Central	Regular in-person	No	No
ALU0702	Lucas Gomes Ribeiro	CUR01	8	25	Paraíso	Regular in-person	No	No
ALU0703	Gustavo Pereira Carvalho	CUR01	6	21	Filostro Machado	Regular in-person	No	No
ALU0704	Luana Souza Oliveira	CUR01	4	24	Jundiaí	Regular in-person	No	No
ALU0705	Beatriz Nunes Costa	CUR01	2	31	Setor Industrial	Regular in-person	Yes	No
ALU0706	Bruno Gomes Almeida	CUR01	7	24	Maracanã	Regular hybrid	Yes	No
ALU0707	Ana Rodrigues Gomes	CUR01	7	23	Residencial das Rosas	Regular in-person	No	Yes
ALU0708	Luana Rodrigues Almeida	CUR01	8	23	Boa Vista	Regular in-person	No	Yes
ALU0709	Larissa Rodrigues Souza	CUR01	3	23	Vila Jaiara	Regular in-person	No	No
ALU0710	Pedro Pereira Silva	CUR01	7	30	Vila Jaiara	Regular hybrid	No	No
ALU0711	Eduardo Gomes Barbosa	CUR01	5	24	Vivian Parque	Regular in-person	No	No
ALU0712	Bruno Barbosa Mendes	CUR01	8	22	Setor Industrial	Regular in-person	No	No
ALU0713	Luana Mendes Nunes	CUR01	3	26	Filostro Machado	Regular in-person	No	No
ALU0714	Bruno Pereira Barbosa	CUR01	8	19	Anápolis City	Regular in-person	No	Yes
ALU0715	Beatriz Ferreira Ferreira	CUR01	3	19	Vivian Parque	Regular in-person	No	No
ALU0716	Pedro Barbosa Oliveira	CUR01	1	21	Filostro Machado	Regular in-person	Yes	No
ALU0717	Isabela Carvalho Oliveira	CUR01	1	23	São Carlos	Regular hybrid	No	No
ALU0718	Felipe Souza Lima	CUR01	7	19	Maracanã	Regular in-person	No	No
ALU0719	Larissa Barbosa Oliveira	CUR01	8	25	Recanto do Sol	Regular in-person	No	Yes
ALU0720	Rafael Mendes Oliveira	CUR01	7	29	Paraíso	Regular in-person	Yes	No
ALU0721	Beatriz Santos Ribeiro	CUR01	2	24	Vivian Parque	Regular hybrid	No	No
ALU0722	Luana Ferreira Teixeira	CUR01	8	22	Boa Vista	Regular in-person	No	No
ALU0723	Victor Santos Nunes	CUR01	2	17	Maracanã	Regular in-person	No	No
ALU0724	Larissa Nunes Rocha	CUR01	4	29	Recanto do Sol	Regular in-person	No	No
ALU0725	Beatriz Teixeira Martins	CUR01	2	24	São Carlos	Regular in-person	No	No
ALU0726	Lucas Rocha Lima	CUR01	7	23	Residencial das Rosas	Regular in-person	No	No
ALU0727	Ana Teixeira Barbosa	CUR01	4	21	Maracanã	Regular hybrid	Yes	No
ALU0728	Gustavo Gomes Ferreira	CUR01	4	17	Maracanã	Regular in-person	No	No
ALU0729	Isabela Martins Oliveira	CUR01	6	20	Setor Central	Regular in-person	No	No
ALU0730	Letícia Gomes Souza	CUR01	7	18	Jardim Alexandrina	Regular in-person	No	No
ALU0731	Letícia Lima Souza	CUR01	8	23	Setor Central	Regular in-person	No	No
ALU0732	Renato Carvalho Ferreira	CUR01	3	27	Filostro Machado	Regular in-person	Yes	No
ALU0733	Ana Teixeira Santos	CUR01	6	23	Filostro Machado	Regular in-person	No	No
ALU0734	Amanda Martins Costa	CUR01	2	21	Setor Industrial	Regular in-person	No	No
ALU0735	Julia Souza Souza	CUR01	4	23	Setor Industrial	EJA	No	No
ALU0736	Felipe Carvalho Mendes	CUR01	1	19	Setor Central	Regular hybrid	No	No
ALU0737	Isabela Oliveira Mendes	CUR01	7	20	Jardim Alexandrina	Regular in-person	No	No
ALU0738	Felipe Barbosa Carvalho	CUR01	8	26	Setor Central	Regular in-person	No	Yes
ALU0739	Mariana Rodrigues Mendes	CUR01	1	25	Filostro Machado	Regular in-person	No	No
ALU0740	Letícia Costa Costa	CUR01	8	17	Paraíso	Regular hybrid	No	Yes
ALU0741	Maria Mendes Nunes	CUR01	4	18	Boa Vista	Regular in-person	No	No
ALU0742	Isabela Souza Araújo	CUR01	1	22	Recanto do Sol	Regular in-person	No	No
ALU0743	Gustavo Barbosa Santos	CUR01	5	21	Jardim Alexandrina	Regular in-person	No	No
ALU0744	Pedro Carvalho Rocha	CUR01	3	28	Jibran El Hadj	EJA	No	No
ALU0745	Thiago Almeida Rodrigues	CUR01	3	23	Residencial das Rosas	Regular in-person	No	No
ALU0746	Maria Silva Almeida	CUR01	1	27	Vila Jaiara	Regular in-person	No	No
ALU0747	Pedro Oliveira Santos	CUR01	7	34	Paraíso	Regular in-person	Yes	No
ALU0748	Amanda Lima Martins	CUR01	6	25	Vila Jaiara	EJA	No	No
ALU0749	Gabriel Oliveira Rodrigues	CUR01	4	20	Anápolis City	Regular in-person	Yes	No
ALU0750	Letícia Almeida Rocha	CUR01	6	26	Maracanã	Regular hybrid	No	No
ALU0751	Rafael Ribeiro Oliveira	CUR01	6	23	Vila Jaiara	Regular in-person	No	No
ALU0752	Renato Barbosa Ribeiro	CUR01	4	18	Jardim Alexandrina	Regular in-person	No	Yes
ALU0753	Thiago Gomes Oliveira	CUR01	2	22	Jardim Alexandrina	Regular hybrid	No	No
ALU0754	Matheus Martins Almeida	CUR01	4	20	São Carlos	Regular in-person	No	No
ALU0755	Thiago Lima Almeida	CUR01	6	28	Jundiaí	Regular in-person	Yes	No
ALU0756	Eduardo Gomes Oliveira	CUR01	8	20	Setor Industrial	Regular hybrid	No	No
ALU0757	Bruno Souza Lima	CUR01	2	21	Boa Vista	Regular in-person	Yes	No
ALU0758	Thiago Rocha Rodrigues	CUR01	7	29	Residencial das Rosas	Regular in-person	No	No
ALU0759	Felipe Oliveira Oliveira	CUR01	1	26	Anápolis City	Regular in-person	No	No
ALU0760	Pedro Martins Silva	CUR01	5	23	São Carlos	Regular hybrid	No	No
ALU0761	Julia Almeida Ribeiro	CUR01	7	25	Vivian Parque	Regular in-person	No	Yes
ALU0762	Maria Ribeiro Martins	CUR01	5	19	Setor Central	Regular in-person	Yes	No
ALU0763	Beatriz Gomes Pereira	CUR01	3	19	Boa Vista	EJA	No	No
ALU0764	Letícia Ferreira Martins	CUR01	4	19	Recanto do Sol	Regular in-person	No	Yes
ALU0765	Gustavo Gomes Barbosa	CUR01	7	20	Setor Central	Regular in-person	No	Yes
ALU0766	Mariana Ribeiro Barbosa	CUR01	1	17	Setor Central	Regular in-person	No	No
ALU0767	Felipe Almeida Martins	CUR01	1	21	Setor Industrial	Regular in-person	No	No
ALU0768	Beatriz Souza Ribeiro	CUR01	6	21	Paraíso	Regular in-person	No	No
ALU0769	Matheus Pereira Almeida	CUR01	1	32	Residencial das Rosas	EJA	No	No
ALU0770	Matheus Souza Ribeiro	CUR01	6	21	Filostro Machado	Regular in-person	Yes	No
ALU0771	Letícia Pereira Ribeiro	CUR01	6	22	Setor Industrial	Regular hybrid	No	No
ALU0772	Maria Rocha Pereira	CUR01	8	20	Setor Industrial	Regular in-person	No	No
ALU0773	Victor Martins Rocha	CUR01	1	19	Jundiaí	Regular in-person	No	No
ALU0774	Maria Martins Santos	CUR01	4	25	Jibran El Hadj	Regular in-person	No	No
ALU0775	Gabriel Lima Teixeira	CUR01	8	24	Setor Central	Regular in-person	No	No
ALU0776	João Carvalho Araújo	CUR01	4	28	Jundiaí	Regular in-person	No	No
ALU0777	Matheus Rodrigues Carvalho	CUR01	3	20	Paraíso	Regular hybrid	No	No
ALU0778	Julia Araújo Rodrigues	CUR01	7	30	Recanto do Sol	Regular in-person	No	No
ALU0779	Gustavo Lima Santos	CUR01	8	20	Jibran El Hadj	Regular hybrid	No	No
ALU0780	Beatriz Nunes Rocha	CUR01	5	27	Anápolis City	Regular in-person	No	Yes
ALU0781	Eduardo Barbosa Ferreira	CUR01	5	24	Boa Vista	Regular hybrid	No	No
ALU0782	Carlos Santos Araújo	CUR01	1	28	São Carlos	Regular hybrid	No	No
ALU0783	Gabriel Teixeira Almeida	CUR01	5	17	São Carlos	Regular in-person	No	Yes
ALU0784	Ana Rodrigues Ferreira	CUR01	4	21	São Carlos	Regular in-person	Yes	No
ALU0785	Gabriel Teixeira Ferreira	CUR01	3	17	Paraíso	Regular in-person	No	No
ALU0786	Carlos Almeida Gomes	CUR01	6	21	Anápolis City	Regular in-person	No	No
ALU0787	Carlos Mendes Rodrigues	CUR01	5	22	São Carlos	Regular in-person	No	No
ALU0788	Gabriel Barbosa Oliveira	CUR01	1	23	Vivian Parque	Regular in-person	Yes	No
ALU0789	Julia Barbosa Santos	CUR01	7	28	Boa Vista	EJA	Yes	No
ALU0790	Pedro Teixeira Carvalho	CUR01	1	17	Residencial das Rosas	Regular in-person	No	No
ALU0791	Eduardo Martins Rocha	CUR01	1	17	Setor Central	Regular in-person	No	No
ALU0792	Felipe Almeida Ribeiro	CUR01	6	17	Jundiaí	Regular in-person	No	No
ALU0793	Gabriel Silva Rocha	CUR01	8	27	São Carlos	Regular in-person	No	No
ALU0794	Felipe Souza Teixeira	CUR01	7	22	Jardim Alexandrina	Regular in-person	No	No
ALU0795	Ana Ferreira Almeida	CUR01	5	17	São Carlos	Regular in-person	No	No
ALU0796	Lucas Almeida Carvalho	CUR01	7	25	Maracanã	Regular hybrid	No	Yes
ALU0797	Julia Barbosa Rodrigues	CUR01	7	22	Setor Central	Regular in-person	No	No
ALU0798	Thiago Pereira Barbosa	CUR01	6	33	Maracanã	Regular in-person	No	No
ALU0799	Isabela Lima Rodrigues	CUR01	8	17	Maracanã	Regular hybrid	No	No
ALU0800	Rafael Mendes Costa	CUR01	6	20	Jundiaí	Regular in-person	No	No
ALU0801	Victor Silva Carvalho	CUR01	4	24	Jundiaí	Regular in-person	Yes	No
ALU0802	Julia Rocha Nunes	CUR01	8	23	Jundiaí	Regular in-person	No	No
ALU0803	Larissa Carvalho Barbosa	CUR01	8	19	Jundiaí	Regular hybrid	Yes	No
ALU0804	Amanda Rodrigues Almeida	CUR01	5	28	Vivian Parque	EJA	No	No
ALU0805	Matheus Lima Rocha	CUR01	8	24	Filostro Machado	Regular in-person	No	No
ALU0806	Bruno Nunes Ribeiro	CUR01	3	20	Maracanã	EJA	Yes	No
ALU0807	Lucas Barbosa Ferreira	CUR01	6	28	Anápolis City	Regular hybrid	No	No
ALU0808	Felipe Pereira Lima	CUR01	3	20	Boa Vista	Regular in-person	No	No
ALU0809	Eduardo Carvalho Ferreira	CUR01	3	17	Paraíso	Regular in-person	No	No
ALU0810	Lucas Nunes Ferreira	CUR01	8	27	São Carlos	Regular in-person	No	No
ALU0811	Rafael Costa Pereira	CUR01	4	21	Residencial das Rosas	Regular in-person	No	No
ALU0812	Thiago Gomes Costa	CUR01	4	22	Setor Central	Regular in-person	No	No
ALU0813	Lucas Rodrigues Carvalho	CUR01	5	25	Paraíso	Regular hybrid	Yes	No
ALU0814	Ana Costa Nunes	CUR01	2	24	Filostro Machado	Regular in-person	Yes	No
ALU0815	Gabriel Mendes Nunes	CUR01	2	24	Vivian Parque	Regular in-person	No	No
ALU0816	Eduardo Santos Silva	CUR01	3	17	Jundiaí	EJA	No	No
ALU0817	Camila Nunes Nunes	CUR01	7	23	Jibran El Hadj	Regular in-person	Yes	No
ALU0818	Julia Santos Oliveira	CUR01	7	20	Filostro Machado	Regular in-person	No	Yes
ALU0819	Carlos Gomes Costa	CUR01	2	27	Vivian Parque	Regular in-person	No	No
ALU0820	Eduardo Santos Souza	CUR01	2	20	Residencial das Rosas	Regular in-person	Yes	No
ALU0821	Renato Almeida Pereira	CUR01	8	20	Filostro Machado	Regular in-person	No	No
ALU0822	Ana Carvalho Nunes	CUR01	4	17	Jundiaí	EJA	Yes	No
ALU0823	Bruno Santos Gomes	CUR01	4	17	Vivian Parque	Regular in-person	No	No
ALU0824	Mariana Silva Almeida	CUR01	3	22	Setor Central	Regular hybrid	Yes	No
ALU0825	Renato Nunes Nunes	CUR01	5	35	Vila Jaiara	Regular in-person	No	No
ALU0826	Renato Araújo Santos	CUR01	6	22	Jardim Alexandrina	Regular in-person	No	No
ALU0827	Matheus Carvalho Santos	CUR01	2	20	São Carlos	Regular in-person	No	No
ALU0828	Amanda Ribeiro Souza	CUR01	8	20	Paraíso	Regular in-person	No	No
ALU0829	Carlos Martins Oliveira	CUR01	4	17	Vivian Parque	Regular hybrid	No	No
ALU0830	Larissa Lima Santos	CUR01	2	26	Vivian Parque	Regular hybrid	No	No
ALU0831	Matheus Souza Silva	CUR01	5	22	Setor Central	Regular in-person	No	No
ALU0832	Beatriz Almeida Almeida	CUR01	7	17	Boa Vista	Regular in-person	No	No
ALU0833	Julia Costa Nunes	CUR01	6	17	Anápolis City	Regular in-person	No	No
ALU0834	Carlos Rodrigues Silva	CUR01	1	29	Boa Vista	Regular in-person	Yes	No
ALU0835	Victor Lima Nunes	CUR01	3	27	Jundiaí	Regular in-person	No	No
ALU0836	Ana Carvalho Costa	CUR01	6	17	Paraíso	Regular in-person	Yes	No
ALU0837	João Almeida Mendes	CUR01	4	27	Paraíso	Regular in-person	No	No
ALU0838	Amanda Araújo Martins	CUR01	5	22	Paraíso	Regular in-person	No	No
ALU0839	Thiago Barbosa Santos	CUR01	2	28	Paraíso	Regular hybrid	No	No
ALU0840	Ana Souza Ferreira	CUR01	6	27	Anápolis City	Regular in-person	Yes	No
ALU0841	Isabela Oliveira Santos	CUR01	6	20	São Carlos	Regular in-person	Yes	No
ALU0842	Matheus Pereira Rodrigues	CUR01	5	27	Jundiaí	Regular in-person	No	No
ALU0843	Rafael Ribeiro Teixeira	CUR01	7	24	Paraíso	Regular hybrid	No	No
ALU0844	Eduardo Lima Oliveira	CUR01	2	22	Setor Industrial	Regular in-person	No	No
ALU0845	Eduardo Rocha Rocha	CUR01	5	22	Jibran El Hadj	Regular hybrid	No	No
ALU0846	Matheus Rodrigues Silva	CUR01	2	28	Residencial das Rosas	Regular in-person	No	No
ALU0847	Isabela Silva Souza	CUR01	8	26	Filostro Machado	Regular in-person	No	No
ALU0848	Julia Silva Souza	CUR01	1	23	Setor Industrial	Regular in-person	No	No
ALU0849	Isabela Ferreira Araújo	CUR01	5	19	Residencial das Rosas	EJA	Yes	No
ALU0850	Matheus Gomes Martins	CUR01	1	26	Maracanã	Regular in-person	No	Yes
ALU0851	Bruno Silva Almeida	CUR01	3	23	Residencial das Rosas	EJA	Yes	No
ALU0852	Letícia Gomes Souza	CUR01	7	17	Vivian Parque	Regular in-person	No	No
ALU0853	Pedro Santos Rocha	CUR01	4	18	Jundiaí	Regular in-person	No	No
ALU0854	João Rodrigues Almeida	CUR01	8	22	Filostro Machado	Regular in-person	No	No
ALU0855	Victor Gomes Oliveira	CUR01	4	26	Anápolis City	Regular in-person	Yes	No
ALU0856	Rafael Oliveira Oliveira	CUR01	6	21	Jibran El Hadj	Regular in-person	Yes	Yes
ALU0857	Larissa Santos Carvalho	CUR01	4	23	Boa Vista	Regular in-person	No	No
ALU0858	Luana Silva Ferreira	CUR01	2	28	São Carlos	Regular in-person	No	No
ALU0859	Isabela Ferreira Silva	CUR01	2	22	Recanto do Sol	Regular in-person	No	No
ALU0860	Gabriel Mendes Lima	CUR01	2	19	Maracanã	Regular in-person	No	No
ALU0861	Renato Almeida Nunes	CUR01	2	24	Recanto do Sol	Regular in-person	Yes	No
ALU0862	Lucas Carvalho Costa	CUR01	5	20	Vila Jaiara	Regular in-person	Yes	No
ALU0863	Carlos Nunes Santos	CUR01	6	18	Paraíso	Regular in-person	Yes	No
ALU0864	Amanda Mendes Santos	CUR01	1	30	São Carlos	Regular in-person	No	No
ALU0865	Letícia Rodrigues Barbosa	CUR01	4	25	Paraíso	EJA	No	No
ALU0866	Camila Souza Barbosa	CUR01	3	17	Filostro Machado	Regular in-person	No	No
ALU0867	Gustavo Martins Costa	CUR01	8	18	Residencial das Rosas	Regular in-person	No	No
ALU0868	Thiago Gomes Rodrigues	CUR01	3	26	Setor Industrial	Regular in-person	Yes	No
ALU0869	Luana Santos Santos	CUR01	8	26	Setor Central	Regular in-person	No	No
ALU0870	Rafael Lima Gomes	CUR01	8	20	São Carlos	Regular hybrid	No	No
ALU0871	Thiago Martins Rocha	CUR01	7	17	Setor Industrial	Regular in-person	No	No
ALU0872	Larissa Lima Pereira	CUR01	2	24	Anápolis City	Regular hybrid	Yes	No
ALU0873	Thiago Almeida Santos	CUR01	3	17	Setor Industrial	Regular in-person	No	No
ALU0874	Maria Costa Rocha	CUR01	2	20	Paraíso	Regular in-person	No	No
ALU0875	Thiago Ribeiro Oliveira	CUR01	7	19	Setor Industrial	Regular in-person	No	Yes
ALU0876	Isabela Barbosa Rocha	CUR01	8	18	Jundiaí	Regular in-person	No	Yes
ALU0877	Maria Ferreira Costa	CUR01	1	32	Vila Jaiara	Regular in-person	No	No
ALU0878	Gabriel Barbosa Santos	CUR01	8	22	Residencial das Rosas	Regular in-person	No	No
ALU0879	Renato Gomes Araújo	CUR01	3	17	Boa Vista	EJA	No	No
ALU0880	Gustavo Rodrigues Rodrigues	CUR01	1	29	Recanto do Sol	Regular in-person	No	No
ALU0881	Felipe Nunes Ferreira	CUR01	1	23	Setor Industrial	Regular in-person	Yes	Yes
ALU0882	Beatriz Costa Nunes	CUR01	4	17	Jundiaí	Regular in-person	No	No
ALU0883	Thiago Souza Carvalho	CUR01	7	17	Filostro Machado	Regular hybrid	No	No
ALU0884	Bruno Araújo Ferreira	CUR01	6	27	Vivian Parque	Regular hybrid	Yes	Yes
ALU0885	Gustavo Gomes Araújo	CUR01	2	27	Boa Vista	Regular in-person	No	No
ALU0886	Pedro Martins Mendes	CUR01	7	18	São Carlos	Regular in-person	No	No
ALU0887	Letícia Costa Carvalho	CUR01	6	22	Recanto do Sol	Regular in-person	No	No
ALU0888	Gustavo Teixeira Rocha	CUR01	5	25	Anápolis City	Regular in-person	No	No
ALU0889	Pedro Rocha Barbosa	CUR01	5	17	Vila Jaiara	Regular in-person	Yes	No
ALU0890	João Ribeiro Rodrigues	CUR01	1	18	Setor Industrial	Regular in-person	No	No
ALU0891	Luana Nunes Rocha	CUR01	3	24	Jardim Alexandrina	Regular in-person	No	No
ALU0892	Ana Souza Teixeira	CUR01	4	26	Anápolis City	Regular in-person	No	No
ALU0893	Isabela Rocha Barbosa	CUR01	8	21	Anápolis City	Regular in-person	Yes	No
ALU0894	Amanda Ribeiro Gomes	CUR01	3	28	Setor Central	Regular in-person	No	No
ALU0895	Letícia Gomes Almeida	CUR01	5	19	Setor Central	Regular in-person	No	Yes
ALU0896	Eduardo Silva Almeida	CUR01	6	21	Residencial das Rosas	Regular in-person	No	No
ALU0897	Mariana Martins Rocha	CUR01	5	24	Jardim Alexandrina	EJA	No	No
ALU0898	Mariana Rodrigues Pereira	CUR01	1	30	Jibran El Hadj	Regular in-person	No	No
ALU0899	Mariana Pereira Almeida	CUR01	7	17	Boa Vista	Regular in-person	No	No
ALU0900	Eduardo Silva Mendes	CUR01	3	26	Setor Industrial	Regular hybrid	No	No
ALU0901	Julia Rodrigues Teixeira	CUR01	2	36	Jundiaí	Regular in-person	No	No
ALU0902	Ana Costa Mendes	CUR01	4	19	Vila Jaiara	Regular in-person	No	No
ALU0903	Renato Silva Teixeira	CUR01	3	17	São Carlos	Regular in-person	No	No
ALU0904	Gabriel Oliveira Pereira	CUR01	5	21	Jibran El Hadj	Regular in-person	No	Yes
ALU0905	Maria Rodrigues Costa	CUR01	2	21	São Carlos	Regular in-person	No	No
ALU0906	Beatriz Santos Barbosa	CUR01	1	17	Jardim Alexandrina	Regular in-person	Yes	No
ALU0907	Pedro Santos Costa	CUR01	2	17	Filostro Machado	Regular hybrid	No	No
ALU0908	Carlos Teixeira Silva	CUR01	7	29	São Carlos	Regular in-person	No	No
ALU0909	Eduardo Rocha Lima	CUR01	4	19	Anápolis City	Regular in-person	No	No
ALU0910	Luana Teixeira Rocha	CUR01	3	20	Filostro Machado	Regular in-person	No	No
ALU0911	Camila Ferreira Araújo	CUR01	5	24	Residencial das Rosas	Regular in-person	No	No
ALU0912	Rafael Carvalho Mendes	CUR01	6	22	Paraíso	Regular in-person	No	No
ALU0913	Gabriel Araújo Teixeira	CUR01	2	20	Maracanã	Regular in-person	No	No
ALU0914	Rafael Carvalho Rocha	CUR01	6	19	Filostro Machado	EJA	No	No
ALU0915	Amanda Rocha Oliveira	CUR01	7	19	Vivian Parque	Regular in-person	No	No
ALU0916	Larissa Teixeira Carvalho	CUR01	4	23	Residencial das Rosas	Regular in-person	No	No
ALU0917	Victor Ribeiro Pereira	CUR01	2	28	Jundiaí	Regular in-person	Yes	No
ALU0918	Eduardo Martins Gomes	CUR01	8	22	Jardim Alexandrina	Regular in-person	No	No
ALU0919	Carlos Lima Nunes	CUR01	1	17	Paraíso	Regular in-person	No	No
ALU0920	Felipe Martins Teixeira	CUR01	8	23	Residencial das Rosas	Regular in-person	No	No
ALU0921	Beatriz Ferreira Ferreira	CUR01	7	24	São Carlos	Regular in-person	No	No
ALU0922	João Pereira Mendes	CUR01	5	22	Boa Vista	Regular in-person	No	No
ALU0923	Camila Santos Araújo	CUR01	5	23	Residencial das Rosas	Regular in-person	No	No
ALU0924	Mariana Gomes Silva	CUR01	6	25	Setor Industrial	Regular in-person	No	No
ALU0925	Felipe Martins Souza	CUR01	2	24	São Carlos	Regular in-person	No	No
ALU0926	Isabela Santos Ferreira	CUR01	7	24	Paraíso	Regular in-person	No	No
ALU0927	Thiago Mendes Mendes	CUR01	6	21	Setor Central	Regular hybrid	Yes	No
ALU0928	Gustavo Silva Carvalho	CUR01	8	25	Recanto do Sol	EJA	No	No
ALU0929	Lucas Martins Ribeiro	CUR01	8	17	Maracanã	Regular in-person	No	No
ALU0930	Maria Teixeira Rocha	CUR01	1	22	Recanto do Sol	Regular in-person	No	No
ALU0931	Thiago Nunes Pereira	CUR01	5	30	Vivian Parque	Regular in-person	No	No
ALU0932	Thiago Martins Rodrigues	CUR01	3	30	Anápolis City	Regular in-person	No	No
ALU0933	Luana Santos Araújo	CUR01	7	23	Maracanã	Regular in-person	No	No
ALU0934	Gustavo Rocha Costa	CUR01	6	33	Recanto do Sol	Regular in-person	No	No
ALU0935	Thiago Araújo Oliveira	CUR01	5	28	Residencial das Rosas	Regular in-person	No	No
ALU0936	Felipe Gomes Rocha	CUR01	3	17	Setor Industrial	Regular in-person	Yes	No
ALU0937	Julia Almeida Gomes	CUR01	5	23	Jundiaí	Regular in-person	Yes	No
ALU0938	Eduardo Santos Pereira	CUR01	3	27	Jundiaí	EJA	No	Yes
ALU0939	Ana Pereira Araújo	CUR01	1	19	Anápolis City	Regular in-person	No	No
ALU0940	Matheus Teixeira Nunes	CUR01	3	22	Recanto do Sol	Regular hybrid	Yes	No
ALU0941	Eduardo Costa Lima	CUR01	2	27	Setor Central	Regular in-person	Yes	No
ALU0942	Beatriz Rocha Gomes	CUR01	7	20	Vivian Parque	Regular in-person	No	No
ALU0943	Letícia Lima Teixeira	CUR01	5	23	Vila Jaiara	Regular in-person	No	No
ALU0944	João Lima Souza	CUR01	1	23	Jardim Alexandrina	Regular hybrid	No	No
ALU0945	Gustavo Oliveira Almeida	CUR01	3	20	Jardim Alexandrina	Regular in-person	No	No
ALU0946	Carlos Rodrigues Silva	CUR01	1	34	Setor Central	Regular hybrid	Yes	No
ALU0947	Ana Ferreira Rodrigues	CUR01	8	26	Residencial das Rosas	Regular in-person	No	No
ALU0948	Amanda Souza Souza	CUR01	2	17	Residencial das Rosas	Regular in-person	No	No
ALU0949	Luana Ferreira Silva	CUR01	3	32	Filostro Machado	Regular hybrid	Yes	No
ALU0950	Carlos Lima Costa	CUR01	2	26	Jardim Alexandrina	Regular in-person	No	Yes
ALU0951	Thiago Araújo Gomes	CUR01	3	21	Filostro Machado	Regular in-person	No	No
ALU0952	Matheus Ribeiro Nunes	CUR01	2	21	Jardim Alexandrina	Regular in-person	No	No
ALU0953	Camila Araújo Lima	CUR01	4	24	Anápolis City	EJA	No	No
ALU0954	Beatriz Ferreira Pereira	CUR01	5	31	Jardim Alexandrina	Regular in-person	No	No
ALU0955	João Costa Pereira	CUR01	7	29	Vila Jaiara	Regular in-person	No	No
ALU0956	Pedro Souza Teixeira	CUR01	4	23	Residencial das Rosas	Regular in-person	No	No
ALU0957	Maria Gomes Silva	CUR01	5	20	Paraíso	Regular in-person	No	No
ALU0958	Bruno Silva Costa	CUR01	5	17	Recanto do Sol	Regular hybrid	No	No
ALU0959	Carlos Costa Barbosa	CUR01	6	27	Jundiaí	Regular in-person	No	No
ALU0960	Beatriz Gomes Almeida	CUR01	8	18	Maracanã	Regular in-person	Yes	No
ALU0961	Larissa Santos Barbosa	CUR01	3	19	Setor Industrial	EJA	No	No
ALU0962	Mariana Teixeira Almeida	CUR01	3	25	Recanto do Sol	Regular in-person	No	No
ALU0963	Bruno Ferreira Araújo	CUR01	3	24	Maracanã	Regular in-person	No	No
ALU0964	Lucas Silva Mendes	CUR01	5	28	Vila Jaiara	Regular in-person	No	No
ALU0965	Gustavo Carvalho Mendes	CUR01	7	28	São Carlos	EJA	No	No
ALU0966	Rafael Ribeiro Souza	CUR01	6	22	Anápolis City	Regular in-person	No	No
ALU0967	Gabriel Martins Ferreira	CUR01	4	27	Residencial das Rosas	Regular in-person	No	No
ALU0968	Mariana Lima Souza	CUR01	5	17	Jardim Alexandrina	Regular in-person	Yes	No
ALU0969	Camila Rocha Ribeiro	CUR01	2	24	Filostro Machado	Regular in-person	No	No
ALU0970	Renato Costa Rodrigues	CUR01	5	18	Anápolis City	Regular in-person	No	No
ALU0971	Luana Oliveira Pereira	CUR01	6	25	Vila Jaiara	Regular in-person	Yes	No
ALU0972	Lucas Silva Ferreira	CUR01	3	17	Jibran El Hadj	Regular in-person	No	No
ALU0973	Beatriz Rocha Mendes	CUR01	4	17	Jibran El Hadj	Regular in-person	No	No
ALU0974	Renato Almeida Barbosa	CUR01	3	18	Residencial das Rosas	Regular in-person	No	No
ALU0975	Eduardo Mendes Martins	CUR01	4	18	Residencial das Rosas	Regular in-person	No	No
ALU0976	Luana Martins Santos	CUR01	3	17	Vila Jaiara	Regular in-person	Yes	Yes
ALU0977	Amanda Pereira Rodrigues	CUR01	1	18	Residencial das Rosas	Regular in-person	Yes	No
ALU0978	Rafael Barbosa Pereira	CUR01	7	27	Paraíso	Regular in-person	No	No
ALU0979	Matheus Carvalho Silva	CUR01	6	22	Filostro Machado	Regular in-person	No	No
ALU0980	Eduardo Rocha Souza	CUR01	2	19	Anápolis City	Regular in-person	No	Yes
ALU0981	Victor Martins Araújo	CUR01	6	17	Jardim Alexandrina	Regular in-person	No	No
ALU0982	Larissa Pereira Barbosa	CUR01	2	17	Jardim Alexandrina	Regular in-person	No	No
ALU0983	Mariana Ferreira Araújo	CUR01	6	17	Setor Industrial	Regular hybrid	No	No
ALU0984	Carlos Oliveira Rodrigues	CUR01	5	22	Recanto do Sol	Regular in-person	No	No
ALU0985	Amanda Nunes Oliveira	CUR01	8	22	Jardim Alexandrina	EJA	Yes	No
ALU0986	Renato Almeida Pereira	CUR01	6	24	Filostro Machado	Regular in-person	No	No
ALU0987	Pedro Rocha Martins	CUR01	5	26	Jibran El Hadj	Regular in-person	No	No
ALU0988	Letícia Santos Ferreira	CUR01	2	20	Anápolis City	Regular in-person	No	No
ALU0989	Julia Oliveira Ferreira	CUR01	5	24	Anápolis City	Regular in-person	No	No
ALU0990	Gustavo Barbosa Nunes	CUR01	1	22	Vila Jaiara	EJA	No	No
ALU0991	Felipe Ferreira Ribeiro	CUR01	2	18	Anápolis City	Regular in-person	No	No
ALU0992	Gabriel Souza Costa	CUR01	3	19	Jardim Alexandrina	Regular in-person	Yes	No
ALU0993	Luana Gomes Ferreira	CUR01	4	20	Vila Jaiara	Regular in-person	No	No
ALU0994	Thiago Oliveira Carvalho	CUR01	8	29	São Carlos	Regular in-person	No	No
ALU0995	Mariana Rocha Gomes	CUR01	6	20	Setor Industrial	Regular in-person	No	Yes
ALU0996	Victor Araújo Costa	CUR01	1	27	São Carlos	Regular in-person	No	No
ALU0997	Felipe Silva Costa	CUR01	2	19	Residencial das Rosas	Regular in-person	No	No
ALU0998	Felipe Santos Ferreira	CUR01	7	24	Anápolis City	Regular in-person	No	No
ALU0999	Pedro Souza Barbosa	CUR01	8	17	Jardim Alexandrina	Regular in-person	No	No
ALU1000	Lucas Lima Ferreira	CUR01	1	21	Jundiaí	Regular in-person	No	No
\.

COPY public.risk_assessments (assessment_id, student_id, academic_period, kind, assessment_date, dropout_risk_pct, risk_level) FROM stdin;
AVR0001	ALU0001	2026/2	Initial	2026-08-17	26.1	Moderate
AVR0002	ALU0002	2026/2	Initial	2026-08-17	73.3	Critical
AVR0003	ALU0003	2026/2	Initial	2026-08-17	10.0	Low
AVR0004	ALU0004	2026/2	Initial	2026-08-17	22.8	Moderate
AVR0005	ALU0005	2026/2	Initial	2026-08-17	19.7	Low
AVR0006	ALU0006	2026/2	Initial	2026-08-17	27.8	Moderate
AVR0007	ALU0007	2026/2	Initial	2026-08-17	12.0	Low
AVR0008	ALU0008	2026/2	Initial	2026-08-17	7.5	Low
AVR0009	ALU0009	2026/2	Initial	2026-08-17	66.3	Critical
AVR0010	ALU0010	2026/2	Initial	2026-08-17	17.0	Low
AVR0011	ALU0011	2026/2	Initial	2026-08-17	15.0	Low
AVR0012	ALU0012	2026/2	Initial	2026-08-17	49.8	High
AVR0013	ALU0013	2026/2	Initial	2026-08-17	11.0	Low
AVR0014	ALU0014	2026/2	Initial	2026-08-17	16.2	Low
AVR0015	ALU0015	2026/2	Initial	2026-08-17	31.0	Moderate
AVR0016	ALU0016	2026/2	Initial	2026-08-17	6.0	Low
AVR0017	ALU0017	2026/2	Initial	2026-08-17	9.0	Low
AVR0018	ALU0018	2026/2	Initial	2026-08-17	20.6	Moderate
AVR0019	ALU0019	2026/2	Initial	2026-08-17	31.5	Moderate
AVR0020	ALU0020	2026/2	Initial	2026-08-17	12.5	Low
AVR0021	ALU0021	2026/2	Initial	2026-08-17	12.9	Low
AVR0022	ALU0022	2026/2	Initial	2026-08-17	10.0	Low
AVR0023	ALU0023	2026/2	Initial	2026-08-17	26.3	Moderate
AVR0024	ALU0024	2026/2	Initial	2026-08-17	13.0	Low
AVR0025	ALU0025	2026/2	Initial	2026-08-17	58.2	Critical
AVR0026	ALU0026	2026/2	Initial	2026-08-17	24.4	Moderate
AVR0027	ALU0027	2026/2	Initial	2026-08-17	27.0	Moderate
AVR0028	ALU0028	2026/2	Initial	2026-08-17	40.0	High
AVR0029	ALU0029	2026/2	Initial	2026-08-17	24.5	Moderate
AVR0030	ALU0030	2026/2	Initial	2026-08-17	23.0	Moderate
AVR0031	ALU0031	2026/2	Initial	2026-08-17	14.0	Low
AVR0032	ALU0032	2026/2	Initial	2026-08-17	42.4	High
AVR0033	ALU0033	2026/2	Initial	2026-08-17	21.5	Moderate
AVR0034	ALU0034	2026/2	Initial	2026-08-17	20.9	Moderate
AVR0035	ALU0035	2026/2	Initial	2026-08-17	32.5	Moderate
AVR0036	ALU0036	2026/2	Initial	2026-08-17	30.5	Moderate
AVR0037	ALU0037	2026/2	Initial	2026-08-17	15.0	Low
AVR0038	ALU0038	2026/2	Initial	2026-08-17	28.0	Moderate
AVR0039	ALU0039	2026/2	Initial	2026-08-17	8.1	Low
AVR0040	ALU0040	2026/2	Initial	2026-08-17	31.6	Moderate
AVR0041	ALU0041	2026/2	Initial	2026-08-17	34.5	Moderate
AVR0042	ALU0042	2026/2	Initial	2026-08-17	9.0	Low
AVR0043	ALU0043	2026/2	Initial	2026-08-17	35.3	High
AVR0044	ALU0044	2026/2	Initial	2026-08-17	16.0	Low
AVR0045	ALU0045	2026/2	Initial	2026-08-17	17.2	Low
AVR0046	ALU0046	2026/2	Initial	2026-08-17	32.9	Moderate
AVR0047	ALU0047	2026/2	Initial	2026-08-17	42.1	High
AVR0048	ALU0048	2026/2	Initial	2026-08-17	5.6	Low
AVR0049	ALU0049	2026/2	Initial	2026-08-17	22.5	Moderate
AVR0050	ALU0050	2026/2	Initial	2026-08-17	30.5	Moderate
AVR0051	ALU0051	2026/2	Initial	2026-08-17	27.2	Moderate
AVR0052	ALU0052	2026/2	Initial	2026-08-17	15.4	Low
AVR0053	ALU0053	2026/2	Initial	2026-08-17	20.5	Moderate
AVR0054	ALU0054	2026/2	Initial	2026-08-17	26.4	Moderate
AVR0055	ALU0055	2026/2	Initial	2026-08-17	27.1	Moderate
AVR0056	ALU0056	2026/2	Initial	2026-08-17	23.8	Moderate
AVR0057	ALU0057	2026/2	Initial	2026-08-17	68.7	Critical
AVR0058	ALU0058	2026/2	Initial	2026-08-17	13.0	Low
AVR0059	ALU0059	2026/2	Initial	2026-08-17	13.3	Low
AVR0060	ALU0060	2026/2	Initial	2026-08-17	42.2	High
AVR0061	ALU0061	2026/2	Initial	2026-08-17	46.0	High
AVR0062	ALU0062	2026/2	Initial	2026-08-17	23.9	Moderate
AVR0063	ALU0063	2026/2	Initial	2026-08-17	13.4	Low
AVR0064	ALU0064	2026/2	Initial	2026-08-17	48.7	High
AVR0065	ALU0065	2026/2	Initial	2026-08-17	20.4	Moderate
AVR0066	ALU0066	2026/2	Initial	2026-08-17	21.0	Moderate
AVR0067	ALU0067	2026/2	Initial	2026-08-17	42.1	High
AVR0068	ALU0068	2026/2	Initial	2026-08-17	3.5	Low
AVR0069	ALU0069	2026/2	Initial	2026-08-17	24.5	Moderate
AVR0070	ALU0070	2026/2	Initial	2026-08-17	21.0	Moderate
AVR0071	ALU0071	2026/2	Initial	2026-08-17	27.7	Moderate
AVR0072	ALU0072	2026/2	Initial	2026-08-17	30.8	Moderate
AVR0073	ALU0073	2026/2	Initial	2026-08-17	23.9	Moderate
AVR0074	ALU0074	2026/2	Initial	2026-08-17	15.8	Low
AVR0075	ALU0075	2026/2	Initial	2026-08-17	35.5	High
AVR0076	ALU0076	2026/2	Initial	2026-08-17	34.1	Moderate
AVR0077	ALU0077	2026/2	Initial	2026-08-17	33.8	Moderate
AVR0078	ALU0078	2026/2	Initial	2026-08-17	31.5	Moderate
AVR0079	ALU0079	2026/2	Initial	2026-08-17	22.6	Moderate
AVR0080	ALU0080	2026/2	Initial	2026-08-17	19.4	Low
AVR0081	ALU0081	2026/2	Initial	2026-08-17	42.0	High
AVR0082	ALU0082	2026/2	Initial	2026-08-17	5.0	Low
AVR0083	ALU0083	2026/2	Initial	2026-08-17	14.0	Low
AVR0084	ALU0084	2026/2	Initial	2026-08-17	26.2	Moderate
AVR0085	ALU0085	2026/2	Initial	2026-08-17	23.0	Moderate
AVR0086	ALU0086	2026/2	Initial	2026-08-17	13.9	Low
AVR0087	ALU0087	2026/2	Initial	2026-08-17	25.1	Moderate
AVR0088	ALU0088	2026/2	Initial	2026-08-17	25.0	Moderate
AVR0089	ALU0089	2026/2	Initial	2026-08-17	20.1	Moderate
AVR0090	ALU0090	2026/2	Initial	2026-08-17	25.4	Moderate
AVR0091	ALU0091	2026/2	Initial	2026-08-17	16.2	Low
AVR0092	ALU0092	2026/2	Initial	2026-08-17	10.0	Low
AVR0093	ALU0093	2026/2	Initial	2026-08-17	18.0	Low
AVR0094	ALU0094	2026/2	Initial	2026-08-17	24.1	Moderate
AVR0095	ALU0095	2026/2	Initial	2026-08-17	11.3	Low
AVR0096	ALU0096	2026/2	Initial	2026-08-17	23.3	Moderate
AVR0097	ALU0097	2026/2	Initial	2026-08-17	18.5	Low
AVR0098	ALU0098	2026/2	Initial	2026-08-17	30.0	Moderate
AVR0099	ALU0099	2026/2	Initial	2026-08-17	75.5	Critical
AVR0100	ALU0100	2026/2	Initial	2026-08-17	37.0	High
AVR0101	ALU0101	2026/2	Initial	2026-08-17	28.3	Moderate
AVR0102	ALU0102	2026/2	Initial	2026-08-17	7.5	Low
AVR0103	ALU0103	2026/2	Initial	2026-08-17	21.5	Moderate
AVR0104	ALU0104	2026/2	Initial	2026-08-17	23.4	Moderate
AVR0105	ALU0105	2026/2	Initial	2026-08-17	33.2	Moderate
AVR0106	ALU0106	2026/2	Initial	2026-08-17	15.0	Low
AVR0107	ALU0107	2026/2	Initial	2026-08-17	22.4	Moderate
AVR0108	ALU0108	2026/2	Initial	2026-08-17	34.8	Moderate
AVR0109	ALU0109	2026/2	Initial	2026-08-17	13.0	Low
AVR0110	ALU0110	2026/2	Initial	2026-08-17	11.0	Low
AVR0111	ALU0111	2026/2	Initial	2026-08-17	22.0	Moderate
AVR0112	ALU0112	2026/2	Initial	2026-08-17	19.9	Low
AVR0113	ALU0113	2026/2	Initial	2026-08-17	18.0	Low
AVR0114	ALU0114	2026/2	Initial	2026-08-17	18.0	Low
AVR0115	ALU0115	2026/2	Initial	2026-08-17	11.0	Low
AVR0116	ALU0116	2026/2	Initial	2026-08-17	78.0	Critical
AVR0117	ALU0117	2026/2	Initial	2026-08-17	26.0	Moderate
AVR0118	ALU0118	2026/2	Initial	2026-08-17	30.0	Moderate
AVR0119	ALU0119	2026/2	Initial	2026-08-17	20.0	Moderate
AVR0120	ALU0120	2026/2	Initial	2026-08-17	52.1	High
AVR0121	ALU0121	2026/2	Initial	2026-08-17	29.9	Moderate
AVR0122	ALU0122	2026/2	Initial	2026-08-17	19.5	Low
AVR0123	ALU0123	2026/2	Initial	2026-08-17	12.0	Low
AVR0124	ALU0124	2026/2	Initial	2026-08-17	10.0	Low
AVR0125	ALU0125	2026/2	Initial	2026-08-17	24.2	Moderate
AVR0126	ALU0126	2026/2	Initial	2026-08-17	2.5	Low
AVR0127	ALU0127	2026/2	Initial	2026-08-17	15.6	Low
AVR0128	ALU0128	2026/2	Initial	2026-08-17	29.4	Moderate
AVR0129	ALU0129	2026/2	Initial	2026-08-17	21.0	Moderate
AVR0130	ALU0130	2026/2	Initial	2026-08-17	41.8	High
AVR0131	ALU0131	2026/2	Initial	2026-08-17	14.0	Low
AVR0132	ALU0132	2026/2	Initial	2026-08-17	21.7	Moderate
AVR0133	ALU0133	2026/2	Initial	2026-08-17	10.3	Low
AVR0134	ALU0134	2026/2	Initial	2026-08-17	18.9	Low
AVR0135	ALU0135	2026/2	Initial	2026-08-17	12.4	Low
AVR0136	ALU0136	2026/2	Initial	2026-08-17	14.0	Low
AVR0137	ALU0137	2026/2	Initial	2026-08-17	32.1	Moderate
AVR0138	ALU0138	2026/2	Initial	2026-08-17	17.5	Low
AVR0139	ALU0139	2026/2	Initial	2026-08-17	16.0	Low
AVR0140	ALU0140	2026/2	Initial	2026-08-17	16.5	Low
AVR0141	ALU0141	2026/2	Initial	2026-08-17	37.5	High
AVR0142	ALU0142	2026/2	Initial	2026-08-17	13.4	Low
AVR0143	ALU0143	2026/2	Initial	2026-08-17	15.0	Low
AVR0144	ALU0144	2026/2	Initial	2026-08-17	16.8	Low
AVR0145	ALU0145	2026/2	Initial	2026-08-17	39.6	High
AVR0146	ALU0146	2026/2	Initial	2026-08-17	23.6	Moderate
AVR0147	ALU0147	2026/2	Initial	2026-08-17	21.1	Moderate
AVR0148	ALU0148	2026/2	Initial	2026-08-17	31.9	Moderate
AVR0149	ALU0149	2026/2	Initial	2026-08-17	27.7	Moderate
AVR0150	ALU0150	2026/2	Initial	2026-08-17	46.0	High
AVR0151	ALU0151	2026/2	Initial	2026-08-17	62.6	Critical
AVR0152	ALU0152	2026/2	Initial	2026-08-17	16.4	Low
AVR0153	ALU0153	2026/2	Initial	2026-08-17	20.5	Moderate
AVR0154	ALU0154	2026/2	Initial	2026-08-17	21.6	Moderate
AVR0155	ALU0155	2026/2	Initial	2026-08-17	56.1	Critical
AVR0156	ALU0156	2026/2	Initial	2026-08-17	46.0	High
AVR0157	ALU0157	2026/2	Initial	2026-08-17	36.6	High
AVR0158	ALU0158	2026/2	Initial	2026-08-17	25.0	Moderate
AVR0159	ALU0159	2026/2	Initial	2026-08-17	13.3	Low
AVR0160	ALU0160	2026/2	Initial	2026-08-17	30.5	Moderate
AVR0161	ALU0161	2026/2	Initial	2026-08-17	23.0	Moderate
AVR0162	ALU0162	2026/2	Initial	2026-08-17	10.0	Low
AVR0163	ALU0163	2026/2	Initial	2026-08-17	27.7	Moderate
AVR0164	ALU0164	2026/2	Initial	2026-08-17	21.0	Moderate
AVR0165	ALU0165	2026/2	Initial	2026-08-17	32.3	Moderate
AVR0166	ALU0166	2026/2	Initial	2026-08-17	33.9	Moderate
AVR0167	ALU0167	2026/2	Initial	2026-08-17	17.0	Low
AVR0168	ALU0168	2026/2	Initial	2026-08-17	35.7	High
AVR0169	ALU0169	2026/2	Initial	2026-08-17	28.5	Moderate
AVR0170	ALU0170	2026/2	Initial	2026-08-17	43.7	High
AVR0171	ALU0171	2026/2	Initial	2026-08-17	37.8	High
AVR0172	ALU0172	2026/2	Initial	2026-08-17	7.7	Low
AVR0173	ALU0173	2026/2	Initial	2026-08-17	5.0	Low
AVR0174	ALU0174	2026/2	Initial	2026-08-17	36.5	High
AVR0175	ALU0175	2026/2	Initial	2026-08-17	18.0	Low
AVR0176	ALU0176	2026/2	Initial	2026-08-17	16.7	Low
AVR0177	ALU0177	2026/2	Initial	2026-08-17	46.4	High
AVR0178	ALU0178	2026/2	Initial	2026-08-17	20.9	Moderate
AVR0179	ALU0179	2026/2	Initial	2026-08-17	47.8	High
AVR0180	ALU0180	2026/2	Initial	2026-08-17	17.0	Low
AVR0181	ALU0181	2026/2	Initial	2026-08-17	33.3	Moderate
AVR0182	ALU0182	2026/2	Initial	2026-08-17	19.0	Low
AVR0183	ALU0183	2026/2	Initial	2026-08-17	26.5	Moderate
AVR0184	ALU0184	2026/2	Initial	2026-08-17	7.5	Low
AVR0185	ALU0185	2026/2	Initial	2026-08-17	54.1	High
AVR0186	ALU0186	2026/2	Initial	2026-08-17	27.9	Moderate
AVR0187	ALU0187	2026/2	Initial	2026-08-17	30.3	Moderate
AVR0188	ALU0188	2026/2	Initial	2026-08-17	6.5	Low
AVR0189	ALU0189	2026/2	Initial	2026-08-17	28.2	Moderate
AVR0190	ALU0190	2026/2	Initial	2026-08-17	32.6	Moderate
AVR0191	ALU0191	2026/2	Initial	2026-08-17	20.9	Moderate
AVR0192	ALU0192	2026/2	Initial	2026-08-17	25.7	Moderate
AVR0193	ALU0193	2026/2	Initial	2026-08-17	32.0	Moderate
AVR0194	ALU0194	2026/2	Initial	2026-08-17	16.5	Low
AVR0195	ALU0195	2026/2	Initial	2026-08-17	24.0	Moderate
AVR0196	ALU0196	2026/2	Initial	2026-08-17	20.7	Moderate
AVR0197	ALU0197	2026/2	Initial	2026-08-17	15.8	Low
AVR0198	ALU0198	2026/2	Initial	2026-08-17	10.0	Low
AVR0199	ALU0199	2026/2	Initial	2026-08-17	38.0	High
AVR0200	ALU0200	2026/2	Initial	2026-08-17	28.5	Moderate
AVR0201	ALU0201	2026/2	Initial	2026-08-17	76.5	Critical
AVR0202	ALU0202	2026/2	Initial	2026-08-17	18.3	Low
AVR0203	ALU0203	2026/2	Initial	2026-08-17	23.5	Moderate
AVR0204	ALU0204	2026/2	Initial	2026-08-17	31.8	Moderate
AVR0205	ALU0205	2026/2	Initial	2026-08-17	11.0	Low
AVR0206	ALU0206	2026/2	Initial	2026-08-17	18.5	Low
AVR0207	ALU0207	2026/2	Initial	2026-08-17	13.0	Low
AVR0208	ALU0208	2026/2	Initial	2026-08-17	36.9	High
AVR0209	ALU0209	2026/2	Initial	2026-08-17	15.7	Low
AVR0210	ALU0210	2026/2	Initial	2026-08-17	18.0	Low
AVR0211	ALU0211	2026/2	Initial	2026-08-17	29.7	Moderate
AVR0212	ALU0212	2026/2	Initial	2026-08-17	43.5	High
AVR0213	ALU0213	2026/2	Initial	2026-08-17	28.0	Moderate
AVR0214	ALU0214	2026/2	Initial	2026-08-17	37.8	High
AVR0215	ALU0215	2026/2	Initial	2026-08-17	33.7	Moderate
AVR0216	ALU0216	2026/2	Initial	2026-08-17	23.7	Moderate
AVR0217	ALU0217	2026/2	Initial	2026-08-17	23.5	Moderate
AVR0218	ALU0218	2026/2	Initial	2026-08-17	29.2	Moderate
AVR0219	ALU0219	2026/2	Initial	2026-08-17	15.8	Low
AVR0220	ALU0220	2026/2	Initial	2026-08-17	54.9	High
AVR0221	ALU0221	2026/2	Initial	2026-08-17	17.0	Low
AVR0222	ALU0222	2026/2	Initial	2026-08-17	18.6	Low
AVR0223	ALU0223	2026/2	Initial	2026-08-17	15.0	Low
AVR0224	ALU0224	2026/2	Initial	2026-08-17	38.0	High
AVR0225	ALU0225	2026/2	Initial	2026-08-17	47.1	High
AVR0226	ALU0226	2026/2	Initial	2026-08-17	11.6	Low
AVR0227	ALU0227	2026/2	Initial	2026-08-17	20.0	Moderate
AVR0228	ALU0228	2026/2	Initial	2026-08-17	17.0	Low
AVR0229	ALU0229	2026/2	Initial	2026-08-17	0.0	Low
AVR0230	ALU0230	2026/2	Initial	2026-08-17	22.1	Moderate
AVR0231	ALU0231	2026/2	Initial	2026-08-17	18.0	Low
AVR0232	ALU0232	2026/2	Initial	2026-08-17	30.6	Moderate
AVR0233	ALU0233	2026/2	Initial	2026-08-17	29.3	Moderate
AVR0234	ALU0234	2026/2	Initial	2026-08-17	21.0	Moderate
AVR0235	ALU0235	2026/2	Initial	2026-08-17	19.4	Low
AVR0236	ALU0236	2026/2	Initial	2026-08-17	17.0	Low
AVR0237	ALU0237	2026/2	Initial	2026-08-17	33.5	Moderate
AVR0238	ALU0238	2026/2	Initial	2026-08-17	37.5	High
AVR0239	ALU0239	2026/2	Initial	2026-08-17	25.5	Moderate
AVR0240	ALU0240	2026/2	Initial	2026-08-17	16.5	Low
AVR0241	ALU0241	2026/2	Initial	2026-08-17	31.5	Moderate
AVR0242	ALU0242	2026/2	Initial	2026-08-17	25.7	Moderate
AVR0243	ALU0243	2026/2	Initial	2026-08-17	27.1	Moderate
AVR0244	ALU0244	2026/2	Initial	2026-08-17	8.8	Low
AVR0245	ALU0245	2026/2	Initial	2026-08-17	16.5	Low
AVR0246	ALU0246	2026/2	Initial	2026-08-17	22.1	Moderate
AVR0247	ALU0247	2026/2	Initial	2026-08-17	23.0	Moderate
AVR0248	ALU0248	2026/2	Initial	2026-08-17	20.2	Moderate
AVR0249	ALU0249	2026/2	Initial	2026-08-17	21.8	Moderate
AVR0250	ALU0250	2026/2	Initial	2026-08-17	31.9	Moderate
AVR0251	ALU0251	2026/2	Initial	2026-08-17	33.3	Moderate
AVR0252	ALU0252	2026/2	Initial	2026-08-17	9.6	Low
AVR0253	ALU0253	2026/2	Initial	2026-08-17	33.4	Moderate
AVR0254	ALU0254	2026/2	Initial	2026-08-17	18.0	Low
AVR0255	ALU0255	2026/2	Initial	2026-08-17	25.5	Moderate
AVR0256	ALU0256	2026/2	Initial	2026-08-17	22.6	Moderate
AVR0257	ALU0257	2026/2	Initial	2026-08-17	34.0	Moderate
AVR0258	ALU0258	2026/2	Initial	2026-08-17	39.1	High
AVR0259	ALU0259	2026/2	Initial	2026-08-17	11.4	Low
AVR0260	ALU0260	2026/2	Initial	2026-08-17	19.0	Low
AVR0261	ALU0261	2026/2	Initial	2026-08-17	14.0	Low
AVR0262	ALU0262	2026/2	Initial	2026-08-17	32.0	Moderate
AVR0263	ALU0263	2026/2	Initial	2026-08-17	40.2	High
AVR0264	ALU0264	2026/2	Initial	2026-08-17	8.5	Low
AVR0265	ALU0265	2026/2	Initial	2026-08-17	15.5	Low
AVR0266	ALU0266	2026/2	Initial	2026-08-17	7.5	Low
AVR0267	ALU0267	2026/2	Initial	2026-08-17	13.0	Low
AVR0268	ALU0268	2026/2	Initial	2026-08-17	29.5	Moderate
AVR0269	ALU0269	2026/2	Initial	2026-08-17	34.4	Moderate
AVR0270	ALU0270	2026/2	Initial	2026-08-17	38.0	High
AVR0271	ALU0271	2026/2	Initial	2026-08-17	17.0	Low
AVR0272	ALU0272	2026/2	Initial	2026-08-17	47.5	High
AVR0273	ALU0273	2026/2	Initial	2026-08-17	41.0	High
AVR0274	ALU0274	2026/2	Initial	2026-08-17	23.9	Moderate
AVR0275	ALU0275	2026/2	Initial	2026-08-17	42.1	High
AVR0276	ALU0276	2026/2	Initial	2026-08-17	20.5	Moderate
AVR0277	ALU0277	2026/2	Initial	2026-08-17	28.0	Moderate
AVR0278	ALU0278	2026/2	Initial	2026-08-17	36.0	High
AVR0279	ALU0279	2026/2	Initial	2026-08-17	29.6	Moderate
AVR0280	ALU0280	2026/2	Initial	2026-08-17	12.5	Low
AVR0281	ALU0281	2026/2	Initial	2026-08-17	22.5	Moderate
AVR0282	ALU0282	2026/2	Initial	2026-08-17	69.5	Critical
AVR0283	ALU0283	2026/2	Initial	2026-08-17	58.9	Critical
AVR0284	ALU0284	2026/2	Initial	2026-08-17	26.0	Moderate
AVR0285	ALU0285	2026/2	Initial	2026-08-17	10.0	Low
AVR0286	ALU0286	2026/2	Initial	2026-08-17	37.0	High
AVR0287	ALU0287	2026/2	Initial	2026-08-17	20.0	Moderate
AVR0288	ALU0288	2026/2	Initial	2026-08-17	19.4	Low
AVR0289	ALU0289	2026/2	Initial	2026-08-17	12.5	Low
AVR0290	ALU0290	2026/2	Initial	2026-08-17	25.9	Moderate
AVR0291	ALU0291	2026/2	Initial	2026-08-17	22.5	Moderate
AVR0292	ALU0292	2026/2	Initial	2026-08-17	25.5	Moderate
AVR0293	ALU0293	2026/2	Initial	2026-08-17	0.0	Low
AVR0294	ALU0294	2026/2	Initial	2026-08-17	20.3	Moderate
AVR0295	ALU0295	2026/2	Initial	2026-08-17	44.4	High
AVR0296	ALU0296	2026/2	Initial	2026-08-17	21.0	Moderate
AVR0297	ALU0297	2026/2	Initial	2026-08-17	48.1	High
AVR0298	ALU0298	2026/2	Initial	2026-08-17	16.5	Low
AVR0299	ALU0299	2026/2	Initial	2026-08-17	19.0	Low
AVR0300	ALU0300	2026/2	Initial	2026-08-17	18.5	Low
AVR0301	ALU0301	2026/2	Initial	2026-08-17	16.0	Low
AVR0302	ALU0302	2026/2	Initial	2026-08-17	24.5	Moderate
AVR0303	ALU0303	2026/2	Initial	2026-08-17	15.0	Low
AVR0304	ALU0304	2026/2	Initial	2026-08-17	14.8	Low
AVR0305	ALU0305	2026/2	Initial	2026-08-17	38.5	High
AVR0306	ALU0306	2026/2	Initial	2026-08-17	31.9	Moderate
AVR0307	ALU0307	2026/2	Initial	2026-08-17	40.9	High
AVR0308	ALU0308	2026/2	Initial	2026-08-17	33.9	Moderate
AVR0309	ALU0309	2026/2	Initial	2026-08-17	26.4	Moderate
AVR0310	ALU0310	2026/2	Initial	2026-08-17	27.4	Moderate
AVR0311	ALU0311	2026/2	Initial	2026-08-17	29.5	Moderate
AVR0312	ALU0312	2026/2	Initial	2026-08-17	22.5	Moderate
AVR0313	ALU0313	2026/2	Initial	2026-08-17	20.3	Moderate
AVR0314	ALU0314	2026/2	Initial	2026-08-17	36.9	High
AVR0315	ALU0315	2026/2	Initial	2026-08-17	20.0	Moderate
AVR0316	ALU0316	2026/2	Initial	2026-08-17	16.5	Low
AVR0317	ALU0317	2026/2	Initial	2026-08-17	14.7	Low
AVR0318	ALU0318	2026/2	Initial	2026-08-17	52.2	High
AVR0319	ALU0319	2026/2	Initial	2026-08-17	20.7	Moderate
AVR0320	ALU0320	2026/2	Initial	2026-08-17	30.0	Moderate
AVR0321	ALU0321	2026/2	Initial	2026-08-17	38.0	High
AVR0322	ALU0322	2026/2	Initial	2026-08-17	38.0	High
AVR0323	ALU0323	2026/2	Initial	2026-08-17	22.5	Moderate
AVR0324	ALU0324	2026/2	Initial	2026-08-17	20.5	Moderate
AVR0325	ALU0325	2026/2	Initial	2026-08-17	6.2	Low
AVR0326	ALU0326	2026/2	Initial	2026-08-17	9.5	Low
AVR0327	ALU0327	2026/2	Initial	2026-08-17	19.9	Low
AVR0328	ALU0328	2026/2	Initial	2026-08-17	16.5	Low
AVR0329	ALU0329	2026/2	Initial	2026-08-17	24.1	Moderate
AVR0330	ALU0330	2026/2	Initial	2026-08-17	21.7	Moderate
AVR0331	ALU0331	2026/2	Initial	2026-08-17	32.5	Moderate
AVR0332	ALU0332	2026/2	Initial	2026-08-17	39.0	High
AVR0333	ALU0333	2026/2	Initial	2026-08-17	8.1	Low
AVR0334	ALU0334	2026/2	Initial	2026-08-17	15.0	Low
AVR0335	ALU0335	2026/2	Initial	2026-08-17	4.0	Low
AVR0336	ALU0336	2026/2	Initial	2026-08-17	45.2	High
AVR0337	ALU0337	2026/2	Initial	2026-08-17	32.8	Moderate
AVR0338	ALU0338	2026/2	Initial	2026-08-17	16.5	Low
AVR0339	ALU0339	2026/2	Initial	2026-08-17	10.0	Low
AVR0340	ALU0340	2026/2	Initial	2026-08-17	17.5	Low
AVR0341	ALU0341	2026/2	Initial	2026-08-17	12.0	Low
AVR0342	ALU0342	2026/2	Initial	2026-08-17	39.0	High
AVR0343	ALU0343	2026/2	Initial	2026-08-17	10.0	Low
AVR0344	ALU0344	2026/2	Initial	2026-08-17	38.3	High
AVR0345	ALU0345	2026/2	Initial	2026-08-17	24.6	Moderate
AVR0346	ALU0346	2026/2	Initial	2026-08-17	33.6	Moderate
AVR0347	ALU0347	2026/2	Initial	2026-08-17	40.0	High
AVR0348	ALU0348	2026/2	Initial	2026-08-17	59.8	Critical
AVR0349	ALU0349	2026/2	Initial	2026-08-17	23.0	Moderate
AVR0350	ALU0350	2026/2	Initial	2026-08-17	19.4	Low
AVR0351	ALU0351	2026/2	Initial	2026-08-17	24.0	Moderate
AVR0352	ALU0352	2026/2	Initial	2026-08-17	48.2	High
AVR0353	ALU0353	2026/2	Initial	2026-08-17	34.8	Moderate
AVR0354	ALU0354	2026/2	Initial	2026-08-17	34.0	Moderate
AVR0355	ALU0355	2026/2	Initial	2026-08-17	33.7	Moderate
AVR0356	ALU0356	2026/2	Initial	2026-08-17	14.0	Low
AVR0357	ALU0357	2026/2	Initial	2026-08-17	18.5	Low
AVR0358	ALU0358	2026/2	Initial	2026-08-17	30.4	Moderate
AVR0359	ALU0359	2026/2	Initial	2026-08-17	17.5	Low
AVR0360	ALU0360	2026/2	Initial	2026-08-17	15.0	Low
AVR0361	ALU0361	2026/2	Initial	2026-08-17	37.4	High
AVR0362	ALU0362	2026/2	Initial	2026-08-17	4.9	Low
AVR0363	ALU0363	2026/2	Initial	2026-08-17	17.5	Low
AVR0364	ALU0364	2026/2	Initial	2026-08-17	29.0	Moderate
AVR0365	ALU0365	2026/2	Initial	2026-08-17	19.9	Low
AVR0366	ALU0366	2026/2	Initial	2026-08-17	23.2	Moderate
AVR0367	ALU0367	2026/2	Initial	2026-08-17	26.2	Moderate
AVR0368	ALU0368	2026/2	Initial	2026-08-17	12.5	Low
AVR0369	ALU0369	2026/2	Initial	2026-08-17	28.9	Moderate
AVR0370	ALU0370	2026/2	Initial	2026-08-17	15.0	Low
AVR0371	ALU0371	2026/2	Initial	2026-08-17	35.8	High
AVR0372	ALU0372	2026/2	Initial	2026-08-17	29.5	Moderate
AVR0373	ALU0373	2026/2	Initial	2026-08-17	37.6	High
AVR0374	ALU0374	2026/2	Initial	2026-08-17	30.1	Moderate
AVR0375	ALU0375	2026/2	Initial	2026-08-17	10.0	Low
AVR0376	ALU0376	2026/2	Initial	2026-08-17	15.5	Low
AVR0377	ALU0377	2026/2	Initial	2026-08-17	45.2	High
AVR0378	ALU0378	2026/2	Initial	2026-08-17	29.4	Moderate
AVR0379	ALU0379	2026/2	Initial	2026-08-17	18.6	Low
AVR0380	ALU0380	2026/2	Initial	2026-08-17	30.8	Moderate
AVR0381	ALU0381	2026/2	Initial	2026-08-17	17.0	Low
AVR0382	ALU0382	2026/2	Initial	2026-08-17	10.0	Low
AVR0383	ALU0383	2026/2	Initial	2026-08-17	12.0	Low
AVR0384	ALU0384	2026/2	Initial	2026-08-17	40.9	High
AVR0385	ALU0385	2026/2	Initial	2026-08-17	2.5	Low
AVR0386	ALU0386	2026/2	Initial	2026-08-17	23.2	Moderate
AVR0387	ALU0387	2026/2	Initial	2026-08-17	49.6	High
AVR0388	ALU0388	2026/2	Initial	2026-08-17	20.0	Moderate
AVR0389	ALU0389	2026/2	Initial	2026-08-17	5.8	Low
AVR0390	ALU0390	2026/2	Initial	2026-08-17	36.0	High
AVR0391	ALU0391	2026/2	Initial	2026-08-17	10.0	Low
AVR0392	ALU0392	2026/2	Initial	2026-08-17	36.6	High
AVR0393	ALU0393	2026/2	Initial	2026-08-17	18.0	Low
AVR0394	ALU0394	2026/2	Initial	2026-08-17	31.0	Moderate
AVR0395	ALU0395	2026/2	Initial	2026-08-17	16.4	Low
AVR0396	ALU0396	2026/2	Initial	2026-08-17	32.0	Moderate
AVR0397	ALU0397	2026/2	Initial	2026-08-17	15.6	Low
AVR0398	ALU0398	2026/2	Initial	2026-08-17	29.2	Moderate
AVR0399	ALU0399	2026/2	Initial	2026-08-17	14.6	Low
AVR0400	ALU0400	2026/2	Initial	2026-08-17	21.0	Moderate
AVR0401	ALU0401	2026/2	Initial	2026-08-17	40.9	High
AVR0402	ALU0402	2026/2	Initial	2026-08-17	23.5	Moderate
AVR0403	ALU0403	2026/2	Initial	2026-08-17	37.6	High
AVR0404	ALU0404	2026/2	Initial	2026-08-17	19.8	Low
AVR0405	ALU0405	2026/2	Initial	2026-08-17	13.3	Low
AVR0406	ALU0406	2026/2	Initial	2026-08-17	16.0	Low
AVR0407	ALU0407	2026/2	Initial	2026-08-17	36.0	High
AVR0408	ALU0408	2026/2	Initial	2026-08-17	37.6	High
AVR0409	ALU0409	2026/2	Initial	2026-08-17	35.8	High
AVR0410	ALU0410	2026/2	Initial	2026-08-17	32.7	Moderate
AVR0411	ALU0411	2026/2	Initial	2026-08-17	28.3	Moderate
AVR0412	ALU0412	2026/2	Initial	2026-08-17	66.8	Critical
AVR0413	ALU0413	2026/2	Initial	2026-08-17	15.9	Low
AVR0414	ALU0414	2026/2	Initial	2026-08-17	23.5	Moderate
AVR0415	ALU0415	2026/2	Initial	2026-08-17	25.7	Moderate
AVR0416	ALU0416	2026/2	Initial	2026-08-17	13.3	Low
AVR0417	ALU0417	2026/2	Initial	2026-08-17	68.6	Critical
AVR0418	ALU0418	2026/2	Initial	2026-08-17	28.1	Moderate
AVR0419	ALU0419	2026/2	Initial	2026-08-17	21.6	Moderate
AVR0420	ALU0420	2026/2	Initial	2026-08-17	20.5	Moderate
AVR0421	ALU0421	2026/2	Initial	2026-08-17	26.5	Moderate
AVR0422	ALU0422	2026/2	Initial	2026-08-17	11.6	Low
AVR0423	ALU0423	2026/2	Initial	2026-08-17	12.5	Low
AVR0424	ALU0424	2026/2	Initial	2026-08-17	7.0	Low
AVR0425	ALU0425	2026/2	Initial	2026-08-17	34.0	Moderate
AVR0426	ALU0426	2026/2	Initial	2026-08-17	38.1	High
AVR0427	ALU0427	2026/2	Initial	2026-08-17	18.5	Low
AVR0428	ALU0428	2026/2	Initial	2026-08-17	18.4	Low
AVR0429	ALU0429	2026/2	Initial	2026-08-17	18.2	Low
AVR0430	ALU0430	2026/2	Initial	2026-08-17	43.9	High
AVR0431	ALU0431	2026/2	Initial	2026-08-17	19.5	Low
AVR0432	ALU0432	2026/2	Initial	2026-08-17	29.2	Moderate
AVR0433	ALU0433	2026/2	Initial	2026-08-17	27.0	Moderate
AVR0434	ALU0434	2026/2	Initial	2026-08-17	12.5	Low
AVR0435	ALU0435	2026/2	Initial	2026-08-17	31.5	Moderate
AVR0436	ALU0436	2026/2	Initial	2026-08-17	2.5	Low
AVR0437	ALU0437	2026/2	Initial	2026-08-17	44.3	High
AVR0438	ALU0438	2026/2	Initial	2026-08-17	19.5	Low
AVR0439	ALU0439	2026/2	Initial	2026-08-17	27.6	Moderate
AVR0440	ALU0440	2026/2	Initial	2026-08-17	29.5	Moderate
AVR0441	ALU0441	2026/2	Initial	2026-08-17	20.0	Moderate
AVR0442	ALU0442	2026/2	Initial	2026-08-17	38.3	High
AVR0443	ALU0443	2026/2	Initial	2026-08-17	38.0	High
AVR0444	ALU0444	2026/2	Initial	2026-08-17	10.0	Low
AVR0445	ALU0445	2026/2	Initial	2026-08-17	40.8	High
AVR0446	ALU0446	2026/2	Initial	2026-08-17	15.0	Low
AVR0447	ALU0447	2026/2	Initial	2026-08-17	44.8	High
AVR0448	ALU0448	2026/2	Initial	2026-08-17	17.8	Low
AVR0449	ALU0449	2026/2	Initial	2026-08-17	12.5	Low
AVR0450	ALU0450	2026/2	Initial	2026-08-17	30.8	Moderate
AVR0451	ALU0451	2026/2	Initial	2026-08-17	28.9	Moderate
AVR0452	ALU0452	2026/2	Initial	2026-08-17	17.0	Low
AVR0453	ALU0453	2026/2	Initial	2026-08-17	21.3	Moderate
AVR0454	ALU0454	2026/2	Initial	2026-08-17	38.5	High
AVR0455	ALU0455	2026/2	Initial	2026-08-17	45.9	High
AVR0456	ALU0456	2026/2	Initial	2026-08-17	28.5	Moderate
AVR0457	ALU0457	2026/2	Initial	2026-08-17	33.2	Moderate
AVR0458	ALU0458	2026/2	Initial	2026-08-17	15.7	Low
AVR0459	ALU0459	2026/2	Initial	2026-08-17	49.6	High
AVR0460	ALU0460	2026/2	Initial	2026-08-17	35.3	High
AVR0461	ALU0461	2026/2	Initial	2026-08-17	15.7	Low
AVR0462	ALU0462	2026/2	Initial	2026-08-17	20.0	Moderate
AVR0463	ALU0463	2026/2	Initial	2026-08-17	34.9	Moderate
AVR0464	ALU0464	2026/2	Initial	2026-08-17	34.7	Moderate
AVR0465	ALU0465	2026/2	Initial	2026-08-17	38.4	High
AVR0466	ALU0466	2026/2	Initial	2026-08-17	43.0	High
AVR0467	ALU0467	2026/2	Initial	2026-08-17	14.6	Low
AVR0468	ALU0468	2026/2	Initial	2026-08-17	29.9	Moderate
AVR0469	ALU0469	2026/2	Initial	2026-08-17	14.0	Low
AVR0470	ALU0470	2026/2	Initial	2026-08-17	36.0	High
AVR0471	ALU0471	2026/2	Initial	2026-08-17	14.0	Low
AVR0472	ALU0472	2026/2	Initial	2026-08-17	5.0	Low
AVR0473	ALU0473	2026/2	Initial	2026-08-17	64.4	Critical
AVR0474	ALU0474	2026/2	Initial	2026-08-17	34.1	Moderate
AVR0475	ALU0475	2026/2	Initial	2026-08-17	14.0	Low
AVR0476	ALU0476	2026/2	Initial	2026-08-17	30.0	Moderate
AVR0477	ALU0477	2026/2	Initial	2026-08-17	17.0	Low
AVR0478	ALU0478	2026/2	Initial	2026-08-17	27.8	Moderate
AVR0479	ALU0479	2026/2	Initial	2026-08-17	10.0	Low
AVR0480	ALU0480	2026/2	Initial	2026-08-17	10.0	Low
AVR0481	ALU0481	2026/2	Initial	2026-08-17	15.5	Low
AVR0482	ALU0482	2026/2	Initial	2026-08-17	22.5	Moderate
AVR0483	ALU0483	2026/2	Initial	2026-08-17	26.3	Moderate
AVR0484	ALU0484	2026/2	Initial	2026-08-17	32.2	Moderate
AVR0485	ALU0485	2026/2	Initial	2026-08-17	27.5	Moderate
AVR0486	ALU0486	2026/2	Initial	2026-08-17	7.5	Low
AVR0487	ALU0487	2026/2	Initial	2026-08-17	14.0	Low
AVR0488	ALU0488	2026/2	Initial	2026-08-17	22.8	Moderate
AVR0489	ALU0489	2026/2	Initial	2026-08-17	30.0	Moderate
AVR0490	ALU0490	2026/2	Initial	2026-08-17	4.0	Low
AVR0491	ALU0491	2026/2	Initial	2026-08-17	10.8	Low
AVR0492	ALU0492	2026/2	Initial	2026-08-17	20.0	Moderate
AVR0493	ALU0493	2026/2	Initial	2026-08-17	20.0	Moderate
AVR0494	ALU0494	2026/2	Initial	2026-08-17	15.5	Low
AVR0495	ALU0495	2026/2	Initial	2026-08-17	31.3	Moderate
AVR0496	ALU0496	2026/2	Initial	2026-08-17	12.5	Low
AVR0497	ALU0497	2026/2	Initial	2026-08-17	8.0	Low
AVR0498	ALU0498	2026/2	Initial	2026-08-17	16.8	Low
AVR0499	ALU0499	2026/2	Initial	2026-08-17	25.8	Moderate
AVR0500	ALU0500	2026/2	Initial	2026-08-17	18.6	Low
AVR0501	ALU0501	2026/2	Initial	2026-08-17	59.9	Critical
AVR0502	ALU0502	2026/2	Initial	2026-08-17	47.1	High
AVR0503	ALU0503	2026/2	Initial	2026-08-17	40.8	High
AVR0504	ALU0504	2026/2	Initial	2026-08-17	12.4	Low
AVR0505	ALU0505	2026/2	Initial	2026-08-17	49.3	High
AVR0506	ALU0506	2026/2	Initial	2026-08-17	39.5	High
AVR0507	ALU0507	2026/2	Initial	2026-08-17	15.0	Low
AVR0508	ALU0508	2026/2	Initial	2026-08-17	21.9	Moderate
AVR0509	ALU0509	2026/2	Initial	2026-08-17	16.2	Low
AVR0510	ALU0510	2026/2	Initial	2026-08-17	1.4	Low
AVR0511	ALU0511	2026/2	Initial	2026-08-17	18.0	Low
AVR0512	ALU0512	2026/2	Initial	2026-08-17	2.5	Low
AVR0513	ALU0513	2026/2	Initial	2026-08-17	21.2	Moderate
AVR0514	ALU0514	2026/2	Initial	2026-08-17	20.9	Moderate
AVR0515	ALU0515	2026/2	Initial	2026-08-17	12.5	Low
AVR0516	ALU0516	2026/2	Initial	2026-08-17	21.6	Moderate
AVR0517	ALU0517	2026/2	Initial	2026-08-17	33.8	Moderate
AVR0518	ALU0518	2026/2	Initial	2026-08-17	14.0	Low
AVR0519	ALU0519	2026/2	Initial	2026-08-17	23.0	Moderate
AVR0520	ALU0520	2026/2	Initial	2026-08-17	28.3	Moderate
AVR0521	ALU0521	2026/2	Initial	2026-08-17	37.6	High
AVR0522	ALU0522	2026/2	Initial	2026-08-17	12.5	Low
AVR0523	ALU0523	2026/2	Initial	2026-08-17	36.7	High
AVR0524	ALU0524	2026/2	Initial	2026-08-17	57.8	Critical
AVR0525	ALU0525	2026/2	Initial	2026-08-17	22.2	Moderate
AVR0526	ALU0526	2026/2	Initial	2026-08-17	19.3	Low
AVR0527	ALU0527	2026/2	Initial	2026-08-17	11.0	Low
AVR0528	ALU0528	2026/2	Initial	2026-08-17	32.6	Moderate
AVR0529	ALU0529	2026/2	Initial	2026-08-17	18.9	Low
AVR0530	ALU0530	2026/2	Initial	2026-08-17	30.1	Moderate
AVR0531	ALU0531	2026/2	Initial	2026-08-17	17.6	Low
AVR0532	ALU0532	2026/2	Initial	2026-08-17	73.8	Critical
AVR0533	ALU0533	2026/2	Initial	2026-08-17	15.8	Low
AVR0534	ALU0534	2026/2	Initial	2026-08-17	24.8	Moderate
AVR0535	ALU0535	2026/2	Initial	2026-08-17	70.2	Critical
AVR0536	ALU0536	2026/2	Initial	2026-08-17	36.9	High
AVR0537	ALU0537	2026/2	Initial	2026-08-17	22.4	Moderate
AVR0538	ALU0538	2026/2	Initial	2026-08-17	12.5	Low
AVR0539	ALU0539	2026/2	Initial	2026-08-17	27.5	Moderate
AVR0540	ALU0540	2026/2	Initial	2026-08-17	22.3	Moderate
AVR0541	ALU0541	2026/2	Initial	2026-08-17	43.4	High
AVR0542	ALU0542	2026/2	Initial	2026-08-17	34.5	Moderate
AVR0543	ALU0543	2026/2	Initial	2026-08-17	22.3	Moderate
AVR0544	ALU0544	2026/2	Initial	2026-08-17	21.4	Moderate
AVR0545	ALU0545	2026/2	Initial	2026-08-17	24.3	Moderate
AVR0546	ALU0546	2026/2	Initial	2026-08-17	28.9	Moderate
AVR0547	ALU0547	2026/2	Initial	2026-08-17	57.2	Critical
AVR0548	ALU0548	2026/2	Initial	2026-08-17	58.1	Critical
AVR0549	ALU0549	2026/2	Initial	2026-08-17	26.7	Moderate
AVR0550	ALU0550	2026/2	Initial	2026-08-17	49.9	High
AVR0551	ALU0551	2026/2	Initial	2026-08-17	7.5	Low
AVR0552	ALU0552	2026/2	Initial	2026-08-17	25.7	Moderate
AVR0553	ALU0553	2026/2	Initial	2026-08-17	37.1	High
AVR0554	ALU0554	2026/2	Initial	2026-08-17	22.0	Moderate
AVR0555	ALU0555	2026/2	Initial	2026-08-17	5.0	Low
AVR0556	ALU0556	2026/2	Initial	2026-08-17	12.7	Low
AVR0557	ALU0557	2026/2	Initial	2026-08-17	19.0	Low
AVR0558	ALU0558	2026/2	Initial	2026-08-17	22.7	Moderate
AVR0559	ALU0559	2026/2	Initial	2026-08-17	14.0	Low
AVR0560	ALU0560	2026/2	Initial	2026-08-17	20.0	Moderate
AVR0561	ALU0561	2026/2	Initial	2026-08-17	4.0	Low
AVR0562	ALU0562	2026/2	Initial	2026-08-17	26.9	Moderate
AVR0563	ALU0563	2026/2	Initial	2026-08-17	16.0	Low
AVR0564	ALU0564	2026/2	Initial	2026-08-17	40.5	High
AVR0565	ALU0565	2026/2	Initial	2026-08-17	12.5	Low
AVR0566	ALU0566	2026/2	Initial	2026-08-17	26.1	Moderate
AVR0567	ALU0567	2026/2	Initial	2026-08-17	7.4	Low
AVR0568	ALU0568	2026/2	Initial	2026-08-17	25.4	Moderate
AVR0569	ALU0569	2026/2	Initial	2026-08-17	56.2	Critical
AVR0570	ALU0570	2026/2	Initial	2026-08-17	32.9	Moderate
AVR0571	ALU0571	2026/2	Initial	2026-08-17	20.2	Moderate
AVR0572	ALU0572	2026/2	Initial	2026-08-17	60.2	Critical
AVR0573	ALU0573	2026/2	Initial	2026-08-17	35.1	High
AVR0574	ALU0574	2026/2	Initial	2026-08-17	16.0	Low
AVR0575	ALU0575	2026/2	Initial	2026-08-17	19.1	Low
AVR0576	ALU0576	2026/2	Initial	2026-08-17	27.5	Moderate
AVR0577	ALU0577	2026/2	Initial	2026-08-17	22.6	Moderate
AVR0578	ALU0578	2026/2	Initial	2026-08-17	26.3	Moderate
AVR0579	ALU0579	2026/2	Initial	2026-08-17	46.8	High
AVR0580	ALU0580	2026/2	Initial	2026-08-17	18.5	Low
AVR0581	ALU0581	2026/2	Initial	2026-08-17	28.6	Moderate
AVR0582	ALU0582	2026/2	Initial	2026-08-17	14.0	Low
AVR0583	ALU0583	2026/2	Initial	2026-08-17	8.0	Low
AVR0584	ALU0584	2026/2	Initial	2026-08-17	15.0	Low
AVR0585	ALU0585	2026/2	Initial	2026-08-17	15.4	Low
AVR0586	ALU0586	2026/2	Initial	2026-08-17	8.0	Low
AVR0587	ALU0587	2026/2	Initial	2026-08-17	48.9	High
AVR0588	ALU0588	2026/2	Initial	2026-08-17	17.5	Low
AVR0589	ALU0589	2026/2	Initial	2026-08-17	24.8	Moderate
AVR0590	ALU0590	2026/2	Initial	2026-08-17	14.5	Low
AVR0591	ALU0591	2026/2	Initial	2026-08-17	34.6	Moderate
AVR0592	ALU0592	2026/2	Initial	2026-08-17	18.0	Low
AVR0593	ALU0593	2026/2	Initial	2026-08-17	50.0	High
AVR0594	ALU0594	2026/2	Initial	2026-08-17	23.5	Moderate
AVR0595	ALU0595	2026/2	Initial	2026-08-17	13.0	Low
AVR0596	ALU0596	2026/2	Initial	2026-08-17	21.5	Moderate
AVR0597	ALU0597	2026/2	Initial	2026-08-17	19.8	Low
AVR0598	ALU0598	2026/2	Initial	2026-08-17	22.0	Moderate
AVR0599	ALU0599	2026/2	Initial	2026-08-17	27.0	Moderate
AVR0600	ALU0600	2026/2	Initial	2026-08-17	14.0	Low
AVR0601	ALU0601	2026/2	Initial	2026-08-17	33.6	Moderate
AVR0602	ALU0602	2026/2	Initial	2026-08-17	42.2	High
AVR0603	ALU0603	2026/2	Initial	2026-08-17	31.3	Moderate
AVR0604	ALU0604	2026/2	Initial	2026-08-17	32.6	Moderate
AVR0605	ALU0605	2026/2	Initial	2026-08-17	18.8	Low
AVR0606	ALU0606	2026/2	Initial	2026-08-17	33.7	Moderate
AVR0607	ALU0607	2026/2	Initial	2026-08-17	10.0	Low
AVR0608	ALU0608	2026/2	Initial	2026-08-17	39.1	High
AVR0609	ALU0609	2026/2	Initial	2026-08-17	19.4	Low
AVR0610	ALU0610	2026/2	Initial	2026-08-17	18.4	Low
AVR0611	ALU0611	2026/2	Initial	2026-08-17	57.0	Critical
AVR0612	ALU0612	2026/2	Initial	2026-08-17	44.3	High
AVR0613	ALU0613	2026/2	Initial	2026-08-17	26.0	Moderate
AVR0614	ALU0614	2026/2	Initial	2026-08-17	30.3	Moderate
AVR0615	ALU0615	2026/2	Initial	2026-08-17	39.8	High
AVR0616	ALU0616	2026/2	Initial	2026-08-17	22.8	Moderate
AVR0617	ALU0617	2026/2	Initial	2026-08-17	57.7	Critical
AVR0618	ALU0618	2026/2	Initial	2026-08-17	39.1	High
AVR0619	ALU0619	2026/2	Initial	2026-08-17	22.9	Moderate
AVR0620	ALU0620	2026/2	Initial	2026-08-17	46.2	High
AVR0621	ALU0621	2026/2	Initial	2026-08-17	21.2	Moderate
AVR0622	ALU0622	2026/2	Initial	2026-08-17	66.0	Critical
AVR0623	ALU0623	2026/2	Initial	2026-08-17	17.5	Low
AVR0624	ALU0624	2026/2	Initial	2026-08-17	22.1	Moderate
AVR0625	ALU0625	2026/2	Initial	2026-08-17	32.5	Moderate
AVR0626	ALU0626	2026/2	Initial	2026-08-17	19.7	Low
AVR0627	ALU0627	2026/2	Initial	2026-08-17	15.9	Low
AVR0628	ALU0628	2026/2	Initial	2026-08-17	15.4	Low
AVR0629	ALU0629	2026/2	Initial	2026-08-17	12.5	Low
AVR0630	ALU0630	2026/2	Initial	2026-08-17	26.5	Moderate
AVR0631	ALU0631	2026/2	Initial	2026-08-17	29.2	Moderate
AVR0632	ALU0632	2026/2	Initial	2026-08-17	23.4	Moderate
AVR0633	ALU0633	2026/2	Initial	2026-08-17	40.4	High
AVR0634	ALU0634	2026/2	Initial	2026-08-17	24.5	Moderate
AVR0635	ALU0635	2026/2	Initial	2026-08-17	25.1	Moderate
AVR0636	ALU0636	2026/2	Initial	2026-08-17	45.5	High
AVR0637	ALU0637	2026/2	Initial	2026-08-17	9.1	Low
AVR0638	ALU0638	2026/2	Initial	2026-08-17	2.5	Low
AVR0639	ALU0639	2026/2	Initial	2026-08-17	49.1	High
AVR0640	ALU0640	2026/2	Initial	2026-08-17	22.2	Moderate
AVR0641	ALU0641	2026/2	Initial	2026-08-17	21.4	Moderate
AVR0642	ALU0642	2026/2	Initial	2026-08-17	20.7	Moderate
AVR0643	ALU0643	2026/2	Initial	2026-08-17	43.4	High
AVR0644	ALU0644	2026/2	Initial	2026-08-17	26.7	Moderate
AVR0645	ALU0645	2026/2	Initial	2026-08-17	7.0	Low
AVR0646	ALU0646	2026/2	Initial	2026-08-17	16.0	Low
AVR0647	ALU0647	2026/2	Initial	2026-08-17	40.9	High
AVR0648	ALU0648	2026/2	Initial	2026-08-17	23.2	Moderate
AVR0649	ALU0649	2026/2	Initial	2026-08-17	23.0	Moderate
AVR0650	ALU0650	2026/2	Initial	2026-08-17	32.1	Moderate
AVR0651	ALU0651	2026/2	Initial	2026-08-17	21.0	Moderate
AVR0652	ALU0652	2026/2	Initial	2026-08-17	18.0	Low
AVR0653	ALU0653	2026/2	Initial	2026-08-17	23.4	Moderate
AVR0654	ALU0654	2026/2	Initial	2026-08-17	22.5	Moderate
AVR0655	ALU0655	2026/2	Initial	2026-08-17	29.5	Moderate
AVR0656	ALU0656	2026/2	Initial	2026-08-17	45.3	High
AVR0657	ALU0657	2026/2	Initial	2026-08-17	19.5	Low
AVR0658	ALU0658	2026/2	Initial	2026-08-17	29.7	Moderate
AVR0659	ALU0659	2026/2	Initial	2026-08-17	15.5	Low
AVR0660	ALU0660	2026/2	Initial	2026-08-17	26.2	Moderate
AVR0661	ALU0661	2026/2	Initial	2026-08-17	28.7	Moderate
AVR0662	ALU0662	2026/2	Initial	2026-08-17	29.6	Moderate
AVR0663	ALU0663	2026/2	Initial	2026-08-17	26.2	Moderate
AVR0664	ALU0664	2026/2	Initial	2026-08-17	21.7	Moderate
AVR0665	ALU0665	2026/2	Initial	2026-08-17	24.8	Moderate
AVR0666	ALU0666	2026/2	Initial	2026-08-17	19.8	Low
AVR0667	ALU0667	2026/2	Initial	2026-08-17	10.5	Low
AVR0668	ALU0668	2026/2	Initial	2026-08-17	23.5	Moderate
AVR0669	ALU0669	2026/2	Initial	2026-08-17	24.3	Moderate
AVR0670	ALU0670	2026/2	Initial	2026-08-17	22.0	Moderate
AVR0671	ALU0671	2026/2	Initial	2026-08-17	27.1	Moderate
AVR0672	ALU0672	2026/2	Initial	2026-08-17	28.2	Moderate
AVR0673	ALU0673	2026/2	Initial	2026-08-17	12.5	Low
AVR0674	ALU0674	2026/2	Initial	2026-08-17	14.6	Low
AVR0675	ALU0675	2026/2	Initial	2026-08-17	31.1	Moderate
AVR0676	ALU0676	2026/2	Initial	2026-08-17	15.8	Low
AVR0677	ALU0677	2026/2	Initial	2026-08-17	28.5	Moderate
AVR0678	ALU0678	2026/2	Initial	2026-08-17	10.0	Low
AVR0679	ALU0679	2026/2	Initial	2026-08-17	19.0	Low
AVR0680	ALU0680	2026/2	Initial	2026-08-17	33.3	Moderate
AVR0681	ALU0681	2026/2	Initial	2026-08-17	36.0	High
AVR0682	ALU0682	2026/2	Initial	2026-08-17	19.5	Low
AVR0683	ALU0683	2026/2	Initial	2026-08-17	24.5	Moderate
AVR0684	ALU0684	2026/2	Initial	2026-08-17	2.5	Low
AVR0685	ALU0685	2026/2	Initial	2026-08-17	37.7	High
AVR0686	ALU0686	2026/2	Initial	2026-08-17	30.2	Moderate
AVR0687	ALU0687	2026/2	Initial	2026-08-17	32.6	Moderate
AVR0688	ALU0688	2026/2	Initial	2026-08-17	5.0	Low
AVR0689	ALU0689	2026/2	Initial	2026-08-17	34.8	Moderate
AVR0690	ALU0690	2026/2	Initial	2026-08-17	17.5	Low
AVR0691	ALU0691	2026/2	Initial	2026-08-17	56.7	Critical
AVR0692	ALU0692	2026/2	Initial	2026-08-17	47.0	High
AVR0693	ALU0693	2026/2	Initial	2026-08-17	22.4	Moderate
AVR0694	ALU0694	2026/2	Initial	2026-08-17	24.1	Moderate
AVR0695	ALU0695	2026/2	Initial	2026-08-17	35.0	High
AVR0696	ALU0696	2026/2	Initial	2026-08-17	13.0	Low
AVR0697	ALU0697	2026/2	Initial	2026-08-17	18.5	Low
AVR0698	ALU0698	2026/2	Initial	2026-08-17	10.0	Low
AVR0699	ALU0699	2026/2	Initial	2026-08-17	32.3	Moderate
AVR0700	ALU0700	2026/2	Initial	2026-08-17	10.0	Low
AVR0701	ALU0701	2026/2	Initial	2026-08-17	19.5	Low
AVR0702	ALU0702	2026/2	Initial	2026-08-17	20.9	Moderate
AVR0703	ALU0703	2026/2	Initial	2026-08-17	34.9	Moderate
AVR0704	ALU0704	2026/2	Initial	2026-08-17	43.0	High
AVR0705	ALU0705	2026/2	Initial	2026-08-17	23.0	Moderate
AVR0706	ALU0706	2026/2	Initial	2026-08-17	21.0	Moderate
AVR0707	ALU0707	2026/2	Initial	2026-08-17	19.1	Low
AVR0708	ALU0708	2026/2	Initial	2026-08-17	15.0	Low
AVR0709	ALU0709	2026/2	Initial	2026-08-17	19.5	Low
AVR0710	ALU0710	2026/2	Initial	2026-08-17	27.0	Moderate
AVR0711	ALU0711	2026/2	Initial	2026-08-17	20.4	Moderate
AVR0712	ALU0712	2026/2	Initial	2026-08-17	31.2	Moderate
AVR0713	ALU0713	2026/2	Initial	2026-08-17	15.7	Low
AVR0714	ALU0714	2026/2	Initial	2026-08-17	12.5	Low
AVR0715	ALU0715	2026/2	Initial	2026-08-17	28.6	Moderate
AVR0716	ALU0716	2026/2	Initial	2026-08-17	19.4	Low
AVR0717	ALU0717	2026/2	Initial	2026-08-17	21.5	Moderate
AVR0718	ALU0718	2026/2	Initial	2026-08-17	26.5	Moderate
AVR0719	ALU0719	2026/2	Initial	2026-08-17	30.0	Moderate
AVR0720	ALU0720	2026/2	Initial	2026-08-17	34.3	Moderate
AVR0721	ALU0721	2026/2	Initial	2026-08-17	15.0	Low
AVR0722	ALU0722	2026/2	Initial	2026-08-17	41.1	High
AVR0723	ALU0723	2026/2	Initial	2026-08-17	21.0	Moderate
AVR0724	ALU0724	2026/2	Initial	2026-08-17	27.5	Moderate
AVR0725	ALU0725	2026/2	Initial	2026-08-17	19.5	Low
AVR0726	ALU0726	2026/2	Initial	2026-08-17	23.5	Moderate
AVR0727	ALU0727	2026/2	Initial	2026-08-17	66.6	Critical
AVR0728	ALU0728	2026/2	Initial	2026-08-17	2.5	Low
AVR0729	ALU0729	2026/2	Initial	2026-08-17	11.6	Low
AVR0730	ALU0730	2026/2	Initial	2026-08-17	20.9	Moderate
AVR0731	ALU0731	2026/2	Initial	2026-08-17	26.0	Moderate
AVR0732	ALU0732	2026/2	Initial	2026-08-17	28.2	Moderate
AVR0733	ALU0733	2026/2	Initial	2026-08-17	19.0	Low
AVR0734	ALU0734	2026/2	Initial	2026-08-17	25.2	Moderate
AVR0735	ALU0735	2026/2	Initial	2026-08-17	28.8	Moderate
AVR0736	ALU0736	2026/2	Initial	2026-08-17	35.5	High
AVR0737	ALU0737	2026/2	Initial	2026-08-17	21.0	Moderate
AVR0738	ALU0738	2026/2	Initial	2026-08-17	79.9	Critical
AVR0739	ALU0739	2026/2	Initial	2026-08-17	32.5	Moderate
AVR0740	ALU0740	2026/2	Initial	2026-08-17	2.5	Low
AVR0741	ALU0741	2026/2	Initial	2026-08-17	47.5	High
AVR0742	ALU0742	2026/2	Initial	2026-08-17	11.5	Low
AVR0743	ALU0743	2026/2	Initial	2026-08-17	32.9	Moderate
AVR0744	ALU0744	2026/2	Initial	2026-08-17	14.5	Low
AVR0745	ALU0745	2026/2	Initial	2026-08-17	36.0	High
AVR0746	ALU0746	2026/2	Initial	2026-08-17	19.0	Low
AVR0747	ALU0747	2026/2	Initial	2026-08-17	44.4	High
AVR0748	ALU0748	2026/2	Initial	2026-08-17	64.6	Critical
AVR0749	ALU0749	2026/2	Initial	2026-08-17	19.0	Low
AVR0750	ALU0750	2026/2	Initial	2026-08-17	19.5	Low
AVR0751	ALU0751	2026/2	Initial	2026-08-17	15.0	Low
AVR0752	ALU0752	2026/2	Initial	2026-08-17	22.0	Moderate
AVR0753	ALU0753	2026/2	Initial	2026-08-17	24.5	Moderate
AVR0754	ALU0754	2026/2	Initial	2026-08-17	10.0	Low
AVR0755	ALU0755	2026/2	Initial	2026-08-17	14.0	Low
AVR0756	ALU0756	2026/2	Initial	2026-08-17	10.0	Low
AVR0757	ALU0757	2026/2	Initial	2026-08-17	34.5	Moderate
AVR0758	ALU0758	2026/2	Initial	2026-08-17	41.2	High
AVR0759	ALU0759	2026/2	Initial	2026-08-17	16.0	Low
AVR0760	ALU0760	2026/2	Initial	2026-08-17	28.0	Moderate
AVR0761	ALU0761	2026/2	Initial	2026-08-17	31.7	Moderate
AVR0762	ALU0762	2026/2	Initial	2026-08-17	25.0	Moderate
AVR0763	ALU0763	2026/2	Initial	2026-08-17	13.0	Low
AVR0764	ALU0764	2026/2	Initial	2026-08-17	30.0	Moderate
AVR0765	ALU0765	2026/2	Initial	2026-08-17	27.8	Moderate
AVR0766	ALU0766	2026/2	Initial	2026-08-17	13.7	Low
AVR0767	ALU0767	2026/2	Initial	2026-08-17	21.0	Moderate
AVR0768	ALU0768	2026/2	Initial	2026-08-17	47.4	High
AVR0769	ALU0769	2026/2	Initial	2026-08-17	29.5	Moderate
AVR0770	ALU0770	2026/2	Initial	2026-08-17	68.2	Critical
AVR0771	ALU0771	2026/2	Initial	2026-08-17	17.5	Low
AVR0772	ALU0772	2026/2	Initial	2026-08-17	42.0	High
AVR0773	ALU0773	2026/2	Initial	2026-08-17	21.0	Moderate
AVR0774	ALU0774	2026/2	Initial	2026-08-17	18.5	Low
AVR0775	ALU0775	2026/2	Initial	2026-08-17	6.0	Low
AVR0776	ALU0776	2026/2	Initial	2026-08-17	32.3	Moderate
AVR0777	ALU0777	2026/2	Initial	2026-08-17	17.5	Low
AVR0778	ALU0778	2026/2	Initial	2026-08-17	33.0	Moderate
AVR0779	ALU0779	2026/2	Initial	2026-08-17	15.0	Low
AVR0780	ALU0780	2026/2	Initial	2026-08-17	12.5	Low
AVR0781	ALU0781	2026/2	Initial	2026-08-17	30.4	Moderate
AVR0782	ALU0782	2026/2	Initial	2026-08-17	13.0	Low
AVR0783	ALU0783	2026/2	Initial	2026-08-17	16.6	Low
AVR0784	ALU0784	2026/2	Initial	2026-08-17	14.9	Low
AVR0785	ALU0785	2026/2	Initial	2026-08-17	10.8	Low
AVR0786	ALU0786	2026/2	Initial	2026-08-17	15.4	Low
AVR0787	ALU0787	2026/2	Initial	2026-08-17	22.8	Moderate
AVR0788	ALU0788	2026/2	Initial	2026-08-17	30.0	Moderate
AVR0789	ALU0789	2026/2	Initial	2026-08-17	21.0	Moderate
AVR0790	ALU0790	2026/2	Initial	2026-08-17	12.8	Low
AVR0791	ALU0791	2026/2	Initial	2026-08-17	17.8	Low
AVR0792	ALU0792	2026/2	Initial	2026-08-17	22.5	Moderate
AVR0793	ALU0793	2026/2	Initial	2026-08-17	27.7	Moderate
AVR0794	ALU0794	2026/2	Initial	2026-08-17	20.3	Moderate
AVR0795	ALU0795	2026/2	Initial	2026-08-17	16.5	Low
AVR0796	ALU0796	2026/2	Initial	2026-08-17	23.0	Moderate
AVR0797	ALU0797	2026/2	Initial	2026-08-17	18.2	Low
AVR0798	ALU0798	2026/2	Initial	2026-08-17	23.6	Moderate
AVR0799	ALU0799	2026/2	Initial	2026-08-17	32.4	Moderate
AVR0800	ALU0800	2026/2	Initial	2026-08-17	17.1	Low
AVR0801	ALU0801	2026/2	Initial	2026-08-17	33.8	Moderate
AVR0802	ALU0802	2026/2	Initial	2026-08-17	21.2	Moderate
AVR0803	ALU0803	2026/2	Initial	2026-08-17	40.6	High
AVR0804	ALU0804	2026/2	Initial	2026-08-17	25.4	Moderate
AVR0805	ALU0805	2026/2	Initial	2026-08-17	22.0	Moderate
AVR0806	ALU0806	2026/2	Initial	2026-08-17	37.6	High
AVR0807	ALU0807	2026/2	Initial	2026-08-17	44.1	High
AVR0808	ALU0808	2026/2	Initial	2026-08-17	29.8	Moderate
AVR0809	ALU0809	2026/2	Initial	2026-08-17	38.5	High
AVR0810	ALU0810	2026/2	Initial	2026-08-17	13.0	Low
AVR0811	ALU0811	2026/2	Initial	2026-08-17	41.3	High
AVR0812	ALU0812	2026/2	Initial	2026-08-17	21.4	Moderate
AVR0813	ALU0813	2026/2	Initial	2026-08-17	44.5	High
AVR0814	ALU0814	2026/2	Initial	2026-08-17	22.7	Moderate
AVR0815	ALU0815	2026/2	Initial	2026-08-17	37.1	High
AVR0816	ALU0816	2026/2	Initial	2026-08-17	12.5	Low
AVR0817	ALU0817	2026/2	Initial	2026-08-17	20.0	Moderate
AVR0818	ALU0818	2026/2	Initial	2026-08-17	30.0	Moderate
AVR0819	ALU0819	2026/2	Initial	2026-08-17	24.0	Moderate
AVR0820	ALU0820	2026/2	Initial	2026-08-17	26.5	Moderate
AVR0821	ALU0821	2026/2	Initial	2026-08-17	32.9	Moderate
AVR0822	ALU0822	2026/2	Initial	2026-08-17	47.2	High
AVR0823	ALU0823	2026/2	Initial	2026-08-17	10.8	Low
AVR0824	ALU0824	2026/2	Initial	2026-08-17	14.0	Low
AVR0825	ALU0825	2026/2	Initial	2026-08-17	12.0	Low
AVR0826	ALU0826	2026/2	Initial	2026-08-17	25.0	Moderate
AVR0827	ALU0827	2026/2	Initial	2026-08-17	30.9	Moderate
AVR0828	ALU0828	2026/2	Initial	2026-08-17	17.3	Low
AVR0829	ALU0829	2026/2	Initial	2026-08-17	18.3	Low
AVR0830	ALU0830	2026/2	Initial	2026-08-17	23.2	Moderate
AVR0831	ALU0831	2026/2	Initial	2026-08-17	19.1	Low
AVR0832	ALU0832	2026/2	Initial	2026-08-17	13.3	Low
AVR0833	ALU0833	2026/2	Initial	2026-08-17	22.5	Moderate
AVR0834	ALU0834	2026/2	Initial	2026-08-17	29.9	Moderate
AVR0835	ALU0835	2026/2	Initial	2026-08-17	24.8	Moderate
AVR0836	ALU0836	2026/2	Initial	2026-08-17	36.4	High
AVR0837	ALU0837	2026/2	Initial	2026-08-17	25.1	Moderate
AVR0838	ALU0838	2026/2	Initial	2026-08-17	20.0	Moderate
AVR0839	ALU0839	2026/2	Initial	2026-08-17	25.3	Moderate
AVR0840	ALU0840	2026/2	Initial	2026-08-17	16.5	Low
AVR0841	ALU0841	2026/2	Initial	2026-08-17	40.2	High
AVR0842	ALU0842	2026/2	Initial	2026-08-17	34.5	Moderate
AVR0843	ALU0843	2026/2	Initial	2026-08-17	45.5	High
AVR0844	ALU0844	2026/2	Initial	2026-08-17	56.3	Critical
AVR0845	ALU0845	2026/2	Initial	2026-08-17	17.7	Low
AVR0846	ALU0846	2026/2	Initial	2026-08-17	38.1	High
AVR0847	ALU0847	2026/2	Initial	2026-08-17	46.3	High
AVR0848	ALU0848	2026/2	Initial	2026-08-17	27.0	Moderate
AVR0849	ALU0849	2026/2	Initial	2026-08-17	20.8	Moderate
AVR0850	ALU0850	2026/2	Initial	2026-08-17	12.2	Low
AVR0851	ALU0851	2026/2	Initial	2026-08-17	26.4	Moderate
AVR0852	ALU0852	2026/2	Initial	2026-08-17	21.5	Moderate
AVR0853	ALU0853	2026/2	Initial	2026-08-17	35.4	High
AVR0854	ALU0854	2026/2	Initial	2026-08-17	17.5	Low
AVR0855	ALU0855	2026/2	Initial	2026-08-17	32.9	Moderate
AVR0856	ALU0856	2026/2	Initial	2026-08-17	32.5	Moderate
AVR0857	ALU0857	2026/2	Initial	2026-08-17	18.0	Low
AVR0858	ALU0858	2026/2	Initial	2026-08-17	43.8	High
AVR0859	ALU0859	2026/2	Initial	2026-08-17	44.5	High
AVR0860	ALU0860	2026/2	Initial	2026-08-17	10.0	Low
AVR0861	ALU0861	2026/2	Initial	2026-08-17	37.1	High
AVR0862	ALU0862	2026/2	Initial	2026-08-17	33.1	Moderate
AVR0863	ALU0863	2026/2	Initial	2026-08-17	62.9	Critical
AVR0864	ALU0864	2026/2	Initial	2026-08-17	12.5	Low
AVR0865	ALU0865	2026/2	Initial	2026-08-17	9.8	Low
AVR0866	ALU0866	2026/2	Initial	2026-08-17	72.2	Critical
AVR0867	ALU0867	2026/2	Initial	2026-08-17	13.0	Low
AVR0868	ALU0868	2026/2	Initial	2026-08-17	19.5	Low
AVR0869	ALU0869	2026/2	Initial	2026-08-17	5.0	Low
AVR0870	ALU0870	2026/2	Initial	2026-08-17	28.0	Moderate
AVR0871	ALU0871	2026/2	Initial	2026-08-17	8.5	Low
AVR0872	ALU0872	2026/2	Initial	2026-08-17	39.8	High
AVR0873	ALU0873	2026/2	Initial	2026-08-17	21.5	Moderate
AVR0874	ALU0874	2026/2	Initial	2026-08-17	14.0	Low
AVR0875	ALU0875	2026/2	Initial	2026-08-17	8.5	Low
AVR0876	ALU0876	2026/2	Initial	2026-08-17	24.4	Moderate
AVR0877	ALU0877	2026/2	Initial	2026-08-17	11.6	Low
AVR0878	ALU0878	2026/2	Initial	2026-08-17	43.0	High
AVR0879	ALU0879	2026/2	Initial	2026-08-17	20.0	Moderate
AVR0880	ALU0880	2026/2	Initial	2026-08-17	15.1	Low
AVR0881	ALU0881	2026/2	Initial	2026-08-17	26.0	Moderate
AVR0882	ALU0882	2026/2	Initial	2026-08-17	53.5	High
AVR0883	ALU0883	2026/2	Initial	2026-08-17	21.2	Moderate
AVR0884	ALU0884	2026/2	Initial	2026-08-17	25.8	Moderate
AVR0885	ALU0885	2026/2	Initial	2026-08-17	19.9	Low
AVR0886	ALU0886	2026/2	Initial	2026-08-17	25.6	Moderate
AVR0887	ALU0887	2026/2	Initial	2026-08-17	16.2	Low
AVR0888	ALU0888	2026/2	Initial	2026-08-17	45.0	High
AVR0889	ALU0889	2026/2	Initial	2026-08-17	35.8	High
AVR0890	ALU0890	2026/2	Initial	2026-08-17	16.2	Low
AVR0891	ALU0891	2026/2	Initial	2026-08-17	26.0	Moderate
AVR0892	ALU0892	2026/2	Initial	2026-08-17	26.2	Moderate
AVR0893	ALU0893	2026/2	Initial	2026-08-17	32.2	Moderate
AVR0894	ALU0894	2026/2	Initial	2026-08-17	17.2	Low
AVR0895	ALU0895	2026/2	Initial	2026-08-17	17.1	Low
AVR0896	ALU0896	2026/2	Initial	2026-08-17	20.1	Moderate
AVR0897	ALU0897	2026/2	Initial	2026-08-17	22.5	Moderate
AVR0898	ALU0898	2026/2	Initial	2026-08-17	20.5	Moderate
AVR0899	ALU0899	2026/2	Initial	2026-08-17	41.1	High
AVR0900	ALU0900	2026/2	Initial	2026-08-17	19.4	Low
AVR0901	ALU0901	2026/2	Initial	2026-08-17	25.6	Moderate
AVR0902	ALU0902	2026/2	Initial	2026-08-17	16.0	Low
AVR0903	ALU0903	2026/2	Initial	2026-08-17	53.3	High
AVR0904	ALU0904	2026/2	Initial	2026-08-17	34.2	Moderate
AVR0905	ALU0905	2026/2	Initial	2026-08-17	33.2	Moderate
AVR0906	ALU0906	2026/2	Initial	2026-08-17	17.2	Low
AVR0907	ALU0907	2026/2	Initial	2026-08-17	38.2	High
AVR0908	ALU0908	2026/2	Initial	2026-08-17	19.9	Low
AVR0909	ALU0909	2026/2	Initial	2026-08-17	26.4	Moderate
AVR0910	ALU0910	2026/2	Initial	2026-08-17	11.6	Low
AVR0911	ALU0911	2026/2	Initial	2026-08-17	15.5	Low
AVR0912	ALU0912	2026/2	Initial	2026-08-17	5.0	Low
AVR0913	ALU0913	2026/2	Initial	2026-08-17	21.3	Moderate
AVR0914	ALU0914	2026/2	Initial	2026-08-17	16.5	Low
AVR0915	ALU0915	2026/2	Initial	2026-08-17	48.4	High
AVR0916	ALU0916	2026/2	Initial	2026-08-17	33.5	Moderate
AVR0917	ALU0917	2026/2	Initial	2026-08-17	21.5	Moderate
AVR0918	ALU0918	2026/2	Initial	2026-08-17	26.5	Moderate
AVR0919	ALU0919	2026/2	Initial	2026-08-17	44.0	High
AVR0920	ALU0920	2026/2	Initial	2026-08-17	24.0	Moderate
AVR0921	ALU0921	2026/2	Initial	2026-08-17	20.8	Moderate
AVR0922	ALU0922	2026/2	Initial	2026-08-17	21.0	Moderate
AVR0923	ALU0923	2026/2	Initial	2026-08-17	19.0	Low
AVR0924	ALU0924	2026/2	Initial	2026-08-17	7.8	Low
AVR0925	ALU0925	2026/2	Initial	2026-08-17	16.0	Low
AVR0926	ALU0926	2026/2	Initial	2026-08-17	41.8	High
AVR0927	ALU0927	2026/2	Initial	2026-08-17	14.4	Low
AVR0928	ALU0928	2026/2	Initial	2026-08-17	13.4	Low
AVR0929	ALU0929	2026/2	Initial	2026-08-17	12.8	Low
AVR0930	ALU0930	2026/2	Initial	2026-08-17	40.8	High
AVR0931	ALU0931	2026/2	Initial	2026-08-17	27.5	Moderate
AVR0932	ALU0932	2026/2	Initial	2026-08-17	27.5	Moderate
AVR0933	ALU0933	2026/2	Initial	2026-08-17	13.9	Low
AVR0934	ALU0934	2026/2	Initial	2026-08-17	36.7	High
AVR0935	ALU0935	2026/2	Initial	2026-08-17	43.6	High
AVR0936	ALU0936	2026/2	Initial	2026-08-17	29.0	Moderate
AVR0937	ALU0937	2026/2	Initial	2026-08-17	24.7	Moderate
AVR0938	ALU0938	2026/2	Initial	2026-08-17	19.7	Low
AVR0939	ALU0939	2026/2	Initial	2026-08-17	18.5	Low
AVR0940	ALU0940	2026/2	Initial	2026-08-17	25.7	Moderate
AVR0941	ALU0941	2026/2	Initial	2026-08-17	22.8	Moderate
AVR0942	ALU0942	2026/2	Initial	2026-08-17	10.0	Low
AVR0943	ALU0943	2026/2	Initial	2026-08-17	21.9	Moderate
AVR0944	ALU0944	2026/2	Initial	2026-08-17	53.1	High
AVR0945	ALU0945	2026/2	Initial	2026-08-17	13.9	Low
AVR0946	ALU0946	2026/2	Initial	2026-08-17	38.5	High
AVR0947	ALU0947	2026/2	Initial	2026-08-17	40.0	High
AVR0948	ALU0948	2026/2	Initial	2026-08-17	15.0	Low
AVR0949	ALU0949	2026/2	Initial	2026-08-17	52.9	High
AVR0950	ALU0950	2026/2	Initial	2026-08-17	28.9	Moderate
AVR0951	ALU0951	2026/2	Initial	2026-08-17	28.9	Moderate
AVR0952	ALU0952	2026/2	Initial	2026-08-17	22.5	Moderate
AVR0953	ALU0953	2026/2	Initial	2026-08-17	7.1	Low
AVR0954	ALU0954	2026/2	Initial	2026-08-17	21.9	Moderate
AVR0955	ALU0955	2026/2	Initial	2026-08-17	15.0	Low
AVR0956	ALU0956	2026/2	Initial	2026-08-17	32.2	Moderate
AVR0957	ALU0957	2026/2	Initial	2026-08-17	12.3	Low
AVR0958	ALU0958	2026/2	Initial	2026-08-17	23.5	Moderate
AVR0959	ALU0959	2026/2	Initial	2026-08-17	13.0	Low
AVR0960	ALU0960	2026/2	Initial	2026-08-17	14.8	Low
AVR0961	ALU0961	2026/2	Initial	2026-08-17	30.4	Moderate
AVR0962	ALU0962	2026/2	Initial	2026-08-17	25.8	Moderate
AVR0963	ALU0963	2026/2	Initial	2026-08-17	5.0	Low
AVR0964	ALU0964	2026/2	Initial	2026-08-17	14.0	Low
AVR0965	ALU0965	2026/2	Initial	2026-08-17	19.6	Low
AVR0966	ALU0966	2026/2	Initial	2026-08-17	36.5	High
AVR0967	ALU0967	2026/2	Initial	2026-08-17	11.8	Low
AVR0968	ALU0968	2026/2	Initial	2026-08-17	32.0	Moderate
AVR0969	ALU0969	2026/2	Initial	2026-08-17	15.4	Low
AVR0970	ALU0970	2026/2	Initial	2026-08-17	28.3	Moderate
AVR0971	ALU0971	2026/2	Initial	2026-08-17	26.4	Moderate
AVR0972	ALU0972	2026/2	Initial	2026-08-17	18.7	Low
AVR0973	ALU0973	2026/2	Initial	2026-08-17	16.3	Low
AVR0974	ALU0974	2026/2	Initial	2026-08-17	20.7	Moderate
AVR0975	ALU0975	2026/2	Initial	2026-08-17	22.7	Moderate
AVR0976	ALU0976	2026/2	Initial	2026-08-17	40.5	High
AVR0977	ALU0977	2026/2	Initial	2026-08-17	42.9	High
AVR0978	ALU0978	2026/2	Initial	2026-08-17	16.7	Low
AVR0979	ALU0979	2026/2	Initial	2026-08-17	27.5	Moderate
AVR0980	ALU0980	2026/2	Initial	2026-08-17	27.5	Moderate
AVR0981	ALU0981	2026/2	Initial	2026-08-17	35.1	High
AVR0982	ALU0982	2026/2	Initial	2026-08-17	21.4	Moderate
AVR0983	ALU0983	2026/2	Initial	2026-08-17	10.0	Low
AVR0984	ALU0984	2026/2	Initial	2026-08-17	16.0	Low
AVR0985	ALU0985	2026/2	Initial	2026-08-17	4.0	Low
AVR0986	ALU0986	2026/2	Initial	2026-08-17	35.2	High
AVR0987	ALU0987	2026/2	Initial	2026-08-17	28.7	Moderate
AVR0988	ALU0988	2026/2	Initial	2026-08-17	32.0	Moderate
AVR0989	ALU0989	2026/2	Initial	2026-08-17	22.2	Moderate
AVR0990	ALU0990	2026/2	Initial	2026-08-17	37.9	High
AVR0991	ALU0991	2026/2	Initial	2026-08-17	17.8	Low
AVR0992	ALU0992	2026/2	Initial	2026-08-17	24.0	Moderate
AVR0993	ALU0993	2026/2	Initial	2026-08-17	22.9	Moderate
AVR0994	ALU0994	2026/2	Initial	2026-08-17	35.6	High
AVR0995	ALU0995	2026/2	Initial	2026-08-17	19.0	Low
AVR0996	ALU0996	2026/2	Initial	2026-08-17	20.8	Moderate
AVR0997	ALU0997	2026/2	Initial	2026-08-17	20.2	Moderate
AVR0998	ALU0998	2026/2	Initial	2026-08-17	22.2	Moderate
AVR0999	ALU0999	2026/2	Initial	2026-08-17	28.9	Moderate
AVR1000	ALU1000	2026/2	Initial	2026-08-17	14.5	Low
\.

COPY public.courses (course_id, university_id, name, degree, duration_semesters, passing_average, minimum_attendance_pct) FROM stdin;
CUR01	UNI01	Artificial Intelligence	Bachelor's	8	6	75
\.

COPY public.academic_indicators (student_id, academic_period, total_absences, attendance_pct, failed_subjects_history, pending_activities, previous_semester_average, current_average, average_trend) FROM stdin;
ALU0001	2026/2	5	72	0	2	6.9	7.7	0.8
ALU0002	2026/2	6	69	0	4	2.8	2.9	0.1
ALU0003	2026/2	1	93	0	0	5.4	6.7	1.3
ALU0004	2026/2	2	87	0	0	6.6	5.9	-0.7
ALU0005	2026/2	5	73	0	2	5.7	6.5	0.8
ALU0006	2026/2	3	85	0	0	6.6	5.6	-1.0
ALU0007	2026/2	4	75	0	0	6.9	7.2	0.3
ALU0008	2026/2	4	77	0	1	4.8	6.9	2.1
ALU0009	2026/2	7	60	0	1	5.7	4.0	-1.7
ALU0010	2026/2	0	100	1	0	5.8	6.1	0.3
ALU0011	2026/2	2	88	0	0	6.0	5.9	-0.1
ALU0012	2026/2	7	61	0	1	5.8	5.1	-0.7
ALU0013	2026/2	4	76	0	0	7.8	8.2	0.4
ALU0014	2026/2	1	92	0	2	5.6	5.9	0.3
ALU0015	2026/2	3	83	0	0	7.3	6.3	-1.0
ALU0016	2026/2	4	76	0	0	5.2	7.5	2.3
ALU0017	2026/2	3	85	0	2	8.0	8.0	0.0
ALU0018	2026/2	3	82	0	2	7.1	6.4	-0.7
ALU0019	2026/2	3	86	0	1	4.5	5.5	1.0
ALU0020	2026/2	4	78	0	1	4.3	6.9	2.6
ALU0021	2026/2	3	85	0	1	7.6	7.3	-0.3
ALU0022	2026/2	3	84	0	0	6.1	6.4	0.3
ALU0023	2026/2	1	97	0	3	8.3	7.2	-1.1
ALU0024	2026/2	3	86	0	0	8.4	7.4	-1.0
ALU0025	2026/2	6	68	0	2	5.1	3.6	-1.5
ALU0026	2026/2	4	77	0	0	8.8	7.0	-1.8
ALU0027	2026/2	1	95	1	2	5.5	7.2	1.7
ALU0028	2026/2	4	77	0	2	3.1	5.0	1.9
ALU0029	2026/2	2	91	2	3	6.4	7.5	1.1
ALU0030	2026/2	4	78	0	2	5.5	6.4	0.9
ALU0031	2026/2	3	84	0	0	6.4	7.1	0.7
ALU0032	2026/2	6	67	0	0	3.7	3.6	-0.1
ALU0033	2026/2	2	89	0	1	9.3	9.5	0.2
ALU0034	2026/2	6	64	0	2	4.9	5.5	0.6
ALU0035	2026/2	4	79	1	3	6.7	8.7	2.0
ALU0036	2026/2	2	88	1	3	7.4	7.8	0.4
ALU0037	2026/2	2	90	0	0	6.6	7.0	0.4
ALU0038	2026/2	3	83	0	2	6.6	6.6	0.0
ALU0039	2026/2	3	84	0	1	7.4	7.2	-0.2
ALU0040	2026/2	2	89	1	0	8.6	7.4	-1.2
ALU0041	2026/2	4	77	2	1	9.1	8.1	-1.0
ALU0042	2026/2	2	90	0	0	6.5	6.0	-0.5
ALU0043	2026/2	1	97	1	1	4.5	5.1	0.6
ALU0044	2026/2	2	90	0	0	5.1	6.6	1.5
ALU0045	2026/2	5	71	0	0	6.3	6.2	-0.1
ALU0046	2026/2	3	84	0	1	6.3	5.6	-0.7
ALU0047	2026/2	2	87	0	1	9.2	6.0	-3.2
ALU0048	2026/2	1	92	0	0	7.6	6.9	-0.7
ALU0049	2026/2	3	83	0	1	6.1	7.8	1.7
ALU0050	2026/2	1	93	1	3	6.9	7.2	0.3
ALU0051	2026/2	0	100	0	0	9.1	7.7	-1.4
ALU0052	2026/2	3	81	0	0	5.5	5.8	0.3
ALU0053	2026/2	1	92	0	3	6.0	6.0	0.0
ALU0054	2026/2	2	90	0	2	7.8	7.0	-0.8
ALU0055	2026/2	3	81	0	3	4.5	5.2	0.7
ALU0056	2026/2	1	92	0	0	8.3	8.2	-0.1
ALU0057	2026/2	8	55	0	1	5.4	4.3	-1.1
ALU0058	2026/2	2	87	0	2	6.3	7.4	1.1
ALU0059	2026/2	1	94	0	1	7.1	7.0	-0.1
ALU0060	2026/2	7	59	0	2	3.8	4.2	0.4
ALU0061	2026/2	4	75	0	0	10.0	8.5	-1.5
ALU0062	2026/2	6	67	0	1	6.2	5.9	-0.3
ALU0063	2026/2	7	61	0	1	4.0	5.5	1.5
ALU0064	2026/2	4	77	0	1	4.9	4.1	-0.8
ALU0065	2026/2	5	74	0	0	8.0	9.1	1.1
ALU0066	2026/2	3	85	0	0	5.7	6.6	0.9
ALU0067	2026/2	1	92	0	1	7.4	6.2	-1.2
ALU0068	2026/2	6	65	0	0	6.6	6.8	0.2
ALU0069	2026/2	0	98	1	1	7.6	7.6	0.0
ALU0070	2026/2	2	87	1	0	5.9	6.5	0.6
ALU0071	2026/2	7	61	1	2	8.1	7.5	-0.6
ALU0072	2026/2	3	86	0	4	7.6	5.6	-2.0
ALU0073	2026/2	4	80	0	1	8.0	7.7	-0.3
ALU0074	2026/2	4	80	0	2	7.2	7.1	-0.1
ALU0075	2026/2	5	71	0	1	5.2	5.0	-0.2
ALU0076	2026/2	4	77	1	3	7.1	6.9	-0.2
ALU0077	2026/2	5	74	0	2	3.4	4.8	1.4
ALU0078	2026/2	2	89	1	1	7.9	6.4	-1.5
ALU0079	2026/2	6	69	0	1	9.2	9.7	0.5
ALU0080	2026/2	4	78	0	2	5.2	5.3	0.1
ALU0081	2026/2	2	90	1	2	8.0	6.5	-1.5
ALU0082	2026/2	3	86	0	0	7.0	7.7	0.7
ALU0083	2026/2	0	100	0	0	5.0	6.7	1.7
ALU0084	2026/2	4	75	0	2	7.0	6.1	-0.9
ALU0085	2026/2	4	77	1	0	8.4	8.5	0.1
ALU0086	2026/2	2	87	0	1	8.6	7.8	-0.8
ALU0087	2026/2	2	89	0	1	7.2	7.0	-0.2
ALU0088	2026/2	0	100	0	2	9.4	8.9	-0.5
ALU0089	2026/2	3	84	0	1	4.9	5.2	0.3
ALU0090	2026/2	3	82	0	2	5.7	5.8	0.1
ALU0091	2026/2	1	95	0	2	4.1	5.9	1.8
ALU0092	2026/2	4	78	0	0	5.5	6.9	1.4
ALU0093	2026/2	1	95	0	2	4.8	6.4	1.6
ALU0094	2026/2	0	100	1	1	7.2	7.0	-0.2
ALU0095	2026/2	4	77	0	1	9.0	7.9	-1.1
ALU0096	2026/2	4	80	0	1	7.3	7.2	-0.1
ALU0097	2026/2	3	82	0	1	5.7	7.2	1.5
ALU0098	2026/2	7	62	0	2	6.4	6.1	-0.3
ALU0099	2026/2	9	51	0	3	3.7	2.9	-0.8
ALU0100	2026/2	4	79	1	0	7.5	5.6	-1.9
ALU0101	2026/2	1	93	0	1	8.4	7.3	-1.1
ALU0102	2026/2	4	75	0	1	6.0	6.4	0.4
ALU0103	2026/2	3	86	0	1	5.3	5.5	0.2
ALU0104	2026/2	1	96	1	0	4.6	5.8	1.2
ALU0105	2026/2	4	77	0	0	5.4	5.3	-0.1
ALU0106	2026/2	2	91	0	2	6.6	7.5	0.9
ALU0107	2026/2	6	68	0	4	5.5	6.0	0.5
ALU0108	2026/2	4	78	0	2	6.1	5.3	-0.8
ALU0109	2026/2	1	97	1	0	6.1	6.2	0.1
ALU0110	2026/2	1	95	0	2	6.1	6.9	0.8
ALU0111	2026/2	3	83	1	0	6.0	6.1	0.1
ALU0112	2026/2	3	86	0	3	6.6	6.3	-0.3
ALU0113	2026/2	0	98	0	0	7.5	6.5	-1.0
ALU0114	2026/2	4	80	0	4	5.3	6.2	0.9
ALU0115	2026/2	3	86	0	2	5.5	5.5	0.0
ALU0116	2026/2	7	62	1	3	8.0	4.5	-3.5
ALU0117	2026/2	3	82	0	2	6.7	7.8	1.1
ALU0118	2026/2	4	79	0	0	4.8	6.4	1.6
ALU0119	2026/2	1	93	0	0	7.9	8.2	0.3
ALU0120	2026/2	5	72	1	1	5.7	5.0	-0.7
ALU0121	2026/2	5	73	0	0	7.8	6.9	-0.9
ALU0122	2026/2	0	98	0	3	5.7	7.0	1.3
ALU0123	2026/2	4	76	0	0	5.8	6.1	0.3
ALU0124	2026/2	2	91	0	0	7.6	7.9	0.3
ALU0125	2026/2	3	86	0	0	7.0	6.6	-0.4
ALU0126	2026/2	2	91	0	1	7.5	7.7	0.2
ALU0127	2026/2	4	76	0	0	5.7	5.6	-0.1
ALU0128	2026/2	0	99	1	0	7.1	6.3	-0.8
ALU0129	2026/2	4	78	0	0	7.8	6.3	-1.5
ALU0130	2026/2	5	74	0	1	6.0	4.9	-1.1
ALU0131	2026/2	4	79	0	0	6.2	6.3	0.1
ALU0132	2026/2	2	87	0	1	8.2	7.3	-0.9
ALU0133	2026/2	2	87	1	1	6.5	6.4	-0.1
ALU0134	2026/2	2	87	0	1	7.4	6.6	-0.8
ALU0135	2026/2	4	75	0	0	6.3	5.7	-0.6
ALU0136	2026/2	0	98	0	0	7.5	7.9	0.4
ALU0137	2026/2	2	88	0	1	7.9	6.7	-1.2
ALU0138	2026/2	3	83	0	1	7.5	7.8	0.3
ALU0139	2026/2	2	87	0	2	6.3	6.4	0.1
ALU0140	2026/2	2	89	0	1	6.3	7.2	0.9
ALU0141	2026/2	5	71	0	3	8.2	7.5	-0.7
ALU0142	2026/2	0	98	0	0	9.2	8.9	-0.3
ALU0143	2026/2	2	91	0	2	7.1	7.4	0.3
ALU0144	2026/2	4	75	1	0	6.6	6.0	-0.6
ALU0145	2026/2	6	65	0	3	4.0	5.2	1.2
ALU0146	2026/2	6	68	0	0	6.7	6.3	-0.4
ALU0147	2026/2	3	83	0	1	7.5	6.8	-0.7
ALU0148	2026/2	3	85	1	1	6.5	6.2	-0.3
ALU0149	2026/2	1	92	0	1	9.8	7.9	-1.9
ALU0150	2026/2	1	93	0	2	6.5	5.2	-1.3
ALU0151	2026/2	1	92	2	0	6.2	4.5	-1.7
ALU0152	2026/2	3	84	0	2	4.4	5.8	1.4
ALU0153	2026/2	4	79	0	1	5.8	6.1	0.3
ALU0154	2026/2	2	88	0	0	8.0	7.8	-0.2
ALU0155	2026/2	7	60	2	2	3.8	4.6	0.8
ALU0156	2026/2	3	85	1	4	7.5	5.6	-1.9
ALU0157	2026/2	3	81	2	2	4.5	5.2	0.7
ALU0158	2026/2	3	82	0	2	6.1	6.5	0.4
ALU0159	2026/2	1	93	0	1	10.0	9.9	-0.1
ALU0160	2026/2	3	81	2	1	7.3	6.3	-1.0
ALU0161	2026/2	3	85	0	0	5.5	7.0	1.5
ALU0162	2026/2	3	82	0	0	6.4	6.6	0.2
ALU0163	2026/2	0	100	0	1	7.9	6.5	-1.4
ALU0164	2026/2	2	88	0	2	6.6	7.0	0.4
ALU0165	2026/2	0	100	0	1	8.0	7.9	-0.1
ALU0166	2026/2	5	73	1	2	7.0	6.6	-0.4
ALU0167	2026/2	3	83	1	0	5.4	7.9	2.5
ALU0168	2026/2	3	86	1	3	4.4	5.9	1.5
ALU0169	2026/2	2	90	0	1	5.3	7.4	2.1
ALU0170	2026/2	4	79	0	1	8.9	7.0	-1.9
ALU0171	2026/2	4	78	0	2	7.8	6.2	-1.6
ALU0172	2026/2	2	88	0	1	5.5	5.9	0.4
ALU0173	2026/2	3	85	0	2	5.7	6.7	1.0
ALU0174	2026/2	4	80	0	3	6.0	5.7	-0.3
ALU0175	2026/2	3	85	0	0	6.0	6.3	0.3
ALU0176	2026/2	2	90	0	1	7.8	6.9	-0.9
ALU0177	2026/2	4	78	2	2	8.6	7.8	-0.8
ALU0178	2026/2	2	91	0	1	5.6	5.8	0.2
ALU0179	2026/2	4	78	0	2	10.0	7.4	-2.6
ALU0180	2026/2	3	86	0	0	7.3	6.8	-0.5
ALU0181	2026/2	1	92	0	5	7.8	6.7	-1.1
ALU0182	2026/2	2	89	0	2	7.1	6.6	-0.5
ALU0183	2026/2	3	81	0	1	6.4	7.2	0.8
ALU0184	2026/2	1	97	0	1	8.8	9.4	0.6
ALU0185	2026/2	4	80	2	3	5.7	5.0	-0.7
ALU0186	2026/2	2	90	0	1	7.6	6.3	-1.3
ALU0187	2026/2	3	84	0	1	7.2	6.1	-1.1
ALU0188	2026/2	4	80	0	1	7.4	6.9	-0.5
ALU0189	2026/2	4	80	0	0	4.7	5.9	1.2
ALU0190	2026/2	3	84	1	4	7.1	6.9	-0.2
ALU0191	2026/2	4	76	0	1	9.1	7.8	-1.3
ALU0192	2026/2	4	78	0	1	9.2	8.3	-0.9
ALU0193	2026/2	2	91	1	2	7.9	7.9	0.0
ALU0194	2026/2	2	89	0	1	6.7	7.2	0.5
ALU0195	2026/2	4	80	0	0	7.5	6.0	-1.5
ALU0196	2026/2	1	92	0	1	5.4	5.3	-0.1
ALU0197	2026/2	3	86	0	2	6.7	6.1	-0.6
ALU0198	2026/2	0	100	0	2	7.5	7.6	0.1
ALU0199	2026/2	4	77	1	2	9.1	7.6	-1.5
ALU0200	2026/2	3	81	0	3	6.5	5.4	-1.1
ALU0201	2026/2	5	70	2	4	2.6	3.1	0.5
ALU0202	2026/2	4	79	0	1	4.2	5.1	0.9
ALU0203	2026/2	0	100	0	1	7.1	8.4	1.3
ALU0204	2026/2	3	84	1	0	7.9	7.3	-0.6
ALU0205	2026/2	3	85	0	0	7.9	8.1	0.2
ALU0206	2026/2	0	99	1	1	8.5	8.9	0.4
ALU0207	2026/2	4	79	0	0	5.6	6.2	0.6
ALU0208	2026/2	5	73	2	2	5.7	5.9	0.2
ALU0209	2026/2	0	99	0	1	6.4	6.0	-0.4
ALU0210	2026/2	0	99	0	0	6.3	7.1	0.8
ALU0211	2026/2	1	95	0	3	8.9	7.5	-1.4
ALU0212	2026/2	2	88	1	3	5.6	6.7	1.1
ALU0213	2026/2	3	81	0	0	8.0	6.5	-1.5
ALU0214	2026/2	5	74	0	1	4.5	4.4	-0.1
ALU0215	2026/2	3	85	0	1	6.9	5.3	-1.6
ALU0216	2026/2	3	82	0	1	8.1	7.2	-0.9
ALU0217	2026/2	2	91	0	1	7.0	8.6	1.6
ALU0218	2026/2	7	63	0	4	6.9	8.4	1.5
ALU0219	2026/2	3	82	0	0	6.3	6.2	-0.1
ALU0220	2026/2	1	94	0	1	5.8	4.8	-1.0
ALU0221	2026/2	0	99	2	0	5.2	6.5	1.3
ALU0222	2026/2	4	77	1	0	7.9	7.7	-0.2
ALU0223	2026/2	4	80	0	0	6.7	7.6	0.9
ALU0224	2026/2	3	84	1	2	9.6	7.6	-2.0
ALU0225	2026/2	3	86	0	1	9.7	5.9	-3.8
ALU0226	2026/2	3	86	0	0	7.0	6.8	-0.2
ALU0227	2026/2	4	76	0	0	7.2	8.0	0.8
ALU0228	2026/2	3	85	1	0	5.0	7.0	2.0
ALU0229	2026/2	0	100	0	0	7.1	7.1	0.0
ALU0230	2026/2	4	79	0	1	7.5	7.3	-0.2
ALU0231	2026/2	4	76	0	0	5.5	6.1	0.6
ALU0232	2026/2	5	71	0	2	6.9	5.8	-1.1
ALU0233	2026/2	4	76	0	1	4.4	5.1	0.7
ALU0234	2026/2	3	81	0	2	7.7	7.9	0.2
ALU0235	2026/2	6	69	0	1	5.4	5.6	0.2
ALU0236	2026/2	4	75	1	2	6.5	6.8	0.3
ALU0237	2026/2	1	93	1	1	8.2	7.7	-0.5
ALU0238	2026/2	3	83	0	3	8.0	5.8	-2.2
ALU0239	2026/2	3	82	0	1	7.5	5.9	-1.6
ALU0240	2026/2	1	93	0	1	7.6	8.4	0.8
ALU0241	2026/2	6	66	1	2	5.8	5.5	-0.3
ALU0242	2026/2	5	72	0	3	4.7	5.4	0.7
ALU0243	2026/2	2	88	0	1	8.2	5.9	-2.3
ALU0244	2026/2	1	92	0	0	7.1	7.0	-0.1
ALU0245	2026/2	0	98	1	1	8.0	8.0	0.0
ALU0246	2026/2	4	78	0	1	8.2	7.0	-1.2
ALU0247	2026/2	3	82	0	0	5.4	7.1	1.7
ALU0248	2026/2	5	74	0	0	5.2	5.6	0.4
ALU0249	2026/2	4	75	1	0	4.8	5.6	0.8
ALU0250	2026/2	1	97	0	1	7.3	5.9	-1.4
ALU0251	2026/2	3	85	0	1	9.2	6.6	-2.6
ALU0252	2026/2	4	75	0	0	4.5	5.2	0.7
ALU0253	2026/2	3	82	0	0	9.0	6.7	-2.3
ALU0254	2026/2	1	93	0	2	6.3	7.0	0.7
ALU0255	2026/2	4	79	0	1	6.7	6.7	0.0
ALU0256	2026/2	5	71	0	0	6.4	5.1	-1.3
ALU0257	2026/2	4	80	1	2	7.8	8.1	0.3
ALU0258	2026/2	3	81	1	3	6.6	6.4	-0.2
ALU0259	2026/2	2	87	0	0	7.0	6.2	-0.8
ALU0260	2026/2	2	88	0	0	8.4	6.4	-2.0
ALU0261	2026/2	0	98	0	0	4.9	6.2	1.3
ALU0262	2026/2	4	75	0	2	4.2	6.0	1.8
ALU0263	2026/2	5	71	0	2	4.4	5.1	0.7
ALU0264	2026/2	1	95	0	1	6.6	6.8	0.2
ALU0265	2026/2	0	100	0	3	8.5	7.5	-1.0
ALU0266	2026/2	1	94	0	1	6.7	7.0	0.3
ALU0267	2026/2	1	97	0	0	5.6	7.6	2.0
ALU0268	2026/2	3	83	0	1	6.3	6.3	0.0
ALU0269	2026/2	1	94	0	2	9.4	7.6	-1.8
ALU0270	2026/2	8	58	0	1	3.8	4.7	0.9
ALU0271	2026/2	4	77	1	0	6.9	8.1	1.2
ALU0272	2026/2	5	72	0	2	3.2	3.8	0.6
ALU0273	2026/2	3	85	1	2	9.5	7.5	-2.0
ALU0274	2026/2	3	85	0	1	6.4	6.1	-0.3
ALU0275	2026/2	6	69	1	2	4.2	4.5	0.3
ALU0276	2026/2	2	88	0	1	5.0	6.3	1.3
ALU0277	2026/2	3	82	1	0	5.9	7.0	1.1
ALU0278	2026/2	4	75	1	2	4.3	5.5	1.2
ALU0279	2026/2	3	85	1	2	5.1	5.7	0.6
ALU0280	2026/2	4	79	0	1	7.4	7.6	0.2
ALU0281	2026/2	2	91	0	3	5.5	6.9	1.4
ALU0282	2026/2	9	52	0	3	2.9	3.5	0.6
ALU0283	2026/2	7	63	0	3	3.4	3.1	-0.3
ALU0284	2026/2	0	100	0	0	5.7	6.3	0.6
ALU0285	2026/2	3	81	0	4	5.3	6.2	0.9
ALU0286	2026/2	0	100	1	2	6.5	6.7	0.2
ALU0287	2026/2	1	93	0	0	5.0	6.1	1.1
ALU0288	2026/2	0	98	1	0	6.7	6.4	-0.3
ALU0289	2026/2	0	100	0	1	6.8	6.9	0.1
ALU0290	2026/2	2	88	0	1	5.3	5.3	0.0
ALU0291	2026/2	2	87	0	1	6.4	7.3	0.9
ALU0292	2026/2	4	80	1	1	5.8	6.9	1.1
ALU0293	2026/2	4	80	0	0	6.7	7.4	0.7
ALU0294	2026/2	1	92	1	1	7.8	7.7	-0.1
ALU0295	2026/2	4	75	1	2	5.3	4.6	-0.7
ALU0296	2026/2	2	87	0	2	7.0	8.0	1.0
ALU0297	2026/2	3	84	0	3	8.8	7.1	-1.7
ALU0298	2026/2	3	85	0	1	6.8	6.3	-0.5
ALU0299	2026/2	0	100	0	2	6.2	7.4	1.2
ALU0300	2026/2	4	75	0	1	6.6	7.7	1.1
ALU0301	2026/2	2	91	0	0	6.2	8.0	1.8
ALU0302	2026/2	3	85	0	3	7.2	7.6	0.4
ALU0303	2026/2	4	75	0	0	5.7	7.1	1.4
ALU0304	2026/2	2	91	0	0	6.6	6.0	-0.6
ALU0305	2026/2	3	82	1	3	6.6	7.5	0.9
ALU0306	2026/2	5	74	0	1	10.0	8.5	-1.5
ALU0307	2026/2	5	71	0	3	6.5	5.4	-1.1
ALU0308	2026/2	1	92	1	1	7.9	6.1	-1.8
ALU0309	2026/2	3	86	0	0	5.8	5.3	-0.5
ALU0310	2026/2	5	70	0	1	4.0	4.9	0.9
ALU0311	2026/2	2	90	0	1	9.4	7.9	-1.5
ALU0312	2026/2	1	92	0	1	6.4	7.4	1.0
ALU0313	2026/2	3	85	0	1	8.5	7.9	-0.6
ALU0314	2026/2	3	85	0	1	8.5	7.2	-1.3
ALU0315	2026/2	4	78	1	0	8.1	8.5	0.4
ALU0316	2026/2	5	74	0	0	5.9	5.4	-0.5
ALU0317	2026/2	3	81	0	1	4.5	5.4	0.9
ALU0318	2026/2	7	60	0	1	6.8	5.1	-1.7
ALU0319	2026/2	0	98	1	1	6.5	6.1	-0.4
ALU0320	2026/2	3	83	0	4	6.1	6.8	0.7
ALU0321	2026/2	3	86	1	2	5.4	7.4	2.0
ALU0322	2026/2	3	84	1	2	8.1	7.1	-1.0
ALU0323	2026/2	4	80	0	1	5.4	6.6	1.2
ALU0324	2026/2	3	84	0	1	6.9	7.9	1.0
ALU0325	2026/2	2	88	0	0	6.9	6.5	-0.4
ALU0326	2026/2	1	95	1	1	8.0	8.0	0.0
ALU0327	2026/2	1	93	0	3	6.9	6.6	-0.3
ALU0328	2026/2	1	95	0	1	7.3	7.7	0.4
ALU0329	2026/2	6	69	1	2	4.2	6.4	2.2
ALU0330	2026/2	1	92	0	1	7.6	7.2	-0.4
ALU0331	2026/2	3	85	1	3	5.5	6.1	0.6
ALU0332	2026/2	3	82	2	2	6.6	7.6	1.0
ALU0333	2026/2	5	73	0	0	5.1	5.8	0.7
ALU0334	2026/2	3	84	0	2	4.6	6.3	1.7
ALU0335	2026/2	0	100	0	0	7.0	6.5	-0.5
ALU0336	2026/2	7	60	0	0	2.7	4.0	1.3
ALU0337	2026/2	3	85	2	0	7.6	7.5	-0.1
ALU0338	2026/2	6	68	0	1	7.6	7.4	-0.2
ALU0339	2026/2	1	97	0	0	6.8	7.5	0.7
ALU0340	2026/2	3	85	0	1	6.0	7.1	1.1
ALU0341	2026/2	0	100	0	2	8.0	8.0	0.0
ALU0342	2026/2	2	88	2	0	6.0	6.3	0.3
ALU0343	2026/2	2	89	0	0	6.9	8.5	1.6
ALU0344	2026/2	1	96	1	1	8.4	7.3	-1.1
ALU0345	2026/2	5	70	0	1	8.8	8.0	-0.8
ALU0346	2026/2	0	99	1	2	7.5	7.3	-0.2
ALU0347	2026/2	4	75	0	2	6.5	5.4	-1.1
ALU0348	2026/2	8	55	0	4	3.6	3.6	0.0
ALU0349	2026/2	4	77	1	2	7.3	7.3	0.0
ALU0350	2026/2	4	78	1	0	5.3	5.8	0.5
ALU0351	2026/2	4	78	1	0	8.3	7.8	-0.5
ALU0352	2026/2	10	47	0	0	1.6	3.8	2.2
ALU0353	2026/2	5	70	0	2	4.0	4.5	0.5
ALU0354	2026/2	2	90	2	4	5.0	6.4	1.4
ALU0355	2026/2	7	63	1	3	7.4	7.9	0.5
ALU0356	2026/2	3	84	0	0	6.6	7.0	0.4
ALU0357	2026/2	0	98	0	1	6.9	7.2	0.3
ALU0358	2026/2	4	78	0	2	7.4	6.1	-1.3
ALU0359	2026/2	3	86	0	3	5.7	6.2	0.5
ALU0360	2026/2	0	100	0	0	6.5	6.5	0.0
ALU0361	2026/2	3	82	0	0	7.4	6.1	-1.3
ALU0362	2026/2	7	61	0	0	7.9	8.7	0.8
ALU0363	2026/2	1	97	0	1	8.1	8.8	0.7
ALU0364	2026/2	4	77	0	0	6.0	4.8	-1.2
ALU0365	2026/2	5	72	0	1	7.2	6.9	-0.3
ALU0366	2026/2	5	72	0	2	5.4	5.2	-0.2
ALU0367	2026/2	4	78	0	0	9.6	8.2	-1.4
ALU0368	2026/2	2	91	0	1	5.0	7.4	2.4
ALU0369	2026/2	6	68	0	1	5.6	6.5	0.9
ALU0370	2026/2	3	83	1	0	7.4	7.4	0.0
ALU0371	2026/2	2	89	2	2	6.7	6.6	-0.1
ALU0372	2026/2	3	85	1	1	6.5	6.5	0.0
ALU0373	2026/2	6	68	0	0	4.9	4.2	-0.7
ALU0374	2026/2	0	100	0	1	6.9	6.2	-0.7
ALU0375	2026/2	3	86	0	0	6.1	7.1	1.0
ALU0376	2026/2	2	90	1	1	7.1	7.3	0.2
ALU0377	2026/2	1	96	0	0	5.4	4.2	-1.2
ALU0378	2026/2	3	83	1	2	5.2	5.8	0.6
ALU0379	2026/2	3	86	0	2	3.5	5.7	2.2
ALU0380	2026/2	4	77	0	2	4.7	5.6	0.9
ALU0381	2026/2	4	80	0	0	7.4	6.9	-0.5
ALU0382	2026/2	1	92	0	0	7.7	8.7	1.0
ALU0383	2026/2	1	93	0	0	5.3	7.3	2.0
ALU0384	2026/2	4	78	0	1	6.3	4.7	-1.6
ALU0385	2026/2	0	100	0	1	6.2	7.4	1.2
ALU0386	2026/2	1	97	0	0	7.0	6.6	-0.4
ALU0387	2026/2	5	74	0	3	5.6	4.8	-0.8
ALU0388	2026/2	1	97	0	0	7.7	8.6	0.9
ALU0389	2026/2	3	86	0	0	7.5	7.4	-0.1
ALU0390	2026/2	2	87	1	2	5.3	6.1	0.8
ALU0391	2026/2	0	100	1	0	6.8	7.1	0.3
ALU0392	2026/2	6	65	0	3	3.6	5.2	1.6
ALU0393	2026/2	0	100	0	0	7.1	7.5	0.4
ALU0394	2026/2	4	77	0	2	5.5	5.0	-0.5
ALU0395	2026/2	3	82	0	0	7.1	6.3	-0.8
ALU0396	2026/2	4	77	0	0	9.8	7.8	-2.0
ALU0397	2026/2	2	88	0	0	7.6	6.9	-0.7
ALU0398	2026/2	2	91	0	0	6.4	5.7	-0.7
ALU0399	2026/2	2	90	0	2	8.2	7.5	-0.7
ALU0400	2026/2	0	100	1	0	7.6	9.6	2.0
ALU0401	2026/2	4	80	0	1	7.3	5.6	-1.7
ALU0402	2026/2	0	100	0	3	5.9	6.1	0.2
ALU0403	2026/2	0	98	1	0	7.4	6.2	-1.2
ALU0404	2026/2	3	85	0	2	7.9	7.3	-0.6
ALU0405	2026/2	1	92	0	1	7.3	7.2	-0.1
ALU0406	2026/2	2	90	0	0	5.6	6.1	0.5
ALU0407	2026/2	5	74	1	2	5.7	5.6	-0.1
ALU0408	2026/2	2	91	0	2	8.3	6.6	-1.7
ALU0409	2026/2	2	89	0	2	7.1	7.0	-0.1
ALU0410	2026/2	6	67	0	1	5.3	4.9	-0.4
ALU0411	2026/2	3	84	0	1	8.8	6.7	-2.1
ALU0412	2026/2	5	73	0	1	5.2	4.0	-1.2
ALU0413	2026/2	1	92	1	1	4.7	5.8	1.1
ALU0414	2026/2	3	82	1	1	5.4	6.6	1.2
ALU0415	2026/2	3	84	0	1	4.2	5.4	1.2
ALU0416	2026/2	2	89	0	1	7.2	7.1	-0.1
ALU0417	2026/2	8	57	0	5	6.6	4.7	-1.9
ALU0418	2026/2	0	100	1	1	7.2	6.5	-0.7
ALU0419	2026/2	4	79	0	2	6.6	6.4	-0.2
ALU0420	2026/2	3	83	0	1	7.2	8.0	0.8
ALU0421	2026/2	4	79	0	1	6.0	5.3	-0.7
ALU0422	2026/2	1	93	0	0	6.8	6.6	-0.2
ALU0423	2026/2	3	83	0	1	6.9	6.9	0.0
ALU0424	2026/2	1	93	1	0	5.9	7.0	1.1
ALU0425	2026/2	0	100	2	0	7.7	8.2	0.5
ALU0426	2026/2	2	91	1	3	4.6	4.7	0.1
ALU0427	2026/2	1	96	0	1	7.3	7.7	0.4
ALU0428	2026/2	1	95	0	2	7.3	7.0	-0.3
ALU0429	2026/2	5	73	0	1	4.7	7.4	2.7
ALU0430	2026/2	4	78	0	3	3.9	4.3	0.4
ALU0431	2026/2	3	81	1	1	6.1	6.1	0.0
ALU0432	2026/2	2	87	0	0	7.2	6.8	-0.4
ALU0433	2026/2	3	83	1	0	7.6	7.1	-0.5
ALU0434	2026/2	3	86	0	1	7.1	7.7	0.6
ALU0435	2026/2	4	80	1	1	6.5	5.6	-0.9
ALU0436	2026/2	3	84	0	1	7.5	8.4	0.9
ALU0437	2026/2	2	89	0	1	6.1	5.0	-1.1
ALU0438	2026/2	0	99	1	3	5.4	6.3	0.9
ALU0439	2026/2	5	70	0	3	6.3	5.9	-0.4
ALU0440	2026/2	0	100	2	1	6.3	6.6	0.3
ALU0441	2026/2	2	87	0	0	8.9	8.4	-0.5
ALU0442	2026/2	2	87	0	1	7.7	6.1	-1.6
ALU0443	2026/2	2	87	0	0	7.5	5.9	-1.6
ALU0444	2026/2	4	75	0	0	7.0	7.3	0.3
ALU0445	2026/2	2	90	1	2	5.6	4.7	-0.9
ALU0446	2026/2	3	85	0	2	7.2	7.4	0.2
ALU0447	2026/2	1	92	2	0	10.0	7.9	-2.1
ALU0448	2026/2	1	92	1	0	7.0	6.9	-0.1
ALU0449	2026/2	3	82	0	1	5.9	7.3	1.4
ALU0450	2026/2	3	84	0	4	8.4	8.3	-0.1
ALU0451	2026/2	4	80	0	1	4.5	5.8	1.3
ALU0452	2026/2	3	86	1	0	7.0	7.2	0.2
ALU0453	2026/2	4	79	0	1	6.6	5.3	-1.3
ALU0454	2026/2	4	79	1	1	6.2	6.6	0.4
ALU0455	2026/2	5	74	0	0	5.7	4.4	-1.3
ALU0456	2026/2	3	86	0	1	6.0	5.7	-0.3
ALU0457	2026/2	4	75	0	2	8.6	6.7	-1.9
ALU0458	2026/2	4	78	0	1	9.4	9.0	-0.4
ALU0459	2026/2	1	94	0	2	5.2	4.6	-0.6
ALU0460	2026/2	0	100	0	1	6.6	6.0	-0.6
ALU0461	2026/2	2	88	0	1	5.9	5.8	-0.1
ALU0462	2026/2	2	88	0	0	6.9	7.9	1.0
ALU0463	2026/2	5	70	0	2	3.4	5.4	2.0
ALU0464	2026/2	1	92	0	1	8.4	7.0	-1.4
ALU0465	2026/2	6	64	0	3	7.0	5.6	-1.4
ALU0466	2026/2	4	77	0	2	7.5	6.5	-1.0
ALU0467	2026/2	5	72	0	1	5.8	6.5	0.7
ALU0468	2026/2	5	70	0	1	9.2	7.0	-2.2
ALU0469	2026/2	2	88	0	2	6.1	6.8	0.7
ALU0470	2026/2	3	81	0	2	7.1	6.1	-1.0
ALU0471	2026/2	0	100	0	0	6.2	6.6	0.4
ALU0472	2026/2	2	91	0	2	6.4	7.5	1.1
ALU0473	2026/2	3	82	1	2	7.8	4.5	-3.3
ALU0474	2026/2	2	91	0	3	8.8	7.1	-1.7
ALU0475	2026/2	2	91	0	0	6.5	7.7	1.2
ALU0476	2026/2	1	93	1	2	8.6	8.1	-0.5
ALU0477	2026/2	3	82	1	0	8.0	8.1	0.1
ALU0478	2026/2	3	85	0	2	10.0	8.4	-1.6
ALU0479	2026/2	2	89	0	2	5.4	6.2	0.8
ALU0480	2026/2	1	95	0	0	7.0	7.7	0.7
ALU0481	2026/2	4	77	0	1	5.3	6.7	1.4
ALU0482	2026/2	1	97	0	1	5.1	7.1	2.0
ALU0483	2026/2	2	89	0	3	7.4	6.8	-0.6
ALU0484	2026/2	5	72	2	1	9.2	9.0	-0.2
ALU0485	2026/2	4	76	0	1	4.8	6.1	1.3
ALU0486	2026/2	4	79	0	3	7.7	8.4	0.7
ALU0487	2026/2	3	86	0	0	5.7	6.6	0.9
ALU0488	2026/2	2	87	0	0	7.4	6.8	-0.6
ALU0489	2026/2	5	71	0	2	2.5	5.2	2.7
ALU0490	2026/2	1	96	0	0	8.4	8.4	0.0
ALU0491	2026/2	1	97	0	2	7.9	7.8	-0.1
ALU0492	2026/2	2	89	0	2	5.5	6.4	0.9
ALU0493	2026/2	4	80	0	2	4.3	6.6	2.3
ALU0494	2026/2	4	79	1	1	8.9	9.3	0.4
ALU0495	2026/2	0	100	0	1	8.8	7.2	-1.6
ALU0496	2026/2	0	98	0	1	7.6	8.1	0.5
ALU0497	2026/2	1	92	0	0	6.4	6.5	0.1
ALU0498	2026/2	5	70	0	2	6.8	8.1	1.3
ALU0499	2026/2	4	75	0	2	4.4	5.1	0.7
ALU0500	2026/2	0	100	0	0	9.6	8.9	-0.7
ALU0501	2026/2	6	64	0	4	4.5	3.8	-0.7
ALU0502	2026/2	7	63	0	3	4.8	4.6	-0.2
ALU0503	2026/2	0	100	0	2	8.3	7.7	-0.6
ALU0504	2026/2	4	76	0	0	6.8	6.5	-0.3
ALU0505	2026/2	4	76	1	3	9.0	8.4	-0.6
ALU0506	2026/2	4	80	1	1	5.6	6.8	1.2
ALU0507	2026/2	3	82	0	2	7.2	7.5	0.3
ALU0508	2026/2	5	70	0	2	4.9	5.9	1.0
ALU0509	2026/2	3	86	0	2	8.3	7.9	-0.4
ALU0510	2026/2	5	71	0	0	8.0	8.0	0.0
ALU0511	2026/2	3	86	0	2	6.4	6.8	0.4
ALU0512	2026/2	0	100	0	1	5.6	6.9	1.3
ALU0513	2026/2	2	89	0	0	5.7	5.9	0.2
ALU0514	2026/2	4	80	0	1	7.6	7.3	-0.3
ALU0515	2026/2	2	88	0	1	5.9	6.9	1.0
ALU0516	2026/2	3	81	0	0	7.2	6.5	-0.7
ALU0517	2026/2	0	100	1	0	6.6	5.8	-0.8
ALU0518	2026/2	3	82	0	0	7.6	8.0	0.4
ALU0519	2026/2	4	80	0	0	6.0	5.6	-0.4
ALU0520	2026/2	1	92	0	1	7.7	6.6	-1.1
ALU0521	2026/2	3	82	0	0	9.4	7.2	-2.2
ALU0522	2026/2	1	93	0	1	6.3	6.6	0.3
ALU0523	2026/2	3	81	1	5	7.7	6.8	-0.9
ALU0524	2026/2	6	67	0	4	2.6	4.0	1.4
ALU0525	2026/2	3	86	0	0	6.5	6.1	-0.4
ALU0526	2026/2	4	78	0	1	5.6	5.5	-0.1
ALU0527	2026/2	3	82	0	0	4.6	6.1	1.5
ALU0528	2026/2	2	91	0	2	6.7	5.7	-1.0
ALU0529	2026/2	0	100	0	1	4.5	5.8	1.3
ALU0530	2026/2	4	78	1	1	4.7	4.7	0.0
ALU0531	2026/2	2	87	0	0	6.2	5.9	-0.3
ALU0532	2026/2	6	64	0	5	3.3	3.8	0.5
ALU0533	2026/2	3	83	0	0	7.0	6.9	-0.1
ALU0534	2026/2	5	71	0	2	5.5	5.8	0.3
ALU0535	2026/2	5	74	0	2	7.1	3.9	-3.2
ALU0536	2026/2	3	86	0	1	8.0	6.7	-1.3
ALU0537	2026/2	6	68	0	0	5.3	6.2	0.9
ALU0538	2026/2	2	91	0	1	5.9	7.1	1.2
ALU0539	2026/2	2	89	0	3	5.1	7.5	2.4
ALU0540	2026/2	2	89	0	1	8.8	8.2	-0.6
ALU0541	2026/2	0	100	1	0	7.3	5.9	-1.4
ALU0542	2026/2	4	80	0	3	6.3	6.7	0.4
ALU0543	2026/2	0	100	0	1	6.7	6.6	-0.1
ALU0544	2026/2	5	74	0	0	5.6	6.0	0.4
ALU0545	2026/2	1	92	0	1	3.8	4.6	0.8
ALU0546	2026/2	4	77	0	1	9.2	7.9	-1.3
ALU0547	2026/2	5	73	1	3	3.1	4.5	1.4
ALU0548	2026/2	1	96	0	3	6.2	4.6	-1.6
ALU0549	2026/2	1	96	0	1	7.9	7.5	-0.4
ALU0550	2026/2	0	100	1	3	7.3	5.4	-1.9
ALU0551	2026/2	2	89	0	1	7.4	7.4	0.0
ALU0552	2026/2	2	87	0	3	5.9	5.9	0.0
ALU0553	2026/2	1	96	0	1	7.7	7.0	-0.7
ALU0554	2026/2	4	75	0	0	4.5	5.0	0.5
ALU0555	2026/2	2	90	0	2	7.2	7.7	0.5
ALU0556	2026/2	4	75	0	1	4.4	5.4	1.0
ALU0557	2026/2	0	100	0	0	6.2	6.6	0.4
ALU0558	2026/2	6	69	1	0	8.6	7.4	-1.2
ALU0559	2026/2	2	89	0	0	5.9	6.4	0.5
ALU0560	2026/2	4	77	1	0	4.8	6.1	1.3
ALU0561	2026/2	1	96	0	0	6.6	6.1	-0.5
ALU0562	2026/2	3	83	0	1	9.4	7.6	-1.8
ALU0563	2026/2	2	89	0	0	8.2	7.2	-1.0
ALU0564	2026/2	4	77	1	1	7.1	6.6	-0.5
ALU0565	2026/2	1	93	0	1	7.0	7.1	0.1
ALU0566	2026/2	2	90	1	3	6.8	6.6	-0.2
ALU0567	2026/2	3	85	0	2	7.1	6.8	-0.3
ALU0568	2026/2	5	71	0	0	7.6	8.0	0.4
ALU0569	2026/2	6	67	1	2	5.8	4.8	-1.0
ALU0570	2026/2	1	95	0	1	7.3	5.0	-2.3
ALU0571	2026/2	4	78	1	0	8.9	8.5	-0.4
ALU0572	2026/2	4	77	0	2	5.9	4.2	-1.7
ALU0573	2026/2	3	83	1	3	7.2	6.0	-1.2
ALU0574	2026/2	1	96	0	0	5.8	6.5	0.7
ALU0575	2026/2	3	84	0	3	8.3	8.1	-0.2
ALU0576	2026/2	3	83	0	1	5.7	6.0	0.3
ALU0577	2026/2	3	85	1	0	7.6	6.9	-0.7
ALU0578	2026/2	4	76	0	1	8.0	6.9	-1.1
ALU0579	2026/2	1	93	1	2	6.1	5.1	-1.0
ALU0580	2026/2	2	88	0	1	5.9	6.3	0.4
ALU0581	2026/2	5	72	1	1	7.8	7.3	-0.5
ALU0582	2026/2	2	91	0	0	6.5	8.1	1.6
ALU0583	2026/2	4	79	0	0	4.9	6.9	2.0
ALU0584	2026/2	1	96	0	0	6.9	7.1	0.2
ALU0585	2026/2	3	85	0	0	7.3	6.5	-0.8
ALU0586	2026/2	2	89	0	0	6.7	7.2	0.5
ALU0587	2026/2	4	78	2	1	5.8	5.0	-0.8
ALU0588	2026/2	2	87	0	1	5.5	6.6	1.1
ALU0589	2026/2	4	77	0	0	6.1	5.6	-0.5
ALU0590	2026/2	4	78	0	1	7.0	6.5	-0.5
ALU0591	2026/2	1	93	1	0	8.7	7.0	-1.7
ALU0592	2026/2	3	85	0	2	6.4	7.9	1.5
ALU0593	2026/2	4	78	2	4	3.9	4.5	0.6
ALU0594	2026/2	3	81	0	3	6.2	6.4	0.2
ALU0595	2026/2	3	85	0	0	8.5	8.0	-0.5
ALU0596	2026/2	2	91	0	3	5.7	7.0	1.3
ALU0597	2026/2	3	86	0	2	6.6	6.0	-0.6
ALU0598	2026/2	4	80	0	0	5.0	5.5	0.5
ALU0599	2026/2	2	90	1	2	6.1	6.1	0.0
ALU0600	2026/2	3	86	0	0	7.7	8.5	0.8
ALU0601	2026/2	0	100	0	0	9.2	7.0	-2.2
ALU0602	2026/2	4	75	2	2	4.4	4.9	0.5
ALU0603	2026/2	2	91	1	1	6.5	6.4	-0.1
ALU0604	2026/2	7	63	0	2	5.3	5.1	-0.2
ALU0605	2026/2	2	91	0	0	9.1	8.0	-1.1
ALU0606	2026/2	5	70	0	3	3.7	5.3	1.6
ALU0607	2026/2	4	75	0	0	6.5	6.0	-0.5
ALU0608	2026/2	5	72	0	0	5.5	5.1	-0.4
ALU0609	2026/2	5	70	0	2	7.7	7.0	-0.7
ALU0610	2026/2	0	99	0	0	9.9	7.6	-2.3
ALU0611	2026/2	6	66	1	5	5.3	4.7	-0.6
ALU0612	2026/2	1	93	0	1	5.6	4.5	-1.1
ALU0613	2026/2	0	100	1	0	7.4	7.8	0.4
ALU0614	2026/2	3	81	0	1	8.1	7.5	-0.6
ALU0615	2026/2	4	75	0	2	8.8	6.7	-2.1
ALU0616	2026/2	2	88	0	0	6.1	5.8	-0.3
ALU0617	2026/2	4	79	0	3	5.4	4.0	-1.4
ALU0618	2026/2	0	99	0	3	4.8	5.2	0.4
ALU0619	2026/2	3	85	0	1	7.2	6.4	-0.8
ALU0620	2026/2	6	67	1	0	5.4	5.8	0.4
ALU0621	2026/2	5	72	1	1	5.7	5.6	-0.1
ALU0622	2026/2	7	62	2	6	3.9	4.8	0.9
ALU0623	2026/2	0	100	0	1	7.6	7.8	0.2
ALU0624	2026/2	2	88	0	1	8.2	8.0	-0.2
ALU0625	2026/2	3	84	1	1	5.0	6.0	1.0
ALU0626	2026/2	3	86	0	1	9.8	8.4	-1.4
ALU0627	2026/2	3	83	0	1	6.8	5.8	-1.0
ALU0628	2026/2	4	76	0	0	6.8	6.5	-0.3
ALU0629	2026/2	2	90	1	1	6.0	6.9	0.9
ALU0630	2026/2	1	93	0	1	9.3	8.3	-1.0
ALU0631	2026/2	2	88	0	0	8.2	6.8	-1.4
ALU0632	2026/2	6	64	0	0	6.3	6.1	-0.2
ALU0633	2026/2	5	73	0	3	7.4	5.2	-2.2
ALU0634	2026/2	2	89	1	3	7.4	8.6	1.2
ALU0635	2026/2	2	90	0	1	8.1	7.9	-0.2
ALU0636	2026/2	5	73	0	0	6.6	5.2	-1.4
ALU0637	2026/2	4	78	0	3	8.7	8.5	-0.2
ALU0638	2026/2	0	99	0	1	8.5	8.9	0.4
ALU0639	2026/2	4	79	1	1	9.6	6.9	-2.7
ALU0640	2026/2	0	100	0	0	7.9	7.5	-0.4
ALU0641	2026/2	0	100	0	2	8.6	7.8	-0.8
ALU0642	2026/2	5	73	0	4	6.0	6.6	0.6
ALU0643	2026/2	0	100	1	0	5.8	5.1	-0.7
ALU0644	2026/2	3	85	0	1	8.6	7.2	-1.4
ALU0645	2026/2	2	89	1	0	6.2	6.3	0.1
ALU0646	2026/2	2	91	0	0	4.9	7.1	2.2
ALU0647	2026/2	5	71	1	1	3.2	4.0	0.8
ALU0648	2026/2	6	64	1	0	6.3	6.0	-0.3
ALU0649	2026/2	1	94	1	0	5.8	7.2	1.4
ALU0650	2026/2	3	86	0	1	6.7	6.0	-0.7
ALU0651	2026/2	4	78	1	0	5.4	6.3	0.9
ALU0652	2026/2	3	82	0	0	5.5	5.4	-0.1
ALU0653	2026/2	4	79	0	0	9.4	7.1	-2.3
ALU0654	2026/2	4	79	0	1	6.6	7.1	0.5
ALU0655	2026/2	1	94	1	1	7.2	7.7	0.5
ALU0656	2026/2	4	80	1	1	9.8	7.7	-2.1
ALU0657	2026/2	3	81	1	3	5.9	6.6	0.7
ALU0658	2026/2	7	63	0	1	6.6	7.1	0.5
ALU0659	2026/2	3	84	0	3	6.1	7.4	1.3
ALU0660	2026/2	4	78	0	0	4.6	4.9	0.3
ALU0661	2026/2	2	88	2	1	5.9	5.6	-0.3
ALU0662	2026/2	7	62	1	0	5.0	6.0	1.0
ALU0663	2026/2	3	86	0	0	7.4	5.5	-1.9
ALU0664	2026/2	4	78	0	1	5.7	5.9	0.2
ALU0665	2026/2	5	70	0	2	7.5	7.0	-0.5
ALU0666	2026/2	3	81	0	0	5.1	5.6	0.5
ALU0667	2026/2	4	77	0	1	7.3	7.5	0.2
ALU0668	2026/2	3	85	1	1	6.8	6.8	0.0
ALU0669	2026/2	3	83	1	1	5.6	5.6	0.0
ALU0670	2026/2	3	85	1	0	5.5	7.0	1.5
ALU0671	2026/2	3	85	0	1	5.3	5.7	0.4
ALU0672	2026/2	3	81	0	2	6.4	5.5	-0.9
ALU0673	2026/2	1	96	0	1	6.2	6.6	0.4
ALU0674	2026/2	6	69	0	1	6.0	6.8	0.8
ALU0675	2026/2	5	73	0	0	2.3	4.3	2.0
ALU0676	2026/2	3	82	0	2	8.5	8.4	-0.1
ALU0677	2026/2	2	89	0	1	6.5	6.9	0.4
ALU0678	2026/2	3	81	0	0	5.7	6.9	1.2
ALU0679	2026/2	3	86	0	2	6.6	7.8	1.2
ALU0680	2026/2	2	90	1	1	7.7	7.6	-0.1
ALU0681	2026/2	3	86	1	0	6.5	5.4	-1.1
ALU0682	2026/2	3	81	0	1	6.8	6.8	0.0
ALU0683	2026/2	4	80	0	1	10.0	8.5	-1.5
ALU0684	2026/2	2	87	0	1	7.7	7.7	0.0
ALU0685	2026/2	6	66	0	2	5.7	4.9	-0.8
ALU0686	2026/2	2	91	1	0	6.7	6.3	-0.4
ALU0687	2026/2	3	85	0	2	6.2	6.0	-0.2
ALU0688	2026/2	1	93	0	2	5.4	6.0	0.6
ALU0689	2026/2	3	81	0	4	5.6	5.1	-0.5
ALU0690	2026/2	4	77	0	1	4.6	6.9	2.3
ALU0691	2026/2	4	76	0	1	3.4	3.0	-0.4
ALU0692	2026/2	5	74	0	2	4.2	3.7	-0.5
ALU0693	2026/2	4	76	0	0	7.3	7.0	-0.3
ALU0694	2026/2	3	82	0	1	6.2	5.5	-0.7
ALU0695	2026/2	3	84	2	2	8.0	7.0	-1.0
ALU0696	2026/2	2	87	0	4	4.9	6.0	1.1
ALU0697	2026/2	3	81	0	1	5.1	6.0	0.9
ALU0698	2026/2	3	84	0	0	7.2	7.5	0.3
ALU0699	2026/2	6	67	1	1	5.8	7.4	1.6
ALU0700	2026/2	0	99	0	0	6.9	7.5	0.6
ALU0701	2026/2	2	87	2	1	6.9	7.4	0.5
ALU0702	2026/2	2	90	0	1	6.3	6.0	-0.3
ALU0703	2026/2	6	64	0	1	4.9	5.7	0.8
ALU0704	2026/2	4	79	2	2	5.6	6.1	0.5
ALU0705	2026/2	3	86	0	2	6.5	6.0	-0.5
ALU0706	2026/2	3	81	1	0	6.5	8.0	1.5
ALU0707	2026/2	5	73	0	0	7.7	7.4	-0.3
ALU0708	2026/2	2	91	0	0	8.1	8.6	0.5
ALU0709	2026/2	2	89	1	1	6.2	6.7	0.5
ALU0710	2026/2	4	80	1	0	6.8	6.3	-0.5
ALU0711	2026/2	0	100	0	0	7.4	6.1	-1.3
ALU0712	2026/2	6	69	0	1	6.2	5.6	-0.6
ALU0713	2026/2	3	83	0	1	8.3	7.9	-0.4
ALU0714	2026/2	3	83	0	1	4.8	6.2	1.4
ALU0715	2026/2	4	77	0	2	5.6	5.7	0.1
ALU0716	2026/2	3	83	0	0	9.2	7.9	-1.3
ALU0717	2026/2	1	93	1	1	7.8	8.4	0.6
ALU0718	2026/2	2	88	1	1	7.2	6.7	-0.5
ALU0719	2026/2	4	80	1	0	6.5	7.1	0.6
ALU0720	2026/2	3	83	0	1	9.3	8.2	-1.1
ALU0721	2026/2	4	79	0	0	6.4	6.9	0.5
ALU0722	2026/2	2	89	0	1	9.2	7.0	-2.2
ALU0723	2026/2	1	95	0	0	6.6	7.3	0.7
ALU0724	2026/2	2	91	0	1	7.3	6.8	-0.5
ALU0725	2026/2	1	95	1	1	6.3	6.3	0.0
ALU0726	2026/2	2	88	0	1	5.7	6.4	0.7
ALU0727	2026/2	2	88	0	2	3.7	3.5	-0.2
ALU0728	2026/2	2	88	0	1	5.5	6.4	0.9
ALU0729	2026/2	2	87	0	0	7.7	7.5	-0.2
ALU0730	2026/2	3	85	0	1	3.9	5.3	1.4
ALU0731	2026/2	3	85	0	2	5.8	6.3	0.5
ALU0732	2026/2	1	92	1	2	8.0	7.1	-0.9
ALU0733	2026/2	1	96	0	0	6.8	7.9	1.1
ALU0734	2026/2	1	97	0	0	9.1	7.2	-1.9
ALU0735	2026/2	4	77	2	2	6.7	6.1	-0.6
ALU0736	2026/2	4	77	0	3	7.0	5.5	-1.5
ALU0737	2026/2	2	89	0	2	5.5	7.5	2.0
ALU0738	2026/2	5	71	0	1	5.0	3.2	-1.8
ALU0739	2026/2	1	95	1	1	6.0	6.5	0.5
ALU0740	2026/2	4	77	0	1	6.2	6.4	0.2
ALU0741	2026/2	0	100	2	3	4.8	6.6	1.8
ALU0742	2026/2	4	77	0	1	7.1	8.1	1.0
ALU0743	2026/2	2	90	0	1	7.1	6.3	-0.8
ALU0744	2026/2	4	78	1	1	6.0	6.9	0.9
ALU0745	2026/2	2	89	1	2	4.9	7.2	2.3
ALU0746	2026/2	3	85	0	2	6.0	5.6	-0.4
ALU0747	2026/2	5	71	0	2	6.0	5.0	-1.0
ALU0748	2026/2	5	74	0	4	3.3	3.4	0.1
ALU0749	2026/2	3	84	0	0	6.1	6.1	0.0
ALU0750	2026/2	1	95	1	1	7.6	7.7	0.1
ALU0751	2026/2	1	95	0	2	3.8	6.6	2.8
ALU0752	2026/2	4	80	1	0	4.7	6.6	1.9
ALU0753	2026/2	1	95	1	1	7.1	7.3	0.2
ALU0754	2026/2	0	98	0	0	6.1	6.5	0.4
ALU0755	2026/2	2	87	0	0	6.7	7.3	0.6
ALU0756	2026/2	2	88	0	0	6.6	6.8	0.2
ALU0757	2026/2	1	94	1	1	8.8	7.8	-1.0
ALU0758	2026/2	3	81	0	0	6.9	5.0	-1.9
ALU0759	2026/2	2	87	0	0	6.3	6.8	0.5
ALU0760	2026/2	2	91	0	0	7.5	5.7	-1.8
ALU0761	2026/2	1	95	1	3	7.2	6.3	-0.9
ALU0762	2026/2	1	92	0	0	7.7	7.8	0.1
ALU0763	2026/2	2	90	0	0	5.2	6.4	1.2
ALU0764	2026/2	6	69	0	1	5.8	4.9	-0.9
ALU0765	2026/2	4	78	0	0	6.6	5.6	-1.0
ALU0766	2026/2	2	87	0	1	4.2	5.9	1.7
ALU0767	2026/2	4	78	0	2	4.0	6.5	2.5
ALU0768	2026/2	4	80	0	2	2.2	3.3	1.1
ALU0769	2026/2	3	83	0	1	7.0	5.3	-1.7
ALU0770	2026/2	7	60	0	3	6.3	4.3	-2.0
ALU0771	2026/2	2	88	0	1	6.5	6.9	0.4
ALU0772	2026/2	2	90	1	0	7.0	5.4	-1.6
ALU0773	2026/2	0	99	0	0	8.1	8.3	0.2
ALU0774	2026/2	3	85	0	1	6.7	8.2	1.5
ALU0775	2026/2	3	82	0	0	7.5	7.9	0.4
ALU0776	2026/2	4	79	0	1	8.6	7.5	-1.1
ALU0777	2026/2	3	84	0	3	4.8	6.1	1.3
ALU0778	2026/2	4	76	0	0	3.9	4.5	0.6
ALU0779	2026/2	3	82	0	0	5.9	6.6	0.7
ALU0780	2026/2	2	88	0	1	7.7	8.0	0.3
ALU0781	2026/2	4	75	0	0	4.2	4.3	0.1
ALU0782	2026/2	3	83	0	0	7.4	7.6	0.2
ALU0783	2026/2	4	78	0	0	4.5	5.7	1.2
ALU0784	2026/2	4	77	0	1	7.3	7.0	-0.3
ALU0785	2026/2	4	80	0	0	6.7	6.6	-0.1
ALU0786	2026/2	2	91	0	2	8.1	7.8	-0.3
ALU0787	2026/2	2	91	1	2	8.0	7.9	-0.1
ALU0788	2026/2	3	83	0	0	4.9	6.7	1.8
ALU0789	2026/2	2	88	0	0	8.9	8.4	-0.5
ALU0790	2026/2	5	74	0	1	5.7	6.4	0.7
ALU0791	2026/2	5	70	0	0	6.0	6.9	0.9
ALU0792	2026/2	4	75	1	1	6.1	7.1	1.0
ALU0793	2026/2	1	93	1	3	7.5	6.6	-0.9
ALU0794	2026/2	4	78	0	1	7.8	7.7	-0.1
ALU0795	2026/2	3	84	0	1	6.5	7.3	0.8
ALU0796	2026/2	2	87	1	0	5.8	6.1	0.3
ALU0797	2026/2	2	87	0	2	6.9	6.5	-0.4
ALU0798	2026/2	2	87	1	0	7.6	7.4	-0.2
ALU0799	2026/2	6	64	0	1	7.7	7.9	0.2
ALU0800	2026/2	3	86	0	1	6.5	6.3	-0.2
ALU0801	2026/2	3	84	0	0	9.0	6.9	-2.1
ALU0802	2026/2	3	84	0	0	6.6	6.2	-0.4
ALU0803	2026/2	4	76	1	0	5.7	4.9	-0.8
ALU0804	2026/2	2	88	0	0	7.3	6.0	-1.3
ALU0805	2026/2	3	83	1	0	5.7	6.1	0.4
ALU0806	2026/2	7	60	1	3	5.1	5.6	0.5
ALU0807	2026/2	6	66	0	7	3.7	5.8	2.1
ALU0808	2026/2	4	79	0	0	4.2	4.6	0.4
ALU0809	2026/2	5	70	1	1	8.2	7.3	-0.9
ALU0810	2026/2	1	94	0	0	7.1	8.0	0.9
ALU0811	2026/2	3	85	1	5	8.2	7.1	-1.1
ALU0812	2026/2	1	92	2	0	7.1	6.8	-0.3
ALU0813	2026/2	5	71	1	1	5.1	5.7	0.6
ALU0814	2026/2	0	98	0	1	7.8	7.4	-0.4
ALU0815	2026/2	3	86	2	1	7.7	6.5	-1.2
ALU0816	2026/2	1	92	0	1	9.2	9.2	0.0
ALU0817	2026/2	3	83	0	0	7.8	7.8	0.0
ALU0818	2026/2	5	74	0	1	5.5	5.9	0.4
ALU0819	2026/2	2	90	0	0	6.8	7.0	0.2
ALU0820	2026/2	0	99	1	1	5.5	6.6	1.1
ALU0821	2026/2	0	98	0	1	9.4	7.6	-1.8
ALU0822	2026/2	4	78	0	0	6.4	4.7	-1.7
ALU0823	2026/2	3	83	0	0	7.1	7.0	-0.1
ALU0824	2026/2	4	76	0	0	6.5	6.7	0.2
ALU0825	2026/2	2	88	0	2	7.5	7.0	-0.5
ALU0826	2026/2	3	85	0	2	6.7	8.0	1.3
ALU0827	2026/2	3	84	0	3	3.3	4.3	1.0
ALU0828	2026/2	1	92	0	1	7.6	7.0	-0.6
ALU0829	2026/2	3	82	0	1	5.1	5.1	0.0
ALU0830	2026/2	6	66	0	1	6.7	5.9	-0.8
ALU0831	2026/2	3	81	0	1	6.2	5.8	-0.4
ALU0832	2026/2	3	85	0	1	8.4	8.3	-0.1
ALU0833	2026/2	0	100	0	1	6.9	7.5	0.6
ALU0834	2026/2	4	75	1	1	8.2	7.4	-0.8
ALU0835	2026/2	3	81	0	0	5.2	5.6	0.4
ALU0836	2026/2	6	64	1	1	4.9	6.2	1.3
ALU0837	2026/2	2	89	1	1	8.9	8.2	-0.7
ALU0838	2026/2	1	94	1	0	5.0	6.2	1.2
ALU0839	2026/2	1	93	0	1	8.8	7.7	-1.1
ALU0840	2026/2	2	90	0	1	7.1	7.2	0.1
ALU0841	2026/2	4	77	1	2	8.9	8.0	-0.9
ALU0842	2026/2	2	88	2	1	6.0	6.5	0.5
ALU0843	2026/2	5	74	0	3	3.0	3.7	0.7
ALU0844	2026/2	4	76	0	1	5.6	3.8	-1.8
ALU0845	2026/2	3	82	0	1	4.8	5.9	1.1
ALU0846	2026/2	3	85	1	1	6.7	5.6	-1.1
ALU0847	2026/2	6	66	1	2	5.3	5.4	0.1
ALU0848	2026/2	3	85	1	0	6.0	6.3	0.3
ALU0849	2026/2	0	100	0	0	5.6	5.5	-0.1
ALU0850	2026/2	5	73	0	1	7.7	7.2	-0.5
ALU0851	2026/2	1	97	0	2	4.6	5.8	1.2
ALU0852	2026/2	2	88	0	1	7.5	7.0	-0.5
ALU0853	2026/2	3	85	2	2	7.2	6.4	-0.8
ALU0854	2026/2	0	98	0	1	6.6	8.5	1.9
ALU0855	2026/2	6	64	0	1	4.2	5.2	1.0
ALU0856	2026/2	3	86	0	1	6.0	6.6	0.6
ALU0857	2026/2	4	76	0	2	5.9	7.3	1.4
ALU0858	2026/2	2	87	0	0	4.6	4.3	-0.3
ALU0859	2026/2	6	66	0	2	3.1	3.8	0.7
ALU0860	2026/2	3	86	0	0	5.7	6.7	1.0
ALU0861	2026/2	6	69	1	0	5.3	6.2	0.9
ALU0862	2026/2	4	78	1	1	4.4	5.7	1.3
ALU0863	2026/2	6	69	2	0	6.6	5.3	-1.3
ALU0864	2026/2	3	86	0	1	5.5	7.3	1.8
ALU0865	2026/2	1	95	0	0	7.3	6.7	-0.6
ALU0866	2026/2	9	51	0	2	5.6	3.9	-1.7
ALU0867	2026/2	1	93	0	0	6.5	7.0	0.5
ALU0868	2026/2	2	89	0	1	6.6	7.3	0.7
ALU0869	2026/2	3	86	0	2	6.6	6.8	0.2
ALU0870	2026/2	1	94	1	0	5.9	7.8	1.9
ALU0871	2026/2	4	77	0	1	7.4	8.7	1.3
ALU0872	2026/2	1	93	0	0	8.0	6.4	-1.6
ALU0873	2026/2	4	76	0	1	8.1	7.1	-1.0
ALU0874	2026/2	3	85	0	0	6.6	6.1	-0.5
ALU0875	2026/2	3	83	0	1	6.3	6.3	0.0
ALU0876	2026/2	4	78	0	0	7.3	5.8	-1.5
ALU0877	2026/2	0	100	0	0	6.7	6.5	-0.2
ALU0878	2026/2	6	65	0	3	4.4	5.0	0.6
ALU0879	2026/2	1	93	0	2	6.1	7.0	0.9
ALU0880	2026/2	5	72	0	0	6.2	6.9	0.7
ALU0881	2026/2	0	100	0	2	8.4	7.9	-0.5
ALU0882	2026/2	5	74	0	1	4.7	3.7	-1.0
ALU0883	2026/2	4	79	0	0	8.9	7.5	-1.4
ALU0884	2026/2	3	85	0	0	7.9	7.3	-0.6
ALU0885	2026/2	3	84	0	1	6.8	5.7	-1.1
ALU0886	2026/2	0	100	0	0	7.2	7.0	-0.2
ALU0887	2026/2	1	95	0	0	5.7	5.9	0.2
ALU0888	2026/2	3	84	1	0	8.0	5.7	-2.3
ALU0889	2026/2	4	79	0	2	7.4	6.3	-1.1
ALU0890	2026/2	2	87	0	2	4.6	5.9	1.3
ALU0891	2026/2	2	87	0	2	5.9	6.9	1.0
ALU0892	2026/2	2	88	0	2	7.4	7.0	-0.4
ALU0893	2026/2	6	68	0	0	3.9	4.6	0.7
ALU0894	2026/2	0	100	0	0	3.8	5.4	1.6
ALU0895	2026/2	6	64	0	1	6.2	6.1	-0.1
ALU0896	2026/2	4	80	0	1	7.0	6.8	-0.2
ALU0897	2026/2	2	87	0	1	6.0	7.0	1.0
ALU0898	2026/2	1	95	0	1	4.4	6.4	2.0
ALU0899	2026/2	5	72	1	3	4.3	4.7	0.4
ALU0900	2026/2	0	100	0	0	10.0	8.2	-1.8
ALU0901	2026/2	4	79	0	0	4.7	5.2	0.5
ALU0902	2026/2	2	89	0	0	4.4	6.4	2.0
ALU0903	2026/2	4	80	0	1	5.1	3.6	-1.5
ALU0904	2026/2	3	85	0	2	3.9	4.9	1.0
ALU0905	2026/2	3	85	0	0	8.3	6.9	-1.4
ALU0906	2026/2	4	80	0	0	7.0	6.6	-0.4
ALU0907	2026/2	5	74	2	3	7.0	6.7	-0.3
ALU0908	2026/2	1	92	0	3	5.1	5.8	0.7
ALU0909	2026/2	3	86	0	0	6.8	6.5	-0.3
ALU0910	2026/2	1	94	0	0	5.7	5.5	-0.2
ALU0911	2026/2	2	90	0	1	9.0	8.0	-1.0
ALU0912	2026/2	4	75	0	0	6.2	6.4	0.2
ALU0913	2026/2	2	90	0	1	8.0	6.9	-1.1
ALU0914	2026/2	0	100	0	5	7.9	8.3	0.4
ALU0915	2026/2	5	70	0	2	6.2	4.5	-1.7
ALU0916	2026/2	4	76	0	3	5.7	6.6	0.9
ALU0917	2026/2	4	76	0	1	5.4	6.2	0.8
ALU0918	2026/2	6	67	0	1	7.3	6.4	-0.9
ALU0919	2026/2	8	58	0	3	4.2	4.7	0.5
ALU0920	2026/2	1	95	2	0	6.9	6.4	-0.5
ALU0921	2026/2	4	78	0	4	6.1	5.9	-0.2
ALU0922	2026/2	4	75	0	2	6.7	7.9	1.2
ALU0923	2026/2	3	86	0	2	4.7	6.0	1.3
ALU0924	2026/2	5	70	0	0	7.0	7.0	0.0
ALU0925	2026/2	3	82	0	0	6.6	8.4	1.8
ALU0926	2026/2	2	91	0	0	5.1	4.8	-0.3
ALU0927	2026/2	3	85	0	0	7.7	7.4	-0.3
ALU0928	2026/2	4	76	0	2	6.3	5.7	-0.6
ALU0929	2026/2	5	74	0	2	5.1	5.8	0.7
ALU0930	2026/2	1	95	0	0	7.1	5.2	-1.9
ALU0931	2026/2	4	80	1	1	9.5	8.5	-1.0
ALU0932	2026/2	3	86	1	1	8.1	8.4	0.3
ALU0933	2026/2	4	76	0	1	6.9	6.1	-0.8
ALU0934	2026/2	5	73	1	0	8.9	7.4	-1.5
ALU0935	2026/2	2	89	0	2	3.4	3.7	0.3
ALU0936	2026/2	3	83	0	2	7.6	8.3	0.7
ALU0937	2026/2	5	73	0	4	4.4	6.4	2.0
ALU0938	2026/2	4	75	0	1	8.1	7.2	-0.9
ALU0939	2026/2	4	77	0	1	6.8	6.8	0.0
ALU0940	2026/2	2	91	1	1	7.5	6.6	-0.9
ALU0941	2026/2	2	89	0	0	8.5	7.9	-0.6
ALU0942	2026/2	2	87	0	0	5.4	6.3	0.9
ALU0943	2026/2	6	69	0	2	5.6	5.6	0.0
ALU0944	2026/2	5	74	2	3	4.9	4.5	-0.4
ALU0945	2026/2	2	87	0	1	9.1	8.3	-0.8
ALU0946	2026/2	0	100	0	1	6.5	5.5	-1.0
ALU0947	2026/2	4	77	0	2	6.0	4.9	-1.1
ALU0948	2026/2	1	94	0	2	6.5	7.4	0.9
ALU0949	2026/2	2	87	1	3	3.9	4.8	0.9
ALU0950	2026/2	5	72	0	1	8.5	8.2	-0.3
ALU0951	2026/2	5	73	0	2	4.0	5.4	1.4
ALU0952	2026/2	3	82	1	1	6.3	6.9	0.6
ALU0953	2026/2	6	69	0	0	6.3	6.6	0.3
ALU0954	2026/2	6	68	0	1	6.7	7.8	1.1
ALU0955	2026/2	2	91	0	0	6.1	6.2	0.1
ALU0956	2026/2	3	86	0	2	4.8	5.4	0.6
ALU0957	2026/2	0	99	0	1	8.4	7.8	-0.6
ALU0958	2026/2	3	84	0	3	5.8	6.4	0.6
ALU0959	2026/2	3	82	0	0	5.1	6.0	0.9
ALU0960	2026/2	0	98	0	0	6.1	6.0	-0.1
ALU0961	2026/2	7	62	0	2	5.1	5.1	0.0
ALU0962	2026/2	2	87	0	0	7.8	6.2	-1.6
ALU0963	2026/2	2	90	0	2	5.8	7.2	1.4
ALU0964	2026/2	1	92	0	2	4.6	6.6	2.0
ALU0965	2026/2	5	74	0	0	8.8	8.4	-0.4
ALU0966	2026/2	6	69	1	0	4.7	4.8	0.1
ALU0967	2026/2	3	81	0	0	7.2	6.1	-1.1
ALU0968	2026/2	4	80	0	4	6.0	6.4	0.4
ALU0969	2026/2	3	86	0	0	7.4	7.1	-0.3
ALU0970	2026/2	3	82	0	1	8.2	7.6	-0.6
ALU0971	2026/2	3	85	1	0	7.6	7.3	-0.3
ALU0972	2026/2	5	73	0	2	6.5	5.8	-0.7
ALU0973	2026/2	2	87	0	3	7.2	6.1	-1.1
ALU0974	2026/2	2	91	0	3	7.4	7.0	-0.4
ALU0975	2026/2	4	78	1	3	6.7	6.3	-0.4
ALU0976	2026/2	5	70	0	0	6.6	5.2	-1.4
ALU0977	2026/2	5	74	1	1	9.1	7.6	-1.5
ALU0978	2026/2	5	73	0	0	6.2	6.5	0.3
ALU0979	2026/2	0	98	1	1	7.5	8.9	1.4
ALU0980	2026/2	3	81	0	3	5.9	6.0	0.1
ALU0981	2026/2	4	77	0	1	8.7	7.5	-1.2
ALU0982	2026/2	5	71	0	2	4.1	6.3	2.2
ALU0983	2026/2	2	89	0	0	7.9	8.2	0.3
ALU0984	2026/2	1	96	0	0	5.5	7.5	2.0
ALU0985	2026/2	1	94	0	0	6.5	7.5	1.0
ALU0986	2026/2	3	82	1	0	8.4	7.5	-0.9
ALU0987	2026/2	1	97	0	1	7.9	6.5	-1.4
ALU0988	2026/2	2	88	2	2	7.8	7.8	0.0
ALU0989	2026/2	3	86	0	2	5.1	5.4	0.3
ALU0990	2026/2	7	62	1	1	4.3	5.1	0.8
ALU0991	2026/2	4	76	1	0	4.1	5.6	1.5
ALU0992	2026/2	2	88	0	2	6.2	6.6	0.4
ALU0993	2026/2	3	85	0	1	7.1	6.8	-0.3
ALU0994	2026/2	3	82	1	2	8.0	6.8	-1.2
ALU0995	2026/2	3	82	0	2	5.7	6.9	1.2
ALU0996	2026/2	4	78	0	2	8.0	7.9	-0.1
ALU0997	2026/2	4	78	0	0	7.6	7.2	-0.4
ALU0998	2026/2	0	100	0	0	8.1	7.2	-0.9
ALU0999	2026/2	0	100	0	1	8.3	7.5	-0.8
ALU1000	2026/2	2	87	1	1	5.7	6.6	0.9
\.

COPY public.course_subjects (course_subject_id, course_id, name, curriculum_semester, workload_h, passing_average, minimum_attendance_pct) FROM stdin;
IA101	CUR01	Programming Logic	1	60	6	75
IA102	CUR01	Algorithms and Programming I	1	80	6	75
IA103	CUR01	Calculus I	1	80	6	75
IA104	CUR01	Foundations of Artificial Intelligence	1	60	6	75
IA105	CUR01	Discrete Mathematics	1	60	6	75
IA106	CUR01	Communication and Ethics in Technology	1	40	6	75
IA201	CUR01	Algorithms and Programming II	2	80	6	75
IA202	CUR01	Calculus II	2	80	6	75
IA203	CUR01	Linear Algebra	2	60	6	75
IA204	CUR01	Data Structures	2	80	6	75
IA205	CUR01	Probability and Statistics	2	60	6	75
IA206	CUR01	Computer Architecture	2	60	6	75
IA301	CUR01	Databases	3	80	6	75
IA302	CUR01	Object-Oriented Programming	3	80	6	75
IA303	CUR01	Applied Statistics	3	60	6	75
IA304	CUR01	Operating Systems	3	60	6	75
IA305	CUR01	Analysis of Algorithms	3	60	6	75
IA306	CUR01	Python for Data Science	3	60	6	75
IA401	CUR01	Machine Learning I	4	80	6	75
IA402	CUR01	Data Mining	4	60	6	75
IA403	CUR01	Software Engineering	4	60	6	75
IA404	CUR01	Computer Networks	4	60	6	75
IA405	CUR01	Optimization	4	60	6	75
IA406	CUR01	Data Visualization	4	40	6	75
IA501	CUR01	Machine Learning II	5	80	6	75
IA502	CUR01	Neural Networks	5	80	6	75
IA503	CUR01	Natural Language Processing	5	60	6	75
IA504	CUR01	Non-Relational Databases	5	60	6	75
IA505	CUR01	Cloud Computing	5	60	6	75
IA506	CUR01	Ethics and Regulation in AI	5	40	6	75
IA601	CUR01	Deep Learning	6	80	6	75
IA602	CUR01	Computer Vision	6	60	6	75
IA603	CUR01	Big Data	6	60	6	75
IA604	CUR01	Multi-Agent Systems	6	60	6	75
IA605	CUR01	Reinforcement Learning	6	60	6	75
IA606	CUR01	Data Engineering	6	60	6	75
IA701	CUR01	Generative AI	7	60	6	75
IA702	CUR01	MLOps	7	60	6	75
IA703	CUR01	Intelligent Robotics	7	60	6	75
IA704	CUR01	Scientific Methodology	7	40	6	75
IA705	CUR01	Data Security and Privacy	7	60	6	75
IA706	CUR01	Capstone Project I	7	80	6	75
IA801	CUR01	Capstone Project II	8	80	6	75
IA802	CUR01	Advanced Topics in AI	8	60	6	75
IA803	CUR01	Entrepreneurship in Technology	8	40	6	75
IA804	CUR01	Human-AI Interaction	8	60	6	75
IA805	CUR01	AI Project Management	8	60	6	75
IA806	CUR01	Supervised Internship	8	120	6	75
\.

COPY public.enrollments (enrollment_id, student_id, class_id, final_grade, attendance_pct, status, exam1, exam2, exam3) FROM stdin;
MAT01557	ALU0260	IA803-B	74.67	77	Approved	77	66	81
MAT05457	ALU0910	IA303-A	79.33	86	Approved	63	91	84
MAT02965	ALU0495	IA401-A	79.00	80	Approved	93	78	66
MAT01801	ALU0301	IA101-B	72.00	82	Approved	72	80	64
MAT05717	ALU0953	IA405-B	81.67	75	Approved	88	94	63
MAT03736	ALU0623	IA604-A	84.67	82	Approved	74	90	90
MAT05806	ALU0968	IA504-B	77.00	98	Approved	88	81	62
MAT05811	ALU0969	IA203-B	78.33	86	Approved	71	82	82
MAT02001	ALU0334	IA203-A	91.33	88	Approved	81	96	97
MAT01163	ALU0194	IA505-A	76.67	86	Approved	90	73	67
MAT00298	ALU0050	IA304-B	86.67	80	Approved	100	77	83
MAT04147	ALU0692	IA201-B	78.00	88	Approved	75	90	69
MAT00734	ALU0123	IA102-B	73.00	99	Approved	68	89	62
MAT02755	ALU0460	IA501-B	74.33	78	Approved	69	67	87
MAT04660	ALU0777	IA304-B	72.67	75	Approved	64	86	68
MAT05162	ALU0861	IA202-B	86.00	97	Approved	95	73	90
MAT05853	ALU0976	IA303-A	83.33	91	Approved	73	93	84
MAT04903	ALU0818	IA701-A	91.67	77	Approved	91	99	85
MAT00270	ALU0045	IA106-B	76.00	99	Approved	82	70	76
MAT01075	ALU0180	IA501-B	79.67	95	Approved	74	86	79
MAT05437	ALU0907	IA201-B	82.00	84	Approved	70	83	93
MAT04143	ALU0691	IA503-B	75.00	78	Approved	89	73	63
MAT05772	ALU0962	IA306-B	86.00	88	Approved	97	81	80
MAT00020	ALU0004	IA702-A	87.00	87	Approved	99	66	96
MAT05288	ALU0882	IA402-B	82.67	89	Approved	63	88	97
MAT00461	ALU0077	IA405-A	81.67	84	Approved	63	85	97
MAT00406	ALU0068	IA104-A	85.00	85	Approved	97	64	94
MAT03379	ALU0564	IA201-B	86.00	78	Approved	67	99	92
MAT05173	ALU0863	IA601-B	73.00	86	Approved	81	61	77
MAT00316	ALU0053	IA804-A	85.33	99	Approved	88	83	85
MAT02488	ALU0415	IA804-B	82.00	86	Approved	60	93	93
MAT00524	ALU0088	IA802-B	78.33	81	Approved	88	82	65
MAT05068	ALU0845	IA504-B	77.33	78	Approved	71	93	68
MAT05576	ALU0930	IA102-A	83.33	80	Approved	100	85	65
MAT00245	ALU0041	IA305-A	71.00	86	Approved	84	66	63
MAT02461	ALU0411	IA401-B	79.33	87	Approved	85	67	86
MAT02240	ALU0374	IA302-B	73.67	92	Approved	60	93	68
MAT00147	ALU0025	IA703-B	79.67	97	Approved	70	79	90
MAT00667	ALU0112	IA401-B	72.00	84	Approved	60	86	70
MAT01910	ALU0319	IA302-B	69.33	97	Approved	66	78	64
MAT03790	ALU0632	IA804-B	74.00	100	Approved	70	72	80
MAT05660	ALU0944	IA102-B	91.33	77	Approved	90	89	95
MAT05395	ALU0900	IA301-A	74.67	84	Approved	74	83	67
MAT02964	ALU0494	IA506-A	81.00	99	Approved	65	90	88
MAT02758	ALU0460	IA504-B	72.33	82	Approved	74	76	67
MAT00675	ALU0113	IA703-B	80.00	97	Approved	77	78	85
MAT03472	ALU0579	IA104-A	76.00	98	Approved	64	94	70
MAT01846	ALU0308	IA104-A	86.67	75	Approved	78	87	95
MAT03725	ALU0621	IA405-B	73.67	79	Approved	78	79	64
MAT02541	ALU0424	IA603-A	82.67	79	Approved	100	66	82
MAT05744	ALU0958	IA502-B	75.67	77	Approved	69	63	95
MAT00922	ALU0154	IA604-A	88.00	80	Approved	94	98	72
MAT04302	ALU0717	IA106-B	82.33	83	Approved	93	81	73
MAT00220	ALU0037	IA304-B	90.00	91	Approved	82	90	98
MAT01999	ALU0334	IA201-A	77.00	90	Approved	71	80	80
MAT01417	ALU0237	IA301-B	76.00	87	Approved	96	61	71
MAT01553	ALU0259	IA405-A	68.00	90	Approved	81	60	63
MAT02252	ALU0376	IA802-B	81.33	91	Approved	91	74	79
MAT02172	ALU0362	IA406-B	79.67	82	Approved	68	96	75
MAT00206	ALU0035	IA502-B	67.00	96	Approved	62	70	69
MAT05604	ALU0934	IA606-A	69.33	87	Approved	65	71	72
MAT00195	ALU0033	IA203-B	73.67	81	Approved	67	78	76
MAT02004	ALU0334	IA206-A	74.67	88	Approved	74	76	74
MAT02869	ALU0479	IA401-B	91.33	78	Approved	100	97	77
MAT01268	ALU0212	IA402-B	86.33	95	Approved	94	75	90
MAT01372	ALU0229	IA204-A	73.67	90	Approved	74	67	80
MAT03536	ALU0590	IA102-B	76.33	96	Approved	73	78	78
MAT00744	ALU0124	IA806-B	87.00	83	Approved	87	93	81
MAT02937	ALU0490	IA403-B	75.00	85	Approved	79	73	73
MAT02366	ALU0395	IA302-B	77.00	99	Approved	80	85	66
MAT02996	ALU0500	IA702-A	81.67	92	Approved	94	66	85
MAT01717	ALU0287	IA501-A	79.33	93	Approved	63	99	76
MAT05946	ALU0991	IA206-B	82.67	99	Approved	76	76	96
MAT02956	ALU0493	IA304-A	85.67	96	Approved	98	82	77
MAT04140	ALU0690	IA306-B	83.67	82	Approved	62	99	90
MAT01638	ALU0273	IA406-A	80.00	88	Approved	88	76	76
MAT01806	ALU0301	IA106-B	86.33	77	Approved	82	100	77
MAT00883	ALU0148	IA201-A	93.00	92	Approved	93	87	99
MAT02538	ALU0423	IA606-A	73.00	86	Approved	75	73	71
MAT02316	ALU0386	IA606-A	84.67	98	Approved	97	79	78
MAT04045	ALU0675	IA301-A	77.33	82	Approved	72	98	62
MAT05924	ALU0988	IA202-B	85.67	81	Approved	81	94	82
MAT00954	ALU0159	IA306-B	76.00	79	Approved	96	69	63
MAT01151	ALU0192	IA405-B	88.00	90	Approved	91	82	91
MAT02037	ALU0340	IA103-B	72.00	84	Approved	84	66	66
MAT02826	ALU0471	IA306-B	73.00	76	Approved	78	76	65
MAT00425	ALU0071	IA405-B	72.33	85	Approved	71	72	74
MAT05755	ALU0960	IA801-A	84.33	79	Approved	88	89	76
MAT00528	ALU0088	IA806-B	80.00	95	Approved	81	65	94
MAT04799	ALU0800	IA605-B	78.00	87	Approved	60	76	98
MAT02548	ALU0425	IA804-B	73.67	91	Approved	62	83	76
MAT05626	ALU0938	IA304-B	79.33	85	Approved	84	78	76
MAT05354	ALU0893	IA802-B	80.00	89	Approved	85	83	72
MAT01711	ALU0286	IA201-A	88.00	83	Approved	91	79	94
MAT03727	ALU0622	IA101-B	70.33	77	Approved	79	61	71
MAT00274	ALU0046	IA504-B	89.67	79	Approved	94	83	92
MAT00205	ALU0035	IA501-B	76.00	99	Approved	85	81	62
MAT01527	ALU0255	IA503-A	88.33	84	Approved	87	78	100
MAT00740	ALU0124	IA802-B	91.00	97	Approved	85	95	93
MAT05009	ALU0835	IA305-B	77.67	92	Approved	71	75	87
MAT00604	ALU0101	IA204-A	78.33	92	Approved	66	69	100
MAT03466	ALU0578	IA204-A	87.67	98	Approved	97	96	70
MAT02569	ALU0429	IA401-A	84.33	84	Approved	77	98	78
MAT00909	ALU0152	IA403-A	79.33	93	Approved	69	71	98
MAT00798	ALU0133	IA706-B	76.67	84	Approved	91	73	66
MAT00946	ALU0158	IA104-B	82.00	92	Approved	89	65	92
MAT03205	ALU0535	IA101-B	72.00	80	Approved	70	67	79
MAT00512	ALU0086	IA802-A	87.00	78	Approved	77	88	96
MAT01277	ALU0213	IA205-B	95.00	80	Approved	95	99	91
MAT01319	ALU0220	IA605-B	88.33	87	Approved	97	74	94
MAT01228	ALU0205	IA604-A	70.00	86	Approved	77	63	70
MAT02129	ALU0355	IA505-B	91.00	92	Approved	87	98	88
MAT02044	ALU0341	IA404-B	77.33	91	Approved	82	82	68
MAT01364	ALU0228	IA402-B	87.00	78	Approved	97	64	100
MAT02938	ALU0490	IA404-B	80.00	85	Approved	72	98	70
MAT00724	ALU0121	IA504-B	74.67	95	Approved	64	79	81
MAT00325	ALU0055	IA201-A	80.00	88	Approved	90	75	75
MAT01260	ALU0210	IA206-B	72.33	82	Approved	69	84	64
MAT03990	ALU0665	IA606-B	86.33	79	Approved	94	83	82
MAT01221	ALU0204	IA803-B	79.67	76	Approved	87	71	81
MAT00792	ALU0132	IA606-B	73.33	83	Approved	62	78	80
MAT05826	ALU0971	IA606-B	81.67	88	Approved	86	86	73
MAT02394	ALU0399	IA806-B	78.67	76	Approved	96	71	69
MAT03711	ALU0619	IA203-B	92.67	75	Approved	95	86	97
MAT05613	ALU0936	IA303-B	77.00	85	Approved	61	89	81
MAT00843	ALU0141	IA803-B	88.00	76	Approved	76	100	88
MAT05533	ALU0923	IA501-A	83.33	80	Approved	87	65	98
MAT03203	ALU0534	IA605-B	87.00	89	Approved	85	100	76
MAT02520	ALU0420	IA606-A	64.00	76	Approved	68	63	61
MAT04228	ALU0705	IA204-A	77.67	92	Approved	75	73	85
MAT03523	ALU0588	IA401-A	75.00	95	Approved	78	73	74
MAT04418	ALU0737	IA702-B	83.67	91	Approved	87	100	64
MAT03034	ALU0506	IA604-B	75.67	82	Approved	65	71	91
MAT01550	ALU0259	IA402-A	84.00	94	Approved	91	97	64
MAT00238	ALU0040	IA304-A	87.33	98	Approved	82	84	96
MAT05099	ALU0850	IA105-B	75.00	97	Approved	74	85	66
MAT03460	ALU0577	IA804-A	81.33	98	Approved	69	94	81
MAT03106	ALU0518	IA104-B	84.00	92	Approved	64	96	92
MAT05523	ALU0921	IA703-A	70.67	78	Approved	65	78	69
MAT02603	ALU0434	IA705-A	75.67	92	Approved	98	66	63
MAT05520	ALU0920	IA806-A	77.33	75	Approved	93	66	73
MAT02943	ALU0491	IA203-B	82.67	77	Approved	86	69	93
MAT05560	ALU0927	IA604-B	68.67	77	Approved	69	63	74
MAT01471	ALU0246	IA801-A	71.00	82	Approved	62	63	88
MAT03732	ALU0622	IA106-B	68.67	90	Approved	68	63	75
MAT01190	ALU0199	IA302-A	84.67	90	Approved	95	60	99
MAT01549	ALU0259	IA401-A	85.00	83	Approved	89	87	79
MAT01259	ALU0210	IA205-B	77.67	93	Approved	80	69	84
MAT04844	ALU0808	IA302-B	79.00	98	Approved	85	65	87
MAT01312	ALU0219	IA104-A	83.67	97	Approved	78	74	99
MAT00796	ALU0133	IA704-B	79.67	93	Approved	81	87	71
MAT03073	ALU0513	IA201-A	80.00	82	Approved	98	72	70
MAT03258	ALU0543	IA206-A	83.33	96	Approved	73	98	79
MAT02962	ALU0494	IA504-A	81.00	90	Approved	81	82	80
MAT05801	ALU0967	IA405-B	74.67	78	Approved	72	67	85
MAT01169	ALU0195	IA305-B	74.67	96	Approved	88	67	69
MAT02721	ALU0454	IA603-B	76.67	76	Approved	60	74	96
MAT01964	ALU0328	IA202-B	79.67	77	Approved	70	83	86
MAT00725	ALU0121	IA505-B	88.33	93	Approved	82	100	83
MAT02599	ALU0434	IA701-A	79.67	87	Approved	79	72	88
MAT05807	ALU0968	IA505-B	74.00	97	Approved	93	65	64
MAT00062	ALU0011	IA102-A	89.67	75	Approved	75	94	100
MAT02476	ALU0413	IA204-B	79.33	97	Approved	97	78	63
MAT01700	ALU0284	IA602-A	77.67	88	Approved	97	68	68
MAT01281	ALU0214	IA503-A	73.33	94	Approved	93	61	66
MAT02959	ALU0494	IA501-A	83.00	95	Approved	64	86	99
MAT01561	ALU0261	IA101-A	75.00	91	Approved	67	62	96
MAT02039	ALU0340	IA105-B	84.00	100	Approved	100	60	92
MAT03350	ALU0559	IA402-A	83.67	79	Approved	91	67	93
MAT05809	ALU0969	IA201-B	72.00	75	Approved	64	85	67
MAT04886	ALU0815	IA202-A	69.67	75	Approved	63	64	82
MAT04406	ALU0735	IA402-A	87.67	75	Approved	99	92	72
MAT04652	ALU0776	IA402-B	77.33	83	Approved	65	85	82
MAT02471	ALU0412	IA605-B	74.67	86	Approved	72	91	61
MAT03625	ALU0605	IA301-A	77.33	84	Approved	92	60	80
MAT01610	ALU0269	IA602-B	73.00	84	Approved	82	63	74
MAT01183	ALU0198	IA401-A	77.33	79	Approved	62	95	75
MAT00694	ALU0116	IA704-A	74.00	85	Approved	100	62	60
MAT00217	ALU0037	IA301-B	83.67	77	Approved	90	81	80
MAT05231	ALU0872	IA205-A	81.33	100	Approved	74	72	98
MAT01240	ALU0207	IA304-A	91.00	85	Approved	91	95	87
MAT01581	ALU0264	IA103-B	66.33	75	Approved	75	61	63
MAT02138	ALU0357	IA802-A	75.67	98	Approved	81	66	80
MAT04874	ALU0813	IA502-A	78.33	96	Approved	61	86	88
MAT02487	ALU0415	IA803-B	84.67	91	Approved	67	93	94
MAT01303	ALU0218	IA401-B	73.00	84	Approved	75	64	80
MAT04288	ALU0715	IA304-B	75.67	86	Approved	60	99	68
MAT05999	ALU1000	IA105-A	65.33	84	Approved	63	69	64
MAT03217	ALU0537	IA401-B	83.33	98	Approved	70	80	100
MAT05943	ALU0991	IA203-B	71.00	77	Approved	69	70	74
MAT05322	ALU0887	IA606-B	76.00	83	Approved	62	85	81
MAT02850	ALU0475	IA806-B	93.67	93	Approved	92	96	93
MAT01187	ALU0198	IA405-A	72.67	75	Approved	70	63	85
MAT01117	ALU0187	IA101-B	93.00	92	Approved	98	86	95
MAT00743	ALU0124	IA805-B	85.33	83	Approved	93	83	80
MAT03922	ALU0654	IA404-B	78.67	76	Approved	78	96	62
MAT05511	ALU0919	IA103-A	71.33	77	Approved	64	83	67
MAT05194	ALU0866	IA304-B	88.67	82	Approved	89	98	79
MAT00713	ALU0119	IA405-B	77.67	78	Approved	80	91	62
MAT05167	ALU0862	IA501-B	82.00	93	Approved	69	91	86
MAT00700	ALU0117	IA504-A	88.33	81	Approved	100	94	71
MAT00422	ALU0071	IA402-B	81.33	79	Approved	90	72	82
MAT04964	ALU0828	IA802-B	73.67	84	Approved	66	93	62
MAT03819	ALU0637	IA603-B	81.00	83	Approved	95	88	60
MAT04796	ALU0800	IA602-B	78.67	95	Approved	100	72	64
MAT02747	ALU0458	IA205-B	74.00	96	Approved	60	64	98
MAT03651	ALU0609	IA303-A	78.00	82	Approved	94	71	69
MAT02489	ALU0415	IA805-B	73.67	99	Approved	83	62	76
MAT02154	ALU0359	IA406-B	70.67	80	Approved	75	72	65
MAT04986	ALU0831	IA506-B	87.33	75	Approved	98	95	69
MAT05070	ALU0845	IA506-B	80.67	81	Approved	84	61	97
MAT01083	ALU0181	IA703-B	78.67	79	Approved	65	72	99
MAT05951	ALU0992	IA305-A	68.33	89	Approved	61	65	79
MAT00407	ALU0068	IA105-A	70.33	92	Approved	62	69	80
MAT05507	ALU0918	IA805-A	80.00	95	Approved	94	81	65
MAT02116	ALU0353	IA304-B	85.00	89	Approved	80	97	78
MAT00947	ALU0158	IA105-B	78.00	79	Approved	98	68	68
MAT05258	ALU0877	IA102-B	95.33	82	Approved	98	91	97
MAT01724	ALU0288	IA202-B	92.00	92	Approved	92	90	94
MAT04386	ALU0731	IA806-B	82.33	96	Approved	89	72	86
MAT03406	ALU0568	IA704-A	78.33	78	Approved	73	72	90
MAT05829	ALU0972	IA303-A	82.00	82	Approved	71	81	94
MAT03084	ALU0514	IA206-B	77.00	87	Approved	76	73	82
MAT00287	ALU0048	IA805-A	78.00	82	Approved	100	60	74
MAT03190	ALU0532	IA204-A	81.33	93	Approved	91	89	64
MAT01940	ALU0324	IA602-B	68.00	93	Approved	60	74	70
MAT04130	ALU0689	IA602-A	70.33	80	Approved	76	63	72
MAT01974	ALU0329	IA106-B	86.33	99	Approved	76	89	94
MAT00125	ALU0021	IA105-B	81.67	86	Approved	95	62	88
MAT00939	ALU0157	IA203-A	78.00	98	Approved	73	62	99
MAT01064	ALU0178	IA602-B	75.00	79	Approved	66	65	94
MAT02887	ALU0482	IA801-B	84.67	78	Approved	89	73	92
MAT04432	ALU0739	IA104-A	84.67	81	Approved	75	94	85
MAT02107	ALU0352	IA201-A	88.67	98	Approved	69	100	97
MAT01950	ALU0325	IA606-B	74.33	98	Approved	70	64	89
MAT05802	ALU0967	IA406-B	65.00	75	Approved	62	68	65
MAT01215	ALU0203	IA103-A	87.00	83	Approved	97	70	94
MAT01805	ALU0301	IA105-B	76.33	77	Approved	84	65	80
MAT00680	ALU0114	IA802-B	81.33	91	Approved	91	87	66
MAT00625	ALU0105	IA801-B	89.00	79	Approved	71	96	100
MAT00793	ALU0133	IA701-B	89.00	80	Approved	75	95	97
MAT01807	ALU0302	IA801-B	78.33	87	Approved	100	64	71
MAT02951	ALU0492	IA705-B	88.67	91	Approved	99	68	99
MAT01231	ALU0206	IA501-A	92.33	92	Approved	96	85	96
MAT03518	ALU0587	IA802-A	44.00	59	Failed	48	43	41
MAT02819	ALU0470	IA205-B	15.33	54	Failed	19	27	0
MAT02536	ALU0423	IA604-A	46.33	62	Failed	46	36	57
MAT03427	ALU0572	IA201-A	30.67	66	Failed	8	49	35
MAT02757	ALU0460	IA503-B	41.33	73	Failed	43	25	56
MAT01161	ALU0194	IA503-A	8.67	42	Failed	0	18	8
MAT01309	ALU0219	IA101-A	36.00	99	Failed	13	41	54
MAT02273	ALU0379	IA705-A	22.33	72	Failed	21	2	44
MAT01579	ALU0264	IA101-B	43.67	46	Failed	48	58	25
MAT01302	ALU0217	IA506-B	28.67	40	Failed	30	12	44
MAT00800	ALU0134	IA502-A	12.33	77	Failed	4	16	17
MAT05404	ALU0901	IA204-A	83.67	100	Approved	75	94	82
MAT01572	ALU0262	IA406-B	37.00	53	Failed	54	46	11
MAT05369	ALU0895	IA505-A	27.00	55	Failed	39	35	7
MAT03616	ALU0603	IA804-A	20.00	75	Failed	27	21	12
MAT02794	ALU0466	IA604-B	3.67	71	Failed	10	0	1
MAT04474	ALU0746	IA104-B	47.67	47	Failed	54	54	35
MAT02708	ALU0452	IA402-B	24.00	93	Failed	27	8	37
MAT01904	ALU0318	IA402-A	28.33	73	Failed	46	39	0
MAT01569	ALU0262	IA403-B	34.33	56	Failed	33	45	25
MAT04144	ALU0691	IA504-B	48.33	77	Failed	56	47	42
MAT04438	ALU0740	IA804-B	43.00	36	Failed	23	57	49
MAT00650	ALU0109	IA202-A	36.00	40	Failed	40	37	31
MAT02305	ALU0385	IA501-B	41.00	80	Failed	54	17	52
MAT02205	ALU0368	IA403-B	21.33	43	Failed	40	21	3
MAT05389	ALU0899	IA701-B	29.67	76	Failed	20	36	33
MAT02038	ALU0340	IA104-B	19.33	66	Failed	49	3	6
MAT05663	ALU0944	IA105-B	27.00	68	Failed	19	29	33
MAT00247	ALU0042	IA501-B	28.67	81	Failed	29	9	48
MAT05059	ALU0844	IA201-A	43.33	33	Failed	57	29	44
MAT05810	ALU0969	IA202-B	10.67	45	Failed	12	5	15
MAT03709	ALU0619	IA201-B	24.33	79	Failed	0	28	45
MAT04649	ALU0775	IA805-B	33.00	41	Failed	16	26	57
MAT00612	ALU0102	IA506-A	20.00	89	Failed	4	7	49
MAT04873	ALU0813	IA501-A	42.00	97	Failed	27	57	42
MAT05076	ALU0846	IA206-A	26.33	93	Failed	18	24	37
MAT01474	ALU0246	IA804-A	24.33	72	Failed	1	47	25
MAT00827	ALU0138	IA205-A	48.00	83	Failed	51	41	52
MAT05566	ALU0928	IA804-B	27.00	42	Failed	7	26	48
MAT00837	ALU0140	IA203-A	28.33	78	Failed	19	28	38
MAT00179	ALU0030	IA705-B	33.00	38	Failed	4	50	45
MAT01153	ALU0193	IA501-A	39.33	79	Failed	43	37	38
MAT02436	ALU0406	IA406-B	32.33	50	Failed	17	22	58
MAT01601	ALU0267	IA605-A	26.33	49	Failed	57	0	22
MAT04037	ALU0673	IA405-B	32.67	93	Failed	36	7	55
MAT03451	ALU0576	IA501-A	9.33	55	Failed	19	0	9
MAT01480	ALU0247	IA204-B	19.67	61	Failed	21	38	0
MAT02329	ALU0389	IA701-B	18.33	91	Failed	34	21	0
MAT02667	ALU0445	IA803-B	19.00	91	Failed	35	14	8
MAT02430	ALU0405	IA806-A	21.00	61	Failed	25	15	23
MAT05561	ALU0927	IA605-B	14.33	55	Failed	12	18	13
MAT00289	ALU0049	IA501-B	17.33	88	Failed	17	34	1
MAT03446	ALU0575	IA402-A	29.33	47	Failed	14	54	20
MAT01983	ALU0331	IA403-A	33.67	68	Failed	28	16	57
MAT02429	ALU0405	IA805-A	51.33	40	Failed	55	50	49
MAT00457	ALU0077	IA401-A	11.33	100	Failed	18	5	11
MAT01057	ALU0177	IA701-B	34.00	91	Failed	24	47	31
MAT03102	ALU0517	IA606-B	27.67	89	Failed	33	28	22
MAT02528	ALU0422	IA402-B	40.00	41	Failed	37	26	57
MAT00290	ALU0049	IA502-B	26.33	49	Failed	2	51	26
MAT03648	ALU0608	IA506-B	26.00	65	Failed	49	18	11
MAT03999	ALU0667	IA603-A	35.33	77	Failed	24	50	32
MAT02814	ALU0469	IA606-B	21.33	100	Failed	31	25	8
MAT04861	ALU0811	IA401-B	38.00	37	Failed	41	44	29
MAT04976	ALU0830	IA202-B	35.00	56	Failed	0	47	58
MAT01769	ALU0295	IA405-B	31.33	65	Failed	39	54	1
MAT01462	ALU0244	IA304-B	25.67	49	Failed	3	35	39
MAT02855	ALU0476	IA405-B	28.67	57	Failed	25	15	46
MAT04963	ALU0828	IA801-B	29.00	49	Failed	59	4	24
MAT02953	ALU0493	IA301-A	20.00	55	Failed	27	3	30
MAT01224	ALU0204	IA806-B	25.00	57	Failed	39	35	1
MAT00671	ALU0112	IA405-B	15.33	92	Failed	17	12	17
MAT05148	ALU0858	IA206-B	19.33	80	Failed	12	12	34
MAT00646	ALU0108	IA404-A	34.33	75	Failed	53	40	10
MAT05791	ALU0966	IA601-B	33.67	33	Failed	58	38	5
MAT01588	ALU0265	IA304-B	33.00	30	Failed	33	55	11
MAT03426	ALU0571	IA806-A	15.33	39	Failed	29	9	8
MAT05192	ALU0866	IA302-B	75.00	95	Approved	68	97	60
MAT04817	ALU0803	IA805-B	56.00	39	Failed	54	57	57
MAT05320	ALU0887	IA604-B	53.33	82	Failed	58	57	45
MAT01059	ALU0177	IA703-B	23.33	73	Failed	14	36	20
MAT01626	ALU0271	IA106-B	33.00	51	Failed	39	5	55
MAT02566	ALU0428	IA204-A	17.67	57	Failed	26	23	4
MAT01912	ALU0319	IA304-B	50.33	44	Failed	44	55	52
MAT01046	ALU0175	IA302-B	13.00	59	Failed	21	12	6
MAT00409	ALU0069	IA101-A	42.33	65	Failed	54	35	38
MAT05542	ALU0924	IA604-B	36.67	42	Failed	16	58	36
MAT01977	ALU0330	IA603-B	22.67	34	Failed	34	28	6
MAT03512	ALU0586	IA202-B	21.00	91	Failed	5	21	37
MAT02251	ALU0376	IA801-B	20.00	42	Failed	19	15	26
MAT00634	ALU0106	IA504-B	27.67	49	Failed	26	55	2
MAT02676	ALU0446	IA206-B	26.00	52	Failed	31	41	6
MAT00467	ALU0078	IA105-A	38.00	39	Failed	44	38	32
MAT02426	ALU0405	IA802-A	43.00	37	Failed	43	29	57
MAT00656	ALU0110	IA202-B	25.00	54	Failed	37	15	23
MAT05181	ALU0864	IA103-A	16.67	89	Failed	16	31	3
MAT00940	ALU0157	IA204-A	20.67	85	Failed	31	27	4
MAT03986	ALU0665	IA602-B	32.67	44	Failed	14	30	54
MAT02597	ALU0433	IA805-A	43.33	39	Failed	49	47	34
MAT02444	ALU0408	IA602-B	34.00	31	Failed	52	47	3
MAT02880	ALU0480	IA306-A	24.67	32	Failed	29	6	39
MAT02226	ALU0371	IA706-B	22.33	42	Failed	1	29	37
MAT02462	ALU0411	IA402-B	41.67	81	Failed	35	50	40
MAT04146	ALU0691	IA506-B	20.00	39	Failed	25	18	17
MAT03988	ALU0665	IA604-B	18.67	63	Failed	48	4	4
MAT05272	ALU0879	IA304-B	28.33	57	Failed	33	16	36
MAT02342	ALU0391	IA702-A	10.67	94	Failed	16	15	1
MAT01754	ALU0293	IA802-B	27.67	55	Failed	49	20	14
MAT01854	ALU0309	IA106-B	36.00	80	Failed	22	42	44
MAT00595	ALU0100	IA401-B	31.67	45	Failed	28	53	14
MAT02162	ALU0361	IA202-B	40.33	69	Failed	57	34	30
MAT04951	ALU0826	IA601-B	25.00	68	Failed	47	18	10
MAT00005	ALU0001	IA205-B	23.00	69	Failed	13	42	14
MAT05502	ALU0917	IA206-B	31.67	86	Failed	45	42	8
MAT00239	ALU0040	IA305-A	35.33	42	Failed	31	44	31
MAT03468	ALU0578	IA206-A	31.67	34	Failed	28	31	36
MAT05105	ALU0851	IA305-A	34.33	94	Failed	55	39	9
MAT05394	ALU0899	IA706-B	29.67	86	Failed	0	44	45
MAT02530	ALU0422	IA404-B	33.67	75	Failed	49	12	40
MAT05950	ALU0992	IA304-A	26.33	57	Failed	1	55	23
MAT01731	ALU0289	IA403-B	46.33	58	Failed	58	22	59
MAT05058	ALU0843	IA706-B	51.67	97	Failed	58	44	53
MAT02760	ALU0460	IA506-B	50.33	44	Failed	57	49	45
MAT05418	ALU0903	IA306-B	12.67	38	Failed	12	15	11
MAT02567	ALU0428	IA205-A	20.67	95	Failed	14	23	25
MAT01317	ALU0220	IA603-B	47.33	94	Failed	54	35	53
MAT00699	ALU0117	IA503-A	20.33	48	Failed	21	25	15
MAT01918	ALU0320	IA704-B	38.33	51	Failed	44	43	28
MAT04000	ALU0667	IA604-A	30.00	96	Failed	44	12	34
MAT01307	ALU0218	IA405-B	24.67	73	Failed	44	7	23
MAT00823	ALU0138	IA201-A	14.00	32	Failed	5	21	16
MAT00482	ALU0081	IA402-B	31.00	97	Failed	20	39	34
MAT00747	ALU0125	IA303-B	43.33	67	Failed	45	55	30
MAT02218	ALU0370	IA604-B	27.00	61	Failed	43	3	35
MAT01304	ALU0218	IA402-B	37.00	38	Failed	47	39	25
MAT01357	ALU0227	IA501-B	28.33	79	Failed	23	24	38
MAT01376	ALU0230	IA802-B	14.67	46	Failed	4	38	2
MAT00727	ALU0122	IA501-B	14.33	81	Failed	8	20	15
MAT01271	ALU0212	IA405-B	48.33	78	Failed	44	47	54
MAT03257	ALU0543	IA205-A	13.33	86	Failed	25	7	8
MAT00503	ALU0084	IA205-B	73.00	77	Approved	88	68	63
MAT00025	ALU0005	IA401-B	22.33	87	Failed	45	3	19
MAT02323	ALU0388	IA801-B	21.33	76	Failed	23	27	14
MAT03541	ALU0591	IA601-B	36.00	36	Failed	45	33	30
MAT01913	ALU0319	IA305-B	37.67	92	Failed	28	37	48
MAT01968	ALU0328	IA206-B	27.67	68	Failed	46	7	30
MAT00183	ALU0031	IA603-B	33.33	87	Failed	8	33	59
MAT05316	ALU0886	IA706-B	30.33	71	Failed	25	29	37
MAT00677	ALU0113	IA705-B	22.67	100	Failed	12	41	15
MAT05419	ALU0904	IA501-B	45.33	53	Failed	40	42	54
MAT01056	ALU0176	IA206-B	29.33	67	Failed	13	22	53
MAT04526	ALU0755	IA602-B	18.67	80	Failed	24	7	25
MAT02540	ALU0424	IA602-A	28.67	71	Failed	17	43	26
MAT05054	ALU0843	IA702-B	39.67	91	Failed	37	29	53
MAT02283	ALU0381	IA703-B	37.33	55	Failed	47	37	28
MAT02677	ALU0447	IA101-B	41.33	70	Failed	19	52	53
MAT02295	ALU0383	IA503-A	16.67	53	Failed	15	3	32
MAT03430	ALU0572	IA204-A	30.00	44	Failed	55	26	9
MAT02645	ALU0441	IA605-B	18.33	81	Failed	1	5	49
MAT01882	ALU0314	IA104-B	24.33	75	Failed	44	26	3
MAT01092	ALU0182	IA806-A	45.33	49	Failed	48	41	47
MAT05382	ALU0897	IA506-B	44.00	31	Failed	59	26	47
MAT02749	ALU0459	IA701-A	32.67	77	Failed	38	7	53
MAT02767	ALU0462	IA601-A	39.67	51	Failed	6	57	56
MAT01908	ALU0318	IA406-A	24.00	38	Failed	2	38	32
MAT00536	ALU0090	IA102-B	45.00	88	Failed	57	26	52
MAT01829	ALU0305	IA305-B	32.67	30	Failed	29	38	31
MAT02978	ALU0497	IA602-B	12.67	60	Failed	16	6	16
MAT02056	ALU0343	IA404-A	40.00	97	Failed	39	54	27
MAT03018	ALU0503	IA706-B	24.33	98	Failed	9	35	29
MAT02896	ALU0483	IA504-B	31.67	69	Failed	38	52	5
MAT00881	ALU0147	IA205-B	28.67	32	Failed	12	42	32
MAT05109	ALU0852	IA703-A	31.00	33	Failed	30	22	41
MAT03707	ALU0618	IA205-B	45.33	84	Failed	46	50	40
MAT02221	ALU0371	IA701-B	35.33	93	Failed	34	59	13
MAT00711	ALU0119	IA403-B	29.67	78	Failed	47	42	0
MAT01843	ALU0308	IA101-A	36.00	45	Failed	9	43	56
MAT01401	ALU0234	IA203-A	25.67	80	Failed	42	4	31
MAT00561	ALU0094	IA603-A	35.33	63	Failed	35	39	32
MAT05923	ALU0988	IA201-B	17.67	55	Failed	29	19	5
MAT05001	ALU0834	IA103-B	35.00	50	Failed	45	56	4
MAT05032	ALU0839	IA204-B	43.33	99	Failed	49	56	25
MAT05152	ALU0859	IA204-B	32.33	63	Failed	20	59	18
MAT00659	ALU0110	IA205-B	34.67	40	Failed	53	22	29
MAT00850	ALU0142	IA604-B	22.33	74	Failed	19	46	2
MAT02093	ALU0349	IA805-B	16.00	92	Failed	6	1	41
MAT02485	ALU0415	IA801-B	35.33	99	Failed	21	52	33
MAT01101	ALU0184	IA303-A	32.33	79	Failed	45	9	43
MAT02845	ALU0475	IA801-B	13.67	82	Failed	4	4	33
MAT02059	ALU0344	IA401-B	35.33	49	Failed	19	37	50
MAT01155	ALU0193	IA503-A	45.00	57	Failed	59	45	31
MAT02881	ALU0481	IA201-B	22.33	49	Failed	10	55	2
MAT04308	ALU0718	IA706-A	37.33	77	Failed	21	40	51
MAT05734	ALU0956	IA404-A	37.67	61	Failed	42	30	41
MAT00539	ALU0090	IA105-B	34.00	46	Failed	44	46	12
MAT03062	ALU0511	IA602-B	39.00	65	Failed	44	14	59
MAT01350	ALU0225	IA306-A	7.67	56	Failed	17	6	0
MAT01116	ALU0186	IA206-B	43.00	70	Failed	41	53	35
MAT04142	ALU0691	IA502-B	20.00	58	Failed	21	22	17
MAT04950	ALU0825	IA506-B	14.00	55	Failed	1	16	25
MAT05699	ALU0950	IA205-A	24.67	58	Failed	24	35	15
MAT02490	ALU0415	IA806-B	40.00	98	Failed	54	52	14
MAT05254	ALU0876	IA804-B	23.00	72	Failed	18	6	45
MAT01825	ALU0305	IA301-B	32.33	72	Failed	18	21	58
MAT02939	ALU0490	IA405-B	33.33	44	Failed	45	2	53
MAT02157	ALU0360	IA203-A	25.00	59	Failed	13	7	55
MAT00532	ALU0089	IA204-A	49.67	96	Failed	58	38	53
MAT03670	ALU0612	IA304-B	29.00	51	Failed	19	50	18
MAT01143	ALU0191	IA603-A	21.00	42	Failed	8	7	48
MAT04198	ALU0700	IA504-B	39.67	79	Failed	35	54	30
MAT01746	ALU0291	IA106-B	28.67	36	Failed	38	34	14
MAT01440	ALU0240	IA206-B	17.00	41	Failed	33	3	15
MAT03617	ALU0603	IA805-A	37.67	75	Failed	14	43	56
MAT02395	ALU0400	IA401-B	14.33	95	Failed	21	19	3
MAT02064	ALU0344	IA406-B	43.00	90	Failed	22	50	57
MAT05202	ALU0867	IA806-B	44.00	59	Failed	49	37	46
MAT04127	ALU0688	IA305-B	53.33	97	Failed	49	54	57
MAT00878	ALU0147	IA202-B	25.67	81	Failed	42	0	35
MAT01933	ALU0323	IA401-A	25.33	66	Failed	56	17	3
MAT01248	ALU0208	IA106-A	39.33	100	Failed	56	12	50
MAT02830	ALU0472	IA704-B	32.33	84	Failed	34	12	51
MAT03210	ALU0535	IA106-B	37.33	93	Failed	36	47	29
MAT05715	ALU0953	IA403-B	16.33	42	Failed	15	34	0
MAT03606	ALU0601	IA606-B	17.00	78	Failed	15	31	5
MAT05685	ALU0948	IA203-B	35.00	86	Failed	52	46	7
MAT00208	ALU0035	IA504-B	29.00	64	Failed	8	26	53
MAT04709	ALU0785	IA305-A	43.33	35	Failed	36	53	41
MAT04930	ALU0822	IA404-B	33.67	54	Failed	49	28	24
MAT00259	ALU0044	IA301-A	42.67	37	Failed	53	36	39
MAT04222	ALU0704	IA404-B	17.00	70	Failed	8	8	35
MAT01804	ALU0301	IA104-B	38.33	94	Failed	56	40	19
MAT04757	ALU0793	IA805-B	23.67	67	Failed	14	1	56
MAT05416	ALU0903	IA304-B	12.00	56	Failed	4	4	28
MAT00686	ALU0115	IA302-A	31.00	90	Failed	13	57	23
MAT03471	ALU0579	IA103-A	27.33	97	Failed	35	22	25
MAT03371	ALU0562	IA405-B	28.33	31	Failed	31	31	23
MAT03090	ALU0515	IA206-B	16.67	88	Failed	38	2	10
MAT00976	ALU0163	IA604-B	38.67	72	Failed	47	50	19
MAT05510	ALU0919	IA102-A	26.00	96	Failed	30	19	29
MAT01826	ALU0305	IA302-B	27.67	74	Failed	34	45	4
MAT00788	ALU0132	IA602-B	34.00	88	Failed	37	36	29
MAT00653	ALU0109	IA205-A	35.33	77	Failed	33	57	16
MAT02969	ALU0495	IA405-A	26.67	84	Failed	41	29	10
MAT02024	ALU0338	IA102-B	28.00	36	Failed	29	35	20
MAT02289	ALU0382	IA203-A	24.67	85	Failed	18	31	25
MAT00707	ALU0118	IA805-B	16.67	70	Failed	4	14	32
MAT02766	ALU0461	IA106-B	33.33	90	Failed	47	0	53
MAT03977	ALU0663	IA805-B	23.00	35	Failed	45	10	14
MAT05500	ALU0917	IA204-B	18.00	45	Failed	5	10	39
MAT05524	ALU0921	IA704-A	27.67	49	Failed	21	45	17
MAT02945	ALU0491	IA205-B	18.33	53	Failed	21	10	24
MAT05011	ALU0836	IA601-B	46.67	95	Failed	45	37	58
MAT05174	ALU0863	IA602-B	43.67	85	Failed	34	51	46
MAT00729	ALU0122	IA503-B	32.33	97	Failed	49	32	16
MAT02663	ALU0444	IA805-B	22.00	81	Failed	4	56	6
MAT02291	ALU0382	IA205-A	34.67	39	Failed	21	58	25
MAT01787	ALU0298	IA805-B	37.00	49	Failed	8	54	49
MAT00506	ALU0085	IA302-B	22.67	58	Failed	15	41	12
MAT05402	ALU0901	IA202-A	6.00	40	Failed	11	4	3
MAT02920	ALU0487	IA804-B	27.67	33	Failed	20	49	14
MAT05609	ALU0935	IA505-A	36.67	64	Failed	19	49	42
MAT00647	ALU0108	IA405-A	38.00	74	Failed	48	27	39
MAT00285	ALU0048	IA803-A	47.33	36	Failed	25	59	58
MAT00143	ALU0024	IA205-B	32.00	65	Failed	31	53	12
MAT04840	ALU0807	IA604-B	38.67	41	Failed	51	56	9
MAT04299	ALU0717	IA103-B	48.33	68	Failed	58	47	40
MAT00216	ALU0036	IA206-A	52.33	37	Failed	42	58	57
MAT00824	ALU0138	IA202-A	31.33	75	Failed	50	9	35
MAT00424	ALU0071	IA404-B	44.00	57	Failed	41	55	36
MAT00421	ALU0071	IA401-B	51.67	98	Failed	51	58	46
MAT01545	ALU0258	IA103-B	19.33	58	Failed	12	37	9
MAT01666	ALU0278	IA504-B	20.00	52	Failed	49	1	10
MAT00801	ALU0134	IA503-A	29.00	55	Failed	23	21	43
MAT05168	ALU0862	IA502-B	24.33	58	Failed	54	10	9
MAT00665	ALU0111	IA805-A	12.00	74	Failed	10	1	25
MAT05497	ALU0917	IA201-B	25.00	59	Failed	36	17	22
MAT00658	ALU0110	IA204-B	27.33	82	Failed	45	10	27
MAT01495	ALU0250	IA301-B	41.00	50	Failed	32	50	41
MAT05541	ALU0924	IA603-B	38.67	52	Failed	41	58	17
MAT04965	ALU0828	IA803-B	50.33	56	Failed	54	45	52
MAT04955	ALU0826	IA605-B	33.67	64	Failed	28	31	42
MAT00609	ALU0102	IA503-A	36.00	76	Failed	57	31	20
MAT03054	ALU0509	IA806-B	33.33	45	Failed	29	23	48
MAT02498	ALU0417	IA502-B	45.67	66	Failed	54	58	25
MAT01941	ALU0324	IA603-B	37.67	30	Failed	14	41	58
MAT01605	ALU0268	IA203-B	8.67	78	Failed	4	2	20
MAT03179	ALU0530	IA805-B	34.33	36	Failed	28	53	22
MAT00785	ALU0131	IA805-A	36.00	63	Failed	35	33	40
MAT04309	ALU0719	IA801-A	44.67	56	Failed	50	57	27
MAT03987	ALU0665	IA603-B	41.00	77	Failed	53	39	31
MAT03456	ALU0576	IA506-A	43.67	78	Failed	38	42	51
MAT04028	ALU0672	IA802-B	19.00	89	Failed	2	37	18
MAT01021	ALU0171	IA101-A	36.33	62	Failed	59	40	10
MAT04021	ALU0671	IA801-A	29.00	32	Failed	32	34	21
MAT01926	ALU0321	IA206-B	44.00	92	Failed	48	46	38
MAT05084	ALU0848	IA102-A	32.00	71	Failed	39	55	2
MAT00607	ALU0102	IA501-A	30.00	60	Failed	31	15	44
MAT05287	ALU0882	IA401-B	22.33	55	Failed	18	7	42
MAT00712	ALU0119	IA404-B	11.00	63	Failed	11	13	9
MAT05945	ALU0991	IA205-B	26.00	37	Failed	31	4	43
MAT02410	ALU0402	IA304-A	24.00	53	Failed	14	50	8
MAT02572	ALU0429	IA404-A	23.33	72	Failed	9	46	15
MAT03254	ALU0543	IA202-A	27.00	61	Failed	14	52	15
MAT02842	ALU0474	IA204-B	27.00	69	Failed	39	39	3
MAT01772	ALU0296	IA802-A	47.67	43	Failed	52	35	56
MAT01909	ALU0319	IA301-B	35.67	72	Failed	19	59	29
MAT00242	ALU0041	IA302-A	12.67	91	Failed	16	9	13
MAT02507	ALU0418	IA605-B	33.67	90	Failed	56	0	45
MAT02494	ALU0416	IA804-B	33.33	43	Failed	41	31	28
MAT00684	ALU0114	IA806-B	38.00	33	Failed	39	16	59
MAT02804	ALU0468	IA202-B	36.67	32	Failed	43	21	46
MAT00960	ALU0160	IA506-A	27.00	52	Failed	4	26	51
MAT01815	ALU0303	IA503-B	25.00	86	Failed	20	33	22
MAT02259	ALU0377	IA103-A	23.67	57	Failed	30	18	23
MAT01976	ALU0330	IA602-B	23.00	83	Failed	15	25	29
MAT03479	ALU0580	IA305-A	21.00	75	Failed	34	14	15
MAT05653	ALU0943	IA501-A	38.00	98	Failed	49	33	32
MAT04672	ALU0779	IA804-A	29.00	79	Failed	11	24	52
MAT01227	ALU0205	IA603-A	20.67	98	Failed	16	41	5
MAT03607	ALU0602	IA501-A	28.00	31	Failed	43	33	8
MAT04440	ALU0740	IA806-B	43.33	68	Failed	54	52	24
MAT03738	ALU0623	IA606-A	26.67	31	Failed	5	46	29
MAT01916	ALU0320	IA702-B	36.33	52	Failed	13	46	50
MAT04426	ALU0738	IA804-B	27.33	77	Failed	21	13	48
MAT01556	ALU0260	IA802-B	13.33	75	Failed	6	6	28
MAT02557	ALU0427	IA401-B	41.00	33	Failed	22	47	54
MAT02341	ALU0391	IA701-A	32.33	79	Failed	47	21	29
MAT01524	ALU0254	IA606-A	39.00	97	Failed	30	42	45
MAT03612	ALU0602	IA506-A	21.67	62	Failed	47	11	7
MAT04626	ALU0771	IA606-A	27.00	95	Failed	27	19	35
MAT01104	ALU0184	IA306-A	26.67	87	Failed	37	13	30
MAT04825	ALU0805	IA801-A	46.33	48	Failed	52	40	47
MAT02334	ALU0389	IA706-B	19.33	38	Failed	2	7	49
MAT02103	ALU0351	IA503-B	42.67	87	Failed	34	46	48
MAT05387	ALU0898	IA105-B	43.00	42	Failed	45	26	58
MAT00462	ALU0077	IA406-A	32.33	63	Failed	30	19	48
MAT01457	ALU0243	IA305-A	33.67	53	Failed	26	50	25
MAT01087	ALU0182	IA801-A	31.67	93	Failed	40	19	36
MAT05370	ALU0895	IA506-A	33.33	54	Failed	42	0	58
MAT02132	ALU0356	IA802-B	21.33	40	Failed	13	31	20
MAT05103	ALU0851	IA303-A	16.00	80	Failed	1	15	32
MAT01369	ALU0229	IA201-A	35.00	79	Failed	48	15	42
MAT01422	ALU0237	IA306-B	30.00	100	Failed	18	46	26
MAT00639	ALU0107	IA303-B	50.00	57	Failed	57	43	50
MAT00696	ALU0116	IA706-A	11.67	30	Failed	3	17	15
MAT02668	ALU0445	IA804-B	28.67	73	Failed	41	23	22
MAT03992	ALU0666	IA802-B	28.67	47	Failed	27	17	42
MAT03875	ALU0646	IA505-B	46.00	37	Failed	54	50	34
MAT00296	ALU0050	IA302-B	31.67	83	Failed	0	57	38
MAT05036	ALU0840	IA602-B	52.33	48	Failed	59	43	55
MAT03454	ALU0576	IA504-A	25.33	33	Failed	33	13	30
MAT01492	ALU0249	IA204-A	30.33	89	Failed	18	44	29
MAT00501	ALU0084	IA203-B	14.00	79	Failed	0	20	22
MAT04286	ALU0715	IA302-B	32.00	36	Failed	25	43	28
MAT00319	ALU0054	IA401-A	14.00	88	Failed	11	18	13
MAT03726	ALU0621	IA406-B	15.33	37	Failed	2	15	29
MAT03067	ALU0512	IA201-A	22.33	77	Failed	23	44	0
MAT02314	ALU0386	IA604-A	35.67	52	Failed	46	14	47
MAT01602	ALU0267	IA606-A	16.33	41	Failed	5	26	18
MAT01768	ALU0295	IA404-B	50.00	67	Failed	46	48	56
MAT00435	ALU0073	IA603-B	46.33	33	Failed	51	46	42
MAT03964	ALU0661	IA404-A	31.33	72	Failed	52	10	32
MAT04032	ALU0672	IA806-B	49.33	81	Failed	44	55	49
MAT05516	ALU0920	IA802-A	42.00	53	Failed	23	47	56
MAT05319	ALU0887	IA603-B	26.67	86	Failed	43	25	12
MAT04269	ALU0712	IA803-A	46.67	49	Failed	56	25	59
MAT05127	ALU0855	IA403-B	35.00	99	Failed	45	42	18
MAT02832	ALU0472	IA706-B	31.00	59	Failed	15	53	25
MAT02537	ALU0423	IA605-A	28.33	44	Failed	45	8	32
MAT00369	ALU0062	IA203-A	29.67	90	Failed	10	58	21
MAT03026	ALU0505	IA602-A	23.33	35	Failed	46	7	17
MAT04002	ALU0667	IA606-A	23.33	79	Failed	57	13	0
MAT00821	ALU0137	IA205-A	21.33	63	Failed	23	5	36
MAT00973	ALU0163	IA601-B	19.33	94	Failed	8	1	49
MAT02547	ALU0425	IA803-B	23.67	70	Failed	4	20	47
MAT00263	ALU0044	IA305-A	29.67	72	Failed	53	23	13
MAT03806	ALU0635	IA402-B	11.33	44	Failed	1	24	9
MAT05517	ALU0920	IA803-A	23.00	80	Failed	50	16	3
MAT00955	ALU0160	IA501-A	23.33	70	Failed	19	48	3
MAT04149	ALU0692	IA203-B	29.33	76	Failed	20	16	52
MAT00530	ALU0089	IA202-A	35.00	57	Failed	44	35	26
MAT03729	ALU0622	IA103-B	48.67	89	Failed	49	50	47
MAT05932	ALU0989	IA504-A	18.67	78	Failed	10	20	26
MAT00533	ALU0089	IA205-A	21.67	48	Failed	11	39	15
MAT02723	ALU0454	IA605-B	10.67	56	Failed	4	0	28
MAT05577	ALU0930	IA103-A	31.67	62	Failed	52	8	35
MAT02071	ALU0346	IA701-B	31.67	65	Failed	38	24	33
MAT02110	ALU0352	IA204-A	27.67	63	Failed	28	5	50
MAT04290	ALU0715	IA306-B	19.67	88	Failed	28	6	25
MAT05854	ALU0976	IA304-A	56.00	62	Failed	52	57	59
MAT05821	ALU0971	IA601-B	25.67	77	Failed	59	8	10
MAT03120	ALU0520	IA306-A	19.33	54	Failed	9	39	10
MAT02838	ALU0473	IA606-A	53.67	42	Failed	56	56	49
MAT02777	ALU0463	IA605-A	21.00	82	Failed	24	13	26
MAT04282	ALU0714	IA804-B	20.67	78	Failed	27	32	3
MAT02616	ALU0436	IA206-A	29.00	33	Failed	17	19	51
MAT01040	ALU0174	IA702-B	27.67	87	Failed	20	9	54
MAT05086	ALU0848	IA104-A	12.67	94	Failed	30	7	1
MAT03482	ALU0581	IA302-B	33.00	97	Failed	32	10	57
MAT01597	ALU0267	IA601-A	28.33	41	Failed	11	15	59
MAT01732	ALU0289	IA404-B	42.33	64	Failed	55	54	18
MAT05602	ALU0934	IA604-A	31.67	51	Failed	41	9	45
MAT02018	ALU0337	IA302-B	19.33	33	Failed	3	1	54
MAT01636	ALU0273	IA404-A	13.33	86	Failed	9	14	17
MAT00268	ALU0045	IA104-B	21.33	93	Failed	26	33	5
MAT03989	ALU0665	IA605-B	7.00	57	Failed	16	2	3
MAT00980	ALU0164	IA502-A	24.67	47	Failed	27	45	2
MAT02734	ALU0456	IA604-A	36.33	59	Failed	36	58	15
MAT01017	ALU0170	IA403-B	22.00	84	Failed	44	7	15
MAT02346	ALU0391	IA706-A	19.33	84	Failed	36	18	4
MAT00364	ALU0061	IA804-B	30.00	68	Failed	20	50	20
MAT00871	ALU0146	IA201-B	28.00	44	Failed	17	40	27
MAT03962	ALU0661	IA402-A	20.67	63	Failed	18	12	32
MAT01291	ALU0216	IA201-A	43.33	70	Failed	45	33	52
MAT01481	ALU0247	IA205-B	52.00	80	Failed	59	52	45
MAT01691	ALU0282	IA805-B	26.00	69	Failed	14	9	55
MAT03809	ALU0635	IA405-B	28.00	71	Failed	38	2	44
MAT01576	ALU0263	IA804-B	29.00	97	Failed	23	7	57
MAT01860	ALU0310	IA506-B	38.33	80	Failed	44	21	50
MAT02408	ALU0402	IA302-A	29.33	66	Failed	26	18	44
MAT02803	ALU0468	IA201-B	18.67	60	Failed	23	6	27
MAT05434	ALU0906	IA104-B	30.67	49	Failed	0	35	57
MAT02142	ALU0357	IA806-A	34.00	30	Failed	43	43	16
MAT00716	ALU0120	IA802-B	20.67	79	Failed	39	2	21
MAT05207	ALU0868	IA305-B	41.67	81	Failed	36	52	37
MAT00944	ALU0158	IA102-B	31.00	94	Failed	39	54	0
MAT01363	ALU0228	IA401-B	29.33	48	Failed	41	47	0
MAT02053	ALU0343	IA401-A	32.00	38	Failed	43	49	4
MAT01235	ALU0206	IA505-A	24.67	45	Failed	12	13	49
MAT00438	ALU0073	IA606-B	33.67	38	Failed	54	10	37
MAT02239	ALU0374	IA301-B	29.00	54	Failed	13	24	50
MAT01055	ALU0176	IA205-B	18.33	39	Failed	21	2	32
MAT00702	ALU0117	IA506-A	26.00	40	Failed	59	3	16
MAT05948	ALU0992	IA302-A	14.00	53	Failed	31	2	9
MAT01656	ALU0276	IA606-B	29.33	54	Failed	42	31	15
MAT02875	ALU0480	IA301-A	18.00	43	Failed	31	23	0
MAT01866	ALU0311	IA406-A	12.00	41	Failed	19	7	10
MAT01346	ALU0225	IA302-A	31.33	73	Failed	21	29	44
MAT02398	ALU0400	IA404-B	36.67	100	Failed	43	25	42
MAT03461	ALU0577	IA805-A	6.67	73	Failed	2	15	3
MAT05471	ALU0912	IA605-B	27.33	97	Failed	2	58	22
MAT00166	ALU0028	IA304-B	35.67	35	Failed	31	51	25
MAT05193	ALU0866	IA303-B	50.00	87	Failed	54	47	49
MAT01504	ALU0251	IA504-A	16.00	93	Failed	9	24	15
MAT01262	ALU0211	IA202-B	26.33	93	Failed	39	25	15
MAT01961	ALU0327	IA105-A	32.00	73	Failed	0	57	39
MAT02054	ALU0343	IA402-A	29.33	72	Failed	26	39	23
MAT04429	ALU0739	IA101-A	45.67	48	Failed	26	58	53
MAT00235	ALU0040	IA301-A	37.00	79	Failed	40	50	21
MAT04202	ALU0701	IA702-B	20.00	65	Failed	51	9	0
MAT00654	ALU0109	IA206-A	28.67	59	Failed	31	55	0
MAT00752	ALU0126	IA702-B	38.33	42	Failed	36	28	51
MAT02698	ALU0450	IA504-A	16.67	50	Failed	47	2	1
MAT03050	ALU0509	IA802-B	35.33	64	Failed	57	4	45
MAT02653	ALU0443	IA101-A	36.33	53	Failed	17	42	50
MAT03267	ALU0545	IA403-B	28.00	83	Failed	19	13	52
MAT04795	ALU0800	IA601-B	33.33	47	Failed	23	47	30
MAT00221	ALU0037	IA305-B	23.33	71	Failed	12	8	50
MAT01821	ALU0304	IA803-B	44.00	79	Failed	34	41	57
MAT00892	ALU0149	IA404-A	16.67	54	Failed	1	18	31
MAT02036	ALU0340	IA102-B	32.33	67	Failed	47	17	33
MAT05307	ALU0885	IA203-B	34.33	78	Failed	22	36	45
MAT01593	ALU0266	IA803-A	12.67	96	Failed	13	1	24
MAT05439	ALU0907	IA203-B	32.00	63	Failed	21	16	59
MAT00608	ALU0102	IA502-A	34.00	84	Failed	33	29	40
MAT04427	ALU0738	IA805-B	36.00	73	Failed	53	23	32
MAT00715	ALU0120	IA801-B	19.67	50	Failed	6	49	4
MAT05677	ALU0947	IA801-A	19.67	47	Failed	36	5	18
MAT01582	ALU0264	IA104-B	20.00	72	Failed	28	24	8
MAT01288	ALU0215	IA604-B	38.67	75	Failed	17	45	54
MAT01877	ALU0313	IA805-A	14.67	39	Failed	20	24	0
MAT05688	ALU0948	IA206-B	26.33	35	Failed	17	18	44
MAT02401	ALU0401	IA301-A	19.67	66	Failed	1	35	23
MAT01113	ALU0186	IA203-B	31.33	75	Failed	50	15	29
MAT05696	ALU0950	IA202-A	21.33	63	Failed	5	41	18
MAT05697	ALU0950	IA203-A	32.00	41	Failed	6	38	52
MAT03585	ALU0598	IA103-A	53.67	53	Failed	53	52	56
MAT01503	ALU0251	IA503-A	33.33	90	Failed	27	47	26
MAT00392	ALU0066	IA302-B	27.67	32	Failed	46	6	31
MAT04289	ALU0715	IA305-B	5.67	30	Failed	0	1	16
MAT02895	ALU0483	IA503-B	28.67	59	Failed	27	3	56
MAT05364	ALU0894	IA306-B	20.67	53	Failed	37	5	20
MAT02418	ALU0403	IA106-B	29.67	88	Failed	45	41	3
MAT01741	ALU0291	IA101-B	44.33	61	Failed	59	45	29
MAT05735	ALU0956	IA405-A	36.33	59	Failed	51	29	29
MAT05177	ALU0863	IA605-B	36.67	100	Failed	32	36	42
MAT00505	ALU0085	IA301-B	30.67	61	Failed	36	36	20
MAT03408	ALU0568	IA706-A	36.33	43	Failed	53	47	9
MAT05265	ALU0878	IA803-B	20.67	80	Failed	54	3	5
MAT00709	ALU0119	IA401-B	31.33	30	Failed	16	41	37
MAT00343	ALU0058	IA101-B	31.33	81	Failed	40	49	5
MAT02303	ALU0384	IA205-B	18.33	69	Failed	31	14	10
MAT04025	ALU0671	IA805-A	35.67	97	Failed	10	52	45
MAT02176	ALU0363	IA804-B	38.00	64	Failed	16	49	49
MAT02000	ALU0334	IA202-A	41.33	56	Failed	58	54	12
MAT02618	ALU0437	IA202-A	19.00	74	Failed	40	5	12
MAT04431	ALU0739	IA103-A	12.67	100	Failed	19	19	0
MAT01342	ALU0224	IA704-B	27.33	78	Failed	51	0	31
MAT00624	ALU0104	IA706-B	33.67	75	Failed	17	44	40
MAT00508	ALU0085	IA304-B	43.67	89	Failed	47	34	50
MAT05046	ALU0841	IA606-B	28.33	36	Failed	11	51	23
MAT05530	ALU0922	IA504-B	10.67	94	Failed	10	3	19
MAT02655	ALU0443	IA103-A	38.00	58	Failed	41	45	28
MAT00682	ALU0114	IA804-B	26.67	74	Failed	18	10	52
MAT02199	ALU0367	IA803-B	27.00	54	Failed	28	47	6
MAT02388	ALU0398	IA606-B	40.67	69	Failed	24	39	59
MAT01702	ALU0284	IA604-A	35.00	83	Failed	36	11	58
MAT03653	ALU0609	IA305-A	24.33	82	Failed	5	36	32
MAT02284	ALU0381	IA704-B	35.33	47	Failed	33	17	56
MAT04373	ALU0729	IA605-A	56.33	100	Failed	54	57	58
MAT00820	ALU0137	IA204-A	30.67	74	Failed	12	32	48
MAT03100	ALU0517	IA604-B	17.67	40	Failed	3	44	6
MAT02506	ALU0418	IA604-B	21.67	44	Failed	43	4	18
MAT00393	ALU0066	IA303-B	21.33	45	Failed	6	36	22
MAT00398	ALU0067	IA602-B	43.67	96	Failed	31	52	48
MAT02499	ALU0417	IA503-B	32.00	30	Failed	23	52	21
MAT05048	ALU0842	IA502-B	42.00	83	Failed	59	26	41
MAT01063	ALU0178	IA601-B	12.33	80	Failed	12	2	23
MAT01361	ALU0227	IA505-B	31.00	43	Failed	21	19	53
MAT00537	ALU0090	IA103-B	20.33	45	Failed	13	6	42
MAT05792	ALU0966	IA602-B	37.67	60	Failed	13	55	45
MAT02828	ALU0472	IA702-B	53.00	40	Failed	51	55	53
MAT04384	ALU0731	IA804-B	12.67	85	Failed	27	10	1
MAT01458	ALU0243	IA306-A	38.00	100	Failed	36	54	24
MAT03542	ALU0591	IA602-B	25.67	88	Failed	18	56	3
MAT01525	ALU0255	IA501-A	19.00	79	Failed	6	21	30
MAT01453	ALU0243	IA301-A	17.67	90	Failed	0	53	0
MAT00321	ALU0054	IA403-A	26.67	73	Failed	50	29	1
MAT02913	ALU0486	IA403-A	10.67	43	Failed	24	2	6
MAT05515	ALU0920	IA801-A	43.33	48	Failed	53	27	50
MAT02515	ALU0420	IA601-A	25.00	75	Failed	24	42	9
MAT05330	ALU0889	IA502-B	16.00	49	Failed	20	9	19
MAT00492	ALU0082	IA106-A	30.67	91	Failed	24	55	13
MAT05628	ALU0938	IA306-B	27.67	33	Failed	31	17	35
MAT04372	ALU0729	IA604-A	12.67	41	Failed	3	10	25
MAT01142	ALU0191	IA602-A	45.67	77	Failed	54	52	31
MAT02595	ALU0433	IA803-A	8.33	38	Failed	5	19	1
MAT01367	ALU0228	IA405-B	35.33	65	Failed	45	48	13
MAT03368	ALU0562	IA402-B	34.33	90	Failed	38	7	58
MAT02995	ALU0500	IA701-A	29.00	40	Failed	51	8	28
MAT01862	ALU0311	IA402-A	9.00	96	Failed	11	11	5
MAT00138	ALU0023	IA606-A	23.00	57	Failed	32	18	19
MAT05203	ALU0868	IA301-B	26.67	32	Failed	21	40	19
MAT00799	ALU0134	IA501-A	27.00	71	Failed	52	12	17
MAT05078	ALU0847	IA802-A	24.33	34	Failed	11	30	32
MAT03969	ALU0662	IA103-B	22.00	63	Failed	21	40	5
MAT01710	ALU0285	IA506-A	22.67	94	Failed	9	33	26
MAT01412	ALU0236	IA602-B	20.00	83	Failed	18	31	11
MAT00085	ALU0015	IA201-B	56.00	85	Failed	55	58	55
MAT02310	ALU0385	IA506-B	22.00	73	Failed	45	10	11
MAT00637	ALU0107	IA301-B	31.33	90	Failed	14	43	37
MAT02853	ALU0476	IA403-B	47.67	37	Failed	36	54	53
MAT05271	ALU0879	IA303-B	23.67	50	Failed	48	18	5
MAT03973	ALU0663	IA801-B	6.67	95	Failed	0	6	14
MAT05601	ALU0934	IA603-A	38.00	69	Failed	23	40	51
MAT01045	ALU0175	IA301-B	18.00	63	Failed	17	37	0
MAT05603	ALU0934	IA605-A	26.67	77	Failed	31	45	4
MAT00116	ALU0020	IA702-B	18.67	75	Failed	15	36	5
MAT02446	ALU0408	IA604-B	27.00	86	Failed	50	6	25
MAT03178	ALU0530	IA804-B	32.33	34	Failed	2	53	42
MAT02854	ALU0476	IA404-B	37.33	99	Failed	17	44	51
MAT03101	ALU0517	IA605-B	31.00	54	Failed	17	40	36
MAT02867	ALU0478	IA405-B	23.33	31	Failed	55	13	2
MAT03206	ALU0535	IA102-B	15.00	80	Failed	25	15	5
MAT01989	ALU0332	IA703-B	19.00	47	Failed	19	19	19
MAT01438	ALU0240	IA204-B	25.00	98	Failed	29	10	36
MAT00182	ALU0031	IA602-B	27.00	91	Failed	9	53	19
MAT03268	ALU0545	IA404-B	24.67	58	Failed	12	28	34
MAT03037	ALU0507	IA301-B	38.33	33	Failed	15	55	45
MAT02260	ALU0377	IA104-A	21.33	92	Failed	26	6	32
MAT03546	ALU0591	IA606-B	30.67	67	Failed	42	32	18
MAT05532	ALU0922	IA506-B	49.33	89	Failed	46	51	51
MAT05496	ALU0916	IA406-B	23.67	83	Failed	16	45	10
MAT01399	ALU0234	IA201-A	44.00	31	Failed	35	54	43
MAT03892	ALU0649	IA304-B	44.67	34	Failed	47	49	38
MAT05154	ALU0859	IA206-B	28.67	73	Failed	47	33	6
MAT02097	ALU0350	IA803-B	37.00	34	Failed	50	50	11
MAT00636	ALU0106	IA506-B	28.67	98	Failed	49	26	11
MAT00672	ALU0112	IA406-B	25.67	56	Failed	15	35	27
MAT04416	ALU0736	IA106-B	36.67	76	Failed	33	28	49
MAT05279	ALU0880	IA105-B	20.00	85	Failed	33	25	2
MAT01682	ALU0281	IA102-B	32.67	70	Failed	28	17	53
MAT02627	ALU0438	IA105-B	21.33	86	Failed	12	33	19
MAT05353	ALU0893	IA801-B	22.33	47	Failed	12	37	18
MAT02256	ALU0376	IA806-B	44.33	82	Failed	43	56	34
MAT00852	ALU0142	IA606-B	33.33	44	Failed	39	16	45
MAT01327	ALU0222	IA701-B	45.00	94	Failed	53	28	54
MAT01375	ALU0230	IA801-B	30.00	46	Failed	33	55	2
MAT05365	ALU0895	IA501-A	11.00	60	Failed	25	8	0
MAT02756	ALU0460	IA502-B	32.00	57	Failed	33	51	12
MAT05732	ALU0956	IA402-A	26.67	53	Failed	18	11	51
MAT00594	ALU0099	IA406-B	12.00	80	Failed	16	6	14
MAT01365	ALU0228	IA403-B	39.33	89	Failed	44	49	25
MAT00230	ALU0039	IA202-B	35.00	53	Failed	34	37	34
MAT00965	ALU0161	IA205-B	10.33	84	Failed	5	22	4
MAT01979	ALU0330	IA605-B	28.33	70	Failed	48	31	6
MAT02818	ALU0470	IA204-B	15.00	75	Failed	7	4	34
MAT05947	ALU0992	IA301-A	22.33	81	Failed	17	13	37
MAT05379	ALU0897	IA503-B	30.67	74	Failed	38	21	33
MAT02770	ALU0462	IA604-A	17.33	79	Failed	14	10	28
MAT01436	ALU0240	IA202-B	37.67	56	Failed	12	55	46
MAT04933	ALU0823	IA401-B	48.00	53	Failed	53	39	52
MAT05089	ALU0849	IA501-B	16.00	52	Failed	24	2	22
MAT05750	ALU0959	IA602-B	34.00	75	Failed	44	52	6
MAT00605	ALU0101	IA205-A	39.67	30	Failed	51	45	23
MAT04297	ALU0717	IA101-B	26.33	53	Failed	20	52	7
MAT03520	ALU0587	IA804-A	31.67	91	Failed	18	57	20
MAT01216	ALU0203	IA104-A	39.00	90	Failed	57	23	37
MAT02002	ALU0334	IA204-A	15.33	43	Failed	1	22	23
MAT00894	ALU0149	IA406-A	20.33	32	Failed	22	3	36
MAT02451	ALU0409	IA403-B	20.67	67	Failed	10	26	26
MAT02452	ALU0409	IA404-B	37.33	42	Failed	44	9	59
MAT02175	ALU0363	IA803-B	12.33	61	Failed	16	11	10
MAT01292	ALU0216	IA202-A	26.67	49	Failed	20	16	44
MAT05102	ALU0851	IA302-A	29.00	44	Failed	20	14	53
MAT02533	ALU0423	IA601-A	9.00	35	Failed	14	10	3
MAT00509	ALU0085	IA305-B	42.67	55	Failed	14	56	58
MAT02453	ALU0409	IA405-B	17.00	69	Failed	24	16	11
MAT05706	ALU0951	IA306-A	30.33	47	Failed	34	44	13
MAT05396	ALU0900	IA302-A	48.00	86	Failed	44	49	51
MAT01879	ALU0314	IA101-B	27.00	90	Failed	35	35	11
MAT05664	ALU0944	IA106-B	48.00	87	Failed	48	49	47
MAT01191	ALU0199	IA303-A	22.00	66	Failed	26	3	37
MAT00368	ALU0062	IA202-A	24.33	57	Failed	12	51	10
MAT02117	ALU0353	IA305-B	19.67	39	Failed	4	7	48
MAT05363	ALU0894	IA305-B	13.33	82	Failed	33	6	1
MAT02058	ALU0343	IA406-A	29.33	69	Failed	42	20	26
MAT00014	ALU0003	IA302-B	27.33	80	Failed	19	13	50
MAT05553	ALU0926	IA703-B	23.33	83	Failed	50	15	5
MAT04023	ALU0671	IA803-A	17.00	35	Failed	5	40	6
MAT01749	ALU0292	IA703-A	13.33	89	Failed	31	3	6
MAT00978	ALU0163	IA606-B	15.33	41	Failed	8	10	28
MAT03072	ALU0512	IA206-A	42.33	94	Failed	43	54	30
MAT01735	ALU0290	IA401-B	42.00	55	Failed	36	34	56
MAT00599	ALU0100	IA405-B	26.33	77	Failed	6	47	26
MAT01023	ALU0171	IA103-A	18.67	62	Failed	6	46	4
MAT03063	ALU0511	IA603-B	36.33	33	Failed	24	26	59
MAT02100	ALU0350	IA806-B	28.33	79	Failed	10	26	49
MAT02927	ALU0488	IA405-B	22.33	36	Failed	28	31	8
MAT00388	ALU0065	IA704-A	39.33	91	Failed	41	43	34
MAT03192	ALU0532	IA206-A	45.00	32	Failed	58	46	31
MAT02780	ALU0464	IA302-B	33.33	58	Failed	32	59	9
MAT01546	ALU0258	IA104-B	20.67	77	Failed	25	18	19
MAT01086	ALU0181	IA706-B	22.33	42	Failed	13	6	48
MAT03043	ALU0508	IA501-B	30.67	62	Failed	56	32	4
MAT00177	ALU0030	IA703-B	26.67	68	Failed	52	12	16
MAT03208	ALU0535	IA104-B	25.00	49	Failed	9	35	31
MAT05067	ALU0845	IA503-B	33.33	73	Failed	15	35	50
MAT01599	ALU0267	IA603-A	35.00	99	Failed	37	11	57
MAT02140	ALU0357	IA804-A	41.33	37	Failed	38	54	32
MAT01097	ALU0183	IA805-B	32.67	49	Failed	22	41	35
MAT03981	ALU0664	IA103-B	37.33	53	Failed	56	41	15
MAT00401	ALU0067	IA605-B	34.00	55	Failed	39	20	43
MAT01853	ALU0309	IA105-B	32.00	35	Failed	38	23	35
MAT00953	ALU0159	IA305-B	31.00	92	Failed	29	21	43
MAT02527	ALU0422	IA401-B	35.67	50	Failed	53	40	14
MAT00260	ALU0044	IA302-A	16.67	77	Failed	21	5	24
MAT00691	ALU0116	IA701-A	36.67	91	Failed	1	54	55
MAT00812	ALU0136	IA302-A	38.33	65	Failed	32	36	47
MAT03474	ALU0579	IA106-A	39.67	76	Failed	36	25	58
MAT04665	ALU0778	IA703-A	38.33	78	Failed	42	51	22
MAT05485	ALU0915	IA701-B	50.00	79	Failed	39	59	52
MAT01088	ALU0182	IA802-A	29.00	38	Failed	37	18	32
MAT02877	ALU0480	IA303-A	37.00	91	Failed	28	52	31
MAT00031	ALU0006	IA101-A	39.00	65	Failed	56	15	46
MAT01766	ALU0295	IA402-B	24.00	44	Failed	25	23	24
MAT00480	ALU0080	IA206-A	22.67	89	Failed	50	4	14
MAT03030	ALU0505	IA606-A	30.67	92	Failed	7	33	52
MAT01081	ALU0181	IA701-B	10.67	50	Failed	3	26	3
MAT00127	ALU0022	IA401-A	19.00	59	Failed	45	3	9
MAT00945	ALU0158	IA103-B	39.00	98	Failed	41	48	28
MAT05337	ALU0890	IA103-A	51.67	48	Failed	52	57	46
MAT02368	ALU0395	IA304-B	47.00	86	Failed	51	42	48
MAT04898	ALU0817	IA702-A	21.00	44	Failed	23	39	1
MAT05830	ALU0972	IA304-A	29.33	91	Failed	13	38	37
MAT05467	ALU0912	IA601-B	28.33	66	Failed	18	40	27
MAT05388	ALU0898	IA106-B	18.00	89	Failed	8	36	10
MAT02492	ALU0416	IA802-B	38.33	39	Failed	41	47	27
MAT01654	ALU0276	IA604-B	30.67	48	Failed	13	58	21
MAT02238	ALU0373	IA606-B	26.00	73	Failed	28	30	20
MAT01823	ALU0304	IA805-B	21.00	68	Failed	7	53	3
MAT02206	ALU0368	IA404-B	37.33	76	Failed	20	43	49
MAT01819	ALU0304	IA801-B	24.33	96	Failed	23	8	42
MAT02859	ALU0477	IA303-A	41.33	40	Failed	52	32	40
MAT02404	ALU0401	IA304-A	36.00	95	Failed	47	19	42
MAT02318	ALU0387	IA302-B	28.33	30	Failed	28	10	47
MAT04304	ALU0718	IA702-A	31.33	47	Failed	18	41	35
MAT02613	ALU0436	IA203-A	39.00	53	Failed	52	31	34
MAT04971	ALU0829	IA403-A	26.67	78	Failed	48	21	11
MAT00294	ALU0049	IA506-B	47.33	46	Failed	52	49	41
MAT03107	ALU0518	IA105-B	22.33	93	Failed	15	9	43
MAT01922	ALU0321	IA202-B	24.00	31	Failed	1	48	23
MAT04619	ALU0770	IA605-B	26.67	50	Failed	31	38	11
MAT01326	ALU0221	IA806-B	42.67	82	Failed	51	57	20
MAT05189	ALU0865	IA405-B	25.00	90	Failed	50	14	11
MAT00353	ALU0059	IA405-B	58.67	42	Failed	59	58	59
MAT04410	ALU0735	IA406-A	33.00	37	Failed	35	22	42
MAT03255	ALU0543	IA203-A	21.00	56	Failed	5	35	23
MAT05759	ALU0960	IA805-A	26.00	88	Failed	6	33	39
MAT05201	ALU0867	IA805-B	28.67	94	Failed	56	10	20
MAT05079	ALU0847	IA803-A	47.00	81	Failed	59	41	41
MAT03085	ALU0515	IA201-B	53.33	88	Failed	54	49	57
MAT01944	ALU0324	IA606-B	12.67	43	Failed	22	6	10
MAT00602	ALU0101	IA202-A	23.67	73	Failed	18	24	29
MAT05304	ALU0884	IA606-A	4.00	68	Failed	10	2	0
MAT00664	ALU0111	IA804-A	26.67	46	Failed	38	26	16
MAT03486	ALU0581	IA306-B	48.33	92	Failed	58	48	39
MAT01781	ALU0297	IA805-B	44.67	76	Failed	48	27	59
MAT05845	ALU0975	IA401-B	33.00	57	Failed	57	38	4
MAT05049	ALU0842	IA503-B	31.33	32	Failed	48	11	35
MAT02983	ALU0498	IA301-B	21.33	86	Failed	3	27	34
MAT02612	ALU0436	IA202-A	33.67	33	Failed	42	10	49
MAT01929	ALU0322	IA503-B	23.33	34	Failed	3	46	21
MAT02638	ALU0440	IA504-A	48.67	63	Failed	52	48	46
MAT00301	ALU0051	IA101-A	31.00	59	Failed	38	20	35
MAT01339	ALU0224	IA701-B	38.67	63	Failed	41	50	25
MAT00540	ALU0090	IA106-B	36.00	79	Failed	38	37	33
MAT02642	ALU0441	IA602-B	13.67	42	Failed	23	14	4
MAT02980	ALU0497	IA604-B	21.00	46	Failed	48	10	5
MAT02975	ALU0496	IA405-A	13.67	70	Failed	8	14	19
MAT02386	ALU0398	IA604-B	37.67	46	Failed	51	52	10
MAT00212	ALU0036	IA202-A	26.33	77	Failed	22	34	23
MAT00286	ALU0048	IA804-A	11.00	40	Failed	17	16	0
MAT05145	ALU0858	IA203-B	40.33	99	Failed	14	55	52
MAT01920	ALU0320	IA706-B	15.67	94	Failed	10	20	17
MAT02561	ALU0427	IA405-B	28.67	93	Failed	18	51	17
MAT04458	ALU0743	IA506-A	13.33	53	Failed	9	24	7
MAT04836	ALU0806	IA306-A	33.33	98	Failed	1	41	58
MAT00219	ALU0037	IA303-B	32.33	52	Failed	54	28	15
MAT02387	ALU0398	IA605-B	47.00	60	Failed	56	57	28
MAT05936	ALU0990	IA102-A	41.00	42	Failed	59	35	29
MAT05574	ALU0929	IA806-A	33.00	69	Failed	50	8	41
MAT03044	ALU0508	IA502-B	34.00	66	Failed	38	14	50
MAT00399	ALU0067	IA603-B	17.67	53	Failed	2	0	51
MAT01137	ALU0190	IA403-A	35.67	95	Failed	17	47	43
MAT00633	ALU0106	IA503-B	45.00	35	Failed	49	50	36
MAT05819	ALU0970	IA505-B	37.33	31	Failed	46	18	48
MAT02497	ALU0417	IA501-B	23.00	76	Failed	3	45	21
MAT03033	ALU0506	IA603-B	32.67	55	Failed	44	35	19
MAT03528	ALU0588	IA406-A	17.33	94	Failed	3	36	13
MAT05702	ALU0951	IA302-A	33.67	32	Failed	14	30	57
MAT01845	ALU0308	IA103-A	33.00	77	Failed	44	35	20
MAT05015	ALU0836	IA605-B	37.67	74	Failed	45	57	11
MAT05687	ALU0948	IA205-B	36.00	100	Failed	38	31	39
MAT00331	ALU0056	IA101-B	21.33	34	Failed	2	40	22
MAT01773	ALU0296	IA803-A	16.67	93	Failed	17	23	10
MAT02403	ALU0401	IA303-A	36.67	30	Failed	6	58	46
MAT00745	ALU0125	IA301-B	12.33	50	Failed	12	8	17
MAT00811	ALU0136	IA301-A	11.00	88	Failed	12	10	11
MAT01814	ALU0303	IA502-B	29.33	62	Failed	46	18	24
MAT01282	ALU0214	IA504-A	39.67	39	Failed	6	56	57
MAT02182	ALU0364	IA104-A	48.33	73	Failed	44	59	42
MAT00359	ALU0060	IA105-A	22.67	83	Failed	1	51	16
MAT01089	ALU0182	IA803-A	44.33	35	Failed	50	28	55
MAT00265	ALU0045	IA101-B	34.00	33	Failed	36	23	43
MAT05808	ALU0968	IA506-B	11.00	51	Failed	2	18	13
MAT02562	ALU0427	IA406-B	26.33	61	Failed	4	30	45
MAT01883	ALU0314	IA105-B	20.00	75	Failed	34	12	14
MAT05672	ALU0946	IA102-B	25.00	34	Failed	42	32	1
MAT05655	ALU0943	IA503-A	38.67	96	Failed	22	39	55
MAT01683	ALU0281	IA103-B	33.67	87	Failed	9	49	43
MAT02247	ALU0375	IA603-A	31.67	66	Failed	55	0	40
MAT01279	ALU0214	IA501-A	27.00	56	Failed	24	26	31
MAT01370	ALU0229	IA202-A	38.67	83	Failed	15	51	50
MAT01598	ALU0267	IA602-A	42.00	85	Failed	38	59	29
MAT01809	ALU0302	IA803-B	44.00	62	Failed	54	52	26
MAT01094	ALU0183	IA802-B	26.33	62	Failed	47	17	15
MAT01567	ALU0262	IA401-B	25.00	72	Failed	37	29	9
MAT01286	ALU0215	IA602-B	27.33	100	Failed	52	20	10
MAT01035	ALU0173	IA303-A	41.33	75	Failed	19	57	48
MAT02246	ALU0375	IA602-A	34.00	73	Failed	57	19	26
MAT01552	ALU0259	IA404-A	25.33	48	Failed	40	32	4
MAT04831	ALU0806	IA301-A	28.67	43	Failed	25	41	20
MAT00988	ALU0165	IA504-B	16.67	99	Failed	19	7	24
MAT05593	ALU0933	IA701-B	45.33	84	Failed	23	59	54
MAT02716	ALU0453	IA804-A	35.67	83	Failed	46	37	24
MAT03611	ALU0602	IA505-A	29.67	58	Failed	23	19	47
MAT00496	ALU0083	IA104-B	25.00	75	Failed	57	12	6
MAT05805	ALU0968	IA503-B	36.00	74	Failed	3	48	57
MAT04366	ALU0728	IA404-B	44.67	61	Failed	54	50	30
MAT04186	ALU0698	IA604-B	26.00	77	Failed	23	13	42
MAT05357	ALU0893	IA805-B	27.00	94	Failed	29	16	36
MAT00196	ALU0033	IA204-B	44.33	34	Failed	47	42	44
MAT01828	ALU0305	IA304-B	30.33	82	Failed	17	22	52
MAT00644	ALU0108	IA402-A	33.33	63	Failed	18	36	46
MAT05037	ALU0840	IA603-B	40.33	34	Failed	41	55	25
MAT02007	ALU0335	IA503-B	26.67	33	Failed	29	6	45
MAT02807	ALU0468	IA205-B	34.00	73	Failed	30	23	49
MAT02420	ALU0404	IA302-B	11.33	44	Failed	17	3	14
MAT00210	ALU0035	IA506-B	47.33	80	Failed	43	49	50
MAT01998	ALU0333	IA106-A	25.33	92	Failed	28	5	43
MAT00452	ALU0076	IA802-B	23.67	34	Failed	24	32	15
MAT01932	ALU0322	IA506-B	35.33	71	Failed	43	56	7
MAT01209	ALU0202	IA603-B	40.33	96	Failed	30	44	47
MAT02742	ALU0457	IA706-A	20.67	44	Failed	37	24	1
MAT02465	ALU0411	IA405-B	52.33	84	Failed	52	58	47
MAT03647	ALU0608	IA505-B	44.00	42	Failed	54	53	25
MAT03691	ALU0616	IA301-B	27.67	93	Failed	4	29	50
MAT05221	ALU0871	IA701-A	48.67	98	Failed	42	54	50
MAT04311	ALU0719	IA803-A	20.00	54	Failed	6	22	32
MAT03075	ALU0513	IA203-A	39.67	84	Failed	50	56	13
MAT00835	ALU0140	IA201-A	40.33	72	Failed	40	35	46
MAT02792	ALU0466	IA602-B	10.67	51	Failed	3	11	18
MAT03222	ALU0537	IA406-B	28.00	51	Failed	47	29	8
MAT01794	ALU0299	IA206-A	36.67	56	Failed	45	45	20
MAT04931	ALU0822	IA405-B	18.00	30	Failed	5	39	10
MAT01434	ALU0239	IA106-B	39.33	74	Failed	29	35	54
MAT00426	ALU0071	IA406-B	45.33	40	Failed	19	59	58
MAT01757	ALU0293	IA805-B	28.00	62	Failed	2	52	30
MAT05912	ALU0986	IA602-B	16.67	54	Failed	18	3	29
MAT02614	ALU0436	IA204-A	15.00	93	Failed	16	19	10
MAT05065	ALU0845	IA501-B	30.33	48	Failed	49	17	25
MAT05212	ALU0869	IA804-B	33.00	58	Failed	25	43	31
MAT03039	ALU0507	IA303-B	10.33	69	Failed	6	12	13
MAT05338	ALU0890	IA104-A	35.00	32	Failed	29	26	50
MAT02534	ALU0423	IA602-A	37.33	38	Failed	22	57	33
MAT02810	ALU0469	IA602-B	38.00	77	Failed	49	14	51
MAT03620	ALU0604	IA402-A	29.67	93	Failed	17	25	47
MAT00880	ALU0147	IA204-B	25.33	44	Failed	2	43	31
MAT01010	ALU0169	IA202-B	31.67	81	Failed	34	9	52
MAT02330	ALU0389	IA702-B	14.00	37	Failed	20	7	15
MAT05311	ALU0886	IA701-B	36.33	91	Failed	42	36	31
MAT01126	ALU0188	IA804-B	18.00	71	Failed	24	16	14
MAT02560	ALU0427	IA404-B	35.33	80	Failed	36	19	51
MAT05925	ALU0988	IA203-B	33.33	69	Failed	13	49	38
MAT03028	ALU0505	IA604-A	26.33	76	Failed	3	40	36
MAT05472	ALU0912	IA606-B	15.00	88	Failed	11	8	26
MAT03219	ALU0537	IA403-B	36.67	67	Failed	7	55	48
MAT00924	ALU0154	IA606-A	21.00	33	Failed	1	50	12
MAT02652	ALU0442	IA306-B	20.00	72	Failed	5	27	28
MAT02654	ALU0443	IA102-A	28.67	79	Failed	11	27	48
MAT05206	ALU0868	IA304-B	13.00	84	Failed	31	3	5
MAT04210	ALU0702	IA804-B	34.00	53	Failed	54	15	33
MAT04977	ALU0830	IA203-B	41.00	72	Failed	59	23	41
MAT02228	ALU0372	IA802-B	34.67	53	Failed	57	23	24
MAT05556	ALU0926	IA706-B	27.33	69	Failed	31	37	14
MAT01134	ALU0189	IA806-A	23.00	48	Failed	33	19	17
MAT00834	ALU0139	IA506-B	44.00	38	Failed	57	40	35
MAT04878	ALU0813	IA506-A	28.33	51	Failed	21	46	18
MAT05073	ALU0846	IA203-A	32.67	42	Failed	32	43	23
MAT03070	ALU0512	IA204-A	34.00	75	Failed	18	42	42
MAT00673	ALU0113	IA701-B	34.00	46	Failed	51	13	38
MAT02285	ALU0381	IA705-B	42.00	84	Failed	56	25	45
MAT00430	ALU0072	IA404-B	26.67	54	Failed	5	29	46
MAT01585	ALU0265	IA301-B	37.67	36	Failed	57	22	34
MAT02148	ALU0358	IA706-A	41.00	75	Failed	45	59	19
MAT01014	ALU0169	IA206-B	17.33	93	Failed	2	20	30
MAT02123	ALU0354	IA705-B	27.33	32	Failed	26	19	37
MAT02356	ALU0393	IA404-B	35.33	74	Failed	23	48	35
MAT01336	ALU0223	IA404-B	46.33	65	Failed	50	41	48
MAT01229	ALU0205	IA605-A	41.33	36	Failed	42	26	56
MAT00431	ALU0072	IA405-B	36.33	81	Failed	48	20	41
MAT02043	ALU0341	IA403-B	34.67	79	Failed	47	17	40
MAT00565	ALU0095	IA301-A	32.33	94	Failed	32	49	16
MAT02392	ALU0399	IA804-B	39.67	91	Failed	40	36	43
MAT01496	ALU0250	IA302-B	35.33	76	Failed	47	22	37
MAT01937	ALU0323	IA405-A	22.33	71	Failed	2	29	36
MAT01560	ALU0260	IA806-B	18.67	80	Failed	44	8	4
MAT00226	ALU0038	IA704-B	36.67	35	Failed	33	54	23
MAT01478	ALU0247	IA202-B	18.00	64	Failed	1	47	6
MAT02358	ALU0393	IA406-B	23.00	66	Failed	10	56	3
MAT03731	ALU0622	IA105-B	41.00	45	Failed	46	32	45
MAT05823	ALU0971	IA603-B	31.00	100	Failed	6	31	56
MAT04338	ALU0723	IA206-A	16.33	78	Failed	25	17	7
MAT02857	ALU0477	IA301-A	16.00	65	Failed	22	10	16
MAT00967	ALU0162	IA401-B	11.33	44	Failed	23	0	11
MAT04350	ALU0725	IA206-B	38.33	36	Failed	50	16	49
MAT05704	ALU0951	IA304-A	25.33	54	Failed	42	9	25
MAT04370	ALU0729	IA602-A	52.67	33	Failed	52	51	55
MAT00920	ALU0154	IA602-A	18.33	100	Failed	17	20	18
MAT04517	ALU0753	IA205-A	23.33	68	Failed	30	12	28
MAT03644	ALU0608	IA502-B	24.00	37	Failed	27	38	7
MAT02952	ALU0492	IA706-B	31.67	47	Failed	19	57	19
MAT04129	ALU0689	IA601-A	31.33	47	Failed	44	14	36
MAT03429	ALU0572	IA203-A	23.67	30	Failed	3	58	10
MAT00419	ALU0070	IA105-B	48.33	78	Failed	53	40	52
MAT03091	ALU0516	IA601-A	30.00	46	Failed	45	23	22
MAT00468	ALU0078	IA106-A	39.00	70	Failed	57	37	23
MAT02563	ALU0428	IA201-A	41.00	59	Failed	53	40	30
MAT03104	ALU0518	IA102-B	31.67	48	Failed	52	34	9
MAT02958	ALU0493	IA306-A	35.33	98	Failed	30	49	27
MAT02861	ALU0477	IA305-A	31.00	48	Failed	58	33	2
MAT05839	ALU0974	IA301-B	28.00	77	Failed	47	31	6
MAT00390	ALU0065	IA706-A	30.33	85	Failed	6	54	31
MAT00531	ALU0089	IA203-A	47.67	33	Failed	38	49	56
MAT05631	ALU0939	IA103-B	17.33	30	Failed	41	10	1
MAT01090	ALU0182	IA804-A	36.33	96	Failed	31	36	42
MAT01516	ALU0253	IA604-B	23.33	68	Failed	16	48	6
MAT03375	ALU0563	IA203-B	27.67	31	Failed	2	22	59
MAT03934	ALU0656	IA404-B	31.67	71	Failed	55	30	10
MAT05420	ALU0904	IA502-B	36.00	81	Failed	29	31	48
MAT01680	ALU0280	IA706-A	25.33	31	Failed	15	27	34
MAT05277	ALU0880	IA103-B	39.67	46	Failed	51	24	44
MAT03965	ALU0661	IA405-A	7.67	95	Failed	6	8	9
MAT05481	ALU0914	IA603-A	34.00	40	Failed	46	34	22
MAT05824	ALU0971	IA604-B	54.67	39	Failed	57	58	49
MAT04787	ALU0798	IA605-B	31.00	80	Failed	30	55	8
MAT01095	ALU0183	IA803-B	20.33	89	Failed	51	9	1
MAT00443	ALU0074	IA305-B	41.33	48	Failed	44	35	45
MAT00814	ALU0136	IA304-A	29.00	46	Failed	0	56	31
MAT01934	ALU0323	IA402-A	34.33	58	Failed	42	13	48
MAT00952	ALU0159	IA304-B	36.00	30	Failed	32	36	40
MAT05684	ALU0948	IA202-B	35.00	39	Failed	33	54	18
MAT02936	ALU0490	IA402-B	38.00	60	Failed	20	54	40
MAT02402	ALU0401	IA302-A	25.00	48	Failed	17	2	56
MAT02518	ALU0420	IA604-A	25.67	51	Failed	32	0	45
MAT00246	ALU0041	IA306-A	34.00	83	Failed	58	21	23
MAT01679	ALU0280	IA705-A	22.67	34	Failed	54	8	6
MAT03411	ALU0569	IA103-B	39.67	56	Failed	58	30	31
MAT00291	ALU0049	IA503-B	20.00	35	Failed	19	2	39
MAT05594	ALU0933	IA702-B	39.33	58	Failed	37	24	57
MAT04554	ALU0759	IA106-B	32.33	54	Failed	16	46	35
MAT03509	ALU0585	IA705-A	26.67	90	Failed	15	34	31
MAT00391	ALU0066	IA301-B	19.67	95	Failed	10	38	11
MAT00280	ALU0047	IA404-A	29.00	85	Failed	31	24	32
MAT02475	ALU0413	IA203-B	22.67	36	Failed	29	4	35
MAT00627	ALU0105	IA803-B	18.67	99	Failed	35	10	11
MAT00542	ALU0091	IA602-B	17.67	97	Failed	6	12	35
MAT00923	ALU0154	IA605-A	18.33	77	Failed	35	1	19
MAT01355	ALU0226	IA305-A	35.67	64	Failed	52	19	36
MAT01867	ALU0312	IA801-A	14.00	85	Failed	1	31	10
MAT02738	ALU0457	IA702-A	18.00	31	Failed	33	17	4
MAT03351	ALU0559	IA403-A	15.67	36	Failed	8	38	1
MAT00970	ALU0162	IA404-B	38.33	51	Failed	41	53	21
MAT03820	ALU0637	IA604-B	28.33	83	Failed	29	34	22
MAT04985	ALU0831	IA505-B	43.00	31	Failed	45	50	34
MAT04525	ALU0755	IA601-B	8.67	72	Failed	3	2	21
MAT00638	ALU0107	IA302-B	31.33	49	Failed	49	32	13
MAT05600	ALU0934	IA602-A	47.67	77	Failed	43	58	42
MAT00826	ALU0138	IA204-A	10.00	67	Failed	14	15	1
MAT01256	ALU0210	IA202-B	31.67	87	Failed	8	58	29
MAT04383	ALU0731	IA803-B	47.00	60	Failed	36	55	50
MAT02844	ALU0474	IA206-B	43.00	62	Failed	19	53	57
MAT03615	ALU0603	IA803-A	3.33	90	Failed	1	7	2
MAT05762	ALU0961	IA302-B	34.67	60	Failed	36	14	54
MAT03221	ALU0537	IA405-B	43.00	58	Failed	29	52	48
MAT03024	ALU0504	IA506-B	22.67	98	Failed	20	46	2
MAT00882	ALU0147	IA206-B	22.67	41	Failed	30	1	37
MAT03095	ALU0516	IA605-A	15.00	64	Failed	15	3	27
MAT02764	ALU0461	IA104-B	15.00	75	Failed	30	8	7
MAT04128	ALU0688	IA306-B	8.67	92	Failed	25	0	1
MAT03516	ALU0586	IA206-B	16.00	36	Failed	30	3	15
MAT03891	ALU0649	IA303-B	27.67	51	Failed	7	37	39
MAT04959	ALU0827	IA203-B	30.33	34	Failed	43	42	6
MAT01402	ALU0234	IA204-A	38.67	91	Failed	30	47	39
MAT05538	ALU0923	IA506-A	46.33	82	Failed	33	58	48
MAT03071	ALU0512	IA205-A	36.00	60	Failed	46	10	52
MAT05753	ALU0959	IA605-B	29.33	80	Failed	32	56	0
MAT01543	ALU0258	IA101-B	16.33	94	Failed	29	13	7
MAT04022	ALU0671	IA802-A	18.67	77	Failed	6	21	29
MAT00886	ALU0148	IA204-A	32.00	59	Failed	41	51	4
MAT00404	ALU0068	IA102-A	20.00	73	Failed	1	20	39
MAT05549	ALU0925	IA205-B	24.67	60	Failed	12	26	36
MAT03436	ALU0573	IA304-B	41.00	45	Failed	33	48	42
MAT04970	ALU0829	IA402-A	14.00	49	Failed	16	1	25
MAT02345	ALU0391	IA705-A	31.00	57	Failed	23	20	50
MAT01729	ALU0289	IA401-B	48.00	72	Failed	49	53	42
MAT01507	ALU0252	IA701-A	36.00	52	Failed	28	46	34
MAT04730	ALU0789	IA702-B	33.33	63	Failed	38	16	46
MAT02390	ALU0399	IA802-B	29.33	73	Failed	37	4	47
MAT02144	ALU0358	IA702-A	10.00	83	Failed	6	24	0
MAT05815	ALU0970	IA501-B	23.00	57	Failed	45	14	10
MAT05693	ALU0949	IA305-A	36.00	46	Failed	16	51	41
MAT05669	ALU0945	IA305-B	39.67	44	Failed	58	33	28
MAT00261	ALU0044	IA303-A	24.67	42	Failed	2	43	29
MAT05605	ALU0935	IA501-A	44.67	68	Failed	47	50	37
MAT02746	ALU0458	IA204-B	44.67	99	Failed	39	36	59
MAT00228	ALU0038	IA706-B	12.67	58	Failed	27	4	7
MAT00657	ALU0110	IA203-B	27.00	81	Failed	24	8	49
MAT05679	ALU0947	IA803-A	35.33	76	Failed	33	32	41
MAT00877	ALU0147	IA201-B	31.67	73	Failed	29	34	32
MAT02517	ALU0420	IA603-A	26.67	31	Failed	33	9	38
MAT00921	ALU0154	IA603-A	21.67	73	Failed	26	27	12
MAT00705	ALU0118	IA803-B	25.00	93	Failed	29	11	35
MAT01690	ALU0282	IA804-B	36.67	62	Failed	43	58	9
MAT01175	ALU0196	IA105-A	29.33	66	Failed	12	24	52
MAT00543	ALU0091	IA603-B	42.00	41	Failed	9	59	58
MAT04422	ALU0737	IA706-B	12.33	39	Failed	6	31	0
MAT01721	ALU0287	IA505-A	21.33	46	Failed	16	11	37
MAT04647	ALU0775	IA803-B	32.33	64	Failed	24	44	29
MAT00295	ALU0050	IA301-B	21.00	30	Failed	32	1	30
MAT01812	ALU0302	IA806-B	22.33	87	Failed	16	1	50
MAT01237	ALU0207	IA301-A	18.00	88	Failed	4	44	6
MAT03186	ALU0531	IA306-B	30.33	68	Failed	35	8	48
MAT05368	ALU0895	IA504-A	30.67	93	Failed	28	21	43
MAT05714	ALU0953	IA402-B	17.67	92	Failed	33	10	10
MAT02651	ALU0442	IA305-B	43.33	48	Failed	24	53	53
MAT01250	ALU0209	IA302-B	15.67	62	Failed	29	2	16
MAT03116	ALU0520	IA302-A	36.00	58	Failed	54	42	12
MAT05939	ALU0990	IA105-A	16.33	36	Failed	15	3	31
MAT02827	ALU0472	IA701-B	34.67	66	Failed	46	33	25
MAT00840	ALU0140	IA206-A	17.33	75	Failed	19	30	3
MAT02223	ALU0371	IA703-B	13.00	30	Failed	9	17	13
MAT03211	ALU0536	IA301-B	18.33	97	Failed	38	10	7
MAT02033	ALU0339	IA305-B	30.67	69	Failed	22	52	18
MAT04975	ALU0830	IA201-B	8.33	86	Failed	0	4	21
MAT01284	ALU0214	IA506-A	26.00	55	Failed	3	34	41
MAT01707	ALU0285	IA503-A	29.33	100	Failed	59	19	10
MAT02683	ALU0448	IA501-A	14.67	36	Failed	13	13	18
MAT00412	ALU0069	IA104-A	43.67	49	Failed	54	28	49
MAT01748	ALU0292	IA702-A	45.00	97	Failed	55	29	51
MAT02384	ALU0398	IA602-B	25.00	93	Failed	18	11	46
MAT02270	ALU0379	IA702-A	41.33	96	Failed	54	19	51
MAT03632	ALU0606	IA302-B	32.67	45	Failed	2	37	59
MAT00623	ALU0104	IA705-B	19.67	49	Failed	11	9	39
MAT00863	ALU0144	IA605-B	31.33	53	Failed	44	10	40
MAT04629	ALU0772	IA803-B	39.67	71	Failed	35	33	51
MAT04806	ALU0801	IA406-B	23.67	34	Failed	28	14	29
MAT01795	ALU0300	IA701-B	9.00	42	Failed	12	8	7
MAT05661	ALU0944	IA103-B	40.33	91	Failed	22	40	59
MAT02029	ALU0339	IA301-B	41.67	78	Failed	48	59	18
MAT04471	ALU0746	IA101-B	42.67	49	Failed	32	48	48
MAT01283	ALU0214	IA505-A	24.33	45	Failed	20	20	33
MAT02158	ALU0360	IA204-A	43.00	99	Failed	34	55	40
MAT04139	ALU0690	IA305-B	3.67	46	Failed	3	7	1
MAT03146	ALU0525	IA802-A	24.67	51	Failed	22	26	26
MAT03074	ALU0513	IA202-A	10.00	75	Failed	6	16	8
MAT00510	ALU0085	IA306-B	27.00	72	Failed	20	39	22
MAT00515	ALU0086	IA805-A	25.00	30	Failed	25	19	31
MAT04239	ALU0707	IA703-A	34.67	100	Failed	9	44	51
MAT01222	ALU0204	IA804-B	40.00	32	Failed	54	47	19
MAT00335	ALU0056	IA105-B	29.33	61	Failed	15	29	44
MAT01509	ALU0252	IA703-A	26.00	42	Failed	31	23	24
MAT03201	ALU0534	IA603-B	28.00	52	Failed	33	4	47
MAT00494	ALU0083	IA102-B	48.33	60	Failed	55	49	41
MAT05042	ALU0841	IA602-B	26.33	39	Failed	0	58	21
MAT01305	ALU0218	IA403-B	21.33	55	Failed	55	8	1
MAT00396	ALU0066	IA306-B	29.67	62	Failed	36	13	40
MAT02383	ALU0398	IA601-B	6.67	91	Failed	9	10	1
MAT02588	ALU0432	IA202-A	13.33	49	Failed	11	27	2
MAT04522	ALU0754	IA404-A	35.00	63	Failed	19	38	48
MAT01096	ALU0183	IA804-B	42.00	36	Failed	48	58	20
MAT05678	ALU0947	IA802-A	9.00	91	Failed	4	12	11
MAT00397	ALU0067	IA601-B	27.33	82	Failed	6	19	57
MAT05838	ALU0973	IA406-A	27.00	97	Failed	58	16	7
MAT05149	ALU0859	IA201-B	18.67	82	Failed	13	26	17
MAT03207	ALU0535	IA103-B	51.00	38	Failed	51	53	49
MAT02055	ALU0343	IA403-A	33.00	75	Failed	5	51	43
MAT02997	ALU0500	IA703-A	4.67	36	Failed	10	1	3
MAT01368	ALU0228	IA406-B	36.33	86	Failed	45	8	56
MAT02032	ALU0339	IA304-B	26.67	34	Failed	9	14	57
MAT05204	ALU0868	IA302-B	36.33	70	Failed	58	12	39
MAT00628	ALU0105	IA804-B	42.33	46	Failed	50	21	56
MAT03972	ALU0662	IA106-B	34.00	51	Failed	17	43	42
MAT05409	ALU0902	IA403-B	19.33	40	Failed	7	48	3
MAT03549	ALU0592	IA603-B	41.33	37	Failed	51	27	46
MAT01193	ALU0199	IA305-A	32.33	57	Failed	17	43	37
MAT01263	ALU0211	IA203-B	30.33	70	Failed	29	22	40
MAT05116	ALU0853	IA404-B	28.33	77	Failed	11	45	29
MAT00557	ALU0093	IA405-A	12.33	85	Failed	22	10	5
MAT04369	ALU0729	IA601-A	26.00	34	Failed	25	24	29
MAT04974	ALU0829	IA406-A	34.67	60	Failed	33	54	17
MAT01886	ALU0315	IA202-A	13.33	88	Failed	18	2	20
MAT05064	ALU0844	IA206-A	23.67	81	Failed	29	30	12
MAT05973	ALU0996	IA103-A	37.33	79	Failed	49	5	58
MAT02109	ALU0352	IA203-A	35.67	79	Failed	21	43	43
MAT02539	ALU0424	IA601-A	29.67	72	Failed	30	13	46
MAT05198	ALU0867	IA802-B	29.33	97	Failed	14	55	19
MAT02378	ALU0397	IA302-B	33.67	44	Failed	46	45	10
MAT01076	ALU0180	IA502-B	35.00	73	Failed	30	51	24
MAT00622	ALU0104	IA704-B	31.00	52	Failed	50	27	16
MAT04148	ALU0692	IA202-B	32.33	36	Failed	55	2	40
MAT02916	ALU0486	IA406-A	25.33	69	Failed	38	15	23
MAT02108	ALU0352	IA202-A	25.33	96	Failed	24	40	12
MAT05263	ALU0878	IA801-B	28.33	90	Failed	36	18	31
MAT03918	ALU0653	IA606-B	24.33	42	Failed	21	8	44
MAT02412	ALU0402	IA306-A	16.33	60	Failed	1	15	33
MAT01978	ALU0330	IA604-B	40.67	94	Failed	49	52	21
MAT05707	ALU0952	IA201-B	30.33	65	Failed	45	12	34
MAT01433	ALU0239	IA105-B	21.67	64	Failed	16	11	38
MAT02839	ALU0474	IA201-B	16.33	55	Failed	26	1	22
MAT05814	ALU0969	IA206-B	19.00	69	Failed	18	23	16
MAT04271	ALU0712	IA805-A	30.00	54	Failed	55	21	14
MAT03942	ALU0657	IA806-B	26.67	87	Failed	16	50	14
MAT02984	ALU0498	IA302-B	35.00	44	Failed	33	27	45
MAT01013	ALU0169	IA205-B	37.00	30	Failed	40	31	40
MAT00475	ALU0080	IA201-A	22.33	65	Failed	21	43	3
MAT02924	ALU0488	IA402-B	34.67	72	Failed	33	12	59
MAT00498	ALU0083	IA106-B	27.33	87	Failed	30	39	13
MAT01362	ALU0227	IA506-B	11.33	34	Failed	12	17	5
MAT00756	ALU0126	IA706-B	31.67	71	Failed	53	7	35
MAT02702	ALU0451	IA402-B	17.67	49	Failed	33	20	0
MAT03899	ALU0650	IA805-B	45.67	81	Failed	47	37	53
MAT01635	ALU0273	IA403-A	13.33	74	Failed	13	24	3
MAT01594	ALU0266	IA804-A	23.33	95	Failed	5	14	51
MAT01316	ALU0220	IA602-B	31.33	81	Failed	10	59	25
MAT00051	ALU0009	IA203-A	9.33	70	Failed	6	18	4
MAT00544	ALU0091	IA604-B	20.00	69	Failed	23	0	37
MAT04307	ALU0718	IA705-A	55.00	70	Failed	55	58	52
MAT02021	ALU0337	IA305-B	42.00	99	Failed	48	23	55
MAT03053	ALU0509	IA805-B	21.00	78	Failed	5	42	16
MAT05093	ALU0849	IA505-B	24.67	55	Failed	6	55	13
MAT00491	ALU0082	IA105-A	46.67	70	Failed	58	26	56
MAT03407	ALU0568	IA705-A	13.00	91	Failed	10	12	17
MAT00300	ALU0050	IA306-B	29.33	58	Failed	17	53	18
MAT05092	ALU0849	IA504-B	49.00	96	Failed	55	55	37
MAT04789	ALU0799	IA801-B	18.67	52	Failed	30	9	17
MAT00500	ALU0084	IA202-B	34.67	47	Failed	23	22	59
MAT03514	ALU0586	IA204-B	32.67	49	Failed	38	10	50
MAT00145	ALU0025	IA701-B	11.67	44	Failed	18	9	8
MAT04846	ALU0808	IA304-B	17.67	43	Failed	18	13	22
MAT01280	ALU0214	IA502-A	42.33	52	Failed	22	54	51
MAT02421	ALU0404	IA303-B	24.67	73	Failed	19	52	3
MAT01479	ALU0247	IA203-B	32.67	95	Failed	47	47	4
MAT05004	ALU0834	IA106-B	31.00	66	Failed	25	10	58
MAT02649	ALU0442	IA303-B	19.67	40	Failed	32	18	9
MAT04272	ALU0712	IA806-A	21.33	76	Failed	39	10	15
MAT00949	ALU0159	IA301-B	26.33	85	Failed	30	8	41
MAT00762	ALU0127	IA806-B	39.33	47	Failed	31	58	29
MAT01520	ALU0254	IA602-A	26.00	75	Failed	36	32	10
MAT02306	ALU0385	IA502-B	15.33	72	Failed	37	4	5
MAT00552	ALU0092	IA106-A	24.67	42	Failed	6	21	47
MAT01701	ALU0284	IA603-A	27.33	72	Failed	14	11	57
MAT00849	ALU0142	IA603-B	22.67	92	Failed	26	22	20
MAT05176	ALU0863	IA604-B	17.33	81	Failed	10	33	9
MAT00701	ALU0117	IA505-A	36.33	48	Failed	51	38	20
MAT05584	ALU0931	IA504-A	32.00	96	Failed	39	43	14
MAT01007	ALU0168	IA405-A	35.67	50	Failed	39	31	37
MAT01760	ALU0294	IA502-A	35.67	65	Failed	42	24	41
MAT02101	ALU0351	IA501-B	15.33	94	Failed	1	36	9
MAT01839	ALU0307	IA403-A	29.67	82	Failed	13	38	38
MAT05787	ALU0965	IA703-B	19.33	39	Failed	12	39	7
MAT01832	ALU0306	IA502-A	23.00	45	Failed	8	30	31
MAT03808	ALU0635	IA404-B	28.00	76	Failed	32	50	2
MAT04620	ALU0770	IA606-B	54.33	97	Failed	58	50	55
MAT00983	ALU0164	IA505-A	33.33	51	Failed	42	8	50
MAT01394	ALU0233	IA402-B	37.00	97	Failed	26	58	27
MAT05522	ALU0921	IA702-A	30.33	94	Failed	35	16	40
MAT02664	ALU0444	IA806-B	19.33	71	Failed	3	28	27
MAT00258	ALU0043	IA306-A	31.67	74	Failed	42	51	2
MAT02669	ALU0445	IA805-B	33.33	92	Failed	54	21	25
MAT00447	ALU0075	IA503-B	32.67	58	Failed	5	42	51
MAT02596	ALU0433	IA804-A	23.33	70	Failed	12	40	18
MAT03975	ALU0663	IA803-B	20.00	90	Failed	22	27	11
MAT04999	ALU0834	IA101-B	32.67	40	Failed	8	48	42
MAT01782	ALU0297	IA806-B	20.67	100	Failed	23	10	29
MAT00651	ALU0109	IA203-A	28.67	61	Failed	57	7	22
MAT02331	ALU0389	IA703-B	21.33	34	Failed	3	37	24
MAT01310	ALU0219	IA102-A	20.67	50	Failed	6	45	11
MAT00578	ALU0097	IA602-A	29.67	31	Failed	25	52	12
MAT04197	ALU0700	IA503-B	18.67	54	Failed	6	5	45
MAT04285	ALU0715	IA301-B	21.67	80	Failed	9	39	17
MAT04797	ALU0800	IA603-B	20.00	98	Failed	13	45	2
MAT03618	ALU0603	IA806-A	14.00	54	Failed	7	1	34
MAT05521	ALU0921	IA701-A	25.00	39	Failed	54	10	11
MAT04413	ALU0736	IA103-B	18.00	77	Failed	50	2	2
MAT05703	ALU0951	IA303-A	33.00	92	Failed	18	31	50
MAT02131	ALU0356	IA801-B	31.67	63	Failed	31	15	49
MAT01511	ALU0252	IA705-A	38.67	76	Failed	51	40	25
MAT03609	ALU0602	IA503-A	15.67	58	Failed	4	22	21
MAT00486	ALU0081	IA406-B	11.67	72	Failed	26	8	1
MAT05509	ALU0919	IA101-A	25.00	95	Failed	47	13	15
MAT00936	ALU0156	IA606-A	38.67	87	Failed	36	39	41
MAT01159	ALU0194	IA501-A	9.33	72	Failed	20	6	2
MAT03199	ALU0534	IA601-B	43.00	64	Failed	46	40	43
MAT05166	ALU0861	IA206-B	30.00	66	Failed	51	31	8
MAT05315	ALU0886	IA705-B	41.33	92	Failed	54	28	42
MAT02187	ALU0365	IA203-A	21.33	97	Failed	24	15	25
MAT00767	ALU0128	IA305-A	27.00	41	Failed	27	29	25
MAT01145	ALU0191	IA605-A	37.00	54	Failed	24	59	28
MAT01738	ALU0290	IA404-B	30.67	93	Failed	45	42	5
MAT02197	ALU0367	IA801-B	34.67	56	Failed	34	48	22
MAT01539	ALU0257	IA403-B	14.67	38	Failed	19	25	0
MAT02641	ALU0441	IA601-B	47.67	69	Failed	34	56	53
MAT03173	ALU0529	IA205-B	37.67	55	Failed	30	47	36
MAT02230	ALU0372	IA804-B	8.67	41	Failed	2	12	12
MAT01799	ALU0300	IA705-B	34.33	100	Failed	21	58	24
MAT04195	ALU0700	IA501-B	28.67	37	Failed	0	41	45
MAT03409	ALU0569	IA101-B	25.33	88	Failed	17	29	30
MAT01623	ALU0271	IA103-B	23.33	41	Failed	11	58	1
MAT02248	ALU0375	IA604-A	24.33	37	Failed	16	27	30
MAT05749	ALU0959	IA601-B	18.67	68	Failed	15	34	7
MAT02374	ALU0396	IA504-B	33.67	76	Failed	38	36	27
MAT02903	ALU0484	IA205-B	16.67	65	Failed	5	41	4
MAT01928	ALU0322	IA502-B	29.67	62	Failed	41	24	24
MAT01512	ALU0252	IA706-A	16.33	83	Failed	7	0	42
MAT04956	ALU0826	IA606-B	25.67	61	Failed	1	33	43
MAT02399	ALU0400	IA405-B	25.67	83	Failed	17	31	29
MAT02785	ALU0465	IA501-A	49.00	54	Failed	56	40	51
MAT02255	ALU0376	IA805-B	26.67	94	Failed	1	53	26
MAT05328	ALU0888	IA506-B	19.33	87	Failed	53	2	3
MAT05935	ALU0990	IA101-A	36.00	83	Failed	38	29	41
MAT01966	ALU0328	IA204-B	17.33	53	Failed	25	19	8
MAT03626	ALU0605	IA302-A	39.00	52	Failed	52	51	14
MAT01337	ALU0223	IA405-B	35.00	67	Failed	10	50	45
MAT02529	ALU0422	IA403-B	38.33	91	Failed	16	43	56
MAT02405	ALU0401	IA305-A	28.67	83	Failed	40	28	18
MAT01230	ALU0205	IA606-A	19.67	91	Failed	48	9	2
MAT02840	ALU0474	IA202-B	27.33	83	Failed	40	32	10
MAT02784	ALU0464	IA306-B	36.33	53	Failed	59	40	10
MAT03510	ALU0585	IA706-A	35.33	31	Failed	12	43	51
MAT02709	ALU0452	IA403-B	29.67	38	Failed	40	42	7
MAT01612	ALU0269	IA604-B	42.67	98	Failed	42	53	33
MAT02532	ALU0422	IA406-B	26.33	52	Failed	21	2	56
MAT00299	ALU0050	IA305-B	28.00	54	Failed	47	29	8
MAT00209	ALU0035	IA505-B	18.33	48	Failed	31	12	12
MAT00836	ALU0140	IA202-A	40.67	68	Failed	31	43	48
MAT05075	ALU0846	IA205-A	26.00	68	Failed	1	52	25
MAT01813	ALU0303	IA501-B	24.67	66	Failed	1	57	16
MAT05794	ALU0966	IA604-B	20.00	43	Failed	7	34	19
MAT02375	ALU0396	IA505-B	28.67	51	Failed	28	50	8
MAT02017	ALU0337	IA301-B	17.00	34	Failed	5	45	1
MAT04854	ALU0809	IA306-A	19.33	74	Failed	33	5	20
MAT03550	ALU0592	IA604-B	20.33	30	Failed	43	7	11
MAT03149	ALU0525	IA805-A	42.67	86	Failed	56	23	49
MAT01233	ALU0206	IA503-A	32.00	96	Failed	13	37	46
MAT03161	ALU0527	IA205-A	14.33	58	Failed	20	8	15
MAT05847	ALU0975	IA403-B	24.67	53	Failed	27	14	33
MAT05812	ALU0969	IA204-B	42.33	92	Failed	51	55	21
MAT01765	ALU0295	IA401-B	42.00	38	Failed	26	41	59
MAT05424	ALU0904	IA506-B	30.33	96	Failed	42	0	49
MAT03013	ALU0503	IA701-B	15.33	91	Failed	39	2	5
MAT01736	ALU0290	IA402-B	39.00	74	Failed	54	21	42
MAT02928	ALU0488	IA406-B	36.33	36	Failed	30	51	28
MAT05974	ALU0996	IA104-A	12.67	97	Failed	2	23	13
MAT05367	ALU0895	IA503-A	25.67	53	Failed	13	52	12
MAT01874	ALU0313	IA802-A	21.33	59	Failed	31	14	19
MAT01016	ALU0170	IA402-B	17.67	72	Failed	19	30	4
MAT05719	ALU0954	IA501-B	25.67	83	Failed	24	45	8
MAT00804	ALU0134	IA506-A	33.00	79	Failed	4	45	50
MAT00847	ALU0142	IA601-B	34.67	53	Failed	11	58	35
MAT02752	ALU0459	IA704-A	33.33	68	Failed	43	8	49
MAT02647	ALU0442	IA301-B	41.33	45	Failed	47	59	18
MAT01580	ALU0264	IA102-B	25.00	73	Failed	48	9	18
MAT01270	ALU0212	IA404-B	29.33	70	Failed	59	22	7
MAT05508	ALU0918	IA806-A	33.00	68	Failed	44	53	2
MAT01665	ALU0278	IA503-B	22.67	78	Failed	11	23	34
MAT04033	ALU0673	IA401-B	27.33	62	Failed	9	31	42
MAT00481	ALU0081	IA401-B	32.33	43	Failed	20	39	38
MAT01851	ALU0309	IA103-B	33.67	33	Failed	31	46	24
MAT01981	ALU0331	IA401-A	14.33	56	Failed	0	1	42
MAT00993	ALU0166	IA103-B	27.67	77	Failed	56	6	21
MAT01907	ALU0318	IA405-A	38.33	90	Failed	44	25	46
MAT02508	ALU0418	IA606-B	32.33	36	Failed	56	29	12
MAT01138	ALU0190	IA404-A	38.67	81	Failed	33	45	38
MAT03995	ALU0666	IA805-B	41.67	63	Failed	50	29	46
MAT03216	ALU0536	IA306-B	21.00	39	Failed	34	4	25
MAT02146	ALU0358	IA704-A	32.67	62	Failed	53	11	34
MAT00768	ALU0128	IA306-A	30.33	50	Failed	45	14	32
MAT02648	ALU0442	IA302-B	35.67	100	Failed	56	23	28
MAT05513	ALU0919	IA105-A	22.00	40	Failed	54	3	9
MAT04688	ALU0782	IA102-B	37.67	93	Failed	13	59	41
MAT02391	ALU0399	IA803-B	28.67	77	Failed	47	3	36
MAT02046	ALU0341	IA406-B	35.33	46	Failed	27	29	50
MAT00218	ALU0037	IA302-B	17.67	88	Failed	22	4	27
MAT05673	ALU0946	IA103-B	35.00	30	Failed	3	47	55
MAT03049	ALU0509	IA801-B	28.00	66	Failed	42	25	17
MAT01993	ALU0333	IA101-A	35.00	95	Failed	29	54	22
MAT04415	ALU0736	IA105-B	24.00	40	Failed	15	46	11
MAT05567	ALU0928	IA805-B	37.67	92	Failed	51	48	14
MAT03357	ALU0560	IA603-B	47.33	41	Failed	50	42	50
MAT02882	ALU0481	IA202-B	9.33	96	Failed	8	16	4
MAT02168	ALU0362	IA402-B	29.00	36	Failed	33	41	13
MAT04313	ALU0719	IA805-A	37.33	31	Failed	44	36	32
MAT03662	ALU0611	IA302-B	23.00	40	Failed	27	16	26
MAT02831	ALU0472	IA705-B	33.67	98	Failed	46	37	18
MAT02165	ALU0361	IA205-B	18.33	50	Failed	35	2	18
MAT03204	ALU0534	IA606-B	31.33	64	Failed	14	54	26
MAT01194	ALU0199	IA306-A	26.33	97	Failed	9	58	12
MAT00948	ALU0158	IA106-B	28.67	70	Failed	14	53	19
MAT01220	ALU0204	IA802-B	22.33	41	Failed	17	22	28
MAT01506	ALU0251	IA506-A	26.00	82	Failed	8	19	51
MAT01673	ALU0279	IA205-B	52.67	36	Failed	53	48	57
MAT02480	ALU0414	IA502-A	21.33	78	Failed	15	25	24
MAT02411	ALU0402	IA305-A	35.33	85	Failed	15	50	41
MAT01831	ALU0306	IA501-A	9.00	47	Failed	19	8	0
MAT01774	ALU0296	IA804-A	26.33	77	Failed	31	19	29
MAT03386	ALU0565	IA702-B	17.00	99	Failed	0	9	42
MAT02008	ALU0335	IA504-B	22.33	59	Failed	3	21	43
MAT02173	ALU0363	IA801-B	27.00	66	Failed	59	2	20
MAT00507	ALU0085	IA303-B	47.67	78	Failed	43	54	46
MAT01967	ALU0328	IA205-B	30.67	32	Failed	33	3	56
MAT02174	ALU0363	IA802-B	7.33	35	Failed	0	16	6
MAT01144	ALU0191	IA604-A	45.33	42	Failed	51	36	49
MAT02009	ALU0335	IA505-B	45.67	77	Failed	57	42	38
MAT03092	ALU0516	IA602-A	18.00	72	Failed	22	7	25
MAT05456	ALU0910	IA302-A	28.00	75	Failed	29	38	17
MAT03020	ALU0504	IA502-B	28.00	71	Failed	8	51	25
MAT02849	ALU0475	IA805-B	29.67	34	Failed	4	34	51
MAT05580	ALU0930	IA106-A	41.33	63	Failed	34	57	33
MAT05400	ALU0900	IA306-A	44.00	81	Failed	52	38	42
MAT03060	ALU0510	IA606-B	21.67	30	Failed	7	41	17
MAT00403	ALU0068	IA101-A	14.67	90	Failed	8	29	7
MAT04184	ALU0698	IA602-B	30.00	34	Failed	3	33	54
MAT05074	ALU0846	IA204-A	35.67	98	Failed	50	14	43
MAT01792	ALU0299	IA204-A	15.00	99	Failed	14	13	18
MAT05443	ALU0908	IA701-B	25.67	60	Failed	31	33	13
MAT02419	ALU0404	IA301-B	34.33	83	Failed	31	43	29
MAT04512	ALU0752	IA406-B	23.00	34	Failed	43	13	13
MAT03392	ALU0566	IA602-B	23.67	86	Failed	45	10	16
MAT01551	ALU0259	IA403-A	33.00	68	Failed	32	16	51
MAT00975	ALU0163	IA603-B	22.67	53	Failed	31	17	20
MAT01497	ALU0250	IA303-B	26.00	69	Failed	11	48	19
MAT03996	ALU0666	IA806-B	41.00	47	Failed	15	57	51
MAT03453	ALU0576	IA503-A	25.00	62	Failed	28	1	46
MAT02261	ALU0377	IA105-A	46.00	59	Failed	46	58	34
MAT02972	ALU0496	IA402-A	22.33	61	Failed	39	11	17
MAT05392	ALU0899	IA704-B	12.00	95	Failed	0	9	27
MAT03943	ALU0658	IA801-B	31.67	94	Failed	38	7	50
MAT04409	ALU0735	IA405-A	20.00	58	Failed	9	10	41
MAT01038	ALU0173	IA306-A	37.67	33	Failed	43	24	46
MAT00603	ALU0101	IA203-A	32.67	41	Failed	50	18	30
MAT02512	ALU0419	IA504-B	26.33	55	Failed	22	24	33
MAT04401	ALU0734	IA203-B	28.67	48	Failed	35	11	40
MAT05470	ALU0912	IA604-B	9.67	67	Failed	5	21	3
MAT05153	ALU0859	IA205-B	25.00	72	Failed	13	58	4
MAT02600	ALU0434	IA702-A	46.00	49	Failed	45	38	55
MAT00717	ALU0120	IA803-B	13.67	82	Failed	18	22	1
MAT01070	ALU0179	IA102-B	26.00	71	Failed	25	22	31
MAT03457	ALU0577	IA801-A	36.00	96	Failed	14	56	38
MAT03438	ALU0573	IA306-B	23.67	80	Failed	10	15	46
MAT04412	ALU0736	IA102-B	16.67	93	Failed	15	15	20
MAT03270	ALU0545	IA406-B	29.67	69	Failed	7	47	35
MAT00413	ALU0069	IA105-A	38.33	30	Failed	50	48	17
MAT05494	ALU0916	IA404-B	37.33	67	Failed	47	51	14
MAT00142	ALU0024	IA204-B	34.33	69	Failed	29	41	33
MAT05710	ALU0952	IA204-B	29.67	56	Failed	27	39	23
MAT05293	ALU0883	IA701-B	29.67	68	Failed	57	3	29
MAT01565	ALU0261	IA105-A	45.33	93	Failed	48	47	41
MAT02864	ALU0478	IA402-B	14.00	67	Failed	18	22	2
MAT00969	ALU0162	IA403-B	34.67	64	Failed	7	45	52
MAT01591	ALU0266	IA801-A	25.67	65	Failed	37	2	38
MAT03792	ALU0632	IA806-B	40.67	93	Failed	57	46	19
MAT02212	ALU0369	IA304-B	31.00	38	Failed	19	47	27
MAT04246	ALU0708	IA804-B	16.67	36	Failed	31	16	3
MAT05957	ALU0993	IA405-B	26.00	93	Failed	16	44	18
MAT05393	ALU0899	IA705-B	25.67	82	Failed	23	20	34
MAT00950	ALU0159	IA302-B	35.00	39	Failed	56	12	37
MAT02503	ALU0418	IA601-B	29.00	82	Failed	25	37	25
MAT00354	ALU0059	IA406-B	38.33	87	Failed	59	51	5
MAT01590	ALU0265	IA306-B	11.33	56	Failed	14	8	12
MAT03416	ALU0570	IA402-B	47.00	81	Failed	52	50	39
MAT01872	ALU0312	IA806-A	38.33	80	Failed	33	58	24
MAT00997	ALU0167	IA701-B	42.67	78	Failed	43	39	46
MAT04292	ALU0716	IA102-B	20.00	84	Failed	15	24	21
MAT02706	ALU0451	IA406-B	36.33	53	Failed	44	53	12
MAT01562	ALU0261	IA102-A	27.33	32	Failed	14	32	36
MAT01488	ALU0248	IA406-B	22.00	84	Failed	1	16	49
MAT05526	ALU0921	IA706-A	14.33	62	Failed	4	21	18
MAT03916	ALU0653	IA604-B	24.33	67	Failed	54	17	2
MAT03191	ALU0532	IA205-A	33.00	78	Failed	54	8	37
MAT02590	ALU0432	IA204-A	34.33	95	Failed	44	47	12
MAT00730	ALU0122	IA504-B	32.33	57	Failed	10	41	46
MAT05441	ALU0907	IA205-B	37.67	33	Failed	45	40	28
MAT01685	ALU0281	IA105-B	29.00	90	Failed	8	47	32
MAT01596	ALU0266	IA806-A	30.33	59	Failed	47	10	34
MAT03537	ALU0590	IA103-B	33.33	41	Failed	25	44	31
MAT01951	ALU0326	IA701-A	31.00	64	Failed	7	38	48
MAT02332	ALU0389	IA704-B	33.33	95	Failed	25	37	38
MAT03501	ALU0584	IA103-A	36.67	71	Failed	45	37	28
MAT00739	ALU0124	IA801-B	23.67	54	Failed	5	16	50
MAT03666	ALU0611	IA306-B	31.33	49	Failed	23	53	18
MAT01077	ALU0180	IA503-B	8.33	39	Failed	17	3	5
MAT01322	ALU0221	IA802-B	35.33	68	Failed	24	36	46
MAT00215	ALU0036	IA205-A	14.00	47	Failed	16	26	0
MAT00490	ALU0082	IA104-A	31.00	79	Failed	58	6	29
MAT05713	ALU0953	IA401-B	46.00	51	Failed	49	38	51
MAT03056	ALU0510	IA602-B	39.67	54	Failed	23	40	56
MAT04978	ALU0830	IA204-B	23.00	32	Failed	4	40	25
MAT03793	ALU0633	IA301-A	18.67	90	Failed	18	24	14
MAT02105	ALU0351	IA505-B	35.33	56	Failed	27	36	43
MAT04193	ALU0699	IA805-B	34.00	91	Failed	53	18	31
MAT00614	ALU0103	IA802-B	40.00	54	Failed	6	58	56
MAT03970	ALU0662	IA104-B	37.33	100	Failed	15	42	55
MAT00448	ALU0075	IA504-B	36.67	73	Failed	47	58	5
MAT05683	ALU0948	IA201-B	31.33	97	Failed	17	31	46
MAT00721	ALU0121	IA501-B	29.00	62	Failed	12	30	45
MAT02660	ALU0444	IA802-B	38.67	76	Failed	51	33	32
MAT00916	ALU0153	IA204-B	29.33	56	Failed	6	23	59
MAT03103	ALU0518	IA101-B	32.00	31	Failed	28	32	36
MAT05492	ALU0916	IA402-B	20.67	84	Failed	7	55	0
MAT00815	ALU0136	IA305-A	43.00	77	Failed	56	57	16
MAT02133	ALU0356	IA803-B	28.00	58	Failed	40	9	35
MAT00361	ALU0061	IA801-B	25.67	98	Failed	52	8	17
MAT01352	ALU0226	IA302-A	34.67	70	Failed	40	6	58
MAT00631	ALU0106	IA501-B	32.33	68	Failed	12	41	44
MAT05332	ALU0889	IA504-B	23.33	37	Failed	30	22	18
MAT05455	ALU0910	IA301-A	27.67	89	Failed	45	10	28
MAT05718	ALU0953	IA406-B	31.67	50	Failed	29	51	15
MAT03979	ALU0664	IA101-B	32.00	81	Failed	59	30	7
MAT02343	ALU0391	IA703-A	32.67	96	Failed	48	41	9
MAT01330	ALU0222	IA704-B	23.67	85	Failed	21	33	17
MAT05700	ALU0950	IA206-A	29.67	53	Failed	34	9	46
MAT01855	ALU0310	IA501-B	21.67	30	Failed	21	16	28
MAT02788	ALU0465	IA504-A	15.67	83	Failed	21	15	11
MAT02606	ALU0435	IA602-B	22.67	41	Failed	11	14	43
MAT00956	ALU0160	IA502-A	13.00	36	Failed	14	15	10
MAT00273	ALU0046	IA503-B	39.33	51	Failed	38	35	45
MAT01510	ALU0252	IA704-A	35.33	64	Failed	3	58	45
MAT02712	ALU0452	IA406-B	20.33	79	Failed	17	34	10
MAT03664	ALU0611	IA304-B	24.67	48	Failed	17	22	35
MAT01489	ALU0249	IA201-A	29.33	54	Failed	13	22	53
MAT01840	ALU0307	IA404-A	38.33	96	Failed	44	40	31
MAT02802	ALU0467	IA306-B	20.33	63	Failed	27	25	9
MAT05101	ALU0851	IA301-A	22.33	67	Failed	17	27	23
MAT05317	ALU0887	IA601-B	21.00	49	Failed	14	37	12
MAT03723	ALU0621	IA403-B	23.67	88	Failed	46	2	23
MAT05491	ALU0916	IA401-B	26.33	99	Failed	34	14	31
MAT05380	ALU0897	IA504-B	29.00	52	Failed	1	40	46
MAT00545	ALU0091	IA605-B	41.00	100	Failed	39	52	32
MAT03023	ALU0504	IA505-B	29.33	56	Failed	26	16	46
MAT01267	ALU0212	IA401-B	21.67	81	Failed	18	4	43
MAT00972	ALU0162	IA406-B	7.00	53	Failed	1	1	19
MAT02848	ALU0475	IA804-B	40.33	80	Failed	39	57	25
MAT01535	ALU0256	IA505-A	34.33	33	Failed	29	46	28
MAT03078	ALU0513	IA206-A	34.33	65	Failed	47	41	15
MAT02868	ALU0478	IA406-B	16.67	54	Failed	15	27	8
MAT00194	ALU0033	IA202-B	28.00	62	Failed	46	14	24
MAT05237	ALU0873	IA305-B	16.00	84	Failed	1	13	34
MAT00049	ALU0009	IA201-A	30.00	80	Failed	53	23	14
MAT03507	ALU0585	IA703-A	18.67	77	Failed	37	11	8
MAT02806	ALU0468	IA204-B	39.00	87	Failed	44	55	18
MAT03412	ALU0569	IA104-B	40.00	35	Failed	34	53	33
MAT00499	ALU0084	IA201-B	36.67	36	Failed	27	31	52
MAT04824	ALU0804	IA506-B	24.67	83	Failed	34	29	11
MAT01049	ALU0175	IA305-B	18.67	80	Failed	18	36	2
MAT04280	ALU0714	IA802-B	38.67	32	Failed	43	50	23
MAT01574	ALU0263	IA802-B	20.33	32	Failed	1	36	24
MAT00649	ALU0109	IA201-A	24.67	38	Failed	29	10	35
MAT05374	ALU0896	IA604-B	25.33	80	Failed	4	38	34
MAT02992	ALU0499	IA304-B	36.00	80	Failed	36	49	23
MAT01661	ALU0277	IA105-A	21.33	70	Failed	7	34	23
MAT01992	ALU0332	IA706-B	29.67	43	Failed	13	47	29
MAT04636	ALU0773	IA104-B	40.00	100	Failed	6	59	55
MAT04876	ALU0813	IA504-A	24.00	89	Failed	1	59	12
MAT00180	ALU0030	IA706-B	30.67	69	Failed	58	6	28
MAT01323	ALU0221	IA803-B	39.33	42	Failed	40	56	22
MAT01965	ALU0328	IA203-B	40.00	84	Failed	55	40	25
MAT00794	ALU0133	IA702-B	22.00	86	Failed	19	12	35
MAT01299	ALU0217	IA503-B	40.00	84	Failed	27	37	56
MAT03180	ALU0530	IA806-B	27.33	31	Failed	7	30	45
MAT02796	ALU0466	IA606-B	24.00	57	Failed	20	8	44
MAT05359	ALU0894	IA301-B	31.67	30	Failed	22	54	19
MAT02722	ALU0454	IA604-B	21.00	41	Failed	31	11	21
MAT03264	ALU0544	IA506-A	34.33	62	Failed	6	52	45
MAT04724	ALU0788	IA102-A	32.00	50	Failed	39	41	16
MAT00434	ALU0073	IA602-B	22.00	35	Failed	20	14	32
MAT00943	ALU0158	IA101-B	13.33	73	Failed	16	21	3
MAT00890	ALU0149	IA402-A	18.67	52	Failed	15	30	11
MAT03997	ALU0667	IA601-A	38.67	86	Failed	49	47	20
MAT04194	ALU0699	IA806-B	24.67	58	Failed	37	14	23
MAT02693	ALU0449	IA805-A	30.33	56	Failed	57	28	6
MAT02820	ALU0470	IA206-B	24.33	85	Failed	40	33	0
MAT02233	ALU0373	IA601-B	12.67	79	Failed	26	6	6
MAT05233	ALU0873	IA301-B	37.67	67	Failed	21	37	55
MAT01783	ALU0298	IA801-B	27.67	32	Failed	7	43	33
MAT05937	ALU0990	IA103-A	36.00	55	Failed	41	49	18
MAT01100	ALU0184	IA302-A	27.67	95	Failed	37	36	10
MAT01715	ALU0286	IA205-A	53.00	53	Failed	50	55	54
MAT03080	ALU0514	IA202-B	42.67	77	Failed	26	59	43
MAT05405	ALU0901	IA205-A	18.33	32	Failed	49	0	6
MAT01005	ALU0168	IA403-A	23.67	32	Failed	13	45	13
MAT02292	ALU0382	IA206-A	36.00	92	Failed	10	43	55
MAT04088	ALU0682	IA402-B	43.00	43	Failed	47	45	37
MAT02293	ALU0383	IA501-A	16.33	77	Failed	22	10	17
MAT04411	ALU0736	IA101-B	31.67	48	Failed	27	31	37
MAT02783	ALU0464	IA305-B	15.00	51	Failed	11	22	12
MAT03649	ALU0609	IA301-A	45.67	93	Failed	47	59	31
MAT02229	ALU0372	IA803-B	24.33	82	Failed	5	33	35
MAT00613	ALU0103	IA801-B	32.33	59	Failed	22	19	56
MAT05505	ALU0918	IA803-A	36.67	55	Failed	26	43	41
MAT03387	ALU0565	IA703-B	16.67	64	Failed	0	21	29
MAT00851	ALU0142	IA605-B	43.00	58	Failed	39	41	49
MAT03578	ALU0597	IA702-A	21.33	45	Failed	5	11	48
MAT03480	ALU0580	IA306-A	48.33	57	Failed	49	37	59
MAT03323	ALU0554	IA305-B	33.67	56	Failed	34	52	15
MAT02278	ALU0380	IA104-B	23.00	41	Failed	8	42	19
MAT02811	ALU0469	IA603-B	31.67	100	Failed	50	20	25
MAT03682	ALU0614	IA704-A	12.00	87	Failed	4	1	31
MAT02060	ALU0344	IA402-B	37.33	72	Failed	51	35	26
MAT03619	ALU0604	IA401-A	39.67	43	Failed	17	45	57
MAT02288	ALU0382	IA202-A	14.67	87	Failed	5	24	15
MAT02812	ALU0469	IA604-B	33.33	93	Failed	32	12	56
MAT04850	ALU0809	IA302-A	37.00	38	Failed	32	50	29
MAT03098	ALU0517	IA602-B	22.67	43	Failed	28	32	8
MAT04628	ALU0772	IA802-B	16.00	36	Failed	20	19	9
MAT01245	ALU0208	IA103-A	40.67	87	Failed	40	27	55
MAT04053	ALU0676	IA103-B	29.00	52	Failed	56	10	21
MAT02482	ALU0414	IA504-A	21.67	96	Failed	8	10	47
MAT05529	ALU0922	IA503-B	22.67	73	Failed	44	6	18
MAT04385	ALU0731	IA805-B	26.67	62	Failed	38	37	5
MAT01400	ALU0234	IA202-A	42.33	31	Failed	55	14	58
MAT03448	ALU0575	IA404-A	29.00	82	Failed	28	14	45
MAT02020	ALU0337	IA304-B	18.67	43	Failed	10	19	27
MAT02674	ALU0446	IA204-B	22.33	34	Failed	1	38	28
MAT03843	ALU0641	IA803-B	37.67	32	Failed	33	35	45
MAT02988	ALU0498	IA306-B	40.33	44	Failed	58	39	24
MAT03805	ALU0635	IA401-B	20.00	53	Failed	3	5	52
MAT03079	ALU0514	IA201-B	38.33	31	Failed	35	57	23
MAT03188	ALU0532	IA202-A	33.00	79	Failed	32	16	51
MAT01727	ALU0288	IA205-B	23.67	56	Failed	47	6	18
MAT05634	ALU0939	IA106-B	13.33	62	Failed	14	16	10
MAT01160	ALU0194	IA502-A	27.00	92	Failed	18	24	39
MAT05129	ALU0855	IA405-B	37.00	84	Failed	45	41	25
MAT05143	ALU0858	IA201-B	32.67	63	Failed	36	42	20
MAT05737	ALU0957	IA501-B	28.33	88	Failed	34	51	0
MAT02852	ALU0476	IA402-B	20.33	99	Failed	48	3	10
MAT05475	ALU0913	IA203-B	28.00	47	Failed	40	39	5
MAT00433	ALU0073	IA601-B	43.00	38	Failed	42	53	34
MAT05383	ALU0898	IA101-B	25.67	32	Failed	36	41	0
MAT02308	ALU0385	IA504-B	40.00	57	Failed	22	59	39
MAT05490	ALU0915	IA706-B	29.67	74	Failed	21	11	57
MAT04353	ALU0726	IA703-B	9.00	58	Failed	10	7	10
MAT02876	ALU0480	IA302-A	37.00	100	Failed	16	36	59
MAT04983	ALU0831	IA503-B	20.67	34	Failed	44	5	13
MAT05034	ALU0839	IA206-B	30.67	35	Failed	32	1	59
MAT02128	ALU0355	IA504-B	39.67	88	Failed	19	47	53
MAT03890	ALU0649	IA302-B	32.00	60	Failed	46	6	44
MAT02687	ALU0448	IA505-A	38.67	60	Failed	48	53	15
MAT00387	ALU0065	IA703-A	23.33	36	Failed	12	33	25
MAT04655	ALU0776	IA405-B	25.67	99	Failed	35	19	23
MAT05264	ALU0878	IA802-B	23.00	38	Failed	13	23	33
MAT03088	ALU0515	IA204-B	23.67	39	Failed	22	41	8
MAT02954	ALU0493	IA302-A	19.33	72	Failed	9	21	28
MAT04111	ALU0686	IA301-B	31.67	63	Failed	57	14	24
MAT05188	ALU0865	IA404-B	34.33	36	Failed	26	32	45
MAT05754	ALU0959	IA606-B	28.67	39	Failed	32	8	46
MAT05681	ALU0947	IA805-A	30.33	99	Failed	35	42	14
MAT05969	ALU0995	IA605-B	46.00	92	Failed	30	51	57
MAT03245	ALU0541	IA605-A	38.67	69	Failed	35	42	39
MAT00698	ALU0117	IA502-A	27.33	49	Failed	12	21	49
MAT01188	ALU0198	IA406-A	27.67	53	Failed	39	12	32
MAT05469	ALU0912	IA603-B	36.00	57	Failed	41	38	29
MAT05571	ALU0929	IA803-A	32.33	71	Failed	29	17	51
MAT01864	ALU0311	IA404-A	25.33	56	Failed	23	48	5
MAT03517	ALU0587	IA801-A	23.67	92	Failed	1	56	14
MAT00408	ALU0068	IA106-A	20.00	95	Failed	21	26	13
MAT03269	ALU0545	IA405-B	34.67	92	Failed	33	35	36
MAT03035	ALU0506	IA605-B	41.00	77	Failed	56	53	14
MAT04648	ALU0775	IA804-B	25.00	55	Failed	18	50	7
MAT05671	ALU0946	IA101-B	26.00	89	Failed	40	7	31
MAT00676	ALU0113	IA704-B	16.00	91	Failed	3	19	26
MAT02258	ALU0377	IA102-A	34.67	69	Failed	24	46	34
MAT00803	ALU0134	IA505-A	38.67	30	Failed	58	4	54
MAT00523	ALU0088	IA801-B	33.00	33	Failed	9	54	36
MAT03437	ALU0573	IA305-B	21.33	65	Failed	3	51	10
MAT05498	ALU0917	IA202-B	39.33	93	Failed	39	27	52
MAT01609	ALU0269	IA601-B	25.33	38	Failed	49	25	2
MAT00402	ALU0067	IA606-B	23.33	74	Failed	9	53	8
MAT01842	ALU0307	IA406-A	2.00	86	Failed	4	0	2
MAT02062	ALU0344	IA404-B	44.67	48	Failed	23	52	59
MAT05610	ALU0935	IA506-A	11.00	54	Failed	16	3	14
MAT00416	ALU0070	IA102-B	27.00	79	Failed	21	51	9
MAT00526	ALU0088	IA804-B	30.67	84	Failed	50	39	3
MAT04185	ALU0698	IA603-B	16.33	93	Failed	13	8	28
MAT03634	ALU0606	IA304-B	28.00	95	Failed	11	24	49
MAT01009	ALU0169	IA201-B	33.67	57	Failed	35	20	46
MAT04164	ALU0694	IA306-B	48.33	76	Failed	45	48	52
MAT05087	ALU0848	IA105-A	16.67	60	Failed	43	2	5
MAT00772	ALU0129	IA604-B	27.00	71	Failed	0	58	23
MAT05512	ALU0919	IA104-A	37.67	61	Failed	53	59	1
MAT00655	ALU0110	IA201-B	19.33	38	Failed	52	3	3
MAT01720	ALU0287	IA504-A	44.00	86	Failed	58	22	52
MAT02216	ALU0370	IA602-B	44.00	89	Failed	48	29	55
MAT03325	ALU0555	IA301-B	38.67	83	Failed	59	34	23
MAT00941	ALU0157	IA205-A	45.67	40	Failed	45	47	45
MAT05406	ALU0901	IA206-A	33.67	49	Failed	51	33	17
MAT04277	ALU0713	IA305-A	21.33	96	Failed	8	9	47
MAT01164	ALU0194	IA506-A	23.00	45	Failed	8	27	34
MAT00893	ALU0149	IA405-A	19.33	87	Failed	28	28	2
MAT05938	ALU0990	IA104-A	30.33	85	Failed	52	10	29
MAT05446	ALU0908	IA704-B	4.33	33	Failed	4	0	9
MAT01844	ALU0308	IA102-A	44.00	43	Failed	51	23	58
MAT01589	ALU0265	IA305-B	35.00	50	Failed	9	38	58
MAT01189	ALU0199	IA301-A	44.67	39	Failed	56	37	41
MAT05044	ALU0841	IA604-B	23.67	43	Failed	31	16	24
MAT05024	ALU0838	IA502-A	33.67	71	Failed	37	25	39
MAT03280	ALU0547	IA604-A	27.00	79	Failed	45	35	1
MAT04953	ALU0826	IA603-B	34.00	42	Failed	45	54	3
MAT02553	ALU0426	IA503-B	36.00	43	Failed	58	5	45
MAT03569	ALU0595	IA405-A	24.00	52	Failed	12	13	47
MAT04890	ALU0815	IA206-A	43.00	61	Failed	33	49	47
MAT00858	ALU0143	IA206-A	7.00	46	Failed	3	16	2
MAT01269	ALU0212	IA403-B	27.67	44	Failed	14	57	12
MAT03991	ALU0666	IA801-B	31.00	43	Failed	29	32	32
MAT02245	ALU0375	IA601-A	13.67	99	Failed	4	0	37
MAT02678	ALU0447	IA102-B	33.67	38	Failed	47	29	25
MAT03105	ALU0518	IA103-B	19.33	42	Failed	36	8	14
MAT00244	ALU0041	IA304-A	14.00	43	Failed	7	35	0
MAT04469	ALU0745	IA305-B	38.00	81	Failed	25	45	44
MAT01404	ALU0234	IA206-A	22.67	72	Failed	45	0	23
MAT05401	ALU0901	IA201-A	24.00	34	Failed	13	11	48
MAT05544	ALU0924	IA606-B	22.33	88	Failed	28	0	39
MAT02267	ALU0378	IA605-B	40.67	49	Failed	38	51	33
MAT01986	ALU0331	IA406-A	45.33	47	Failed	35	50	51
MAT00144	ALU0024	IA206-B	37.00	90	Failed	19	53	39
MAT00415	ALU0070	IA101-B	13.00	51	Failed	14	22	3
MAT03189	ALU0532	IA203-A	36.33	50	Failed	52	3	54
MAT04875	ALU0813	IA503-A	47.67	39	Failed	34	55	54
MAT00362	ALU0061	IA802-B	53.00	51	Failed	54	51	54
MAT00439	ALU0074	IA301-B	23.00	56	Failed	6	24	39
MAT00825	ALU0138	IA203-A	20.33	83	Failed	4	10	47
MAT01211	ALU0202	IA605-B	31.67	38	Failed	5	52	38
MAT01447	ALU0242	IA401-A	30.33	69	Failed	4	38	49
MAT00455	ALU0076	IA805-B	32.00	58	Failed	23	56	17
MAT05568	ALU0928	IA806-B	41.33	47	Failed	56	22	46
MAT03143	ALU0524	IA205-B	34.67	90	Failed	57	32	15
MAT01066	ALU0178	IA604-B	28.00	38	Failed	21	12	51
MAT02741	ALU0457	IA705-A	50.33	46	Failed	59	41	51
MAT05000	ALU0834	IA102-B	27.67	41	Failed	14	18	51
MAT02666	ALU0445	IA802-B	14.00	72	Failed	10	6	26
MAT02628	ALU0438	IA106-B	16.67	44	Failed	12	33	5
MAT01093	ALU0183	IA801-B	34.67	49	Failed	15	31	58
MAT03898	ALU0650	IA804-B	27.00	43	Failed	18	38	25
MAT05953	ALU0993	IA401-B	21.00	39	Failed	33	4	26
MAT02099	ALU0350	IA805-B	40.00	69	Failed	54	49	17
MAT05476	ALU0913	IA204-B	25.33	75	Failed	15	53	8
MAT04404	ALU0734	IA206-B	16.33	53	Failed	11	15	23
MAT03763	ALU0628	IA401-B	36.67	84	Failed	15	36	59
MAT00140	ALU0024	IA202-B	38.00	68	Failed	37	18	59
MAT05985	ALU0998	IA703-B	36.67	77	Failed	35	58	17
MAT01899	ALU0317	IA803-A	8.33	65	Failed	15	9	1
MAT01185	ALU0198	IA403-A	17.33	83	Failed	12	10	30
MAT05764	ALU0961	IA304-B	19.00	60	Failed	12	28	17
MAT05793	ALU0966	IA603-B	20.00	92	Failed	40	20	0
MAT03496	ALU0583	IA104-A	34.00	81	Failed	43	50	9
MAT05835	ALU0973	IA403-A	22.33	32	Failed	5	45	17
MAT05514	ALU0919	IA106-A	26.00	87	Failed	1	21	56
MAT00564	ALU0094	IA606-A	40.67	96	Failed	44	33	45
MAT03202	ALU0534	IA604-B	20.67	37	Failed	36	12	14
MAT02789	ALU0465	IA505-A	21.67	89	Failed	8	18	39
MAT00995	ALU0166	IA105-B	27.00	83	Failed	4	40	37
MAT04012	ALU0669	IA304-A	40.00	55	Failed	43	39	38
MAT04160	ALU0694	IA302-B	18.00	51	Failed	14	37	3
MAT01053	ALU0176	IA203-B	26.00	44	Failed	55	19	4
MAT03832	ALU0639	IA304-B	38.33	57	Failed	15	53	47
MAT00146	ALU0025	IA702-B	42.00	42	Failed	58	22	46
MAT05200	ALU0867	IA804-B	30.67	93	Failed	31	29	32
MAT03230	ALU0539	IA702-B	29.33	61	Failed	22	54	12
MAT03552	ALU0592	IA606-B	44.67	37	Failed	51	32	51
MAT05440	ALU0907	IA204-B	40.00	82	Failed	50	49	21
MAT03842	ALU0641	IA802-B	14.67	64	Failed	12	6	26
MAT01505	ALU0251	IA505-A	24.67	45	Failed	25	38	11
MAT05837	ALU0973	IA405-A	31.33	45	Failed	33	29	32
MAT00472	ALU0079	IA404-B	7.67	91	Failed	4	13	6
MAT02296	ALU0383	IA504-A	17.00	74	Failed	32	1	18
MAT00726	ALU0121	IA506-B	26.33	35	Failed	5	16	58
MAT02949	ALU0492	IA703-B	34.33	33	Failed	18	26	59
MAT03789	ALU0632	IA803-B	30.00	41	Failed	11	38	41
MAT00525	ALU0088	IA803-B	30.67	46	Failed	16	47	29
MAT01335	ALU0223	IA403-B	44.67	71	Failed	36	51	47
MAT04174	ALU0696	IA704-B	8.33	87	Failed	14	8	3
MAT02901	ALU0484	IA203-B	25.33	43	Failed	5	15	56
MAT02870	ALU0479	IA402-B	35.33	54	Failed	27	42	37
MAT01500	ALU0250	IA306-B	34.67	88	Failed	54	43	7
MAT02019	ALU0337	IA303-B	21.67	62	Failed	14	39	12
MAT02396	ALU0400	IA402-B	50.67	90	Failed	54	40	58
MAT05579	ALU0930	IA105-A	36.33	87	Failed	41	17	51
MAT05468	ALU0912	IA602-B	44.00	55	Failed	39	36	57
MAT03893	ALU0649	IA305-B	28.33	90	Failed	54	3	28
MAT05113	ALU0853	IA401-B	40.33	69	Failed	13	56	52
MAT00913	ALU0153	IA201-B	37.67	80	Failed	40	55	18
MAT02879	ALU0480	IA305-A	34.67	87	Failed	35	55	14
MAT01065	ALU0178	IA603-B	29.67	42	Failed	35	5	49
MAT03110	ALU0519	IA502-B	50.00	75	Failed	52	57	41
MAT05386	ALU0898	IA104-B	31.00	34	Failed	28	29	36
MAT00985	ALU0165	IA501-B	23.00	97	Failed	3	35	31
MAT02294	ALU0383	IA502-A	41.00	82	Failed	58	22	43
MAT02243	ALU0374	IA305-B	38.67	53	Failed	7	54	55
MAT01296	ALU0216	IA206-A	19.67	76	Failed	38	10	11
MAT01371	ALU0229	IA203-A	18.33	31	Failed	26	0	29
MAT00841	ALU0141	IA801-B	34.67	72	Failed	32	21	51
MAT01254	ALU0209	IA306-B	25.33	86	Failed	56	15	5
MAT05244	ALU0874	IA206-B	34.67	82	Failed	54	48	2
MAT00241	ALU0041	IA301-A	19.67	76	Failed	17	8	34
MAT01948	ALU0325	IA604-B	39.67	83	Failed	39	22	58
MAT05110	ALU0852	IA704-A	23.67	93	Failed	31	33	7
MAT00618	ALU0103	IA806-B	16.00	67	Failed	8	31	9
MAT02847	ALU0475	IA803-B	25.67	80	Failed	33	4	40
MAT03131	ALU0522	IA405-B	36.67	70	Failed	57	24	29
MAT04462	ALU0744	IA304-B	27.33	32	Failed	12	39	31
MAT03132	ALU0522	IA406-B	35.00	82	Failed	24	59	22
MAT05453	ALU0909	IA405-B	13.67	47	Failed	4	19	18
MAT04857	ALU0810	IA803-B	19.33	68	Failed	39	2	17
MAT01129	ALU0189	IA801-A	30.33	99	Failed	44	27	20
MAT02118	ALU0353	IA306-B	20.67	72	Failed	27	25	10
MAT02636	ALU0440	IA502-A	29.33	62	Failed	53	8	27
MAT02909	ALU0485	IA305-B	26.00	35	Failed	14	8	56
MAT02231	ALU0372	IA805-B	33.67	86	Failed	35	52	14
MAT01820	ALU0304	IA802-B	39.67	63	Failed	49	46	24
MAT02543	ALU0424	IA605-A	28.67	40	Failed	27	23	36
MAT04835	ALU0806	IA305-A	36.00	70	Failed	59	43	6
MAT01226	ALU0205	IA602-A	21.00	38	Failed	35	14	14
MAT05125	ALU0855	IA401-B	10.00	50	Failed	22	5	3
MAT01861	ALU0311	IA401-A	38.00	63	Failed	21	41	52
MAT03490	ALU0582	IA204-B	37.00	40	Failed	45	16	50
MAT02633	ALU0439	IA805-B	37.67	86	Failed	41	27	45
MAT02558	ALU0427	IA402-B	11.67	46	Failed	22	1	12
MAT02491	ALU0416	IA801-B	19.33	95	Failed	30	16	12
MAT03801	ALU0634	IA303-B	32.00	85	Failed	16	47	33
MAT05081	ALU0847	IA805-A	27.00	90	Failed	8	51	22
MAT05799	ALU0967	IA403-B	27.00	71	Failed	25	16	40
MAT00666	ALU0111	IA806-A	41.33	68	Failed	48	36	40
MAT03591	ALU0599	IA703-B	14.00	97	Failed	3	12	27
MAT01611	ALU0269	IA603-B	33.00	50	Failed	52	9	38
MAT02200	ALU0367	IA804-B	39.00	51	Failed	59	24	34
MAT00460	ALU0077	IA404-A	46.00	93	Failed	54	40	44
MAT04720	ALU0787	IA504-A	25.67	52	Failed	20	17	40
MAT03019	ALU0504	IA501-B	31.67	59	Failed	35	3	57
MAT02899	ALU0484	IA201-B	29.67	59	Failed	28	40	21
MAT00497	ALU0083	IA105-B	24.67	53	Failed	27	26	21
MAT05266	ALU0878	IA804-B	46.00	45	Failed	35	59	44
MAT05051	ALU0842	IA505-B	32.33	72	Failed	41	45	11
MAT01566	ALU0261	IA106-A	30.33	76	Failed	31	4	56
MAT00283	ALU0048	IA801-A	15.00	63	Failed	2	21	22
MAT02878	ALU0480	IA304-A	29.67	70	Failed	37	37	15
MAT04555	ALU0760	IA501-B	40.33	95	Failed	38	29	54
MAT00414	ALU0069	IA106-A	32.33	31	Failed	22	22	53
MAT04177	ALU0697	IA201-B	16.33	87	Failed	24	1	24
MAT01959	ALU0327	IA103-A	25.67	84	Failed	23	29	25
MAT05267	ALU0878	IA805-B	3.67	92	Failed	0	4	7
MAT02686	ALU0448	IA504-A	47.00	37	Failed	36	51	54
MAT01054	ALU0176	IA204-B	30.67	36	Failed	28	45	19
MAT03157	ALU0527	IA201-A	38.00	37	Failed	56	17	41
MAT00141	ALU0024	IA203-B	30.33	54	Failed	49	13	29
MAT00197	ALU0033	IA205-B	32.00	84	Failed	23	40	33
MAT01996	ALU0333	IA104-A	36.33	61	Failed	52	21	36
MAT02923	ALU0488	IA401-B	29.33	52	Failed	26	44	18
MAT00233	ALU0039	IA205-B	32.67	45	Failed	46	6	46
MAT03370	ALU0562	IA404-B	20.00	86	Failed	21	14	25
MAT00495	ALU0083	IA103-B	29.00	98	Failed	17	43	27
MAT02976	ALU0496	IA406-A	14.67	32	Failed	33	6	5
MAT03213	ALU0536	IA303-B	10.00	67	Failed	24	5	1
MAT02979	ALU0497	IA603-B	35.00	40	Failed	50	1	54
MAT02786	ALU0465	IA502-A	16.67	82	Failed	24	18	8
MAT00148	ALU0025	IA704-B	36.33	69	Failed	48	26	35
MAT02371	ALU0396	IA501-B	37.67	93	Failed	33	55	25
MAT02312	ALU0386	IA602-A	14.00	33	Failed	11	6	25
MAT00323	ALU0054	IA405-A	26.00	36	Failed	30	22	26
MAT00929	ALU0155	IA105-A	8.00	53	Failed	18	3	3
MAT02304	ALU0384	IA206-B	23.00	47	Failed	50	8	11
MAT05171	ALU0862	IA505-B	4.33	57	Failed	0	1	12
MAT00007	ALU0002	IA101-B	24.00	83	Failed	29	29	14
MAT00786	ALU0131	IA806-A	40.33	90	Failed	44	28	49
MAT01925	ALU0321	IA205-B	30.00	68	Failed	38	18	34
MAT01863	ALU0311	IA403-A	27.00	63	Failed	31	32	18
MAT00131	ALU0022	IA405-A	22.00	69	Failed	3	51	12
MAT04187	ALU0698	IA605-B	25.67	90	Failed	27	37	13
MAT00075	ALU0013	IA703-A	24.00	55	Failed	50	19	3
MAT02192	ALU0366	IA302-B	14.67	33	Failed	6	1	37
MAT02790	ALU0465	IA506-A	28.00	48	Failed	19	34	31
MAT03845	ALU0641	IA805-B	27.33	90	Failed	15	43	24
MAT03679	ALU0614	IA701-A	22.00	80	Failed	19	33	14
MAT01251	ALU0209	IA303-B	26.33	81	Failed	22	5	52
MAT04334	ALU0723	IA202-A	15.00	100	Failed	40	4	1
MAT05463	ALU0911	IA503-A	25.33	31	Failed	9	34	33
MAT05169	ALU0862	IA503-B	38.33	53	Failed	47	53	15
MAT02929	ALU0489	IA601-A	17.33	62	Failed	7	12	33
MAT01377	ALU0230	IA803-B	20.33	66	Failed	10	17	34
MAT01586	ALU0265	IA302-B	37.67	35	Failed	54	0	59
MAT04484	ALU0748	IA602-B	22.00	62	Failed	11	18	37
MAT02940	ALU0490	IA406-B	46.00	51	Failed	34	51	53
MAT01217	ALU0203	IA105-A	35.33	50	Failed	23	31	52
MAT03742	ALU0624	IA704-B	30.67	83	Failed	56	8	28
MAT02659	ALU0444	IA801-B	16.33	53	Failed	43	2	4
MAT05390	ALU0899	IA702-B	17.33	73	Failed	10	24	18
MAT01743	ALU0291	IA103-B	26.67	75	Failed	34	23	23
MAT02568	ALU0428	IA206-A	35.33	84	Failed	38	18	50
MAT02773	ALU0463	IA601-A	33.33	95	Failed	12	58	30
MAT03036	ALU0506	IA606-B	20.67	41	Failed	2	38	22
MAT02309	ALU0385	IA505-B	39.67	75	Failed	55	14	50
MAT05381	ALU0897	IA505-B	16.67	45	Failed	27	20	3
MAT05795	ALU0966	IA605-B	54.33	38	Failed	55	49	59
MAT05674	ALU0946	IA104-B	26.33	80	Failed	9	53	17
MAT03152	ALU0526	IA502-B	33.33	50	Failed	29	40	31
MAT02114	ALU0353	IA302-B	31.00	83	Failed	44	12	37
MAT02155	ALU0360	IA201-A	45.00	91	Failed	50	56	29
MAT01026	ALU0171	IA106-A	43.00	100	Failed	55	28	46
MAT00708	ALU0118	IA806-B	35.67	33	Failed	22	26	59
MAT01784	ALU0298	IA802-B	34.67	60	Failed	45	44	15
MAT04179	ALU0697	IA203-B	25.00	99	Failed	10	15	50
MAT05770	ALU0962	IA304-B	24.67	43	Failed	28	13	33
MAT01455	ALU0243	IA303-A	48.33	84	Failed	52	56	37
MAT03931	ALU0656	IA401-B	34.33	92	Failed	36	22	45
MAT01830	ALU0305	IA306-B	34.33	69	Failed	29	15	59
MAT01517	ALU0253	IA605-B	26.67	87	Failed	4	57	19
MAT01295	ALU0216	IA205-A	23.00	89	Failed	1	46	22
MAT05144	ALU0858	IA202-B	32.67	97	Failed	53	10	35
MAT02519	ALU0420	IA605-A	16.67	45	Failed	4	31	15
MAT03040	ALU0507	IA304-B	88.33	95	Approved	94	100	71
MAT03123	ALU0521	IA503-B	22.33	66	Failed	44	16	7
MAT05140	ALU0857	IA404-A	21.33	63	Failed	40	16	8
MAT00417	ALU0070	IA103-B	30.00	58	Failed	12	31	47
MAT04013	ALU0669	IA305-A	29.00	55	Failed	20	24	43
MAT03650	ALU0609	IA302-A	25.67	59	Failed	14	49	14
MAT03484	ALU0581	IA304-B	47.67	87	Failed	57	35	51
MAT00478	ALU0080	IA204-A	33.67	64	Failed	57	26	18
MAT03066	ALU0511	IA606-B	44.00	45	Failed	44	30	58
MAT01796	ALU0300	IA702-B	45.67	67	Failed	52	45	40
MAT02217	ALU0370	IA603-B	33.00	43	Failed	26	47	26
MAT03029	ALU0505	IA605-A	39.33	73	Failed	16	57	45
MAT04364	ALU0728	IA402-B	18.00	73	Failed	2	11	41
MAT03735	ALU0623	IA603-A	14.67	38	Failed	14	16	14
MAT00611	ALU0102	IA505-A	21.00	64	Failed	13	14	36
MAT01791	ALU0299	IA203-A	17.67	94	Failed	18	17	18
MAT01084	ALU0181	IA704-B	29.00	72	Failed	58	15	14
MAT02496	ALU0416	IA806-B	24.00	87	Failed	8	53	11
MAT00648	ALU0108	IA406-A	18.67	95	Failed	51	3	2
MAT03866	ALU0645	IA602-B	37.33	60	Failed	29	24	59
MAT04944	ALU0824	IA306-B	20.33	41	Failed	19	2	40
MAT03439	ALU0574	IA501-A	28.33	86	Failed	39	15	31
MAT05928	ALU0988	IA206-B	33.67	35	Failed	22	34	45
MAT03740	ALU0624	IA702-B	25.00	64	Failed	38	12	25
MAT00168	ALU0028	IA306-B	39.33	91	Failed	55	29	34
MAT04538	ALU0757	IA202-A	22.67	57	Failed	28	4	36
MAT03083	ALU0514	IA205-B	23.33	84	Failed	39	12	19
MAT00304	ALU0051	IA104-A	39.67	50	Failed	23	40	56
MAT01667	ALU0278	IA505-B	43.00	80	Failed	25	52	52
MAT05199	ALU0867	IA803-B	36.67	84	Failed	52	24	34
MAT01002	ALU0167	IA706-B	35.00	61	Failed	5	53	47
MAT00931	ALU0156	IA601-A	29.33	96	Failed	39	42	7
MAT03344	ALU0558	IA102-B	35.33	76	Failed	34	52	20
MAT03570	ALU0595	IA406-A	42.00	99	Failed	15	53	58
MAT00592	ALU0099	IA404-B	42.33	83	Failed	59	43	25
MAT03404	ALU0568	IA702-A	16.67	60	Failed	21	24	5
MAT02957	ALU0493	IA305-A	32.00	75	Failed	2	36	58
MAT05482	ALU0914	IA604-A	34.00	30	Failed	32	48	22
MAT05071	ALU0846	IA201-A	22.67	71	Failed	26	41	1
MAT04232	ALU0706	IA702-B	23.00	50	Failed	26	13	30
MAT05539	ALU0924	IA601-B	41.67	45	Failed	41	29	55
MAT05954	ALU0993	IA402-B	38.33	54	Failed	55	14	46
MAT02075	ALU0346	IA705-B	20.00	50	Failed	6	25	29
MAT01637	ALU0273	IA405-A	36.67	59	Failed	13	51	46
MAT01464	ALU0244	IA306-B	23.67	49	Failed	8	54	9
MAT00813	ALU0136	IA303-A	40.33	49	Failed	53	23	45
MAT05128	ALU0855	IA404-B	39.33	32	Failed	12	55	51
MAT02682	ALU0447	IA106-B	29.00	65	Failed	24	28	35
MAT00784	ALU0131	IA804-A	29.33	42	Failed	45	18	25
MAT00869	ALU0145	IA705-B	20.00	43	Failed	25	23	12
MAT04056	ALU0676	IA106-B	46.67	34	Failed	46	58	36
MAT03548	ALU0592	IA602-B	36.00	56	Failed	16	42	50
MAT05178	ALU0863	IA606-B	24.33	75	Failed	41	28	4
MAT04275	ALU0713	IA303-A	36.33	39	Failed	3	53	53
MAT02751	ALU0459	IA703-A	36.33	93	Failed	40	16	53
MAT05662	ALU0944	IA104-B	31.33	64	Failed	46	48	0
MAT01252	ALU0209	IA304-B	14.67	74	Failed	23	0	21
MAT00534	ALU0089	IA206-A	24.00	62	Failed	13	52	7
MAT01501	ALU0251	IA501-A	37.33	99	Failed	50	41	21
MAT03420	ALU0570	IA406-B	19.67	37	Failed	8	44	7
MAT03431	ALU0572	IA205-A	37.67	49	Failed	54	10	49
MAT04437	ALU0740	IA803-B	32.67	58	Failed	14	31	53
MAT00930	ALU0155	IA106-A	44.67	96	Failed	33	46	55
MAT04192	ALU0699	IA804-B	40.67	99	Failed	37	38	47
MAT02710	ALU0452	IA404-B	32.67	98	Failed	5	34	59
MAT02707	ALU0452	IA401-B	41.33	100	Failed	37	29	58
MAT03646	ALU0608	IA504-B	32.00	61	Failed	23	14	59
MAT01876	ALU0313	IA804-A	19.33	46	Failed	10	27	21
MAT00855	ALU0143	IA203-A	38.67	41	Failed	24	35	57
MAT04618	ALU0770	IA604-B	28.00	35	Failed	47	18	19
MAT03055	ALU0510	IA601-B	26.00	56	Failed	52	14	12
MAT01847	ALU0308	IA105-A	17.00	85	Failed	42	8	1
MAT05444	ALU0908	IA702-B	38.33	90	Failed	44	29	42
MAT04020	ALU0670	IA206-A	31.67	61	Failed	2	40	53
MAT05941	ALU0991	IA201-B	24.00	70	Failed	9	23	40
MAT03015	ALU0503	IA703-B	32.00	39	Failed	31	31	34
MAT01956	ALU0326	IA706-A	11.67	54	Failed	15	20	0
MAT05391	ALU0899	IA703-B	27.33	87	Failed	21	50	11
MAT01459	ALU0244	IA301-B	38.67	86	Failed	10	58	48
MAT00831	ALU0139	IA503-B	28.00	64	Failed	33	11	40
MAT04941	ALU0824	IA303-B	31.33	84	Failed	32	19	43
MAT01197	ALU0200	IA603-A	14.33	88	Failed	2	9	32
MAT04838	ALU0807	IA602-B	15.33	62	Failed	30	6	10
MAT05378	ALU0897	IA502-B	34.33	89	Failed	38	56	9
MAT02971	ALU0496	IA401-A	21.67	39	Failed	30	20	15
MAT01272	ALU0212	IA406-B	43.33	41	Failed	56	26	48
MAT03565	ALU0595	IA401-A	25.00	68	Failed	9	50	16
MAT03499	ALU0584	IA101-A	30.33	74	Failed	50	22	19
MAT03115	ALU0520	IA301-A	28.00	31	Failed	29	3	52
MAT01583	ALU0264	IA105-B	17.33	98	Failed	0	37	15
MAT02904	ALU0484	IA206-B	25.67	68	Failed	55	12	10
MAT00845	ALU0141	IA805-B	34.67	81	Failed	22	42	40
MAT04122	ALU0687	IA206-A	23.00	48	Failed	0	23	46
MAT01150	ALU0192	IA404-B	41.33	70	Failed	52	26	46
MAT00538	ALU0090	IA104-B	24.67	77	Failed	49	11	14
MAT05426	ALU0905	IA202-B	42.67	85	Failed	40	33	55
MAT00722	ALU0121	IA502-B	41.67	91	Failed	33	46	46
MAT01333	ALU0223	IA401-B	21.67	98	Failed	4	11	50
MAT03187	ALU0532	IA201-A	45.00	39	Failed	53	37	45
MAT03047	ALU0508	IA505-B	18.00	74	Failed	9	25	20
MAT02689	ALU0449	IA801-A	41.33	46	Failed	21	45	58
MAT02816	ALU0470	IA202-B	27.33	76	Failed	53	2	27
MAT02754	ALU0459	IA706-A	35.33	88	Failed	52	19	35
MAT02355	ALU0393	IA403-B	41.67	83	Failed	30	43	52
MAT00662	ALU0111	IA802-A	31.67	69	Failed	6	34	55
MAT00822	ALU0137	IA206-A	40.67	94	Failed	10	54	58
MAT03007	ALU0502	IA101-B	37.33	42	Failed	55	8	49
MAT04115	ALU0686	IA305-B	33.67	43	Failed	17	39	45
MAT00303	ALU0051	IA103-A	25.00	85	Failed	27	17	31
MAT04932	ALU0822	IA406-B	35.33	57	Failed	29	28	49
MAT00790	ALU0132	IA604-B	27.33	86	Failed	8	38	36
MAT02960	ALU0494	IA502-A	12.67	65	Failed	7	0	31
MAT02894	ALU0483	IA502-B	34.67	74	Failed	13	41	50
MAT03452	ALU0576	IA502-A	13.67	30	Failed	5	24	12
MAT05527	ALU0922	IA501-B	27.00	70	Failed	5	52	24
MAT04667	ALU0778	IA705-A	26.67	44	Failed	41	12	27
MAT02068	ALU0345	IA704-A	32.00	78	Failed	32	30	34
MAT04957	ALU0827	IA201-B	44.00	85	Failed	46	53	33
MAT01770	ALU0295	IA406-B	18.33	48	Failed	12	41	2
MAT02141	ALU0357	IA805-A	19.67	69	Failed	24	22	13
MAT02279	ALU0380	IA105-B	28.67	99	Failed	57	16	13
MAT01103	ALU0184	IA305-A	44.67	63	Failed	56	37	41
MAT04791	ALU0799	IA803-B	39.00	82	Failed	35	53	29
MAT03983	ALU0664	IA105-B	44.00	60	Failed	38	37	57
MAT01011	ALU0169	IA203-B	22.67	51	Failed	30	35	3
MAT02336	ALU0390	IA702-B	32.00	54	Failed	3	52	41
MAT02991	ALU0499	IA303-B	35.00	76	Failed	20	31	54
MAT04435	ALU0740	IA801-B	16.33	44	Failed	26	15	8
MAT00160	ALU0027	IA204-B	25.33	53	Failed	27	37	12
MAT01437	ALU0240	IA203-B	29.33	90	Failed	10	54	24
MAT00350	ALU0059	IA402-B	21.33	80	Failed	42	1	21
MAT01592	ALU0266	IA802-A	37.33	38	Failed	44	12	56
MAT05356	ALU0893	IA804-B	25.00	45	Failed	2	25	48
MAT02944	ALU0491	IA204-B	11.67	94	Failed	9	9	17
MAT00610	ALU0102	IA504-A	19.67	59	Failed	27	28	4
MAT02469	ALU0412	IA603-B	17.33	43	Failed	5	37	10
MAT03153	ALU0526	IA503-B	38.00	96	Failed	49	7	58
MAT02127	ALU0355	IA503-B	42.00	51	Failed	52	28	46
MAT00589	ALU0099	IA401-B	26.67	62	Failed	40	31	9
MAT04954	ALU0826	IA604-B	9.67	68	Failed	5	8	16
MAT04832	ALU0806	IA302-A	29.67	83	Failed	33	34	22
MAT05624	ALU0938	IA302-B	32.67	70	Failed	44	25	29
MAT05375	ALU0896	IA605-B	47.67	70	Failed	55	29	59
MAT00919	ALU0154	IA601-A	10.67	36	Failed	11	7	14
MAT00621	ALU0104	IA703-B	38.67	39	Failed	49	46	21
MAT05118	ALU0853	IA406-B	40.00	56	Failed	19	48	53
MAT04030	ALU0672	IA804-B	30.00	73	Failed	34	11	45
MAT04721	ALU0787	IA505-A	24.00	93	Failed	27	34	11
MAT02045	ALU0341	IA405-B	28.67	57	Failed	44	16	26
MAT03930	ALU0655	IA806-A	27.67	80	Failed	14	11	58
MAT01587	ALU0265	IA303-B	38.67	56	Failed	38	42	36
MAT03590	ALU0599	IA702-B	36.33	48	Failed	51	41	17
MAT01466	ALU0245	IA402-B	12.67	56	Failed	14	1	23
MAT00889	ALU0149	IA401-A	36.33	50	Failed	19	45	45
MAT00360	ALU0060	IA106-A	26.33	31	Failed	4	42	33
MAT00829	ALU0139	IA501-B	25.00	95	Failed	9	49	17
MAT02930	ALU0489	IA602-A	38.00	54	Failed	31	56	27
MAT02578	ALU0430	IA104-B	29.33	85	Failed	15	40	33
MAT02776	ALU0463	IA604-A	31.33	96	Failed	53	2	39
MAT00405	ALU0068	IA103-A	25.33	60	Failed	28	3	45
MAT05137	ALU0857	IA401-A	23.67	99	Failed	19	12	40
MAT01298	ALU0217	IA502-B	34.00	66	Failed	28	59	15
MAT02748	ALU0458	IA206-B	27.33	91	Failed	40	26	16
MAT04240	ALU0707	IA704-A	42.33	63	Failed	31	50	46
MAT04348	ALU0725	IA204-B	27.33	58	Failed	5	57	20
MAT00518	ALU0087	IA802-B	13.33	30	Failed	17	2	21
MAT01119	ALU0187	IA103-B	20.33	90	Failed	17	15	29
MAT02800	ALU0467	IA304-B	25.67	53	Failed	35	31	11
MAT00928	ALU0155	IA104-A	24.33	63	Failed	7	22	44
MAT01875	ALU0313	IA803-A	37.33	44	Failed	4	51	57
MAT04399	ALU0734	IA201-B	36.00	50	Failed	44	16	48
MAT00022	ALU0004	IA704-A	38.33	97	Failed	14	54	47
MAT01048	ALU0175	IA304-B	42.33	47	Failed	32	38	57
MAT01980	ALU0330	IA606-B	26.33	43	Failed	30	21	28
MAT02768	ALU0462	IA602-A	14.67	96	Failed	17	17	10
MAT04101	ALU0684	IA703-A	43.67	34	Failed	44	45	42
MAT00313	ALU0053	IA801-A	50.33	70	Failed	52	53	46
MAT03830	ALU0639	IA302-B	19.00	56	Failed	5	27	25
MAT03002	ALU0501	IA702-A	39.00	86	Failed	31	48	38
MAT02198	ALU0367	IA802-B	35.33	49	Failed	54	9	43
MAT03469	ALU0579	IA101-A	29.67	37	Failed	55	1	33
MAT02325	ALU0388	IA803-B	28.33	66	Failed	1	30	54
MAT04511	ALU0752	IA405-B	19.67	33	Failed	6	38	15
MAT03641	ALU0607	IA305-A	24.00	53	Failed	9	27	36
MAT01441	ALU0241	IA201-B	28.67	40	Failed	25	39	22
MAT04972	ALU0829	IA404-A	25.33	61	Failed	37	11	28
MAT04478	ALU0747	IA702-B	31.00	39	Failed	51	22	20
MAT03902	ALU0651	IA202-B	39.33	93	Failed	54	42	22
MAT04860	ALU0810	IA806-B	12.67	95	Failed	13	9	16
MAT00986	ALU0165	IA502-B	29.33	38	Failed	39	36	13
MAT01213	ALU0203	IA101-A	15.67	75	Failed	4	11	32
MAT01445	ALU0241	IA205-B	27.67	94	Failed	20	7	56
MAT02347	ALU0392	IA501-B	36.00	39	Failed	37	37	34
MAT03846	ALU0641	IA806-B	25.00	60	Failed	58	6	11
MAT01484	ALU0248	IA402-B	34.00	78	Failed	27	32	43
MAT02865	ALU0478	IA403-B	23.33	88	Failed	11	55	4
MAT05479	ALU0914	IA601-A	16.67	31	Failed	12	33	5
MAT03016	ALU0503	IA704-B	34.00	68	Failed	56	0	46
MAT04793	ALU0799	IA805-B	38.00	39	Failed	24	47	43
MAT01850	ALU0309	IA102-B	25.00	45	Failed	46	26	3
MAT00951	ALU0159	IA303-B	20.00	32	Failed	14	21	25
MAT01852	ALU0309	IA104-B	33.00	77	Failed	39	20	40
MAT04178	ALU0697	IA202-B	21.00	61	Failed	15	41	7
MAT03097	ALU0517	IA601-B	37.67	66	Failed	43	57	13
MAT04476	ALU0746	IA106-B	40.00	72	Failed	29	37	54
MAT05131	ALU0856	IA601-B	31.00	78	Failed	35	0	58
MAT03373	ALU0563	IA201-B	25.33	61	Failed	43	18	15
MAT03218	ALU0537	IA402-B	18.33	50	Failed	8	29	18
MAT03241	ALU0541	IA601-A	15.33	63	Failed	1	35	10
MAT03675	ALU0613	IA103-B	22.67	54	Failed	27	18	23
MAT01425	ALU0238	IA803-A	28.00	62	Failed	41	13	30
MAT03599	ALU0600	IA105-B	28.33	38	Failed	32	11	42
MAT01029	ALU0172	IA503-B	42.00	72	Failed	59	54	13
MAT02737	ALU0457	IA701-A	38.67	62	Failed	57	54	5
MAT02717	ALU0453	IA805-A	26.67	79	Failed	41	25	14
MAT05828	ALU0972	IA302-A	40.33	39	Failed	55	36	30
MAT04196	ALU0700	IA502-B	38.67	40	Failed	27	52	37
MAT05746	ALU0958	IA504-B	33.33	33	Failed	5	54	41
MAT01257	ALU0210	IA203-B	29.33	57	Failed	11	49	28
MAT05573	ALU0929	IA805-A	34.67	52	Failed	16	37	51
MAT05725	ALU0955	IA701-B	37.33	52	Failed	47	34	31
MAT03032	ALU0506	IA602-B	10.33	50	Failed	0	2	29
MAT04162	ALU0694	IA304-B	12.67	82	Failed	1	9	28
MAT02836	ALU0473	IA604-A	37.67	85	Failed	49	41	23
MAT02635	ALU0440	IA501-A	25.33	56	Failed	18	5	53
MAT00854	ALU0143	IA202-A	42.33	50	Failed	49	43	35
MAT03614	ALU0603	IA802-A	45.00	68	Failed	37	43	55
MAT01570	ALU0262	IA404-B	26.00	66	Failed	50	11	17
MAT04355	ALU0726	IA705-B	47.00	31	Failed	44	42	55
MAT02277	ALU0380	IA103-B	21.33	39	Failed	37	16	11
MAT02057	ALU0343	IA405-A	12.67	85	Failed	31	7	0
MAT02700	ALU0450	IA506-A	20.00	62	Failed	29	20	11
MAT05686	ALU0948	IA204-B	38.33	63	Failed	31	37	47
MAT00115	ALU0020	IA701-B	24.00	80	Failed	4	53	15
MAT02763	ALU0461	IA103-B	21.67	98	Failed	26	35	4
MAT03831	ALU0639	IA303-B	52.67	74	Failed	45	56	57
MAT01554	ALU0259	IA406-A	11.33	92	Failed	8	13	13
MAT05727	ALU0955	IA703-B	43.67	76	Failed	45	38	48
MAT01198	ALU0200	IA604-A	45.00	71	Failed	30	53	52
MAT02602	ALU0434	IA704-A	26.67	60	Failed	25	10	45
MAT03160	ALU0527	IA204-A	11.33	81	Failed	20	8	6
MAT03925	ALU0655	IA801-A	48.00	82	Failed	57	47	40
MAT04481	ALU0747	IA705-B	28.00	47	Failed	30	18	36
MAT05164	ALU0861	IA204-B	36.00	67	Failed	22	46	40
MAT05619	ALU0937	IA503-B	30.33	58	Failed	50	18	23
MAT02317	ALU0387	IA301-B	51.67	91	Failed	55	58	42
MAT04851	ALU0809	IA303-A	34.67	86	Failed	46	29	29
MAT02611	ALU0436	IA201-A	16.67	59	Failed	11	3	36
MAT03048	ALU0508	IA506-B	22.00	97	Failed	2	53	11
MAT01811	ALU0302	IA805-B	35.00	77	Failed	33	37	35
MAT05625	ALU0938	IA303-B	22.67	30	Failed	34	29	5
MAT00795	ALU0133	IA703-B	32.00	32	Failed	35	10	51
MAT00689	ALU0115	IA305-A	19.33	55	Failed	1	15	42
MAT05431	ALU0906	IA101-B	19.33	47	Failed	33	20	5
MAT04405	ALU0735	IA401-A	23.67	96	Failed	6	25	40
MAT05020	ALU0837	IA404-A	32.33	63	Failed	16	49	32
MAT04859	ALU0810	IA805-B	30.33	62	Failed	39	8	44
MAT03328	ALU0555	IA304-B	29.33	34	Failed	10	54	24
MAT03786	ALU0631	IA306-B	27.67	45	Failed	33	4	46
MAT00596	ALU0100	IA402-B	51.33	58	Failed	51	59	44
MAT03861	ALU0644	IA503-A	21.33	36	Failed	1	24	39
MAT00891	ALU0149	IA403-A	31.67	94	Failed	33	55	7
MAT02282	ALU0381	IA702-B	28.67	71	Failed	19	21	46
MAT05813	ALU0969	IA205-B	23.33	89	Failed	23	42	5
MAT04318	ALU0720	IA704-B	30.33	38	Failed	12	37	42
MAT04847	ALU0808	IA305-B	32.67	89	Failed	59	33	6
MAT00086	ALU0015	IA202-B	21.33	74	Failed	49	1	14
MAT01641	ALU0274	IA203-A	10.00	76	Failed	5	15	10
MAT05825	ALU0971	IA605-B	27.67	58	Failed	46	16	21
MAT03046	ALU0508	IA504-B	38.67	70	Failed	18	57	41
MAT00064	ALU0011	IA104-A	20.67	62	Failed	16	33	13
MAT05465	ALU0911	IA505-A	54.00	35	Failed	57	57	48
MAT02942	ALU0491	IA202-B	31.67	36	Failed	38	14	43
MAT03181	ALU0531	IA301-B	36.00	58	Failed	39	46	23
MAT01767	ALU0295	IA403-B	38.33	49	Failed	51	59	5
MAT05094	ALU0849	IA506-B	27.67	52	Failed	19	58	6
MAT02335	ALU0390	IA701-B	38.33	84	Failed	11	55	49
MAT01354	ALU0226	IA304-A	22.00	64	Failed	19	26	21
MAT04183	ALU0698	IA601-B	29.67	87	Failed	4	40	45
MAT03867	ALU0645	IA603-B	24.67	73	Failed	17	47	10
MAT05620	ALU0937	IA504-B	33.33	91	Failed	17	50	33
MAT02823	ALU0471	IA303-B	26.33	36	Failed	58	9	12
MAT00555	ALU0093	IA403-A	39.00	40	Failed	44	18	55
MAT02313	ALU0386	IA603-A	42.67	74	Failed	40	48	40
MAT03481	ALU0581	IA301-B	17.00	45	Failed	36	8	7
MAT05499	ALU0917	IA203-B	17.33	51	Failed	11	24	17
MAT04882	ALU0814	IA204-B	30.33	57	Failed	42	37	12
MAT05091	ALU0849	IA503-B	22.33	62	Failed	3	19	45
MAT03082	ALU0514	IA204-B	24.33	71	Failed	26	23	24
MAT01047	ALU0175	IA303-B	45.00	54	Failed	54	37	44
MAT01564	ALU0261	IA104-A	34.67	49	Failed	38	44	22
MAT00073	ALU0013	IA701-A	26.33	57	Failed	30	28	21
MAT05276	ALU0880	IA102-B	21.67	39	Failed	37	19	9
MAT00257	ALU0043	IA305-A	33.33	84	Failed	56	43	1
MAT02160	ALU0360	IA206-A	37.00	67	Failed	10	51	50
MAT01606	ALU0268	IA204-B	25.00	32	Failed	7	16	52
MAT03844	ALU0641	IA804-B	13.67	100	Failed	10	26	5
MAT02385	ALU0398	IA603-B	38.00	89	Failed	52	21	41
MAT00035	ALU0006	IA105-A	23.00	64	Failed	23	7	39
MAT02907	ALU0485	IA303-B	29.33	45	Failed	41	47	0
MAT00556	ALU0093	IA404-A	28.00	49	Failed	9	33	42
MAT01360	ALU0227	IA504-B	45.67	86	Failed	54	33	50
MAT02888	ALU0482	IA802-B	26.67	96	Failed	2	29	49
MAT03017	ALU0503	IA705-B	43.00	98	Failed	21	58	50
MAT03579	ALU0597	IA703-A	36.33	99	Failed	38	40	31
MAT01133	ALU0189	IA805-A	40.00	43	Failed	57	27	36
MAT02319	ALU0387	IA303-B	32.33	31	Failed	38	9	50
MAT00989	ALU0165	IA505-B	32.00	81	Failed	47	43	6
MAT03129	ALU0522	IA403-B	12.33	45	Failed	11	19	7
MAT03758	ALU0627	IA102-B	26.33	84	Failed	41	12	26
MAT05241	ALU0874	IA203-B	37.33	60	Failed	54	26	32
MAT00579	ALU0097	IA603-A	37.67	39	Failed	26	29	58
MAT01759	ALU0294	IA501-A	46.33	88	Failed	44	36	59
MAT02765	ALU0461	IA105-B	21.67	88	Failed	16	33	16
MAT05260	ALU0877	IA104-B	28.33	62	Failed	49	0	36
MAT02031	ALU0339	IA303-B	51.67	83	Failed	58	54	43
MAT04296	ALU0716	IA106-B	21.33	64	Failed	30	9	25
MAT05452	ALU0909	IA404-B	26.33	73	Failed	12	27	40
MAT03926	ALU0655	IA802-A	32.00	89	Failed	28	53	15
MAT00846	ALU0141	IA806-B	27.33	55	Failed	19	16	47
MAT02095	ALU0350	IA801-B	41.67	91	Failed	34	39	52
MAT00032	ALU0006	IA102-A	29.33	57	Failed	22	11	55
MAT03138	ALU0523	IA506-B	26.00	67	Failed	11	37	30
MAT04248	ALU0708	IA806-B	32.33	48	Failed	32	30	35
MAT05098	ALU0850	IA104-B	34.33	68	Failed	56	45	2
MAT02841	ALU0474	IA203-B	35.67	94	Failed	41	10	56
MAT03500	ALU0584	IA102-A	21.33	91	Failed	30	5	29
MAT05608	ALU0935	IA504-A	14.00	95	Failed	20	4	18
MAT03933	ALU0656	IA403-B	33.00	99	Failed	49	32	18
MAT01705	ALU0285	IA501-A	28.00	91	Failed	18	55	11
MAT02269	ALU0379	IA701-A	14.33	61	Failed	19	22	2
MAT05016	ALU0836	IA606-B	44.67	59	Failed	49	32	53
MAT05743	ALU0958	IA501-B	19.33	94	Failed	37	12	9
MAT00600	ALU0100	IA406-B	34.00	51	Failed	52	23	27
MAT03447	ALU0575	IA403-A	44.67	42	Failed	26	56	52
MAT02701	ALU0451	IA401-B	42.33	34	Failed	43	36	48
MAT03756	ALU0626	IA706-B	21.00	88	Failed	42	5	16
MAT01341	ALU0224	IA703-B	50.33	89	Failed	44	50	57
MAT00527	ALU0088	IA805-B	26.67	83	Failed	56	15	9
MAT04233	ALU0706	IA703-B	31.33	95	Failed	57	4	33
MAT03421	ALU0571	IA801-A	27.33	59	Failed	22	24	36
MAT04150	ALU0692	IA204-B	15.33	59	Failed	4	11	31
MAT05326	ALU0888	IA504-B	20.33	53	Failed	17	6	38
MAT01395	ALU0233	IA403-B	29.00	56	Failed	35	31	21
MAT04436	ALU0740	IA802-B	27.00	81	Failed	25	39	17
MAT05305	ALU0885	IA201-B	23.67	37	Failed	37	33	1
MAT05179	ALU0864	IA101-A	41.67	31	Failed	19	48	58
MAT01502	ALU0251	IA502-A	39.67	55	Failed	40	21	58
MAT00243	ALU0041	IA303-A	26.67	75	Failed	17	15	48
MAT01789	ALU0299	IA201-A	11.00	40	Failed	4	23	6
MAT05306	ALU0885	IA202-B	30.33	94	Failed	28	57	6
MAT03847	ALU0642	IA401-B	40.00	69	Failed	24	49	47
MAT03220	ALU0537	IA404-B	9.00	88	Failed	11	1	15
MAT05358	ALU0893	IA806-B	20.00	87	Failed	0	35	25
MAT05327	ALU0888	IA505-B	46.33	95	Failed	59	55	25
MAT02546	ALU0425	IA802-B	29.00	35	Failed	10	20	57
MAT01671	ALU0279	IA203-B	12.33	94	Failed	3	28	6
MAT01793	ALU0299	IA205-A	36.33	49	Failed	27	36	46
MAT04098	ALU0683	IA606-B	47.67	55	Failed	57	31	55
MAT02594	ALU0433	IA802-A	42.00	98	Failed	35	47	44
MAT01468	ALU0245	IA404-B	28.33	45	Failed	20	15	50
MAT05543	ALU0924	IA605-B	20.33	98	Failed	9	5	47
MAT01802	ALU0301	IA102-B	34.33	52	Failed	18	58	27
MAT02379	ALU0397	IA303-B	23.67	51	Failed	3	9	59
MAT01448	ALU0242	IA402-A	28.00	44	Failed	12	37	35
MAT05611	ALU0936	IA301-B	14.67	32	Failed	17	16	11
MAT05335	ALU0890	IA101-A	44.33	73	Failed	44	53	36
MAT05789	ALU0965	IA705-B	48.00	83	Failed	58	44	42
MAT02711	ALU0452	IA405-B	44.67	79	Failed	46	29	59
MAT02675	ALU0446	IA205-B	24.00	35	Failed	21	26	25
MAT04339	ALU0724	IA401-B	31.00	30	Failed	38	2	53
MAT00632	ALU0106	IA502-B	37.33	61	Failed	42	45	25
MAT01373	ALU0229	IA205-A	17.33	97	Failed	18	6	28
MAT01775	ALU0296	IA805-A	31.67	43	Failed	33	59	3
MAT05540	ALU0924	IA602-B	29.00	65	Failed	40	16	31
MAT03347	ALU0558	IA105-B	46.67	62	Failed	59	22	59
MAT05536	ALU0923	IA504-A	29.33	40	Failed	53	13	22
MAT00723	ALU0121	IA503-B	28.67	67	Failed	32	8	46
MAT05779	ALU0964	IA501-B	26.67	52	Failed	52	25	3
MAT00030	ALU0005	IA406-B	37.33	59	Failed	30	35	47
MAT02149	ALU0359	IA401-B	37.00	37	Failed	47	30	34
MAT03010	ALU0502	IA104-B	8.33	61	Failed	3	17	5
MAT01670	ALU0279	IA202-B	29.33	36	Failed	42	39	7
MAT01528	ALU0255	IA504-A	9.33	65	Failed	17	0	11
MAT05842	ALU0974	IA304-B	44.00	52	Failed	38	51	43
MAT01340	ALU0224	IA702-B	32.33	57	Failed	58	23	16
MAT01942	ALU0324	IA604-B	22.00	75	Failed	13	28	25
MAT00379	ALU0064	IA501-B	24.00	96	Failed	50	19	3
MAT00635	ALU0106	IA505-B	30.00	45	Failed	51	1	38
MAT02974	ALU0496	IA404-A	50.33	53	Failed	53	57	41
MAT01293	ALU0216	IA203-A	19.67	66	Failed	11	34	14
MAT02908	ALU0485	IA304-B	26.33	60	Failed	29	14	36
MAT04116	ALU0686	IA306-B	28.67	57	Failed	21	10	55
MAT03535	ALU0590	IA101-B	27.00	60	Failed	16	20	45
MAT02681	ALU0447	IA105-B	32.33	36	Failed	40	44	13
MAT02159	ALU0360	IA205-A	14.67	94	Failed	0	41	3
MAT01834	ALU0306	IA504-A	28.00	44	Failed	22	24	38
MAT03643	ALU0608	IA501-B	27.00	76	Failed	11	29	41
MAT05023	ALU0838	IA501-A	35.33	51	Failed	17	51	38
MAT02479	ALU0414	IA501-A	23.67	80	Failed	18	1	52
MAT05736	ALU0956	IA406-A	22.33	90	Failed	59	2	6
MAT00844	ALU0141	IA804-B	17.67	40	Failed	0	33	20
MAT03663	ALU0611	IA303-B	23.00	58	Failed	8	10	51
MAT00520	ALU0087	IA804-B	41.67	82	Failed	43	43	39
MAT01042	ALU0174	IA704-B	45.00	62	Failed	40	51	44
MAT03749	ALU0625	IA605-B	42.00	98	Failed	55	15	56
MAT03547	ALU0592	IA601-B	26.67	94	Failed	11	49	20
MAT04407	ALU0735	IA403-A	36.67	99	Failed	42	58	10
MAT05483	ALU0914	IA605-A	29.33	86	Failed	18	11	59
MAT03045	ALU0508	IA503-B	25.67	82	Failed	44	6	27
MAT04316	ALU0720	IA702-B	31.00	46	Failed	51	17	25
MAT02180	ALU0364	IA102-A	13.67	67	Failed	36	0	5
MAT03027	ALU0505	IA603-A	23.67	60	Failed	10	11	50
MAT05077	ALU0847	IA801-A	28.67	64	Failed	55	7	24
MAT01653	ALU0276	IA603-B	21.33	45	Failed	50	1	13
MAT02778	ALU0463	IA606-A	31.00	90	Failed	49	37	7
MAT04877	ALU0813	IA505-A	14.33	60	Failed	12	24	7
MAT02377	ALU0397	IA301-B	46.67	57	Failed	59	43	38
MAT03833	ALU0639	IA305-B	29.67	43	Failed	20	49	20
MAT01706	ALU0285	IA502-A	23.33	78	Failed	0	59	11
MAT03168	ALU0528	IA306-B	21.67	73	Failed	11	39	15
MAT01236	ALU0206	IA506-A	30.33	83	Failed	45	20	26
MAT05197	ALU0867	IA801-B	33.67	78	Failed	53	6	42
MAT05607	ALU0935	IA503-A	43.67	38	Failed	57	24	50
MAT04498	ALU0750	IA604-B	34.67	83	Failed	36	40	28
MAT04270	ALU0712	IA804-A	24.67	50	Failed	10	34	30
MAT02153	ALU0359	IA405-B	50.33	69	Failed	46	47	58
MAT02040	ALU0340	IA106-B	18.33	31	Failed	6	0	49
MAT03744	ALU0624	IA706-B	17.00	34	Failed	32	18	1
MAT05300	ALU0884	IA602-A	36.67	76	Failed	34	20	56
MAT01273	ALU0213	IA201-B	33.67	66	Failed	48	11	42
MAT03932	ALU0656	IA402-B	36.67	34	Failed	33	50	27
MAT01467	ALU0245	IA403-B	29.33	31	Failed	36	49	3
MAT02967	ALU0495	IA403-A	32.67	82	Failed	9	45	44
MAT01383	ALU0231	IA503-B	19.00	30	Failed	22	1	34
MAT00981	ALU0164	IA503-A	50.33	33	Failed	59	48	44
MAT05758	ALU0960	IA804-A	37.00	40	Failed	13	40	58
MAT00484	ALU0081	IA404-B	34.33	69	Failed	35	37	31
MAT00907	ALU0152	IA401-A	26.33	67	Failed	12	21	46
MAT01427	ALU0238	IA805-A	27.67	33	Failed	12	35	36
MAT02063	ALU0344	IA405-B	19.00	45	Failed	24	25	8
MAT01678	ALU0280	IA704-A	29.33	63	Failed	12	40	36
MAT05355	ALU0893	IA803-B	42.67	59	Failed	45	26	57
MAT04414	ALU0736	IA104-B	34.67	58	Failed	44	51	9
MAT05827	ALU0972	IA301-A	18.00	92	Failed	0	54	0
MAT05572	ALU0929	IA804-A	32.00	54	Failed	50	25	21
MAT01204	ALU0201	IA404-A	38.33	50	Failed	39	44	32
MAT01332	ALU0222	IA706-B	20.33	72	Failed	20	23	18
MAT01714	ALU0286	IA204-A	31.33	55	Failed	21	39	34
MAT05323	ALU0888	IA501-B	32.00	53	Failed	47	1	48
MAT02302	ALU0384	IA204-B	18.67	54	Failed	23	17	16
MAT05120	ALU0854	IA802-B	9.33	88	Failed	1	25	2
MAT04445	ALU0741	IA405-B	14.00	85	Failed	12	30	0
MAT04094	ALU0683	IA602-B	42.00	77	Failed	28	49	49
MAT01019	ALU0170	IA405-B	24.33	61	Failed	48	20	5
MAT00381	ALU0064	IA503-B	40.00	91	Failed	46	30	44
MAT02584	ALU0431	IA204-A	31.33	37	Failed	17	50	27
MAT03004	ALU0501	IA704-A	26.67	84	Failed	23	21	36
MAT03265	ALU0545	IA401-B	21.33	79	Failed	20	38	6
MAT00383	ALU0064	IA505-B	35.67	64	Failed	39	30	38
MAT05528	ALU0922	IA502-B	52.00	31	Failed	52	57	47
MAT03433	ALU0573	IA301-B	31.67	70	Failed	10	49	36
MAT01903	ALU0318	IA401-A	41.67	38	Failed	58	21	46
MAT05488	ALU0915	IA704-B	44.33	77	Failed	34	55	44
MAT00577	ALU0097	IA601-A	50.33	52	Failed	49	47	55
MAT02380	ALU0397	IA304-B	25.67	53	Failed	27	27	23
MAT03428	ALU0572	IA202-A	50.33	73	Failed	48	57	46
MAT05191	ALU0866	IA301-B	29.67	47	Failed	0	44	45
MAT02504	ALU0418	IA602-B	28.00	55	Failed	29	30	25
MAT04935	ALU0823	IA403-B	25.67	83	Failed	15	29	33
MAT00728	ALU0122	IA502-B	32.00	56	Failed	32	42	22
MAT00690	ALU0115	IA306-A	30.67	35	Failed	55	21	16
MAT02699	ALU0450	IA505-A	34.33	65	Failed	44	18	41
MAT02509	ALU0419	IA501-B	34.67	93	Failed	5	42	57
MAT04909	ALU0819	IA201-B	26.67	30	Failed	22	46	12
MAT03064	ALU0511	IA604-B	23.33	32	Failed	9	40	21
MAT01135	ALU0190	IA401-A	41.33	65	Failed	46	40	38
MAT02697	ALU0450	IA503-A	20.33	72	Failed	42	5	14
MAT05931	ALU0989	IA503-A	25.33	64	Failed	34	15	27
MAT03838	ALU0640	IA104-B	31.33	43	Failed	26	50	18
MAT02449	ALU0409	IA401-B	41.33	56	Failed	23	42	59
MAT05313	ALU0886	IA703-B	33.67	70	Failed	15	48	38
MAT00489	ALU0082	IA103-A	41.00	91	Failed	58	50	15
MAT03677	ALU0613	IA105-B	45.33	39	Failed	52	49	35
MAT01614	ALU0269	IA606-B	24.33	77	Failed	59	5	9
MAT05599	ALU0934	IA601-A	38.33	49	Failed	46	59	10
MAT02372	ALU0396	IA502-B	14.67	54	Failed	18	12	14
MAT05397	ALU0900	IA303-A	47.67	98	Failed	58	27	58
MAT00306	ALU0051	IA106-A	34.33	38	Failed	8	40	55
MAT00184	ALU0031	IA604-B	30.67	77	Failed	53	23	16
MAT03563	ALU0594	IA405-A	40.33	51	Failed	41	44	36
MAT01285	ALU0215	IA601-B	18.00	87	Failed	13	41	0
MAT05585	ALU0931	IA505-A	31.67	78	Failed	38	8	49
MAT02338	ALU0390	IA704-B	44.67	44	Failed	54	55	25
MAT02673	ALU0446	IA203-B	10.33	50	Failed	3	25	3
MAT02203	ALU0368	IA401-B	45.33	51	Failed	47	50	39
MAT03113	ALU0519	IA505-B	27.33	39	Failed	13	18	51
MAT03145	ALU0525	IA801-A	36.67	83	Failed	47	27	36
MAT00572	ALU0096	IA102-A	29.00	50	Failed	17	44	26
MAT03365	ALU0561	IA805-B	19.33	73	Failed	5	15	38
MAT04091	ALU0682	IA405-B	35.33	40	Failed	33	36	37
MAT05151	ALU0859	IA203-B	35.67	35	Failed	49	28	30
MAT04079	ALU0680	IA305-B	23.33	100	Failed	8	53	9
MAT05005	ALU0835	IA301-B	24.33	59	Failed	16	10	47
MAT04852	ALU0809	IA304-A	26.00	98	Failed	28	17	33
MAT01374	ALU0229	IA206-A	47.33	38	Failed	56	58	28
MAT03876	ALU0646	IA506-B	47.67	53	Failed	46	39	58
MAT05955	ALU0993	IA403-B	38.67	53	Failed	41	57	18
MAT04182	ALU0697	IA206-B	22.33	38	Failed	52	2	13
MAT04265	ALU0711	IA505-A	29.33	61	Failed	46	27	15
MAT02740	ALU0457	IA704-A	43.00	99	Failed	48	37	44
MAT01274	ALU0213	IA202-B	26.00	89	Failed	2	50	26
MAT03025	ALU0505	IA601-A	31.33	70	Failed	35	6	53
MAT01935	ALU0323	IA403-A	38.67	38	Failed	57	6	53
MAT02985	ALU0498	IA303-B	24.67	79	Failed	29	43	2
MAT00554	ALU0093	IA402-A	42.67	99	Failed	17	57	54
MAT00315	ALU0053	IA803-A	22.67	89	Failed	11	19	38
MAT05104	ALU0851	IA304-A	12.33	60	Failed	21	8	8
MAT02587	ALU0432	IA201-A	28.67	57	Failed	33	42	11
MAT00487	ALU0082	IA101-A	16.67	94	Failed	16	11	23
MAT04231	ALU0706	IA701-B	13.00	66	Failed	0	38	1
MAT03669	ALU0612	IA303-B	47.00	84	Failed	57	54	30
MAT03660	ALU0610	IA306-B	32.33	84	Failed	46	23	28
MAT05729	ALU0955	IA705-B	36.00	50	Failed	39	53	16
MAT04442	ALU0741	IA402-B	23.00	48	Failed	25	19	25
MAT02935	ALU0490	IA401-B	34.33	100	Failed	36	51	16
MAT02884	ALU0481	IA204-B	14.00	31	Failed	28	8	6
MAT01763	ALU0294	IA505-A	22.00	54	Failed	5	30	31
MAT01051	ALU0176	IA201-B	34.67	74	Failed	42	58	4
MAT05834	ALU0973	IA402-A	22.67	76	Failed	10	8	50
MAT00926	ALU0155	IA102-A	11.00	63	Failed	3	13	17
MAT00582	ALU0097	IA606-A	45.33	100	Failed	38	55	43
MAT04320	ALU0720	IA706-B	32.33	94	Failed	46	6	45
MAT04945	ALU0825	IA501-B	18.67	83	Failed	19	5	32
MAT05112	ALU0852	IA706-A	31.33	64	Failed	49	24	21
MAT03994	ALU0666	IA804-B	16.67	99	Failed	34	1	15
MAT00763	ALU0128	IA301-A	23.33	42	Failed	23	32	15
MAT02593	ALU0433	IA801-A	25.00	100	Failed	15	5	55
MAT02073	ALU0346	IA703-B	29.00	86	Failed	35	9	43
MAT04345	ALU0725	IA201-B	43.67	82	Failed	51	54	26
MAT01253	ALU0209	IA305-B	24.33	64	Failed	4	36	33
MAT05061	ALU0844	IA203-A	13.33	60	Failed	13	14	13
MAT02263	ALU0378	IA601-B	30.00	92	Failed	47	24	19
MAT02970	ALU0495	IA406-A	35.33	36	Failed	56	14	36
MAT01247	ALU0208	IA105-A	27.67	41	Failed	31	17	35
MAT02999	ALU0500	IA705-A	23.67	69	Failed	41	22	8
MAT01242	ALU0207	IA306-A	43.67	31	Failed	43	50	38
MAT01239	ALU0207	IA303-A	19.33	47	Failed	12	38	8
MAT02241	ALU0374	IA303-B	46.00	73	Failed	39	41	58
MAT02156	ALU0360	IA202-A	28.00	31	Failed	57	25	2
MAT02559	ALU0427	IA403-B	42.00	70	Failed	48	53	25
MAT05454	ALU0909	IA406-B	14.33	100	Failed	32	10	1
MAT05014	ALU0836	IA604-B	27.00	69	Failed	32	10	39
MAT05816	ALU0970	IA502-B	30.67	69	Failed	18	36	38
MAT02905	ALU0485	IA301-B	20.67	92	Failed	53	0	9
MAT00013	ALU0003	IA301-B	21.00	69	Failed	40	14	9
MAT01218	ALU0203	IA106-A	38.33	64	Failed	36	39	40
MAT00483	ALU0081	IA403-B	42.33	45	Failed	45	41	41
MAT04155	ALU0693	IA203-B	17.67	62	Failed	17	3	33
MAT04927	ALU0822	IA401-B	29.33	46	Failed	40	25	23
MAT04889	ALU0815	IA205-A	19.67	33	Failed	5	14	40
MAT00828	ALU0138	IA206-A	44.00	58	Failed	27	50	55
MAT05414	ALU0903	IA302-B	37.67	84	Failed	55	32	26
MAT01068	ALU0178	IA606-B	5.00	77	Failed	5	4	6
MAT04664	ALU0778	IA702-A	28.33	92	Failed	47	7	31
MAT01034	ALU0173	IA302-A	38.00	37	Failed	37	50	27
MAT02137	ALU0357	IA801-A	26.67	36	Failed	48	10	22
MAT03031	ALU0506	IA601-B	31.67	77	Failed	24	41	30
MAT02034	ALU0339	IA306-B	31.00	83	Failed	49	29	15
MAT03272	ALU0546	IA202-B	47.33	37	Failed	55	43	44
MAT00933	ALU0156	IA603-A	29.67	77	Failed	10	34	45
MAT04007	ALU0668	IA305-B	36.33	66	Failed	32	19	58
MAT03993	ALU0666	IA803-B	17.33	94	Failed	13	20	19
MAT05096	ALU0850	IA102-B	27.67	83	Failed	13	33	37
MAT04842	ALU0807	IA606-B	38.00	50	Failed	14	59	41
MAT05344	ALU0891	IA304-B	21.33	89	Failed	19	44	1
MAT02470	ALU0412	IA604-B	33.67	60	Failed	38	31	32
MAT05618	ALU0937	IA502-B	12.67	53	Failed	5	4	29
MAT03449	ALU0575	IA405-A	7.67	71	Failed	0	17	6
MAT05460	ALU0910	IA306-A	29.00	90	Failed	13	48	26
MAT00464	ALU0078	IA102-A	19.67	100	Failed	2	2	55
MAT03330	ALU0555	IA306-B	27.00	31	Failed	0	43	38
MAT05240	ALU0874	IA202-B	44.00	43	Failed	39	47	46
MAT05090	ALU0849	IA502-B	31.33	44	Failed	27	27	40
MAT01742	ALU0291	IA102-B	32.67	77	Failed	33	51	14
MAT05175	ALU0863	IA603-B	37.67	51	Failed	30	25	58
MAT05698	ALU0950	IA204-A	26.00	50	Failed	18	17	43
MAT02680	ALU0447	IA104-B	26.67	37	Failed	3	44	33
MAT01651	ALU0276	IA601-B	31.67	84	Failed	21	32	42
MAT04038	ALU0673	IA406-B	27.33	51	Failed	14	36	32
MAT00781	ALU0131	IA801-A	36.67	61	Failed	20	58	32
MAT02463	ALU0411	IA403-B	47.00	63	Failed	52	40	49
MAT02915	ALU0486	IA405-A	19.67	88	Failed	2	10	47
MAT02744	ALU0458	IA202-B	16.33	52	Failed	6	40	3
MAT01320	ALU0220	IA606-B	15.67	85	Failed	19	23	5
MAT00806	ALU0135	IA302-B	15.00	81	Failed	24	10	11
MAT00958	ALU0160	IA504-A	21.67	45	Failed	16	27	22
MAT00567	ALU0095	IA303-A	34.33	45	Failed	37	33	33
MAT03415	ALU0570	IA401-B	34.33	78	Failed	38	39	26
MAT05239	ALU0874	IA201-B	28.67	90	Failed	51	17	18
MAT05121	ALU0854	IA803-B	32.33	50	Failed	32	18	47
MAT03665	ALU0611	IA305-B	39.33	51	Failed	55	22	41
MAT03748	ALU0625	IA604-B	7.67	65	Failed	20	2	1
MAT05122	ALU0854	IA804-B	35.00	79	Failed	49	31	25
MAT00575	ALU0096	IA105-A	48.33	71	Failed	52	49	44
MAT04801	ALU0801	IA401-B	27.67	62	Failed	40	35	8
MAT04138	ALU0690	IA304-B	35.00	84	Failed	50	0	55
MAT04421	ALU0737	IA705-B	25.33	41	Failed	54	15	7
MAT05922	ALU0987	IA506-A	5.00	74	Failed	5	5	5
MAT05552	ALU0926	IA702-B	37.33	75	Failed	48	57	7
MAT03402	ALU0567	IA106-B	33.67	83	Failed	6	50	45
MAT04287	ALU0715	IA303-B	14.67	33	Failed	22	2	20
MAT02906	ALU0485	IA302-B	47.00	61	Failed	54	40	47
MAT05052	ALU0842	IA506-B	29.33	44	Failed	45	37	6
MAT02467	ALU0412	IA601-B	36.67	37	Failed	40	36	34
MAT01386	ALU0231	IA506-B	33.33	69	Failed	24	30	46
MAT01947	ALU0325	IA603-B	53.67	81	Failed	59	54	48
MAT05124	ALU0854	IA806-B	25.00	42	Failed	11	34	30
MAT03122	ALU0521	IA502-B	23.33	84	Failed	6	54	10
MAT05280	ALU0880	IA106-B	30.33	66	Failed	52	29	10
MAT04058	ALU0677	IA102-B	13.67	99	Failed	0	5	36
MAT00998	ALU0167	IA702-B	19.67	44	Failed	3	33	23
MAT05551	ALU0926	IA701-B	19.33	58	Failed	25	25	8
MAT02466	ALU0411	IA406-B	25.67	54	Failed	29	23	25
MAT05442	ALU0907	IA206-B	37.00	97	Failed	44	56	11
MAT04131	ALU0689	IA603-A	18.33	54	Failed	0	47	8
MAT00365	ALU0061	IA805-B	9.00	90	Failed	4	15	8
MAT02963	ALU0494	IA505-A	15.33	48	Failed	41	4	1
MAT05780	ALU0964	IA502-B	24.67	69	Failed	9	44	21
MAT03172	ALU0529	IA204-B	27.33	51	Failed	11	23	48
MAT02147	ALU0358	IA705-A	37.00	84	Failed	44	27	40
MAT02505	ALU0418	IA603-B	24.33	78	Failed	38	14	21
MAT04865	ALU0811	IA405-B	24.67	62	Failed	29	27	18
MAT00111	ALU0019	IA103-B	33.00	53	Failed	28	20	51
MAT01750	ALU0292	IA704-A	38.67	67	Failed	55	48	13
MAT01078	ALU0180	IA504-B	25.33	62	Failed	19	22	35
MAT02125	ALU0355	IA501-B	6.67	37	Failed	7	11	2
MAT00703	ALU0118	IA801-B	42.67	78	Failed	18	58	52
MAT04837	ALU0807	IA601-B	17.00	77	Failed	33	16	2
MAT01776	ALU0296	IA806-A	45.33	63	Failed	51	40	45
MAT04132	ALU0689	IA604-A	14.67	91	Failed	6	13	25
MAT01465	ALU0245	IA401-B	25.67	88	Failed	36	2	39
MAT01454	ALU0243	IA302-A	42.33	100	Failed	44	28	55
MAT03718	ALU0620	IA404-B	8.00	71	Failed	5	16	3
MAT01568	ALU0262	IA402-B	32.67	59	Failed	1	54	43
MAT05451	ALU0909	IA403-B	14.67	45	Failed	3	31	10
MAT04794	ALU0799	IA806-B	33.00	40	Failed	28	26	45
MAT03464	ALU0578	IA202-A	32.00	56	Failed	56	32	8
MAT02474	ALU0413	IA202-B	49.33	39	Failed	52	41	55
MAT01558	ALU0260	IA804-B	51.33	39	Failed	54	56	44
MAT03929	ALU0655	IA805-A	20.33	43	Failed	17	19	25
MAT01356	ALU0226	IA306-A	44.00	37	Failed	32	48	52
MAT02897	ALU0483	IA505-B	41.00	59	Failed	44	47	32
MAT01390	ALU0232	IA404-B	7.67	44	Failed	7	3	13
MAT04303	ALU0718	IA701-A	27.00	96	Failed	22	29	30
MAT03705	ALU0618	IA203-B	24.00	73	Failed	29	38	5
MAT05372	ALU0896	IA602-B	17.33	95	Failed	48	0	4
MAT03414	ALU0569	IA106-B	30.67	66	Failed	48	29	15
MAT03315	ALU0553	IA803-A	27.33	53	Failed	24	20	38
MAT05459	ALU0910	IA305-A	25.67	81	Failed	15	24	38
MAT05581	ALU0931	IA501-A	16.67	75	Failed	21	16	13
MAT05635	ALU0940	IA301-B	31.00	46	Failed	10	41	42
MAT05371	ALU0896	IA601-B	26.00	54	Failed	43	30	5
MAT03544	ALU0591	IA604-B	31.67	61	Failed	36	22	37
MAT05117	ALU0853	IA405-B	1.33	71	Failed	1	1	2
MAT03628	ALU0605	IA304-A	27.67	88	Failed	11	27	45
MAT01675	ALU0280	IA701-A	28.00	72	Failed	44	4	36
MAT05056	ALU0843	IA704-B	26.33	40	Failed	20	58	1
MAT05895	ALU0983	IA603-B	32.67	58	Failed	50	44	4
MAT03418	ALU0570	IA404-B	48.00	38	Failed	34	58	52
MAT02545	ALU0425	IA801-B	30.00	94	Failed	29	39	22
MAT00991	ALU0166	IA101-B	27.33	63	Failed	26	20	36
MAT04428	ALU0738	IA806-B	18.00	78	Failed	30	10	14
MAT05902	ALU0984	IA504-B	35.67	33	Failed	9	55	43
MAT05428	ALU0905	IA204-B	18.00	62	Failed	37	0	17
MAT02646	ALU0441	IA606-B	27.33	58	Failed	59	8	15
MAT03440	ALU0574	IA502-A	36.33	100	Failed	34	58	17
MAT03671	ALU0612	IA305-B	18.67	45	Failed	7	48	1
MAT00642	ALU0107	IA306-B	41.00	100	Failed	58	18	47
MAT03470	ALU0579	IA102-A	31.00	71	Failed	21	13	59
MAT05297	ALU0883	IA705-B	28.00	76	Failed	27	13	44
MAT00961	ALU0161	IA201-B	18.00	79	Failed	15	15	24
MAT05495	ALU0916	IA405-B	24.33	73	Failed	24	41	8
MAT02771	ALU0462	IA605-A	37.33	51	Failed	52	36	24
MAT04051	ALU0676	IA101-B	6.00	60	Failed	6	7	5
MAT03596	ALU0600	IA102-B	15.67	36	Failed	12	12	23
MAT02139	ALU0357	IA803-A	23.00	75	Failed	19	42	8
MAT05377	ALU0897	IA501-B	23.67	41	Failed	13	52	6
MAT05636	ALU0940	IA302-B	40.67	96	Failed	14	51	57
MAT00152	ALU0026	IA402-A	32.67	66	Failed	57	39	2
MAT01868	ALU0312	IA802-A	32.33	79	Failed	37	39	21
MAT05025	ALU0838	IA503-A	40.67	98	Failed	48	22	52
MAT03142	ALU0524	IA204-B	18.33	54	Failed	9	33	13
MAT01297	ALU0217	IA501-B	31.33	91	Failed	41	18	35
MAT03041	ALU0507	IA305-B	23.00	40	Failed	17	23	29
MAT01688	ALU0282	IA802-B	19.67	75	Failed	10	31	18
MAT02183	ALU0364	IA105-A	26.67	69	Failed	24	55	1
MAT01555	ALU0260	IA801-B	19.00	46	Failed	3	29	25
MAT04759	ALU0794	IA701-B	34.67	55	Failed	11	44	49
MAT02111	ALU0352	IA205-A	11.00	50	Failed	12	13	8
MAT03364	ALU0561	IA804-B	17.33	96	Failed	16	2	34
MAT04145	ALU0691	IA505-B	30.00	53	Failed	3	57	30
MAT02281	ALU0381	IA701-B	17.33	70	Failed	8	37	7
MAT05846	ALU0975	IA402-B	22.00	57	Failed	28	38	0
MAT00802	ALU0134	IA504-A	28.33	95	Failed	26	57	2
MAT00377	ALU0063	IA805-B	22.67	93	Failed	29	14	25
MAT00336	ALU0056	IA106-B	39.00	53	Failed	8	56	53
MAT03052	ALU0509	IA804-B	22.33	38	Failed	44	11	12
MAT01513	ALU0253	IA601-B	41.33	86	Failed	38	38	48
MAT02115	ALU0353	IA303-B	22.00	46	Failed	29	8	29
MAT04904	ALU0818	IA702-A	30.33	48	Failed	21	49	21
MAT00683	ALU0114	IA805-B	25.67	47	Failed	23	30	24
MAT04159	ALU0694	IA301-B	11.67	56	Failed	16	13	6
MAT03162	ALU0527	IA206-A	37.67	45	Failed	56	11	46
MAT01381	ALU0231	IA501-B	30.67	77	Failed	47	1	44
MAT02389	ALU0399	IA801-B	17.33	54	Failed	15	1	36
MAT04723	ALU0788	IA101-A	32.00	39	Failed	50	1	45
MAT00710	ALU0119	IA402-B	22.67	34	Failed	46	12	10
MAT01419	ALU0237	IA303-B	17.33	81	Failed	27	22	3
MAT03051	ALU0509	IA803-B	26.33	80	Failed	30	39	10
MAT03637	ALU0607	IA301-A	11.67	98	Failed	5	4	26
MAT00351	ALU0059	IA403-B	17.33	46	Failed	9	6	37
MAT01677	ALU0280	IA703-A	19.00	92	Failed	36	6	15
MAT01405	ALU0235	IA601-A	7.00	51	Failed	18	0	3
MAT01518	ALU0253	IA606-B	36.33	94	Failed	34	26	49
MAT02585	ALU0431	IA205-A	29.67	48	Failed	54	21	14
MAT00832	ALU0139	IA504-B	23.33	77	Failed	19	19	32
MAT03155	ALU0526	IA505-B	44.00	64	Failed	52	36	44
MAT01146	ALU0191	IA606-A	47.00	40	Failed	54	51	36
MAT02610	ALU0435	IA606-B	43.33	85	Failed	36	36	58
MAT05250	ALU0875	IA706-B	28.67	34	Failed	2	42	42
MAT05161	ALU0861	IA201-B	33.00	73	Failed	36	50	13
MAT03717	ALU0620	IA403-B	25.33	50	Failed	6	38	32
MAT01730	ALU0289	IA402-B	41.00	98	Failed	25	56	42
MAT00363	ALU0061	IA803-B	25.00	72	Failed	1	39	35
MAT02091	ALU0349	IA803-B	20.00	80	Failed	18	12	30
MAT05949	ALU0992	IA303-A	27.33	95	Failed	14	44	24
MAT05215	ALU0870	IA801-B	31.00	75	Failed	29	15	49
MAT03394	ALU0566	IA604-B	30.67	45	Failed	11	26	55
MAT02324	ALU0388	IA802-B	14.33	66	Failed	4	23	16
MAT02891	ALU0482	IA805-B	34.33	63	Failed	8	44	51
MAT00571	ALU0096	IA101-A	43.33	98	Failed	50	43	37
MAT05352	ALU0892	IA406-B	35.33	88	Failed	22	41	43
MAT01900	ALU0317	IA804-A	31.67	30	Failed	33	59	3
MAT00276	ALU0046	IA506-B	21.00	44	Failed	26	10	27
MAT01420	ALU0237	IA304-B	24.33	65	Failed	12	20	41
MAT01890	ALU0315	IA206-A	38.33	57	Failed	42	32	41
MAT01024	ALU0171	IA104-A	39.33	62	Failed	13	51	54
MAT05906	ALU0985	IA802-B	40.00	82	Failed	51	32	37
MAT02122	ALU0354	IA704-B	46.00	46	Failed	59	38	41
MAT01756	ALU0293	IA804-B	32.67	38	Failed	0	47	51
MAT02658	ALU0443	IA106-A	19.33	87	Failed	25	6	27
MAT03636	ALU0606	IA306-B	20.33	60	Failed	9	41	11
MAT02782	ALU0464	IA304-B	35.67	71	Failed	10	53	44
MAT02607	ALU0435	IA603-B	52.67	61	Failed	53	53	52
MAT00234	ALU0039	IA206-B	32.67	39	Failed	59	34	5
MAT03603	ALU0601	IA603-B	18.00	62	Failed	20	22	12
MAT03543	ALU0591	IA603-B	33.67	93	Failed	17	34	50
MAT02415	ALU0403	IA103-B	35.67	30	Failed	55	27	25
MAT04242	ALU0707	IA706-A	16.33	82	Failed	34	15	0
MAT05432	ALU0906	IA102-B	19.00	84	Failed	10	37	10
MAT04092	ALU0682	IA406-B	29.00	90	Failed	0	46	41
MAT03503	ALU0584	IA105-A	33.00	80	Failed	8	54	37
MAT00719	ALU0120	IA805-B	26.33	85	Failed	25	32	22
MAT05003	ALU0834	IA105-B	38.00	92	Failed	43	43	28
MAT03623	ALU0604	IA405-A	3.33	68	Failed	2	8	0
MAT04305	ALU0718	IA703-A	23.67	77	Failed	12	45	14
MAT03124	ALU0521	IA504-B	42.67	100	Failed	30	46	52
MAT03865	ALU0645	IA601-B	27.67	55	Failed	22	20	41
MAT05752	ALU0959	IA604-B	31.00	52	Failed	52	38	3
MAT05150	ALU0859	IA202-B	24.33	50	Failed	59	5	9
MAT03237	ALU0540	IA403-A	42.00	81	Failed	50	41	35
MAT04829	ALU0805	IA805-A	42.33	54	Failed	21	54	52
MAT04400	ALU0734	IA202-B	16.33	37	Failed	2	10	37
MAT01532	ALU0256	IA502-A	37.33	52	Failed	53	31	28
MAT01633	ALU0273	IA401-A	33.33	67	Failed	21	21	58
MAT00109	ALU0019	IA101-B	46.67	46	Failed	28	57	55
MAT02762	ALU0461	IA102-B	15.33	86	Failed	11	6	29
MAT00514	ALU0086	IA804-A	28.67	59	Failed	11	57	18
MAT03802	ALU0634	IA304-B	22.67	42	Failed	7	30	31
MAT03266	ALU0545	IA402-B	40.67	47	Failed	16	49	57
MAT01681	ALU0281	IA101-B	30.33	99	Failed	40	37	14
MAT00477	ALU0080	IA203-A	38.00	99	Failed	57	2	55
MAT03571	ALU0596	IA101-B	21.67	85	Failed	3	58	4
MAT04979	ALU0830	IA205-B	36.67	90	Failed	22	59	29
MAT00645	ALU0108	IA403-A	49.67	83	Failed	57	37	55
MAT02871	ALU0479	IA403-B	30.33	73	Failed	39	4	48
MAT05797	ALU0967	IA401-B	44.33	69	Failed	28	48	57
MAT01716	ALU0286	IA206-A	37.00	56	Failed	49	11	51
MAT02987	ALU0498	IA305-B	48.00	97	Failed	47	38	59
MAT04268	ALU0712	IA802-A	23.33	67	Failed	6	52	12
MAT01082	ALU0181	IA702-B	28.67	98	Failed	11	46	29
MAT05186	ALU0865	IA402-B	33.00	60	Failed	46	49	4
MAT03384	ALU0564	IA206-B	25.00	33	Failed	49	23	3
MAT00732	ALU0122	IA506-B	28.67	57	Failed	11	34	41
MAT05555	ALU0926	IA705-B	30.00	36	Failed	21	21	48
MAT04617	ALU0770	IA603-B	21.00	83	Failed	24	9	30
MAT02582	ALU0431	IA202-A	25.00	32	Failed	8	22	45
MAT05130	ALU0855	IA406-B	24.33	68	Failed	17	5	51
MAT01156	ALU0193	IA504-A	29.33	74	Failed	34	36	18
MAT05873	ALU0979	IA605-B	30.00	36	Failed	31	1	58
MAT04942	ALU0824	IA304-B	10.67	90	Failed	1	10	21
MAT04133	ALU0689	IA605-A	28.00	97	Failed	4	45	35
MAT04908	ALU0818	IA706-A	26.33	77	Failed	47	31	1
MAT00324	ALU0054	IA406-A	21.33	100	Failed	40	1	23
MAT05640	ALU0940	IA306-B	35.00	56	Failed	48	12	45
MAT03069	ALU0512	IA203-A	23.00	58	Failed	6	59	4
MAT05862	ALU0977	IA106-B	14.33	93	Failed	12	7	24
MAT05657	ALU0943	IA505-A	37.67	31	Failed	55	21	37
MAT00560	ALU0094	IA602-A	13.33	65	Failed	8	2	30
MAT05654	ALU0943	IA502-A	29.33	59	Failed	55	15	18
MAT02481	ALU0414	IA503-A	30.33	45	Failed	27	28	36
MAT01669	ALU0279	IA201-B	34.00	33	Failed	55	40	7
MAT00517	ALU0087	IA801-B	27.00	69	Failed	12	51	18
MAT03089	ALU0515	IA205-B	25.67	43	Failed	40	14	23
MAT02966	ALU0495	IA402-A	28.33	32	Failed	53	28	4
MAT04858	ALU0810	IA804-B	30.33	46	Failed	46	35	10
MAT00370	ALU0062	IA204-A	10.00	75	Failed	16	9	5
MAT03382	ALU0564	IA204-B	25.33	56	Failed	11	7	58
MAT03605	ALU0601	IA605-B	25.33	60	Failed	31	14	31
MAT05724	ALU0954	IA506-B	25.67	59	Failed	22	50	5
MAT02006	ALU0335	IA502-B	10.33	32	Failed	14	2	15
MAT03803	ALU0634	IA305-B	38.00	58	Failed	21	53	40
MAT00312	ALU0052	IA706-A	23.00	89	Failed	20	49	0
MAT02860	ALU0477	IA304-A	39.00	41	Failed	51	16	50
MAT00292	ALU0049	IA504-B	29.33	77	Failed	40	23	25
MAT01498	ALU0250	IA304-B	29.33	34	Failed	13	54	21
MAT03336	ALU0556	IA606-B	18.00	93	Failed	34	4	16
MAT02023	ALU0338	IA101-B	47.67	32	Failed	50	45	48
MAT00899	ALU0150	IA605-B	46.33	86	Failed	29	58	52
MAT02493	ALU0416	IA803-B	14.67	86	Failed	1	4	39
MAT01739	ALU0290	IA405-B	9.67	44	Failed	4	22	3
MAT02759	ALU0460	IA505-B	37.67	85	Failed	28	51	34
MAT01771	ALU0296	IA801-A	35.00	38	Failed	28	49	28
MAT00697	ALU0117	IA501-A	37.33	73	Failed	51	32	29
MAT03696	ALU0616	IA306-B	10.33	59	Failed	4	15	12
MAT04997	ALU0833	IA605-B	24.67	86	Failed	55	1	18
MAT02775	ALU0463	IA603-A	29.67	91	Failed	52	5	32
MAT02990	ALU0499	IA302-B	25.33	65	Failed	45	14	17
MAT05788	ALU0965	IA704-B	23.33	46	Failed	35	24	11
MAT05464	ALU0911	IA504-A	20.67	66	Failed	10	19	33
MAT01266	ALU0211	IA206-B	24.67	89	Failed	3	26	45
MAT04926	ALU0821	IA806-A	19.00	56	Failed	17	21	19
MAT01884	ALU0314	IA106-B	33.33	77	Failed	5	52	43
MAT05841	ALU0974	IA303-B	29.67	47	Failed	41	2	46
MAT04792	ALU0799	IA804-B	23.33	100	Failed	38	1	31
MAT00288	ALU0048	IA806-A	31.33	78	Failed	17	21	56
MAT04019	ALU0670	IA205-A	39.33	67	Failed	21	48	49
MAT01988	ALU0332	IA702-B	37.00	65	Failed	33	51	27
MAT04006	ALU0668	IA304-B	27.00	33	Failed	38	2	41
MAT01158	ALU0193	IA506-A	34.33	43	Failed	40	14	49
MAT01315	ALU0220	IA601-B	40.67	71	Failed	49	53	20
MAT03783	ALU0631	IA303-B	31.00	40	Failed	31	19	43
MAT01001	ALU0167	IA705-B	30.67	57	Failed	32	42	18
MAT00773	ALU0129	IA605-B	27.00	52	Failed	26	12	43
MAT01091	ALU0182	IA805-A	20.33	60	Failed	29	14	18
MAT00942	ALU0157	IA206-A	19.33	46	Failed	20	2	36
MAT03580	ALU0597	IA704-A	32.67	45	Failed	32	24	42
MAT01243	ALU0208	IA101-A	22.00	71	Failed	42	10	14
MAT00692	ALU0116	IA702-A	24.67	47	Failed	42	12	20
MAT01148	ALU0192	IA402-B	31.33	90	Failed	24	40	30
MAT01923	ALU0321	IA203-B	37.33	49	Failed	58	35	19
MAT02657	ALU0443	IA105-A	23.00	53	Failed	53	12	4
MAT01225	ALU0205	IA601-A	37.67	90	Failed	42	26	45
MAT05246	ALU0875	IA702-B	26.00	53	Failed	57	2	19
MAT05487	ALU0915	IA703-B	8.33	63	Failed	19	0	6
MAT01234	ALU0206	IA504-A	14.67	81	Failed	11	29	4
MAT00535	ALU0090	IA101-B	37.67	72	Failed	48	53	12
MAT04472	ALU0746	IA102-B	28.00	43	Failed	50	3	31
MAT03652	ALU0609	IA304-A	41.00	88	Failed	57	37	29
MAT05486	ALU0915	IA702-B	27.33	67	Failed	18	38	26
MAT05818	ALU0970	IA504-B	24.00	82	Failed	1	34	37
MAT00587	ALU0098	IA205-A	31.00	97	Failed	36	10	47
MAT01604	ALU0268	IA202-B	12.67	54	Failed	23	12	3
MAT00870	ALU0145	IA706-B	25.00	55	Failed	4	21	50
MAT02822	ALU0471	IA302-B	23.00	40	Failed	18	8	43
MAT02554	ALU0426	IA504-B	17.67	30	Failed	25	20	8
MAT03151	ALU0526	IA501-B	23.33	63	Failed	38	15	17
MAT04798	ALU0800	IA604-B	32.00	77	Failed	4	44	48
MAT02311	ALU0386	IA601-A	38.00	52	Failed	29	38	47
MAT00714	ALU0119	IA406-B	38.00	79	Failed	41	59	14
MAT03326	ALU0555	IA302-B	24.33	61	Failed	21	47	5
MAT01859	ALU0310	IA505-B	35.33	30	Failed	19	28	59
MAT03308	ALU0552	IA402-B	57.33	93	Failed	58	59	55
MAT05213	ALU0869	IA805-B	34.00	65	Failed	47	51	4
MAT02565	ALU0428	IA203-A	26.67	95	Failed	19	5	56
MAT03668	ALU0612	IA302-B	49.33	65	Failed	56	40	52
MAT04204	ALU0701	IA704-B	12.33	41	Failed	3	1	33
MAT00308	ALU0052	IA702-A	26.33	53	Failed	15	49	15
MAT01000	ALU0167	IA704-B	43.33	36	Failed	40	53	37
MAT01917	ALU0320	IA703-B	53.00	32	Failed	57	58	44
MAT02824	ALU0471	IA304-B	25.00	79	Failed	19	29	27
MAT01099	ALU0184	IA301-A	19.33	61	Failed	9	5	44
MAT02625	ALU0438	IA103-B	46.00	34	Failed	50	44	44
MAT02210	ALU0369	IA302-B	33.00	35	Failed	15	38	46
MAT00990	ALU0165	IA506-B	32.67	35	Failed	8	57	33
MAT04027	ALU0672	IA801-B	33.33	55	Failed	1	54	45
MAT01519	ALU0254	IA601-A	29.00	76	Failed	25	17	45
MAT00513	ALU0086	IA803-A	43.67	66	Failed	52	27	52
MAT04582	ALU0764	IA404-A	11.33	72	Failed	17	6	11
MAT05972	ALU0996	IA102-A	24.00	83	Failed	10	32	30
MAT02883	ALU0481	IA203-B	20.33	33	Failed	25	30	6
MAT04055	ALU0676	IA105-B	20.00	34	Failed	9	11	40
MAT05072	ALU0846	IA202-A	22.33	33	Failed	12	23	32
MAT01115	ALU0186	IA205-B	36.67	97	Failed	0	52	58
MAT05248	ALU0875	IA704-B	24.67	43	Failed	40	9	25
MAT03042	ALU0507	IA306-B	31.67	78	Failed	28	22	45
MAT01192	ALU0199	IA304-A	17.33	94	Failed	7	17	28
MAT00334	ALU0056	IA104-B	18.67	40	Failed	43	13	0
MAT00521	ALU0087	IA805-B	28.00	44	Failed	11	41	32
MAT05462	ALU0911	IA502-A	32.33	99	Failed	45	29	23
MAT04506	ALU0751	IA606-B	18.67	70	Failed	27	2	27
MAT00663	ALU0111	IA803-A	20.33	98	Failed	1	36	24
MAT00938	ALU0157	IA202-A	20.00	33	Failed	21	29	10
MAT03642	ALU0607	IA306-A	18.33	40	Failed	2	7	46
MAT04928	ALU0822	IA402-B	31.33	84	Failed	58	9	27
MAT00445	ALU0075	IA501-B	14.33	54	Failed	4	11	28
MAT01878	ALU0313	IA806-A	20.33	66	Failed	22	28	11
MAT02772	ALU0462	IA606-A	49.67	99	Failed	52	41	56
MAT00348	ALU0058	IA106-B	19.33	40	Failed	32	6	20
MAT03506	ALU0585	IA702-A	34.67	56	Failed	58	30	16
MAT00355	ALU0060	IA101-A	24.67	65	Failed	25	11	38
MAT00810	ALU0135	IA306-B	26.33	82	Failed	18	35	26
MAT03716	ALU0620	IA402-B	26.00	92	Failed	29	26	23
MAT01244	ALU0208	IA102-A	43.67	72	Failed	51	55	25
MAT05695	ALU0950	IA201-A	43.00	61	Failed	40	33	56
MAT02637	ALU0440	IA503-A	29.00	76	Failed	53	17	17
MAT01881	ALU0314	IA103-B	23.67	52	Failed	3	24	44
MAT03128	ALU0522	IA402-B	36.00	97	Failed	49	44	15
MAT03823	ALU0638	IA401-B	21.67	47	Failed	10	34	21
MAT01124	ALU0188	IA802-B	25.33	98	Failed	42	34	0
MAT04863	ALU0811	IA403-B	29.00	72	Failed	6	31	50
MAT03774	ALU0629	IA406-A	19.00	55	Failed	25	12	20
MAT04841	ALU0807	IA605-B	42.67	31	Failed	46	51	31
MAT02483	ALU0414	IA505-A	31.00	51	Failed	52	3	38
MAT02787	ALU0465	IA503-A	7.67	78	Failed	2	15	6
MAT00158	ALU0027	IA202-B	25.00	54	Failed	10	22	43
MAT02169	ALU0362	IA403-B	31.00	96	Failed	29	43	21
MAT02779	ALU0464	IA301-B	31.67	69	Failed	7	43	45
MAT03296	ALU0550	IA502-A	21.33	32	Failed	22	42	0
MAT01686	ALU0281	IA106-B	21.33	70	Failed	43	5	16
MAT01745	ALU0291	IA105-B	18.33	68	Failed	12	8	35
MAT05563	ALU0928	IA801-B	13.67	71	Failed	2	30	9
MAT04141	ALU0691	IA501-B	21.00	91	Failed	10	30	23
MAT03417	ALU0570	IA403-B	19.00	34	Failed	8	13	36
MAT03125	ALU0521	IA505-B	25.33	34	Failed	6	56	14
MAT04126	ALU0688	IA304-B	23.33	77	Failed	31	15	24
MAT01523	ALU0254	IA605-A	30.00	65	Failed	41	23	26
MAT03119	ALU0520	IA305-A	22.67	77	Failed	3	46	19
MAT01071	ALU0179	IA103-B	32.33	98	Failed	3	56	38
MAT00816	ALU0136	IA306-A	29.00	80	Failed	49	23	15
MAT01058	ALU0177	IA702-B	18.33	66	Failed	34	7	14
MAT00169	ALU0029	IA801-A	16.67	42	Failed	33	14	3
MAT03000	ALU0500	IA706-A	30.00	88	Failed	2	40	48
MAT02113	ALU0353	IA301-B	25.67	83	Failed	31	28	18
MAT04335	ALU0723	IA203-A	31.67	59	Failed	50	35	10
MAT04475	ALU0746	IA105-B	11.00	93	Failed	4	0	29
MAT05413	ALU0903	IA301-B	15.00	76	Failed	2	8	35
MAT04546	ALU0758	IA704-A	11.67	64	Failed	17	9	9
MAT01575	ALU0263	IA803-B	28.00	58	Failed	21	37	26
MAT02858	ALU0477	IA302-A	42.33	76	Failed	57	21	49
MAT00593	ALU0099	IA405-B	23.67	68	Failed	17	45	9
MAT01325	ALU0221	IA805-B	21.33	76	Failed	4	2	58
MAT01797	ALU0300	IA703-B	41.00	94	Failed	35	37	51
MAT01321	ALU0221	IA801-B	23.33	90	Failed	20	37	13
MAT05255	ALU0876	IA805-B	38.00	42	Failed	26	35	53
MAT05840	ALU0974	IA302-B	27.00	39	Failed	31	32	18
MAT00493	ALU0083	IA101-B	40.33	63	Failed	33	33	55
MAT01848	ALU0308	IA106-A	31.33	58	Failed	29	27	38
MAT02104	ALU0351	IA504-B	30.00	30	Failed	38	17	35
MAT01391	ALU0232	IA405-B	39.33	59	Failed	35	55	28
MAT05050	ALU0842	IA504-B	10.33	57	Failed	19	4	8
MAT03345	ALU0558	IA103-B	30.33	34	Failed	46	0	45
MAT05915	ALU0986	IA605-B	22.67	91	Failed	4	24	40
MAT01987	ALU0332	IA701-B	34.67	42	Failed	31	31	42
MAT03005	ALU0501	IA705-A	23.67	49	Failed	13	21	37
MAT00999	ALU0167	IA703-B	50.00	61	Failed	47	55	48
MAT02382	ALU0397	IA306-B	37.33	75	Failed	27	50	35
MAT00819	ALU0137	IA203-A	9.00	49	Failed	17	1	9
MAT03282	ALU0547	IA606-A	9.33	33	Failed	12	9	7
MAT03730	ALU0622	IA104-B	18.67	79	Failed	6	19	31
MAT04982	ALU0831	IA502-B	34.00	51	Failed	31	20	51
MAT02087	ALU0348	IA705-A	26.33	30	Failed	7	51	21
MAT04772	ALU0796	IA702-A	19.00	51	Failed	10	47	0
MAT03672	ALU0612	IA306-B	29.00	65	Failed	18	24	45
MAT00352	ALU0059	IA404-B	24.33	63	Failed	31	38	4
MAT05800	ALU0967	IA404-B	50.33	72	Failed	57	54	40
MAT05329	ALU0889	IA501-B	37.33	32	Failed	31	55	26
MAT05564	ALU0928	IA802-B	9.67	78	Failed	12	17	0
MAT01031	ALU0172	IA505-B	9.33	36	Failed	5	6	17
MAT04821	ALU0804	IA503-B	28.00	69	Failed	29	50	5
MAT02544	ALU0424	IA606-A	24.33	46	Failed	29	33	11
MAT05546	ALU0925	IA202-B	36.33	94	Failed	26	34	49
MAT00117	ALU0020	IA703-B	31.00	60	Failed	43	35	15
MAT04839	ALU0807	IA603-B	43.33	87	Failed	38	43	49
MAT00366	ALU0061	IA806-B	25.33	31	Failed	0	51	25
MAT04663	ALU0778	IA701-A	14.33	45	Failed	5	34	4
MAT00470	ALU0079	IA402-B	23.33	35	Failed	24	27	19
MAT03690	ALU0615	IA306-B	16.33	64	Failed	5	26	18
MAT01473	ALU0246	IA803-A	40.00	47	Failed	30	44	46
MAT04310	ALU0719	IA802-A	54.33	51	Failed	53	55	55
MAT03747	ALU0625	IA603-B	18.00	98	Failed	4	19	31
MAT01824	ALU0304	IA806-B	34.33	37	Failed	36	48	19
MAT03329	ALU0555	IA305-B	40.67	31	Failed	5	59	58
MAT02863	ALU0478	IA401-B	52.00	36	Failed	39	59	58
MAT00776	ALU0130	IA702-A	15.00	45	Failed	11	14	20
MAT04862	ALU0811	IA402-B	25.33	71	Failed	57	7	12
MAT03150	ALU0525	IA806-A	34.00	35	Failed	56	35	11
MAT03601	ALU0601	IA601-B	25.33	46	Failed	21	2	53
MAT03134	ALU0523	IA502-B	23.00	45	Failed	26	39	4
MAT00262	ALU0044	IA304-A	19.00	96	Failed	23	33	1
MAT03200	ALU0534	IA602-B	31.67	32	Failed	38	20	37
MAT03183	ALU0531	IA303-B	38.33	96	Failed	13	43	59
MAT02950	ALU0492	IA704-B	13.00	69	Failed	14	12	13
MAT02262	ALU0377	IA106-A	29.00	60	Failed	51	17	19
MAT02354	ALU0393	IA402-B	38.00	32	Failed	59	42	13
MAT03435	ALU0573	IA303-B	27.67	68	Failed	35	36	12
MAT04439	ALU0740	IA805-B	15.33	41	Failed	14	7	25
MAT02424	ALU0404	IA306-B	39.33	30	Failed	59	35	24
MAT00271	ALU0046	IA501-B	26.00	52	Failed	10	11	57
MAT05691	ALU0949	IA303-A	31.33	70	Failed	7	39	48
MAT00224	ALU0038	IA702-B	34.33	58	Failed	15	35	53
MAT03868	ALU0645	IA604-B	20.00	94	Failed	0	55	5
MAT02575	ALU0430	IA101-B	31.67	99	Failed	33	30	32
MAT01577	ALU0263	IA805-B	45.00	48	Failed	26	51	58
MAT01460	ALU0244	IA302-B	14.33	50	Failed	7	25	11
MAT01238	ALU0207	IA302-A	22.00	77	Failed	15	38	13
MAT03629	ALU0605	IA305-A	13.00	92	Failed	6	28	5
MAT03164	ALU0528	IA302-B	42.67	45	Failed	50	40	38
MAT01764	ALU0294	IA506-A	28.33	96	Failed	22	34	29
MAT02434	ALU0406	IA404-B	22.33	88	Failed	43	9	15
MAT01062	ALU0177	IA706-B	17.67	43	Failed	9	16	28
MAT04510	ALU0752	IA404-B	32.33	30	Failed	31	32	34
MAT00389	ALU0065	IA705-A	7.33	89	Failed	7	0	15
MAT03524	ALU0588	IA402-A	25.67	54	Failed	25	6	46
MAT03984	ALU0664	IA106-B	25.00	89	Failed	35	32	8
MAT04879	ALU0814	IA201-B	36.00	94	Failed	31	58	19
MAT01744	ALU0291	IA104-B	27.33	64	Failed	14	22	46
MAT05373	ALU0896	IA603-B	28.00	63	Failed	41	14	29
MAT04527	ALU0755	IA603-B	23.33	82	Failed	14	10	46
MAT03980	ALU0664	IA102-B	53.33	85	Failed	58	43	59
MAT02254	ALU0376	IA804-B	26.67	95	Failed	53	23	4
MAT04046	ALU0675	IA302-A	25.67	39	Failed	18	53	6
MAT03539	ALU0590	IA105-B	31.67	87	Failed	5	39	51
MAT01758	ALU0293	IA806-B	16.33	58	Failed	17	7	25
MAT02817	ALU0470	IA203-B	28.67	52	Failed	4	47	35
MAT02204	ALU0368	IA402-B	25.33	34	Failed	3	19	54
MAT02094	ALU0349	IA806-B	30.33	40	Failed	44	20	27
MAT01676	ALU0280	IA702-A	14.67	100	Failed	42	1	1
MAT01785	ALU0298	IA803-B	25.33	82	Failed	40	28	8
MAT05694	ALU0949	IA306-A	19.33	89	Failed	21	10	27
MAT01972	ALU0329	IA104-B	33.00	54	Failed	44	17	38
MAT01946	ALU0325	IA602-B	31.33	98	Failed	6	48	40
MAT02743	ALU0458	IA201-B	41.33	58	Failed	47	22	55
MAT01044	ALU0174	IA706-B	34.33	80	Failed	31	48	24
MAT04745	ALU0791	IA105-A	25.67	81	Failed	35	35	7
MAT01475	ALU0246	IA805-A	36.00	93	Failed	39	28	41
MAT04096	ALU0683	IA604-B	23.33	95	Failed	49	5	16
MAT05720	ALU0954	IA502-B	29.67	31	Failed	42	10	37
MAT01880	ALU0314	IA102-B	30.67	99	Failed	55	2	35
MAT02902	ALU0484	IA204-B	43.67	53	Failed	41	56	34
MAT04650	ALU0775	IA806-B	44.00	82	Failed	58	46	28
MAT02124	ALU0354	IA706-B	33.00	58	Failed	45	37	17
MAT05776	ALU0963	IA304-B	12.67	94	Failed	14	4	20
MAT00309	ALU0052	IA703-A	27.00	70	Failed	10	44	27
MAT02092	ALU0349	IA804-B	48.00	57	Failed	27	59	58
MAT05411	ALU0902	IA405-B	29.00	40	Failed	0	37	50
MAT04443	ALU0741	IA403-B	32.00	98	Failed	35	9	52
MAT03710	ALU0619	IA202-B	39.00	36	Failed	48	56	13
MAT00591	ALU0099	IA403-B	2.33	98	Failed	3	1	3
MAT01345	ALU0225	IA301-A	19.67	69	Failed	31	25	3
MAT05591	ALU0932	IA305-B	43.67	63	Failed	59	20	52
MAT00344	ALU0058	IA102-B	21.33	39	Failed	1	41	22
MAT02178	ALU0363	IA806-B	47.00	94	Failed	58	27	56
MAT01515	ALU0253	IA603-B	50.00	60	Failed	49	52	49
MAT05738	ALU0957	IA502-B	36.67	51	Failed	53	27	30
MAT05478	ALU0913	IA206-B	18.33	51	Failed	1	32	22
MAT01871	ALU0312	IA805-A	18.33	46	Failed	33	9	13
MAT03021	ALU0504	IA503-B	28.00	49	Failed	38	21	25
MAT00994	ALU0166	IA104-B	23.67	96	Failed	33	37	1
MAT04948	ALU0825	IA504-B	35.67	84	Failed	26	54	27
MAT02589	ALU0432	IA203-A	22.00	64	Failed	10	44	12
MAT03256	ALU0543	IA204-A	38.33	55	Failed	28	43	44
MAT03001	ALU0501	IA701-A	28.00	58	Failed	25	39	20
MAT00529	ALU0089	IA201-A	41.33	56	Failed	31	50	43
MAT00857	ALU0143	IA205-A	29.67	89	Failed	19	57	13
MAT05438	ALU0907	IA202-B	31.67	58	Failed	13	35	47
MAT02253	ALU0376	IA803-B	25.00	31	Failed	41	32	2
MAT01012	ALU0169	IA204-B	49.00	44	Failed	40	54	53
MAT03545	ALU0591	IA605-B	30.67	38	Failed	35	5	52
MAT03498	ALU0583	IA106-A	17.33	62	Failed	27	11	14
MAT05341	ALU0891	IA301-B	22.67	38	Failed	58	3	7
MAT03485	ALU0581	IA305-B	45.33	36	Failed	54	38	44
MAT00968	ALU0162	IA402-B	28.00	97	Failed	45	5	34
MAT00428	ALU0072	IA402-B	21.67	43	Failed	7	13	45
MAT05196	ALU0866	IA306-B	34.33	72	Failed	49	42	12
MAT04899	ALU0817	IA703-A	40.33	61	Failed	20	43	58
MAT03594	ALU0599	IA706-B	52.33	50	Failed	53	55	49
MAT02510	ALU0419	IA502-B	28.67	31	Failed	36	32	18
MAT00349	ALU0059	IA401-B	13.00	44	Failed	11	21	7
MAT00742	ALU0124	IA804-B	49.67	93	Failed	53	41	55
MAT03766	ALU0628	IA404-B	30.33	99	Failed	35	10	46
MAT01613	ALU0269	IA605-B	46.33	92	Failed	35	58	46
MAT04946	ALU0825	IA502-B	38.00	64	Failed	55	35	24
MAT02208	ALU0368	IA406-B	35.33	42	Failed	47	46	13
MAT00437	ALU0073	IA605-B	38.00	56	Failed	38	44	32
MAT01810	ALU0302	IA804-B	21.33	92	Failed	38	18	8
MAT02729	ALU0455	IA805-B	21.67	76	Failed	2	57	6
MAT01786	ALU0298	IA804-B	30.00	63	Failed	28	39	23
MAT04374	ALU0729	IA606-A	41.67	46	Failed	55	57	13
MAT03737	ALU0623	IA605-A	29.67	61	Failed	29	27	33
MAT04761	ALU0794	IA703-B	27.67	33	Failed	35	38	10
MAT03600	ALU0600	IA106-B	28.67	90	Failed	17	59	10
MAT01674	ALU0279	IA206-B	26.00	76	Failed	7	51	20
MAT00154	ALU0026	IA404-A	42.67	45	Failed	44	54	30
MAT04747	ALU0792	IA601-B	20.67	94	Failed	8	3	51
MAT02171	ALU0362	IA405-B	29.00	49	Failed	29	58	0
MAT02993	ALU0499	IA305-B	44.67	92	Failed	41	51	42
MAT00598	ALU0100	IA404-B	34.67	57	Failed	32	49	23
MAT00833	ALU0139	IA505-B	11.00	38	Failed	0	25	8
MAT03109	ALU0519	IA501-B	54.33	57	Failed	54	57	52
MAT05960	ALU0994	IA802-A	21.67	89	Failed	32	27	6
MAT01718	ALU0287	IA502-A	34.67	90	Failed	45	9	50
MAT05518	ALU0920	IA804-A	32.33	46	Failed	41	1	55
MAT05083	ALU0848	IA101-A	21.33	88	Failed	15	14	35
MAT03121	ALU0521	IA501-B	24.00	92	Failed	51	10	11
MAT04008	ALU0668	IA306-B	33.67	50	Failed	57	10	34
MAT05682	ALU0947	IA806-A	28.33	68	Failed	13	39	33
MAT00848	ALU0142	IA602-B	41.00	74	Failed	35	30	58
MAT04918	ALU0820	IA204-A	35.33	88	Failed	19	41	46
MAT05350	ALU0892	IA404-B	18.33	100	Failed	15	25	15
MAT03715	ALU0620	IA401-B	35.33	38	Failed	47	47	12
MAT02801	ALU0467	IA305-B	23.33	71	Failed	37	11	22
MAT03177	ALU0530	IA803-B	29.00	47	Failed	23	46	18
MAT05489	ALU0915	IA705-B	42.33	89	Failed	48	46	33
MAT02586	ALU0431	IA206-A	28.33	86	Failed	26	50	9
MAT04392	ALU0732	IA306-A	23.67	34	Failed	27	19	25
MAT01300	ALU0217	IA504-B	33.00	41	Failed	46	14	39
MAT05598	ALU0933	IA706-B	25.00	67	Failed	30	12	33
MAT02679	ALU0447	IA103-B	46.33	80	Failed	37	56	46
MAT04063	ALU0678	IA201-B	36.00	78	Failed	43	22	43
MAT03311	ALU0552	IA405-B	37.33	35	Failed	42	42	28
MAT02542	ALU0424	IA604-A	44.00	79	Failed	54	57	21
MAT02846	ALU0475	IA802-B	40.67	65	Failed	29	46	47
MAT05422	ALU0904	IA504-B	13.33	49	Failed	18	7	15
MAT00082	ALU0014	IA304-B	38.67	49	Failed	7	59	50
MAT00001	ALU0001	IA201-B	26.00	55	Failed	11	45	22
MAT02185	ALU0365	IA201-A	40.67	93	Failed	55	28	39
MAT03410	ALU0569	IA102-B	40.67	57	Failed	51	25	46
MAT01275	ALU0213	IA203-B	10.67	99	Failed	2	7	23
MAT02257	ALU0377	IA101-A	25.33	43	Failed	14	33	29
MAT05063	ALU0844	IA205-A	36.67	96	Failed	55	48	7
MAT04403	ALU0734	IA205-B	38.67	84	Failed	52	19	45
MAT02370	ALU0395	IA306-B	24.00	49	Failed	36	31	5
MAT02955	ALU0493	IA303-A	13.33	32	Failed	11	24	5
MAT02290	ALU0382	IA204-A	33.33	79	Failed	38	44	18
MAT00293	ALU0049	IA505-B	39.33	97	Failed	54	20	44
MAT03502	ALU0584	IA104-A	14.00	42	Failed	22	15	5
MAT05670	ALU0945	IA306-B	50.00	39	Failed	46	55	49
MAT03405	ALU0568	IA703-A	24.33	93	Failed	18	39	16
MAT05135	ALU0856	IA605-B	18.67	30	Failed	38	6	12
MAT04189	ALU0699	IA801-B	38.33	33	Failed	27	46	42
MAT00314	ALU0053	IA802-A	49.00	86	Failed	55	37	55
MAT05852	ALU0976	IA302-A	29.00	43	Failed	42	10	35
MAT00302	ALU0051	IA102-A	46.33	66	Failed	33	52	54
MAT03366	ALU0561	IA806-B	36.00	56	Failed	28	49	31
MAT01379	ALU0230	IA805-B	26.67	55	Failed	12	51	17
MAT03086	ALU0515	IA202-B	22.67	83	Failed	12	35	21
MAT01728	ALU0288	IA206-B	18.00	87	Failed	32	4	18
MAT02624	ALU0438	IA102-B	30.00	80	Failed	20	49	21
MAT00394	ALU0066	IA304-B	36.67	90	Failed	31	35	44
MAT01430	ALU0239	IA102-B	21.33	51	Failed	12	29	23
MAT04693	ALU0783	IA501-A	45.33	99	Failed	54	56	26
MAT02605	ALU0435	IA601-B	23.00	42	Failed	11	58	0
MAT00971	ALU0162	IA405-B	49.33	90	Failed	49	44	55
MAT05501	ALU0917	IA205-B	22.33	40	Failed	17	15	35
MAT02524	ALU0421	IA304-B	36.00	59	Failed	39	28	41
MAT04998	ALU0833	IA606-B	35.67	46	Failed	47	7	53
MAT01311	ALU0219	IA103-A	40.67	30	Failed	48	48	26
MAT05975	ALU0996	IA105-A	16.00	32	Failed	10	9	29
MAT02136	ALU0356	IA806-B	26.00	40	Failed	32	21	25
MAT04833	ALU0806	IA303-A	22.33	60	Failed	5	50	12
MAT00751	ALU0126	IA701-B	28.67	49	Failed	7	43	36
MAT05597	ALU0933	IA705-B	42.00	80	Failed	49	57	20
MAT04112	ALU0686	IA302-B	32.67	79	Failed	38	52	8
MAT04867	ALU0812	IA401-A	37.33	77	Failed	9	57	46
MAT01032	ALU0172	IA506-B	34.67	86	Failed	43	43	18
MAT03443	ALU0574	IA505-A	16.33	32	Failed	1	17	31
MAT05030	ALU0839	IA202-B	11.00	35	Failed	5	26	2
MAT00198	ALU0033	IA206-B	26.00	99	Failed	43	5	30
MAT04455	ALU0743	IA503-A	27.33	72	Failed	59	1	22
MAT01015	ALU0170	IA401-B	24.67	96	Failed	18	33	23
MAT00326	ALU0055	IA202-A	29.00	36	Failed	45	23	19
MAT05570	ALU0929	IA802-A	8.33	81	Failed	12	4	9
MAT04036	ALU0673	IA404-B	15.00	34	Failed	19	0	26
MAT00959	ALU0160	IA505-A	19.33	97	Failed	8	27	23
MAT04315	ALU0720	IA701-B	39.33	64	Failed	49	53	16
MAT04295	ALU0716	IA105-B	40.00	59	Failed	50	33	37
MAT01128	ALU0188	IA806-B	42.00	40	Failed	56	54	16
MAT02190	ALU0365	IA206-A	36.00	68	Failed	28	44	36
MAT05562	ALU0927	IA606-B	23.33	53	Failed	47	16	7
MAT00207	ALU0035	IA503-B	33.67	77	Failed	31	35	35
MAT05458	ALU0910	IA304-A	26.00	69	Failed	34	0	44
MAT03322	ALU0554	IA304-B	30.00	79	Failed	11	34	45
MAT01184	ALU0198	IA402-A	48.67	94	Failed	55	33	58
MAT02010	ALU0335	IA506-B	22.67	97	Failed	20	32	16
MAT00149	ALU0025	IA705-B	43.00	38	Failed	43	45	41
MAT05045	ALU0841	IA605-B	36.33	54	Failed	53	41	15
MAT05766	ALU0961	IA306-B	31.67	30	Failed	39	7	49
MAT01366	ALU0228	IA404-B	47.00	99	Failed	44	58	39
MAT01214	ALU0203	IA102-A	37.33	76	Failed	33	54	25
MAT02381	ALU0397	IA305-B	14.67	75	Failed	23	0	21
MAT05537	ALU0923	IA505-A	37.67	98	Failed	57	0	56
MAT02866	ALU0478	IA404-B	27.00	46	Failed	37	3	41
MAT01927	ALU0322	IA501-B	27.33	92	Failed	43	20	19
MAT01450	ALU0242	IA404-A	34.67	92	Failed	59	3	42
MAT01414	ALU0236	IA604-B	17.67	31	Failed	4	26	23
MAT01061	ALU0177	IA705-B	30.00	43	Failed	53	16	21
MAT02207	ALU0368	IA405-B	21.67	65	Failed	19	5	41
MAT02003	ALU0334	IA205-A	17.67	36	Failed	45	5	3
MAT04962	ALU0827	IA206-B	12.00	95	Failed	13	15	8
MAT05940	ALU0990	IA106-A	28.33	84	Failed	33	48	4
MAT02315	ALU0386	IA605-A	36.67	59	Failed	48	49	13
MAT01127	ALU0188	IA805-B	7.67	64	Failed	5	4	14
MAT03353	ALU0559	IA405-A	13.33	80	Failed	40	0	0
MAT05820	ALU0970	IA506-B	33.67	58	Failed	43	28	30
MAT05259	ALU0877	IA103-B	7.67	34	Failed	0	21	2
MAT01924	ALU0321	IA204-B	41.33	30	Failed	43	47	34
MAT02998	ALU0500	IA704-A	90.00	82	Approved	80	100	90
MAT05933	ALU0989	IA505-A	88.00	100	Approved	81	99	84
MAT03894	ALU0649	IA306-B	78.00	90	Approved	91	76	67
MAT00962	ALU0161	IA202-B	89.33	88	Approved	89	87	92
MAT04417	ALU0737	IA701-B	83.33	93	Approved	91	96	63
MAT03788	ALU0632	IA802-B	44.00	73	Failed	51	46	35
MAT05747	ALU0958	IA505-B	37.33	58	Failed	48	32	32
MAT05097	ALU0850	IA103-B	32.67	52	Failed	6	54	38
MAT02022	ALU0337	IA306-B	40.33	34	Failed	43	55	23
MAT04424	ALU0738	IA802-B	26.33	65	Failed	27	39	13
MAT05934	ALU0989	IA506-A	30.67	75	Failed	25	50	17
MAT01435	ALU0240	IA201-B	44.00	48	Failed	46	46	40
MAT01798	ALU0300	IA704-B	29.33	64	Failed	1	49	38
MAT02445	ALU0408	IA603-B	36.33	68	Failed	6	54	49
MAT03724	ALU0621	IA404-B	37.67	54	Failed	50	47	16
MAT00136	ALU0023	IA604-A	13.00	93	Failed	12	1	26
MAT02298	ALU0383	IA506-A	25.33	87	Failed	20	16	40
MAT00410	ALU0069	IA102-A	22.33	42	Failed	24	8	35
MAT02564	ALU0428	IA202-A	16.67	62	Failed	2	36	12
MAT01470	ALU0245	IA406-B	39.00	56	Failed	46	18	53
MAT03495	ALU0583	IA103-A	26.00	33	Failed	15	30	33
MAT00766	ALU0128	IA304-A	21.00	86	Failed	33	1	29
MAT05730	ALU0955	IA706-B	35.33	96	Failed	32	27	47
MAT03624	ALU0604	IA406-A	43.33	65	Failed	42	59	29
MAT01790	ALU0299	IA202-A	19.67	95	Failed	12	2	45
MAT03755	ALU0626	IA705-B	22.00	47	Failed	19	19	28
MAT00652	ALU0109	IA204-A	39.67	49	Failed	51	32	36
MAT02862	ALU0477	IA306-A	26.33	78	Failed	16	11	52
MAT00332	ALU0056	IA102-B	23.33	61	Failed	36	27	7
MAT00748	ALU0125	IA304-B	33.67	88	Failed	42	11	48
MAT02327	ALU0388	IA805-B	19.67	93	Failed	2	21	36
MAT05726	ALU0955	IA702-B	46.33	33	Failed	56	25	58
MAT05284	ALU0881	IA104-A	50.00	98	Failed	59	59	32
MAT01905	ALU0318	IA403-A	39.67	63	Failed	49	28	42
MAT03655	ALU0610	IA301-B	46.67	65	Failed	49	53	38
MAT01423	ALU0238	IA801-A	27.67	83	Failed	24	49	10
MAT02473	ALU0413	IA201-B	9.67	37	Failed	16	1	12
MAT04775	ALU0796	IA705-A	31.33	57	Failed	43	32	19
MAT00479	ALU0080	IA205-A	49.67	63	Failed	42	53	54
MAT05822	ALU0971	IA602-B	46.67	79	Failed	40	46	54
MAT01196	ALU0200	IA602-A	21.33	70	Failed	51	5	8
MAT00441	ALU0074	IA303-B	13.00	87	Failed	2	7	30
MAT01514	ALU0253	IA602-B	25.00	46	Failed	45	25	5
MAT01308	ALU0218	IA406-B	46.67	33	Failed	47	41	52
MAT04293	ALU0716	IA103-B	23.00	74	Failed	9	21	39
MAT02170	ALU0362	IA404-B	32.00	35	Failed	32	35	29
MAT03099	ALU0517	IA603-B	37.33	47	Failed	28	40	44
MAT02973	ALU0496	IA403-A	32.00	56	Failed	24	25	47
MAT01439	ALU0240	IA205-B	26.67	73	Failed	41	12	27
MAT03511	ALU0586	IA201-B	29.67	35	Failed	42	23	24
MAT01687	ALU0282	IA801-B	28.67	42	Failed	33	13	40
MAT05942	ALU0991	IA202-B	35.33	35	Failed	20	28	58
MAT05417	ALU0903	IA305-B	30.33	56	Failed	0	45	46
MAT01713	ALU0286	IA203-A	25.00	48	Failed	22	22	31
MAT04790	ALU0799	IA802-B	28.00	68	Failed	43	1	40
MAT01689	ALU0282	IA803-B	30.33	58	Failed	16	51	24
MAT02326	ALU0388	IA804-B	34.67	39	Failed	43	6	55
MAT00559	ALU0094	IA601-A	37.00	39	Failed	37	49	25
MAT01200	ALU0200	IA606-A	29.33	80	Failed	10	43	35
MAT05548	ALU0925	IA204-B	21.00	70	Failed	8	8	47
MAT05333	ALU0889	IA505-B	71.33	95	Approved	76	74	64
MAT05384	ALU0898	IA102-B	91.33	91	Approved	80	100	94
MAT00563	ALU0094	IA605-A	90.33	84	Approved	98	84	89
MAT05366	ALU0895	IA502-A	85.67	75	Approved	98	83	76
MAT01889	ALU0315	IA205-A	77.67	97	Approved	80	71	82
MAT04237	ALU0707	IA701-A	91.67	100	Approved	98	85	92
MAT00758	ALU0127	IA802-B	70.33	99	Approved	66	62	83
MAT00161	ALU0027	IA205-B	78.00	76	Approved	70	97	67
MAT00681	ALU0114	IA803-B	72.33	80	Approved	63	73	81
MAT01241	ALU0207	IA305-A	80.67	97	Approved	80	97	65
MAT05062	ALU0844	IA204-A	93.00	79	Approved	81	98	100
MAT02120	ALU0354	IA702-B	80.67	93	Approved	67	75	100
MAT01028	ALU0172	IA502-B	83.67	98	Approved	69	85	97
MAT04482	ALU0747	IA706-B	80.33	98	Approved	85	86	70
MAT01856	ALU0310	IA502-B	86.00	94	Approved	89	90	79
MAT05952	ALU0992	IA306-A	87.33	87	Approved	93	100	69
MAT03133	ALU0523	IA501-B	77.00	83	Approved	65	66	100
MAT03148	ALU0525	IA804-A	84.00	94	Approved	82	88	82
MAT03135	ALU0523	IA503-B	32.00	75	Failed	41	42	13
MAT05126	ALU0855	IA402-B	43.00	67	Failed	59	34	36
MAT02797	ALU0467	IA301-B	15.67	38	Failed	12	10	25
MAT03130	ALU0522	IA404-B	35.00	68	Failed	53	47	5
MAT02307	ALU0385	IA503-B	25.00	74	Failed	35	39	1
MAT01522	ALU0254	IA604-A	20.00	30	Failed	23	15	22
MAT04317	ALU0720	IA703-B	34.33	60	Failed	35	53	15
MAT01477	ALU0247	IA201-B	31.00	88	Failed	30	57	6
MAT03928	ALU0655	IA804-A	25.33	83	Failed	20	36	20
MAT03158	ALU0527	IA202-A	53.67	37	Failed	46	58	57
MAT04387	ALU0732	IA301-A	18.67	65	Failed	21	31	4
MAT02287	ALU0382	IA201-A	12.33	47	Failed	8	13	16
MAT03154	ALU0526	IA504-B	30.67	76	Failed	35	12	45
MAT00451	ALU0076	IA801-B	15.33	70	Failed	3	32	11
MAT05055	ALU0843	IA703-B	21.00	98	Failed	12	37	14
MAT02066	ALU0345	IA702-A	26.67	86	Failed	54	21	5
MAT02550	ALU0425	IA806-B	31.33	66	Failed	39	15	40
MAT02912	ALU0486	IA402-A	16.67	36	Failed	31	19	0
MAT02656	ALU0443	IA104-A	30.00	48	Failed	31	51	8
MAT00516	ALU0086	IA806-A	34.00	62	Failed	52	29	21
MAT03166	ALU0528	IA304-B	68.33	81	Approved	69	67	69
MAT03251	ALU0542	IA405-B	71.67	98	Approved	64	61	90
MAT03197	ALU0533	IA705-B	80.00	80	Approved	74	88	78
MAT03244	ALU0541	IA604-A	86.00	86	Approved	98	98	62
MAT03194	ALU0533	IA702-B	82.00	96	Approved	89	65	92
MAT03193	ALU0533	IA701-B	79.33	83	Approved	70	87	81
MAT04123	ALU0688	IA301-B	76.33	80	Approved	76	82	71
MAT03170	ALU0529	IA202-B	20.33	76	Failed	14	45	2
MAT02406	ALU0401	IA306-A	9.67	57	Failed	19	4	6
MAT03226	ALU0538	IA204-A	33.33	30	Failed	45	14	41
MAT03236	ALU0540	IA402-A	35.67	40	Failed	41	59	7
MAT04430	ALU0739	IA102-A	25.00	38	Failed	54	19	2
MAT03250	ALU0542	IA404-B	24.00	50	Failed	51	1	20
MAT03196	ALU0533	IA704-B	37.33	74	Failed	7	47	58
MAT01306	ALU0218	IA404-B	30.33	42	Failed	27	21	43
MAT03240	ALU0540	IA406-A	22.67	90	Failed	2	15	51
MAT01334	ALU0223	IA402-B	13.67	95	Failed	1	16	24
MAT00704	ALU0118	IA802-B	41.67	98	Failed	55	57	13
MAT03215	ALU0536	IA305-B	21.00	62	Failed	57	1	5
MAT03239	ALU0540	IA405-A	37.33	88	Failed	44	26	42
MAT03252	ALU0542	IA406-B	29.33	43	Failed	26	51	11
MAT01915	ALU0320	IA701-B	21.67	84	Failed	14	29	22
MAT03212	ALU0536	IA302-B	16.33	53	Failed	13	23	13
MAT03165	ALU0528	IA303-B	25.67	80	Failed	25	5	47
MAT03214	ALU0536	IA304-B	35.33	71	Failed	36	31	39
MAT04234	ALU0706	IA704-B	28.67	97	Failed	6	24	56
MAT03253	ALU0543	IA201-A	39.67	49	Failed	56	58	5
MAT03195	ALU0533	IA703-B	42.00	86	Failed	34	38	54
MAT05308	ALU0885	IA204-B	30.33	98	Failed	34	39	18
MAT03248	ALU0542	IA402-B	32.67	33	Failed	33	23	42
MAT02126	ALU0355	IA502-B	19.67	50	Failed	8	0	51
MAT03223	ALU0538	IA201-A	28.00	53	Failed	18	42	24
MAT03232	ALU0539	IA704-B	36.33	95	Failed	49	44	16
MAT03229	ALU0539	IA701-B	35.33	91	Failed	13	37	56
MAT03249	ALU0542	IA403-B	35.33	95	Failed	55	11	40
MAT03167	ALU0528	IA305-B	35.67	64	Failed	34	47	26
MAT03231	ALU0539	IA703-B	25.33	67	Failed	31	41	4
MAT03228	ALU0538	IA206-A	31.00	59	Failed	32	56	5
MAT03233	ALU0539	IA705-B	32.00	38	Failed	24	20	52
MAT03163	ALU0528	IA301-B	35.67	46	Failed	45	20	42
MAT03198	ALU0533	IA706-B	36.67	77	Failed	33	49	28
MAT03224	ALU0538	IA202-A	22.33	48	Failed	1	21	45
MAT03341	ALU0557	IA405-B	88.00	85	Approved	92	80	92
MAT03349	ALU0559	IA401-A	81.00	85	Approved	66	83	94
MAT02672	ALU0446	IA202-B	43.33	77	Failed	22	57	51
MAT03340	ALU0557	IA404-B	37.67	86	Failed	59	24	30
MAT01808	ALU0302	IA802-B	33.33	84	Failed	26	43	31
MAT01123	ALU0188	IA801-B	13.00	83	Failed	0	33	6
MAT03289	ALU0549	IA101-B	18.33	95	Failed	33	11	11
MAT03327	ALU0555	IA303-B	35.33	73	Failed	14	57	35
MAT01640	ALU0274	IA202-A	40.67	73	Failed	32	48	42
MAT03339	ALU0557	IA403-B	24.33	72	Failed	26	40	7
MAT03022	ALU0504	IA504-B	22.33	68	Failed	26	6	35
MAT03302	ALU0551	IA402-B	19.33	79	Failed	5	20	33
MAT03293	ALU0549	IA105-B	27.33	44	Failed	2	40	40
MAT03303	ALU0551	IA403-B	27.00	70	Failed	35	34	12
MAT00695	ALU0116	IA705-A	31.33	37	Failed	31	53	10
MAT03292	ALU0549	IA104-B	35.67	69	Failed	39	9	59
MAT03285	ALU0548	IA103-B	19.67	70	Failed	17	32	10
MAT05170	ALU0862	IA504-B	31.33	76	Failed	15	46	33
MAT03337	ALU0557	IA401-B	23.00	79	Failed	26	11	32
MAT03314	ALU0553	IA802-A	10.33	32	Failed	7	5	19
MAT03301	ALU0551	IA401-B	41.00	73	Failed	55	11	57
MAT03271	ALU0546	IA201-B	27.00	75	Failed	54	0	27
MAT03260	ALU0544	IA502-A	34.33	75	Failed	55	17	31
MAT02472	ALU0412	IA606-B	35.33	71	Failed	54	41	11
MAT04298	ALU0717	IA102-B	20.33	54	Failed	7	2	52
MAT02890	ALU0482	IA804-B	28.67	77	Failed	44	42	0
MAT03316	ALU0553	IA804-A	33.67	52	Failed	28	34	39
MAT03320	ALU0554	IA302-B	23.33	49	Failed	13	19	38
MAT03294	ALU0549	IA106-B	43.33	74	Failed	40	49	41
MAT03306	ALU0551	IA406-B	41.33	50	Failed	39	40	45
MAT03305	ALU0551	IA405-B	18.00	80	Failed	12	21	21
MAT03318	ALU0553	IA806-A	34.00	45	Failed	57	39	6
MAT03290	ALU0549	IA102-B	48.00	94	Failed	54	44	46
MAT03238	ALU0540	IA404-A	37.00	33	Failed	24	41	46
MAT03310	ALU0552	IA404-B	54.33	55	Failed	57	56	50
MAT03273	ALU0546	IA203-B	23.33	45	Failed	23	47	0
MAT03334	ALU0556	IA604-B	32.67	48	Failed	31	46	21
MAT03298	ALU0550	IA504-A	26.00	55	Failed	51	22	5
MAT02893	ALU0483	IA501-B	42.00	96	Failed	25	48	53
MAT03274	ALU0546	IA204-B	29.67	65	Failed	0	43	46
MAT03444	ALU0574	IA506-A	66.00	96	Approved	64	66	68
MAT01800	ALU0300	IA706-B	64.33	82	Approved	68	63	62
MAT01223	ALU0204	IA805-B	79.67	92	Approved	70	95	74
MAT02941	ALU0491	IA201-B	66.33	100	Approved	66	73	60
MAT03445	ALU0575	IA401-A	90.33	96	Approved	91	93	87
MAT03396	ALU0566	IA606-B	42.33	46	Failed	56	39	32
MAT03395	ALU0566	IA605-B	25.67	46	Failed	26	31	20
MAT03096	ALU0516	IA606-A	26.67	92	Failed	10	59	11
MAT02977	ALU0497	IA601-B	39.67	95	Failed	53	56	10
MAT03399	ALU0567	IA103-B	25.00	40	Failed	23	23	29
MAT03383	ALU0564	IA205-B	25.33	93	Failed	46	9	21
MAT03389	ALU0565	IA705-B	24.33	47	Failed	46	12	15
MAT03378	ALU0563	IA206-B	19.33	87	Failed	19	24	15
MAT00620	ALU0104	IA702-B	31.00	85	Failed	39	40	14
MAT04902	ALU0817	IA706-A	26.67	54	Failed	20	6	54
MAT03367	ALU0562	IA401-B	5.00	35	Failed	2	9	4
MAT01020	ALU0170	IA406-B	35.33	77	Failed	44	28	34
MAT03391	ALU0566	IA601-B	21.00	67	Failed	17	13	33
MAT03401	ALU0567	IA105-B	37.00	75	Failed	33	21	57
MAT03390	ALU0565	IA706-B	39.00	41	Failed	39	26	52
MAT03434	ALU0573	IA302-B	31.00	39	Failed	1	44	48
MAT03442	ALU0574	IA504-A	24.00	49	Failed	3	40	29
MAT03393	ALU0566	IA603-B	21.67	53	Failed	45	0	20
MAT03423	ALU0571	IA803-A	39.00	64	Failed	32	50	35
MAT00606	ALU0101	IA206-A	40.33	68	Failed	52	13	56
MAT01313	ALU0219	IA105-A	39.33	97	Failed	40	40	38
MAT03377	ALU0563	IA205-B	23.67	89	Failed	37	28	6
MAT03521	ALU0587	IA805-A	49.00	35	Failed	51	41	55
MAT03400	ALU0567	IA104-B	24.33	73	Failed	11	8	54
MAT03385	ALU0565	IA701-B	9.33	58	Failed	8	15	5
MAT03441	ALU0574	IA503-A	44.67	80	Failed	23	58	53
MAT03422	ALU0571	IA802-A	32.33	63	Failed	17	40	40
MAT03381	ALU0564	IA203-B	49.67	94	Failed	58	39	52
MAT01991	ALU0332	IA705-B	35.67	79	Failed	18	30	59
MAT03388	ALU0565	IA704-B	26.33	42	Failed	18	16	45
MAT03424	ALU0571	IA804-A	18.00	35	Failed	1	37	16
MAT03372	ALU0562	IA406-B	48.33	73	Failed	51	41	53
MAT05728	ALU0955	IA704-B	28.33	34	Failed	44	37	4
MAT03397	ALU0567	IA101-B	32.67	47	Failed	49	36	13
MAT01870	ALU0312	IA804-A	33.00	41	Failed	44	32	23
MAT03508	ALU0585	IA704-A	88.67	93	Approved	89	99	78
MAT03493	ALU0583	IA101-A	86.33	75	Approved	82	92	85
MAT03483	ALU0581	IA303-B	75.33	94	Approved	67	72	87
MAT04516	ALU0753	IA204-A	71.67	98	Approved	81	68	66
MAT03487	ALU0582	IA201-B	92.33	75	Approved	99	89	89
MAT03462	ALU0577	IA806-A	28.00	62	Failed	35	0	49
MAT00685	ALU0115	IA301-A	35.67	93	Failed	6	55	46
MAT03473	ALU0579	IA105-A	21.33	30	Failed	32	9	23
MAT03504	ALU0584	IA106-A	42.33	81	Failed	55	40	32
MAT01085	ALU0181	IA705-B	42.33	93	Failed	26	43	58
MAT03494	ALU0583	IA102-A	46.67	55	Failed	38	53	49
MAT05336	ALU0890	IA102-A	30.33	32	Failed	27	40	24
MAT01652	ALU0276	IA602-B	48.33	98	Failed	46	53	46
MAT03492	ALU0582	IA206-B	50.00	97	Failed	37	55	58
MAT03463	ALU0578	IA201-A	17.33	57	Failed	26	26	0
MAT03489	ALU0582	IA203-B	24.00	62	Failed	38	12	22
MAT04518	ALU0753	IA206-A	30.33	84	Failed	8	34	49
MAT03458	ALU0577	IA802-A	42.00	34	Failed	48	19	59
MAT05525	ALU0921	IA705-A	29.67	90	Failed	16	14	59
MAT01548	ALU0258	IA106-B	36.67	39	Failed	31	38	41
MAT01152	ALU0192	IA406-B	51.33	92	Failed	43	59	52
MAT03478	ALU0580	IA304-A	17.33	85	Failed	9	17	26
MAT03374	ALU0563	IA202-B	30.67	67	Failed	46	17	29
MAT02150	ALU0359	IA402-B	35.33	30	Failed	47	26	33
MAT03505	ALU0585	IA701-A	33.33	70	Failed	32	16	52
MAT03475	ALU0580	IA301-A	36.00	34	Failed	43	26	39
MAT05559	ALU0927	IA603-B	45.67	66	Failed	29	59	49
MAT04943	ALU0824	IA305-B	18.33	43	Failed	6	47	2
MAT00284	ALU0048	IA802-A	28.33	48	Failed	57	5	23
MAT03476	ALU0580	IA302-A	19.67	87	Failed	15	39	5
MAT05680	ALU0947	IA804-A	18.33	53	Failed	33	2	20
MAT01421	ALU0237	IA305-B	20.33	90	Failed	10	6	45
MAT05506	ALU0918	IA804-A	76.33	81	Approved	65	96	68
MAT03595	ALU0600	IA101-B	87.67	75	Approved	96	68	99
MAT03584	ALU0598	IA102-A	84.33	78	Approved	78	81	94
MAT02333	ALU0389	IA705-B	38.33	73	Failed	57	29	29
MAT03631	ALU0606	IA301-B	31.33	88	Failed	27	8	59
MAT05964	ALU0994	IA806-A	43.33	51	Failed	49	52	29
MAT03681	ALU0614	IA703-A	19.67	82	Failed	7	36	16
MAT03554	ALU0593	IA502-A	22.00	76	Failed	9	31	26
MAT03597	ALU0600	IA103-B	17.67	49	Failed	12	27	14
MAT05763	ALU0961	IA303-B	49.33	55	Failed	43	54	51
MAT03593	ALU0599	IA705-B	27.67	32	Failed	44	13	26
MAT03561	ALU0594	IA403-A	28.33	99	Failed	58	14	13
MAT03567	ALU0595	IA403-A	33.33	67	Failed	41	50	9
MAT03598	ALU0600	IA104-B	19.00	79	Failed	50	0	7
MAT01625	ALU0271	IA105-B	40.67	97	Failed	53	43	26
MAT03627	ALU0605	IA303-A	45.33	69	Failed	32	49	55
MAT03654	ALU0609	IA306-A	24.67	91	Failed	27	2	45
MAT00782	ALU0131	IA802-A	29.67	37	Failed	45	13	31
MAT05944	ALU0991	IA204-B	38.67	81	Failed	55	51	10
MAT03638	ALU0607	IA302-A	31.00	69	Failed	41	27	25
MAT03038	ALU0507	IA302-B	27.67	60	Failed	35	47	1
MAT03575	ALU0596	IA105-B	22.00	98	Failed	1	44	21
MAT03564	ALU0594	IA406-A	31.33	73	Failed	29	36	29
MAT03630	ALU0605	IA306-A	20.00	95	Failed	15	44	1
MAT01634	ALU0273	IA402-A	49.00	34	Failed	46	59	42
MAT03583	ALU0598	IA101-A	33.33	100	Failed	6	50	44
MAT03568	ALU0595	IA404-A	30.33	41	Failed	6	53	32
MAT01600	ALU0267	IA604-A	33.00	34	Failed	6	46	47
MAT01954	ALU0326	IA704-A	21.67	57	Failed	8	44	13
MAT03680	ALU0614	IA702-A	25.33	33	Failed	44	15	17
MAT00791	ALU0132	IA605-B	41.33	67	Failed	59	33	32
MAT03574	ALU0596	IA104-B	14.33	66	Failed	31	1	11
MAT03559	ALU0594	IA401-A	33.67	57	Failed	44	53	4
MAT05804	ALU0968	IA502-B	23.00	45	Failed	40	11	18
MAT03566	ALU0595	IA402-A	35.00	76	Failed	17	41	47
MAT03784	ALU0631	IA304-B	72.00	96	Approved	62	83	71
MAT01255	ALU0210	IA201-B	80.33	88	Approved	90	61	90
MAT03782	ALU0631	IA302-B	80.00	93	Approved	85	93	62
MAT03751	ALU0626	IA701-B	78.00	77	Approved	74	62	98
MAT04047	ALU0675	IA303-A	72.00	89	Approved	74	67	75
MAT02813	ALU0469	IA605-B	87.00	80	Approved	72	93	96
MAT03778	ALU0630	IA104-B	91.00	94	Approved	96	98	79
MAT05765	ALU0961	IA305-B	15.00	56	Failed	17	27	1
MAT03800	ALU0634	IA302-B	27.67	37	Failed	4	20	59
MAT03741	ALU0624	IA703-B	28.00	86	Failed	58	11	15
MAT03799	ALU0634	IA301-B	15.33	47	Failed	36	7	3
MAT02478	ALU0413	IA206-B	48.67	51	Failed	41	55	50
MAT03764	ALU0628	IA402-B	29.33	33	Failed	20	54	14
MAT01887	ALU0315	IA203-A	18.67	66	Failed	8	34	14
MAT03743	ALU0624	IA705-B	44.67	39	Failed	47	53	34
MAT03773	ALU0629	IA405-A	30.67	82	Failed	53	28	11
MAT03750	ALU0625	IA606-B	16.67	47	Failed	37	1	12
MAT05569	ALU0929	IA801-A	42.67	40	Failed	19	51	58
MAT03746	ALU0625	IA602-B	41.00	58	Failed	31	58	34
MAT05318	ALU0887	IA602-B	43.67	43	Failed	54	25	52
MAT03760	ALU0627	IA104-B	40.67	44	Failed	35	32	55
MAT05100	ALU0850	IA106-B	27.33	87	Failed	20	24	38
MAT03771	ALU0629	IA403-A	34.67	66	Failed	54	45	5
MAT03777	ALU0630	IA103-B	22.33	72	Failed	6	35	26
MAT05309	ALU0885	IA205-B	38.67	85	Failed	44	50	22
MAT03779	ALU0630	IA105-B	22.00	75	Failed	15	24	27
MAT03772	ALU0629	IA404-A	34.67	33	Failed	56	3	45
MAT02220	ALU0370	IA606-B	39.00	60	Failed	59	54	4
MAT03765	ALU0628	IA403-B	18.00	53	Failed	30	17	7
MAT01888	ALU0315	IA204-A	15.67	72	Failed	12	14	21
MAT01079	ALU0180	IA505-B	25.67	96	Failed	1	25	51
MAT03769	ALU0629	IA401-A	28.33	78	Failed	22	43	20
MAT03745	ALU0625	IA601-B	25.00	58	Failed	37	28	10
MAT03770	ALU0629	IA402-A	51.33	79	Failed	53	45	56
MAT03752	ALU0626	IA702-B	24.00	88	Failed	11	49	12
MAT03781	ALU0631	IA301-B	47.00	32	Failed	57	32	52
MAT03780	ALU0630	IA106-B	28.33	99	Failed	33	50	2
MAT02151	ALU0359	IA403-B	89.00	100	Approved	100	100	67
MAT01329	ALU0222	IA703-B	76.00	78	Approved	84	69	75
MAT03840	ALU0640	IA106-B	80.00	75	Approved	92	65	83
MAT03829	ALU0639	IA301-B	71.33	77	Approved	81	65	68
MAT03860	ALU0644	IA502-A	34.00	56	Failed	41	43	18
MAT04853	ALU0809	IA305-A	39.33	32	Failed	51	21	46
MAT01622	ALU0271	IA102-B	16.00	42	Failed	7	27	14
MAT03853	ALU0643	IA401-A	14.00	86	Failed	5	3	34
MAT02549	ALU0425	IA805-B	14.33	80	Failed	23	1	19
MAT02297	ALU0383	IA505-A	42.00	91	Failed	55	35	36
MAT02622	ALU0437	IA206-A	35.67	39	Failed	18	40	49
MAT03835	ALU0640	IA101-B	5.67	50	Failed	0	3	14
MAT03827	ALU0638	IA405-B	27.00	50	Failed	12	16	53
MAT00185	ALU0031	IA605-B	48.33	79	Failed	56	35	54
MAT03869	ALU0645	IA605-B	36.33	59	Failed	55	20	34
MAT00601	ALU0101	IA201-A	50.67	66	Failed	46	49	57
MAT01624	ALU0271	IA104-B	20.33	56	Failed	20	27	14
MAT02464	ALU0411	IA404-B	25.67	46	Failed	5	24	48
MAT02119	ALU0354	IA701-B	30.33	64	Failed	24	11	56
MAT01780	ALU0297	IA804-B	18.33	79	Failed	19	14	22
MAT01149	ALU0192	IA403-B	38.00	97	Failed	59	27	28
MAT03841	ALU0641	IA801-B	29.33	93	Failed	16	28	44
MAT03759	ALU0627	IA103-B	36.33	46	Failed	43	56	10
MAT03857	ALU0643	IA405-A	33.00	31	Failed	10	44	45
MAT05731	ALU0956	IA401-A	25.00	68	Failed	6	50	19
MAT02477	ALU0413	IA205-B	23.33	65	Failed	13	42	15
MAT03862	ALU0644	IA504-A	47.33	80	Failed	54	34	54
MAT01165	ALU0195	IA301-B	23.33	74	Failed	19	32	19
MAT03828	ALU0638	IA406-B	28.00	82	Failed	8	32	44
MAT03873	ALU0646	IA503-B	30.67	97	Failed	44	5	43
MAT03836	ALU0640	IA102-B	26.67	52	Failed	52	7	21
MAT01837	ALU0307	IA401-A	34.67	77	Failed	47	22	35
MAT05312	ALU0886	IA702-B	38.33	53	Failed	58	1	56
MAT03998	ALU0667	IA602-A	72.33	86	Approved	76	67	74
MAT04003	ALU0668	IA301-B	73.67	90	Approved	78	79	64
MAT04477	ALU0747	IA701-B	23.67	50	Failed	22	1	48
MAT03985	ALU0665	IA601-B	32.00	94	Failed	1	44	51
MAT03937	ALU0657	IA801-B	28.00	74	Failed	37	24	23
MAT04061	ALU0677	IA105-B	39.00	89	Failed	56	26	35
MAT04072	ALU0679	IA104-B	42.33	47	Failed	39	34	54
MAT04018	ALU0670	IA204-A	27.67	86	Failed	26	32	25
MAT04015	ALU0670	IA201-A	48.33	78	Failed	51	37	57
MAT03974	ALU0663	IA802-B	40.33	63	Failed	39	40	42
MAT03952	ALU0659	IA604-A	31.67	94	Failed	14	51	30
MAT03982	ALU0664	IA104-B	20.33	68	Failed	6	50	5
MAT03940	ALU0657	IA804-B	26.33	48	Failed	25	11	43
MAT03938	ALU0657	IA802-B	29.33	96	Failed	22	38	28
MAT03953	ALU0659	IA605-A	26.00	67	Failed	8	16	54
MAT03068	ALU0512	IA202-A	41.67	49	Failed	26	58	41
MAT04062	ALU0677	IA106-B	23.33	43	Failed	33	25	12
MAT03954	ALU0659	IA606-A	20.33	82	Failed	13	42	6
MAT04069	ALU0679	IA101-B	41.33	58	Failed	47	36	41
MAT04064	ALU0678	IA202-B	37.00	68	Failed	43	57	11
MAT02130	ALU0355	IA506-B	48.33	92	Failed	45	49	51
MAT04001	ALU0667	IA605-A	25.67	66	Failed	4	37	36
MAT03978	ALU0663	IA806-B	29.00	50	Failed	16	52	19
MAT01289	ALU0215	IA605-B	45.00	62	Failed	34	52	49
MAT03963	ALU0661	IA403-A	24.67	38	Failed	19	45	10
MAT03425	ALU0571	IA805-A	48.67	38	Failed	58	52	36
MAT03949	ALU0659	IA601-A	39.67	71	Failed	53	7	59
MAT04010	ALU0669	IA302-A	30.67	37	Failed	38	30	24
MAT02745	ALU0458	IA203-B	17.67	85	Failed	36	11	6
MAT04073	ALU0679	IA105-B	37.00	96	Failed	57	20	34
MAT00432	ALU0072	IA406-B	47.67	88	Failed	58	41	44
MAT03941	ALU0657	IA805-B	19.33	35	Failed	23	24	11
MAT04071	ALU0679	IA103-B	33.33	75	Failed	41	18	41
MAT04004	ALU0668	IA302-B	29.00	46	Failed	28	51	8
MAT03936	ALU0656	IA406-B	29.00	83	Failed	10	47	30
MAT03951	ALU0659	IA603-A	26.00	90	Failed	33	2	43
MAT04067	ALU0678	IA205-B	36.00	76	Failed	54	17	37
MAT04005	ALU0668	IA303-B	27.00	79	Failed	19	14	48
MAT04016	ALU0670	IA202-A	25.33	79	Failed	42	15	19
MAT04011	ALU0669	IA303-A	8.33	59	Failed	3	10	12
MAT04200	ALU0700	IA506-B	46.33	36	Failed	47	40	52
MAT05701	ALU0951	IA301-A	26.00	88	Failed	34	2	42
MAT04066	ALU0678	IA204-B	37.67	69	Failed	32	32	49
MAT04076	ALU0680	IA302-B	76.00	91	Approved	86	82	60
MAT05060	ALU0844	IA202-A	80.67	80	Approved	83	86	73
MAT05423	ALU0904	IA505-B	85.33	90	Approved	87	75	94
MAT04161	ALU0694	IA303-B	24.67	77	Failed	16	15	43
MAT02968	ALU0495	IA404-A	28.00	56	Failed	27	31	26
MAT03734	ALU0623	IA602-A	22.33	91	Failed	26	11	30
MAT02225	ALU0371	IA705-B	51.67	36	Failed	45	57	53
MAT04102	ALU0684	IA704-A	19.00	46	Failed	12	12	33
MAT04166	ALU0695	IA202-B	32.00	83	Failed	22	29	45
MAT04163	ALU0694	IA305-B	25.00	33	Failed	10	28	37
MAT02143	ALU0358	IA701-A	26.00	56	Failed	20	23	35
MAT01397	ALU0233	IA405-B	39.67	66	Failed	45	30	44
MAT04100	ALU0684	IA702-A	43.00	99	Failed	43	36	50
MAT04093	ALU0683	IA601-B	38.00	67	Failed	41	32	41
MAT00674	ALU0113	IA702-B	38.33	89	Failed	18	45	52
MAT04081	ALU0681	IA601-B	29.33	73	Failed	8	27	53
MAT04167	ALU0695	IA203-B	24.00	72	Failed	0	22	50
MAT01704	ALU0284	IA606-A	22.00	68	Failed	47	5	14
MAT00173	ALU0029	IA805-A	25.33	44	Failed	20	22	34
MAT04169	ALU0695	IA205-B	39.67	59	Failed	54	22	43
MAT02761	ALU0461	IA101-B	21.67	37	Failed	9	46	10
MAT04077	ALU0680	IA303-B	36.67	46	Failed	33	26	51
MAT02851	ALU0476	IA401-B	29.00	61	Failed	34	7	46
MAT04157	ALU0693	IA205-B	33.33	39	Failed	10	34	56
MAT04074	ALU0679	IA106-B	25.67	97	Failed	6	48	23
MAT04075	ALU0680	IA301-B	43.33	91	Failed	55	25	50
MAT02222	ALU0371	IA702-B	26.67	41	Failed	55	2	23
MAT04078	ALU0680	IA304-B	33.00	78	Failed	2	53	44
MAT00974	ALU0163	IA602-B	25.00	56	Failed	30	2	43
MAT01154	ALU0193	IA502-A	25.33	54	Failed	21	29	26
MAT04080	ALU0680	IA306-B	30.33	83	Failed	11	48	32
MAT04106	ALU0685	IA202-A	34.67	76	Failed	58	27	19
MAT04156	ALU0693	IA204-B	21.00	86	Failed	51	1	11
MAT04104	ALU0684	IA706-A	38.67	54	Failed	49	20	47
MAT00669	ALU0112	IA403-B	21.67	36	Failed	34	6	25
MAT04103	ALU0684	IA705-A	32.33	61	Failed	35	35	27
MAT04181	ALU0697	IA205-B	26.00	33	Failed	25	37	16
MAT04294	ALU0716	IA104-B	82.33	89	Approved	89	79	79
MAT04095	ALU0683	IA603-B	68.33	79	Approved	77	68	60
MAT04235	ALU0706	IA705-B	19.67	90	Failed	16	20	23
MAT04274	ALU0713	IA302-A	34.67	97	Failed	37	47	20
MAT04278	ALU0713	IA306-A	35.33	51	Failed	9	40	57
MAT04283	ALU0714	IA805-B	16.67	73	Failed	7	15	28
MAT02393	ALU0399	IA805-B	31.67	58	Failed	46	45	4
MAT04241	ALU0707	IA705-A	25.00	100	Failed	24	33	18
MAT04255	ALU0710	IA701-B	28.00	69	Failed	37	26	21
MAT04254	ALU0709	IA306-A	29.00	41	Failed	7	49	31
MAT05290	ALU0882	IA404-B	16.67	62	Failed	0	41	9
MAT01338	ALU0223	IA406-B	16.33	70	Failed	31	12	6
MAT04249	ALU0709	IA301-A	53.67	52	Failed	59	45	57
MAT04259	ALU0710	IA705-B	21.00	33	Failed	59	2	2
MAT04243	ALU0708	IA801-B	31.67	67	Failed	30	56	9
MAT04420	ALU0737	IA704-B	27.00	50	Failed	24	18	39
MAT04252	ALU0709	IA304-A	30.00	98	Failed	20	20	50
MAT04207	ALU0702	IA801-B	13.00	39	Failed	12	17	10
MAT04291	ALU0716	IA101-B	12.00	90	Failed	12	10	14
MAT01547	ALU0258	IA105-B	34.33	69	Failed	24	22	57
MAT04212	ALU0702	IA806-B	24.33	99	Failed	15	41	17
MAT04238	ALU0707	IA702-A	21.33	72	Failed	32	8	24
MAT01803	ALU0301	IA103-B	25.00	94	Failed	8	11	56
MAT04279	ALU0714	IA801-B	33.00	76	Failed	9	44	46
MAT05637	ALU0940	IA303-B	33.33	36	Failed	14	47	39
MAT04251	ALU0709	IA303-A	26.00	74	Failed	25	43	10
MAT04284	ALU0714	IA806-B	39.67	97	Failed	35	32	52
MAT00547	ALU0092	IA101-A	29.67	69	Failed	29	19	41
MAT01955	ALU0326	IA705-A	23.33	98	Failed	29	7	34
MAT04273	ALU0713	IA301-A	38.67	89	Failed	43	58	15
MAT04245	ALU0708	IA803-B	21.67	99	Failed	22	7	36
MAT04211	ALU0702	IA805-B	36.00	36	Failed	52	6	50
MAT00541	ALU0091	IA601-B	30.00	69	Failed	6	56	28
MAT04151	ALU0692	IA205-B	28.67	83	Failed	32	44	10
MAT04206	ALU0701	IA706-B	29.33	50	Failed	11	58	19
MAT04244	ALU0708	IA802-B	30.00	99	Failed	27	33	30
MAT04208	ALU0702	IA802-B	32.00	66	Failed	1	45	50
MAT04250	ALU0709	IA302-A	22.00	45	Failed	16	22	28
MAT04351	ALU0726	IA701-B	81.00	99	Approved	88	69	86
MAT04134	ALU0689	IA606-A	85.67	94	Approved	94	73	90
MAT05721	ALU0954	IA503-B	82.33	94	Approved	81	94	72
MAT04336	ALU0723	IA204-A	83.00	91	Approved	72	80	97
MAT04347	ALU0725	IA203-B	81.33	89	Approved	61	94	89
MAT02640	ALU0440	IA506-A	71.67	80	Approved	92	63	60
MAT04365	ALU0728	IA403-B	75.67	83	Approved	76	68	83
MAT00957	ALU0160	IA503-A	69.00	81	Approved	75	71	61
MAT02400	ALU0400	IA406-B	72.00	90	Approved	69	83	64
MAT04332	ALU0722	IA806-B	79.33	87	Approved	68	85	85
MAT02644	ALU0441	IA604-B	35.67	74	Failed	56	15	36
MAT05962	ALU0994	IA804-A	31.67	67	Failed	46	2	47
MAT01287	ALU0215	IA603-B	29.00	30	Failed	23	42	22
MAT04343	ALU0724	IA405-B	20.67	67	Failed	28	32	2
MAT04346	ALU0725	IA202-B	24.33	58	Failed	23	27	23
MAT01709	ALU0285	IA505-A	24.33	36	Failed	9	43	21
MAT04371	ALU0729	IA603-A	23.67	91	Failed	30	31	10
MAT01672	ALU0279	IA204-B	42.00	83	Failed	47	42	37
MAT02692	ALU0449	IA804-A	28.67	74	Failed	56	23	7
MAT00485	ALU0081	IA405-B	28.00	34	Failed	25	10	49
MAT00504	ALU0084	IA206-B	40.33	78	Failed	51	52	18
MAT05733	ALU0956	IA403-A	34.67	89	Failed	30	24	50
MAT05292	ALU0882	IA406-B	34.33	61	Failed	17	48	38
MAT02570	ALU0429	IA402-A	33.67	78	Failed	29	44	28
MAT01973	ALU0329	IA105-B	29.00	91	Failed	22	12	53
MAT02825	ALU0471	IA305-B	19.00	99	Failed	15	31	11
MAT04090	ALU0682	IA404-B	17.67	36	Failed	9	31	13
MAT05223	ALU0871	IA703-A	42.00	75	Failed	32	59	35
MAT01953	ALU0326	IA703-A	26.00	39	Failed	1	20	57
MAT04441	ALU0741	IA401-B	77.67	98	Approved	66	67	100
MAT04507	ALU0752	IA401-B	83.33	76	Approved	90	86	74
MAT04456	ALU0743	IA504-A	90.67	91	Approved	87	87	98
MAT05689	ALU0949	IA301-A	35.33	85	Failed	44	26	36
MAT04468	ALU0745	IA304-B	35.67	94	Failed	46	13	48
MAT04515	ALU0753	IA203-A	35.33	95	Failed	6	54	46
MAT04513	ALU0753	IA201-A	30.67	94	Failed	8	50	34
MAT04473	ALU0746	IA103-B	31.67	45	Failed	29	58	8
MAT04489	ALU0749	IA401-B	31.33	45	Failed	47	0	47
MAT04494	ALU0749	IA406-B	26.00	83	Failed	34	1	43
MAT04497	ALU0750	IA603-B	25.33	95	Failed	32	43	1
MAT02365	ALU0395	IA301-B	14.67	95	Failed	28	0	16
MAT04466	ALU0745	IA302-B	18.33	49	Failed	25	24	6
MAT04467	ALU0745	IA303-B	21.67	32	Failed	10	25	30
MAT01508	ALU0252	IA702-A	28.33	79	Failed	21	49	15
MAT05504	ALU0918	IA802-A	30.00	56	Failed	36	12	42
MAT02598	ALU0433	IA806-A	20.67	75	Failed	43	13	6
MAT04451	ALU0742	IA105-A	32.00	76	Failed	26	29	41
MAT03376	ALU0563	IA204-B	16.67	34	Failed	7	2	41
MAT04459	ALU0744	IA301-B	25.33	34	Failed	50	25	1
MAT05621	ALU0937	IA505-B	27.33	72	Failed	32	16	34
MAT04504	ALU0751	IA604-B	47.00	33	Failed	48	55	38
MAT04470	ALU0745	IA306-B	35.00	65	Failed	32	44	29
MAT04457	ALU0743	IA505-A	38.67	37	Failed	57	13	46
MAT05057	ALU0843	IA705-B	37.67	87	Failed	51	52	10
MAT01931	ALU0322	IA505-B	13.33	35	Failed	14	22	4
MAT05449	ALU0909	IA401-B	18.00	46	Failed	5	41	8
MAT04502	ALU0751	IA602-B	18.33	92	Failed	25	25	5
MAT04446	ALU0741	IA406-B	31.67	74	Failed	16	41	38
MAT01232	ALU0206	IA502-A	25.67	75	Failed	24	49	4
MAT04514	ALU0753	IA202-A	14.67	61	Failed	3	13	28
MAT04491	ALU0749	IA403-B	9.67	58	Failed	12	2	15
MAT04465	ALU0745	IA301-B	41.00	93	Failed	58	40	25
MAT04500	ALU0750	IA606-B	38.67	47	Failed	49	24	43
MAT04503	ALU0751	IA603-B	41.67	58	Failed	25	54	46
MAT04453	ALU0743	IA501-A	30.00	74	Failed	8	51	31
MAT04447	ALU0742	IA101-A	23.67	46	Failed	17	2	52
MAT00839	ALU0140	IA205-A	33.00	40	Failed	2	45	52
MAT04495	ALU0750	IA601-B	28.33	100	Failed	54	19	12
MAT00225	ALU0038	IA703-B	41.33	55	Failed	23	59	42
MAT04561	ALU0761	IA701-A	79.00	98	Approved	75	73	89
MAT04621	ALU0771	IA601-A	88.67	98	Approved	77	94	95
MAT04535	ALU0756	IA805-B	77.33	92	Approved	74	80	78
MAT04573	ALU0763	IA301-A	83.33	75	Approved	93	66	91
MAT04575	ALU0763	IA303-A	43.00	57	Failed	50	51	28
MAT04623	ALU0771	IA603-A	28.33	77	Failed	7	31	47
MAT04568	ALU0762	IA502-A	37.33	96	Failed	50	48	14
MAT04610	ALU0769	IA102-A	29.67	34	Failed	56	8	25
MAT04530	ALU0755	IA606-B	13.67	67	Failed	0	14	27
MAT04596	ALU0766	IA106-A	28.67	32	Failed	45	0	41
MAT04597	ALU0767	IA101-B	23.67	53	Failed	10	54	7
MAT04558	ALU0760	IA504-B	17.00	55	Failed	2	42	7
MAT04633	ALU0773	IA101-B	11.00	31	Failed	12	14	7
MAT04599	ALU0767	IA103-B	32.33	36	Failed	53	15	29
MAT04577	ALU0763	IA305-A	3.33	97	Failed	6	3	1
MAT04574	ALU0763	IA302-A	17.00	67	Failed	30	0	21
MAT04578	ALU0763	IA306-A	37.00	76	Failed	57	54	0
MAT04569	ALU0762	IA503-A	25.33	32	Failed	47	14	15
MAT04624	ALU0771	IA604-A	24.33	62	Failed	13	47	13
MAT04528	ALU0755	IA604-B	3.00	50	Failed	2	5	2
MAT04625	ALU0771	IA605-A	33.33	52	Failed	1	58	41
MAT04567	ALU0762	IA501-A	30.67	73	Failed	42	50	0
MAT04533	ALU0756	IA803-B	29.67	44	Failed	39	34	16
MAT04534	ALU0756	IA804-B	33.33	43	Failed	26	42	32
MAT04602	ALU0767	IA106-B	17.00	78	Failed	8	14	29
MAT04570	ALU0762	IA504-A	40.00	73	Failed	46	26	48
MAT04594	ALU0766	IA104-A	31.67	86	Failed	25	52	18
MAT04589	ALU0765	IA705-B	16.33	59	Failed	4	37	8
MAT04529	ALU0755	IA605-B	30.67	45	Failed	37	2	53
MAT04632	ALU0772	IA806-B	11.33	67	Failed	12	22	0
MAT04559	ALU0760	IA505-B	39.33	40	Failed	18	46	54
MAT04634	ALU0773	IA102-B	20.67	57	Failed	21	8	33
MAT04571	ALU0762	IA505-A	34.67	79	Failed	33	23	48
MAT04630	ALU0772	IA804-B	24.67	55	Failed	28	14	32
MAT04635	ALU0773	IA103-B	36.33	53	Failed	40	45	24
MAT04627	ALU0772	IA801-B	21.67	100	Failed	4	58	3
MAT04980	ALU0830	IA206-B	21.33	88	Failed	18	18	28
MAT00036	ALU0006	IA106-A	8.67	92	Failed	1	2	23
MAT04572	ALU0762	IA506-A	39.67	79	Failed	50	30	39
MAT02601	ALU0434	IA703-A	41.00	63	Failed	49	39	35
MAT04560	ALU0760	IA506-B	30.67	45	Failed	19	56	17
MAT03966	ALU0661	IA406-A	28.67	50	Failed	11	54	21
MAT01037	ALU0173	IA305-A	12.67	98	Failed	4	22	12
MAT04710	ALU0785	IA306-A	70.67	91	Approved	62	77	73
MAT04702	ALU0784	IA404-A	74.00	77	Approved	76	83	63
MAT04713	ALU0786	IA603-A	66.33	83	Approved	68	69	62
MAT04639	ALU0774	IA401-B	75.33	99	Approved	70	64	92
MAT04640	ALU0774	IA402-B	74.33	94	Approved	60	99	64
MAT04638	ALU0773	IA106-B	39.67	64	Failed	57	39	23
MAT04714	ALU0786	IA604-A	42.00	51	Failed	49	44	33
MAT04637	ALU0773	IA105-B	26.33	80	Failed	47	9	23
MAT04644	ALU0774	IA406-B	46.67	97	Failed	52	40	48
MAT04670	ALU0779	IA802-A	33.33	61	Failed	12	59	29
MAT04700	ALU0784	IA402-A	41.67	63	Failed	17	56	52
MAT04716	ALU0786	IA606-A	49.67	89	Failed	43	57	49
MAT04643	ALU0774	IA405-B	15.33	32	Failed	32	9	5
MAT04641	ALU0774	IA403-B	17.33	52	Failed	23	11	18
MAT04674	ALU0779	IA806-A	27.33	68	Failed	25	19	38
MAT02898	ALU0483	IA506-B	25.67	43	Failed	19	7	51
MAT04671	ALU0779	IA803-A	30.00	47	Failed	54	7	29
MAT04717	ALU0787	IA501-A	29.33	35	Failed	28	42	18
MAT04203	ALU0701	IA703-B	11.33	59	Failed	18	1	15
MAT04645	ALU0775	IA801-B	38.00	61	Failed	28	29	57
MAT04646	ALU0775	IA802-B	38.33	70	Failed	4	52	59
MAT04711	ALU0786	IA601-A	30.67	68	Failed	35	33	24
MAT04678	ALU0780	IA504-A	35.33	62	Failed	21	34	51
MAT05114	ALU0853	IA402-B	52.00	38	Failed	46	54	56
MAT04725	ALU0788	IA103-A	24.00	60	Failed	26	6	40
MAT04679	ALU0780	IA505-A	25.00	42	Failed	44	26	5
MAT04701	ALU0784	IA403-A	46.67	69	Failed	32	51	57
MAT04696	ALU0783	IA504-A	22.33	46	Failed	57	7	3
MAT04729	ALU0789	IA701-B	26.67	86	Failed	4	47	29
MAT04705	ALU0785	IA301-A	22.33	30	Failed	36	14	17
MAT04689	ALU0782	IA103-B	29.33	80	Failed	6	36	46
MAT04680	ALU0780	IA506-A	12.33	67	Failed	15	7	15
MAT04715	ALU0786	IA605-A	39.00	100	Failed	47	41	29
MAT04673	ALU0779	IA805-A	22.33	93	Failed	14	21	32
MAT04726	ALU0788	IA104-A	18.33	89	Failed	1	36	18
MAT04690	ALU0782	IA104-B	39.00	36	Failed	43	44	30
MAT04692	ALU0782	IA106-B	18.00	98	Failed	1	43	10
MAT04687	ALU0782	IA101-B	31.67	31	Failed	33	19	43
MAT04659	ALU0777	IA303-B	20.33	87	Failed	38	6	17
MAT04677	ALU0780	IA503-A	41.00	63	Failed	9	59	55
MAT04712	ALU0786	IA602-A	23.00	73	Failed	4	57	8
MAT04691	ALU0782	IA105-B	24.33	100	Failed	26	7	40
MAT01963	ALU0328	IA201-B	34.33	51	Failed	34	15	54
MAT04762	ALU0794	IA704-B	93.67	75	Approved	90	97	94
MAT03093	ALU0516	IA603-A	31.33	63	Failed	26	12	56
MAT04751	ALU0792	IA605-B	15.67	85	Failed	3	34	10
MAT04760	ALU0794	IA702-B	24.67	55	Failed	24	38	12
MAT05659	ALU0944	IA101-B	14.67	72	Failed	6	25	13
MAT04822	ALU0804	IA504-B	40.33	89	Failed	59	54	8
MAT04731	ALU0789	IA703-B	38.00	72	Failed	42	59	13
MAT04849	ALU0809	IA301-A	11.33	48	Failed	0	14	20
MAT04779	ALU0797	IA703-A	34.33	89	Failed	1	53	49
MAT04753	ALU0793	IA801-B	24.33	91	Failed	24	49	0
MAT04827	ALU0805	IA803-A	11.00	64	Failed	3	0	30
MAT04777	ALU0797	IA701-A	27.00	88	Failed	6	41	34
MAT02639	ALU0440	IA505-A	36.67	68	Failed	52	31	27
MAT04820	ALU0804	IA502-B	40.00	48	Failed	53	33	34
MAT04767	ALU0795	IA503-B	41.33	60	Failed	59	14	51
MAT04752	ALU0792	IA606-B	30.67	52	Failed	19	38	35
MAT04823	ALU0804	IA505-B	37.67	78	Failed	21	34	58
MAT04855	ALU0810	IA801-B	35.00	58	Failed	57	45	3
MAT00167	ALU0028	IA305-B	49.33	44	Failed	41	57	50
MAT02167	ALU0362	IA401-B	20.33	56	Failed	42	0	19
MAT05978	ALU0997	IA202-A	19.33	37	Failed	13	21	24
MAT04856	ALU0810	IA802-B	16.33	97	Failed	2	3	44
MAT00395	ALU0066	IA305-B	33.00	76	Failed	45	38	16
MAT04764	ALU0794	IA706-B	42.67	51	Failed	27	47	54
MAT04732	ALU0789	IA704-B	29.33	77	Failed	39	26	23
MAT04749	ALU0792	IA603-B	41.00	60	Failed	56	8	59
MAT00463	ALU0078	IA101-A	26.33	94	Failed	18	22	39
MAT04771	ALU0796	IA701-A	40.67	86	Failed	29	35	58
MAT04782	ALU0797	IA706-A	37.67	86	Failed	50	41	22
MAT04781	ALU0797	IA705-A	12.33	92	Failed	4	10	23
MAT04766	ALU0795	IA502-B	37.33	54	Failed	29	47	36
MAT03863	ALU0644	IA505-A	37.33	76	Failed	43	10	59
MAT04733	ALU0789	IA705-B	24.00	99	Failed	13	35	24
MAT04763	ALU0794	IA705-B	18.67	67	Failed	1	8	47
MAT04734	ALU0789	IA706-B	45.00	51	Failed	42	59	34
MAT04765	ALU0795	IA501-B	27.67	55	Failed	41	16	26
MAT04830	ALU0805	IA806-A	25.00	82	Failed	31	37	7
MAT04769	ALU0795	IA505-B	15.00	45	Failed	3	34	8
MAT04748	ALU0792	IA602-B	44.33	37	Failed	37	57	39
MAT04819	ALU0804	IA501-B	18.67	81	Failed	10	16	30
MAT04925	ALU0821	IA805-A	77.67	86	Approved	66	78	89
MAT04901	ALU0817	IA705-A	77.33	78	Approved	81	65	86
MAT03065	ALU0511	IA605-B	79.33	96	Approved	67	82	89
MAT04938	ALU0823	IA406-B	72.67	84	Approved	71	64	83
MAT00162	ALU0027	IA206-B	74.33	81	Approved	67	90	66
MAT04920	ALU0820	IA206-A	86.33	86	Approved	70	92	97
MAT04911	ALU0819	IA203-B	39.00	45	Failed	55	34	28
MAT04940	ALU0824	IA302-B	27.00	67	Failed	38	12	31
MAT04913	ALU0819	IA205-B	34.33	91	Failed	38	12	53
MAT04917	ALU0820	IA203-A	21.33	99	Failed	51	0	13
MAT04869	ALU0812	IA403-A	24.00	76	Failed	15	1	56
MAT04929	ALU0822	IA403-B	15.67	85	Failed	17	21	9
MAT04868	ALU0812	IA402-A	29.67	65	Failed	49	22	18
MAT04870	ALU0812	IA404-A	42.00	41	Failed	47	21	58
MAT04924	ALU0821	IA804-A	32.00	96	Failed	10	48	38
MAT05053	ALU0843	IA701-B	40.00	100	Failed	32	51	37
MAT04871	ALU0812	IA405-A	46.67	61	Failed	44	42	54
MAT03592	ALU0599	IA704-B	47.00	51	Failed	55	58	28
MAT04937	ALU0823	IA405-B	39.00	47	Failed	38	34	45
MAT00741	ALU0124	IA803-B	30.33	50	Failed	22	53	16
MAT04880	ALU0814	IA202-B	34.00	64	Failed	10	57	35
MAT05361	ALU0894	IA303-B	18.33	51	Failed	4	49	2
MAT04910	ALU0819	IA202-B	27.33	85	Failed	24	2	56
MAT04922	ALU0821	IA802-A	26.00	74	Failed	35	7	36
MAT04921	ALU0821	IA801-A	29.33	68	Failed	4	28	56
MAT03225	ALU0538	IA203-A	17.67	92	Failed	4	35	14
MAT03477	ALU0580	IA303-A	14.00	73	Failed	31	7	4
MAT04864	ALU0811	IA404-B	33.33	42	Failed	2	43	55
MAT04900	ALU0817	IA704-A	42.33	99	Failed	30	38	59
MAT04915	ALU0820	IA201-A	30.67	53	Failed	41	30	21
MAT04936	ALU0823	IA404-B	38.33	40	Failed	43	58	14
MAT04872	ALU0812	IA406-A	47.00	54	Failed	47	40	54
MAT04881	ALU0814	IA203-B	35.33	46	Failed	47	40	19
MAT04916	ALU0820	IA202-A	32.00	91	Failed	30	19	47
MAT04866	ALU0811	IA406-B	44.00	43	Failed	49	41	42
MAT04848	ALU0808	IA306-B	22.33	34	Failed	7	24	36
MAT05785	ALU0965	IA701-B	56.33	65	Failed	59	52	58
MAT04923	ALU0821	IA803-A	12.33	32	Failed	7	24	6
MAT04906	ALU0818	IA704-A	38.67	50	Failed	26	50	40
MAT03465	ALU0578	IA203-A	68.00	75	Approved	63	75	66
MAT04989	ALU0832	IA703-B	83.67	95	Approved	90	76	85
MAT05040	ALU0840	IA606-B	84.00	87	Approved	84	75	93
MAT00097	ALU0017	IA501-B	90.00	98	Approved	100	89	81
MAT05027	ALU0838	IA505-A	73.33	92	Approved	74	73	73
MAT05010	ALU0835	IA306-B	79.67	82	Approved	79	69	91
MAT05554	ALU0926	IA704-B	38.33	48	Failed	48	55	12
MAT04993	ALU0833	IA601-B	19.67	48	Failed	17	22	20
MAT02753	ALU0459	IA705-A	27.67	83	Failed	9	35	39
MAT04981	ALU0831	IA501-B	53.33	54	Failed	49	55	56
MAT04987	ALU0832	IA701-B	15.00	46	Failed	27	13	5
MAT04992	ALU0832	IA706-B	55.33	78	Failed	54	57	55
MAT04968	ALU0828	IA806-B	21.67	80	Failed	27	35	3
MAT05843	ALU0974	IA305-B	25.67	32	Failed	1	59	17
MAT05021	ALU0837	IA405-A	39.00	60	Failed	50	54	13
MAT05017	ALU0837	IA401-A	33.00	35	Failed	54	31	14
MAT04205	ALU0701	IA705-B	37.00	55	Failed	29	24	58
MAT03804	ALU0634	IA306-B	35.67	93	Failed	52	2	53
MAT05028	ALU0838	IA506-A	31.33	59	Failed	53	31	10
MAT05031	ALU0839	IA203-B	32.33	76	Failed	2	46	49
MAT04966	ALU0828	IA804-B	17.00	56	Failed	42	8	1
MAT04969	ALU0829	IA401-A	30.00	88	Failed	15	51	24
MAT04990	ALU0832	IA704-B	37.00	61	Failed	27	49	35
MAT03108	ALU0518	IA106-B	46.33	57	Failed	54	27	58
MAT04994	ALU0833	IA602-B	21.33	87	Failed	44	2	18
MAT05026	ALU0838	IA504-A	39.67	80	Failed	51	43	25
MAT04995	ALU0833	IA603-B	14.33	46	Failed	34	7	2
MAT01668	ALU0278	IA506-B	41.67	44	Failed	28	57	40
MAT05043	ALU0841	IA603-B	22.00	65	Failed	32	0	34
MAT05029	ALU0839	IA201-B	17.67	37	Failed	2	30	21
MAT05041	ALU0841	IA601-B	29.00	75	Failed	36	48	3
MAT04988	ALU0832	IA702-B	36.00	56	Failed	14	41	53
MAT04991	ALU0832	IA705-B	32.00	56	Failed	36	53	7
MAT04996	ALU0833	IA604-B	33.33	50	Failed	29	14	57
MAT05146	ALU0858	IA204-B	42.67	65	Failed	18	56	54
MAT05002	ALU0834	IA104-B	11.67	48	Failed	19	12	4
MAT05019	ALU0837	IA403-A	31.67	91	Failed	16	52	27
MAT05183	ALU0864	IA105-A	87.33	87	Approved	97	65	100
MAT05107	ALU0852	IA701-A	86.33	91	Approved	99	96	64
MAT05133	ALU0856	IA603-B	82.67	95	Approved	92	95	61
MAT05158	ALU0860	IA204-B	76.00	86	Approved	85	63	80
MAT05723	ALU0954	IA505-B	74.33	85	Approved	66	72	85
MAT05796	ALU0966	IA606-B	66.67	86	Approved	61	68	71
MAT05111	ALU0852	IA705-A	89.33	98	Approved	92	84	92
MAT02516	ALU0420	IA602-A	87.00	86	Approved	89	83	89
MAT05141	ALU0857	IA405-A	38.33	96	Failed	46	18	51
MAT05134	ALU0856	IA604-B	42.33	46	Failed	28	52	47
MAT05362	ALU0894	IA304-B	31.00	74	Failed	37	5	51
MAT02634	ALU0439	IA806-B	28.00	32	Failed	10	49	25
MAT05108	ALU0852	IA702-A	31.00	81	Failed	39	47	7
MAT05187	ALU0865	IA403-B	29.67	86	Failed	10	25	54
MAT05157	ALU0860	IA203-B	25.00	39	Failed	15	6	54
MAT05119	ALU0854	IA801-B	37.00	30	Failed	50	29	32
MAT05106	ALU0851	IA306-A	38.67	37	Failed	18	47	51
MAT05159	ALU0860	IA205-B	44.67	97	Failed	46	56	32
MAT01033	ALU0173	IA301-A	51.33	80	Failed	55	48	51
MAT05182	ALU0864	IA104-A	38.00	31	Failed	34	38	42
MAT05856	ALU0976	IA306-A	30.33	90	Failed	34	57	0
MAT05160	ALU0860	IA206-B	27.33	40	Failed	9	59	14
MAT03613	ALU0603	IA801-A	20.00	88	Failed	34	16	10
MAT00746	ALU0125	IA302-B	37.67	73	Failed	38	35	40
MAT05184	ALU0864	IA106-A	21.33	36	Failed	5	30	29
MAT05155	ALU0860	IA201-B	40.33	68	Failed	52	19	50
MAT03243	ALU0541	IA603-A	40.00	70	Failed	26	51	43
MAT05139	ALU0857	IA403-A	28.00	77	Failed	52	30	2
MAT02328	ALU0388	IA806-B	34.33	84	Failed	19	44	40
MAT05565	ALU0928	IA803-B	38.00	84	Failed	38	44	32
MAT03432	ALU0572	IA206-A	21.67	64	Failed	9	27	29
MAT05156	ALU0860	IA202-B	49.33	46	Failed	58	37	53
MAT05132	ALU0856	IA602-B	41.67	44	Failed	25	45	55
MAT02750	ALU0459	IA702-A	23.67	82	Failed	17	42	12
MAT05185	ALU0865	IA401-B	57.00	52	Failed	57	59	55
MAT04344	ALU0724	IA406-B	33.33	82	Failed	38	33	29
MAT03312	ALU0552	IA406-B	18.00	46	Failed	5	4	45
MAT05247	ALU0875	IA703-B	91.00	78	Approved	91	98	84
MAT05210	ALU0869	IA802-B	86.00	86	Approved	88	71	99
MAT02025	ALU0338	IA103-B	87.33	99	Approved	95	68	99
MAT05262	ALU0877	IA106-B	77.67	84	Approved	72	84	77
MAT05218	ALU0870	IA804-B	82.33	78	Approved	88	90	69
MAT01542	ALU0257	IA406-B	34.67	86	Failed	35	43	26
MAT05274	ALU0879	IA306-B	42.00	66	Failed	31	47	48
MAT05225	ALU0871	IA705-A	41.00	57	Failed	59	39	25
MAT05249	ALU0875	IA705-B	36.67	32	Failed	1	59	50
MAT05261	ALU0877	IA105-B	21.00	36	Failed	5	8	50
MAT05214	ALU0869	IA806-B	20.00	48	Failed	33	26	1
MAT05217	ALU0870	IA803-B	25.67	30	Failed	44	1	32
MAT05227	ALU0872	IA201-A	31.33	63	Failed	18	53	23
MAT05220	ALU0870	IA806-B	31.67	42	Failed	19	46	30
MAT05226	ALU0871	IA706-A	27.00	46	Failed	28	28	25
MAT05216	ALU0870	IA802-B	47.33	60	Failed	45	45	52
MAT05269	ALU0879	IA301-B	23.33	63	Failed	47	2	21
MAT00411	ALU0069	IA103-A	15.67	52	Failed	24	23	0
MAT05243	ALU0874	IA205-B	23.33	53	Failed	22	32	16
MAT01559	ALU0260	IA805-B	21.33	81	Failed	22	8	34
MAT05234	ALU0873	IA302-B	23.67	53	Failed	9	38	24
MAT05230	ALU0872	IA204-A	31.33	31	Failed	55	14	25
MAT05251	ALU0876	IA801-B	22.33	100	Failed	53	3	11
MAT05209	ALU0869	IA801-B	48.00	65	Failed	51	39	54
MAT05219	ALU0870	IA805-B	13.33	66	Failed	3	6	31
MAT05275	ALU0880	IA101-B	51.67	43	Failed	56	41	58
MAT05245	ALU0875	IA701-B	21.33	74	Failed	3	52	9
MAT05270	ALU0879	IA302-B	19.33	45	Failed	28	25	5
MAT05222	ALU0871	IA702-A	27.67	46	Failed	56	27	0
MAT04960	ALU0827	IA204-B	15.33	56	Failed	23	22	1
MAT05035	ALU0840	IA601-B	28.33	71	Failed	33	7	45
MAT05224	ALU0871	IA704-A	32.00	60	Failed	57	8	31
MAT05228	ALU0872	IA202-A	30.00	63	Failed	17	36	37
MAT05253	ALU0876	IA803-B	35.67	87	Failed	59	33	15
MAT05242	ALU0874	IA204-B	45.00	50	Failed	51	56	28
MAT05232	ALU0872	IA206-A	31.33	58	Failed	40	39	15
MAT05257	ALU0877	IA101-B	9.00	93	Failed	19	8	0
MAT05256	ALU0876	IA806-B	29.00	94	Failed	21	29	37
MAT05211	ALU0869	IA803-B	34.00	36	Failed	40	47	15
MAT05273	ALU0879	IA305-B	31.67	71	Failed	44	44	7
MAT03976	ALU0663	IA804-B	86.33	86	Approved	99	62	98
MAT02695	ALU0450	IA501-A	83.67	83	Approved	69	96	86
MAT05286	ALU0881	IA106-A	84.00	88	Approved	76	90	86
MAT05295	ALU0883	IA703-B	92.33	95	Approved	86	95	96
MAT05278	ALU0880	IA104-B	82.00	88	Approved	87	70	89
MAT05281	ALU0881	IA101-A	32.00	63	Failed	34	45	17
MAT03733	ALU0623	IA601-A	33.67	75	Failed	44	56	1
MAT00305	ALU0051	IA105-A	29.00	66	Failed	27	48	12
MAT00519	ALU0087	IA803-B	6.33	99	Failed	0	17	2
MAT05340	ALU0890	IA106-A	33.00	82	Failed	39	25	35
MAT03927	ALU0655	IA803-A	26.33	58	Failed	9	30	40
MAT03246	ALU0541	IA606-A	45.00	80	Failed	40	54	41
MAT05283	ALU0881	IA103-A	16.00	48	Failed	22	7	19
MAT03757	ALU0627	IA101-B	27.67	56	Failed	33	11	39
MAT05324	ALU0888	IA502-B	52.00	38	Failed	47	56	53
MAT02344	ALU0391	IA704-A	28.67	88	Failed	45	9	32
MAT05334	ALU0889	IA506-B	41.33	67	Failed	48	57	19
MAT05299	ALU0884	IA601-A	43.33	72	Failed	42	46	42
MAT01301	ALU0217	IA505-B	16.33	71	Failed	2	3	44
MAT05294	ALU0883	IA702-B	37.33	73	Failed	12	45	55
MAT02249	ALU0375	IA605-A	29.00	83	Failed	24	28	35
MAT02357	ALU0393	IA405-B	36.67	54	Failed	57	47	6
MAT05339	ALU0890	IA105-A	47.33	65	Failed	53	53	36
MAT01541	ALU0257	IA405-B	7.33	48	Failed	7	12	3
MAT05325	ALU0888	IA503-B	26.67	49	Failed	23	50	7
MAT05303	ALU0884	IA605-A	14.00	98	Failed	6	1	35
MAT05147	ALU0858	IA205-B	48.00	47	Failed	50	52	42
MAT05349	ALU0892	IA403-B	4.67	53	Failed	7	6	1
MAT05343	ALU0891	IA303-B	29.00	82	Failed	30	23	34
MAT05342	ALU0891	IA302-B	21.33	63	Failed	58	3	3
MAT05347	ALU0892	IA401-B	32.67	46	Failed	19	48	31
MAT05345	ALU0891	IA305-B	30.33	32	Failed	1	44	46
MAT05298	ALU0883	IA706-B	34.33	31	Failed	57	23	23
MAT05348	ALU0892	IA402-B	40.67	69	Failed	59	38	25
MAT05360	ALU0894	IA302-B	31.33	34	Failed	39	19	36
MAT05296	ALU0883	IA704-B	35.33	42	Failed	11	54	41
MAT05430	ALU0905	IA206-B	81.67	92	Approved	88	64	93
MAT03209	ALU0535	IA105-B	91.33	76	Approved	97	84	93
MAT05921	ALU0987	IA505-A	92.33	82	Approved	94	87	96
MAT00568	ALU0095	IA304-A	80.67	78	Approved	97	66	79
MAT00581	ALU0097	IA605-A	72.00	80	Approved	74	69	73
MAT03917	ALU0653	IA605-B	33.33	46	Failed	22	30	48
MAT05398	ALU0900	IA304-A	15.67	70	Failed	11	30	6
MAT01621	ALU0271	IA101-B	38.67	38	Failed	53	54	9
MAT04770	ALU0795	IA506-B	34.33	84	Failed	17	38	48
MAT00753	ALU0126	IA703-B	31.33	64	Failed	51	38	5
MAT02177	ALU0363	IA805-B	24.67	59	Failed	9	59	6
MAT05403	ALU0901	IA203-A	33.33	39	Failed	45	36	19
MAT05136	ALU0856	IA606-B	35.33	35	Failed	30	25	51
MAT05012	ALU0836	IA602-B	40.00	93	Failed	22	53	45
MAT01493	ALU0249	IA205-A	35.67	30	Failed	42	14	51
MAT05436	ALU0906	IA106-B	36.67	90	Failed	50	6	54
MAT05473	ALU0913	IA201-B	36.00	41	Failed	17	36	55
MAT05450	ALU0909	IA402-B	23.67	70	Failed	49	21	1
MAT04199	ALU0700	IA505-B	38.00	36	Failed	53	7	54
MAT03182	ALU0531	IA302-B	50.33	63	Failed	49	58	44
MAT05448	ALU0908	IA706-B	40.00	60	Failed	54	48	18
MAT05461	ALU0911	IA501-A	23.33	42	Failed	51	0	19
MAT05493	ALU0916	IA403-B	25.33	52	Failed	3	44	29
MAT05445	ALU0908	IA703-B	30.33	37	Failed	28	50	13
MAT05229	ALU0872	IA203-A	33.00	77	Failed	28	23	48
MAT05427	ALU0905	IA203-B	17.33	85	Failed	34	5	13
MAT02369	ALU0395	IA305-B	26.67	82	Failed	28	3	49
MAT04479	ALU0747	IA703-B	40.33	81	Failed	58	10	53
MAT05474	ALU0913	IA202-B	35.33	80	Failed	36	29	41
MAT05558	ALU0927	IA602-B	19.00	89	Failed	15	15	27
MAT05399	ALU0900	IA305-A	20.00	48	Failed	0	26	34
MAT02643	ALU0441	IA603-B	89.00	84	Approved	86	89	92
MAT04247	ALU0708	IA805-B	84.00	80	Approved	97	71	84
MAT02791	ALU0466	IA601-B	69.67	85	Approved	72	64	73
MAT05588	ALU0932	IA302-B	24.33	66	Failed	36	4	33
MAT02041	ALU0341	IA401-B	42.67	85	Failed	26	48	54
MAT04201	ALU0701	IA701-B	30.67	72	Failed	56	22	14
MAT05615	ALU0936	IA305-B	29.67	89	Failed	33	25	31
MAT05617	ALU0937	IA501-B	25.00	81	Failed	38	2	35
MAT05667	ALU0945	IA303-B	16.33	100	Failed	43	4	2
MAT05652	ALU0942	IA706-B	18.33	70	Failed	4	24	27
MAT01431	ALU0239	IA103-B	40.33	43	Failed	51	47	23
MAT05641	ALU0941	IA201-B	40.00	46	Failed	17	52	51
MAT04845	ALU0808	IA303-B	25.67	63	Failed	8	44	25
MAT05638	ALU0940	IA304-B	35.67	51	Failed	31	52	24
MAT05612	ALU0936	IA302-B	41.67	40	Failed	22	54	49
MAT05596	ALU0933	IA704-B	21.67	68	Failed	19	3	43
MAT02121	ALU0354	IA703-B	33.00	79	Failed	41	30	28
MAT03235	ALU0540	IA401-A	20.00	67	Failed	0	38	22
MAT00678	ALU0113	IA706-B	34.00	45	Failed	53	35	14
MAT05616	ALU0936	IA306-B	32.33	91	Failed	54	43	0
MAT05589	ALU0932	IA303-B	20.00	42	Failed	15	37	8
MAT05582	ALU0931	IA502-A	18.67	47	Failed	53	1	2
MAT05587	ALU0932	IA301-B	20.33	85	Failed	21	34	6
MAT05668	ALU0945	IA304-B	48.00	68	Failed	38	53	53
MAT05592	ALU0932	IA306-B	27.67	46	Failed	16	50	17
MAT05632	ALU0939	IA104-B	33.33	50	Failed	59	26	15
MAT05614	ALU0936	IA304-B	23.00	73	Failed	9	29	31
MAT05590	ALU0932	IA304-B	49.67	59	Failed	56	55	38
MAT04828	ALU0805	IA804-A	20.00	86	Failed	3	10	47
MAT05583	ALU0931	IA503-A	37.00	68	Failed	31	29	51
MAT05627	ALU0938	IA305-B	36.67	73	Failed	45	13	52
MAT05666	ALU0945	IA302-B	40.33	91	Failed	53	38	30
MAT05650	ALU0942	IA704-B	33.33	89	Failed	47	1	52
MAT05586	ALU0931	IA506-A	32.67	33	Failed	14	49	35
MAT05639	ALU0940	IA305-B	20.67	56	Failed	25	37	0
MAT05665	ALU0945	IA301-B	35.00	86	Failed	43	13	49
MAT05630	ALU0939	IA102-B	23.33	44	Failed	41	7	22
MAT05095	ALU0850	IA101-B	73.33	96	Approved	60	89	71
MAT05190	ALU0865	IA406-B	72.33	90	Approved	86	69	62
MAT04024	ALU0671	IA804-A	80.33	76	Approved	98	78	65
MAT05022	ALU0837	IA406-A	81.33	100	Approved	86	75	83
MAT05712	ALU0952	IA206-B	79.00	78	Approved	75	90	72
MAT05790	ALU0965	IA706-B	67.00	93	Approved	60	70	71
MAT05748	ALU0958	IA506-B	79.00	85	Approved	69	88	80
MAT00679	ALU0114	IA801-B	85.00	97	Approved	81	85	89
MAT05757	ALU0960	IA803-A	64.67	99	Approved	63	68	63
MAT05767	ALU0962	IA301-B	73.00	83	Approved	74	61	84
MAT05708	ALU0952	IA202-B	26.33	67	Failed	25	6	48
MAT04464	ALU0744	IA306-B	21.67	89	Failed	8	4	53
MAT01563	ALU0261	IA103-A	18.67	85	Failed	17	3	36
MAT03712	ALU0619	IA204-B	29.00	67	Failed	50	3	34
MAT01344	ALU0224	IA706-B	27.33	98	Failed	29	36	17
MAT05739	ALU0957	IA503-B	26.67	86	Failed	24	29	27
MAT01157	ALU0193	IA505-A	31.00	46	Failed	11	23	59
MAT05740	ALU0957	IA504-B	34.67	46	Failed	18	56	30
MAT05709	ALU0952	IA203-B	27.00	33	Failed	51	11	19
MAT05742	ALU0957	IA506-B	37.00	70	Failed	12	42	57
MAT03061	ALU0511	IA601-B	23.00	84	Failed	9	12	48
MAT02733	ALU0456	IA603-A	8.67	86	Failed	9	8	9
MAT01294	ALU0216	IA204-A	12.33	95	Failed	11	15	11
MAT05716	ALU0953	IA404-B	34.67	54	Failed	31	34	39
MAT05756	ALU0960	IA802-A	16.33	39	Failed	17	14	18
MAT05745	ALU0958	IA503-B	33.00	41	Failed	24	59	16
MAT05741	ALU0957	IA505-B	31.00	46	Failed	59	4	30
MAT00838	ALU0140	IA204-A	19.33	51	Failed	33	17	8
MAT05798	ALU0967	IA402-B	28.33	52	Failed	22	22	41
MAT03602	ALU0601	IA602-B	28.33	54	Failed	18	29	38
MAT05869	ALU0979	IA601-B	80.67	95	Approved	79	79	84
MAT05907	ALU0985	IA803-B	64.00	97	Approved	60	69	63
MAT05905	ALU0985	IA801-B	81.67	96	Approved	72	89	84
MAT05876	ALU0980	IA202-B	28.33	78	Failed	39	37	9
MAT00465	ALU0078	IA103-A	17.00	94	Failed	17	11	23
MAT05874	ALU0979	IA606-B	42.67	48	Failed	38	53	37
MAT05918	ALU0987	IA502-A	39.67	81	Failed	47	30	42
MAT04565	ALU0761	IA705-A	39.00	68	Failed	20	47	50
MAT05893	ALU0983	IA601-B	29.67	79	Failed	1	42	46
MAT02665	ALU0445	IA801-B	30.33	94	Failed	6	36	49
MAT05899	ALU0984	IA501-B	29.00	52	Failed	56	24	7
MAT05871	ALU0979	IA603-B	11.67	73	Failed	13	13	9
MAT05870	ALU0979	IA602-B	18.00	67	Failed	9	25	20
MAT05927	ALU0988	IA205-B	27.67	78	Failed	33	44	6
MAT05882	ALU0981	IA602-B	19.67	63	Failed	41	12	6
MAT01573	ALU0263	IA801-B	20.00	71	Failed	11	20	29
MAT05903	ALU0984	IA505-B	10.33	58	Failed	22	5	4
MAT05904	ALU0984	IA506-B	27.33	84	Failed	8	50	24
MAT05909	ALU0985	IA805-B	37.67	71	Failed	49	9	55
MAT05887	ALU0982	IA201-B	51.33	33	Failed	46	51	57
MAT05908	ALU0985	IA804-B	30.67	90	Failed	8	57	27
MAT05675	ALU0946	IA105-B	10.00	36	Failed	6	24	0
MAT05911	ALU0986	IA601-B	24.00	77	Failed	2	54	16
MAT05910	ALU0985	IA806-B	31.33	37	Failed	45	14	35
MAT05926	ALU0988	IA204-B	32.33	82	Failed	31	10	56
MAT05857	ALU0977	IA101-B	44.67	57	Failed	55	23	56
MAT05879	ALU0980	IA205-B	23.00	30	Failed	19	27	23
MAT05872	ALU0979	IA604-B	19.00	96	Failed	8	12	37
MAT05897	ALU0983	IA605-B	38.33	85	Failed	54	48	13
MAT05896	ALU0983	IA604-B	51.67	59	Failed	43	56	56
MAT05885	ALU0981	IA605-B	18.33	95	Failed	17	10	28
MAT05894	ALU0983	IA602-B	23.33	97	Failed	28	39	3
MAT04300	ALU0717	IA104-B	29.33	54	Failed	11	54	23
MAT05898	ALU0983	IA606-B	10.00	62	Failed	12	12	6
MAT05900	ALU0984	IA502-B	20.33	77	Failed	7	53	1
MAT05892	ALU0982	IA206-B	31.67	44	Failed	50	5	40
MAT05916	ALU0986	IA606-B	24.67	55	Failed	13	52	9
MAT05115	ALU0853	IA403-B	33.67	92	Failed	37	6	58
MAT05858	ALU0977	IA102-B	16.00	50	Failed	16	31	1
MAT05861	ALU0977	IA105-B	32.33	81	Failed	54	15	28
MAT00128	ALU0022	IA402-A	80.00	79	Approved	86	74	80
MAT05965	ALU0995	IA601-B	62.67	82	Approved	61	62	65
MAT04907	ALU0818	IA705-A	74.33	89	Approved	94	69	60
MAT00003	ALU0001	IA203-B	69.00	99	Approved	60	78	69
MAT00006	ALU0001	IA206-B	76.67	98	Approved	85	78	67
MAT05968	ALU0995	IA604-B	70.00	90	Approved	69	67	74
MAT05976	ALU0996	IA106-A	20.00	98	Failed	17	20	23
MAT00118	ALU0020	IA704-B	16.67	94	Failed	18	13	19
MAT05967	ALU0995	IA603-B	35.00	84	Failed	48	41	16
MAT05961	ALU0994	IA803-A	38.67	64	Failed	35	39	42
MAT05970	ALU0995	IA606-B	39.00	95	Failed	28	41	48
MAT05971	ALU0996	IA101-A	29.33	51	Failed	31	0	57
MAT00038	ALU0007	IA502-B	30.33	100	Failed	33	33	25
MAT00029	ALU0005	IA405-B	27.00	75	Failed	8	56	17
MAT00040	ALU0007	IA504-B	29.00	68	Failed	22	32	33
MAT00039	ALU0007	IA503-B	14.67	33	Failed	1	34	9
MAT00042	ALU0007	IA506-B	14.00	88	Failed	8	19	15
MAT05966	ALU0995	IA602-B	23.33	45	Failed	19	32	19
MAT03807	ALU0635	IA403-B	51.33	76	Failed	43	53	58
MAT00076	ALU0013	IA704-A	47.00	92	Failed	47	38	56
MAT00046	ALU0008	IA204-A	12.67	38	Failed	30	8	0
MAT00004	ALU0001	IA204-B	24.33	36	Failed	0	47	26
MAT00106	ALU0018	IA604-B	12.67	82	Failed	15	4	19
MAT03491	ALU0582	IA205-B	42.67	66	Failed	43	28	57
MAT00078	ALU0013	IA706-A	30.33	64	Failed	17	56	18
MAT00037	ALU0007	IA501-B	31.33	61	Failed	49	31	14
MAT05963	ALU0994	IA805-A	45.00	83	Failed	49	56	30
MAT00151	ALU0026	IA401-A	36.33	66	Failed	35	55	19
MAT05958	ALU0993	IA406-B	44.00	91	Failed	45	41	46
MAT00155	ALU0026	IA405-A	29.67	81	Failed	39	10	40
MAT00093	ALU0016	IA203-A	36.67	47	Failed	37	27	46
MAT05959	ALU0994	IA801-A	12.67	62	Failed	14	20	4
MAT02615	ALU0436	IA205-A	2.67	37	Failed	4	4	0
MAT05082	ALU0847	IA806-A	27.67	94	Failed	41	41	1
MAT00153	ALU0026	IA403-A	43.00	93	Failed	31	49	49
MAT04631	ALU0772	IA805-B	38.00	74	Failed	47	14	53
MAT04949	ALU0825	IA505-B	32.00	71	Failed	25	45	26
MAT01865	ALU0311	IA405-A	20.33	33	Failed	12	16	33
MAT05956	ALU0993	IA404-B	36.67	37	Failed	27	39	44
MAT05803	ALU0968	IA501-B	34.67	51	Failed	29	26	49
MAT00551	ALU0092	IA105-A	86.33	76	Approved	92	67	100
MAT03761	ALU0627	IA105-B	74.67	94	Approved	74	68	82
MAT00476	ALU0080	IA202-A	81.33	96	Approved	77	99	68
MAT00269	ALU0045	IA105-B	77.00	91	Approved	66	79	86
MAT00371	ALU0062	IA205-A	32.33	61	Failed	34	12	51
MAT00574	ALU0096	IA104-A	44.33	32	Failed	21	54	58
MAT00456	ALU0076	IA806-B	42.67	82	Failed	35	46	47
MAT00375	ALU0063	IA803-B	29.00	52	Failed	16	21	50
MAT02407	ALU0402	IA301-A	24.00	56	Failed	27	24	21
MAT05722	ALU0954	IA504-B	24.33	48	Failed	36	26	11
MAT02947	ALU0492	IA701-B	47.67	57	Failed	46	53	44
MAT04070	ALU0679	IA102-B	30.33	75	Failed	25	34	32
MAT00471	ALU0079	IA403-B	33.00	69	Failed	14	47	38
MAT00643	ALU0108	IA401-A	22.67	43	Failed	10	46	12
MAT00459	ALU0077	IA403-A	24.00	81	Failed	9	51	12
MAT00569	ALU0095	IA305-A	18.33	65	Failed	12	10	33
MAT00570	ALU0095	IA306-A	28.00	35	Failed	15	43	26
MAT00458	ALU0077	IA402-A	29.67	58	Failed	18	35	36
MAT00442	ALU0074	IA304-B	19.67	60	Failed	45	3	11
MAT00549	ALU0092	IA103-A	25.00	46	Failed	1	31	43
MAT00385	ALU0065	IA701-A	9.00	87	Failed	19	3	5
MAT00367	ALU0062	IA201-A	17.33	95	Failed	1	19	32
MAT00629	ALU0105	IA805-B	24.00	51	Failed	32	11	29
MAT00640	ALU0107	IA304-B	24.33	81	Failed	38	21	14
MAT00474	ALU0079	IA406-B	27.33	47	Failed	32	8	42
MAT05851	ALU0976	IA301-A	31.67	43	Failed	47	35	13
MAT00440	ALU0074	IA302-B	24.00	73	Failed	26	14	32
MAT00548	ALU0092	IA102-A	31.67	30	Failed	29	28	38
MAT03939	ALU0657	IA803-B	42.33	77	Failed	39	30	58
MAT00630	ALU0105	IA806-B	33.67	62	Failed	55	5	41
MAT00473	ALU0079	IA405-B	38.33	42	Failed	41	35	39
MAT03689	ALU0615	IA305-B	10.00	30	Failed	3	5	22
MAT05165	ALU0861	IA205-B	35.00	85	Failed	49	27	29
MAT00347	ALU0058	IA105-B	33.00	84	Failed	54	38	7
MAT00550	ALU0092	IA104-A	37.00	51	Failed	46	23	42
MAT00444	ALU0074	IA306-B	44.33	78	Failed	59	47	27
MAT00453	ALU0076	IA803-B	48.33	47	Failed	56	40	49
MAT00573	ALU0096	IA103-A	17.67	76	Failed	6	0	47
MAT00469	ALU0079	IA401-B	36.33	44	Failed	37	49	23
MAT00436	ALU0073	IA604-B	28.00	44	Failed	2	38	44
MAT01060	ALU0177	IA704-B	65.67	97	Approved	65	65	67
MAT01069	ALU0179	IA101-B	85.33	75	Approved	93	95	68
MAT05208	ALU0868	IA306-B	84.67	75	Approved	81	94	79
MAT00873	ALU0146	IA203-B	66.67	94	Approved	75	62	63
MAT05282	ALU0881	IA102-A	84.33	80	Approved	93	67	93
MAT01050	ALU0175	IA306-B	78.33	76	Approved	68	91	76
MAT00770	ALU0129	IA602-B	84.00	83	Approved	95	82	75
MAT05760	ALU0960	IA806-A	86.67	97	Approved	86	79	95
MAT00996	ALU0166	IA106-B	89.33	82	Approved	74	100	94
MAT01382	ALU0231	IA502-B	35.67	31	Failed	42	37	28
MAT00842	ALU0141	IA802-B	23.33	94	Failed	13	36	21
MAT02030	ALU0339	IA302-B	33.33	31	Failed	33	44	23
MAT00992	ALU0166	IA102-B	40.67	90	Failed	54	23	45
MAT00807	ALU0135	IA303-B	37.67	78	Failed	41	29	43
MAT00879	ALU0147	IA203-B	38.00	85	Failed	53	8	53
MAT02202	ALU0367	IA806-B	28.00	73	Failed	28	1	55
MAT04419	ALU0737	IA703-B	8.00	55	Failed	7	6	11
MAT01827	ALU0305	IA303-B	22.33	88	Failed	1	27	39
MAT00771	ALU0129	IA603-B	28.00	45	Failed	18	44	22
MAT01869	ALU0312	IA803-A	24.00	37	Failed	8	22	42
MAT00937	ALU0157	IA201-A	17.00	74	Failed	3	40	8
MAT04340	ALU0724	IA402-B	24.33	39	Failed	51	14	8
MAT05844	ALU0974	IA306-B	6.00	85	Failed	1	12	5
MAT00733	ALU0123	IA101-B	9.67	48	Failed	2	13	14
MAT01039	ALU0174	IA701-B	43.67	49	Failed	52	58	21
MAT02799	ALU0467	IA303-B	40.00	81	Failed	52	16	52
MAT00862	ALU0144	IA604-B	29.33	69	Failed	32	40	16
MAT01073	ALU0179	IA105-B	27.67	34	Failed	36	17	30
MAT01074	ALU0179	IA106-B	45.00	77	Failed	34	54	47
MAT00876	ALU0146	IA206-B	28.00	58	Failed	8	32	44
MAT00522	ALU0087	IA806-B	17.67	65	Failed	22	14	17
MAT01424	ALU0238	IA802-A	41.33	64	Failed	44	31	49
MAT01072	ALU0179	IA104-B	18.67	39	Failed	2	52	2
MAT01409	ALU0235	IA605-A	80.00	99	Approved	69	74	97
MAT05018	ALU0837	IA402-A	72.67	76	Approved	61	77	80
MAT01331	ALU0222	IA705-B	82.00	88	Approved	81	74	91
MAT01835	ALU0306	IA505-A	81.33	95	Approved	78	79	87
MAT01358	ALU0227	IA502-B	84.00	85	Approved	80	76	96
MAT01413	ALU0236	IA603-B	23.00	41	Failed	22	22	25
MAT01571	ALU0262	IA405-B	33.67	87	Failed	11	55	35
MAT01895	ALU0316	IA805-B	31.33	68	Failed	26	37	31
MAT04939	ALU0824	IA301-B	46.33	46	Failed	57	26	56
MAT00597	ALU0100	IA403-B	34.67	37	Failed	51	7	46
MAT01385	ALU0231	IA505-B	41.67	50	Failed	28	57	40
MAT05817	ALU0970	IA503-B	23.67	52	Failed	47	19	5
MAT05658	ALU0943	IA506-A	34.00	67	Failed	36	16	50
MAT01836	ALU0306	IA506-A	27.67	64	Failed	28	40	15
MAT05013	ALU0836	IA603-B	19.67	83	Failed	23	0	36
MAT01818	ALU0303	IA506-B	37.00	58	Failed	7	55	49
MAT01841	ALU0307	IA405-A	26.33	37	Failed	10	33	36
MAT01384	ALU0231	IA504-B	32.33	89	Failed	49	24	24
MAT01838	ALU0307	IA402-A	24.00	93	Failed	9	4	59
MAT03360	ALU0560	IA606-B	46.33	32	Failed	59	55	25
MAT00987	ALU0165	IA503-B	41.00	92	Failed	21	55	47
MAT01708	ALU0285	IA504-A	44.00	70	Failed	40	33	59
MAT01817	ALU0303	IA505-B	21.33	33	Failed	48	1	15
MAT01816	ALU0303	IA504-B	22.33	38	Failed	12	18	37
MAT01392	ALU0232	IA406-B	31.00	43	Failed	17	46	30
MAT01857	ALU0310	IA503-B	44.33	39	Failed	33	55	45
MAT01858	ALU0310	IA504-B	33.00	91	Failed	29	47	23
MAT01753	ALU0293	IA801-B	19.33	53	Failed	11	11	36
MAT01380	ALU0230	IA806-B	6.33	79	Failed	6	1	12
MAT01314	ALU0219	IA106-A	30.67	80	Failed	22	47	23
MAT00754	ALU0126	IA704-B	38.00	88	Failed	12	45	57
MAT01415	ALU0236	IA605-B	29.67	78	Failed	27	24	38
MAT01747	ALU0292	IA701-A	39.33	74	Failed	27	38	53
MAT04402	ALU0734	IA204-B	33.00	52	Failed	18	46	35
MAT01885	ALU0315	IA201-A	40.33	58	Failed	41	55	25
MAT01328	ALU0222	IA702-B	31.33	98	Failed	2	40	52
MAT01378	ALU0230	IA804-B	32.67	50	Failed	11	52	35
MAT05069	ALU0845	IA505-B	31.67	54	Failed	42	40	13
MAT02070	ALU0345	IA706-A	87.00	75	Approved	100	62	99
MAT02631	ALU0439	IA803-B	72.33	96	Approved	66	82	69
MAT02573	ALU0429	IA405-A	83.33	78	Approved	87	69	94
MAT02376	ALU0396	IA506-B	19.33	97	Failed	21	13	24
MAT02209	ALU0369	IA301-B	40.00	97	Failed	43	39	38
MAT02026	ALU0338	IA104-B	26.00	100	Failed	12	52	14
MAT02280	ALU0380	IA106-B	15.00	52	Failed	7	28	10
MAT02373	ALU0396	IA503-B	36.00	86	Failed	44	7	57
MAT02714	ALU0453	IA802-A	11.33	48	Failed	8	7	19
MAT02583	ALU0431	IA203-A	23.00	72	Failed	9	7	53
MAT02069	ALU0345	IA705-A	33.00	71	Failed	54	4	41
MAT02440	ALU0407	IA404-B	38.67	79	Failed	44	51	21
MAT02629	ALU0439	IA801-B	45.67	37	Failed	51	27	59
MAT02457	ALU0410	IA803-A	20.33	73	Failed	17	30	14
MAT02135	ALU0356	IA805-B	50.67	58	Failed	55	43	54
MAT02690	ALU0449	IA802-A	34.00	47	Failed	20	26	56
MAT02438	ALU0407	IA402-B	28.33	73	Failed	22	17	46
MAT02048	ALU0342	IA202-A	46.00	56	Failed	33	49	56
MAT02106	ALU0351	IA506-B	46.33	30	Failed	52	36	51
MAT02214	ALU0369	IA306-B	22.00	36	Failed	6	37	23
MAT02102	ALU0351	IA502-B	37.33	38	Failed	46	49	17
MAT02360	ALU0394	IA402-B	49.00	42	Failed	45	59	43
MAT02286	ALU0381	IA706-B	35.67	33	Failed	18	32	57
MAT02065	ALU0345	IA701-A	44.67	91	Failed	53	46	35
MAT02051	ALU0342	IA205-A	50.00	59	Failed	52	40	58
MAT02713	ALU0453	IA801-A	43.67	67	Failed	57	28	46
MAT02067	ALU0345	IA703-A	23.67	72	Failed	23	38	10
MAT02417	ALU0403	IA105-B	20.67	74	Failed	3	24	35
MAT01432	ALU0239	IA104-B	35.00	47	Failed	29	41	35
MAT02696	ALU0450	IA502-A	45.67	45	Failed	58	36	43
MAT02299	ALU0384	IA201-B	41.33	58	Failed	53	55	16
MAT02359	ALU0394	IA401-B	39.00	71	Failed	53	33	31
MAT02661	ALU0444	IA803-B	40.33	73	Failed	45	48	28
MAT02662	ALU0444	IA804-B	35.33	68	Failed	52	20	34
MAT02571	ALU0429	IA403-A	17.33	74	Failed	6	10	36
MAT02250	ALU0375	IA606-A	33.00	73	Failed	42	12	45
MAT00050	ALU0009	IA202-A	32.67	82	Failed	30	11	57
MAT02098	ALU0350	IA804-B	32.00	34	Failed	42	42	12
MAT02276	ALU0380	IA102-B	23.33	75	Failed	23	17	30
MAT02089	ALU0349	IA801-B	24.67	61	Failed	56	3	15
MAT05085	ALU0848	IA103-A	30.33	85	Failed	25	17	49
MAT02090	ALU0349	IA802-B	28.33	45	Failed	7	39	39
MAT02163	ALU0361	IA203-B	27.67	78	Failed	33	47	3
MAT02730	ALU0455	IA806-B	71.33	93	Approved	63	77	74
MAT00333	ALU0056	IA103-B	80.33	78	Approved	83	79	79
MAT03450	ALU0575	IA406-A	87.00	89	Approved	90	71	100
MAT03874	ALU0646	IA504-B	77.00	100	Approved	82	79	70
MAT02719	ALU0454	IA601-B	36.00	38	Failed	54	23	31
MAT01121	ALU0187	IA105-B	26.67	50	Failed	44	0	36
MAT00019	ALU0004	IA701-A	23.00	44	Failed	21	44	4
MAT02843	ALU0474	IA205-B	36.67	37	Failed	50	20	40
MAT03455	ALU0576	IA505-A	30.00	49	Failed	49	26	15
MAT02650	ALU0442	IA304-B	35.00	34	Failed	57	14	34
MAT04912	ALU0819	IA204-B	12.67	47	Failed	30	5	3
MAT00012	ALU0002	IA106-B	48.33	41	Failed	59	42	44
MAT00074	ALU0013	IA702-A	29.33	99	Failed	5	58	25
MAT00023	ALU0004	IA705-A	25.67	43	Failed	24	12	41
MAT05996	ALU1000	IA102-A	31.00	89	Failed	25	48	20
MAT01822	ALU0304	IA804-B	45.67	93	Failed	33	45	59
MAT04958	ALU0827	IA202-B	31.33	86	Failed	25	45	24
MAT01990	ALU0332	IA704-B	17.67	76	Failed	11	2	40
MAT03459	ALU0577	IA803-A	32.33	44	Failed	34	40	23
MAT00171	ALU0029	IA803-A	14.67	55	Failed	18	26	0
MAT00027	ALU0005	IA403-B	35.00	71	Failed	30	30	45
MAT00011	ALU0002	IA105-B	25.00	72	Failed	3	37	35
MAT00026	ALU0005	IA402-B	35.67	91	Failed	57	35	15
MAT00077	ALU0013	IA705-A	29.67	34	Failed	18	31	40
MAT03175	ALU0530	IA801-B	27.33	73	Failed	53	5	24
MAT02720	ALU0454	IA602-B	17.00	74	Failed	42	2	7
MAT04984	ALU0831	IA504-B	24.00	77	Failed	24	44	4
MAT00009	ALU0002	IA103-B	20.33	98	Failed	20	7	34
MAT00008	ALU0002	IA102-B	23.00	30	Failed	48	17	4
MAT00174	ALU0029	IA806-A	25.00	67	Failed	56	4	15
MAT01761	ALU0294	IA503-A	38.33	83	Failed	48	22	45
MAT00018	ALU0003	IA306-B	48.00	49	Failed	48	50	46
MAT02739	ALU0457	IA703-A	19.00	64	Failed	44	7	6
MAT02856	ALU0476	IA406-B	73.00	98	Approved	76	68	75
MAT00110	ALU0019	IA102-B	69.67	79	Approved	60	64	85
MAT00070	ALU0012	IA504-B	84.33	79	Approved	98	60	95
MAT03659	ALU0610	IA305-B	69.00	91	Approved	75	67	65
MAT00059	ALU0010	IA705-A	69.00	78	Approved	62	65	80
MAT00069	ALU0012	IA503-B	31.33	39	Failed	54	26	14
MAT00058	ALU0010	IA704-A	31.00	44	Failed	51	13	29
MAT03673	ALU0613	IA101-B	26.00	47	Failed	38	35	5
MAT00056	ALU0010	IA702-A	21.67	87	Failed	19	35	11
MAT00114	ALU0019	IA106-B	38.00	32	Failed	53	44	17
MAT00112	ALU0019	IA104-B	31.00	59	Failed	50	4	39
MAT05711	ALU0952	IA205-B	39.67	41	Failed	53	45	21
MAT04281	ALU0714	IA803-B	14.33	99	Failed	0	3	40
MAT00087	ALU0015	IA203-B	46.33	40	Failed	46	50	43
MAT05836	ALU0973	IA404-A	42.67	82	Failed	24	56	48
MAT00420	ALU0070	IA106-B	32.67	68	Failed	57	3	38
MAT00060	ALU0010	IA706-A	20.67	81	Failed	17	13	32
MAT03658	ALU0610	IA304-B	40.00	30	Failed	49	39	32
MAT03676	ALU0613	IA104-B	31.67	73	Failed	25	15	55
MAT00067	ALU0012	IA501-B	24.33	97	Failed	31	28	14
MAT00083	ALU0014	IA305-B	23.00	70	Failed	28	31	10
MAT00068	ALU0012	IA502-B	25.33	97	Failed	6	18	52
MAT00072	ALU0012	IA506-B	29.67	38	Failed	16	14	59
MAT00080	ALU0014	IA302-B	44.00	81	Failed	59	41	32
MAT03657	ALU0610	IA303-B	15.67	41	Failed	0	25	22
MAT00084	ALU0014	IA306-B	37.00	65	Failed	56	34	21
MAT02961	ALU0494	IA503-A	17.00	64	Failed	14	22	15
MAT00065	ALU0011	IA105-A	23.00	72	Failed	0	28	41
MAT03678	ALU0613	IA106-B	15.00	38	Failed	15	26	4
MAT03247	ALU0542	IA401-B	19.67	97	Failed	22	25	12
MAT04342	ALU0724	IA404-B	20.33	30	Failed	46	12	3
MAT00061	ALU0011	IA101-A	25.67	97	Failed	1	20	56
MAT00107	ALU0018	IA605-B	36.33	91	Failed	57	4	48
MAT00079	ALU0014	IA301-B	4.33	52	Failed	10	2	1
MAT04035	ALU0673	IA403-B	30.67	98	Failed	39	49	4
MAT03656	ALU0610	IA302-B	14.00	71	Failed	14	19	9
MAT00054	ALU0009	IA206-A	40.00	52	Failed	30	38	52
MAT00052	ALU0009	IA204-A	41.33	97	Failed	46	53	25
MAT00113	ALU0019	IA105-B	36.00	84	Failed	46	58	4
MAT00254	ALU0043	IA302-A	80.00	75	Approved	72	93	75
MAT00164	ALU0028	IA302-B	82.33	97	Approved	78	73	96
MAT00150	ALU0025	IA706-B	84.33	81	Approved	83	87	83
MAT00186	ALU0031	IA606-B	39.33	31	Failed	37	58	23
MAT00202	ALU0034	IA404-A	31.00	100	Failed	39	53	1
MAT00249	ALU0042	IA503-B	40.00	58	Failed	28	43	49
MAT00223	ALU0038	IA701-B	11.00	47	Failed	28	5	0
MAT00256	ALU0043	IA304-A	24.67	32	Failed	55	18	1
MAT00199	ALU0034	IA401-A	29.67	52	Failed	36	43	10
MAT00252	ALU0042	IA506-B	19.00	58	Failed	3	0	54
MAT00250	ALU0042	IA504-B	26.67	88	Failed	2	45	33
MAT00176	ALU0030	IA702-B	24.33	55	Failed	50	8	15
MAT00188	ALU0032	IA102-A	30.00	58	Failed	23	15	52
MAT00201	ALU0034	IA403-A	27.00	79	Failed	52	14	15
MAT00232	ALU0039	IA204-B	34.67	98	Failed	53	29	22
MAT00165	ALU0028	IA303-B	47.67	83	Failed	36	57	50
MAT00191	ALU0032	IA105-A	27.00	36	Failed	4	21	56
MAT03753	ALU0626	IA703-B	24.33	53	Failed	19	48	6
MAT00251	ALU0042	IA505-B	19.00	34	Failed	11	21	25
MAT00200	ALU0034	IA402-A	45.33	66	Failed	44	53	39
MAT00248	ALU0042	IA502-B	27.00	79	Failed	4	25	52
MAT00175	ALU0030	IA701-B	34.00	96	Failed	21	31	50
MAT05123	ALU0854	IA805-B	21.00	42	Failed	27	29	7
MAT00240	ALU0040	IA306-A	23.00	55	Failed	24	39	6
MAT00178	ALU0030	IA704-B	31.33	69	Failed	35	44	15
MAT00203	ALU0034	IA405-A	32.67	31	Failed	36	34	28
MAT00237	ALU0040	IA303-A	24.00	79	Failed	34	8	30
MAT00159	ALU0027	IA203-B	30.00	44	Failed	42	11	37
MAT01723	ALU0288	IA201-B	24.33	98	Failed	43	5	25
MAT00189	ALU0032	IA103-A	20.67	92	Failed	41	7	14
MAT01290	ALU0215	IA606-B	40.67	68	Failed	41	26	55
MAT00229	ALU0039	IA201-B	40.33	49	Failed	56	6	59
MAT03754	ALU0626	IA704-B	15.00	88	Failed	31	7	7
MAT00193	ALU0033	IA201-B	36.33	91	Failed	33	21	55
MAT00253	ALU0043	IA301-A	36.67	80	Failed	46	22	42
MAT01318	ALU0220	IA604-B	54.33	40	Failed	53	59	51
MAT00213	ALU0036	IA203-A	47.67	34	Failed	42	59	42
MAT00192	ALU0032	IA106-A	39.00	80	Failed	22	48	47
MAT00190	ALU0032	IA104-A	39.33	97	Failed	43	41	34
MAT00172	ALU0029	IA804-A	24.67	96	Failed	5	50	19
MAT00255	ALU0043	IA303-A	18.33	82	Failed	19	27	9
MAT00187	ALU0032	IA101-A	36.67	87	Failed	58	34	18
MAT00357	ALU0060	IA103-A	84.67	75	Approved	99	75	80
MAT00342	ALU0057	IA306-A	89.67	81	Approved	92	79	98
MAT00626	ALU0105	IA802-B	81.67	89	Approved	60	92	93
MAT00266	ALU0045	IA102-B	85.33	95	Approved	76	83	97
MAT00337	ALU0057	IA301-A	91.00	97	Approved	86	88	99
MAT00330	ALU0055	IA206-A	42.33	82	Failed	56	57	14
MAT00311	ALU0052	IA705-A	32.67	83	Failed	19	55	24
MAT00297	ALU0050	IA303-B	37.67	57	Failed	5	57	51
MAT03825	ALU0638	IA403-B	28.33	36	Failed	3	54	28
MAT05235	ALU0873	IA303-B	39.00	73	Failed	37	33	47
MAT00317	ALU0053	IA805-A	32.33	59	Failed	57	18	22
MAT00281	ALU0047	IA405-A	29.67	30	Failed	45	11	33
MAT00310	ALU0052	IA704-A	50.67	61	Failed	43	54	55
MAT00264	ALU0044	IA306-A	21.67	58	Failed	28	32	5
MAT00340	ALU0057	IA304-A	27.33	40	Failed	35	38	9
MAT05477	ALU0913	IA205-B	32.33	36	Failed	34	4	59
MAT01521	ALU0254	IA603-A	35.67	76	Failed	51	8	48
MAT00282	ALU0047	IA406-A	30.33	71	Failed	41	26	24
MAT00278	ALU0047	IA402-A	29.33	48	Failed	27	16	45
MAT00277	ALU0047	IA401-A	24.67	66	Failed	40	23	11
MAT00341	ALU0057	IA305-A	24.00	61	Failed	4	12	56
MAT00329	ALU0055	IA205-A	25.33	67	Failed	27	27	22
MAT00345	ALU0058	IA103-B	38.00	34	Failed	59	8	47
MAT03826	ALU0638	IA404-B	41.00	69	Failed	23	48	52
MAT00338	ALU0057	IA302-A	29.33	82	Failed	42	24	22
MAT00346	ALU0058	IA104-B	48.33	98	Failed	52	36	57
MAT00279	ALU0047	IA403-A	33.67	41	Failed	29	52	20
MAT05575	ALU0930	IA101-A	28.00	53	Failed	28	25	31
MAT00272	ALU0046	IA502-B	48.00	44	Failed	41	48	55
MAT00322	ALU0054	IA404-A	39.00	99	Failed	40	24	53
MAT00267	ALU0045	IA103-B	11.33	69	Failed	20	6	8
MAT00356	ALU0060	IA102-A	18.00	66	Failed	11	25	18
MAT00307	ALU0052	IA701-A	30.67	30	Failed	20	39	33
MAT00328	ALU0055	IA204-A	38.33	63	Failed	58	16	41
MAT03824	ALU0638	IA402-B	31.00	52	Failed	25	49	19
MAT00320	ALU0054	IA402-A	16.33	57	Failed	13	32	4
MAT00339	ALU0057	IA303-A	23.33	73	Failed	20	18	32
MAT05268	ALU0878	IA806-B	20.67	93	Failed	32	11	19
MAT04333	ALU0723	IA201-A	21.67	81	Failed	14	35	16
MAT02781	ALU0464	IA303-B	44.67	90	Failed	53	41	40
MAT04029	ALU0672	IA803-B	73.33	92	Approved	70	60	90
MAT00374	ALU0063	IA802-B	80.67	90	Approved	73	76	93
MAT00382	ALU0064	IA504-B	68.00	95	Approved	71	72	61
MAT00446	ALU0075	IA502-B	79.33	81	Approved	71	96	71
MAT03722	ALU0621	IA402-B	74.00	84	Approved	72	82	68
MAT04054	ALU0676	IA104-B	75.67	87	Approved	72	65	90
MAT00859	ALU0144	IA601-B	95.33	95	Approved	95	97	94
MAT00373	ALU0063	IA801-B	77.00	85	Approved	96	67	68
MAT03354	ALU0559	IA406-A	40.67	75	Failed	20	45	57
MAT00380	ALU0064	IA502-B	39.67	37	Failed	27	52	40
MAT00384	ALU0064	IA506-B	29.33	58	Failed	56	17	15
MAT03901	ALU0651	IA201-B	39.33	72	Failed	40	53	25
MAT02484	ALU0414	IA506-A	25.67	93	Failed	13	34	30
MAT04052	ALU0676	IA102-B	27.00	80	Failed	9	28	44
MAT04026	ALU0671	IA806-A	37.00	90	Failed	40	35	36
MAT00358	ALU0060	IA104-A	5.00	79	Failed	6	8	1
MAT04060	ALU0677	IA104-B	9.67	78	Failed	16	9	4
MAT00378	ALU0063	IA806-B	39.33	71	Failed	45	20	53
MAT04754	ALU0793	IA802-B	21.33	62	Failed	41	18	5
MAT00372	ALU0062	IA206-A	40.67	74	Failed	40	55	27
MAT03914	ALU0653	IA602-B	42.33	74	Failed	54	41	32
MAT00641	ALU0107	IA305-B	40.00	94	Failed	46	22	52
MAT04031	ALU0672	IA805-B	28.67	96	Failed	54	5	27
MAT00449	ALU0075	IA505-B	40.00	95	Failed	33	34	53
MAT00454	ALU0076	IA804-B	29.67	86	Failed	59	4	26
MAT00376	ALU0063	IA804-B	36.00	73	Failed	19	50	39
MAT04651	ALU0776	IA401-B	29.67	92	Failed	16	43	30
MAT04727	ALU0788	IA105-A	26.67	90	Failed	34	46	0
MAT03908	ALU0652	IA502-B	8.67	100	Failed	10	15	1
MAT00318	ALU0053	IA806-A	29.33	43	Failed	51	22	15
MAT03185	ALU0531	IA305-B	20.67	97	Failed	47	8	7
MAT02076	ALU0346	IA706-B	78.33	99	Approved	80	93	62
MAT05578	ALU0930	IA104-A	78.00	91	Approved	68	93	73
MAT02145	ALU0358	IA703-A	78.00	94	Approved	67	75	92
MAT02671	ALU0446	IA201-B	78.33	94	Approved	93	67	75
MAT00616	ALU0103	IA804-B	73.33	89	Approved	62	74	84
MAT00588	ALU0098	IA206-A	84.33	95	Approved	79	89	85
MAT00590	ALU0099	IA402-B	82.33	90	Approved	81	100	66
MAT00619	ALU0104	IA701-B	40.00	52	Failed	43	56	21
MAT04153	ALU0693	IA201-B	13.67	76	Failed	29	10	2
MAT00580	ALU0097	IA604-A	41.33	38	Failed	45	58	21
MAT04117	ALU0687	IA201-A	25.33	95	Failed	17	39	20
MAT01018	ALU0170	IA404-B	51.67	75	Failed	55	51	49
MAT00617	ALU0103	IA805-B	10.67	81	Failed	0	3	29
MAT03762	ALU0627	IA106-B	7.67	95	Failed	2	14	7
MAT04124	ALU0688	IA302-B	20.67	70	Failed	17	17	28
MAT00137	ALU0023	IA605-A	23.67	67	Failed	5	41	25
MAT03304	ALU0551	IA404-B	28.00	95	Failed	25	18	41
MAT00558	ALU0093	IA406-A	26.00	36	Failed	20	58	0
MAT04152	ALU0692	IA206-B	24.33	52	Failed	14	38	21
MAT05863	ALU0978	IA701-A	14.33	50	Failed	30	5	8
MAT02179	ALU0364	IA101-A	40.67	36	Failed	44	49	29
MAT00227	ALU0038	IA705-B	15.67	91	Failed	14	8	25
MAT00615	ALU0103	IA803-B	34.00	87	Failed	43	37	22
MAT01052	ALU0176	IA202-B	47.67	74	Failed	41	53	49
MAT00585	ALU0098	IA203-A	33.00	87	Failed	43	26	30
MAT00546	ALU0091	IA606-B	45.33	61	Failed	58	24	54
MAT05415	ALU0903	IA303-B	23.67	43	Failed	12	2	57
MAT00583	ALU0098	IA201-A	19.00	99	Failed	20	0	37
MAT05606	ALU0935	IA502-A	14.67	99	Failed	30	2	12
MAT01788	ALU0298	IA806-B	84.33	82	Approved	69	86	98
MAT00750	ALU0125	IA306-B	88.67	83	Approved	94	98	74
MAT00778	ALU0130	IA704-A	73.67	84	Approved	69	69	83
MAT04363	ALU0728	IA401-B	42.00	77	Failed	42	26	58
MAT00718	ALU0120	IA804-B	49.00	55	Failed	50	59	38
MAT00818	ALU0137	IA202-A	44.67	94	Failed	53	41	40
MAT04423	ALU0738	IA801-B	23.67	100	Failed	33	13	25
MAT00738	ALU0123	IA106-B	28.00	82	Failed	40	35	9
MAT02028	ALU0338	IA106-B	28.67	43	Failed	38	43	5
MAT03839	ALU0640	IA105-B	35.33	38	Failed	39	12	55
MAT01343	ALU0224	IA705-B	37.33	78	Failed	4	49	59
MAT00749	ALU0125	IA305-B	27.33	97	Failed	49	4	29
MAT03497	ALU0583	IA105-A	33.00	59	Failed	32	43	24
MAT00809	ALU0135	IA305-B	40.33	40	Failed	52	43	26
MAT00668	ALU0112	IA402-B	19.33	46	Failed	7	23	28
MAT00764	ALU0128	IA302-A	17.33	52	Failed	35	2	15
MAT00777	ALU0130	IA703-A	18.33	62	Failed	30	22	3
MAT00737	ALU0123	IA105-B	16.67	83	Failed	6	4	40
MAT00757	ALU0127	IA801-B	39.00	45	Failed	53	49	15
MAT00780	ALU0130	IA706-A	12.00	94	Failed	5	7	24
MAT00765	ALU0128	IA303-A	32.00	95	Failed	44	31	21
MAT00735	ALU0123	IA103-B	37.00	66	Failed	46	11	54
MAT00805	ALU0135	IA301-B	38.67	47	Failed	39	21	56
MAT00775	ALU0130	IA701-A	18.67	76	Failed	15	37	4
MAT00760	ALU0127	IA804-B	15.00	75	Failed	2	17	26
MAT00731	ALU0122	IA505-B	20.33	46	Failed	12	39	10
MAT00817	ALU0137	IA201-A	34.33	82	Failed	39	9	55
MAT04329	ALU0722	IA803-B	33.00	33	Failed	54	30	15
MAT00736	ALU0123	IA104-B	29.67	33	Failed	10	28	51
MAT04322	ALU0721	IA202-A	42.67	42	Failed	35	56	37
MAT00783	ALU0131	IA803-A	50.67	91	Failed	55	52	45
MAT04324	ALU0721	IA204-A	29.00	80	Failed	50	34	3
MAT00797	ALU0133	IA705-B	40.33	40	Failed	53	14	54
MAT00429	ALU0072	IA403-B	30.67	75	Failed	40	2	50
MAT05676	ALU0946	IA106-B	14.00	99	Failed	5	22	15
MAT04330	ALU0722	IA804-B	27.67	38	Failed	35	9	39
MAT00769	ALU0129	IA601-B	24.67	81	Failed	31	22	21
MAT00720	ALU0120	IA806-B	21.33	66	Failed	14	16	34
MAT04327	ALU0722	IA801-B	21.67	38	Failed	8	34	23
MAT03818	ALU0637	IA602-B	35.33	63	Failed	32	35	39
MAT00867	ALU0145	IA703-B	72.00	100	Approved	65	68	83
MAT00884	ALU0148	IA202-A	88.00	82	Approved	90	87	87
MAT00901	ALU0151	IA701-B	86.67	93	Approved	68	96	96
MAT04393	ALU0733	IA601-B	26.33	92	Failed	34	18	27
MAT00860	ALU0144	IA602-B	24.00	66	Failed	25	27	20
MAT00903	ALU0151	IA703-B	19.67	79	Failed	2	13	44
MAT00902	ALU0151	IA702-B	29.67	82	Failed	45	26	18
MAT00864	ALU0144	IA606-B	33.33	34	Failed	54	46	0
MAT00897	ALU0150	IA603-B	25.33	81	Failed	9	48	19
MAT00904	ALU0151	IA704-B	32.33	64	Failed	48	39	10
MAT00865	ALU0145	IA701-B	30.00	82	Failed	21	11	58
MAT00906	ALU0151	IA706-B	39.33	74	Failed	37	54	27
MAT00911	ALU0152	IA405-A	28.67	58	Failed	0	42	44
MAT04394	ALU0733	IA602-B	29.33	50	Failed	17	32	39
MAT04388	ALU0732	IA302-A	26.67	52	Failed	19	40	21
MAT00872	ALU0146	IA202-B	22.67	44	Failed	19	26	23
MAT03787	ALU0632	IA801-B	27.67	82	Failed	32	38	13
MAT00868	ALU0145	IA704-B	32.67	42	Failed	23	56	19
MAT01118	ALU0187	IA102-B	32.67	47	Failed	23	39	36
MAT04391	ALU0732	IA305-A	29.33	99	Failed	22	13	53
MAT00888	ALU0148	IA206-A	31.33	71	Failed	13	51	30
MAT00874	ALU0146	IA204-B	16.67	69	Failed	31	12	7
MAT00914	ALU0153	IA202-B	26.67	33	Failed	36	27	17
MAT00885	ALU0148	IA203-A	42.33	92	Failed	44	47	36
MAT00905	ALU0151	IA705-B	39.00	36	Failed	25	35	57
MAT00912	ALU0152	IA406-A	35.67	81	Failed	13	41	53
MAT04397	ALU0733	IA605-B	35.00	95	Failed	56	5	44
MAT04390	ALU0732	IA304-A	33.33	71	Failed	30	46	24
MAT00910	ALU0152	IA404-A	20.00	77	Failed	6	46	8
MAT04389	ALU0732	IA303-A	29.67	64	Failed	14	56	19
MAT00908	ALU0152	IA402-A	18.33	62	Failed	53	0	2
MAT00887	ALU0148	IA205-A	17.00	57	Failed	8	25	18
MAT00900	ALU0150	IA606-B	30.67	86	Failed	16	27	49
MAT00866	ALU0145	IA702-B	29.33	85	Failed	58	18	12
MAT04398	ALU0733	IA606-B	28.33	61	Failed	18	44	23
MAT00875	ALU0146	IA205-B	26.67	57	Failed	6	42	32
MAT04396	ALU0733	IA604-B	35.00	30	Failed	45	31	29
MAT04460	ALU0744	IA302-B	11.67	82	Failed	11	0	24
MAT04395	ALU0733	IA603-B	13.33	37	Failed	9	27	4
MAT00915	ALU0153	IA203-B	30.33	41	Failed	41	29	21
MAT00898	ALU0150	IA604-B	20.67	47	Failed	7	20	35
MAT00896	ALU0150	IA602-B	20.67	48	Failed	9	27	26
MAT00895	ALU0150	IA601-B	35.00	37	Failed	14	48	43
MAT04826	ALU0805	IA802-A	81.00	78	Approved	95	78	70
MAT02027	ALU0338	IA105-B	91.00	89	Approved	100	77	96
MAT01952	ALU0326	IA702-A	82.33	86	Approved	96	69	82
MAT03871	ALU0646	IA501-B	86.33	86	Approved	97	97	65
MAT04553	ALU0759	IA105-B	72.00	100	Approved	66	73	77
MAT01030	ALU0172	IA504-B	79.33	79	Approved	71	99	68
MAT01027	ALU0172	IA501-B	69.67	84	Approved	72	75	62
MAT04552	ALU0759	IA104-B	73.33	91	Approved	62	84	74
MAT00010	ALU0002	IA104-B	75.33	91	Approved	78	87	61
MAT05172	ALU0862	IA506-B	34.67	78	Failed	44	51	9
MAT00935	ALU0156	IA605-A	24.33	46	Failed	34	29	10
MAT00925	ALU0155	IA101-A	27.67	32	Failed	24	55	4
MAT04550	ALU0759	IA102-B	25.33	96	Failed	19	45	12
MAT04542	ALU0757	IA206-A	13.33	93	Failed	1	23	16
MAT00979	ALU0164	IA501-A	47.00	80	Failed	48	52	41
MAT04540	ALU0757	IA204-A	23.67	45	Failed	24	39	8
MAT04461	ALU0744	IA303-B	31.67	80	Failed	15	39	41
MAT01891	ALU0316	IA801-B	28.00	46	Failed	18	35	31
MAT00932	ALU0156	IA602-A	19.33	86	Failed	15	0	43
MAT01004	ALU0168	IA402-A	27.00	81	Failed	46	27	8
MAT00927	ALU0155	IA103-A	6.00	73	Failed	12	3	3
MAT01022	ALU0171	IA102-A	43.00	64	Failed	57	36	36
MAT00982	ALU0164	IA504-A	28.33	63	Failed	0	54	31
MAT04539	ALU0757	IA203-A	21.33	57	Failed	33	20	11
MAT00918	ALU0153	IA206-B	19.67	55	Failed	7	31	21
MAT00977	ALU0163	IA605-B	46.33	42	Failed	34	47	58
MAT01003	ALU0168	IA401-A	18.67	99	Failed	12	2	42
MAT02685	ALU0448	IA503-A	13.00	77	Failed	28	4	7
MAT02914	ALU0486	IA404-A	41.67	99	Failed	51	53	21
MAT05346	ALU0891	IA306-B	29.33	48	Failed	19	47	22
MAT01595	ALU0266	IA805-A	29.00	36	Failed	52	34	1
MAT01043	ALU0174	IA705-B	7.33	91	Failed	6	2	14
MAT01025	ALU0171	IA105-A	21.33	91	Failed	22	20	22
MAT00917	ALU0153	IA205-B	44.00	62	Failed	51	26	55
MAT04499	ALU0750	IA605-B	31.67	77	Failed	0	44	51
MAT03176	ALU0530	IA802-B	37.00	76	Failed	24	53	34
MAT01041	ALU0174	IA703-B	41.00	31	Failed	17	57	49
MAT01172	ALU0196	IA102-A	75.67	79	Approved	85	67	75
MAT01110	ALU0185	IA306-B	12.67	52	Failed	10	24	4
MAT05692	ALU0949	IA304-A	23.67	40	Failed	7	5	59
MAT04669	ALU0779	IA801-A	12.00	70	Failed	18	1	17
MAT01109	ALU0185	IA305-B	21.67	69	Failed	19	25	21
MAT01140	ALU0190	IA406-A	13.33	33	Failed	20	11	9
MAT01177	ALU0197	IA401-A	17.33	97	Failed	7	15	30
MAT01112	ALU0186	IA202-B	43.67	39	Failed	41	57	33
MAT04662	ALU0777	IA306-B	29.00	62	Failed	27	5	55
MAT01125	ALU0188	IA803-B	27.33	78	Failed	16	31	35
MAT01181	ALU0197	IA405-A	25.67	88	Failed	15	55	7
MAT01174	ALU0196	IA104-A	22.33	83	Failed	49	15	3
MAT04656	ALU0776	IA406-B	43.00	59	Failed	50	26	53
MAT01180	ALU0197	IA404-A	51.67	38	Failed	50	49	56
MAT01166	ALU0195	IA302-B	32.00	43	Failed	55	27	14
MAT02244	ALU0374	IA306-B	36.67	62	Failed	43	31	36
MAT04718	ALU0787	IA502-A	34.33	30	Failed	49	47	7
MAT04661	ALU0777	IA305-B	30.33	97	Failed	16	24	51
MAT04653	ALU0776	IA403-B	49.33	84	Failed	53	56	39
MAT01178	ALU0197	IA402-A	40.67	90	Failed	51	28	43
MAT01107	ALU0185	IA303-B	12.33	98	Failed	15	18	4
MAT00861	ALU0144	IA603-B	33.67	33	Failed	52	48	1
MAT01173	ALU0196	IA103-A	25.00	32	Failed	38	19	18
MAT01120	ALU0187	IA104-B	29.67	71	Failed	2	31	56
MAT04657	ALU0777	IA301-B	41.00	92	Failed	19	48	56
MAT01176	ALU0196	IA106-A	19.67	41	Failed	3	13	43
MAT01130	ALU0189	IA802-A	27.33	32	Failed	56	15	11
MAT04658	ALU0777	IA302-B	32.67	38	Failed	53	30	15
MAT01111	ALU0186	IA201-B	32.00	84	Failed	34	11	51
MAT01114	ALU0186	IA204-B	31.33	96	Failed	52	12	30
MAT01179	ALU0197	IA403-A	19.33	57	Failed	1	53	4
MAT01170	ALU0195	IA306-B	13.33	62	Failed	8	31	1
MAT01108	ALU0185	IA304-B	33.33	97	Failed	51	12	37
MAT04666	ALU0778	IA704-A	39.00	62	Failed	58	40	19
MAT01182	ALU0197	IA406-A	37.00	62	Failed	45	34	32
MAT01162	ALU0194	IA504-A	47.67	47	Failed	58	56	29
MAT01131	ALU0189	IA803-A	35.67	74	Failed	50	46	11
MAT01098	ALU0183	IA806-B	29.67	30	Failed	50	19	20
MAT01168	ALU0195	IA304-B	19.33	70	Failed	13	27	18
MAT01171	ALU0196	IA101-A	11.33	45	Failed	7	15	12
MAT01105	ALU0185	IA301-B	10.00	49	Failed	17	9	4
MAT04654	ALU0776	IA404-B	31.33	44	Failed	53	33	8
MAT01106	ALU0185	IA302-B	28.00	73	Failed	24	6	54
MAT05331	ALU0889	IA503-B	62.67	87	Approved	67	60	61
MAT01203	ALU0201	IA403-A	72.33	84	Approved	84	72	61
MAT04784	ALU0798	IA602-B	74.33	97	Approved	81	65	77
MAT01207	ALU0202	IA601-B	72.00	78	Approved	61	90	65
MAT01833	ALU0306	IA503-A	74.67	92	Approved	81	82	61
MAT01276	ALU0213	IA204-B	70.67	98	Approved	60	65	87
MAT01212	ALU0202	IA606-B	76.33	96	Approved	78	80	71
MAT01205	ALU0201	IA405-A	8.00	96	Failed	15	3	6
MAT04722	ALU0787	IA506-A	9.33	85	Failed	6	6	16
MAT01264	ALU0211	IA204-B	25.33	98	Failed	22	48	6
MAT01201	ALU0201	IA401-A	19.67	59	Failed	11	16	32
MAT00779	ALU0130	IA705-A	48.67	31	Failed	38	51	57
MAT05629	ALU0939	IA101-B	23.33	89	Failed	48	14	8
MAT02769	ALU0462	IA603-A	44.33	65	Failed	58	43	32
MAT01195	ALU0200	IA601-A	27.67	45	Failed	31	46	6
MAT01206	ALU0201	IA406-A	17.00	87	Failed	37	0	14
MAT04425	ALU0738	IA803-B	39.67	95	Failed	57	18	44
MAT00774	ALU0129	IA606-B	9.67	43	Failed	6	19	4
MAT01202	ALU0201	IA402-A	37.33	47	Failed	14	59	39
MAT00423	ALU0071	IA403-B	41.67	58	Failed	35	31	59
MAT03667	ALU0612	IA301-B	17.00	52	Failed	6	13	32
MAT01494	ALU0249	IA206-A	29.33	76	Failed	25	13	50
MAT04301	ALU0717	IA105-B	29.00	87	Failed	11	50	26
MAT01210	ALU0202	IA604-B	28.67	68	Failed	26	35	25
MAT01249	ALU0209	IA301-B	43.33	50	Failed	47	42	41
MAT01265	ALU0211	IA205-B	36.33	75	Failed	19	48	42
MAT01246	ALU0208	IA104-A	12.67	94	Failed	23	1	14
MAT01006	ALU0168	IA404-A	43.67	95	Failed	37	41	53
MAT02367	ALU0395	IA303-B	24.67	50	Failed	17	27	30
MAT01584	ALU0264	IA106-B	33.67	36	Failed	42	54	5
MAT03234	ALU0539	IA706-B	30.67	64	Failed	36	41	15
MAT01348	ALU0225	IA304-A	81.67	96	Approved	88	71	86
MAT04883	ALU0814	IA205-B	75.33	99	Approved	76	60	90
MAT04884	ALU0814	IA206-B	89.67	91	Approved	95	80	94
MAT01349	ALU0225	IA305-A	81.00	86	Approved	83	97	63
MAT01351	ALU0226	IA301-A	90.67	86	Approved	86	89	97
MAT04017	ALU0670	IA203-A	87.33	91	Approved	99	70	93
MAT01396	ALU0233	IA404-B	77.33	77	Approved	73	89	70
MAT04894	ALU0816	IA304-B	37.33	72	Failed	33	45	34
MAT01398	ALU0233	IA406-B	36.67	95	Failed	48	31	31
MAT04891	ALU0816	IA301-B	48.67	55	Failed	50	45	51
MAT01347	ALU0225	IA303-A	33.00	34	Failed	27	42	30
MAT02926	ALU0488	IA404-B	39.33	46	Failed	31	46	41
MAT04896	ALU0816	IA306-B	50.67	56	Failed	50	51	51
MAT04887	ALU0815	IA203-A	36.33	74	Failed	47	4	58
MAT01393	ALU0233	IA401-B	41.33	75	Failed	36	33	55
MAT01406	ALU0235	IA602-A	44.67	51	Failed	57	36	41
MAT04802	ALU0801	IA402-B	30.67	96	Failed	33	45	14
MAT01324	ALU0221	IA804-B	26.33	65	Failed	23	48	8
MAT01408	ALU0235	IA604-A	7.33	59	Failed	13	6	3
MAT01388	ALU0232	IA402-B	41.00	92	Failed	57	9	57
MAT01407	ALU0235	IA603-A	25.00	87	Failed	57	5	13
MAT01147	ALU0192	IA401-B	38.67	59	Failed	58	58	0
MAT04885	ALU0815	IA201-A	16.67	48	Failed	5	40	5
MAT01387	ALU0232	IA401-B	42.33	88	Failed	42	31	54
MAT04895	ALU0816	IA305-B	28.33	84	Failed	40	17	28
MAT04408	ALU0735	IA404-A	34.00	34	Failed	24	36	42
MAT01353	ALU0226	IA303-A	33.00	31	Failed	58	14	27
MAT04892	ALU0816	IA302-B	33.00	88	Failed	28	28	43
MAT04812	ALU0802	IA806-B	26.00	60	Failed	55	9	14
MAT05484	ALU0914	IA606-A	17.67	57	Failed	23	0	30
MAT00204	ALU0034	IA406-A	10.00	98	Failed	11	12	7
MAT01410	ALU0235	IA606-A	28.67	100	Failed	23	34	29
MAT00156	ALU0026	IA406-A	22.67	63	Failed	49	13	6
MAT01403	ALU0234	IA205-A	51.67	93	Failed	50	47	58
MAT02152	ALU0359	IA404-B	26.67	64	Failed	46	24	10
MAT04893	ALU0816	IA303-B	25.33	89	Failed	38	6	32
MAT01411	ALU0236	IA601-B	33.33	74	Failed	8	40	52
MAT00170	ALU0029	IA802-A	32.00	41	Failed	42	47	7
MAT00759	ALU0127	IA803-B	84.33	85	Approved	81	79	93
MAT01533	ALU0256	IA503-A	82.33	93	Approved	84	79	84
MAT04191	ALU0699	IA803-B	94.33	88	Approved	97	97	89
MAT01476	ALU0246	IA806-A	84.33	81	Approved	84	89	80
MAT01442	ALU0241	IA202-B	30.00	80	Failed	27	32	31
MAT00934	ALU0156	IA604-A	32.00	77	Failed	2	54	40
MAT01449	ALU0242	IA403-A	8.33	93	Failed	1	19	5
MAT01536	ALU0256	IA506-A	24.00	33	Failed	27	5	40
MAT05033	ALU0839	IA205-B	32.67	53	Failed	43	14	41
MAT05138	ALU0857	IA402-A	26.67	98	Failed	57	8	15
MAT01446	ALU0241	IA206-B	29.00	66	Failed	1	28	58
MAT01036	ALU0173	IA304-A	25.33	86	Failed	29	14	33
MAT04947	ALU0825	IA503-B	25.67	88	Failed	55	15	7
MAT05623	ALU0938	IA301-B	46.00	61	Failed	58	41	39
MAT01452	ALU0242	IA406-A	21.67	99	Failed	31	10	24
MAT01443	ALU0241	IA203-B	27.67	100	Failed	23	22	38
MAT01534	ALU0256	IA504-A	25.00	45	Failed	0	46	29
MAT01529	ALU0255	IA505-A	23.67	84	Failed	29	29	13
MAT01487	ALU0248	IA405-B	28.67	53	Failed	26	4	56
MAT03633	ALU0606	IA303-B	24.00	92	Failed	1	31	40
MAT01486	ALU0248	IA404-B	43.67	30	Failed	48	42	41
MAT01456	ALU0243	IA304-A	25.00	87	Failed	48	17	10
MAT05314	ALU0886	IA704-B	23.00	95	Failed	14	34	21
MAT03488	ALU0582	IA202-B	19.00	46	Failed	13	20	24
MAT04952	ALU0826	IA602-B	36.67	86	Failed	15	58	37
MAT01444	ALU0241	IA204-B	35.67	90	Failed	29	42	36
MAT02219	ALU0370	IA605-B	36.33	49	Failed	45	59	5
MAT01490	ALU0249	IA202-A	38.33	39	Failed	21	43	51
MAT01491	ALU0249	IA203-A	49.67	34	Failed	56	49	44
MAT01451	ALU0242	IA405-A	19.00	38	Failed	14	11	32
MAT03645	ALU0608	IA503-B	21.67	82	Failed	2	38	25
MAT01530	ALU0255	IA506-A	24.67	33	Failed	36	26	12
MAT01483	ALU0248	IA401-B	17.00	87	Failed	41	5	5
MAT01531	ALU0256	IA501-A	34.67	51	Failed	14	50	40
MAT01615	ALU0270	IA801-B	86.00	91	Approved	70	90	98
MAT05236	ALU0873	IA304-B	78.00	86	Approved	82	87	65
MAT01628	ALU0272	IA402-B	76.00	83	Approved	76	89	63
MAT05038	ALU0840	IA604-B	21.67	98	Failed	18	9	38
MAT01659	ALU0277	IA103-A	43.67	38	Failed	36	58	37
MAT01692	ALU0282	IA806-B	24.00	59	Failed	12	50	10
MAT01655	ALU0276	IA605-B	36.00	94	Failed	31	39	38
MAT01642	ALU0274	IA204-A	20.67	55	Failed	6	27	29
MAT01616	ALU0270	IA802-B	15.67	40	Failed	40	0	7
MAT01608	ALU0268	IA206-B	32.00	73	Failed	49	16	31
MAT05039	ALU0840	IA605-B	32.67	60	Failed	50	43	5
MAT01645	ALU0275	IA201-B	37.00	53	Failed	55	30	26
MAT01632	ALU0272	IA406-B	35.00	33	Failed	36	12	57
MAT01658	ALU0277	IA102-A	12.67	66	Failed	27	9	2
MAT01627	ALU0272	IA401-B	20.00	48	Failed	8	26	26
MAT01578	ALU0263	IA806-B	40.00	99	Failed	10	51	59
MAT01649	ALU0275	IA205-B	40.67	85	Failed	57	16	49
MAT01631	ALU0272	IA405-B	30.00	54	Failed	47	41	2
MAT01618	ALU0270	IA804-B	24.67	30	Failed	1	33	40
MAT01619	ALU0270	IA805-B	24.00	90	Failed	21	4	47
MAT01639	ALU0274	IA201-A	33.33	84	Failed	5	37	58
MAT01648	ALU0275	IA204-B	37.00	43	Failed	55	27	29
MAT01617	ALU0270	IA803-B	25.33	76	Failed	42	23	11
MAT01657	ALU0277	IA101-A	30.00	88	Failed	42	34	14
MAT01629	ALU0272	IA403-B	43.00	40	Failed	51	35	43
MAT01643	ALU0274	IA205-A	26.67	61	Failed	22	54	4
MAT01650	ALU0275	IA206-B	7.67	85	Failed	12	3	8
MAT01646	ALU0275	IA202-B	34.67	70	Failed	40	16	48
MAT05901	ALU0984	IA503-B	23.67	70	Failed	11	50	10
MAT01644	ALU0274	IA206-A	15.00	92	Failed	18	10	17
MAT01697	ALU0283	IA705-A	41.33	34	Failed	20	45	59
MAT01695	ALU0283	IA703-A	41.67	31	Failed	56	23	46
MAT01630	ALU0272	IA404-B	30.00	74	Failed	10	57	23
MAT01620	ALU0270	IA806-B	6.67	62	Failed	0	9	11
MAT01647	ALU0275	IA203-B	25.33	85	Failed	15	8	53
MAT01663	ALU0278	IA501-B	20.00	64	Failed	33	24	3
MAT01607	ALU0268	IA205-B	19.33	97	Failed	39	14	5
MAT01693	ALU0283	IA701-A	36.33	49	Failed	33	57	19
MAT01662	ALU0277	IA106-A	23.33	87	Failed	56	5	9
MAT01664	ALU0278	IA502-B	26.33	71	Failed	42	18	19
MAT01694	ALU0283	IA702-A	21.33	92	Failed	16	14	34
MAT01696	ALU0283	IA704-A	39.00	89	Failed	25	33	59
MAT01698	ALU0283	IA706-A	42.00	38	Failed	13	54	59
MAT01722	ALU0287	IA506-A	82.67	90	Approved	82	98	68
MAT01712	ALU0286	IA202-A	66.33	100	Approved	65	72	62
MAT01740	ALU0290	IA406-B	87.00	94	Approved	91	84	86
MAT01703	ALU0284	IA605-A	86.33	93	Approved	69	93	97
MAT01725	ALU0288	IA203-B	24.67	97	Failed	32	7	35
MAT04450	ALU0742	IA104-A	5.00	34	Failed	5	8	2
MAT03184	ALU0531	IA304-B	35.33	68	Failed	6	54	46
MAT01752	ALU0292	IA706-A	25.00	77	Failed	46	29	0
MAT05656	ALU0943	IA504-A	27.33	51	Failed	23	28	31
MAT00964	ALU0161	IA204-B	31.00	58	Failed	30	51	12
MAT03515	ALU0586	IA205-B	35.00	33	Failed	9	38	58
MAT01751	ALU0292	IA705-A	35.67	30	Failed	31	32	44
MAT02911	ALU0486	IA401-A	22.00	32	Failed	25	11	30
MAT01684	ALU0281	IA104-B	30.33	44	Failed	41	50	0
MAT01733	ALU0289	IA405-B	27.67	84	Failed	27	47	9
MAT04675	ALU0780	IA501-A	28.33	73	Failed	27	51	7
MAT04276	ALU0713	IA304-A	38.33	51	Failed	46	46	23
MAT04818	ALU0803	IA806-B	30.00	40	Failed	36	49	5
MAT04236	ALU0706	IA706-B	20.67	64	Failed	14	29	19
MAT01719	ALU0287	IA503-A	20.67	48	Failed	8	44	10
MAT01726	ALU0288	IA204-B	41.00	43	Failed	34	49	40
MAT01930	ALU0322	IA504-B	42.67	98	Failed	45	51	32
MAT01737	ALU0290	IA403-B	32.33	34	Failed	51	37	9
MAT01762	ALU0294	IA504-A	29.00	65	Failed	42	41	4
MAT05376	ALU0896	IA606-B	45.33	68	Failed	40	48	48
MAT01894	ALU0316	IA804-B	87.33	90	Approved	88	84	90
MAT01911	ALU0319	IA303-B	23.67	73	Failed	19	29	23
MAT00693	ALU0116	IA703-A	25.00	52	Failed	20	18	37
MAT01897	ALU0317	IA801-A	27.67	92	Failed	0	49	34
MAT05408	ALU0902	IA402-B	39.00	61	Failed	4	55	58
MAT01938	ALU0323	IA406-A	17.67	81	Failed	33	17	3
MAT01949	ALU0325	IA605-B	19.00	36	Failed	11	32	14
MAT01982	ALU0331	IA402-A	19.33	64	Failed	3	0	55
MAT01945	ALU0325	IA601-B	18.33	88	Failed	24	26	5
MAT01995	ALU0333	IA103-A	12.00	91	Failed	13	0	23
MAT01971	ALU0329	IA103-B	27.33	63	Failed	10	49	23
MAT01901	ALU0317	IA805-A	23.67	46	Failed	15	22	34
MAT05412	ALU0902	IA406-B	15.67	88	Failed	42	4	1
MAT02005	ALU0335	IA501-B	47.67	43	Failed	49	36	58
MAT05535	ALU0923	IA503-A	24.33	47	Failed	20	18	35
MAT01893	ALU0316	IA803-B	29.67	94	Failed	8	25	56
MAT05407	ALU0902	IA401-B	8.67	61	Failed	17	3	6
MAT01921	ALU0321	IA201-B	34.33	30	Failed	58	34	11
MAT05410	ALU0902	IA404-B	16.00	60	Failed	21	12	15
MAT05321	ALU0887	IA605-B	11.67	62	Failed	0	15	20
MAT01970	ALU0329	IA102-B	29.67	34	Failed	51	37	1
MAT05425	ALU0905	IA201-B	23.00	43	Failed	6	27	36
MAT04563	ALU0761	IA703-A	28.00	64	Failed	42	38	4
MAT01914	ALU0319	IA306-B	34.33	69	Failed	47	3	53
MAT01896	ALU0316	IA806-B	24.67	90	Failed	31	15	28
MAT01898	ALU0317	IA802-A	43.00	78	Failed	26	54	49
MAT01906	ALU0318	IA404-A	40.00	93	Failed	20	50	50
MAT01892	ALU0316	IA802-B	24.67	42	Failed	21	12	41
MAT00418	ALU0070	IA104-B	30.33	76	Failed	28	13	50
MAT01984	ALU0331	IA404-A	27.00	71	Failed	42	21	18
MAT01936	ALU0323	IA404-A	47.00	90	Failed	57	25	59
MAT01939	ALU0324	IA601-B	12.00	36	Failed	34	1	1
MAT01962	ALU0327	IA106-A	26.67	88	Failed	44	33	3
MAT05531	ALU0922	IA505-B	19.33	90	Failed	41	1	16
MAT01943	ALU0324	IA605-B	35.33	73	Failed	33	38	35
MAT01994	ALU0333	IA102-A	48.33	91	Failed	36	54	55
MAT01958	ALU0327	IA102-A	41.00	99	Failed	32	42	49
MAT01902	ALU0317	IA806-A	28.67	82	Failed	22	57	7
MAT01969	ALU0329	IA101-B	28.00	71	Failed	2	50	32
MAT05534	ALU0923	IA502-A	40.00	49	Failed	59	52	9
MAT05421	ALU0904	IA503-B	39.67	83	Failed	16	55	48
MAT01919	ALU0320	IA705-B	25.67	37	Failed	39	31	7
MAT05646	ALU0941	IA206-B	79.67	99	Approved	94	68	77
MAT02016	ALU0336	IA506-B	89.00	83	Approved	88	80	99
MAT05643	ALU0941	IA203-B	86.00	75	Approved	89	70	99
MAT02012	ALU0336	IA502-B	88.67	84	Approved	94	90	82
MAT02014	ALU0336	IA504-B	81.67	92	Approved	88	84	73
MAT05550	ALU0925	IA206-B	30.00	90	Failed	34	36	20
MAT02061	ALU0344	IA403-B	45.00	44	Failed	41	45	49
MAT02088	ALU0348	IA706-A	23.67	47	Failed	33	37	1
MAT03822	ALU0637	IA606-B	25.33	38	Failed	23	29	24
MAT02082	ALU0347	IA306-B	37.33	71	Failed	52	27	33
MAT05238	ALU0873	IA306-B	20.67	68	Failed	55	4	3
MAT02079	ALU0347	IA303-B	54.00	87	Failed	55	56	51
MAT05545	ALU0925	IA201-B	3.33	95	Failed	1	7	2
MAT02078	ALU0347	IA302-B	26.33	92	Failed	44	30	5
MAT02072	ALU0346	IA702-B	46.00	90	Failed	36	50	52
MAT05547	ALU0925	IA203-B	52.67	68	Failed	55	56	47
MAT02052	ALU0342	IA206-A	26.33	67	Failed	12	18	49
MAT00214	ALU0036	IA204-A	32.00	75	Failed	57	12	27
MAT05648	ALU0942	IA702-B	22.00	90	Failed	10	43	13
MAT05642	ALU0941	IA202-B	32.33	33	Failed	58	8	31
MAT00236	ALU0040	IA302-A	53.33	71	Failed	59	55	46
MAT02047	ALU0342	IA201-A	16.33	99	Failed	7	34	8
MAT02085	ALU0348	IA703-A	37.67	44	Failed	35	21	57
MAT05644	ALU0941	IA204-B	42.33	96	Failed	39	44	44
MAT02050	ALU0342	IA204-A	42.67	68	Failed	33	57	38
MAT02013	ALU0336	IA503-B	32.33	81	Failed	1	37	59
MAT02096	ALU0350	IA802-B	26.00	97	Failed	19	16	43
MAT02084	ALU0348	IA702-A	23.00	56	Failed	11	43	15
MAT05649	ALU0942	IA703-B	5.67	95	Failed	3	5	9
MAT00002	ALU0001	IA202-B	39.33	43	Failed	57	8	53
MAT02080	ALU0347	IA304-B	25.33	92	Failed	26	12	38
MAT05557	ALU0927	IA601-B	33.00	68	Failed	27	35	37
MAT05645	ALU0941	IA205-B	27.33	44	Failed	35	23	24
MAT02083	ALU0348	IA701-A	24.00	37	Failed	26	33	13
MAT02011	ALU0336	IA501-B	32.67	98	Failed	36	8	54
MAT02086	ALU0348	IA704-A	39.33	39	Failed	41	43	34
MAT02081	ALU0347	IA305-B	32.67	89	Failed	37	44	17
MAT05647	ALU0942	IA701-B	33.00	50	Failed	0	46	53
MAT02015	ALU0336	IA505-B	33.67	86	Failed	24	54	23
MAT02077	ALU0347	IA301-B	26.33	39	Failed	20	54	5
MAT02196	ALU0366	IA306-B	68.00	87	Approved	72	65	67
MAT01102	ALU0184	IA304-A	77.67	99	Approved	82	71	80
MAT05466	ALU0911	IA506-A	97.67	82	Approved	100	93	100
MAT02166	ALU0361	IA206-B	76.67	87	Approved	64	91	75
MAT02213	ALU0369	IA305-B	75.00	94	Approved	77	61	87
MAT05782	ALU0964	IA504-B	65.33	95	Approved	69	67	60
MAT02181	ALU0364	IA103-A	81.00	83	Approved	62	93	88
MAT03227	ALU0538	IA205-A	22.00	64	Failed	9	24	33
MAT05768	ALU0962	IA302-B	34.67	63	Failed	39	22	43
MAT04158	ALU0693	IA206-B	29.00	52	Failed	5	56	26
MAT05778	ALU0963	IA306-B	34.00	44	Failed	24	26	52
MAT05775	ALU0963	IA303-B	27.33	55	Failed	20	29	33
MAT03661	ALU0611	IA301-B	28.33	61	Failed	24	3	58
MAT02193	ALU0366	IA303-B	39.67	34	Failed	34	29	56
MAT02195	ALU0366	IA305-B	38.67	91	Failed	40	24	52
MAT05781	ALU0964	IA503-B	36.33	32	Failed	47	26	36
MAT02161	ALU0361	IA201-B	13.00	54	Failed	22	8	9
MAT02234	ALU0373	IA602-B	32.33	67	Failed	43	34	20
MAT04331	ALU0722	IA805-B	49.33	80	Failed	53	43	52
MAT05777	ALU0963	IA305-B	14.00	52	Failed	15	2	25
MAT05310	ALU0885	IA206-B	35.00	55	Failed	36	14	55
MAT02211	ALU0369	IA303-B	32.00	53	Failed	24	23	49
MAT02237	ALU0373	IA605-B	28.67	99	Failed	22	15	49
MAT05784	ALU0964	IA506-B	44.00	70	Failed	32	55	45
MAT02184	ALU0364	IA106-A	36.33	36	Failed	43	55	11
MAT02235	ALU0373	IA603-B	42.00	81	Failed	44	59	23
MAT02164	ALU0361	IA204-B	25.33	50	Failed	54	9	13
MAT02236	ALU0373	IA604-B	45.67	57	Failed	59	58	20
MAT02194	ALU0366	IA304-B	35.00	90	Failed	59	39	7
MAT02191	ALU0366	IA301-B	37.67	51	Failed	33	53	27
MAT03674	ALU0613	IA102-B	36.00	63	Failed	35	40	33
MAT05774	ALU0963	IA302-B	36.67	83	Failed	55	27	28
MAT02186	ALU0365	IA202-A	26.67	73	Failed	20	10	50
MAT02232	ALU0372	IA806-B	20.67	54	Failed	8	29	25
MAT05771	ALU0962	IA305-B	38.67	86	Failed	46	18	52
MAT05773	ALU0963	IA301-B	36.33	89	Failed	46	42	21
MAT05783	ALU0964	IA505-B	25.67	87	Failed	27	20	30
MAT02362	ALU0394	IA404-B	84.00	86	Approved	81	81	90
MAT02266	ALU0378	IA604-B	83.67	88	Approved	83	68	100
MAT02321	ALU0387	IA305-B	91.00	91	Approved	91	82	100
MAT02348	ALU0392	IA502-B	80.00	81	Approved	85	63	92
MAT02271	ALU0379	IA703-A	77.33	75	Approved	78	68	86
MAT02363	ALU0394	IA405-B	17.33	32	Failed	28	3	21
MAT02352	ALU0392	IA506-B	29.67	57	Failed	22	9	58
MAT02339	ALU0390	IA705-B	20.00	95	Failed	49	5	6
MAT02350	ALU0392	IA504-B	33.67	54	Failed	52	13	36
MAT00275	ALU0046	IA505-B	38.67	81	Failed	25	56	35
MAT02275	ALU0380	IA101-B	41.33	72	Failed	36	36	52
MAT02349	ALU0392	IA503-B	43.67	51	Failed	40	48	43
MAT03081	ALU0514	IA203-B	14.33	91	Failed	18	14	11
MAT04059	ALU0677	IA103-B	36.00	69	Failed	40	10	58
MAT05769	ALU0962	IA303-B	12.00	49	Failed	1	28	7
MAT02268	ALU0378	IA606-B	35.67	88	Failed	53	3	51
MAT02274	ALU0379	IA706-A	45.67	56	Failed	50	50	37
MAT02042	ALU0341	IA402-B	19.67	39	Failed	21	14	24
MAT04719	ALU0787	IA503-A	41.33	33	Failed	25	58	41
MAT05849	ALU0975	IA405-B	25.00	93	Failed	41	12	22
MAT02265	ALU0378	IA603-B	22.33	47	Failed	21	0	46
MAT03076	ALU0513	IA204-A	37.00	87	Failed	50	44	17
MAT02340	ALU0390	IA706-B	19.00	70	Failed	8	37	12
MAT02300	ALU0384	IA202-B	19.67	69	Failed	10	14	35
MAT04973	ALU0829	IA405-A	22.33	39	Failed	21	34	12
MAT02468	ALU0412	IA602-B	32.33	76	Failed	21	40	36
MAT02351	ALU0392	IA505-B	23.00	100	Failed	9	36	24
MAT02320	ALU0387	IA304-B	50.67	69	Failed	52	47	53
MAT05008	ALU0835	IA304-B	38.33	75	Failed	56	36	23
MAT02364	ALU0394	IA406-B	20.00	67	Failed	21	31	8
MAT02353	ALU0393	IA401-B	35.67	92	Failed	44	13	50
MAT02272	ALU0379	IA704-A	28.00	63	Failed	6	33	45
MAT02361	ALU0394	IA403-B	18.67	48	Failed	40	0	16
MAT02301	ALU0384	IA203-B	25.67	81	Failed	48	4	25
MAT02724	ALU0454	IA606-B	31.67	44	Failed	59	23	13
MAT02439	ALU0407	IA403-B	75.67	82	Approved	73	91	63
MAT02435	ALU0406	IA405-B	72.00	83	Approved	73	77	66
MAT00088	ALU0015	IA204-B	86.33	95	Approved	100	98	61
MAT00066	ALU0011	IA106-A	91.00	86	Approved	92	100	81
MAT02521	ALU0421	IA301-B	82.67	80	Approved	87	69	92
MAT02458	ALU0410	IA804-A	17.00	51	Failed	39	11	1
MAT02502	ALU0417	IA506-B	20.33	71	Failed	7	8	46
MAT02427	ALU0405	IA803-A	34.00	31	Failed	45	57	0
MAT02459	ALU0410	IA805-A	18.00	100	Failed	14	12	28
MAT02422	ALU0404	IA304-B	45.33	91	Failed	55	56	25
MAT02443	ALU0408	IA601-B	40.33	65	Failed	58	49	14
MAT02500	ALU0417	IA504-B	45.33	67	Failed	31	57	48
MAT02454	ALU0409	IA406-B	42.67	82	Failed	57	23	48
MAT02437	ALU0407	IA401-B	40.33	89	Failed	37	29	55
MAT02423	ALU0404	IA305-B	11.33	43	Failed	9	13	12
MAT02432	ALU0406	IA402-B	36.00	56	Failed	32	51	25
MAT02522	ALU0421	IA302-B	11.00	50	Failed	0	8	25
MAT04788	ALU0798	IA606-B	22.00	60	Failed	8	42	16
MAT05142	ALU0857	IA406-A	26.00	62	Failed	29	26	23
MAT02531	ALU0422	IA405-B	28.00	62	Failed	26	15	43
MAT02460	ALU0410	IA806-A	41.67	97	Failed	27	48	50
MAT02526	ALU0421	IA306-B	23.00	78	Failed	42	0	27
MAT00091	ALU0016	IA201-A	34.00	91	Failed	32	24	46
MAT02450	ALU0409	IA402-B	28.00	39	Failed	39	34	11
MAT02431	ALU0406	IA401-B	40.67	48	Failed	40	27	55
MAT02501	ALU0417	IA505-B	46.00	35	Failed	49	53	36
MAT02535	ALU0423	IA603-A	27.33	69	Failed	15	31	36
MAT02511	ALU0419	IA503-B	18.33	51	Failed	49	2	4
MAT05622	ALU0937	IA506-B	24.00	64	Failed	58	3	11
MAT02441	ALU0407	IA405-B	22.67	82	Failed	36	5	27
MAT02447	ALU0408	IA605-B	31.33	50	Failed	29	19	46
MAT02414	ALU0403	IA102-B	23.67	38	Failed	29	34	8
MAT02413	ALU0403	IA101-B	25.67	63	Failed	35	2	40
MAT02523	ALU0421	IA303-B	33.00	57	Failed	0	59	40
MAT02514	ALU0419	IA506-B	32.00	44	Failed	47	11	38
MAT02525	ALU0421	IA305-B	18.00	68	Failed	0	51	3
MAT02425	ALU0405	IA801-A	25.33	34	Failed	50	5	21
MAT02448	ALU0408	IA606-B	38.33	42	Failed	51	11	53
MAT02455	ALU0410	IA801-A	35.67	82	Failed	47	23	37
MAT02416	ALU0403	IA104-B	31.67	61	Failed	12	38	45
MAT02456	ALU0410	IA802-A	32.00	40	Failed	38	11	47
MAT02433	ALU0406	IA403-B	30.67	48	Failed	10	51	31
MAT02552	ALU0426	IA502-B	63.00	98	Approved	65	64	60
MAT00576	ALU0096	IA106-A	73.67	81	Approved	79	82	60
MAT02551	ALU0426	IA501-B	79.00	80	Approved	68	85	84
MAT02576	ALU0430	IA102-B	29.33	43	Failed	19	22	47
MAT02580	ALU0430	IA106-B	44.00	77	Failed	50	50	32
MAT00584	ALU0098	IA202-A	21.67	69	Failed	50	7	8
MAT02577	ALU0430	IA103-B	33.00	47	Failed	49	7	43
MAT02604	ALU0434	IA706-A	25.00	79	Failed	2	54	19
MAT01777	ALU0297	IA801-B	30.67	35	Failed	9	30	53
MAT02632	ALU0439	IA804-B	41.67	83	Failed	52	59	14
MAT01997	ALU0333	IA105-A	24.33	45	Failed	0	57	16
MAT02623	ALU0438	IA101-B	35.67	84	Failed	18	55	34
MAT02620	ALU0437	IA204-A	31.33	30	Failed	14	39	41
MAT02556	ALU0426	IA506-B	23.00	74	Failed	24	1	44
MAT02626	ALU0438	IA104-B	38.00	71	Failed	39	37	38
MAT05480	ALU0914	IA602-A	32.00	61	Failed	42	14	40
MAT02619	ALU0437	IA203-A	27.67	55	Failed	41	18	24
MAT04444	ALU0741	IA404-B	34.00	51	Failed	36	14	52
MAT05007	ALU0835	IA303-B	25.67	93	Failed	53	2	22
MAT02617	ALU0437	IA201-A	25.00	65	Failed	41	11	23
MAT02581	ALU0431	IA201-A	20.67	46	Failed	38	24	0
MAT02630	ALU0439	IA802-B	32.67	92	Failed	31	46	21
MAT02579	ALU0430	IA105-B	22.67	77	Failed	57	3	8
MAT04785	ALU0798	IA603-B	34.33	47	Failed	48	36	19
MAT00586	ALU0098	IA204-A	37.67	64	Failed	54	37	22
MAT04695	ALU0783	IA503-A	33.00	37	Failed	52	5	42
MAT02621	ALU0437	IA205-A	40.33	99	Failed	46	28	47
MAT02574	ALU0429	IA406-A	20.67	38	Failed	19	11	32
MAT02608	ALU0435	IA604-B	28.00	63	Failed	44	20	20
MAT05080	ALU0847	IA804-A	33.33	85	Failed	15	54	31
MAT02609	ALU0435	IA605-B	43.67	33	Failed	44	32	55
MAT04326	ALU0721	IA206-A	19.67	51	Failed	12	7	40
MAT02592	ALU0432	IA206-A	28.00	72	Failed	14	44	26
MAT05285	ALU0881	IA105-A	29.33	69	Failed	13	20	55
MAT02726	ALU0455	IA802-B	74.00	92	Approved	73	87	62
MAT01429	ALU0239	IA101-B	83.33	85	Approved	75	100	75
MAT02715	ALU0453	IA803-A	81.67	77	Approved	88	85	72
MAT02670	ALU0445	IA806-B	72.67	86	Approved	63	74	81
MAT02703	ALU0451	IA403-B	88.33	87	Approved	93	98	74
MAT01526	ALU0255	IA502-A	72.67	91	Approved	71	72	75
MAT02684	ALU0448	IA502-A	75.33	91	Approved	72	60	94
MAT02694	ALU0449	IA806-A	75.00	90	Approved	95	65	65
MAT02727	ALU0455	IA803-B	30.67	67	Failed	24	32	36
MAT02704	ALU0451	IA404-B	20.67	89	Failed	7	35	20
MAT03775	ALU0630	IA101-B	27.67	95	Failed	20	4	59
MAT01132	ALU0189	IA804-A	37.67	30	Failed	10	52	51
MAT01538	ALU0257	IA402-B	31.33	99	Failed	16	26	52
MAT01540	ALU0257	IA404-B	9.67	59	Failed	6	18	5
MAT04914	ALU0819	IA206-B	25.67	60	Failed	16	33	28
MAT01428	ALU0238	IA806-A	25.67	63	Failed	3	50	24
MAT01485	ALU0248	IA403-B	23.33	51	Failed	7	55	8
MAT02688	ALU0448	IA506-A	19.00	71	Failed	16	22	19
MAT02725	ALU0455	IA801-B	50.00	51	Failed	45	46	59
MAT02774	ALU0463	IA602-A	30.67	69	Failed	28	15	49
MAT03776	ALU0630	IA102-B	19.00	78	Failed	16	10	31
MAT02691	ALU0449	IA803-A	28.33	38	Failed	9	24	52
MAT05301	ALU0884	IA603-A	16.33	74	Failed	12	7	30
MAT01537	ALU0257	IA401-B	37.67	72	Failed	50	29	34
MAT00053	ALU0009	IA205-A	26.67	57	Failed	2	31	47
MAT04843	ALU0808	IA301-B	21.00	58	Failed	10	16	37
MAT02731	ALU0456	IA601-A	16.67	45	Failed	37	3	10
MAT01472	ALU0246	IA802-A	40.67	42	Failed	39	41	42
MAT05761	ALU0961	IA301-B	27.67	43	Failed	31	13	39
MAT01482	ALU0247	IA206-B	35.67	68	Failed	35	27	45
MAT02718	ALU0453	IA806-A	9.67	31	Failed	7	5	17
MAT02736	ALU0456	IA606-A	48.00	55	Failed	56	57	31
MAT01416	ALU0236	IA606-B	25.00	97	Failed	42	9	24
MAT02728	ALU0455	IA804-B	30.33	60	Failed	3	38	50
MAT02705	ALU0451	IA405-B	21.67	71	Failed	17	19	29
MAT01139	ALU0190	IA405-A	35.00	52	Failed	42	5	58
MAT03684	ALU0614	IA706-A	34.00	81	Failed	8	46	48
MAT02793	ALU0466	IA603-B	94.00	75	Approved	97	97	88
MAT02834	ALU0473	IA602-A	87.33	95	Approved	100	73	89
MAT02837	ALU0473	IA605-A	75.67	85	Approved	70	86	71
MAT05447	ALU0908	IA705-B	95.00	96	Approved	100	94	91
MAT02934	ALU0489	IA606-A	94.33	98	Approved	100	88	95
MAT02922	ALU0487	IA806-B	84.67	93	Approved	66	97	91
MAT02874	ALU0479	IA406-B	23.67	42	Failed	19	47	5
MAT02835	ALU0473	IA603-A	35.00	95	Failed	46	58	1
MAT02873	ALU0479	IA405-B	34.00	48	Failed	42	4	56
MAT02946	ALU0491	IA206-B	32.67	70	Failed	27	28	43
MAT02833	ALU0473	IA601-A	42.00	85	Failed	44	36	46
MAT00034	ALU0006	IA104-A	33.33	71	Failed	44	51	5
MAT02805	ALU0468	IA203-B	18.00	50	Failed	20	11	23
MAT02917	ALU0487	IA801-B	27.00	47	Failed	6	43	32
MAT00856	ALU0143	IA204-A	29.33	76	Failed	11	43	34
MAT02815	ALU0470	IA201-B	20.00	74	Failed	14	9	37
MAT02829	ALU0472	IA703-B	32.67	67	Failed	37	8	53
MAT02189	ALU0365	IA205-A	25.67	43	Failed	33	26	18
MAT02798	ALU0467	IA302-B	27.33	78	Failed	38	13	31
MAT05088	ALU0848	IA106-A	27.33	47	Failed	9	33	40
MAT04009	ALU0669	IA301-A	25.00	79	Failed	7	37	31
MAT00400	ALU0067	IA604-B	39.33	40	Failed	44	49	25
MAT02201	ALU0367	IA805-B	22.67	53	Failed	13	39	16
MAT02808	ALU0468	IA206-B	29.33	37	Failed	6	45	37
MAT00450	ALU0075	IA506-B	13.00	61	Failed	1	12	26
MAT02932	ALU0489	IA604-A	35.67	53	Failed	37	39	31
MAT02821	ALU0471	IA301-B	34.00	56	Failed	56	26	20
MAT02925	ALU0488	IA403-B	27.33	86	Failed	31	4	47
MAT02795	ALU0466	IA605-B	31.67	49	Failed	23	26	46
MAT00386	ALU0065	IA702-A	22.00	56	Failed	5	9	52
MAT02933	ALU0489	IA605-A	41.00	57	Failed	50	37	36
MAT03291	ALU0549	IA103-B	27.33	64	Failed	56	23	3
MAT05252	ALU0876	IA802-B	19.33	88	Failed	49	1	8
MAT02188	ALU0365	IA204-A	37.00	51	Failed	59	41	11
MAT04961	ALU0827	IA205-B	26.67	42	Failed	12	38	30
MAT02948	ALU0492	IA702-B	32.00	76	Failed	53	38	5
MAT03006	ALU0501	IA706-A	79.00	85	Approved	84	93	60
MAT01461	ALU0244	IA303-B	73.33	94	Approved	100	60	60
MAT03011	ALU0502	IA105-B	74.67	92	Approved	95	66	63
MAT03003	ALU0501	IA703-A	93.00	82	Approved	100	91	88
MAT02986	ALU0498	IA304-B	72.00	88	Approved	71	77	68
MAT04834	ALU0806	IA304-A	82.67	84	Approved	86	99	63
MAT03014	ALU0503	IA702-B	75.33	97	Approved	82	76	68
MAT03467	ALU0578	IA205-A	68.33	92	Approved	61	63	81
MAT02982	ALU0497	IA606-B	23.67	58	Failed	2	29	40
MAT03551	ALU0592	IA605-B	31.00	62	Failed	40	3	50
MAT02885	ALU0481	IA205-B	33.67	43	Failed	23	35	43
MAT04034	ALU0673	IA402-B	35.33	66	Failed	34	52	20
MAT02900	ALU0484	IA202-B	22.33	51	Failed	24	14	29
MAT02989	ALU0499	IA301-B	17.33	82	Failed	8	40	4
MAT04190	ALU0699	IA802-B	48.33	81	Failed	56	31	58
MAT00488	ALU0082	IA102-A	25.00	38	Failed	12	30	33
MAT05006	ALU0835	IA302-B	23.67	98	Failed	7	19	45
MAT02886	ALU0481	IA206-B	38.00	92	Failed	17	49	48
MAT02035	ALU0340	IA101-B	30.67	94	Failed	45	25	22
MAT02981	ALU0497	IA605-B	37.67	78	Failed	37	34	42
MAT02442	ALU0407	IA406-B	21.67	51	Failed	51	0	14
MAT03012	ALU0502	IA106-B	43.67	92	Failed	49	48	34
MAT03513	ALU0586	IA203-B	27.67	33	Failed	38	23	22
MAT05690	ALU0949	IA302-A	32.00	55	Failed	15	24	57
MAT02994	ALU0499	IA306-B	37.33	35	Failed	40	28	44
MAT05291	ALU0882	IA405-B	15.33	78	Failed	6	0	40
MAT03009	ALU0502	IA103-B	11.00	44	Failed	3	0	30
MAT02931	ALU0489	IA603-A	22.67	69	Failed	20	9	39
MAT02910	ALU0485	IA306-B	21.67	88	Failed	7	44	14
MAT03008	ALU0502	IA102-B	39.00	67	Failed	11	51	55
MAT04483	ALU0748	IA601-B	15.67	90	Failed	5	42	0
MAT00761	ALU0127	IA805-B	76.00	75	Approved	87	80	61
MAT03144	ALU0524	IA206-B	77.33	94	Approved	71	63	98
MAT03112	ALU0519	IA504-B	86.00	76	Approved	89	72	97
MAT03117	ALU0520	IA303-A	43.33	98	Failed	47	50	33
MAT01136	ALU0190	IA402-A	7.00	45	Failed	4	10	7
MAT03141	ALU0524	IA203-B	19.00	62	Failed	4	2	51
MAT05705	ALU0951	IA305-A	39.00	85	Failed	56	30	31
MAT04905	ALU0818	IA703-A	15.67	98	Failed	17	0	30
MAT03059	ALU0510	IA605-B	38.00	84	Failed	35	36	43
MAT05503	ALU0918	IA801-A	8.67	69	Failed	2	16	8
MAT03058	ALU0510	IA604-B	44.00	39	Failed	52	32	48
MAT03137	ALU0523	IA505-B	34.00	48	Failed	52	36	14
MAT03127	ALU0522	IA401-B	19.00	81	Failed	10	9	38
MAT03136	ALU0523	IA504-B	31.67	32	Failed	15	35	45
MAT03057	ALU0510	IA603-B	23.33	53	Failed	9	23	38
MAT03140	ALU0524	IA202-B	46.00	99	Failed	55	24	59
MAT03094	ALU0516	IA604-A	47.67	53	Failed	52	45	46
MAT03171	ALU0529	IA203-B	35.00	64	Failed	19	51	35
MAT03169	ALU0529	IA201-B	39.33	36	Failed	57	37	24
MAT02872	ALU0479	IA404-B	26.00	43	Failed	35	24	19
MAT03139	ALU0524	IA201-B	31.00	78	Failed	25	56	12
MAT03519	ALU0587	IA803-A	19.67	45	Failed	17	2	40
MAT04743	ALU0791	IA103-A	21.00	33	Failed	23	11	29
MAT00071	ALU0012	IA505-B	29.67	92	Failed	38	0	51
MAT02397	ALU0400	IA403-B	41.00	72	Failed	45	59	19
MAT05433	ALU0906	IA103-B	31.00	89	Failed	43	2	48
MAT03111	ALU0519	IA503-B	32.00	83	Failed	27	15	54
MAT00966	ALU0161	IA206-B	28.33	66	Failed	45	30	10
MAT04934	ALU0823	IA402-B	4.67	95	Failed	8	1	5
MAT04897	ALU0817	IA701-A	32.67	37	Failed	47	50	1
MAT03156	ALU0526	IA506-B	29.67	98	Failed	1	47	41
MAT03114	ALU0519	IA506-B	25.00	50	Failed	26	17	32
MAT03284	ALU0548	IA102-B	88.33	98	Approved	100	71	94
MAT03346	ALU0558	IA104-B	79.67	78	Approved	63	79	97
MAT03355	ALU0560	IA601-B	85.33	76	Approved	92	82	82
MAT03319	ALU0554	IA301-B	74.00	83	Approved	75	69	78
MAT03335	ALU0556	IA605-B	75.33	85	Approved	91	75	60
MAT05595	ALU0933	IA703-B	85.67	91	Approved	97	77	83
MAT03278	ALU0547	IA602-A	66.00	98	Approved	61	77	60
MAT03087	ALU0515	IA203-B	85.67	100	Approved	68	89	100
MAT03342	ALU0557	IA406-B	84.00	95	Approved	76	76	100
MAT03297	ALU0550	IA503-A	82.00	94	Approved	78	75	93
MAT03287	ALU0548	IA105-B	35.33	62	Failed	29	39	38
MAT03263	ALU0544	IA505-A	25.00	57	Failed	50	9	16
MAT03259	ALU0544	IA501-A	32.00	37	Failed	30	10	56
MAT03262	ALU0544	IA504-A	46.00	40	Failed	37	50	51
MAT03362	ALU0561	IA802-B	15.67	94	Failed	13	3	31
MAT03332	ALU0556	IA602-B	27.00	84	Failed	31	22	28
MAT03275	ALU0546	IA205-B	21.33	57	Failed	15	10	39
MAT03321	ALU0554	IA303-B	36.33	59	Failed	23	54	32
MAT03358	ALU0560	IA604-B	32.67	85	Failed	29	34	35
MAT03281	ALU0547	IA605-A	36.67	41	Failed	34	50	26
MAT03307	ALU0552	IA401-B	28.33	66	Failed	9	38	38
MAT03324	ALU0554	IA306-B	32.67	48	Failed	14	58	26
MAT03363	ALU0561	IA803-B	39.00	98	Failed	39	54	24
MAT03356	ALU0560	IA602-B	35.67	92	Failed	2	47	58
MAT03317	ALU0553	IA805-A	15.00	66	Failed	22	0	23
MAT03277	ALU0547	IA601-A	29.00	35	Failed	36	15	36
MAT03288	ALU0548	IA106-B	40.67	41	Failed	52	13	57
MAT03352	ALU0559	IA404-A	20.67	73	Failed	0	42	20
MAT03309	ALU0552	IA403-B	24.33	95	Failed	21	6	46
MAT03333	ALU0556	IA603-B	27.33	35	Failed	36	7	39
MAT03338	ALU0557	IA402-B	25.00	64	Failed	57	11	7
MAT03299	ALU0550	IA505-A	23.67	84	Failed	12	48	11
MAT03295	ALU0550	IA501-A	47.67	87	Failed	54	31	58
MAT03279	ALU0547	IA603-A	24.67	84	Failed	37	12	25
MAT03286	ALU0548	IA104-B	37.00	86	Failed	19	49	43
MAT02227	ALU0372	IA801-B	35.33	33	Failed	7	47	52
MAT03261	ALU0544	IA503-A	33.33	45	Failed	15	41	44
MAT03283	ALU0548	IA101-B	21.33	35	Failed	3	57	4
MAT03276	ALU0546	IA206-B	34.67	86	Failed	13	36	55
MAT03126	ALU0521	IA506-B	17.67	89	Failed	30	21	2
MAT05855	ALU0976	IA305-A	81.33	97	Approved	76	86	82
MAT03359	ALU0560	IA605-B	84.67	90	Approved	86	79	89
MAT02322	ALU0387	IA306-B	78.00	89	Approved	65	95	74
MAT03403	ALU0568	IA701-A	85.67	81	Approved	67	93	97
MAT03785	ALU0631	IA305-B	30.00	85	Failed	23	56	11
MAT03348	ALU0558	IA106-B	18.33	54	Failed	10	32	13
MAT00706	ALU0118	IA804-B	40.33	77	Failed	55	32	34
MAT00502	ALU0084	IA204-B	33.33	33	Failed	46	5	49
MAT03331	ALU0556	IA601-B	22.67	46	Failed	12	31	25
MAT02112	ALU0352	IA206-A	32.33	96	Failed	27	42	28
MAT03413	ALU0569	IA105-B	38.00	38	Failed	48	39	27
MAT03728	ALU0622	IA102-B	39.67	48	Failed	48	52	19
MAT03739	ALU0624	IA701-B	43.33	97	Failed	36	45	49
MAT03380	ALU0564	IA202-B	43.67	68	Failed	50	27	54
MAT00466	ALU0078	IA104-A	40.67	81	Failed	48	55	19
MAT00670	ALU0112	IA404-B	20.67	37	Failed	26	3	33
MAT02486	ALU0415	IA802-B	20.67	55	Failed	10	2	50
MAT03398	ALU0567	IA102-B	38.67	32	Failed	56	56	4
MAT04531	ALU0756	IA801-B	38.00	58	Failed	41	42	31
MAT02735	ALU0456	IA605-A	47.67	47	Failed	53	34	56
MAT03300	ALU0550	IA506-A	36.00	60	Failed	45	22	41
MAT03419	ALU0570	IA405-B	29.00	70	Failed	20	21	46
MAT01359	ALU0227	IA503-B	34.00	89	Failed	27	36	39
MAT03343	ALU0558	IA101-B	31.67	42	Failed	1	52	42
MAT00211	ALU0036	IA201-A	23.67	37	Failed	14	5	52
MAT00028	ALU0005	IA404-B	17.67	37	Failed	16	8	29
MAT01469	ALU0245	IA405-B	40.67	34	Failed	34	56	32
MAT00566	ALU0095	IA302-A	80.00	94	Approved	98	70	72
MAT03582	ALU0597	IA706-A	89.67	79	Approved	100	96	73
MAT03553	ALU0593	IA501-A	79.67	81	Approved	75	94	70
MAT03530	ALU0589	IA702-B	90.00	87	Approved	73	99	98
MAT03529	ALU0589	IA701-B	72.33	87	Approved	81	71	65
MAT03534	ALU0589	IA706-B	77.00	99	Approved	77	87	67
MAT03604	ALU0601	IA604-B	65.33	81	Approved	72	62	62
MAT03573	ALU0596	IA103-B	22.00	93	Failed	34	8	24
MAT03588	ALU0598	IA106-A	33.33	73	Failed	57	43	0
MAT03572	ALU0596	IA102-B	12.67	76	Failed	9	14	15
MAT04537	ALU0757	IA201-A	44.33	60	Failed	47	51	35
MAT03538	ALU0590	IA104-B	29.67	100	Failed	8	55	26
MAT03522	ALU0587	IA806-A	7.00	61	Failed	5	0	16
MAT05195	ALU0866	IA305-B	38.67	58	Failed	35	26	55
MAT03526	ALU0588	IA404-A	44.67	71	Failed	57	39	38
MAT03525	ALU0588	IA403-A	25.00	81	Failed	46	6	23
MAT03577	ALU0597	IA701-A	19.33	69	Failed	32	16	10
MAT03589	ALU0599	IA701-B	41.67	90	Failed	50	31	44
MAT03369	ALU0562	IA403-B	8.33	39	Failed	0	14	11
MAT03581	ALU0597	IA705-A	20.33	57	Failed	8	8	45
MAT03527	ALU0588	IA405-A	28.67	68	Failed	46	32	8
MAT00984	ALU0164	IA506-A	37.33	54	Failed	37	44	31
MAT03558	ALU0593	IA506-A	38.67	82	Failed	51	43	22
MAT03560	ALU0594	IA402-A	22.67	39	Failed	14	37	17
MAT03532	ALU0589	IA704-B	31.67	72	Failed	49	9	37
MAT03557	ALU0593	IA505-A	32.00	38	Failed	8	54	34
MAT03533	ALU0589	IA705-B	39.67	70	Failed	24	40	55
MAT03556	ALU0593	IA504-A	35.33	92	Failed	21	38	47
MAT00163	ALU0028	IA301-B	29.33	31	Failed	50	1	37
MAT03540	ALU0590	IA106-B	47.33	70	Failed	36	55	51
MAT03576	ALU0596	IA106-B	34.67	59	Failed	7	56	41
MAT05986	ALU0998	IA704-B	35.33	62	Failed	49	33	24
MAT03555	ALU0593	IA503-A	11.33	41	Failed	3	0	31
MAT03587	ALU0598	IA105-A	26.33	51	Failed	14	49	16
MAT03562	ALU0594	IA404-A	23.67	48	Failed	12	40	19
MAT01261	ALU0211	IA201-B	31.67	65	Failed	35	15	45
MAT03586	ALU0598	IA104-A	21.67	86	Failed	3	43	19
MAT03531	ALU0589	IA703-B	32.67	76	Failed	13	35	50
MAT03720	ALU0620	IA406-B	79.00	77	Approved	96	72	69
MAT03639	ALU0607	IA303-A	29.00	77	Failed	45	28	14
MAT03700	ALU0617	IA704-A	32.33	75	Failed	39	54	4
MAT03719	ALU0620	IA405-B	49.33	42	Failed	52	51	45
MAT05786	ALU0965	IA702-B	42.00	81	Failed	28	41	57
MAT03683	ALU0614	IA705-A	44.67	90	Failed	59	28	47
MAT03698	ALU0617	IA702-A	36.67	84	Failed	26	39	45
MAT03610	ALU0602	IA504-A	25.00	63	Failed	23	44	8
MAT03687	ALU0615	IA303-B	45.33	54	Failed	49	57	30
MAT03621	ALU0604	IA403-A	27.33	74	Failed	19	37	26
MAT03703	ALU0618	IA201-B	29.67	75	Failed	32	55	2
MAT03708	ALU0618	IA206-B	22.33	30	Failed	21	33	13
MAT03686	ALU0615	IA302-B	20.33	73	Failed	51	1	9
MAT03693	ALU0616	IA303-B	24.33	32	Failed	12	55	6
MAT03622	ALU0604	IA404-A	32.33	70	Failed	8	57	32
MAT03699	ALU0617	IA703-A	23.33	45	Failed	35	3	32
MAT03702	ALU0617	IA706-A	23.33	90	Failed	3	24	43
MAT03688	ALU0615	IA304-B	17.33	48	Failed	16	15	21
MAT03714	ALU0619	IA206-B	8.33	70	Failed	3	4	18
MAT03713	ALU0619	IA205-B	31.00	100	Failed	15	19	59
MAT03694	ALU0616	IA304-B	33.67	70	Failed	10	34	57
MAT03706	ALU0618	IA204-B	17.33	55	Failed	17	10	25
MAT01463	ALU0244	IA305-B	32.67	60	Failed	54	5	39
MAT03721	ALU0621	IA401-B	46.67	42	Failed	27	54	59
MAT01426	ALU0238	IA804-A	37.33	31	Failed	8	59	45
MAT01699	ALU0284	IA601-A	27.33	88	Failed	40	18	24
MAT01778	ALU0297	IA802-B	23.00	99	Failed	21	33	15
MAT04642	ALU0774	IA404-B	25.67	62	Failed	11	7	59
MAT02892	ALU0482	IA806-B	25.00	60	Failed	14	17	44
MAT05163	ALU0861	IA203-B	36.00	99	Failed	29	43	36
MAT05066	ALU0845	IA502-B	33.67	92	Failed	34	43	24
MAT05289	ALU0882	IA403-B	27.33	63	Failed	57	4	21
MAT03640	ALU0607	IA304-A	40.00	76	Failed	42	32	46
MAT03695	ALU0616	IA305-B	33.67	86	Failed	40	44	17
MAT03697	ALU0617	IA701-A	17.33	46	Failed	5	42	5
MAT03692	ALU0616	IA302-B	26.00	31	Failed	44	21	13
MAT03685	ALU0615	IA301-B	38.00	79	Failed	59	4	51
MAT03635	ALU0606	IA305-B	38.00	69	Failed	51	22	41
MAT03701	ALU0617	IA705-A	29.00	98	Failed	28	40	19
MAT03879	ALU0647	IA503-A	73.00	89	Approved	63	88	68
MAT03796	ALU0633	IA304-A	75.67	80	Approved	70	68	89
MAT03849	ALU0642	IA403-B	83.67	99	Approved	87	90	74
MAT03813	ALU0636	IA303-B	72.33	79	Approved	62	79	76
MAT03878	ALU0647	IA502-A	72.33	94	Approved	68	64	85
MAT03816	ALU0636	IA306-B	70.33	87	Approved	75	65	71
MAT03797	ALU0633	IA305-A	84.67	98	Approved	80	97	77
MAT03885	ALU0648	IA703-B	34.00	87	Failed	36	34	32
MAT03856	ALU0643	IA404-A	28.00	96	Failed	34	49	1
MAT03854	ALU0643	IA402-A	32.33	95	Failed	20	36	41
MAT03882	ALU0647	IA506-A	27.67	77	Failed	54	7	22
MAT03821	ALU0637	IA605-B	19.33	59	Failed	15	16	27
MAT03795	ALU0633	IA303-A	11.33	47	Failed	25	9	0
MAT03837	ALU0640	IA103-B	36.33	59	Failed	36	15	58
MAT03870	ALU0645	IA606-B	28.67	43	Failed	33	5	48
MAT03872	ALU0646	IA502-B	38.00	66	Failed	1	59	54
MAT03855	ALU0643	IA403-A	27.33	78	Failed	40	2	40
MAT03814	ALU0636	IA304-B	14.67	39	Failed	3	26	15
MAT03767	ALU0628	IA405-B	27.00	67	Failed	16	36	29
MAT03850	ALU0642	IA404-B	23.33	69	Failed	43	18	9
MAT03834	ALU0639	IA306-B	20.00	79	Failed	2	49	9
MAT03768	ALU0628	IA406-B	48.67	58	Failed	55	46	45
MAT03798	ALU0633	IA306-A	23.33	36	Failed	29	5	36
MAT03881	ALU0647	IA505-A	6.33	76	Failed	10	7	2
MAT03880	ALU0647	IA504-A	21.33	59	Failed	15	12	37
MAT03794	ALU0633	IA302-A	22.67	60	Failed	24	37	7
MAT03812	ALU0636	IA302-B	9.00	76	Failed	9	9	9
MAT03859	ALU0644	IA501-A	8.67	46	Failed	12	6	8
MAT03887	ALU0648	IA705-B	18.00	100	Failed	9	11	34
MAT03791	ALU0632	IA805-B	46.00	53	Failed	42	53	43
MAT03848	ALU0642	IA402-B	32.67	54	Failed	45	2	51
MAT03810	ALU0635	IA406-B	40.33	48	Failed	24	48	49
MAT03883	ALU0648	IA701-B	24.00	71	Failed	0	56	16
MAT03886	ALU0648	IA704-B	38.33	69	Failed	55	14	46
MAT03817	ALU0637	IA601-B	40.67	46	Failed	25	43	54
MAT03877	ALU0647	IA501-A	20.33	49	Failed	16	18	27
MAT03889	ALU0649	IA301-B	34.33	74	Failed	45	52	6
MAT03858	ALU0643	IA406-A	21.00	82	Failed	5	40	18
MAT03815	ALU0636	IA305-B	27.33	74	Failed	6	44	32
MAT03852	ALU0642	IA406-B	37.67	62	Failed	29	37	47
MAT03811	ALU0636	IA301-B	49.00	59	Failed	55	34	58
MAT03888	ALU0648	IA706-B	48.00	36	Failed	53	57	34
MAT01199	ALU0200	IA605-A	19.00	37	Failed	16	39	2
MAT00688	ALU0115	IA304-A	34.33	84	Failed	56	23	24
MAT03884	ALU0648	IA702-B	81.00	87	Approved	92	77	74
MAT03971	ALU0662	IA105-B	14.33	38	Failed	11	9	23
MAT03961	ALU0661	IA401-A	39.33	50	Failed	51	50	17
MAT03968	ALU0662	IA102-B	36.67	99	Failed	50	13	47
MAT03955	ALU0660	IA401-B	48.00	82	Failed	53	39	52
MAT03957	ALU0660	IA403-B	20.67	69	Failed	25	21	16
MAT03956	ALU0660	IA402-B	19.33	56	Failed	5	7	46
MAT03958	ALU0660	IA404-B	17.00	41	Failed	8	9	34
MAT03915	ALU0653	IA603-B	19.00	43	Failed	26	27	4
MAT03948	ALU0658	IA806-B	12.33	58	Failed	21	16	0
MAT03935	ALU0656	IA405-B	32.67	56	Failed	38	13	47
MAT03923	ALU0654	IA405-B	27.67	81	Failed	44	34	5
MAT03910	ALU0652	IA504-B	41.33	96	Failed	37	59	28
MAT03967	ALU0662	IA101-B	27.33	80	Failed	19	5	58
MAT03920	ALU0654	IA402-B	49.00	59	Failed	44	44	59
MAT03905	ALU0651	IA205-B	44.33	51	Failed	39	54	40
MAT03946	ALU0658	IA804-B	11.33	72	Failed	3	16	15
MAT03906	ALU0651	IA206-B	34.67	50	Failed	2	45	57
MAT03945	ALU0658	IA803-B	37.00	72	Failed	15	56	40
MAT03895	ALU0650	IA801-B	31.33	56	Failed	41	28	25
MAT03950	ALU0659	IA602-A	13.67	35	Failed	16	0	25
MAT03912	ALU0652	IA506-B	24.00	40	Failed	40	21	11
MAT03864	ALU0644	IA506-A	29.00	97	Failed	30	51	6
MAT03909	ALU0652	IA503-B	43.00	30	Failed	21	50	58
MAT03903	ALU0651	IA203-B	29.00	93	Failed	59	26	2
MAT03919	ALU0654	IA401-B	34.00	81	Failed	35	43	24
MAT03896	ALU0650	IA802-B	39.67	40	Failed	45	40	34
MAT03960	ALU0660	IA406-B	26.00	79	Failed	19	9	50
MAT03907	ALU0652	IA501-B	40.67	45	Failed	56	19	47
MAT03904	ALU0651	IA204-B	24.67	30	Failed	22	24	28
MAT03944	ALU0658	IA802-B	40.00	81	Failed	22	43	55
MAT03947	ALU0658	IA805-B	16.33	54	Failed	30	13	6
MAT03913	ALU0653	IA601-B	34.33	37	Failed	6	49	48
MAT03921	ALU0654	IA403-B	16.33	31	Failed	15	24	10
MAT03924	ALU0654	IA406-B	27.00	34	Failed	18	43	20
MAT03959	ALU0660	IA405-B	35.67	60	Failed	45	36	26
MAT05633	ALU0939	IA105-B	11.00	94	Failed	0	21	12
MAT02409	ALU0402	IA303-A	25.33	49	Failed	52	5	19
MAT01975	ALU0330	IA601-B	26.33	64	Failed	19	29	31
MAT04082	ALU0681	IA602-B	32.00	92	Failed	23	16	57
MAT04097	ALU0683	IA605-B	23.00	71	Failed	5	38	26
MAT04050	ALU0675	IA306-A	13.00	32	Failed	19	19	1
MAT04107	ALU0685	IA203-A	36.33	37	Failed	47	59	3
MAT04057	ALU0677	IA101-B	28.33	92	Failed	23	29	33
MAT04118	ALU0687	IA202-A	38.33	48	Failed	34	53	28
MAT04108	ALU0685	IA204-A	32.00	36	Failed	32	30	34
MAT04048	ALU0675	IA304-A	28.33	61	Failed	8	57	20
MAT04114	ALU0686	IA304-B	42.67	60	Failed	20	55	53
MAT04043	ALU0674	IA305-B	47.67	55	Failed	45	44	54
MAT04120	ALU0687	IA204-A	44.67	38	Failed	27	57	50
MAT04084	ALU0681	IA604-B	40.67	40	Failed	52	55	15
MAT04065	ALU0678	IA203-B	45.00	94	Failed	37	53	45
MAT04113	ALU0686	IA303-B	46.33	49	Failed	51	40	48
MAT04042	ALU0674	IA304-B	33.67	33	Failed	28	30	43
MAT04040	ALU0674	IA302-B	36.00	59	Failed	29	37	42
MAT04049	ALU0675	IA305-A	52.00	45	Failed	56	50	50
MAT04099	ALU0684	IA701-A	17.67	69	Failed	52	1	0
MAT04110	ALU0685	IA206-A	34.00	56	Failed	23	28	51
MAT04085	ALU0681	IA605-B	31.33	62	Failed	20	16	58
MAT04039	ALU0674	IA301-B	19.67	65	Failed	11	38	10
MAT04087	ALU0682	IA401-B	27.33	83	Failed	1	50	31
MAT04089	ALU0682	IA403-B	30.00	66	Failed	28	27	35
MAT04041	ALU0674	IA303-B	21.67	70	Failed	6	57	2
MAT04119	ALU0687	IA203-A	14.67	82	Failed	10	23	11
MAT04109	ALU0685	IA205-A	33.67	91	Failed	3	58	40
MAT04086	ALU0681	IA606-B	33.67	61	Failed	25	56	20
MAT04044	ALU0674	IA306-B	37.00	73	Failed	50	7	54
MAT04105	ALU0685	IA201-A	26.67	65	Failed	33	2	45
MAT04068	ALU0678	IA206-B	27.00	57	Failed	3	50	28
MAT04121	ALU0687	IA205-A	36.33	76	Failed	51	13	45
MAT04137	ALU0690	IA303-B	77.33	88	Approved	64	88	80
MAT04135	ALU0690	IA301-B	82.67	77	Approved	62	100	86
MAT04227	ALU0705	IA203-A	87.00	97	Approved	93	74	94
MAT04225	ALU0705	IA201-A	36.67	80	Failed	52	57	1
MAT04230	ALU0705	IA206-A	32.33	69	Failed	47	25	25
MAT04172	ALU0696	IA702-B	8.33	68	Failed	1	13	11
MAT04219	ALU0704	IA401-B	36.00	51	Failed	23	30	55
MAT04168	ALU0695	IA204-B	16.33	74	Failed	23	4	22
MAT04258	ALU0710	IA704-B	25.00	97	Failed	48	13	14
MAT04175	ALU0696	IA705-B	32.33	40	Failed	47	48	2
MAT04215	ALU0703	IA603-A	44.00	63	Failed	28	58	46
MAT04257	ALU0710	IA703-B	30.33	42	Failed	15	42	34
MAT04260	ALU0710	IA706-B	26.33	48	Failed	27	41	11
MAT04224	ALU0704	IA406-B	21.00	51	Failed	55	5	3
MAT04262	ALU0711	IA502-A	20.33	70	Failed	24	24	13
MAT04267	ALU0712	IA801-A	38.00	32	Failed	23	43	48
MAT04223	ALU0704	IA405-B	37.00	67	Failed	56	14	41
MAT04213	ALU0703	IA601-A	37.67	98	Failed	21	37	55
MAT04214	ALU0703	IA602-A	49.33	30	Failed	52	59	37
MAT04264	ALU0711	IA504-A	15.00	97	Failed	8	16	21
MAT04256	ALU0710	IA702-B	19.00	53	Failed	10	26	21
MAT04261	ALU0711	IA501-A	35.33	58	Failed	20	51	35
MAT04154	ALU0693	IA202-B	40.00	81	Failed	29	39	52
MAT04136	ALU0690	IA302-B	32.00	95	Failed	16	50	30
MAT04173	ALU0696	IA703-B	30.00	37	Failed	33	38	19
MAT04218	ALU0703	IA606-A	33.00	99	Failed	22	39	38
MAT04165	ALU0695	IA201-B	33.67	89	Failed	49	33	19
MAT04229	ALU0705	IA205-A	52.00	76	Failed	59	42	55
MAT04216	ALU0703	IA604-A	39.00	91	Failed	48	47	22
MAT04263	ALU0711	IA503-A	36.33	32	Failed	30	59	20
MAT04180	ALU0697	IA204-B	32.67	58	Failed	40	53	5
MAT04217	ALU0703	IA605-A	23.67	79	Failed	37	25	9
MAT04253	ALU0709	IA305-A	36.00	68	Failed	28	46	34
MAT04266	ALU0711	IA506-A	7.00	92	Failed	6	13	2
MAT04226	ALU0705	IA202-A	30.33	79	Failed	55	4	32
MAT04221	ALU0704	IA403-B	26.33	75	Failed	17	53	9
MAT04176	ALU0696	IA706-B	28.67	90	Failed	27	5	54
MAT04220	ALU0704	IA402-B	38.00	67	Failed	13	42	59
MAT04367	ALU0728	IA405-B	41.00	70	Failed	55	10	58
MAT04354	ALU0726	IA704-B	28.00	98	Failed	41	32	11
MAT04328	ALU0722	IA802-B	6.33	76	Failed	6	5	8
MAT04319	ALU0720	IA705-B	22.00	99	Failed	23	33	10
MAT04376	ALU0730	IA702-A	18.67	37	Failed	4	7	45
MAT04368	ALU0728	IA406-B	27.67	57	Failed	1	46	36
MAT04337	ALU0723	IA205-A	24.33	44	Failed	18	7	48
MAT04381	ALU0731	IA801-B	16.33	83	Failed	8	0	41
MAT04360	ALU0727	IA404-B	21.67	54	Failed	7	51	7
MAT04321	ALU0721	IA201-A	33.67	62	Failed	42	37	22
MAT04357	ALU0727	IA401-B	17.33	50	Failed	41	7	4
MAT04378	ALU0730	IA704-A	22.00	31	Failed	17	10	39
MAT04375	ALU0730	IA701-A	31.67	81	Failed	48	11	36
MAT04379	ALU0730	IA705-A	45.67	53	Failed	29	53	55
MAT04358	ALU0727	IA402-B	23.00	40	Failed	47	5	17
MAT04314	ALU0719	IA806-A	47.00	59	Failed	55	37	49
MAT04352	ALU0726	IA702-B	35.67	49	Failed	22	54	31
MAT04359	ALU0727	IA403-B	29.33	97	Failed	22	48	18
MAT04382	ALU0731	IA802-B	48.33	53	Failed	54	34	57
MAT04312	ALU0719	IA804-A	26.00	80	Failed	6	17	55
MAT04323	ALU0721	IA203-A	31.67	98	Failed	41	14	40
MAT04362	ALU0727	IA406-B	20.67	92	Failed	5	20	37
MAT04361	ALU0727	IA405-B	33.67	64	Failed	52	44	5
MAT04377	ALU0730	IA703-A	49.00	69	Failed	41	53	53
MAT04325	ALU0721	IA205-A	39.33	38	Failed	24	51	43
MAT04349	ALU0725	IA205-B	20.33	46	Failed	14	29	18
MAT04380	ALU0730	IA706-A	19.67	98	Failed	21	12	26
MAT04501	ALU0751	IA601-B	73.33	93	Approved	81	62	77
MAT04523	ALU0754	IA405-A	37.33	51	Failed	48	37	27
MAT04524	ALU0754	IA406-A	46.67	44	Failed	44	57	39
MAT04584	ALU0764	IA406-A	27.67	99	Failed	20	44	19
MAT04487	ALU0748	IA605-B	9.00	49	Failed	3	18	6
MAT04449	ALU0742	IA103-A	35.33	84	Failed	52	37	17
MAT04448	ALU0742	IA102-A	28.67	94	Failed	16	42	28
MAT04551	ALU0759	IA103-B	53.00	79	Failed	58	57	44
MAT04544	ALU0758	IA702-A	23.67	52	Failed	48	12	11
MAT04505	ALU0751	IA605-B	24.00	83	Failed	38	17	17
MAT04520	ALU0754	IA402-A	38.00	90	Failed	25	31	58
MAT04586	ALU0765	IA702-B	47.67	50	Failed	43	50	50
MAT04492	ALU0749	IA404-B	39.33	92	Failed	47	55	16
MAT04496	ALU0750	IA602-B	32.33	46	Failed	39	56	2
MAT04509	ALU0752	IA403-B	35.00	82	Failed	48	30	27
MAT04583	ALU0764	IA405-A	39.67	84	Failed	49	20	50
MAT04485	ALU0748	IA603-B	24.00	99	Failed	17	54	1
MAT04581	ALU0764	IA403-A	29.67	39	Failed	2	42	45
MAT04579	ALU0764	IA401-A	38.67	71	Failed	58	51	7
MAT04452	ALU0742	IA106-A	14.00	48	Failed	20	6	16
MAT04519	ALU0754	IA401-A	32.33	36	Failed	24	44	29
MAT04580	ALU0764	IA402-A	19.33	63	Failed	10	46	2
MAT04493	ALU0749	IA405-B	35.67	84	Failed	8	43	56
MAT04486	ALU0748	IA604-B	19.67	66	Failed	36	22	1
MAT04532	ALU0756	IA802-B	19.33	74	Failed	18	33	7
MAT04463	ALU0744	IA305-B	19.33	80	Failed	5	7	46
MAT04480	ALU0747	IA704-B	45.67	77	Failed	33	46	58
MAT04585	ALU0765	IA701-B	33.33	81	Failed	29	15	56
MAT04556	ALU0760	IA502-B	9.00	78	Failed	8	3	16
MAT04490	ALU0749	IA402-B	23.00	72	Failed	3	36	30
MAT04564	ALU0761	IA704-A	25.67	85	Failed	4	38	35
MAT04549	ALU0759	IA101-B	32.67	77	Failed	22	53	23
MAT04576	ALU0763	IA304-A	21.67	58	Failed	4	54	7
MAT04536	ALU0756	IA806-B	37.67	73	Failed	34	50	29
MAT04557	ALU0760	IA503-B	43.33	65	Failed	58	19	53
MAT04488	ALU0748	IA606-B	44.00	68	Failed	57	54	21
MAT04562	ALU0761	IA702-A	37.00	52	Failed	31	54	26
MAT04541	ALU0757	IA205-A	29.33	35	Failed	47	7	34
MAT04545	ALU0758	IA703-A	43.00	94	Failed	21	59	49
MAT04508	ALU0752	IA402-B	25.00	71	Failed	26	24	25
MAT04548	ALU0758	IA706-A	24.67	88	Failed	44	21	9
MAT04521	ALU0754	IA403-A	14.00	72	Failed	11	9	22
MAT04547	ALU0758	IA705-A	22.00	97	Failed	24	6	36
MAT04590	ALU0765	IA706-B	82.00	97	Approved	63	84	99
MAT04611	ALU0769	IA103-A	73.67	93	Approved	75	63	83
MAT04607	ALU0768	IA605-A	86.00	79	Approved	97	95	66
MAT04707	ALU0785	IA303-A	72.00	91	Approved	86	62	68
MAT04756	ALU0793	IA804-B	73.00	82	Approved	68	67	84
MAT04738	ALU0790	IA104-B	83.00	83	Approved	90	61	98
MAT04622	ALU0771	IA602-A	14.67	35	Failed	13	18	13
MAT04612	ALU0769	IA104-A	37.67	94	Failed	56	44	13
MAT04605	ALU0768	IA603-A	31.33	93	Failed	35	30	29
MAT04613	ALU0769	IA105-A	20.67	81	Failed	59	0	3
MAT04698	ALU0783	IA506-A	45.33	34	Failed	54	55	27
MAT04595	ALU0766	IA105-A	24.00	67	Failed	25	25	22
MAT04600	ALU0767	IA104-B	18.00	39	Failed	8	11	35
MAT04728	ALU0788	IA106-A	32.67	65	Failed	31	29	38
MAT04598	ALU0767	IA102-B	27.33	72	Failed	5	26	51
MAT04609	ALU0769	IA101-A	33.67	84	Failed	39	16	46
MAT04736	ALU0790	IA102-B	36.00	47	Failed	13	45	50
MAT04588	ALU0765	IA704-B	22.33	37	Failed	22	7	38
MAT04604	ALU0768	IA602-A	42.00	70	Failed	35	37	54
MAT04614	ALU0769	IA106-A	19.33	41	Failed	20	3	35
MAT04601	ALU0767	IA105-B	31.33	67	Failed	39	37	18
MAT04706	ALU0785	IA302-A	40.33	44	Failed	39	51	31
MAT04697	ALU0783	IA505-A	30.33	69	Failed	35	24	32
MAT04603	ALU0768	IA601-A	24.33	99	Failed	12	15	46
MAT04615	ALU0770	IA601-B	43.00	86	Failed	48	52	29
MAT04606	ALU0768	IA604-A	29.33	97	Failed	25	12	51
MAT04668	ALU0778	IA706-A	33.67	61	Failed	22	43	36
MAT04682	ALU0781	IA502-A	28.67	37	Failed	12	19	55
MAT04708	ALU0785	IA304-A	50.00	49	Failed	43	59	48
MAT04591	ALU0766	IA101-A	35.00	62	Failed	57	24	24
MAT04755	ALU0793	IA803-B	15.33	69	Failed	14	28	4
MAT04684	ALU0781	IA504-A	26.67	40	Failed	23	21	36
MAT04681	ALU0781	IA501-A	38.00	74	Failed	57	53	4
MAT04593	ALU0766	IA103-A	33.00	38	Failed	50	43	6
MAT04683	ALU0781	IA503-A	15.00	64	Failed	21	1	23
MAT04592	ALU0766	IA102-A	25.33	82	Failed	47	12	17
MAT04694	ALU0783	IA502-A	32.67	77	Failed	20	50	28
MAT04685	ALU0781	IA505-A	33.33	44	Failed	47	53	0
MAT04608	ALU0768	IA606-A	54.33	39	Failed	52	57	54
MAT04686	ALU0781	IA506-A	32.00	70	Failed	33	7	56
MAT04587	ALU0765	IA703-B	38.33	45	Failed	2	57	56
MAT04616	ALU0770	IA602-B	46.33	80	Failed	59	51	29
MAT04740	ALU0790	IA106-B	69.67	85	Approved	77	62	70
MAT04816	ALU0803	IA804-B	81.00	91	Approved	67	93	83
MAT04768	ALU0795	IA504-B	79.33	94	Approved	87	70	81
MAT04811	ALU0802	IA805-B	76.67	76	Approved	79	61	90
MAT04778	ALU0797	IA702-A	16.67	75	Failed	22	25	3
MAT04807	ALU0802	IA801-B	43.00	82	Failed	37	35	57
MAT04810	ALU0802	IA804-B	27.33	86	Failed	34	39	9
MAT04750	ALU0792	IA604-B	33.00	56	Failed	54	2	43
MAT04803	ALU0801	IA403-B	45.67	48	Failed	23	57	57
MAT04758	ALU0793	IA806-B	27.33	75	Failed	12	37	33
MAT04804	ALU0801	IA404-B	33.67	54	Failed	32	49	20
MAT04704	ALU0784	IA406-A	35.00	97	Failed	7	47	51
MAT04780	ALU0797	IA704-A	25.67	36	Failed	18	17	42
MAT04809	ALU0802	IA803-B	38.33	100	Failed	30	56	29
MAT04739	ALU0790	IA105-B	39.33	69	Failed	55	40	23
MAT04744	ALU0791	IA104-A	34.33	35	Failed	34	11	58
MAT04774	ALU0796	IA704-A	32.33	86	Failed	48	39	10
MAT04737	ALU0790	IA103-B	31.67	94	Failed	25	46	24
MAT04805	ALU0801	IA405-B	23.00	46	Failed	4	38	27
MAT04815	ALU0803	IA803-B	32.33	48	Failed	40	36	21
MAT04783	ALU0798	IA601-B	27.00	69	Failed	11	34	36
MAT04703	ALU0784	IA405-A	22.33	36	Failed	11	54	2
MAT04746	ALU0791	IA106-A	44.33	54	Failed	42	53	38
MAT04808	ALU0802	IA802-B	23.67	67	Failed	24	8	39
MAT04741	ALU0791	IA101-A	16.67	70	Failed	3	29	18
MAT04813	ALU0803	IA801-B	37.33	40	Failed	52	8	52
MAT04735	ALU0790	IA101-B	37.67	66	Failed	44	22	47
MAT04776	ALU0796	IA706-A	18.67	33	Failed	24	21	11
MAT04742	ALU0791	IA102-A	29.67	52	Failed	23	35	31
MAT04800	ALU0800	IA606-B	30.00	34	Failed	30	21	39
MAT04814	ALU0803	IA802-B	36.33	86	Failed	9	59	41
MAT04699	ALU0784	IA401-A	20.33	30	Failed	6	20	35
MAT04773	ALU0796	IA703-A	32.67	69	Failed	53	0	45
MAT05831	ALU0972	IA305-A	81.33	81	Approved	79	76	89
MAT05884	ALU0981	IA604-B	82.00	85	Approved	92	94	60
MAT05850	ALU0975	IA406-B	15.00	70	Failed	26	19	0
MAT05891	ALU0982	IA205-B	25.00	71	Failed	44	20	11
MAT05875	ALU0980	IA201-B	16.33	99	Failed	6	14	29
MAT05832	ALU0972	IA306-A	21.33	89	Failed	3	33	28
MAT05848	ALU0975	IA404-B	37.67	65	Failed	29	53	31
MAT05864	ALU0978	IA702-A	27.33	69	Failed	32	42	8
MAT05930	ALU0989	IA502-A	25.67	40	Failed	28	40	9
MAT05867	ALU0978	IA705-A	42.33	86	Failed	50	34	43
MAT05880	ALU0980	IA206-B	28.00	89	Failed	22	20	42
MAT05886	ALU0981	IA606-B	32.67	33	Failed	50	21	27
MAT05877	ALU0980	IA203-B	31.67	90	Failed	30	58	7
MAT05883	ALU0981	IA603-B	27.67	94	Failed	20	53	10
MAT05859	ALU0977	IA103-B	27.67	89	Failed	0	47	36
MAT05889	ALU0982	IA203-B	34.00	33	Failed	32	28	42
MAT05860	ALU0977	IA104-B	41.33	64	Failed	57	34	33
MAT05878	ALU0980	IA204-B	29.67	81	Failed	19	54	16
MAT05865	ALU0978	IA703-A	32.00	51	Failed	21	19	56
MAT05868	ALU0978	IA706-A	31.00	86	Failed	13	52	28
MAT05917	ALU0987	IA501-A	33.00	44	Failed	55	40	4
MAT05929	ALU0989	IA501-A	25.67	96	Failed	39	27	11
MAT05866	ALU0978	IA704-A	22.33	84	Failed	46	11	10
MAT05888	ALU0982	IA202-B	30.67	90	Failed	38	9	45
MAT05913	ALU0986	IA603-B	45.00	59	Failed	46	45	44
MAT05881	ALU0981	IA601-B	28.67	86	Failed	8	32	46
MAT05833	ALU0973	IA401-A	20.00	30	Failed	30	19	11
MAT05914	ALU0986	IA604-B	40.33	91	Failed	22	49	50
MAT05890	ALU0982	IA204-B	26.00	59	Failed	25	10	43
MAT05920	ALU0987	IA504-A	17.67	56	Failed	6	45	2
MAT01258	ALU0210	IA204-B	48.00	91	Failed	55	32	57
MAT04170	ALU0695	IA206-B	17.33	73	Failed	25	24	3
MAT04888	ALU0815	IA204-A	15.67	88	Failed	2	14	31
MAT00044	ALU0008	IA202-A	82.00	100	Approved	92	93	61
MAT00045	ALU0008	IA203-A	18.33	85	Failed	36	12	7
MAT00016	ALU0003	IA304-B	43.00	71	Failed	53	33	43
MAT00015	ALU0003	IA303-B	30.00	95	Failed	23	33	34
MAT00033	ALU0006	IA103-A	30.00	99	Failed	25	24	41
MAT00043	ALU0008	IA201-A	19.67	32	Failed	41	12	6
MAT00021	ALU0004	IA703-A	34.33	100	Failed	36	40	27
MAT00017	ALU0003	IA305-B	31.67	84	Failed	17	47	31
MAT00024	ALU0004	IA706-A	31.67	88	Failed	13	59	23
MAT00041	ALU0007	IA505-B	38.00	33	Failed	52	43	19
MAT00055	ALU0010	IA701-A	54.00	71	Failed	58	46	58
MAT01141	ALU0191	IA601-A	81.00	78	Approved	71	89	83
MAT00096	ALU0016	IA206-A	30.00	84	Failed	12	37	41
MAT00123	ALU0021	IA103-B	32.00	86	Failed	27	16	53
MAT00119	ALU0020	IA705-B	29.33	87	Failed	45	24	19
MAT00105	ALU0018	IA603-B	42.33	56	Failed	21	52	54
MAT00129	ALU0022	IA403-A	22.00	86	Failed	28	23	15
MAT00135	ALU0023	IA603-A	7.67	51	Failed	19	2	2
MAT00089	ALU0015	IA205-B	40.00	66	Failed	27	45	48
MAT00103	ALU0018	IA601-B	16.00	42	Failed	13	21	14
MAT00121	ALU0021	IA101-B	29.33	31	Failed	44	20	24
MAT00100	ALU0017	IA504-B	45.00	63	Failed	57	28	50
MAT00098	ALU0017	IA502-B	38.67	89	Failed	55	14	47
MAT00133	ALU0023	IA601-A	21.00	84	Failed	5	45	13
MAT00126	ALU0021	IA106-B	31.33	65	Failed	15	46	33
MAT00057	ALU0010	IA703-A	18.33	63	Failed	28	8	19
MAT00048	ALU0008	IA206-A	31.00	40	Failed	10	35	48
MAT00095	ALU0016	IA205-A	32.00	51	Failed	30	42	24
MAT00092	ALU0016	IA202-A	30.67	57	Failed	35	11	46
MAT00108	ALU0018	IA606-B	25.00	31	Failed	20	46	9
MAT00063	ALU0011	IA103-A	45.67	78	Failed	39	43	55
MAT00120	ALU0020	IA706-B	28.33	96	Failed	55	5	25
MAT00132	ALU0022	IA406-A	26.33	60	Failed	46	24	9
MAT00104	ALU0018	IA602-B	29.33	78	Failed	49	29	10
MAT00047	ALU0008	IA205-A	25.33	83	Failed	23	32	21
MAT00124	ALU0021	IA104-B	25.33	62	Failed	23	5	48
MAT00134	ALU0023	IA602-A	43.00	83	Failed	47	23	59
MAT00090	ALU0015	IA206-B	27.33	92	Failed	2	40	40
MAT00099	ALU0017	IA503-B	23.00	36	Failed	13	25	31
MAT00122	ALU0021	IA102-B	12.67	55	Failed	0	9	29
MAT00130	ALU0022	IA404-A	33.67	43	Failed	46	29	26
MAT00081	ALU0014	IA303-B	38.67	82	Failed	34	27	55
MAT00102	ALU0017	IA506-B	15.33	95	Failed	24	5	17
MAT00101	ALU0017	IA505-B	39.00	55	Failed	36	59	22
MAT00094	ALU0016	IA204-A	32.00	92	Failed	35	59	2
MAT00157	ALU0027	IA201-B	8.67	94	Failed	17	6	3
MAT00222	ALU0037	IA306-B	28.33	77	Failed	27	38	20
MAT00231	ALU0039	IA203-B	23.33	39	Failed	53	6	11
MAT00181	ALU0031	IA601-B	27.00	54	Failed	58	12	11
MAT00139	ALU0024	IA201-B	16.33	62	Failed	42	3	4
MAT00327	ALU0055	IA203-A	48.33	54	Failed	55	51	39
MAT00553	ALU0093	IA401-A	32.00	80	Failed	40	0	56
MAT00427	ALU0072	IA401-B	21.00	89	Failed	6	43	14
MAT00511	ALU0086	IA801-A	26.33	98	Failed	1	28	50
MAT00562	ALU0094	IA604-A	29.33	59	Failed	34	24	30
MAT00660	ALU0110	IA206-B	95.67	77	Approved	99	89	99
MAT00687	ALU0115	IA303-A	15.33	44	Failed	17	21	8
MAT00755	ALU0126	IA705-B	22.00	50	Failed	40	0	26
MAT00661	ALU0111	IA801-A	30.00	89	Failed	28	21	41
MAT00787	ALU0132	IA601-B	76.67	77	Approved	65	89	76
MAT00808	ALU0135	IA304-B	36.67	81	Failed	54	22	34
MAT00789	ALU0132	IA603-B	35.33	61	Failed	28	49	29
MAT00853	ALU0143	IA201-A	33.67	63	Failed	19	49	33
MAT00830	ALU0139	IA502-B	30.33	94	Failed	33	26	32
MAT01008	ALU0168	IA406-A	35.00	92	Failed	51	38	16
MAT00963	ALU0161	IA203-B	32.33	69	Failed	27	44	26
MAT01122	ALU0187	IA106-B	26.67	42	Failed	30	42	8
MAT01167	ALU0195	IA303-B	30.67	81	Failed	15	33	44
MAT01186	ALU0198	IA404-A	30.33	79	Failed	4	50	37
MAT01067	ALU0178	IA605-B	33.00	85	Failed	47	20	32
MAT01080	ALU0180	IA506-B	12.67	46	Failed	11	2	25
MAT01219	ALU0204	IA801-B	25.33	30	Failed	41	3	32
MAT01278	ALU0213	IA206-B	25.00	31	Failed	13	34	28
MAT01208	ALU0202	IA602-B	46.00	35	Failed	56	55	27
MAT01389	ALU0232	IA403-B	22.33	50	Failed	52	6	9
MAT01418	ALU0237	IA302-B	26.00	46	Failed	38	27	13
MAT01603	ALU0268	IA201-B	33.33	49	Failed	25	52	23
MAT01544	ALU0258	IA102-B	47.67	93	Failed	42	46	55
MAT01499	ALU0250	IA305-B	34.33	34	Failed	55	4	44
MAT01734	ALU0289	IA406-B	28.67	80	Failed	32	15	39
MAT01779	ALU0297	IA803-B	37.33	41	Failed	18	41	53
MAT01755	ALU0293	IA803-B	47.67	69	Failed	37	58	48
MAT01660	ALU0277	IA104-A	43.33	96	Failed	57	26	47
MAT01873	ALU0313	IA801-A	78.00	84	Approved	98	67	69
MAT01849	ALU0309	IA101-B	27.67	64	Failed	34	14	35
MAT02049	ALU0342	IA203-A	83.00	91	Approved	99	88	62
MAT01985	ALU0331	IA405-A	24.00	88	Failed	0	21	51
MAT01957	ALU0327	IA101-A	43.67	33	Failed	38	46	47
MAT01960	ALU0327	IA104-A	28.67	65	Failed	14	58	14
MAT02134	ALU0356	IA804-B	92.67	86	Approved	86	93	99
MAT02074	ALU0346	IA704-B	28.00	61	Failed	57	26	1
MAT02224	ALU0371	IA704-B	38.33	56	Failed	36	52	27
MAT02215	ALU0370	IA601-B	32.00	96	Failed	52	20	24
MAT02337	ALU0390	IA703-B	26.33	87	Failed	18	44	17
MAT02264	ALU0378	IA602-B	37.00	73	Failed	59	21	31
MAT02242	ALU0374	IA304-B	31.00	78	Failed	47	39	7
MAT02513	ALU0419	IA505-B	71.33	99	Approved	61	60	93
MAT02495	ALU0416	IA805-B	30.33	47	Failed	19	26	46
MAT02428	ALU0405	IA804-A	41.00	96	Failed	19	57	47
MAT02555	ALU0426	IA505-B	49.00	50	Failed	45	51	51
MAT02591	ALU0432	IA205-A	43.67	43	Failed	42	38	51
MAT02809	ALU0469	IA601-B	48.00	81	Failed	37	52	55
MAT02732	ALU0456	IA602-A	21.00	48	Failed	30	12	21
MAT02918	ALU0487	IA802-B	34.67	88	Failed	18	40	46
MAT02889	ALU0482	IA803-B	30.67	81	Failed	2	31	59
MAT02919	ALU0487	IA803-B	42.33	50	Failed	29	43	55
MAT02921	ALU0487	IA805-B	34.67	85	Failed	28	53	23
MAT03077	ALU0513	IA205-A	82.67	99	Approved	62	90	96
MAT03159	ALU0527	IA203-A	81.33	89	Approved	61	94	89
MAT03147	ALU0525	IA803-A	74.00	83	Approved	66	92	64
MAT03242	ALU0541	IA602-A	37.00	90	Failed	36	56	19
MAT03118	ALU0520	IA304-A	46.00	63	Failed	41	54	43
MAT03174	ALU0529	IA206-B	34.00	95	Failed	38	30	34
MAT03361	ALU0561	IA801-B	16.33	61	Failed	26	3	20
MAT03313	ALU0553	IA801-A	16.33	50	Failed	5	11	33
MAT03608	ALU0602	IA502-A	79.33	91	Approved	87	76	75
MAT03704	ALU0618	IA202-B	54.00	32	Failed	58	56	48
MAT03900	ALU0650	IA806-B	80.33	76	Approved	86	78	77
MAT03897	ALU0650	IA803-B	45.67	33	Failed	46	55	36
MAT03851	ALU0642	IA405-B	38.00	75	Failed	32	46	36
MAT04014	ALU0669	IA306-A	34.00	79	Failed	34	49	19
MAT03911	ALU0652	IA505-B	39.00	99	Failed	40	44	33
MAT04125	ALU0688	IA303-B	80.33	99	Approved	79	90	72
MAT04083	ALU0681	IA603-B	38.67	32	Failed	26	54	36
MAT04209	ALU0702	IA803-B	16.33	82	Failed	6	41	2
MAT04171	ALU0696	IA701-B	22.00	50	Failed	39	0	27
MAT04188	ALU0698	IA606-B	33.33	66	Failed	29	22	49
MAT04356	ALU0726	IA706-B	87.33	97	Approved	90	79	93
MAT04341	ALU0724	IA403-B	32.00	44	Failed	59	18	19
MAT04306	ALU0718	IA704-A	34.67	78	Failed	30	27	47
MAT04454	ALU0743	IA502-A	30.33	94	Failed	34	54	3
MAT04434	ALU0739	IA106-A	36.00	100	Failed	51	12	45
MAT04433	ALU0739	IA105-A	26.67	85	Failed	6	56	18
MAT04566	ALU0761	IA706-A	34.00	81	Failed	11	41	50
MAT04543	ALU0758	IA701-A	28.67	44	Failed	36	23	27
MAT04786	ALU0798	IA604-B	32.00	91	Failed	28	41	27
MAT04676	ALU0780	IA502-A	16.33	45	Failed	11	20	18
MAT04919	ALU0820	IA205-A	17.00	50	Failed	39	9	3
MAT04967	ALU0828	IA805-B	34.00	75	Failed	0	52	50
MAT05047	ALU0842	IA501-B	22.33	98	Failed	2	10	55
MAT05180	ALU0864	IA102-A	85.67	81	Approved	86	94	77
MAT05205	ALU0868	IA303-B	28.00	87	Failed	28	6	50
MAT05435	ALU0906	IA105-B	20.67	32	Failed	56	0	6
MAT05429	ALU0905	IA205-B	26.67	84	Failed	37	43	0
MAT05351	ALU0892	IA405-B	33.00	31	Failed	21	19	59
MAT05385	ALU0898	IA103-B	4.67	46	Failed	3	8	3
MAT05302	ALU0884	IA604-A	28.67	98	Failed	11	32	43
MAT05519	ALU0920	IA805-A	23.00	74	Failed	3	59	7
MAT05651	ALU0942	IA705-B	15.67	67	Failed	3	26	18
MAT05751	ALU0959	IA603-B	29.33	38	Failed	18	11	59
MAT05919	ALU0987	IA503-A	31.00	86	Failed	44	39	10
MAT05993	ALU0999	IA805-A	86.33	98	Approved	82	91	86
MAT05994	ALU0999	IA806-A	79.33	90	Approved	67	86	85
MAT05984	ALU0998	IA702-B	30.67	39	Failed	12	25	55
MAT05981	ALU0997	IA205-A	27.00	50	Failed	23	47	11
MAT05980	ALU0997	IA204-A	20.67	42	Failed	27	6	29
MAT05983	ALU0998	IA701-B	38.67	97	Failed	57	15	44
MAT05989	ALU0999	IA801-A	30.00	69	Failed	34	50	6
MAT05987	ALU0998	IA705-B	45.33	55	Failed	53	51	32
MAT05992	ALU0999	IA804-A	42.33	59	Failed	57	53	17
MAT05990	ALU0999	IA802-A	30.67	31	Failed	43	12	37
MAT05997	ALU1000	IA103-A	18.67	67	Failed	33	6	17
MAT05979	ALU0997	IA203-A	30.00	44	Failed	22	22	46
MAT05982	ALU0997	IA206-A	8.33	76	Failed	9	1	15
MAT05991	ALU0999	IA803-A	19.67	96	Failed	23	7	29
MAT05998	ALU1000	IA104-A	23.33	90	Failed	46	20	4
MAT05995	ALU1000	IA101-A	32.00	53	Failed	29	59	8
MAT06000	ALU1000	IA106-A	25.67	50	Failed	46	28	3
MAT05988	ALU0998	IA706-B	27.33	76	Failed	45	10	27
MAT05977	ALU0997	IA201-A	42.00	92	Failed	28	41	57
\.

COPY public.professors (id_professor, name, degree, expertise_area, work_regime, institutional_email, hire_date) FROM stdin;
PROF001	Ricardo Almeida Prado	Specialization	Programming	Full-time	ricardo.prado@docente.uma.example	2008-08-01
PROF002	Fernanda Lopes Teixeira	PhD	Programming	Full-time	fernanda.teixeira@docente.uma.example	2012-02-01
PROF003	Marcos Vinícius Rocha	Specialization	Programming	Full-time	marcos.rocha@docente.uma.example	2021-02-01
PROF004	Patrícia Nunes Barros	PhD	Programming	Full-time	patricia.barros@docente.uma.example	2014-02-01
PROF005	Helena Duarte Campos	Master's	Mathematics and Statistics	Full-time	helena.campos@docente.uma.example	2014-08-01
PROF006	Eduardo Siqueira Melo	PhD	Mathematics and Statistics	Hourly	eduardo.melo@docente.uma.example	2016-02-01
PROF007	Luciana Freitas Moura	PhD	Mathematics and Statistics	Hourly	luciana.moura@docente.uma.example	2018-08-01
PROF008	Rogério Batista Lima	PhD	Mathematics and Statistics	Full-time	rogerio.lima@docente.uma.example	2018-02-01
PROF009	Juliana Castro Reis	PhD	Artificial Intelligence	Hourly	juliana.reis@docente.uma.example	2011-08-01
PROF010	André Luiz Monteiro	Master's	Artificial Intelligence	Part-time	andre.monteiro@docente.uma.example	2009-08-01
PROF011	Carolina Vieira Paiva	Master's	Artificial Intelligence	Full-time	carolina.paiva@docente.uma.example	2020-02-01
PROF012	Thiago Moreira Dias	Master's	Artificial Intelligence	Part-time	thiago.dias@docente.uma.example	2019-02-01
PROF013	Renata Cardoso Pires	Specialization	Data	Full-time	renata.pires@docente.uma.example	2009-02-01
PROF014	Gustavo Henrique Brito	Master's	Data	Full-time	gustavo.brito@docente.uma.example	2015-02-01
PROF015	Aline Correia Fonseca	PhD	Data	Part-time	aline.fonseca@docente.uma.example	2022-08-01
PROF016	Leandro Pacheco Souto	PhD	Data	Part-time	leandro.souto@docente.uma.example	2019-02-01
PROF017	Sérgio Antunes Farias	Specialization	Systems and Infrastructure	Part-time	sergio.farias@docente.uma.example	2010-02-01
PROF018	Mariana Queiroz Leal	Master's	Systems and Infrastructure	Full-time	mariana.leal@docente.uma.example	2013-08-01
PROF019	Daniel Ferraz Coelho	PhD	Systems and Infrastructure	Part-time	daniel.coelho@docente.uma.example	2015-08-01
PROF020	Vanessa Rezende Cunha	PhD	Systems and Infrastructure	Full-time	vanessa.cunha@docente.uma.example	2009-08-01
PROF021	Cláudia Matos Ventura	PhD	Humanities and Management	Part-time	claudia.ventura@docente.uma.example	2010-02-01
PROF022	Paulo Roberto Sales	Master's	Humanities and Management	Part-time	paulo.sales@docente.uma.example	2014-08-01
PROF023	Beatriz Fontes Amaral	PhD	Humanities and Management	Hourly	beatriz.amaral@docente.uma.example	2012-08-01
PROF024	Fábio Torres Medeiros	PhD	Humanities and Management	Full-time	fabio.medeiros@docente.uma.example	2016-08-01
\.

COPY public.risk_rules (rule_id, rule, condition, points, interpretation) FROM stdin;
REG01	low_grade	current_average < 6	15	Critical academic indicator
REG02	low_attendance	attendance_pct < 75	15	Risk of failure/lack of engagement
REG03	performance_drop	average_trend <= -1	10	Relevant drop vs. previous period
REG04	failures	failed_subjects_history >= 2	10	Repeating subjects
REG05	pending_items	pending_activities >= 4	8	Accumulated activities
REG06	finance	per_capita_income < 1500	10	Possible need for support
REG07	working_hours	daily_work_hours >= 8 and weekly_study_hours < 7	8	Unfavorable work-study balance
REG08	commute	distance_km >= 20 or commute_time_min >= 90	10	Relevant commute
REG09	responsibilities	weekly_family_responsibilities_h >= 12	6	Relevant family load
REG10	support	requested_psychosocial_support = Yes	4	Sign of a need for welcoming support; not a diagnosis
REG11	bands	0-19 low; 20-34 moderate; 35-54 high; 55+ critical	-	Individual screening; not a dropout verdict
\.

COPY public.socioeconomic (student_id, monthly_family_income, household_residents, per_capita_income, scholarship_aid, works, daily_work_hours, weekly_study_hours, weekly_family_responsibilities_h, distance_km, commute_time_min, transport_mode, prouni, fies, employee_discount) FROM stdin;
ALU0268	2975	5	595.0	yes	Full time	8	2.2	0	11.7	65	Car	yes	no	no
ALU0101	3890	3	1296.67	yes	Part time	6	6.3	8	6.6	36	Bus	yes	no	no
ALU0622	4121	1	4121.0	yes	Full time	8	5.3	4	20.5	121	Motorcycle	yes	no	no
ALU0954	901	4	225.25	yes	Part time	6	6.4	8	7.0	29	Bus	yes	no	no
ALU0454	3264	4	816.0	yes	Full time	8	6.0	12	16.3	87	Bicycle	yes	no	no
ALU0456	2514	5	502.8	yes	Does not work	0	7.3	4	21.0	121	Bus	yes	no	no
ALU0019	1355	5	271.0	yes	Full time	8	6.0	0	12.3	49	Car	yes	no	no
ALU0968	3430	1	3430.0	yes	Full time	8	4.8	4	21.2	87	Motorcycle	yes	no	no
ALU0849	1550	4	387.5	yes	Does not work	0	10.1	0	8.4	34	Bicycle	yes	no	no
ALU0936	4347	3	1449.0	yes	Does not work	0	9.8	0	30.6	138	Car	yes	no	no
ALU0951	2341	2	1170.5	yes	Part time	6	8.2	12	9.2	47	Bus	yes	no	no
ALU0215	2651	5	530.2	yes	Does not work	0	8.7	4	4.8	26	Bus	yes	no	no
ALU0531	5343	3	1781.0	yes	Part time	6	6.3	0	10.9	60	Bus	yes	no	no
ALU0471	2017	2	1008.5	yes	Does not work	0	12.1	0	5.1	26	Bus	yes	no	no
ALU0649	7523	5	1504.6	yes	Full time	8	4.0	8	4.6	21	Bus	yes	no	no
ALU0638	6518	2	3259.0	yes	Does not work	0	11.6	4	10.8	59	Motorcycle	yes	no	no
ALU0303	1807	4	451.75	yes	Full time	8	8.1	4	13.4	72	Car	yes	no	no
ALU0859	1556	6	259.33	yes	Does not work	0	10.5	0	2.6	12	Ride app	yes	no	no
ALU0189	2456	5	491.2	yes	Does not work	0	16.1	8	23.4	100	On foot	yes	no	no
ALU0483	810	6	135.0	yes	Part time	6	2.7	0	5.4	21	Motorcycle	yes	no	no
ALU0312	3860	4	965.0	yes	Does not work	0	11.2	12	7.9	35	Bus	yes	no	no
ALU0832	3348	4	837.0	yes	Does not work	0	8.0	0	5.6	31	Motorcycle	yes	no	no
ALU0333	3358	1	3358.0	yes	Does not work	0	14.5	4	13.5	54	Bus	yes	no	no
ALU0266	3519	2	1759.5	yes	Part time	6	8.6	4	6.1	32	Ride app	yes	no	no
ALU0338	2150	1	2150.0	yes	Full time	8	9.4	4	19.2	89	Bus	yes	no	no
ALU0696	3868	1	3868.0	yes	Does not work	0	11.2	8	6.3	25	Bus	yes	no	no
ALU0201	2867	3	955.67	yes	Does not work	0	11.9	12	6.4	38	Car	yes	no	no
ALU0417	2719	3	906.33	yes	Part time	6	6.7	0	13.1	74	Bus	yes	no	no
ALU0502	2734	4	683.5	yes	Full time	8	7.6	8	5.9	34	Bus	yes	no	no
ALU0228	1028	2	514.0	yes	Full time	8	9.2	0	10.1	59	Ride app	yes	no	no
ALU0774	4424	6	737.33	yes	Does not work	0	12.3	12	5.8	30	Motorcycle	yes	no	no
ALU0927	10476	2	5238.0	yes	Full time	8	5.3	0	2.0	8	Bus	yes	no	no
ALU0956	2244	6	374.0	yes	Part time	6	10.3	0	22.8	104	Bus	yes	no	no
ALU0523	1676	2	838.0	yes	Does not work	0	9.9	4	5.8	25	Motorcycle	yes	no	no
ALU0314	1412	2	706.0	yes	Full time	8	6.7	12	3.7	19	Motorcycle	yes	no	no
ALU0238	1414	1	1414.0	yes	Does not work	0	11.6	4	7.1	34	Bus	yes	no	no
ALU0881	3063	3	1021.0	yes	Does not work	0	10.0	8	7.4	43	Bus	yes	no	no
ALU0167	3942	1	3942.0	yes	Part time	6	10.6	12	4.0	19	Car	yes	no	no
ALU0480	4166	3	1388.67	yes	Does not work	0	14.2	0	3.4	14	Bicycle	yes	no	no
ALU0808	4435	4	1108.75	yes	Part time	6	12.7	8	7.8	38	Car	yes	no	no
ALU0347	1872	5	374.4	yes	Full time	8	7.7	0	14.8	78	Ride app	yes	no	no
ALU0154	1772	2	886.0	yes	Part time	6	9.6	16	2.5	14	Car	yes	no	no
ALU0132	5236	3	1745.33	yes	Part time	6	10.6	8	10.6	47	Bicycle	yes	no	no
ALU0571	4747	1	4747.0	yes	Does not work	0	10.3	12	3.1	15	Bus	yes	no	no
ALU0407	1828	5	365.6	yes	Full time	8	2.2	4	5.7	23	Bus	yes	no	no
ALU0123	3241	1	3241.0	yes	Full time	8	6.7	0	7.0	41	Ride app	yes	no	no
ALU0673	6181	6	1030.17	yes	Does not work	0	8.7	0	10.8	47	Bus	yes	no	no
ALU0699	1996	3	665.33	yes	Does not work	0	8.8	0	23.4	106	Motorcycle	yes	no	no
ALU0329	3254	2	1627.0	yes	Does not work	0	9.9	0	10.8	61	Bus	yes	no	no
ALU0770	1390	2	695.0	yes	Part time	6	11.9	0	19.9	87	Car	yes	no	no
ALU0712	1954	4	488.5	yes	Part time	6	7.7	8	7.9	40	Bus	yes	no	no
ALU0404	6274	5	1254.8	yes	Does not work	0	13.2	0	9.1	43	Bus	yes	no	no
ALU0485	1192	2	596.0	yes	Full time	8	7.8	16	14.7	67	Bicycle	yes	no	no
ALU0392	2461	1	2461.0	yes	Does not work	0	11.2	20	17.8	95	Motorcycle	yes	no	no
ALU0060	1428	6	238.0	yes	Does not work	0	8.4	0	10.8	43	Bus	yes	no	no
ALU0250	1447	4	361.75	yes	Part time	6	6.2	8	1.5	6	Car	yes	no	no
ALU0703	5265	3	1755.0	yes	Part time	6	3.6	16	18.9	92	Bus	yes	no	no
ALU0367	2340	3	780.0	yes	Part time	6	10.7	4	13.5	59	Motorcycle	yes	no	no
ALU0846	2358	3	786.0	yes	Does not work	0	16.1	4	14.0	73	Bus	yes	no	no
ALU0071	2393	1	2393.0	yes	Part time	6	13.9	20	8.0	40	Ride app	yes	no	no
ALU0704	1819	2	909.5	yes	Full time	8	7.1	4	27.1	158	Ride app	yes	no	no
ALU0544	3268	5	653.6	yes	Does not work	0	10.9	16	14.4	81	Bus	yes	no	no
ALU0988	3713	6	618.83	yes	Does not work	0	6.7	8	6.0	35	Car	yes	no	no
ALU0984	1683	1	1683.0	yes	Full time	8	5.8	8	3.8	17	Motorcycle	yes	no	no
ALU0496	1534	2	767.0	yes	Does not work	0	10.3	0	4.0	23	Motorcycle	yes	no	no
ALU0079	3186	3	1062.0	yes	Full time	8	6.0	0	6.0	27	Ride app	yes	no	no
ALU0584	1499	3	499.67	yes	Does not work	0	13.8	0	14.1	77	Bus	yes	no	no
ALU0518	2619	6	436.5	yes	Part time	6	6.3	0	4.0	22	Ride app	yes	no	no
ALU0878	2298	6	383.0	yes	Does not work	0	9.0	4	29.7	120	Motorcycle	yes	no	no
ALU0194	2030	5	406.0	yes	Does not work	0	13.0	0	9.9	57	Ride app	yes	no	no
ALU0741	1793	6	298.83	yes	Does not work	0	11.4	20	16.8	96	Car	yes	no	no
ALU0355	1669	6	278.17	yes	Does not work	0	11.1	4	19.0	78	Bus	yes	no	no
ALU0223	2148	4	537.0	yes	Full time	8	9.6	4	11.1	60	Ride app	yes	no	no
ALU0552	1910	5	382.0	yes	Full time	8	10.0	8	8.4	40	Car	yes	no	no
ALU0376	7606	2	3803.0	yes	Does not work	0	4.8	16	5.6	32	Bus	yes	no	no
ALU1000	3283	1	3283.0	yes	Does not work	0	8.4	4	16.7	84	Bus	yes	no	no
ALU0530	3294	2	1647.0	yes	Full time	8	8.1	0	10.0	53	Car	yes	no	no
ALU0251	4295	3	1431.67	yes	Does not work	0	10.0	0	3.1	12	Bus	yes	no	no
ALU0326	2881	1	2881.0	yes	Does not work	0	17.8	0	2.9	16	On foot	yes	no	no
ALU0935	3267	2	1633.5	yes	Does not work	0	9.9	16	8.1	41	Motorcycle	yes	no	no
ALU0742	4663	3	1554.33	yes	Part time	6	5.3	0	10.8	49	Car	yes	no	no
ALU0902	5120	3	1706.67	yes	Part time	6	8.3	16	13.9	77	Bus	yes	no	no
ALU0513	3130	4	782.5	yes	Part time	6	7.7	20	8.2	47	Bicycle	yes	no	no
ALU0033	4006	6	667.67	yes	Part time	6	4.7	0	13.4	59	Car	yes	no	no
ALU0179	3617	2	1808.5	yes	Part time	6	11.8	8	55.0	180	Bus	yes	no	no
ALU0466	1617	2	808.5	yes	Does not work	0	10.5	12	19.9	115	Bus	yes	no	no
ALU0917	5752	6	958.67	yes	Does not work	0	9.6	0	18.8	87	Bus	yes	no	no
ALU0034	2433	1	2433.0	yes	Part time	6	9.3	16	3.8	21	Motorcycle	yes	no	no
ALU0724	4987	4	1246.75	yes	Full time	8	11.7	16	14.2	72	Motorcycle	yes	no	no
ALU0538	1238	2	619.0	yes	Does not work	0	8.2	4	5.5	26	Motorcycle	yes	no	no
ALU0069	3281	5	656.2	yes	Does not work	0	15.7	0	11.4	67	Bus	yes	no	no
ALU0874	6757	5	1351.4	yes	Does not work	0	3.5	4	2.2	12	Car	yes	no	no
ALU0922	2446	4	611.5	yes	Part time	6	9.5	12	7.5	40	Ride app	yes	no	no
ALU0615	4264	4	1066.0	yes	Full time	8	6.5	4	5.5	29	Bus	yes	no	no
ALU0634	1816	3	605.33	yes	Does not work	0	13.0	0	4.4	26	Motorcycle	yes	no	no
ALU0269	3369	6	561.5	yes	Part time	6	10.2	4	12.2	63	Motorcycle	yes	no	no
ALU0325	6023	1	6023.0	yes	Does not work	0	7.9	8	10.1	46	On foot	yes	no	no
ALU0027	1701	4	425.25	yes	Does not work	0	8.7	0	12.7	52	Car	yes	no	no
ALU0099	4280	6	713.33	yes	Does not work	0	12.3	16	6.8	30	Bus	yes	no	no
ALU0933	4924	3	1641.33	yes	Does not work	0	15.6	0	7.2	35	Ride app	yes	no	no
ALU0005	8346	1	8346.0	yes	Full time	8	5.2	12	8.5	39	Bicycle	no	yes	no
ALU0226	1067	3	355.67	yes	Does not work	0	13.5	4	4.3	18	Car	no	yes	no
ALU0294	1568	2	784.0	yes	Does not work	0	11.0	4	6.8	33	Bicycle	no	yes	no
ALU0479	6440	4	1610.0	yes	Part time	6	10.7	0	2.6	11	Bus	no	yes	no
ALU0840	1708	6	284.67	yes	Full time	8	8.2	4	11.4	59	On foot	no	yes	no
ALU0606	2931	6	488.5	yes	Part time	6	9.6	12	8.6	47	Ride app	no	yes	no
ALU0557	4977	4	1244.25	yes	Full time	8	10.1	0	12.0	54	Bus	no	yes	no
ALU0507	2681	4	670.25	yes	Does not work	0	14.6	0	6.2	33	Bicycle	no	yes	no
ALU0059	2000	4	500.0	yes	Full time	8	8.8	0	5.6	28	Ride app	no	yes	no
ALU0608	1396	5	279.2	yes	Full time	8	2.0	12	7.8	39	Bus	no	yes	no
ALU0898	2428	3	809.33	yes	Full time	8	6.3	4	4.4	26	Bus	no	yes	no
ALU0940	5274	2	2637.0	yes	Does not work	0	19.8	0	12.8	73	Bus	no	yes	no
ALU0715	5556	5	1111.2	yes	Does not work	0	6.7	0	21.3	107	Bus	no	yes	no
ALU0133	2708	1	2708.0	yes	Does not work	0	13.1	0	4.3	17	Bus	no	yes	no
ALU0656	5197	6	866.17	yes	Does not work	0	15.4	4	10.3	60	Ride app	no	yes	no
ALU0088	3046	1	3046.0	yes	Full time	8	3.6	8	17.1	79	Ride app	no	yes	no
ALU0093	4735	6	789.17	yes	Does not work	0	10.1	8	3.7	18	Bus	no	yes	no
ALU0229	17457	3	5819.0	yes	Part time	6	8.5	0	3.3	15	Ride app	no	yes	no
ALU0855	2756	6	459.33	yes	Full time	8	11.8	8	5.7	26	Motorcycle	no	yes	no
ALU0001	1583	4	395.75	yes	Does not work	0	18.3	4	28.7	161	Bus	no	yes	no
ALU0848	2088	2	1044.0	yes	Part time	6	13.6	0	23.8	126	Bus	no	yes	no
ALU0187	8035	5	1607.0	yes	Full time	8	5.3	16	8.3	44	Car	no	yes	no
ALU0331	5327	3	1775.67	yes	Does not work	0	15.5	8	36.2	180	Car	no	yes	no
ALU0371	3089	6	514.83	yes	Does not work	0	11.0	12	3.7	18	Bus	no	yes	no
ALU0684	3457	1	3457.0	yes	Does not work	0	7.6	0	3.9	22	Bicycle	no	yes	no
ALU0403	3245	3	1081.67	yes	Does not work	0	6.8	16	15.0	79	Car	no	yes	no
ALU0192	4917	6	819.5	yes	Does not work	0	9.5	12	9.2	53	Bus	no	yes	no
ALU0293	2817	1	2817.0	yes	Does not work	0	8.8	0	2.3	13	Bus	no	yes	no
ALU0637	6125	2	3062.5	yes	Does not work	0	13.1	4	3.3	13	Motorcycle	no	yes	no
ALU0301	2662	4	665.5	yes	Full time	8	9.7	12	6.5	36	Car	no	yes	no
ALU0700	3969	6	661.5	yes	Does not work	0	10.6	0	4.3	20	Bus	no	yes	no
ALU0819	3554	4	888.5	yes	Full time	8	2.6	12	3.0	12	Motorcycle	no	yes	no
ALU0904	5558	6	926.33	yes	Full time	8	10.2	16	8.5	41	Bus	no	yes	no
ALU0527	1878	1	1878.0	yes	Part time	6	9.8	16	6.4	35	Car	no	yes	no
ALU0171	2386	6	397.67	yes	Part time	6	3.4	12	8.3	40	Car	no	yes	no
ALU0373	5113	2	2556.5	yes	Full time	8	4.6	4	7.9	34	Bicycle	no	yes	no
ALU0299	4869	5	973.8	yes	Part time	6	9.1	4	7.5	44	Car	no	yes	no
ALU0235	7606	4	1901.5	yes	Part time	6	8.5	0	13.3	57	Car	no	yes	no
ALU0048	5795	2	2897.5	yes	Does not work	0	9.9	0	3.5	18	Bicycle	no	yes	no
ALU0383	1943	1	1943.0	yes	Part time	6	7.0	8	7.0	37	Bus	no	yes	no
ALU0115	4974	1	4974.0	yes	Does not work	0	8.5	0	4.2	21	Bus	no	yes	no
ALU0130	3498	2	1749.0	yes	Part time	6	5.2	8	12.2	49	Motorcycle	no	yes	no
ALU0654	2954	3	984.67	yes	Full time	8	10.3	20	9.7	52	Bus	no	yes	no
ALU0366	2686	1	2686.0	yes	Does not work	0	13.0	16	9.6	49	On foot	no	yes	no
ALU0769	5518	3	1839.33	yes	Does not work	0	8.8	0	3.4	17	Bus	no	yes	no
ALU0730	2563	3	854.33	yes	Part time	6	9.1	4	8.9	37	Car	no	yes	no
ALU0919	1800	3	600.0	yes	Does not work	0	11.5	0	12.2	50	Motorcycle	no	yes	no
ALU0039	6987	1	6987.0	yes	Does not work	0	11.2	0	3.0	13	Bus	no	yes	no
ALU0682	2722	4	680.5	yes	Does not work	0	10.3	8	2.7	15	Bus	no	yes	no
ALU0014	5045	4	1261.25	yes	Full time	8	10.7	4	7.4	31	Motorcycle	no	yes	no
ALU0745	1389	6	231.5	yes	Full time	8	4.5	12	8.3	36	Bus	no	yes	no
ALU0960	2357	4	589.25	yes	Does not work	0	14.3	0	3.4	14	On foot	no	yes	no
ALU0165	3891	5	778.2	yes	Full time	8	5.7	12	14.8	76	Bus	no	yes	no
ALU0482	2025	3	675.0	yes	Part time	6	3.8	16	5.6	33	Car	no	yes	no
ALU0925	2025	5	405.0	yes	Full time	8	10.8	16	8.5	36	Bus	no	yes	no
ALU0489	2338	4	584.5	yes	Part time	6	6.3	0	10.4	56	Bus	no	yes	no
ALU0751	2024	4	506.0	yes	Does not work	0	13.7	4	6.0	33	Motorcycle	no	yes	no
ALU0522	1220	6	203.33	yes	Does not work	0	8.9	0	9.8	50	Car	no	yes	no
ALU0472	2316	1	2316.0	yes	Part time	6	8.9	0	7.0	30	Car	no	yes	no
ALU0910	4971	1	4971.0	yes	Part time	6	3.6	0	9.9	39	Motorcycle	no	yes	no
ALU0828	2650	6	441.67	yes	Does not work	0	13.1	4	6.0	27	Car	no	yes	no
ALU0116	2085	1	2085.0	yes	Part time	6	5.4	0	3.4	15	Bus	no	yes	no
ALU0834	3446	4	861.5	yes	Part time	6	9.5	0	6.7	36	Bus	no	yes	no
ALU0918	1744	5	348.8	yes	Part time	6	7.4	0	1.4	7	Ride app	no	yes	no
ALU0343	3583	5	716.6	yes	Does not work	0	15.3	0	10.0	58	Motorcycle	no	yes	no
ALU0363	2393	3	797.67	yes	Full time	8	16.5	0	16.2	79	Bicycle	no	yes	no
ALU0369	6316	5	1263.2	yes	Full time	8	5.0	16	8.2	33	Bus	no	yes	no
ALU0335	3634	1	3634.0	yes	Does not work	0	8.1	0	6.4	28	Car	no	yes	no
ALU0915	3198	4	799.5	yes	Part time	6	14.0	0	3.7	19	Ride app	no	yes	no
ALU0439	2810	2	1405.0	yes	Does not work	0	13.7	0	2.3	12	Bus	no	yes	no
ALU0230	3815	4	953.75	yes	Full time	8	6.5	0	11.2	49	Bus	no	yes	no
ALU0534	1630	4	407.5	yes	Does not work	0	9.2	20	4.3	19	Bus	no	yes	no
ALU0698	5990	3	1996.67	yes	Does not work	0	13.7	0	14.2	79	Car	no	yes	no
ALU0160	6170	2	3085.0	yes	Does not work	0	6.8	16	1.6	6	Car	no	yes	no
ALU0249	1076	5	215.2	yes	Does not work	0	12.6	0	5.5	23	Bus	no	yes	no
ALU0563	1764	1	1764.0	yes	Does not work	0	14.5	8	8.4	39	Ride app	no	yes	no
ALU0149	3703	1	3703.0	yes	Does not work	0	9.0	16	9.8	49	Car	no	yes	no
ALU0311	2158	3	719.33	yes	Does not work	0	10.5	0	12.7	63	Ride app	no	yes	no
ALU0281	1887	6	314.5	yes	Does not work	0	8.8	0	18.0	81	Bus	no	yes	no
ALU0486	5788	1	5788.0	yes	Does not work	0	8.5	0	4.1	19	Bus	no	yes	no
ALU0356	3402	6	567.0	yes	Does not work	0	13.0	4	7.0	32	Ride app	no	yes	no
ALU0776	2521	4	630.25	yes	Does not work	0	9.7	12	12.2	66	Bus	no	yes	no
ALU0112	5792	1	5792.0	yes	Does not work	0	6.4	12	1.4	8	Car	no	yes	no
ALU0743	1396	1	1396.0	yes	Part time	6	5.9	0	41.2	176	Car	no	yes	no
ALU0514	1416	1	1416.0	yes	Part time	6	10.9	16	3.7	20	Bus	no	yes	no
ALU0868	2365	2	1182.5	yes	Part time	6	10.5	8	2.3	9	Car	no	yes	no
ALU0800	2362	3	787.33	yes	Full time	8	10.0	8	5.3	31	Bus	no	yes	no
ALU0446	5071	4	1267.75	yes	Full time	8	9.2	4	5.9	25	Bus	no	yes	no
ALU0274	1784	3	594.67	yes	Part time	6	6.4	0	11.5	66	Bus	no	yes	no
ALU0662	4404	5	880.8	yes	Does not work	0	16.8	8	12.8	53	Car	no	yes	no
ALU0793	8308	2	4154.0	yes	Part time	6	10.8	12	4.7	22	Ride app	no	yes	no
ALU0257	5012	4	1253.0	yes	Part time	6	6.2	8	13.6	67	Bus	no	yes	no
ALU0860	5826	6	971.0	yes	Does not work	0	13.9	0	10.4	58	Bus	no	yes	no
ALU0537	4313	4	1078.25	yes	Part time	6	2.9	16	8.7	44	Bus	no	yes	no
ALU0038	6009	4	1502.25	yes	Full time	8	4.2	0	15.3	90	Car	no	yes	no
ALU0065	2043	6	340.5	yes	Does not work	0	15.8	0	19.5	91	Bus	no	yes	no
ALU0989	2791	5	558.2	yes	Does not work	0	16.1	4	2.3	12	Bicycle	no	yes	no
ALU0082	4787	3	1595.67	yes	Does not work	0	10.5	0	6.6	37	Bus	no	yes	no
ALU0628	2391	6	398.5	yes	Full time	8	11.0	8	2.2	12	Bus	no	yes	no
ALU0863	3155	3	1051.67	yes	Full time	8	6.6	12	10.4	54	Motorcycle	no	yes	no
ALU0558	5383	2	2691.5	yes	Full time	8	8.2	4	6.4	38	Bus	no	no	yes
ALU0259	2589	1	2589.0	yes	Does not work	0	16.3	0	16.2	89	Bus	no	no	yes
ALU0078	3857	4	964.25	yes	Does not work	0	13.7	0	8.2	39	Bus	no	no	yes
ALU0911	6342	4	1585.5	yes	Does not work	0	6.5	0	6.6	31	Car	no	no	yes
ALU0755	1965	5	393.0	yes	Does not work	0	14.2	0	4.6	19	Bus	no	no	yes
ALU0946	6007	6	1001.17	yes	Full time	8	3.4	0	4.2	21	On foot	no	no	yes
ALU0024	5040	1	5040.0	yes	Does not work	0	6.5	4	12.3	73	Ride app	no	no	yes
ALU0924	4358	1	4358.0	yes	Full time	8	8.5	12	6.7	38	Motorcycle	no	no	yes
ALU0958	1959	2	979.5	yes	Part time	6	8.0	12	3.1	15	Car	no	no	yes
ALU0567	2760	1	2760.0	yes	Part time	6	10.5	0	3.4	14	Bus	no	no	yes
ALU0067	3344	4	836.0	yes	Part time	6	4.1	12	25.8	145	Bus	no	no	yes
ALU0492	4397	4	1099.25	yes	Part time	6	10.9	4	12.5	65	Bus	no	no	yes
ALU0752	4357	3	1452.33	yes	Part time	6	10.9	0	19.2	77	Bus	no	no	yes
ALU0663	3042	1	3042.0	yes	Does not work	0	8.6	0	13.3	63	Bus	no	no	yes
ALU0550	2610	6	435.0	yes	Does not work	0	9.4	8	6.4	26	Bicycle	no	no	yes
ALU0170	800	4	200.0	yes	Full time	8	9.4	12	55.0	180	Car	no	no	yes
ALU0429	2912	3	970.67	yes	Part time	6	8.6	0	15.1	62	Car	no	no	yes
ALU0732	1907	1	1907.0	yes	Part time	6	10.7	0	1.9	9	Bus	no	no	yes
ALU0211	4490	2	2245.0	yes	Part time	6	12.1	12	14.7	72	Bus	no	no	yes
ALU0870	3463	6	577.17	yes	Does not work	0	9.7	20	11.8	67	Car	no	no	yes
ALU0546	5105	4	1276.25	yes	Does not work	0	11.8	12	10.7	57	Ride app	no	no	yes
ALU0204	3469	5	693.8	yes	Part time	6	12.0	12	7.7	45	Motorcycle	no	no	yes
ALU0998	2146	1	2146.0	yes	Part time	6	10.9	0	20.0	100	Bus	no	no	yes
ALU0413	5040	2	2520.0	yes	Does not work	0	13.5	0	5.2	27	Ride app	no	no	yes
ALU0448	2258	3	752.67	yes	Does not work	0	14.9	0	1.2	7	Motorcycle	no	no	yes
ALU0385	4184	1	4184.0	yes	Does not work	0	10.8	0	2.4	9	Motorcycle	no	no	yes
ALU0841	2878	5	575.6	yes	Part time	6	3.5	8	2.9	12	Bus	no	no	yes
ALU0055	5167	4	1291.75	yes	Does not work	0	15.0	0	4.6	22	Bus	no	no	yes
ALU0178	4614	6	769.0	yes	Does not work	0	6.4	20	5.5	27	Bus	no	no	yes
ALU0999	3631	4	907.75	yes	Part time	6	7.7	16	4.7	21	Bus	no	no	yes
ALU0073	6078	3	2026.0	yes	Does not work	0	12.6	0	28.6	145	Car	no	no	yes
ALU0872	2924	5	584.8	yes	Does not work	0	11.6	8	20.7	105	On foot	no	no	yes
ALU0601	1805	3	601.67	yes	Part time	6	9.3	12	2.1	8	Bus	no	no	yes
ALU0265	3341	1	3341.0	yes	Full time	8	8.5	4	3.9	22	Bus	no	no	yes
ALU0280	4754	4	1188.5	yes	Does not work	0	12.1	0	6.2	31	On foot	no	no	yes
ALU0495	2474	2	1237.0	yes	Part time	6	9.6	16	4.0	23	Bus	no	no	yes
ALU0585	1812	1	1812.0	yes	Part time	6	3.6	0	9.8	41	Bicycle	no	no	yes
ALU0342	4157	4	1039.25	yes	Part time	6	12.9	12	13.3	58	Ride app	no	no	yes
ALU0686	2197	6	366.17	yes	Does not work	0	9.5	0	21.6	111	Motorcycle	no	no	yes
ALU0519	4873	5	974.6	yes	Does not work	0	11.7	0	14.1	72	Bus	no	no	yes
ALU0581	2979	6	496.5	yes	Full time	8	7.8	0	4.7	21	Bus	no	no	yes
ALU0023	4057	5	811.4	yes	Does not work	0	9.6	0	6.6	35	Car	no	no	yes
ALU0421	1161	3	387.0	yes	Full time	8	12.8	0	6.3	28	Bus	no	no	yes
ALU0096	4930	4	1232.5	yes	Part time	6	7.2	16	9.3	50	Bus	no	no	yes
ALU0777	1289	4	322.25	yes	Does not work	0	10.4	0	7.7	35	Bicycle	no	no	yes
ALU0568	3287	5	657.4	yes	Part time	6	4.7	0	30.2	136	Bus	no	no	yes
ALU0206	6259	1	6259.0	yes	Does not work	0	12.2	4	14.2	68	Bus	no	no	yes
ALU0555	2296	1	2296.0	yes	Part time	6	8.3	4	5.0	24	Bus	no	no	yes
ALU0473	3053	2	1526.5	yes	Does not work	0	10.1	8	6.5	32	Car	no	no	yes
ALU0114	3925	2	1962.5	yes	Does not work	0	14.2	8	6.6	37	Ride app	no	no	yes
ALU0406	997	3	332.33	yes	Part time	6	10.9	12	8.7	39	Bus	no	no	yes
ALU0939	3496	3	1165.33	yes	Does not work	0	15.0	12	10.2	47	Bicycle	no	no	yes
ALU0813	2040	5	408.0	yes	Part time	6	9.5	16	32.7	155	Motorcycle	no	no	yes
ALU0080	3195	1	3195.0	yes	Does not work	0	10.0	12	5.6	32	Motorcycle	no	no	yes
ALU0648	2949	3	983.0	yes	Part time	6	9.6	0	6.1	33	Bus	no	no	yes
ALU0524	1923	3	641.0	yes	Does not work	0	2.8	12	15.8	75	Bus	no	no	yes
ALU0600	2338	3	779.33	yes	Part time	6	5.3	4	10.5	43	On foot	no	no	yes
ALU0328	3110	4	777.5	yes	Full time	8	10.7	0	10.0	47	Bus	no	no	yes
ALU0375	4244	6	707.33	yes	Does not work	0	8.3	0	7.3	32	Car	no	no	yes
ALU0438	5345	1	5345.0	yes	Full time	8	9.4	0	13.1	52	Car	no	no	yes
ALU0424	3763	1	3763.0	yes	Does not work	0	8.2	0	6.8	27	Bus	no	no	yes
ALU0270	3432	4	858.0	yes	Full time	8	7.8	0	6.6	35	Car	no	no	yes
ALU0817	1795	6	299.17	yes	Does not work	0	11.8	12	5.5	30	Bus	no	no	yes
ALU0361	1135	5	227.0	yes	Part time	6	7.6	8	30.5	129	Bus	no	no	yes
ALU0790	3292	3	1097.33	yes	Full time	8	8.0	0	5.2	29	Bicycle	no	no	yes
ALU0899	2273	5	454.6	yes	Does not work	0	5.5	0	9.0	47	Motorcycle	no	no	yes
ALU0897	3736	6	622.67	yes	Does not work	0	14.5	4	55.0	180	Bus	no	no	yes
ALU0461	2624	5	524.8	yes	Full time	8	9.6	0	10.1	55	Car	no	no	yes
ALU0583	6013	2	3006.5	yes	Part time	6	7.1	0	1.3	7	Bus	no	no	yes
ALU0653	3124	2	1562.0	yes	Does not work	0	6.8	4	5.3	26	Bus	no	no	yes
ALU0928	2805	1	2805.0	yes	Full time	8	11.7	0	2.0	11	Car	no	no	yes
ALU0757	3587	6	597.83	yes	Part time	6	11.0	8	5.3	23	On foot	no	no	yes
ALU0107	4621	4	1155.25	yes	Full time	8	11.2	4	7.9	43	Motorcycle	no	no	yes
ALU0089	3021	2	1510.5	yes	Does not work	0	12.4	8	10.1	44	Motorcycle	no	no	yes
ALU0118	1893	6	315.5	yes	Part time	6	7.8	12	21.9	94	Car	no	no	yes
ALU0510	3309	1	3309.0	yes	Does not work	0	10.6	4	2.4	11	Car	no	no	yes
ALU0645	3533	1	3533.0	yes	Does not work	0	11.1	0	2.0	10	Bus	no	no	yes
ALU0390	2608	2	1304.0	yes	Part time	6	10.6	0	24.4	137	Bus	no	no	yes
ALU0209	1780	4	445.0	yes	Does not work	0	14.1	0	7.8	46	Motorcycle	no	no	yes
ALU0575	4071	6	678.5	yes	Does not work	0	12.2	0	3.0	17	On foot	no	no	yes
ALU0232	1568	4	392.0	yes	Full time	8	13.9	8	7.3	41	Car	no	no	yes
ALU0997	2920	3	973.33	yes	Part time	6	7.3	8	6.0	29	Car	no	no	yes
ALU0254	1198	6	199.67	yes	Does not work	0	12.1	8	9.8	46	Bus	no	no	yes
ALU0599	2533	3	844.33	yes	Does not work	0	5.3	0	13.3	79	Car	no	no	yes
ALU0260	6320	2	3160.0	yes	Does not work	0	10.9	8	5.9	30	Motorcycle	no	no	yes
ALU0789	1879	1	1879.0	yes	Full time	8	5.7	0	8.9	36	Bus	no	no	yes
ALU0296	4668	1	4668.0	yes	Does not work	0	9.9	16	24.7	132	Bus	no	no	yes
ALU0240	1085	2	542.5	yes	Full time	8	7.1	0	3.0	16	Motorcycle	no	no	yes
ALU0681	3130	2	1565.0	yes	Full time	8	4.7	4	3.0	13	Bus	no	no	yes
ALU0761	1448	4	362.0	yes	Part time	6	10.6	0	5.2	27	Bus	no	no	yes
ALU0440	4624	1	4624.0	yes	Part time	6	3.3	0	14.3	67	Bus	no	no	yes
ALU0620	2833	5	566.6	yes	Full time	8	3.9	20	19.5	98	Motorcycle	no	no	yes
ALU0788	2568	5	513.6	yes	Part time	6	13.7	12	33.1	180	Bus	no	no	yes
ALU0465	3196	1	3196.0	yes	Does not work	0	11.2	12	16.0	81	Bicycle	no	no	yes
ALU0586	2883	1	2883.0	yes	Does not work	0	11.0	8	16.2	88	Bus	no	no	yes
ALU0664	2510	4	627.5	yes	Does not work	0	12.7	8	12.5	61	Bus	no	no	yes
ALU0506	2615	5	523.0	yes	Does not work	0	9.7	20	17.2	100	Motorcycle	no	no	yes
ALU0012	1911	5	382.2	yes	Full time	8	3.3	8	16.6	88	Bus	no	no	yes
ALU0346	2783	2	1391.5	yes	Full time	8	11.4	0	21.9	112	Car	no	no	yes
ALU0574	1755	4	438.75	yes	Does not work	0	12.3	12	7.9	41	Bus	no	no	yes
ALU0384	2269	3	756.33	no	Part time	6	11.0	4	6.0	24	Bus	no	no	no
ALU0961	3421	3	1140.33	no	Part time	6	12.6	4	3.1	13	Car	no	no	no
ALU0054	4110	2	2055.0	no	Part time	6	8.9	4	33.7	175	Car	no	no	no
ALU0674	2515	2	1257.5	no	Full time	8	8.1	4	2.8	14	Motorcycle	no	no	no
ALU0148	2275	3	758.33	no	Does not work	0	8.1	0	20.9	104	Bus	no	no	no
ALU0695	4519	2	2259.5	no	Full time	8	5.2	0	5.7	23	Bus	no	no	no
ALU0282	824	1	824.0	no	Does not work	0	14.5	4	21.7	120	Bus	no	no	no
ALU0166	4656	2	2328.0	no	Full time	8	3.2	0	21.5	116	Car	no	no	no
ALU0221	3428	1	3428.0	no	Does not work	0	11.6	8	5.2	26	Bus	no	no	no
ALU0665	1793	6	298.83	no	Part time	6	12.1	4	9.4	38	Bus	no	no	no
ALU0030	6387	5	1277.4	no	Full time	8	5.3	4	8.0	36	Bus	no	no	no
ALU0837	1895	6	315.83	no	Part time	6	15.7	0	3.5	20	Bicycle	no	no	no
ALU0744	3301	2	1650.5	no	Full time	8	10.5	0	6.2	26	Ride app	no	no	no
ALU0503	4409	6	734.83	no	Full time	8	2.0	8	20.4	96	Ride app	no	no	no
ALU0009	3458	6	576.33	no	Does not work	0	13.4	12	11.8	64	Bus	no	no	no
ALU0671	2546	2	1273.0	no	Does not work	0	14.4	12	13.4	71	Motorcycle	no	no	no
ALU0124	2261	6	376.83	no	Does not work	0	13.5	0	3.2	17	Bicycle	no	no	no
ALU0592	4520	4	1130.0	no	Part time	6	9.8	8	5.7	29	Ride app	no	no	no
ALU0862	5639	6	939.83	no	Full time	8	8.0	16	10.5	44	Car	no	no	no
ALU0420	2561	5	512.2	no	Does not work	0	5.4	8	15.7	67	Bus	no	no	no
ALU0953	4060	2	2030.0	no	Part time	6	11.1	0	6.1	28	On foot	no	no	no
ALU0566	4963	5	992.6	no	Full time	8	9.3	0	8.1	47	Bus	no	no	no
ALU0127	8921	2	4460.5	no	Does not work	0	10.5	20	5.2	21	Bus	no	no	no
ALU0224	4454	3	1484.67	no	Does not work	0	12.1	4	4.4	25	On foot	no	no	no
ALU0458	5936	5	1187.2	no	Part time	6	12.6	0	4.4	26	Bus	no	no	no
ALU0739	4290	4	1072.5	no	Does not work	0	13.1	8	20.0	116	Motorcycle	no	no	no
ALU0937	5004	3	1668.0	no	Does not work	0	8.9	0	12.2	51	Bicycle	no	no	no
ALU0738	3726	6	621.0	no	Full time	8	5.3	0	28.8	121	Ride app	no	no	no
ALU0437	6361	6	1060.17	no	Part time	6	10.1	12	12.6	66	Bicycle	no	no	no
ALU0434	2809	6	468.17	no	Part time	6	13.1	4	8.6	41	Motorcycle	no	no	no
ALU0842	3276	6	546.0	no	Full time	8	2.0	0	3.3	16	Ride app	no	no	no
ALU0108	4838	3	1612.67	no	Part time	6	6.4	12	4.3	23	Car	no	no	no
ALU0561	2548	1	2548.0	no	Part time	6	8.5	0	6.6	26	Car	no	no	no
ALU0016	4417	2	2208.5	no	Does not work	0	12.2	12	9.4	41	Bus	no	no	no
ALU0864	3385	5	677.0	no	Does not work	0	14.8	0	4.7	20	Bus	no	no	no
ALU0042	2051	1	2051.0	no	Does not work	0	12.0	0	4.8	22	Bus	no	no	no
ALU0200	3551	2	1775.5	no	Part time	6	8.5	0	7.0	29	Bicycle	no	no	no
ALU0943	3313	4	828.25	no	Does not work	0	10.1	0	2.0	9	Bus	no	no	no
ALU0857	1838	5	367.6	no	Does not work	0	9.1	8	10.1	56	On foot	no	no	no
ALU0549	1878	4	469.5	no	Part time	6	10.8	12	14.0	71	Car	no	no	no
ALU0710	1910	5	382.0	no	Full time	8	8.8	12	7.9	46	Bus	no	no	no
ALU0217	1782	4	445.5	no	Does not work	0	12.5	12	14.3	66	Motorcycle	no	no	no
ALU0156	5811	3	1937.0	no	Does not work	0	12.5	0	7.9	40	Bus	no	no	no
ALU0147	2800	6	466.67	no	Full time	8	13.8	8	7.4	42	On foot	no	no	no
ALU0136	1381	5	276.2	no	Part time	6	9.1	0	7.0	41	Motorcycle	no	no	no
ALU0767	2766	2	1383.0	no	Full time	8	10.2	16	8.6	45	Bus	no	no	no
ALU0981	1497	3	499.0	no	Does not work	0	13.5	8	16.1	91	Ride app	no	no	no
ALU0786	1582	1	1582.0	no	Does not work	0	8.2	8	7.4	30	Motorcycle	no	no	no
ALU0892	3994	3	1331.33	no	Full time	8	5.5	4	5.7	24	Car	no	no	no
ALU0647	11936	4	2984.0	no	Part time	6	11.7	16	7.4	32	On foot	no	no	no
ALU0515	4177	5	835.4	no	Does not work	0	8.9	0	3.7	18	Car	no	no	no
ALU0351	2333	6	388.83	no	Part time	6	12.9	8	2.2	10	Bus	no	no	no
ALU0950	1873	3	624.33	no	Does not work	0	14.1	8	22.4	92	Bus	no	no	no
ALU0883	2728	3	909.33	no	Does not work	0	11.6	0	5.0	20	On foot	no	no	no
ALU0891	1887	4	471.75	no	Full time	8	8.0	20	10.2	60	Motorcycle	no	no	no
ALU0146	3536	3	1178.67	no	Full time	8	6.4	0	3.7	16	Motorcycle	no	no	no
ALU0317	6421	4	1605.25	no	Does not work	0	10.2	0	3.4	20	Bus	no	no	no
ALU0181	5408	3	1802.67	no	Part time	6	8.7	8	4.1	24	Bicycle	no	no	no
ALU0379	2679	2	1339.5	no	Part time	6	12.0	4	3.1	17	Bus	no	no	no
ALU0128	4240	4	1060.0	no	Does not work	0	17.7	12	8.0	38	Motorcycle	no	no	no
ALU0701	4131	1	4131.0	no	Does not work	0	13.6	8	6.5	35	Motorcycle	no	no	no
ALU0416	1782	2	891.0	no	Part time	6	12.1	4	1.9	9	Bus	no	no	no
ALU0364	3625	1	3625.0	no	Part time	6	18.1	0	15.7	85	On foot	no	no	no
ALU0358	1730	3	576.67	no	Part time	6	8.2	4	10.5	60	Car	no	no	no
ALU0174	2932	5	586.4	no	Full time	8	5.7	0	13.3	78	Bus	no	no	no
ALU0046	1918	2	959.0	no	Part time	6	8.4	0	17.6	100	Bus	no	no	no
ALU0560	1377	4	344.25	no	Part time	6	8.8	8	8.2	41	Bus	no	no	no
ALU0809	1197	1	1197.0	no	Part time	6	10.3	4	18.6	105	Bus	no	no	no
ALU0022	3116	3	1038.67	no	Does not work	0	7.6	0	10.0	42	Bus	no	no	no
ALU0975	5124	3	1708.0	no	Full time	8	10.6	4	9.4	38	Motorcycle	no	no	no
ALU0488	2066	4	516.5	no	Full time	8	4.9	4	4.5	26	Ride app	no	no	no
ALU0412	1351	4	337.75	no	Full time	8	7.0	12	19.3	97	Bus	no	no	no
ALU0213	2618	1	2618.0	no	Does not work	0	9.5	12	31.6	151	Bus	no	no	no
ALU0733	1835	1	1835.0	no	Full time	8	6.0	16	9.2	42	Bicycle	no	no	no
ALU0511	1457	2	728.5	no	Full time	8	8.7	8	5.7	28	Bus	no	no	no
ALU0097	1169	1	1169.0	no	Does not work	0	13.9	12	5.4	25	Car	no	no	no
ALU0494	8424	1	8424.0	no	Does not work	0	10.8	12	3.8	16	Bus	no	no	no
ALU0839	1514	3	504.67	no	Part time	6	4.3	0	5.4	31	Bicycle	no	no	no
ALU0141	1584	5	316.8	no	Full time	8	10.5	8	19.2	108	Motorcycle	no	no	no
ALU0641	2485	4	621.25	no	Part time	6	14.4	4	5.9	32	Bus	no	no	no
ALU0370	2659	1	2659.0	no	Full time	8	4.1	4	9.7	41	Bus	no	no	no
ALU0105	2828	1	2828.0	no	Full time	8	5.6	12	22.2	105	Bus	no	no	no
ALU0795	1759	2	879.5	no	Part time	6	7.5	0	6.2	37	Ride app	no	no	no
ALU0184	3731	2	1865.5	no	Part time	6	10.0	4	5.5	25	Bus	no	no	no
ALU0066	5998	6	999.67	no	Does not work	0	11.9	12	11.6	64	Bus	no	no	no
ALU0723	3338	3	1112.67	no	Does not work	0	9.0	12	11.5	64	Bus	no	no	no
ALU0244	5162	3	1720.67	no	Part time	6	8.3	8	4.0	20	Car	no	no	no
ALU0843	2862	2	1431.0	no	Does not work	0	8.5	0	9.5	48	Motorcycle	no	no	no
ALU0090	2864	2	1432.0	no	Full time	8	3.3	0	7.8	46	Bicycle	no	no	no
ALU0028	1566	4	391.5	no	Does not work	0	17.7	8	16.4	93	Bus	no	no	no
ALU0186	2005	3	668.33	no	Full time	8	9.7	0	14.7	84	Motorcycle	no	no	no
ALU0750	4945	6	824.17	no	Does not work	0	8.0	0	8.9	49	Motorcycle	no	no	no
ALU0163	1331	6	221.83	no	Does not work	0	5.9	0	7.2	29	Motorcycle	no	no	no
ALU0714	5586	6	931.0	no	Full time	8	8.0	0	1.0	5	Bicycle	no	no	no
ALU0091	4460	2	2230.0	no	Full time	8	7.6	20	5.7	29	Bus	no	no	no
ALU0320	2448	2	1224.0	no	Full time	8	10.5	0	29.2	159	Ride app	no	no	no
ALU0748	2887	3	962.33	no	Full time	8	2.0	0	12.3	53	Bus	no	no	no
ALU0782	1539	3	513.0	no	Does not work	0	11.2	8	10.2	47	Ride app	no	no	no
ALU0467	4115	2	2057.5	no	Full time	8	9.0	16	6.5	32	Motorcycle	no	no	no
ALU0791	3633	4	908.25	no	Part time	6	11.3	12	5.2	30	Car	no	no	no
ALU0155	3133	2	1566.5	no	Part time	6	9.6	0	26.2	130	Car	no	no	no
ALU0802	4490	2	2245.0	no	Full time	8	4.0	4	31.9	146	Car	no	no	no
ALU0804	3532	5	706.4	no	Does not work	0	14.7	0	14.4	85	Bus	no	no	no
ALU0619	3415	3	1138.33	no	Part time	6	7.7	0	5.3	29	Car	no	no	no
ALU0013	8661	4	2165.25	no	Part time	6	11.8	12	4.8	25	Bus	no	no	no
ALU0610	4678	2	2339.0	no	Does not work	0	7.5	0	9.8	48	Bus	no	no	no
ALU0003	3218	1	3218.0	no	Part time	6	5.1	16	8.7	43	Car	no	no	no
ALU0193	3564	5	712.8	no	Part time	6	7.9	16	5.9	33	On foot	no	no	no
ALU0966	2815	3	938.33	no	Does not work	0	3.9	8	4.3	19	On foot	no	no	no
ALU0512	6096	1	6096.0	no	Does not work	0	10.4	0	3.9	18	Motorcycle	no	no	no
ALU0267	2277	5	455.4	no	Does not work	0	12.8	8	2.5	11	Bus	no	no	no
ALU0002	3455	4	863.75	no	Full time	8	8.1	0	26.8	159	On foot	no	no	no
ALU0669	2814	1	2814.0	no	Part time	6	11.5	0	25.4	149	Car	no	no	no
ALU0321	961	4	240.25	no	Part time	6	6.4	8	18.5	81	Car	no	no	no
ALU0858	1744	1	1744.0	no	Full time	8	12.9	16	20.7	103	Motorcycle	no	no	no
ALU0276	6925	5	1385.0	no	Full time	8	6.6	0	8.8	43	Car	no	no	no
ALU0948	2961	2	1480.5	no	Does not work	0	13.4	0	4.9	22	Bus	no	no	no
ALU0548	2616	2	1308.0	no	Full time	8	5.7	8	2.9	13	Bus	no	no	no
ALU0307	4542	6	757.0	no	Does not work	0	10.2	16	3.8	21	Motorcycle	no	no	no
ALU0140	3379	4	844.75	no	Does not work	0	13.4	4	7.9	36	Ride app	no	no	no
ALU0533	1357	3	452.33	no	Does not work	0	14.7	4	17.7	76	Bus	no	no	no
ALU0945	2330	1	2330.0	no	Does not work	0	13.8	0	12.8	56	Bus	no	no	no
ALU0474	1286	3	428.67	no	Part time	6	10.0	8	9.5	53	Car	no	no	no
ALU0151	1690	4	422.5	no	Does not work	0	11.3	8	4.0	16	Car	no	no	no
ALU0234	5542	4	1385.5	no	Does not work	0	8.8	12	4.7	27	Motorcycle	no	no	no
ALU0041	1428	5	285.6	no	Does not work	0	9.3	0	1.7	8	Car	no	no	no
ALU0887	2351	2	1175.5	no	Full time	8	11.6	4	14.3	71	Bus	no	no	no
ALU0241	6908	2	3454.0	no	Full time	8	5.8	0	5.5	26	Car	no	no	no
ALU0017	3933	1	3933.0	no	Part time	6	12.4	0	3.9	17	Bus	no	no	no
ALU0469	1585	1	1585.0	no	Part time	6	6.1	0	5.1	28	Bicycle	no	no	no
ALU0675	2790	5	558.0	no	Does not work	0	16.6	4	6.7	37	On foot	no	no	no
ALU0255	4740	4	1185.0	no	Does not work	0	13.4	8	38.3	164	Car	no	no	no
ALU0521	2289	6	381.5	no	Does not work	0	7.7	0	23.2	103	On foot	no	no	no
ALU0273	1750	3	583.33	no	Part time	6	11.1	8	4.5	25	Car	no	no	no
ALU0129	6777	3	2259.0	no	Full time	8	7.0	0	13.5	78	Car	no	no	no
ALU0497	3095	2	1547.5	no	Full time	8	8.9	8	3.6	21	Car	no	no	no
ALU0721	5369	3	1789.67	no	Does not work	0	7.7	0	47.4	180	Motorcycle	no	no	no
ALU0063	7920	3	2640.0	no	Full time	8	9.9	0	5.8	25	Bicycle	no	no	no
ALU0650	6808	5	1361.6	no	Full time	8	6.4	20	6.9	29	Bus	no	no	no
ALU0884	2831	6	471.83	no	Part time	6	6.6	8	9.1	38	Bus	no	no	no
ALU0476	3652	2	1826.0	no	Part time	6	6.9	4	12.2	55	Bus	no	no	no
ALU0785	2275	2	1137.5	no	Does not work	0	15.1	0	9.9	47	Car	no	no	no
ALU0969	4267	5	853.4	no	Part time	6	8.7	8	5.6	27	Bus	no	no	no
ALU0794	2163	3	721.0	no	Part time	6	6.7	8	10.6	54	Bicycle	no	no	no
ALU0400	2255	4	563.75	no	Part time	6	4.7	0	5.2	21	Car	no	no	no
ALU0444	3271	3	1090.33	no	Does not work	0	12.2	0	4.0	19	Bus	no	no	no
ALU0636	3233	6	538.83	no	Part time	6	6.7	0	43.4	180	Car	no	no	no
ALU0853	2399	5	479.8	no	Does not work	0	13.0	0	8.0	33	Bus	no	no	no
ALU0816	3802	5	760.4	no	Part time	6	8.4	0	2.1	8	Car	no	no	no
ALU0826	2089	4	522.25	no	Full time	8	7.8	12	9.7	38	Bus	no	no	no
ALU0909	2781	2	1390.5	no	Full time	8	7.3	0	31.4	150	Motorcycle	no	no	no
ALU0341	9253	2	4626.5	no	Does not work	0	15.7	8	6.6	31	Bicycle	no	no	no
ALU0778	5142	3	1714.0	no	Does not work	0	8.1	0	29.3	132	Motorcycle	no	no	no
ALU0944	3263	3	1087.67	no	Full time	8	9.7	0	9.5	45	Motorcycle	no	no	no
ALU0616	3065	5	613.0	no	Part time	6	9.3	8	15.6	74	On foot	no	no	no
ALU0871	2317	1	2317.0	no	Does not work	0	7.0	20	3.5	20	Bus	no	no	no
ALU0302	2481	2	1240.5	no	Part time	6	9.8	8	6.6	29	On foot	no	no	no
ALU0876	4637	4	1159.25	no	Does not work	0	9.1	0	10.4	47	Car	no	no	no
ALU0460	1647	4	411.75	no	Full time	8	5.3	0	25.7	125	Bus	no	no	no
ALU0315	2638	3	879.33	no	Does not work	0	6.8	8	3.9	22	Bicycle	no	no	no
ALU0459	1686	2	843.0	no	Does not work	0	11.3	8	50.2	180	Bus	no	no	no
ALU0907	4597	5	919.4	no	Part time	6	6.2	0	9.2	52	Ride app	no	no	no
ALU0113	1538	6	256.33	no	Full time	8	11.2	0	4.5	23	Ride app	no	no	no
ALU0111	3658	3	1219.33	no	Does not work	0	10.2	0	12.6	66	Bus	no	no	no
ALU0191	5122	2	2561.0	no	Part time	6	9.2	8	16.4	87	Bus	no	no	no
ALU0504	4428	4	1107.0	no	Full time	8	9.1	0	6.6	30	Bus	no	no	no
ALU0938	6209	4	1552.25	no	Does not work	0	14.3	0	15.4	70	Car	no	no	no
ALU0798	2628	4	657.0	no	Does not work	0	5.7	4	12.4	53	Bus	no	no	no
ALU0463	2876	5	575.2	no	Does not work	0	8.4	20	13.8	78	Bus	no	no	no
ALU0624	2774	6	462.33	no	Part time	6	3.6	4	4.8	24	Bus	no	no	no
ALU0122	4857	2	2428.5	no	Full time	8	2.9	0	10.7	57	Car	no	no	no
ALU0205	5017	3	1672.33	no	Does not work	0	10.8	16	7.2	30	Bus	no	no	no
ALU0239	6217	3	2072.33	no	Part time	6	5.3	0	6.2	25	Car	no	no	no
ALU0920	3344	1	3344.0	no	Does not work	0	15.3	20	5.2	20	Car	no	no	no
ALU0158	3145	2	1572.5	no	Full time	8	2.0	8	11.6	52	Car	no	no	no
ALU0252	2850	1	2850.0	no	Does not work	0	6.9	4	2.4	10	Motorcycle	no	no	no
ALU0345	4366	6	727.67	no	Part time	6	7.7	4	4.3	17	Bus	no	no	no
ALU0490	2924	1	2924.0	no	Does not work	0	8.6	4	7.6	35	Bus	no	no	no
ALU0787	1811	2	905.5	no	Does not work	0	11.4	0	5.0	24	Car	no	no	no
ALU0283	4740	4	1185.0	no	Part time	6	12.1	0	1.9	10	Bus	no	no	no
ALU0903	4825	2	2412.5	no	Full time	8	10.7	0	27.9	125	Motorcycle	no	no	no
ALU0457	4242	6	707.0	no	Does not work	0	12.6	8	4.3	18	Car	no	no	no
ALU0464	3029	6	504.83	no	Does not work	0	15.9	12	12.7	64	Motorcycle	no	no	no
ALU0690	1748	2	874.0	no	Does not work	0	13.8	4	12.5	72	Car	no	no	no
ALU0258	2321	2	1160.5	no	Does not work	0	11.1	8	19.9	98	Bus	no	no	no
ALU0353	4083	4	1020.75	no	Does not work	0	13.7	0	10.2	56	Ride app	no	no	no
ALU0287	4006	4	1001.5	no	Part time	6	10.2	0	32.1	146	Bus	no	no	no
ALU0718	3013	3	1004.33	no	Does not work	0	8.8	8	4.3	18	Bus	no	no	no
ALU0298	3766	4	941.5	no	Does not work	0	10.3	0	5.3	29	Motorcycle	no	no	no
ALU0913	2514	5	502.8	no	Full time	8	10.8	4	3.6	19	Motorcycle	no	no	no
ALU0589	2287	6	381.17	no	Part time	6	9.6	12	4.6	21	Bus	no	no	no
ALU0487	2952	3	984.0	no	Part time	6	5.4	0	2.4	10	Bus	no	no	no
ALU0985	3940	1	3940.0	no	Does not work	0	6.0	0	5.5	26	Car	no	no	no
ALU0605	3373	6	562.17	no	Part time	6	13.7	4	6.8	39	Bus	no	no	no
ALU0011	2124	4	531.0	no	Does not work	0	9.8	8	11.5	48	Car	no	no	no
ALU0894	2020	4	505.0	no	Does not work	0	10.9	0	5.6	32	Bus	no	no	no
ALU0685	3281	6	546.83	no	Does not work	0	17.6	0	2.0	10	Bicycle	no	no	no
ALU0797	3200	3	1066.67	no	Part time	6	9.6	4	5.3	29	Motorcycle	no	no	no
ALU0735	3289	2	1644.5	no	Does not work	0	12.0	0	7.4	30	Bus	no	no	no
ALU0157	2735	1	2735.0	no	Does not work	0	7.9	8	12.2	68	Bus	no	no	no
ALU0926	2416	4	604.0	no	Part time	6	4.8	12	11.1	62	Motorcycle	no	no	no
ALU0177	4357	5	871.4	no	Part time	6	11.2	12	19.4	82	Bicycle	no	no	no
ALU0773	1062	6	177.0	no	Does not work	0	9.6	20	15.8	69	On foot	no	no	no
ALU0137	2057	2	1028.5	no	Part time	6	11.1	0	24.5	118	Motorcycle	no	no	no
ALU0243	3795	2	1897.5	no	Does not work	0	11.2	0	7.8	44	Bus	no	no	no
ALU0655	1749	5	349.8	no	Part time	6	3.2	16	2.6	14	Car	no	no	no
ALU0784	6699	1	6699.0	no	Does not work	0	15.5	20	6.4	34	Bus	no	no	no
ALU0175	2622	2	1311.0	no	Full time	8	5.1	0	9.7	40	Bus	no	no	no
ALU0153	3056	4	764.0	no	Full time	8	4.2	0	7.2	33	Bus	no	no	no
ALU0196	6995	3	2331.67	no	Part time	6	6.2	0	15.2	61	Bus	no	no	no
ALU0676	2410	2	1205.0	no	Part time	6	8.9	4	8.9	45	Bus	no	no	no
ALU0365	3226	4	806.5	no	Does not work	0	14.2	4	6.7	35	Bus	no	no	no
ALU0861	2771	3	923.67	no	Full time	8	7.2	4	42.2	180	Bus	no	no	no
ALU0083	2395	6	399.17	no	Part time	6	12.6	0	5.4	29	Car	no	no	no
ALU0359	3667	5	733.4	no	Does not work	0	12.0	4	7.0	40	Bus	no	no	no
ALU0587	1427	1	1427.0	no	Part time	6	4.4	4	7.0	35	Ride app	no	no	no
ALU0921	6679	2	3339.5	no	Part time	6	8.9	8	17.2	69	Bus	no	no	no
ALU0337	2383	3	794.33	no	Full time	8	11.4	8	18.9	76	Bus	no	no	no
ALU0607	6902	1	6902.0	no	Does not work	0	14.2	16	10.2	49	Car	no	no	no
ALU0245	2876	1	2876.0	no	Does not work	0	11.4	8	5.3	29	Car	no	no	no
ALU0965	2516	2	1258.0	no	Part time	6	11.1	12	4.4	18	Car	no	no	no
ALU0947	3000	4	750.0	no	Does not work	0	14.4	8	9.5	49	Bicycle	no	no	no
ALU0044	2413	6	402.17	no	Does not work	0	13.2	12	8.2	37	Bus	no	no	no
ALU0626	16127	2	8063.5	no	Full time	8	9.9	12	9.8	51	Car	no	no	no
ALU0851	4393	2	2196.5	no	Does not work	0	6.5	0	22.0	116	Car	no	no	no
ALU0639	2851	6	475.17	no	Full time	8	5.6	0	2.5	10	Bus	no	no	no
ALU0104	5822	5	1164.4	no	Part time	6	7.2	0	7.7	34	Car	no	no	no
ALU0931	2379	5	475.8	no	Part time	6	10.8	0	11.1	58	Car	no	no	no
ALU0316	3738	2	1869.0	no	Does not work	0	9.1	0	6.3	30	On foot	no	no	no
ALU0445	6310	1	6310.0	no	Does not work	0	16.9	12	5.5	30	Car	no	no	no
ALU0658	2000	1	2000.0	no	Full time	8	3.4	20	7.3	36	Car	no	no	no
ALU0717	3719	2	1859.5	no	Part time	6	7.9	8	7.7	40	Car	no	no	no
ALU0271	3906	5	781.2	no	Full time	8	14.6	0	3.6	19	On foot	no	no	no
ALU0766	2253	5	450.6	no	Does not work	0	10.5	0	8.1	34	Bicycle	no	no	no
ALU0428	6001	4	1500.25	no	Does not work	0	16.0	12	2.8	14	Car	no	no	no
ALU0765	3123	6	520.5	no	Does not work	0	10.0	4	13.7	70	Bus	no	no	no
ALU0579	2533	3	844.33	no	Does not work	0	16.0	12	5.6	25	Car	no	no	no
ALU0289	3046	1	3046.0	no	Full time	8	9.0	4	34.6	166	Motorcycle	no	no	no
ALU0644	1331	4	332.75	no	Does not work	0	11.8	8	4.7	22	Bus	no	no	no
ALU0505	3538	4	884.5	no	Does not work	0	6.3	16	21.7	123	Bicycle	no	no	no
ALU0916	1107	5	221.4	no	Part time	6	14.8	16	21.3	107	Ride app	no	no	no
ALU0197	3592	1	3592.0	no	Does not work	0	16.9	16	7.6	44	Car	no	no	no
ALU0866	4418	4	1104.5	no	Part time	6	13.1	0	16.5	95	Bus	no	no	no
ALU0106	3010	5	602.0	no	Does not work	0	12.7	0	9.6	47	Bus	no	no	no
ALU0694	3791	5	758.2	no	Part time	6	13.4	4	4.7	27	Motorcycle	no	no	no
ALU0779	3639	6	606.5	no	Does not work	0	13.2	0	14.5	58	Car	no	no	no
ALU0632	4222	6	703.67	no	Full time	8	12.0	8	15.2	72	Bus	no	no	no
ALU0540	1522	5	304.4	no	Does not work	0	11.0	0	11.2	63	Motorcycle	no	no	no
ALU0980	908	4	227.0	no	Full time	8	10.8	0	21.0	114	Bus	no	no	no
ALU0199	2496	6	416.0	no	Does not work	0	18.4	0	5.9	33	Car	no	no	no
ALU0542	5972	4	1493.0	no	Part time	6	7.8	8	18.1	104	Car	no	no	no
ALU0216	4387	4	1096.75	no	Part time	6	11.8	4	10.0	42	Bus	no	no	no
ALU0015	2203	5	440.6	no	Does not work	0	10.0	8	23.7	104	Motorcycle	no	no	no
ALU0886	3629	2	1814.5	no	Full time	8	6.4	20	16.0	77	Bus	no	no	no
ALU0253	2619	6	436.5	no	Does not work	0	8.4	4	11.8	60	Car	no	no	no
ALU0135	3757	1	3757.0	no	Full time	8	7.9	0	6.8	32	Car	no	no	no
ALU0668	3770	3	1256.67	no	Full time	8	9.4	0	4.3	22	Bicycle	no	no	no
ALU0734	2002	6	333.67	no	Full time	8	12.1	0	5.0	28	Motorcycle	no	no	no
ALU0890	1758	5	351.6	no	Does not work	0	11.1	4	5.0	28	Car	no	no	no
ALU0679	1729	5	345.8	no	Full time	8	8.6	0	3.2	16	Ride app	no	no	no
ALU0749	1999	6	333.17	no	Full time	8	10.8	0	12.1	60	Motorcycle	no	no	no
ALU0630	7577	5	1515.4	no	Does not work	0	18.2	12	17.0	73	Bus	no	no	no
ALU0409	3773	6	628.83	no	Part time	6	6.2	12	21.8	99	Ride app	no	no	no
ALU0623	1287	4	321.75	no	Does not work	0	14.6	0	16.4	68	Motorcycle	no	no	no
ALU0529	1799	4	449.75	no	Part time	6	7.7	0	6.7	29	Bus	no	no	no
ALU0905	2216	3	738.67	no	Full time	8	7.6	8	14.5	77	Bus	no	no	no
ALU0692	2158	5	431.6	no	Part time	6	9.3	4	6.0	28	Bus	no	no	no
ALU0278	2036	3	678.67	no	Full time	8	6.2	0	10.9	49	Bus	no	no	no
ALU0053	8921	2	4460.5	no	Does not work	0	8.6	8	19.9	103	Ride app	no	no	no
ALU0279	2521	4	630.25	no	Part time	6	6.9	0	10.7	48	Car	no	no	no
ALU0006	2047	4	511.75	no	Part time	6	8.9	0	17.2	69	Bus	no	no	no
ALU0025	7382	1	7382.0	no	Part time	6	12.1	4	18.0	105	Bicycle	no	no	no
ALU0499	1991	5	398.2	no	Full time	8	10.5	4	5.8	23	Car	no	no	no
ALU0095	2379	1	2379.0	no	Does not work	0	9.9	4	7.9	39	Bus	no	no	no
ALU0103	5268	4	1317.0	no	Full time	8	9.6	8	5.9	32	Ride app	no	no	no
ALU0045	2119	2	1059.5	no	Does not work	0	14.3	0	16.2	70	Bus	no	no	no
ALU0602	2455	3	818.33	no	Does not work	0	13.9	4	9.9	56	Bus	no	no	no
ALU0572	2149	2	1074.5	no	Part time	6	6.9	12	5.2	25	Bicycle	no	no	no
ALU0126	3678	1	3678.0	no	Part time	6	9.8	0	1.2	5	Car	no	no	no
ALU0451	1506	3	502.0	no	Full time	8	5.2	16	5.7	29	Car	no	no	no
ALU0470	5869	5	1173.8	no	Part time	6	8.2	8	22.0	124	Bus	no	no	no
ALU0594	2237	3	745.67	no	Does not work	0	9.0	12	2.7	11	Bus	no	no	no
ALU0660	3727	4	931.75	no	Does not work	0	12.1	8	2.0	10	Bus	no	no	no
ALU0719	4300	6	716.67	no	Does not work	0	6.6	8	20.0	89	Bus	no	no	no
ALU0618	3792	2	1896.0	no	Full time	8	3.9	0	14.8	81	Ride app	no	no	no
ALU0593	2882	1	2882.0	no	Does not work	0	7.4	8	14.6	71	Motorcycle	no	no	no
ALU0070	3230	3	1076.67	no	Part time	6	4.0	0	10.1	53	Ride app	no	no	no
ALU0856	1431	4	357.75	no	Does not work	0	8.9	16	27.3	138	Motorcycle	no	no	no
ALU0098	3382	4	845.5	no	Part time	6	3.7	4	4.2	20	Bus	no	no	no
ALU0423	1742	5	348.4	no	Does not work	0	17.4	0	2.8	15	Bus	no	no	no
ALU0100	3795	4	948.75	no	Full time	8	8.0	0	8.7	44	Ride app	no	no	no
ALU0419	4167	3	1389.0	no	Part time	6	15.2	0	12.3	49	Car	no	no	no
ALU0453	4303	1	4303.0	no	Does not work	0	7.1	0	2.9	12	Ride app	no	no	no
ALU0183	2344	1	2344.0	no	Full time	8	2.2	20	25.5	109	Bus	no	no	no
ALU0498	2382	6	397.0	no	Part time	6	13.1	0	5.0	21	Motorcycle	no	no	no
ALU0783	1653	1	1653.0	no	Does not work	0	13.1	8	13.2	62	Bus	no	no	no
ALU0180	2442	2	1221.0	no	Part time	6	8.4	8	5.8	24	Bus	no	no	no
ALU0227	1979	6	329.83	no	Does not work	0	9.9	20	10.8	55	Bus	no	no	no
ALU0176	4538	2	2269.0	no	Part time	6	6.0	8	10.0	45	Motorcycle	no	no	no
ALU0570	4877	2	2438.5	no	Part time	6	10.9	4	7.8	39	Bus	no	no	no
ALU0882	3997	4	999.25	no	Full time	8	9.0	0	19.1	84	Motorcycle	no	no	no
ALU0284	4359	5	871.8	no	Does not work	0	6.5	16	21.8	122	Car	no	no	no
ALU0117	1331	6	221.83	no	Part time	6	12.0	12	15.5	67	Bus	no	no	no
ALU0349	7313	2	3656.5	no	Part time	6	12.7	20	15.2	67	Bus	no	no	no
ALU0173	7717	3	2572.33	no	Does not work	0	14.6	0	8.6	42	Bus	no	no	no
ALU0323	2649	5	529.8	no	Does not work	0	10.7	4	33.6	180	Bus	no	no	no
ALU0426	2341	1	2341.0	no	Part time	6	5.3	0	9.0	52	Bus	no	no	no
ALU0352	1590	1	1590.0	no	Part time	6	7.0	8	3.7	20	Motorcycle	no	no	no
ALU0290	7078	4	1769.5	no	Full time	8	7.6	20	3.3	15	Bicycle	no	no	no
ALU0222	14196	2	7098.0	no	Does not work	0	12.8	0	22.6	102	Car	no	no	no
ALU0058	6277	1	6277.0	no	Full time	8	4.5	0	4.3	22	Bus	no	no	no
ALU0578	2860	2	1430.0	no	Part time	6	13.4	0	12.2	57	Car	no	no	no
ALU0214	1940	3	646.67	no	Does not work	0	13.2	0	14.3	76	Bus	no	no	no
ALU0941	3520	3	1173.33	no	Full time	8	7.4	0	5.9	26	Bicycle	no	no	no
ALU0869	4548	2	2274.0	no	Does not work	0	11.6	0	2.9	12	Bicycle	no	no	no
ALU0821	2497	5	499.4	no	Does not work	0	12.3	12	5.5	30	Car	no	no	no
ALU0414	4749	5	949.8	no	Part time	6	2.4	0	5.7	23	Motorcycle	no	no	no
ALU0362	3210	1	3210.0	no	Full time	8	8.1	0	2.6	12	Bus	no	no	no
ALU0535	1873	4	468.25	no	Full time	8	7.5	0	9.9	51	Bicycle	no	no	no
ALU0964	1537	1	1537.0	no	Part time	6	5.3	0	3.9	20	Motorcycle	no	no	no
ALU0029	7116	2	3558.0	no	Part time	6	8.2	8	5.5	31	Bicycle	no	no	no
ALU0332	1774	6	295.67	no	Does not work	0	7.0	20	2.0	10	Ride app	no	no	no
ALU0491	5183	3	1727.67	no	Does not work	0	11.6	4	6.8	39	Bus	no	no	no
ALU0659	8401	5	1680.2	no	Part time	6	8.0	8	3.1	15	Car	no	no	no
ALU0726	2068	6	344.67	no	Full time	8	6.5	8	9.4	55	Car	no	no	no
ALU0021	3407	1	3407.0	no	Does not work	0	8.7	8	14.2	71	Bus	no	no	no
ALU0150	3497	6	582.83	no	Full time	8	13.8	12	13.2	72	Motorcycle	no	no	no
ALU0613	4569	5	913.8	no	Full time	8	7.8	4	12.9	56	Bus	no	no	no
ALU0617	2737	6	456.17	no	Does not work	0	14.9	0	12.8	70	Car	no	no	no
ALU0979	1477	3	492.33	no	Full time	8	5.4	4	6.7	32	Bus	no	no	no
ALU0520	5321	6	886.83	no	Part time	6	7.5	8	9.3	50	Car	no	no	no
ALU0597	3433	6	572.17	no	Part time	6	11.3	0	9.2	40	Bicycle	no	no	no
ALU0643	4348	4	1087.0	no	Part time	6	6.6	12	8.9	38	Bus	no	no	no
ALU0275	1862	5	372.4	no	Part time	6	9.5	4	5.4	29	Bicycle	no	no	no
ALU0640	3017	2	1508.5	no	Full time	8	4.2	12	7.6	36	Bus	no	no	no
ALU0008	9696	6	1616.0	no	Part time	6	11.7	0	7.3	33	Car	no	no	no
ALU0242	2125	6	354.17	no	Part time	6	8.7	0	4.8	21	Car	no	no	no
ALU0565	2426	5	485.2	no	Does not work	0	4.7	0	7.0	41	Bus	no	no	no
ALU0064	2941	4	735.25	no	Part time	6	3.7	8	7.8	46	Motorcycle	no	no	no
ALU0481	3155	4	788.75	no	Full time	8	13.5	8	6.2	35	Ride app	no	no	no
ALU0528	2612	5	522.4	no	Does not work	0	13.8	12	4.6	24	Motorcycle	no	no	no
ALU0468	2271	1	2271.0	no	Full time	8	6.7	0	7.1	32	Bus	no	no	no
ALU0085	2484	1	2484.0	no	Full time	8	5.9	8	13.3	67	On foot	no	no	no
ALU0576	5127	3	1709.0	no	Part time	6	5.9	16	16.7	97	Bus	no	no	no
ALU0740	3821	1	3821.0	no	Full time	8	8.8	0	3.3	17	Bus	no	no	no
ALU0172	5366	2	2683.0	no	Does not work	0	2.6	0	3.9	17	Car	no	no	no
ALU0411	4811	3	1603.67	no	Part time	6	5.6	0	6.6	28	Bus	no	no	no
ALU0185	2750	6	458.33	no	Does not work	0	13.4	0	16.0	70	Motorcycle	no	no	no
ALU0397	6433	1	6433.0	no	Full time	8	9.4	0	16.3	96	Bus	no	no	no
ALU0159	3223	6	537.17	no	Full time	8	8.3	0	8.0	46	Bus	no	no	no
ALU0934	4714	1	4714.0	no	Part time	6	6.0	8	18.5	108	Bicycle	no	no	no
ALU0756	1868	4	467.0	no	Does not work	0	13.4	0	5.9	32	Bus	no	no	no
ALU0987	1578	5	315.6	no	Does not work	0	11.9	0	13.6	63	Bicycle	no	no	no
ALU0932	1814	5	362.8	no	Full time	8	5.1	4	6.9	41	Bus	no	no	no
ALU0248	1443	1	1443.0	no	Does not work	0	10.3	0	11.6	69	Bus	no	no	no
ALU0393	1410	1	1410.0	no	Full time	8	4.6	4	7.6	34	Motorcycle	no	no	no
ALU0713	2338	3	779.33	no	Part time	6	9.7	0	9.0	38	Bus	no	no	no
ALU0295	1818	6	303.0	no	Full time	8	13.0	0	10.6	50	Motorcycle	no	no	no
ALU0415	6603	5	1320.6	no	Part time	6	12.4	20	8.2	49	On foot	no	no	no
ALU0801	1507	5	301.4	no	Full time	8	8.0	8	9.9	44	Motorcycle	no	no	no
ALU0263	2166	2	1083.0	no	Does not work	0	11.4	8	23.2	113	Bus	no	no	no
ALU0829	4171	2	2085.5	no	Does not work	0	7.5	0	9.1	37	Car	no	no	no
ALU0344	5014	4	1253.5	no	Full time	8	11.9	0	24.2	141	Bus	no	no	no
ALU0553	1861	5	372.2	no	Part time	6	7.1	16	16.3	79	Bus	no	no	no
ALU0501	3042	5	608.4	no	Part time	6	7.1	0	3.4	15	Bus	no	no	no
ALU0667	5503	3	1834.33	no	Does not work	0	12.9	8	2.6	14	Bus	no	no	no
ALU0705	5548	5	1109.6	no	Does not work	0	7.7	0	2.9	13	Bus	no	no	no
ALU0075	3099	4	774.75	no	Part time	6	3.9	4	4.7	28	Bus	no	no	no
ALU0330	2691	1	2691.0	no	Full time	8	6.9	8	15.3	77	Bus	no	no	no
ALU0203	2242	5	448.4	no	Part time	6	12.9	20	11.6	61	Car	no	no	no
ALU0475	2057	2	1028.5	no	Part time	6	7.8	0	2.5	10	Bus	no	no	no
ALU0247	3254	4	813.5	no	Does not work	0	8.9	8	21.7	98	Bus	no	no	no
ALU0182	1310	4	327.5	no	Does not work	0	15.0	0	5.8	28	Motorcycle	no	no	no
ALU0666	1387	2	693.5	no	Does not work	0	17.3	0	10.7	63	Bus	no	no	no
ALU0963	12458	3	4152.67	no	Full time	8	10.7	0	2.7	11	Motorcycle	no	no	no
ALU0895	2253	2	1126.5	no	Does not work	0	11.4	0	5.7	26	Bus	no	no	no
ALU0208	2821	5	564.2	no	Does not work	0	11.4	20	2.6	11	Ride app	no	no	no
ALU0010	2389	5	477.8	no	Part time	6	10.1	0	4.7	25	Bus	no	no	no
ALU0994	3668	6	611.33	no	Part time	6	7.9	0	6.9	29	Car	no	no	no
ALU0746	3359	1	3359.0	no	Does not work	0	2.0	12	7.3	38	Motorcycle	no	no	no
ALU0803	3999	4	999.75	no	Full time	8	11.4	0	3.1	16	Car	no	no	no
ALU0877	2343	3	781.0	no	Does not work	0	15.1	0	3.3	19	Bus	no	no	no
ALU0162	3699	3	1233.0	no	Does not work	0	16.8	4	5.1	24	Bus	no	no	no
ALU0825	4650	1	4650.0	no	Full time	8	8.4	8	8.5	38	Motorcycle	no	no	no
ALU0758	2490	5	498.0	no	Part time	6	3.8	0	3.5	14	Bus	no	no	no
ALU0799	1970	5	394.0	no	Does not work	0	12.5	20	16.8	90	Bus	no	no	no
ALU0094	1729	4	432.25	no	Does not work	0	9.0	8	11.0	46	Bicycle	no	no	no
ALU0753	2102	4	525.5	no	Does not work	0	8.9	0	11.2	62	Bus	no	no	no
ALU0762	1486	5	297.2	no	Does not work	0	14.8	20	14.1	69	Bus	no	no	no
ALU0716	6362	3	2120.67	no	Does not work	0	11.9	0	4.6	24	Bus	no	no	no
ALU0677	2393	2	1196.5	no	Does not work	0	14.0	20	21.0	119	Bus	no	no	no
ALU0422	7203	5	1440.6	no	Does not work	0	8.9	4	1.4	6	Bus	no	no	no
ALU0139	6703	4	1675.75	no	Part time	6	16.6	16	8.3	33	Bicycle	no	no	no
ALU0305	1909	6	318.17	no	Full time	8	2.0	20	4.5	20	Car	no	no	no
ALU0378	4356	4	1089.0	no	Part time	6	9.1	0	12.5	54	Bus	no	no	no
ALU0759	5469	3	1823.0	no	Does not work	0	10.8	16	11.0	60	Bus	no	no	no
ALU0577	1185	4	296.25	no	Does not work	0	11.8	4	2.8	14	On foot	no	no	no
ALU0277	2361	5	472.2	no	Does not work	0	10.4	20	15.3	67	Motorcycle	no	no	no
ALU0865	1989	1	1989.0	no	Full time	8	8.6	4	6.9	29	Bus	no	no	no
ALU0264	6756	1	6756.0	no	Part time	6	10.7	12	5.7	23	Bus	no	no	no
ALU0339	2226	4	556.5	no	Full time	8	10.7	0	7.8	39	Bus	no	no	no
ALU0955	1632	3	544.0	no	Does not work	0	18.4	4	17.8	75	Motorcycle	no	no	no
ALU0395	864	2	432.0	no	Part time	6	9.6	0	5.5	22	Bicycle	no	no	no
ALU0256	6300	1	6300.0	no	Does not work	0	11.9	0	2.8	15	Bus	no	no	no
ALU0702	3725	5	745.0	no	Full time	8	9.1	20	4.7	22	Bus	no	no	no
ALU0092	2574	6	429.0	no	Does not work	0	14.6	4	2.2	11	Bus	no	no	no
ALU0318	2940	6	490.0	no	Part time	6	8.0	0	17.7	90	Car	no	no	no
ALU0545	4358	2	2179.0	no	Full time	8	9.9	0	6.5	27	Bus	no	no	no
ALU0525	2675	5	535.0	no	Does not work	0	13.1	4	12.2	57	Car	no	no	no
ALU0631	5639	3	1879.67	no	Full time	8	4.6	0	16.6	89	Car	no	no	no
ALU0040	4149	5	829.8	no	Part time	6	9.3	0	15.6	67	Bus	no	no	no
ALU0635	1708	4	427.0	no	Does not work	0	12.8	20	19.2	87	Motorcycle	no	no	no
ALU0818	6039	6	1006.5	no	Does not work	0	13.5	20	42.3	180	Bus	no	no	no
ALU0388	4679	4	1169.75	no	Full time	8	10.8	0	27.2	150	Bicycle	no	no	no
ALU0792	4330	1	4330.0	no	Does not work	0	13.6	8	16.8	100	Motorcycle	no	no	no
ALU0993	2426	6	404.33	no	Does not work	0	15.5	8	14.9	71	Car	no	no	no
ALU0074	2052	2	1026.0	no	Full time	8	10.5	0	5.6	25	Car	no	no	no
ALU0687	2207	4	551.75	no	Does not work	0	11.5	16	33.0	180	Motorcycle	no	no	no
ALU0532	2147	3	715.67	no	Part time	6	5.0	8	19.6	91	Motorcycle	no	no	no
ALU0541	2994	2	1497.0	no	Does not work	0	15.1	0	26.9	109	Motorcycle	no	no	no
ALU0873	3577	2	1788.5	no	Full time	8	13.0	16	2.0	10	Car	no	no	no
ALU0056	4589	5	917.8	no	Does not work	0	15.0	8	21.4	104	Ride app	no	no	no
ALU0212	2838	2	1419.0	no	Full time	8	4.2	20	15.7	74	Bus	no	no	no
ALU0219	3880	3	1293.33	no	Does not work	0	14.8	0	12.5	55	Bus	no	no	no
ALU0322	2218	6	369.67	no	Full time	8	5.7	0	4.0	16	Bus	no	no	no
ALU0722	3262	3	1087.33	no	Part time	6	9.9	12	11.9	64	Motorcycle	no	no	no
ALU0573	7116	2	3558.0	no	Does not work	0	8.8	16	12.9	70	Bus	no	no	no
ALU0554	2869	3	956.33	no	Does not work	0	13.1	4	8.0	39	Bus	no	no	no
ALU0043	4439	4	1109.75	no	Part time	6	8.3	4	18.6	89	Bus	no	no	no
ALU0603	2746	6	457.67	no	Does not work	0	10.6	20	12.5	65	On foot	no	no	no
ALU0327	1651	4	412.75	no	Does not work	0	12.0	0	9.3	46	Motorcycle	no	no	no
ALU0707	4543	6	757.17	no	Does not work	0	12.7	20	7.1	36	Car	no	no	no
ALU0564	3586	5	717.2	no	Part time	6	6.8	8	19.3	102	Motorcycle	no	no	no
ALU0399	2342	1	2342.0	no	Does not work	0	12.8	0	5.1	27	Bicycle	no	no	no
ALU0447	2611	4	652.75	no	Does not work	0	9.6	0	6.2	35	Bus	no	no	no
ALU0430	3475	3	1158.33	no	Does not work	0	9.8	12	6.9	32	On foot	no	no	no
ALU0087	1924	5	384.8	no	Full time	8	11.9	12	15.8	73	Motorcycle	no	no	no
ALU0729	1985	6	330.83	no	Does not work	0	9.6	4	1.5	6	Bus	no	no	no
ALU0854	2777	6	462.83	no	Does not work	0	13.3	0	13.0	74	Car	no	no	no
ALU0982	1498	1	1498.0	no	Part time	6	10.9	0	17.1	87	Bus	no	no	no
ALU0068	4626	2	2313.0	no	Part time	6	10.8	0	6.3	26	On foot	no	no	no
ALU0970	1929	4	482.25	no	Does not work	0	4.5	20	13.7	66	Ride app	no	no	no
ALU0086	3196	1	3196.0	no	Does not work	0	3.2	0	12.4	69	Bus	no	no	no
ALU0233	3489	4	872.25	no	Full time	8	9.3	16	8.5	39	Car	no	no	no
ALU0991	5003	1	5003.0	no	Does not work	0	10.7	12	4.2	22	Motorcycle	no	no	no
ALU0901	1909	4	477.25	no	Does not work	0	10.4	12	4.7	23	Bus	no	no	no
ALU0768	4610	6	768.33	no	Does not work	0	8.0	4	6.1	30	Bus	no	no	no
ALU0830	3174	4	793.5	no	Full time	8	12.6	0	5.4	25	Bus	no	no	no
ALU0225	800	6	133.33	no	Does not work	0	12.9	8	10.1	44	Motorcycle	no	no	no
ALU0972	9915	4	2478.75	no	Does not work	0	15.3	0	19.5	87	Bus	no	no	no
ALU0402	3011	3	1003.67	no	Does not work	0	11.9	12	10.8	48	Bus	no	no	no
ALU0974	4971	6	828.5	no	Part time	6	9.0	4	7.0	39	Bus	no	no	no
ALU0164	2757	6	459.5	no	Does not work	0	11.1	16	3.3	19	Car	no	no	no
ALU0435	1820	2	910.0	no	Full time	8	10.4	0	10.1	41	Ride app	no	no	no
ALU0262	3590	3	1196.67	no	Part time	6	2.1	8	20.4	121	Bus	no	no	no
ALU0334	2114	4	528.5	no	Part time	6	9.6	4	9.3	45	Car	no	no	no
ALU0381	2141	6	356.83	no	Part time	6	8.6	8	3.4	15	Car	no	no	no
ALU0906	4189	3	1396.33	no	Part time	6	10.5	0	2.1	8	Bus	no	no	no
ALU0218	4361	5	872.2	no	Does not work	0	14.3	0	14.0	61	Car	no	no	no
ALU0680	1668	1	1668.0	no	Full time	8	4.8	4	20.7	111	Motorcycle	no	no	no
ALU0374	1976	4	494.0	no	Full time	8	4.1	0	7.6	33	Motorcycle	no	no	no
ALU0354	2514	4	628.5	no	Does not work	0	8.7	0	10.3	52	Car	no	no	no
ALU0807	5248	5	1049.6	no	Full time	8	4.2	8	6.7	34	Bus	no	no	no
ALU0462	1360	1	1360.0	no	Part time	6	10.5	0	19.4	114	Bus	no	no	no
ALU0651	2079	6	346.5	no	Full time	8	7.8	0	7.0	28	Bus	no	no	no
ALU0609	3925	1	3925.0	no	Does not work	0	11.9	8	8.1	37	Car	no	no	no
ALU0812	6875	4	1718.75	no	Part time	6	14.5	0	4.4	19	On foot	no	no	no
ALU0967	11876	4	2969.0	no	Full time	8	9.0	8	2.5	11	Bus	no	no	no
ALU0621	1683	1	1683.0	no	Does not work	0	11.6	0	6.1	29	Motorcycle	no	no	no
ALU0760	3940	4	985.0	no	Does not work	0	10.3	0	6.5	28	Bus	no	no	no
ALU0983	3170	3	1056.67	no	Full time	8	8.3	0	6.8	33	Bus	no	no	no
ALU0037	2149	3	716.33	no	Full time	8	10.0	0	12.1	50	Bus	no	no	no
ALU0138	3473	4	868.25	no	Does not work	0	13.5	0	11.7	64	Bus	no	no	no
ALU0425	6334	6	1055.67	no	Part time	6	4.5	16	4.3	20	Motorcycle	no	no	no
ALU0357	2466	6	411.0	no	Part time	6	9.1	12	3.4	18	On foot	no	no	no
ALU0588	2124	6	354.0	no	Part time	6	10.3	0	13.3	60	Motorcycle	no	no	no
ALU0077	2817	6	469.5	no	Part time	6	7.8	0	8.5	47	Car	no	no	no
ALU0478	2191	4	547.75	no	Does not work	0	14.5	0	5.8	34	Car	no	no	no
ALU0509	3298	2	1649.0	no	Does not work	0	8.2	8	11.0	57	Bus	no	no	no
ALU0035	4791	6	798.5	no	Full time	8	5.5	0	9.3	51	Motorcycle	no	no	no
ALU0285	3725	1	3725.0	no	Does not work	0	11.8	0	9.1	54	Motorcycle	no	no	no
ALU0880	2249	4	562.25	no	Full time	8	7.5	0	4.5	26	Car	no	no	no
ALU0844	4444	4	1111.0	no	Part time	6	8.3	8	6.3	32	Bus	no	no	no
ALU0500	5332	4	1333.0	no	Does not work	0	11.3	8	2.5	10	Bus	no	no	no
ALU0591	3277	1	3277.0	no	Full time	8	6.6	16	10.6	43	Bus	no	no	no
ALU0477	2513	2	1256.5	no	Does not work	0	9.8	0	6.2	28	Bicycle	no	no	no
ALU0728	6284	2	3142.0	no	Does not work	0	8.0	0	5.1	25	Bus	no	no	no
ALU0508	5287	1	5287.0	no	Part time	6	6.2	0	23.5	128	Motorcycle	no	no	no
ALU0720	2462	6	410.33	no	Part time	6	7.7	0	14.6	60	Bus	no	no	no
ALU0814	6695	1	6695.0	no	Full time	8	6.7	0	16.3	88	Motorcycle	no	no	no
ALU0145	6499	5	1299.8	no	Part time	6	7.7	4	12.7	72	Bus	no	no	no
ALU0949	1154	6	192.33	no	Part time	6	8.1	0	29.8	138	Car	no	no	no
ALU0493	1803	5	360.6	no	Does not work	0	11.7	4	12.9	52	Bus	no	no	no
ALU0838	3615	4	903.75	no	Part time	6	11.3	8	2.4	10	Car	no	no	no
ALU0340	2097	1	2097.0	no	Full time	8	12.3	0	29.4	144	Car	no	no	no
ALU0036	2837	6	472.83	no	Part time	6	10.3	20	6.8	38	Bus	no	no	no
ALU0401	5494	6	915.67	no	Does not work	0	12.0	20	5.7	31	Bus	no	no	no
ALU0161	6246	5	1249.2	no	Part time	6	6.2	0	13.5	76	Car	no	no	no
ALU0595	4154	2	2077.0	no	Part time	6	7.5	0	7.4	39	Bus	no	no	no
ALU0771	1855	6	309.17	no	Does not work	0	9.2	0	11.5	64	Bus	no	no	no
ALU0688	3182	1	3182.0	no	Part time	6	12.7	0	3.9	22	Car	no	no	no
ALU0657	4146	2	2073.0	no	Does not work	0	9.4	0	4.4	20	Motorcycle	no	no	no
ALU0971	2349	6	391.5	no	Does not work	0	7.7	8	9.6	41	Car	no	no	no
ALU0308	2737	1	2737.0	no	Does not work	0	11.8	0	47.8	180	Bus	no	no	no
ALU0210	1995	6	332.5	no	Full time	8	6.3	4	3.3	14	Motorcycle	no	no	no
ALU0661	3775	2	1887.5	no	Does not work	0	12.1	0	4.5	19	Bus	no	no	no
ALU0772	3020	2	1510.0	no	Does not work	0	14.8	4	33.1	176	Bus	no	no	no
ALU0543	2448	4	612.0	no	Part time	6	4.8	0	14.0	81	Ride app	no	no	no
ALU0747	2782	6	463.67	no	Part time	6	7.9	4	9.2	44	Motorcycle	no	no	no
ALU0845	2427	6	404.5	no	Full time	8	7.6	0	3.3	16	Bus	no	no	no
ALU0912	5678	3	1892.67	no	Does not work	0	19.3	0	8.6	35	Bus	no	no	no
ALU0559	2010	6	335.0	no	Does not work	0	7.2	0	7.7	39	On foot	no	no	no
ALU0996	800	3	266.67	no	Does not work	0	13.8	4	12.7	73	On foot	no	no	no
ALU0394	2496	1	2496.0	no	Does not work	0	11.9	0	20.1	91	Motorcycle	no	no	no
ALU0450	4683	4	1170.75	no	Part time	6	6.9	20	5.6	31	On foot	no	no	no
ALU0893	3887	2	1943.5	no	Full time	8	7.0	4	7.3	32	Bus	no	no	no
ALU0709	3273	3	1091.0	no	Does not work	0	17.2	4	6.0	26	Car	no	no	no
ALU0930	2048	6	341.33	no	Does not work	0	13.2	12	2.2	10	Bus	no	no	no
ALU0962	2792	1	2792.0	no	Full time	8	3.3	0	12.0	69	Car	no	no	no
ALU0691	3792	4	948.0	no	Does not work	0	8.1	0	11.5	63	Car	no	no	no
ALU0539	3630	1	3630.0	no	Part time	6	7.9	20	29.0	127	Ride app	no	no	no
ALU0050	4453	6	742.17	no	Does not work	0	2.3	16	6.0	24	Bus	no	no	no
ALU0386	1484	1	1484.0	no	Part time	6	6.2	16	4.1	21	Bus	no	no	no
ALU0049	2876	3	958.67	no	Does not work	0	17.0	12	6.3	25	Car	no	no	no
ALU0433	3878	3	1292.67	no	Does not work	0	10.8	12	3.3	19	Car	no	no	no
ALU0125	2004	6	334.0	no	Full time	8	3.7	8	5.8	33	Bicycle	no	no	no
ALU0823	3620	1	3620.0	no	Full time	8	9.9	0	37.3	151	Bus	no	no	no
ALU0449	1882	5	376.4	no	Does not work	0	14.6	0	9.8	43	Bus	no	no	no
ALU0885	4371	2	2185.5	no	Does not work	0	11.3	0	4.9	27	Car	no	no	no
ALU0057	2130	5	426.0	no	Part time	6	2.0	16	17.7	105	Bus	no	no	no
ALU0850	4900	2	2450.0	no	Full time	8	11.3	0	14.3	72	Motorcycle	no	no	no
ALU0806	3265	2	1632.5	no	Part time	6	7.0	4	9.9	40	Ride app	no	no	no
ALU0556	2355	1	2355.0	no	Does not work	0	18.0	8	4.4	21	Motorcycle	no	no	no
ALU0711	1878	3	626.0	no	Does not work	0	13.7	0	10.2	48	Motorcycle	no	no	no
ALU0004	4452	5	890.4	no	Does not work	0	8.9	16	2.7	11	Bus	no	no	no
ALU0811	1663	6	277.17	no	Does not work	0	9.7	8	7.4	29	Bus	no	no	no
ALU0220	3177	3	1059.0	no	Full time	8	7.1	12	32.1	145	Ride app	no	no	no
ALU0888	1473	5	294.6	no	Does not work	0	11.8	20	3.1	13	Motorcycle	no	no	no
ALU0007	5425	3	1808.33	no	Part time	6	6.1	8	9.6	53	Car	no	no	no
ALU0781	3732	3	1244.0	no	Part time	6	11.0	0	10.7	57	Bus	no	no	no
ALU0820	2394	4	598.5	no	Part time	6	10.9	8	4.1	16	Car	no	no	no
ALU0978	2847	6	474.5	no	Does not work	0	4.3	16	9.0	42	Ride app	no	no	no
ALU0612	2625	6	437.5	no	Does not work	0	13.2	0	11.6	65	Bicycle	no	no	no
ALU0796	3103	3	1034.33	no	Does not work	0	9.2	12	1.0	5	Car	no	no	no
ALU0387	4006	1	4006.0	no	Full time	8	3.1	8	31.9	153	Motorcycle	no	no	no
ALU0484	3375	2	1687.5	no	Full time	8	5.5	4	10.6	47	Motorcycle	no	no	no
ALU0109	6448	1	6448.0	no	Does not work	0	7.8	12	5.3	25	Car	no	no	no
ALU0427	5530	5	1106.0	no	Full time	8	11.9	20	8.7	40	Bus	no	no	no
ALU0896	2917	4	729.25	no	Full time	8	9.6	16	7.8	36	Car	no	no	no
ALU0551	3323	2	1661.5	no	Full time	8	10.0	0	10.4	45	Bus	no	no	no
ALU0288	3064	1	3064.0	no	Full time	8	7.1	12	7.1	37	Bus	no	no	no
ALU0986	1522	3	507.33	no	Part time	6	12.9	16	14.7	62	Motorcycle	no	no	no
ALU0580	1880	6	313.33	no	Does not work	0	8.1	16	2.7	15	Bus	no	no	no
ALU0389	7446	2	3723.0	no	Does not work	0	11.4	0	11.8	69	Bus	no	no	no
ALU0763	800	3	266.67	no	Part time	6	8.7	8	3.5	14	Bus	no	no	no
ALU0360	4192	2	2096.0	no	Part time	6	11.0	12	3.3	18	Motorcycle	no	no	no
ALU0062	1373	3	457.67	no	Part time	6	10.3	0	14.7	69	Bus	no	no	no
ALU0431	1952	5	390.4	no	Part time	6	13.5	0	4.4	25	Bus	no	no	no
ALU0536	3514	3	1171.33	no	Full time	8	11.7	0	20.5	92	Ride app	no	no	no
ALU0372	1477	5	295.4	no	Part time	6	7.8	12	2.8	13	Motorcycle	no	no	no
ALU0646	2254	4	563.5	no	Does not work	0	10.6	16	6.1	31	Ride app	no	no	no
ALU0516	2677	2	1338.5	no	Part time	6	12.0	20	4.7	24	Car	no	no	no
ALU0441	4083	1	4083.0	no	Does not work	0	13.0	20	25.2	133	Bus	no	no	no
ALU0562	4354	5	870.8	no	Part time	6	8.0	0	8.6	41	On foot	no	no	no
ALU0942	4862	6	810.33	no	Does not work	0	9.5	4	4.7	27	Motorcycle	no	no	no
ALU0300	2291	6	381.83	no	Full time	8	10.7	16	4.3	21	Motorcycle	no	no	no
ALU0380	1614	3	538.0	no	Full time	8	8.7	20	18.8	79	Motorcycle	no	no	no
ALU0143	2372	2	1186.0	no	Part time	6	11.5	0	8.5	43	Bus	no	no	no
ALU0526	2916	2	1458.0	no	Does not work	0	13.7	0	7.1	32	Bus	no	no	no
ALU0708	3663	3	1221.0	no	Part time	6	12.9	0	15.8	89	Bus	no	no	no
ALU0642	2625	2	1312.5	no	Full time	8	8.3	0	5.6	25	Bus	no	no	no
ALU0261	1681	6	280.17	no	Part time	6	4.6	0	3.3	17	Motorcycle	no	no	no
ALU0436	2516	1	2516.0	no	Does not work	0	11.9	4	3.0	12	Car	no	no	no
ALU0168	1290	6	215.0	no	Does not work	0	11.3	4	22.1	104	Bicycle	no	no	no
ALU0683	5116	1	5116.0	no	Full time	8	7.5	12	3.2	14	Motorcycle	no	no	no
ALU0026	3948	5	789.6	no	Does not work	0	12.1	4	8.0	42	Bicycle	no	no	no
ALU0134	5014	4	1253.5	no	Does not work	0	12.5	0	9.7	52	Bus	no	no	no
ALU0835	1592	6	265.33	no	Does not work	0	10.6	0	19.8	112	Bus	no	no	no
ALU0678	2873	2	1436.5	no	Full time	8	10.2	0	10.9	54	Ride app	no	no	no
ALU0336	1928	6	321.33	no	Does not work	0	12.4	12	9.0	39	Bus	no	no	no
ALU0625	2598	5	519.6	no	Does not work	0	12.3	8	20.6	87	Bus	no	no	no
ALU0313	2118	2	1059.0	no	Does not work	0	11.6	8	5.6	32	Motorcycle	no	no	no
ALU0324	1254	1	1254.0	no	Full time	8	5.4	4	5.1	29	Motorcycle	no	no	no
ALU0810	2497	2	1248.5	no	Full time	8	11.8	8	5.5	31	Bicycle	no	no	no
ALU0775	6385	2	3192.5	no	Part time	6	10.8	16	3.1	14	Motorcycle	no	no	no
ALU0418	3164	4	791.0	no	Part time	6	10.1	8	6.9	38	On foot	no	no	no
ALU0780	3688	4	922.0	no	Does not work	0	10.4	0	2.6	12	Motorcycle	no	no	no
ALU0110	2678	1	2678.0	no	Does not work	0	15.6	16	3.3	13	Car	no	no	no
ALU0833	2774	3	924.67	no	Part time	6	11.4	0	20.2	87	Car	no	no	no
ALU0900	4291	2	2145.5	no	Does not work	0	11.3	0	8.4	37	Ride app	no	no	no
ALU0455	2392	4	598.0	no	Does not work	0	10.6	20	1.3	7	Bus	no	no	no
ALU0144	4260	1	4260.0	no	Does not work	0	11.0	0	19.7	85	Motorcycle	no	no	no
ALU0081	938	5	187.6	no	Full time	8	2.0	0	3.7	20	On foot	no	no	no
ALU0952	2005	5	401.0	no	Part time	6	11.7	8	8.3	49	Motorcycle	no	no	no
ALU0990	3492	5	698.4	no	Does not work	0	6.9	8	2.9	13	Bus	no	no	no
ALU0310	1614	6	269.0	no	Part time	6	9.6	0	7.6	40	Bicycle	no	no	no
ALU0764	3918	2	1959.0	no	Does not work	0	10.0	0	6.4	28	Bicycle	no	no	no
ALU0142	1618	1	1618.0	no	Part time	6	10.8	12	4.1	20	Car	no	no	no
ALU0350	1436	3	478.67	no	Does not work	0	16.9	0	9.6	45	Bicycle	no	no	no
ALU0697	4310	5	862.0	no	Does not work	0	15.9	20	10.6	59	Car	no	no	no
ALU0377	3007	1	3007.0	no	Part time	6	10.4	0	24.0	113	Bus	no	no	no
ALU0957	4965	1	4965.0	no	Part time	6	8.4	0	15.1	85	On foot	no	no	no
ALU0992	2996	3	998.67	no	Does not work	0	15.0	0	12.9	60	Bicycle	no	no	no
ALU0731	1752	4	438.0	no	Part time	6	9.8	12	16.2	77	Bus	no	no	no
ALU0297	4139	3	1379.67	no	Does not work	0	9.2	8	16.3	96	Bus	no	no	no
ALU0031	3011	5	602.2	no	Part time	6	5.5	4	3.1	14	Bus	no	no	no
ALU0410	5154	3	1718.0	no	Does not work	0	14.5	20	8.3	46	Motorcycle	no	no	no
ALU0976	2191	2	1095.5	no	Part time	6	6.7	0	4.3	24	Bus	no	no	no
ALU0736	14848	3	4949.33	no	Part time	6	10.2	0	19.2	103	Car	no	no	no
ALU0020	5376	3	1792.0	no	Does not work	0	7.0	0	12.1	70	Bus	no	no	no
ALU0973	3788	1	3788.0	no	Does not work	0	12.7	4	6.4	37	Bus	no	no	no
ALU0627	4352	1	4352.0	no	Does not work	0	8.5	8	5.1	24	Bus	no	no	no
ALU0725	2840	2	1420.0	no	Full time	8	8.1	0	6.6	30	Ride app	no	no	no
ALU0604	7600	5	1520.0	no	Does not work	0	13.4	16	1.6	7	Bus	no	no	no
ALU0304	1784	3	594.67	no	Full time	8	13.5	0	5.0	28	Car	no	no	no
ALU0706	2561	4	640.25	no	Full time	8	8.6	4	5.3	25	On foot	no	no	no
ALU0852	2531	4	632.75	no	Does not work	0	14.1	4	14.9	63	Bus	no	no	no
ALU0396	1377	1	1377.0	no	Full time	8	12.1	12	10.2	42	Car	no	no	no
ALU0084	2672	1	2672.0	no	Full time	8	7.1	0	16.3	95	Motorcycle	no	no	no
ALU0614	1140	6	190.0	no	Does not work	0	10.5	8	21.9	122	Bus	no	no	no
ALU0052	2687	3	895.67	no	Does not work	0	12.0	8	6.2	35	Car	no	no	no
ALU0190	5640	6	940.0	no	Part time	6	7.0	0	7.7	33	Car	no	no	no
ALU0405	4414	4	1103.5	no	Does not work	0	13.6	4	5.8	25	Bicycle	no	no	no
ALU0805	2751	4	687.75	no	Part time	6	11.4	0	11.6	63	Bus	no	no	no
ALU0867	2486	2	1243.0	no	Does not work	0	9.2	8	7.7	33	On foot	no	no	no
ALU0443	1626	5	325.2	no	Part time	6	6.4	20	8.2	42	Ride app	no	no	no
ALU0908	1867	1	1867.0	no	Full time	8	10.8	4	13.6	70	Bicycle	no	no	no
ALU0452	3911	4	977.75	no	Full time	8	9.0	0	4.1	23	On foot	no	no	no
ALU0831	9282	4	2320.5	no	Part time	6	13.8	12	14.1	71	Motorcycle	no	no	no
ALU0047	1093	4	273.25	no	Part time	6	12.0	4	8.4	46	Bus	no	no	no
ALU0670	5094	4	1273.5	no	Does not work	0	11.0	4	11.1	64	Bus	no	no	no
ALU0061	1679	6	279.83	no	Full time	8	6.4	12	29.6	143	Car	no	no	no
ALU0319	7107	4	1776.75	no	Does not work	0	10.7	8	10.1	47	Ride app	no	no	no
ALU0076	3134	4	783.5	no	Full time	8	4.3	0	7.1	38	Bus	no	no	no
ALU0822	1900	4	475.0	no	Part time	6	5.0	0	8.2	48	Bus	no	no	no
ALU0051	2640	2	1320.0	no	Part time	6	9.9	12	3.6	20	Car	no	no	no
ALU0672	2242	6	373.67	no	Does not work	0	12.9	0	6.8	34	Car	no	no	no
ALU0959	1917	3	639.0	no	Does not work	0	12.4	8	4.9	26	Bicycle	no	no	no
ALU0827	3542	1	3542.0	no	Full time	8	8.2	8	10.0	51	Motorcycle	no	no	no
ALU0391	6739	1	6739.0	no	Part time	6	8.5	8	4.1	20	Bicycle	no	no	no
ALU0547	2549	6	424.83	no	Part time	6	10.4	0	28.4	134	Ride app	no	no	no
ALU0306	2471	6	411.83	no	Does not work	0	17.8	8	4.5	24	Bus	no	no	no
ALU0652	2141	2	1070.5	no	Does not work	0	14.2	0	7.2	32	Car	no	no	no
ALU0348	1535	6	255.83	no	Does not work	0	7.1	0	8.0	46	Bus	no	no	no
ALU0188	3806	1	3806.0	no	Full time	8	8.3	0	5.8	26	Car	no	no	no
ALU0923	1534	6	255.67	no	Part time	6	6.6	0	8.0	46	Motorcycle	no	no	no
ALU0598	2465	6	410.83	no	Part time	6	9.6	20	1.2	5	Bus	no	no	no
ALU0292	2296	6	382.67	no	Does not work	0	8.0	12	11.2	45	Bus	no	no	no
ALU0754	2875	2	1437.5	no	Part time	6	10.0	4	9.4	48	Bus	no	no	no
ALU0590	5540	1	5540.0	no	Does not work	0	9.5	8	16.1	64	Bus	no	no	no
ALU0291	2407	6	401.17	no	Part time	6	4.0	20	8.6	42	Bus	no	no	no
ALU0929	5264	3	1754.67	no	Does not work	0	5.9	0	6.9	27	Bus	no	no	no
ALU0977	5608	4	1402.0	no	Part time	6	6.1	8	9.0	46	Bicycle	no	no	no
ALU0689	2560	4	640.0	no	Part time	6	11.2	0	4.5	22	Motorcycle	no	no	no
ALU0398	3251	3	1083.67	no	Does not work	0	15.9	0	35.6	180	Bus	no	no	no
ALU0875	2201	1	2201.0	no	Full time	8	16.3	16	1.5	6	Bus	no	no	no
ALU0815	4803	3	1601.0	no	Does not work	0	10.0	12	6.1	26	Bus	no	no	no
ALU0408	2214	2	1107.0	no	Full time	8	7.4	4	15.7	78	Car	no	no	no
ALU0236	3889	1	3889.0	no	Full time	8	11.4	0	14.0	79	Bicycle	no	no	no
ALU0246	7211	5	1442.2	no	Does not work	0	11.6	0	3.9	19	Motorcycle	no	no	no
ALU0737	3340	2	1670.0	no	Full time	8	5.7	8	3.1	18	Motorcycle	no	no	no
ALU0569	3329	2	1664.5	no	Full time	8	6.9	12	5.6	31	Bus	no	no	no
ALU0231	2221	5	444.2	no	Full time	8	3.1	0	3.2	18	Car	no	no	no
ALU0131	1429	3	476.33	no	Part time	6	7.4	0	3.7	20	Car	no	no	no
ALU0727	1438	5	287.6	no	Full time	8	13.1	12	34.4	157	Bus	no	no	no
ALU0237	1575	1	1575.0	no	Does not work	0	14.3	16	15.8	74	Bus	no	no	no
ALU0836	1708	2	854.0	no	Part time	6	6.4	4	15.7	75	Bus	no	no	no
ALU0582	2035	6	339.17	no	Full time	8	10.4	4	11.0	50	Bus	no	no	no
ALU0018	4755	3	1585.0	no	Does not work	0	5.8	0	16.9	75	Bus	no	no	no
ALU0152	5041	3	1680.33	no	Part time	6	6.6	0	2.8	11	On foot	no	no	no
ALU0633	2176	1	2176.0	no	Does not work	0	12.5	0	5.7	24	Motorcycle	no	no	no
ALU0286	1723	5	344.6	no	Part time	6	7.7	16	13.1	73	On foot	no	no	no
ALU0309	1852	2	926.0	no	Does not work	0	12.9	0	6.6	37	Bus	no	no	no
ALU0995	3796	6	632.67	no	Part time	6	6.6	0	5.2	27	Motorcycle	no	no	no
ALU0121	1969	6	328.17	no	Full time	8	2.6	0	2.9	15	Motorcycle	no	no	no
ALU0442	2319	3	773.0	no	Part time	6	8.1	8	18.0	107	Bicycle	no	no	no
ALU0207	1264	1	1264.0	no	Does not work	0	16.1	8	3.5	14	Bus	no	no	no
ALU0195	3618	2	1809.0	no	Part time	6	7.9	8	9.7	56	Ride app	no	no	no
ALU0169	4589	4	1147.25	no	Full time	8	11.2	12	23.5	109	On foot	no	no	no
ALU0914	7591	1	7591.0	no	Part time	6	6.7	0	4.3	18	Motorcycle	no	no	no
ALU0611	3800	4	950.0	no	Part time	6	4.2	0	4.5	22	Ride app	no	no	no
ALU0629	3279	1	3279.0	no	Does not work	0	11.9	8	7.1	38	Bicycle	no	no	no
ALU0879	2353	3	784.33	no	Part time	6	9.3	0	11.8	63	Bus	no	no	no
ALU0119	4439	6	739.83	no	Does not work	0	13.9	16	3.7	16	Bus	no	no	no
ALU0432	5487	4	1371.75	no	Part time	6	11.9	16	26.3	139	Motorcycle	no	no	no
ALU0596	4650	2	2325.0	no	Part time	6	6.3	20	2.7	11	Bus	no	no	no
ALU0517	2063	4	515.75	no	Full time	8	6.5	0	8.1	38	Bus	no	no	no
ALU0198	3801	2	1900.5	no	Does not work	0	7.0	0	1.6	8	Bus	no	no	no
ALU0824	3708	3	1236.0	no	Does not work	0	12.9	0	3.9	19	Bus	no	no	no
ALU0120	1767	6	294.5	no	Full time	8	6.0	16	2.8	16	Ride app	no	no	no
ALU0847	1459	6	243.17	no	Part time	6	6.3	0	21.3	88	Motorcycle	no	no	no
ALU0272	1746	1	1746.0	no	Part time	6	7.8	20	4.9	25	Bus	no	no	no
ALU0382	2987	2	1493.5	no	Part time	6	8.5	0	9.5	49	Motorcycle	no	no	no
ALU0102	10459	6	1743.17	no	Part time	6	10.1	0	6.0	25	Motorcycle	no	no	no
ALU0032	7370	6	1228.33	no	Does not work	0	13.0	4	5.6	30	Car	no	no	no
ALU0368	3628	4	907.0	no	Full time	8	8.3	0	11.0	50	Bus	no	no	no
ALU0693	1742	4	435.5	no	Does not work	0	14.7	12	3.6	15	Bus	no	no	no
ALU0072	6705	3	2235.0	no	Does not work	0	11.9	0	6.0	29	Bus	no	no	no
ALU0202	6648	1	6648.0	no	Full time	8	13.7	0	10.6	63	Bus	no	no	no
ALU0889	2590	4	647.5	no	Does not work	0	7.3	8	19.0	80	Bus	no	no	no
\.

COPY public.classes (class_id, course_subject_id, id_professor, academic_period, class_value, shift) FROM stdin;
IA101-A	IA101	PROF001	2026/2	A	Morning
IA101-B	IA101	PROF002	2026/2	B	Evening
IA102-A	IA102	PROF003	2026/2	A	Morning
IA102-B	IA102	PROF004	2026/2	B	Evening
IA103-A	IA103	PROF005	2026/2	A	Morning
IA103-B	IA103	PROF006	2026/2	B	Evening
IA104-A	IA104	PROF009	2026/2	A	Morning
IA104-B	IA104	PROF010	2026/2	B	Evening
IA105-A	IA105	PROF007	2026/2	A	Morning
IA105-B	IA105	PROF008	2026/2	B	Evening
IA106-A	IA106	PROF021	2026/2	A	Morning
IA106-B	IA106	PROF022	2026/2	B	Evening
IA201-A	IA201	PROF001	2026/2	A	Morning
IA201-B	IA201	PROF002	2026/2	B	Evening
IA202-A	IA202	PROF005	2026/2	A	Morning
IA202-B	IA202	PROF006	2026/2	B	Evening
IA203-A	IA203	PROF007	2026/2	A	Morning
IA203-B	IA203	PROF008	2026/2	B	Evening
IA204-A	IA204	PROF003	2026/2	A	Morning
IA204-B	IA204	PROF004	2026/2	B	Evening
IA205-A	IA205	PROF005	2026/2	A	Morning
IA205-B	IA205	PROF006	2026/2	B	Evening
IA206-A	IA206	PROF017	2026/2	A	Morning
IA206-B	IA206	PROF018	2026/2	B	Evening
IA301-A	IA301	PROF013	2026/2	A	Morning
IA301-B	IA301	PROF014	2026/2	B	Evening
IA302-A	IA302	PROF001	2026/2	A	Morning
IA302-B	IA302	PROF002	2026/2	B	Evening
IA303-A	IA303	PROF007	2026/2	A	Morning
IA303-B	IA303	PROF008	2026/2	B	Evening
IA304-A	IA304	PROF019	2026/2	A	Morning
IA304-B	IA304	PROF020	2026/2	B	Evening
IA305-A	IA305	PROF003	2026/2	A	Morning
IA305-B	IA305	PROF004	2026/2	B	Evening
IA306-A	IA306	PROF015	2026/2	A	Morning
IA306-B	IA306	PROF016	2026/2	B	Evening
IA401-A	IA401	PROF011	2026/2	A	Morning
IA401-B	IA401	PROF012	2026/2	B	Evening
IA402-A	IA402	PROF013	2026/2	A	Morning
IA402-B	IA402	PROF014	2026/2	B	Evening
IA403-A	IA403	PROF001	2026/2	A	Morning
IA403-B	IA403	PROF002	2026/2	B	Evening
IA404-A	IA404	PROF017	2026/2	A	Morning
IA404-B	IA404	PROF018	2026/2	B	Evening
IA405-A	IA405	PROF005	2026/2	A	Morning
IA405-B	IA405	PROF006	2026/2	B	Evening
IA406-A	IA406	PROF015	2026/2	A	Morning
IA406-B	IA406	PROF016	2026/2	B	Evening
IA501-A	IA501	PROF009	2026/2	A	Morning
IA501-B	IA501	PROF010	2026/2	B	Evening
IA502-A	IA502	PROF011	2026/2	A	Morning
IA502-B	IA502	PROF012	2026/2	B	Evening
IA503-A	IA503	PROF009	2026/2	A	Morning
IA503-B	IA503	PROF010	2026/2	B	Evening
IA504-A	IA504	PROF013	2026/2	A	Morning
IA504-B	IA504	PROF014	2026/2	B	Evening
IA505-A	IA505	PROF019	2026/2	A	Morning
IA505-B	IA505	PROF020	2026/2	B	Evening
IA506-A	IA506	PROF023	2026/2	A	Morning
IA506-B	IA506	PROF024	2026/2	B	Evening
IA601-A	IA601	PROF011	2026/2	A	Morning
IA601-B	IA601	PROF012	2026/2	B	Evening
IA602-A	IA602	PROF009	2026/2	A	Morning
IA602-B	IA602	PROF010	2026/2	B	Evening
IA603-A	IA603	PROF015	2026/2	A	Morning
IA603-B	IA603	PROF016	2026/2	B	Evening
IA604-A	IA604	PROF011	2026/2	A	Morning
IA604-B	IA604	PROF012	2026/2	B	Evening
IA605-A	IA605	PROF009	2026/2	A	Morning
IA605-B	IA605	PROF010	2026/2	B	Evening
IA606-A	IA606	PROF013	2026/2	A	Morning
IA606-B	IA606	PROF014	2026/2	B	Evening
IA701-A	IA701	PROF011	2026/2	A	Morning
IA701-B	IA701	PROF012	2026/2	B	Evening
IA702-A	IA702	PROF017	2026/2	A	Morning
IA702-B	IA702	PROF018	2026/2	B	Evening
IA703-A	IA703	PROF009	2026/2	A	Morning
IA703-B	IA703	PROF010	2026/2	B	Evening
IA704-A	IA704	PROF021	2026/2	A	Morning
IA704-B	IA704	PROF022	2026/2	B	Evening
IA705-A	IA705	PROF019	2026/2	A	Morning
IA705-B	IA705	PROF020	2026/2	B	Evening
IA706-A	IA706	PROF023	2026/2	A	Morning
IA706-B	IA706	PROF024	2026/2	B	Evening
IA801-A	IA801	PROF021	2026/2	A	Morning
IA801-B	IA801	PROF022	2026/2	B	Evening
IA802-A	IA802	PROF011	2026/2	A	Morning
IA802-B	IA802	PROF012	2026/2	B	Evening
IA803-A	IA803	PROF023	2026/2	A	Morning
IA803-B	IA803	PROF024	2026/2	B	Evening
IA804-A	IA804	PROF009	2026/2	A	Morning
IA804-B	IA804	PROF010	2026/2	B	Evening
IA805-A	IA805	PROF021	2026/2	A	Morning
IA805-B	IA805	PROF022	2026/2	B	Evening
IA806-A	IA806	PROF023	2026/2	A	Morning
IA806-B	IA806	PROF024	2026/2	B	Evening
\.

COPY public.universities (university_id, name, city, uf) FROM stdin;
UNI01	Anápolis Model University	Anápolis	GO
\.

\unrestrict ZQ4gFzwVffDWmS8gylf1GFMpyqbPefQVkBsYJIEpmeavYsOpNohTvwzLS5gRDnU

