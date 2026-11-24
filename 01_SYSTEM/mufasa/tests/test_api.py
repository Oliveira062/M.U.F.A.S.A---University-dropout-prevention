from datetime import datetime, timedelta, timezone

import jwt
import pytest

from app.api.auth import generate_password_hash
from app.api.errors import DENIED_ACCESS_MSG
from tests.conftest import TEST_JWT, PASSWORD, enter, sql


def count(client, query, **params):
    return list(sql(client, query, params)[0].values())[0]


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


def test_login_with_enrollment_only_fails(client):
    r = client.post("/api/v1/auth/token", json={"login": "ALU0001"})
    assert r.status_code == 422


def test_login_with_wrong_password_fails_without_revealing_if_it_exists(client):
    a = client.post("/api/v1/auth/token", json={"login": "ALU0001", "password": "wrong", "profile": "STUDENT"})
    b = client.post("/api/v1/auth/token", json={"login": "ALU9999", "password": "wrong", "profile": "STUDENT"})
    assert a.status_code == b.status_code == 401
    assert a.json()["detail"] == b.json()["detail"]
    sql(client, "UPDATE users SET login_failures = 0 WHERE login = 'ALU0001'")


def test_block_after_five_failures(client):
    sql(client, "INSERT INTO users (login, password_hash, profile, student_id, must_change_password) "
                 "VALUES ('bloq.test', :h, 'STUDENT', 'ALU0003', FALSE)", {"h": generate_password_hash(PASSWORD)})
    for _ in range(5):
        r = client.post("/api/v1/auth/token", json={"login": "bloq.test", "password": "wrong", "profile": "STUDENT"})
        assert r.status_code == 401
    r = client.post("/api/v1/auth/token", json={"login": "bloq.test", "password": PASSWORD, "profile": "STUDENT"})
    assert r.status_code in (401, 423)
    assert count(client, "SELECT COUNT(*) FROM access_audit WHERE operation='LOGIN' AND result='BLOCKED'") >= 1


def test_login_attempt_limit_per_ip(client):
    codes = [client.post("/api/v1/auth/token", json={"login": f"not_value.exists{i}", "password": "x", "profile": "STUDENT"}).status_code
               for i in range(11)]
    assert codes[-1] == 429


def test_validation_error_does_not_echo_the_password(client):
    r = client.post("/api/v1/auth/token", json={"login": "a", "password": "MinhaSenhaSecreta!", "profile": "STUDENT"})
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
                         TEST_JWT, algorithm="HS256")
    r = client.get("/api/v1/students/ALU0001/score", headers={"Authorization": f"Bearer {overdue}"})
    assert r.status_code == 401


def test_logout_revokes_the_token(client):
    header = enter(client, "ALU0001", new=True)
    assert client.post("/api/v1/auth/logout", headers=header).status_code == 204
    assert client.get("/api/v1/students/ALU0001/score", headers=header).status_code == 401


@pytest.mark.parametrize("enrollment", [
    "ALU0001' OR '1'='1", "ALU0001;DROP TABLE students", "12345", "12345678", "ALU 001", "1 OR 1=1",
])
def test_malicious_or_malformed_enrollment_is_rejected(client, enrollment):
    header = enter(client, "coord.ai")
    r = client.get(f"/api/v1/students/{enrollment}/score", headers=header)
    assert r.status_code in (404, 422)
    assert count(client, "SELECT COUNT(*) FROM students") > 0


@pytest.mark.parametrize("params", [
    {"order": "name; DROP TABLE students"}, {"semester": "1 OR 1=1"}, {"limit": "1000"}, {"page": "-1"},
])
def test_malicious_filters_are_rejected(client, params):
    header = enter(client, "coord.ai")
    assert client.get("/api/v1/students", params=params, headers=header).status_code == 422


def test_login_with_sql_is_rejected(client):
    r = client.post("/api/v1/auth/token", json={"login": "' OR 1=1 --", "password": "x", "profile": "ADMIN"})
    assert r.status_code == 422


def test_extra_field_is_refused(client):
    r = client.post("/api/v1/auth/token", json={"login": "ALU0001", "password": PASSWORD, "profile": "STUDENT", "role": "ADMIN"})
    assert r.status_code == 422


def test_profile_other_than_registered_does_not_enter(client):
    r = client.post("/api/v1/auth/token", json={"login": "ALU0001", "password": PASSWORD, "profile": "COORDINATION"})
    assert r.status_code == 401


def test_student_sees_own_score_with_explanation(client):
    r = client.get("/api/v1/students/ALU0001/score", headers=enter(client, "ALU0001"))
    assert r.status_code == 200
    body = r.json()
    assert body["level"] in ("LOW", "MODERATE", "HIGH", "CRITICAL", "UNDETERMINED")
    assert body["explanation"] and body["notice"]
    calculated = [f for f in body["factors"] if f.get("points") is not None]
    assert calculated and all(f["raw_value"] is not None and f["explanation"] for f in calculated)


def test_student_does_not_see_another_student_and_it_is_recorded(client):
    header = enter(client, "ALU0001")
    other = client.get("/api/v1/students/ALU0002/score", headers=header)
    nonexistent = client.get("/api/v1/students/ALU9999/score", headers=header)
    assert other.status_code == nonexistent.status_code == 403
    assert other.json()["detail"] == nonexistent.json()["detail"] == DENIED_ACCESS_MSG
    assert count(client, "SELECT COUNT(*) FROM access_audit WHERE target_student_id='ALU0002' AND result='DENIED'") >= 1


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
    names = set(score["main_factors"]) | {f["factor"] for f in score["factors"]}
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


def test_error_500_does_not_expose_stack_or_sql(client, monkeypatch):
    from app.api import routes

    def _break(*_):
        raise RuntimeError("SELECT * FROM socioeconomic -- detail internal")

    monkeypatch.setattr(routes, "crop_score", _break)
    r = client.get("/api/v1/students/ALU0001/score", headers=enter(client, "coord.ai"))
    assert r.status_code == 500
    assert "Traceback" not in r.text and "SELECT" not in r.text and "socioeconomic" not in r.text
    code = r.json()["request"]
    assert code and r.headers["X-Request-ID"] == code
    assert count(client, "SELECT COUNT(*) FROM technical_logs WHERE request_id = :c", c=code) == 1


def _only_constants(no) -> bool:
    import ast
    if isinstance(no, ast.Constant):
        return isinstance(no.value, str)
    if isinstance(no, ast.Name):
        return no.id.lstrip("_").replace("_", "").isupper()
    if isinstance(no, ast.Subscript):
        return _only_constants(no.value)
    if isinstance(no, ast.BinOp) and isinstance(no.op, ast.Add):
        return _only_constants(no.left) and _only_constants(no.right)
    return False


def test_no_sql_built_with_variable_text():
    import ast
    import pathlib

    root = pathlib.Path(__file__).resolve().parents[1]
    for file in list((root / "app").rglob("*.py")) + list((root / "scripts").rglob("*.py")):
        for no in ast.walk(ast.parse(file.read_text(encoding="utf-8"))):
            if isinstance(no, ast.Call) and getattr(no.func, "id", getattr(no.func, "attr", None)) == "text":
                assert no.args and _only_constants(no.args[0]), f"{file}:{no.lineno}"
