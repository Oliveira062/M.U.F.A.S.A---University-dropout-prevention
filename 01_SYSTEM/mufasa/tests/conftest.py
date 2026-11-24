import os
from pathlib import Path

import pytest

from scripts._environment import ROOT, load_env

load_env()

TEST_DATABASE = "mufasa_test"
PASSWORD = "test-password-123"
TEST_JWT = "x" * 48


def _change_database(url: str | None) -> str | None:
    if not url:
        return None
    from sqlalchemy.engine import make_url
    return make_url(url).set(database=TEST_DATABASE).render_as_string(hide_password=False)


URLS = {name: _change_database(os.environ.get(name)) for name in
        ("DATABASE_URL_ADMIN", "DATABASE_URL", "CHAT_DATABASE_URL", "CALCULATION_DATABASE_URL")}
URLS["DATABASE_URL_ADMIN"] = os.environ.get("MUFASA_TEST_URL_ADMIN") or URLS["DATABASE_URL_ADMIN"]
_CANDIDATES_DUMP = [os.environ.get("MUFASA_DUMP"), ROOT / "database" / "Samuel Part BackEnd B1 - clean.sql",
                    ROOT.parent / "database" / "Samuel Part BackEnd B1 - clean.sql"]
DUMP = next((Path(c) for c in _CANDIDATES_DUMP if c and Path(c).exists()), None)
MISSING = [n for n, u in URLS.items() if not u] + ([] if os.environ.get("SUPPORT_KEY") else ["SUPPORT_KEY"]) \
    + ([] if DUMP else ["B1 dump (database/Samuel Part BackEnd B1 - clean.sql)"])

for _name, _url in URLS.items():
    if _url:
        os.environ[_name] = _url
os.environ.update({"JWT_SECRET": TEST_JWT, "ENVIRONMENT": "development", "MINIMUM_WAGE": "1518",
                   "MUFASA_LOG_DIR": str(ROOT / "logs" / "tests")})


def pytest_configure(config):
    config.addinivalue_line("markers", "database: needs the test PostgreSQL")


def pytest_collection_modifyitems(config, items):
    for item in items:
        if "test_database" in getattr(item, "fixturenames", ()):
            item.add_marker(pytest.mark.database)


DATA = """
INSERT INTO universities VALUES ('UNI01','University Test','Anapolis','GO');
INSERT INTO courses VALUES ('CUR01','UNI01','Artificial Intelligence','Bachelor''s',8,6,75),
                          ('CUR02','UNI01','Other Course','Bachelor''s',8,6,75);
INSERT INTO professors (id_professor, name) VALUES ('PROF001','Prof Um'),('PROF002','Prof Two'),('PROF003','Prof Three');
INSERT INTO students VALUES ('ALU0001','Julia Araujo Silva','CUR01',2,23,'Center','Regular'),
                          ('ALU0002','Camila Mendes','CUR01',1,17,'Center','Regular'),
                          ('ALU0003','Isabela Ribeiro','CUR02',3,20,'Center','Regular'),
                          ('ALU0004','Without Data','CUR01',1,19,'Center','Regular');
INSERT INTO course_subjects VALUES ('IA101','CUR01','Programming Logic',1,60,6,75),
                            ('IA103','CUR01','Calculus I',1,80,6,75),
                            ('IA202','CUR01','Calculus II',2,80,6,75),
                            ('IA203','CUR01','Linear Algebra',2,60,6,75),
                            ('IA501','CUR01','Topics',5,60,6,75),
                            ('IA999','CUR02','Algorithms',1,80,6,75);
INSERT INTO classes VALUES ('IA101-A','IA101','PROF001','2026/2','A','Morning'),
                          ('IA103-A','IA103','PROF001','2026/2','A','Morning'),
                          ('IA202-A','IA202','PROF002','2026/2','A','Morning'),
                          ('IA203-A','IA203','PROF002','2026/2','A','Morning'),
                          ('IA501-A','IA501','PROF002','2026/2','A','Evening'),
                          ('IA999-A','IA999','PROF003','2026/2','A','Morning');
INSERT INTO academic_indicators VALUES ('ALU0001','2026/2',5,72,0,2,6.9,7.7,0.8),
                                          ('ALU0002','2026/2',6,69,0,4,2.8,2.9,0.1);
INSERT INTO enrollments VALUES ('MAT1','ALU0001','IA101-A',7.467,77,'Approved',7.7,6.6,8.1),
                              ('MAT2','ALU0001','IA103-A',1.733,37,'Failed',2.7,0,2.4),
                              ('MAT3','ALU0001','IA202-A',6.15,92,'Approved',6.0,6.2,6.25),
                              ('MAT4','ALU0002','IA101-A',8.8,95,'Approved',9.0,8.5,8.9),
                              ('MAT5','ALU0003','IA999-A',7.0,80,'Approved',7.0,7.0,7.0);
INSERT INTO socioeconomic VALUES ('ALU0001',3000,5,600,'no','Full time',8,4,0,10,65,'Bus','no','no','no');
INSERT INTO risk_assessments VALUES ('AVR0001','ALU0001','2026/2','Initial','2026-08-17',26.1,'Moderate'),
                                    ('AVR0002','ALU0002','2026/2','Initial','2026-08-17',73.3,'Critical'),
                                    ('AVR0003','ALU0003','2026/2','Initial','2026-08-17',60,'High');
"""

USERS = [
    ("ALU0001", "STUDENT", "ALU0001", None, "CUR01"),
    ("ALU0002", "STUDENT", "ALU0002", None, "CUR01"),
    ("ALU0004", "STUDENT", "ALU0004", None, "CUR01"),
    ("prof.um", "TEACHER", None, "PROF001", None),
    ("coord.ai", "COORDINATION", None, None, "CUR01"),
    ("coord2.ai", "COORDINATION", None, None, "CUR01"),
    ("center.ai", "SUPPORT_CENTER", None, None, "CUR01"),
    ("finance", "FINANCE", None, None, None),
    ("board", "BOARD", None, None, None),
    ("admin", "ADMIN", None, None, None),
    ("dpo", "DPO", None, None, None),
]


def calculate_everything(calculation_url: str) -> int:
    from sqlalchemy import create_engine

    from app.calculation_service import calculation_queries as sqlc
    from app.calculation_service.__main__ import load_parameters
    from app.calculation_service.recalculation import process_batch
    engine = create_engine(calculation_url, hide_parameters=True)
    p = load_parameters(engine)
    with engine.begin() as c:
        c.execute(sqlc.ENQUEUE_WITHOUT_SCORE)
        c.execute(sqlc.ENQUEUE_OLD_VERSION, {"version": p.version})
    total, done = 0, 1
    while done:
        with engine.begin() as c:
            done = process_batch(c, p)
        total += done
    engine.dispose()
    return total


@pytest.fixture(scope="session")
def test_database():
    if MISSING:
        pytest.skip("Test PostgreSQL not configured: missing " + ", ".join(MISSING))
    from sqlalchemy import create_engine, text

    from app.api.auth import generate_password_hash
    from app.api.cipher import encrypt
    from scripts.build_database import construct

    admin = URLS["DATABASE_URL_ADMIN"]
    construct(admin, DUMP, only_schema=True, speak=lambda *_: None)
    engine = create_engine(admin, hide_parameters=True)
    with engine.begin() as c:
        c.exec_driver_sql(DATA)
        for i in range(10, 18):
            student = f"ALU00{i}"
            c.execute(text("INSERT INTO students VALUES (:id,'Aggregate','CUR01',:s,20,'X','Y')"),
                      {"id": student, "s": 5 if i < 16 else 6})
            c.execute(text("INSERT INTO academic_indicators VALUES (:id,'2026/2',0,98,0,0,9.5,9.5,0)"), {"id": student})
            c.execute(text("INSERT INTO enrollments VALUES (:m,:id,'IA501-A',9.5,98,'Approved',9.5,9.5,9.5)"),
                      {"m": f"MATX{i}", "id": student})
            c.execute(text("INSERT INTO socioeconomic (student_id, monthly_family_income, household_residents, "
                           "per_capita_income, works, daily_work_hours, commute_time_min) "
                           "VALUES (:id, 20000, 2, 10000, 'No', 0, 10)"), {"id": student})
        key = os.environ["SUPPORT_KEY"]
        c.execute(text("INSERT INTO student_support (student_id, encrypted_data) VALUES ('ALU0001', :d)"),
                  {"d": encrypt(key=key, data={"requested_psychosocial_support": True,
                                                   "accessibility_need": False})})
        password_hash = generate_password_hash(PASSWORD)
        for login, profile, student, prof, course in USERS:
            c.execute(text("INSERT INTO users (login, password_hash, profile, student_id, id_professor, course_id, name, "
                           "must_change_password, version_term, accepted_term_at) "
                           "VALUES (:l, :h, :p, :a, :pr, :c, :n, FALSE, '1.0', now())"),
                      {"l": login, "h": password_hash, "p": profile, "a": student, "pr": prof, "c": course,
                       "n": f"Test {login}"})
    calculate_everything(URLS["CALCULATION_DATABASE_URL"])
    yield {"admin": engine, "urls": URLS}
    engine.dispose()


def _restart_configuration():
    from app.api import database
    from app.chatbot import chat_database, config_chat
    from app.config import get_configuration
    get_configuration.cache_clear()
    config_chat.get_chat_configuration.cache_clear()
    database._engine = None
    chat_database._engine_chat = None


@pytest.fixture(scope="session")
def client(test_database):
    from fastapi.testclient import TestClient
    _restart_configuration()
    from app.main import app
    with TestClient(app, raise_server_exceptions=False) as tc:
        tc.engine = test_database["admin"]
        yield tc


@pytest.fixture(scope="session")
def chat_client(test_database):
    from fastapi.testclient import TestClient
    from app.main_chat import app
    with TestClient(app, raise_server_exceptions=False) as tc:
        tc.engine = test_database["admin"]
        yield tc


@pytest.fixture(autouse=True)
def _clear_limits():
    try:
        from app.api.security import limiter
        limiter.clear()
    except Exception:
        pass


_TOKENS: dict[str, dict] = {}


def enter(client, login, password=PASSWORD, profile=None, new=False):
    if new or login not in _TOKENS or password != PASSWORD:
        profile = profile or next(u[1] for u in USERS if u[0] == login)
        r = client.post("/api/v1/auth/token", json={"login": login, "password": password, "profile": profile})
        assert r.status_code == 200, r.text
        header = {"Authorization": f"Bearer {r.json()['access_token']}"}
        if new or password != PASSWORD:
            return header
        _TOKENS[login] = header
    return _TOKENS[login]


def sql(client, query: str, params: dict | None = None):
    from sqlalchemy import text
    with client.engine.begin() as c:
        r = c.execute(text(query), params or {})
        return r.mappings().all() if r.returns_rows else []
