"""
B3 tests (SRS: CA04, CA08, CA14, CA19, RN07, RN12, RN17, Section 3.3).

They run without PostgreSQL: a temporary SQLite receives tables with the same
names and columns as the B1 dump, plus the B3 tables.

    pytest tests/test_api.py -v
"""

import os
import tempfile
from datetime import datetime, timedelta, timezone

import jwt
import pytest

_FOLDER = tempfile.mkdtemp(prefix="mufasa-test-")
os.environ.update({
    "DATABASE_URL": f"sqlite:///{_FOLDER}/test.db",
    "JWT_SECRET": "x" * 48,
    "MINIMUM_WAGE": "1518",
    "ENVIRONMENT": "development",
})

from fastapi.testclient import TestClient  # noqa: E402
from sqlalchemy import create_engine, event, text  # noqa: E402

from app.api import database  # noqa: E402
from app.api.auth import generate_password_hash  # noqa: E402
from app.api.errors import DENIED_ACCESS_MSG  # noqa: E402
from app.api.security import limiter  # noqa: E402
from app.config import get_configuration  # noqa: E402

PASSWORD = "test-password-123"

SCHEMA = """
CREATE TABLE courses (course_id TEXT, university_id TEXT, name TEXT, degree TEXT, duration_semesters INT,
                     passing_average INT, minimum_attendance_pct INT);
CREATE TABLE students (student_id TEXT, fictitious_name TEXT, course_id TEXT, current_semester INT, age INT, neighborhood TEXT,
                     high_school_type TEXT, requested_psychosocial_support TEXT, accessibility_need TEXT);
CREATE TABLE course_subjects (course_subject_id TEXT, course_id TEXT, name TEXT, curriculum_semester INT, workload_h INT,
                       passing_average INT, minimum_attendance_pct INT);
CREATE TABLE classes (class_id TEXT, course_subject_id TEXT, id_professor TEXT, academic_period TEXT, class_value TEXT, shift TEXT);
CREATE TABLE enrollments (enrollment_id TEXT, student_id TEXT, class_id TEXT, final_grade NUMERIC, attendance_pct INT,
                         status TEXT, exam1 NUMERIC, exam2 NUMERIC, exam3 NUMERIC);
CREATE TABLE academic_indicators (student_id TEXT, academic_period TEXT, total_absences INT, attendance_pct INT,
                         failed_subjects_history INT, pending_activities INT,
                         previous_semester_average NUMERIC, current_average NUMERIC, average_trend NUMERIC);
CREATE TABLE socioeconomic (student_id TEXT, monthly_family_income INT, household_residents INT, per_capita_income NUMERIC,
                         scholarship_aid TEXT, works TEXT, daily_work_hours INT, weekly_study_hours NUMERIC,
                         weekly_family_responsibilities_h INT, distance_km NUMERIC, commute_time_min INT,
                         transport_mode TEXT, prouni TEXT, fies TEXT, employee_discount TEXT);
CREATE TABLE risk_assessments (assessment_id TEXT, student_id TEXT, academic_period TEXT, kind TEXT, assessment_date TEXT,
                         dropout_risk_pct NUMERIC, risk_level TEXT);
CREATE TABLE users (user_id INTEGER PRIMARY KEY AUTOINCREMENT, login TEXT UNIQUE, password_hash TEXT, profile TEXT,
                       student_id TEXT, id_professor TEXT, course_id TEXT, active BOOLEAN DEFAULT 1,
                       login_failures INT DEFAULT 0, blocked_until TEXT, last_login TEXT);
CREATE TABLE revoked_tokens (jti TEXT PRIMARY KEY, expires_at TEXT);
CREATE TABLE access_audit (audit_id INTEGER PRIMARY KEY AUTOINCREMENT, moment TEXT, request_id TEXT,
                       user_id INT, profile TEXT, operation TEXT, resource TEXT, target_student_id TEXT,
                       result TEXT, origin TEXT);
CREATE TABLE consents (consent_id INTEGER PRIMARY KEY AUTOINCREMENT, student_id TEXT, purpose TEXT,
                       granted BOOLEAN, granted_by TEXT, term_version TEXT, registered_at TEXT, user_id INT);
CREATE TABLE data_subject_requests (subject_request_id INTEGER PRIMARY KEY AUTOINCREMENT, student_id TEXT, kind TEXT,
                       description TEXT, status TEXT, registered_at TEXT, answered_at TEXT);
"""

DATA = """
INSERT INTO courses VALUES ('CUR01','UNI01','Artificial Intelligence','Bachelor''s',8,6,75),
                          ('CUR02','UNI01','Other Course','Bachelor''s',8,6,75);
INSERT INTO students VALUES ('ALU0001','Julia Test','CUR01',2,23,'Center','Regular in-person','Yes','No'),
                          ('ALU0002','Camila Test','CUR01',1,17,'Center','Regular in-person','No','No'),
                          ('ALU0003','Isabela Test','CUR02',3,20,'Center','Regular in-person','No','No');
INSERT INTO course_subjects VALUES ('IA101','CUR01','Logica',1,60,6,75), ('IA102','CUR02','Algorithms',1,80,6,75);
INSERT INTO classes VALUES ('IA101-A','IA101','PROF001','2026/2','A','Morning'),
                          ('IA102-A','IA102','PROF002','2026/2','A','Morning');
INSERT INTO enrollments VALUES ('MAT1','ALU0001','IA101-A',60,68,'Enrolled',60,60,60),
                              ('MAT2','ALU0002','IA101-A',80,90,'Enrolled',80,80,80),
                              ('MAT3','ALU0003','IA102-A',70,80,'Enrolled',70,70,70);
INSERT INTO academic_indicators VALUES ('ALU0001','2026/2',25,68,1,2,5.0,5.4,0.4),
                                          ('ALU0002','2026/2',2,95,0,0,9.0,9.5,0.5);
INSERT INTO socioeconomic VALUES ('ALU0001',3000,5,600,'no','Full time',8,4,0,10,65,'Bus','no','no','no');
INSERT INTO risk_assessments VALUES ('AV1','ALU0001','2026/2','Initial','2026-08-17',63,'High'),
                                    ('AV2','ALU0002','2026/2','Initial','2026-08-17',80,'Critical'),
                                    ('AV3','ALU0003','2026/2','Initial','2026-08-17',60,'High');
"""

USERS = [
    ("ALU0001", "STUDENT", "ALU0001", None, "CUR01"),
    ("ALU0002", "STUDENT", "ALU0002", None, "CUR01"),
    ("prof.um", "TEACHER", None, "PROF001", None),
    ("coord.ai", "COORDINATION", None, None, "CUR01"),
    ("center.ai", "SUPPORT_CENTER", None, None, "CUR01"),
    ("board", "BOARD", None, None, None),
    ("dpo", "DPO", None, None, None),
]


@pytest.fixture(scope="module")
def client():
    get_configuration.cache_clear()
    engine = create_engine(os.environ["DATABASE_URL"])

    @event.listens_for(engine, "connect")
    def _wal(dbapi_connection, _):
        dbapi_connection.execute("PRAGMA journal_mode=WAL")

    with engine.begin() as c:
        for command in (SCHEMA + DATA).split(";"):
            if command.strip():
                c.execute(text(command))
        # 6 students in term 5 (visible group) and 2 in term 6 (suppressed group).
        for i in range(10, 18):
            semester = 5 if i < 16 else 6
            c.execute(text("INSERT INTO students VALUES (:id,'Aggregate','CUR01',:s,20,'X','Y','No','No')"),
                      {"id": f"ALU00{i}", "s": semester})
            c.execute(text("INSERT INTO risk_assessments VALUES (:av,:id,'2026/2','Initial','2026-08-17',10,'Low')"),
                      {"av": f"AVX{i}", "id": f"ALU00{i}"})
        password_hash = generate_password_hash(PASSWORD)
        for login, profile, student, prof, course in USERS:
            c.execute(text("INSERT INTO users (login, password_hash, profile, student_id, id_professor, course_id) "
                           "VALUES (:l, :h, :p, :a, :pr, :c)"),
                      {"l": login, "h": password_hash, "p": profile, "a": student, "pr": prof, "c": course})

    database._engine = engine
    from app.main import app
    with TestClient(app, raise_server_exceptions=False) as tc:
        yield tc


@pytest.fixture(autouse=True)
def _clear_limits():
    limiter.clear()


def enter(client, login, password=PASSWORD):
    r = client.post("/api/v1/auth/token", json={"login": login, "password": password})
    assert r.status_code == 200, r.text
    return {"Authorization": f"Bearer {r.json()['access_token']}"}


def count(sql, **params):
    with database._engine.connect() as c:
        return c.execute(text(sql), params).scalar()


# ---------------------------------------------------------------------------
# Basics and headers
# ---------------------------------------------------------------------------

def test_health_and_security_headers(client):
    r = client.get("/health")
    assert r.status_code == 200
    assert r.headers["X-Content-Type-Options"] == "nosniff"
    assert r.headers["X-Frame-Options"] == "DENY"
    assert "default-src 'none'" in r.headers["Content-Security-Policy"]
    assert r.headers["Cache-Control"] == "no-store"
    assert r.headers["X-Request-ID"]


def test_endpoint_without_token_returns_401(client):
    r = client.get("/api/v1/students/ALU0001/score")
    assert r.status_code == 401
    assert set(r.json()) >= {"title", "status", "detail", "request"}


# ---------------------------------------------------------------------------
# Authentication (RN12, CA04)
# ---------------------------------------------------------------------------

def test_login_with_enrollment_only_fails(client):
    r = client.post("/api/v1/auth/token", json={"login": "ALU0001"})
    assert r.status_code == 422


def test_login_with_wrong_password_fails_without_revealing_if_it_exists(client):
    a = client.post("/api/v1/auth/token", json={"login": "ALU0001", "password": "wrong"})
    b = client.post("/api/v1/auth/token", json={"login": "ALU9999", "password": "wrong"})
    assert a.status_code == b.status_code == 401
    assert a.json()["detail"] == b.json()["detail"]
    with database._engine.begin() as c:
        c.execute(text("UPDATE users SET login_failures = 0 WHERE login = 'ALU0001'"))


def test_block_after_five_failures(client):
    with database._engine.begin() as c:
        c.execute(text("INSERT INTO users (login, password_hash, profile, student_id) VALUES ('bloq.test', :h, 'STUDENT', 'ALU0003')"),
                  {"h": generate_password_hash(PASSWORD)})
    for _ in range(5):
        assert client.post("/api/v1/auth/token", json={"login": "bloq.test", "password": "wrong"}).status_code == 401
    # Even with the right password, it stays locked.
    assert client.post("/api/v1/auth/token", json={"login": "bloq.test", "password": PASSWORD}).status_code == 401
    assert count("SELECT COUNT(*) FROM access_audit WHERE operation='LOGIN' AND result='BLOCKED'") >= 1


def test_login_attempt_limit_per_ip(client):
    codes = [client.post("/api/v1/auth/token", json={"login": f"not_value.exists{i}", "password": "x"}).status_code
               for i in range(11)]
    assert codes[-1] == 429


def test_validation_error_does_not_echo_the_password(client):
    r = client.post("/api/v1/auth/token", json={"login": "a", "password": "MinhaSenhaSecreta!"})
    assert r.status_code == 422
    assert "SecretaMyPassword" not in r.text


def test_token_with_alg_none_is_refused(client):
    false = jwt.encode({"sub": "1", "exp": datetime.now(timezone.utc) + timedelta(minutes=5)}, key=None, algorithm="none")
    r = client.get("/api/v1/students/ALU0001/score", headers={"Authorization": f"Bearer {false}"})
    assert r.status_code == 401


def test_expired_token_is_refused(client):
    now = datetime.now(timezone.utc)
    overdue = jwt.encode({"sub": "1", "iat": now - timedelta(hours=2), "nbf": now - timedelta(hours=2),
                          "exp": now - timedelta(hours=1), "jti": "a", "iss": "mufasa-api", "aud": "mufasa-interface"},
                         "x" * 48, algorithm="HS256")
    r = client.get("/api/v1/students/ALU0001/score", headers={"Authorization": f"Bearer {overdue}"})
    assert r.status_code == 401


def test_logout_revokes_the_token(client):
    header = enter(client, "ALU0001")
    assert client.post("/api/v1/auth/logout", headers=header).status_code == 204
    assert client.get("/api/v1/students/ALU0001/score", headers=header).status_code == 401


# ---------------------------------------------------------------------------
# SQL injection and input validation
# ---------------------------------------------------------------------------

@pytest.mark.parametrize("enrollment", [
    "ALU0001' OR '1'='1", "ALU0001;DROP TABLE students", "12345", "12345678", "ALU 001", "1 OR 1=1",
])
def test_malicious_or_malformed_enrollment_is_rejected(client, enrollment):
    header = enter(client, "coord.ai")
    r = client.get(f"/api/v1/students/{enrollment}/score", headers=header)
    assert r.status_code in (404, 422)
    assert count("SELECT COUNT(*) FROM students") > 0


@pytest.mark.parametrize("params", [
    {"order": "name; DROP TABLE students"}, {"semester": "1 OR 1=1"}, {"limit": "1000"}, {"page": "-1"},
])
def test_malicious_filters_are_rejected(client, params):
    header = enter(client, "coord.ai")
    assert client.get("/api/v1/students", params=params, headers=header).status_code == 422


def test_login_with_sql_is_rejected(client):
    r = client.post("/api/v1/auth/token", json={"login": "' OR 1=1 --", "password": "x"})
    assert r.status_code == 422


def test_extra_field_is_refused(client):
    r = client.post("/api/v1/auth/token", json={"login": "ALU0001", "password": PASSWORD, "profile": "ADMIN"})
    assert r.status_code == 422


# ---------------------------------------------------------------------------
# Isolation and permissions (RN07, RN17, CA14, CA19)
# ---------------------------------------------------------------------------

def test_student_sees_own_score_with_explanation(client):
    r = client.get("/api/v1/students/ALU0001/score", headers=enter(client, "ALU0001"))
    assert r.status_code == 200
    body = r.json()
    assert body["level"] in ("LOW", "MODERATE", "HIGH", "CRITICAL", "UNDETERMINED")
    assert body["explanation"] and body["notice"]
    assert all(f["risk"] is not None for f in body["breakdown"])  # CA08: concrete number


def test_student_does_not_see_another_student_and_it_is_recorded(client):
    header = enter(client, "ALU0001")
    other = client.get("/api/v1/students/ALU0002/score", headers=header)
    nonexistent = client.get("/api/v1/students/ALU9999/score", headers=header)
    assert other.status_code == nonexistent.status_code == 403
    assert other.json()["detail"] == nonexistent.json()["detail"] == DENIED_ACCESS_MSG
    assert count("SELECT COUNT(*) FROM access_audit WHERE target_student_id='ALU0002' AND result='DENIED'") >= 1


def test_teacher_lists_only_students_of_own_classes(client):
    r = client.get("/api/v1/students", headers=enter(client, "prof.um"))
    assert r.status_code == 200
    assert {a["enrollment"] for a in r.json()["items"]} == {"ALU0001", "ALU0002"}


def test_teacher_does_not_see_student_of_another_class(client):
    assert client.get("/api/v1/students/ALU0003", headers=enter(client, "prof.um")).status_code == 403


def test_teacher_does_not_get_socioeconomic_data(client):
    header = enter(client, "prof.um")
    profile = client.get("/api/v1/students/ALU0001", headers=header).json()
    assert "socioeconomic" not in profile and "support" not in profile and "finance" not in profile
    score = client.get("/api/v1/students/ALU0001/score", headers=header).json()
    names = set(score["main_factors"]) | {f["factor"] for f in score["breakdown"]}
    assert not names & {"finance", "work", "commute", "housing", "dependents", "mental_health", "physical_health"}


def test_coordination_sees_only_socioeconomic_band(client):
    profile = client.get("/api/v1/students/ALU0001", headers=enter(client, "coord.ai")).json()
    assert profile["socioeconomic_vulnerability"] in ("low", "average", "high")
    assert "socioeconomic" not in profile


def test_center_sees_values_and_support_data(client):
    profile = client.get("/api/v1/students/ALU0001", headers=enter(client, "center.ai")).json()
    assert profile["socioeconomic"]["per_capita_income"] == 600
    assert profile["support"]["requested_psychosocial_support"] is True


def test_board_does_not_read_individual_student(client):
    header = enter(client, "board")
    assert client.get("/api/v1/students", headers=header).status_code == 403
    assert client.get("/api/v1/students/ALU0001", headers=header).status_code == 403


def test_aggregates_suppress_small_groups(client):
    r = client.get("/api/v1/indicators/aggregates", headers=enter(client, "board"))
    assert r.status_code == 200
    groups = r.json()["groups"]
    assert all(g["total"] >= 5 for g in groups)
    assert {"semester": 5, "risk_level": "LOW", "total": 6} in groups
    assert not any(g["semester"] == 6 for g in groups)
    assert "enrollment" not in r.text and "name" not in r.text


def test_audit_only_for_dpo(client):
    assert client.get("/api/v1/audit", headers=enter(client, "coord.ai")).status_code == 403
    r = client.get("/api/v1/audit", headers=enter(client, "dpo"))
    assert r.status_code == 200 and len(r.json()) > 0


# ---------------------------------------------------------------------------
# LGPD: consent and data subject rights
# ---------------------------------------------------------------------------

def test_minor_does_not_consent_alone_to_health_data(client):
    r = client.post("/api/v1/privacy/consents", headers=enter(client, "ALU0002"),
                     json={"purpose": "HEALTH_DATA", "granted": True, "term_version": "1.0"})
    assert r.status_code == 422


def test_adult_grants_and_revokes(client):
    header = enter(client, "ALU0001")
    for granted in (True, False):
        r = client.post("/api/v1/privacy/consents", headers=header,
                         json={"purpose": "HEALTH_DATA", "granted": granted, "term_version": "1.0"})
        assert r.status_code == 201
    history = client.get("/api/v1/privacy/consents", headers=header).json()
    assert [c["granted"] for c in history][-2:] == [True, False]


def test_my_data_brings_only_the_own_student(client):
    r = client.get("/api/v1/privacy/my-data", headers=enter(client, "ALU0001"))
    assert r.status_code == 200
    assert r.json()["registration"]["student_id"] == "ALU0001"
    assert "ALU0002" not in r.text


def test_data_subject_right_request(client):
    r = client.post("/api/v1/privacy/requests", headers=enter(client, "ALU0001"),
                     json={"kind": "AUTOMATED_DECISION_REVIEW", "description": "I want a review of my level."})
    assert r.status_code == 201
    items = client.get("/api/v1/privacy/requests", headers=enter(client, "dpo")).json()
    assert any(s["kind"] == "AUTOMATED_DECISION_REVIEW" for s in items)


# ---------------------------------------------------------------------------
# Errors (SRS Section 3.3)
# ---------------------------------------------------------------------------

def test_error_500_does_not_expose_stack_or_sql(client, monkeypatch):
    from app.api import routes

    def _break(_):
        raise RuntimeError("SELECT * FROM socioeconomic -- detail internal")

    monkeypatch.setattr(routes, "calculate_student_score", _break)
    r = client.get("/api/v1/students/ALU0001/score", headers=enter(client, "coord.ai"))
    assert r.status_code == 500
    assert "Traceback" not in r.text and "SELECT" not in r.text and "socioeconomic" not in r.text
    assert r.json()["request"]


# ---------------------------------------------------------------------------
# Static guard against SQL built from text
# ---------------------------------------------------------------------------

def test_built_none_sql_with_queries_outside_text():
    """Fails text() with an f-string, concatenation or % outside queries.py."""
    import ast
    import pathlib

    root = pathlib.Path(__file__).resolve().parents[1]
    for file in list((root / "app").rglob("*.py")) + list((root / "scripts").rglob("*.py")):
        if file.name == "queries.py":
            continue
        for no in ast.walk(ast.parse(file.read_text(encoding="utf-8"))):
            if isinstance(no, ast.Call) and getattr(no.func, "id", getattr(no.func, "attr", None)) == "text":
                assert no.args and isinstance(no.args[0], ast.Constant), f"{file}:{no.lineno}"
