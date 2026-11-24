import io
from datetime import datetime, timedelta
from zoneinfo import ZoneInfo

import pytest

from tests.conftest import URLS, calculate_everything, enter, sql

TIMEZONE = ZoneInfo("America/Sao_Paulo")


def um(client, query, **p):
    rows = sql(client, query, p)
    return list(rows[0].values())[0] if rows else None


def alert_of(client, student):
    return um(client, "SELECT alert_id FROM alerts WHERE student_id = :a AND status <> 'CLOSED' "
                       "ORDER BY alert_id DESC LIMIT 1", a=student)


def test_account_me_shows_profile_and_pending_items(client):
    r = client.get("/api/v1/account/eu", headers=enter(client, "coord.ai"))
    assert r.status_code == 200
    eu = r.json()
    assert eu["profile"] == "COORDINATION" and eu["pending_term"] is False and eu["must_change_password"] is False


def test_new_account_requires_password_change_before_use(client):
    r = client.post("/api/v1/admin/users", headers=enter(client, "admin"),
                     json={"login": "ssc.new", "name": "SSC New", "profile": "SUPPORT_CENTER", "course_id": "CUR01"})
    assert r.status_code == 201, r.text
    temporary = r.json()["temporary_password"]
    header = enter(client, "ssc.new", password=temporary, profile="SUPPORT_CENTER")
    blocked = client.get("/api/v1/alerts", headers=header)
    assert blocked.status_code == 403 and blocked.headers.get("X-Pending") in ("password", "term")
    weak = client.post("/api/v1/account/password", headers=header, json={"current_password": temporary, "new_password": "ssc.new123"})
    assert weak.status_code == 422
    ok = client.post("/api/v1/account/password", headers=header,
                      json={"current_password": temporary, "new_password": "Welcoming2026"})
    assert ok.status_code in (200, 204), ok.text
    header = enter(client, "ssc.new", password="Welcoming2026", profile="SUPPORT_CENTER")
    assert client.post("/api/v1/account/term", headers=header, json={"version": "1.0", "accepted": True}).status_code in (200, 201, 204)
    assert client.get("/api/v1/alerts", headers=header).status_code == 200


def test_admin_does_not_read_student_data(client):
    header = enter(client, "admin")
    assert client.get("/api/v1/students", headers=header).status_code == 403
    assert client.get("/api/v1/students/ALU0001/score", headers=header).status_code == 403


def test_coordination_queue_has_critical_first(client):
    r = client.get("/api/v1/alerts", headers=enter(client, "coord.ai"))
    assert r.status_code == 200
    items = r.json()["items"]
    assert items and items[0]["level"] == "CRITICAL"
    assert all(i["enrollment"] != "ALU0003" for i in items)


def test_ssc_sees_only_alerts_assigned_to_it(client):
    header = enter(client, "center.ai")
    ssc_id = um(client, "SELECT user_id FROM users WHERE login = 'center.ai'")
    items = client.get("/api/v1/alerts", headers=header).json()["items"]
    ids = {i["alert_id"] for i in items}
    assigned = {l["alert_id"] for l in sql(client, "SELECT alert_id FROM alerts WHERE owner_id = :u "
                                                       "AND status <> 'CLOSED'", {"u": ssc_id})}
    assert ids == assigned


def test_alert_cycle_assign_act_close(client):
    coord = enter(client, "coord.ai")
    alert = alert_of(client, "ALU0001")
    assert alert, "ALU0001 (Critical) should have an open alert"
    ssc_id = um(client, "SELECT user_id FROM users WHERE login = 'center.ai'")
    assert client.patch(f"/api/v1/alerts/{alert}", headers=coord, json={"owner_id": ssc_id}).status_code == 200
    ssc = enter(client, "center.ai")
    detail = client.get(f"/api/v1/alerts/{alert}", headers=ssc)
    assert detail.status_code == 200 and detail.json()["can_manage"] is True
    close = {"cause": "FINANCIAL", "outcome": "REMAINED", "there_was_contact": True,
                "contact_channel": "IN_PERSON", "executed_actions": "Conversation and referral to aid."}
    assert client.post(f"/api/v1/alerts/{alert}/closing", headers=ssc, json=close).status_code in (409, 422)
    action = client.post(f"/api/v1/alerts/{alert}/actions", headers=ssc,
                        json={"action_type": "CONVERSATION", "description": "Welcoming conversation.", "visible_to_student": True})
    assert action.status_code in (200, 201), action.text
    r = client.post(f"/api/v1/alerts/{alert}/closing", headers=ssc, json=close)
    assert r.status_code in (200, 201), r.text
    assert um(client, "SELECT status FROM alerts WHERE alert_id = :a", a=alert) == "CLOSED"
    recs = client.get("/api/v1/student/followup", headers=enter(client, "ALU0001")).json()["records"]
    assert any("Welcoming" in (r.get("description") or "") for r in recs)


def test_emergency_channel_only_for_critical(client):
    sql(client, "INSERT INTO alerts (student_id, origin_score_id, level, deadline_at) "
                 "SELECT 'ALU0002', id_score, 'HIGH', now() + interval '5 days' FROM vw_current_score "
                 "WHERE student_id = 'ALU0002'")
    high = alert_of(client, "ALU0002")
    coord = enter(client, "coord.ai")
    client.post(f"/api/v1/alerts/{high}/actions", headers=coord,
                 json={"action_type": "CONVERSATION", "description": "Contact made.", "visible_to_student": False})
    r = client.post(f"/api/v1/alerts/{high}/closing", headers=coord, json={
        "cause": "ACADEMIC", "outcome": "REMAINED", "there_was_contact": True, "contact_channel": "RN19_EMERGENCY",
        "executed_actions": "Contact through the emergency channel."})
    assert r.status_code in (403, 409, 422), r.text
    assert um(client, "SELECT status FROM alerts WHERE alert_id = :a", a=high) != "CLOSED"


def _time(days: int) -> str:
    d = (datetime.now(TIMEZONE) + timedelta(days=days)).replace(hour=10, minute=0, second=0, microsecond=0)
    return d.isoformat()


def test_minimum_interval_between_services(client):
    header = enter(client, "ALU0002")
    first = client.post("/api/v1/appointments", headers=header, json={"start": _time(2)})
    assert first.status_code == 201, first.text
    second = client.post("/api/v1/appointments", headers=header, json={"start": _time(5)})
    assert second.status_code == 409
    assert "Next possible date" in second.json()["detail"]
    assert um(client, "SELECT count(*) FROM appointment_refusals WHERE student_id = 'ALU0002'") >= 1
    assert client.post("/api/v1/appointments", headers=header, json={"start": _time(20)}).status_code == 201


def test_student_does_not_schedule_for_another(client):
    r = client.post("/api/v1/appointments", headers=enter(client, "ALU0002"),
                     json={"enrollment": "ALU0001", "start": _time(30)})
    assert um(client, "SELECT count(*) FROM appointments WHERE student_id = 'ALU0001'") == 0 or r.status_code != 201


def test_student_status_without_score_number(client):
    r = client.get("/api/v1/student/status", headers=enter(client, "ALU0001"))
    assert r.status_code == 200
    s = r.json()
    assert "score" not in s and "dropout" not in s["message"].lower()
    assert s["status"] == "Immediate follow-up" and s["immediate_channel"]
    subj = client.get("/api/v1/student/subjects", headers=enter(client, "ALU0001")).json()
    calculation = next(d for d in subj["subjects"] if d["subject"] == "Calculus I")
    assert calculation["exam2"] == 0 and calculation["minimum_below_attendance"] is True


def test_student_disputes_factor(client):
    r = client.post("/api/v1/student/disputes", headers=enter(client, "ALU0001"),
                     json={"factor": "attendance", "description": "My attendance in Calculus I is wrong."})
    assert r.status_code == 201
    assert um(client, "SELECT count(*) FROM data_subject_requests WHERE student_id = 'ALU0001' AND kind = 'CORRECTION'") >= 1


def test_management_dashboard_aggregates_and_suppresses(client):
    r = client.get("/api/v1/dashboards/general-view", headers=enter(client, "board"))
    assert r.status_code == 200
    v = r.json()
    assert "ALU00" not in r.text and "Julia" not in r.text
    for d in v["distribution"]:
        assert d["total"] is None or d["total"] == 0 or d["total"] >= 5
    if v["there_was_suppression"]:
        assert v["students"] is None and all(d.get("pct") is None for d in v["distribution"])


def test_student_and_teacher_do_not_open_dashboards(client):
    for login in ("ALU0001", "prof.um"):
        assert client.get("/api/v1/dashboards/general-view", headers=enter(client, login)).status_code == 403


def test_dashboard_analyses(client):
    r = client.get("/api/v1/dashboards/analyses", headers=enter(client, "coord.ai"))
    assert r.status_code == 200
    assert {"evolution", "frequent_factors", "comparison", "effectiveness"} <= set(r.json())


def _send(client, kind, content: str):
    return client.post("/api/v1/imports", headers=enter(client, "admin"), data={"kind": kind},
                        files={"file": ("load.csv", io.BytesIO(content.encode("utf-8")), "text/csv")})


def test_load_with_error_applies_nothing(client):
    r = _send(client, "INDICATORS", "student_id;academic_period;total_absences;pending_activities;"
                                        "failed_subjects_history;previous_semester_average\n"
                                        "ALU0001;2026/2;3;1;0;7.0\nALU9999;2026/2;-1;x;0;20\n")
    assert r.status_code == 201, r.text
    body = r.json()
    assert body["status"] == "WITH_ERRORS" and body["rows_with_error"] == 1
    assert {e["field"] for e in body["rejections"]} >= {"student_id"}
    assert client.post(f"/api/v1/imports/{body['load_id']}/confirmation",
                        headers=enter(client, "admin")).status_code == 409


def test_valid_load_is_applied_and_recalculates(client):
    from sqlalchemy import create_engine

    from app.calculation_service.loads import apply_next_load
    r = _send(client, "INDICATORS", "student_id;academic_period;total_absences;pending_activities;"
                                        "failed_subjects_history;previous_semester_average\n"
                                        "ALU0002;2026/2;1;0;0;8.5\n")
    body = r.json()
    assert body["status"] == "VALIDATED", body
    assert _send(client, "INDICATORS", "student_id;academic_period;total_absences;pending_activities;"
                                           "failed_subjects_history;previous_semester_average\n"
                                           "ALU0002;2026/2;1;0;0;8.5\n").status_code == 409
    assert client.post(f"/api/v1/imports/{body['load_id']}/confirmation",
                        headers=enter(client, "admin")).status_code == 200
    engine = create_engine(URLS["CALCULATION_DATABASE_URL"])
    assert apply_next_load(engine) == body["load_id"]
    engine.dispose()
    assert um(client, "SELECT total_absences FROM academic_indicators WHERE student_id = 'ALU0002'") == 1
    assert um(client, "SELECT status FROM loads WHERE load_id = :c", c=body["load_id"]) == "APPLIED"


def test_admin_does_not_change_coordination_parameter(client):
    r = client.put("/api/v1/parameters/SERVICE_INTERVAL", headers=enter(client, "admin"),
                    json={"value": 10, "justification": "Admin permission test."})
    assert r.status_code == 403


def test_minimum_grade_needs_approval_and_generates_version(client):
    admin, coord = enter(client, "admin"), enter(client, "coord.ai")
    version_before = um(client, "SELECT max(version) FROM parameter_versions")
    r = client.put("/api/v1/parameters/MINIMUM_GRADE", headers=admin,
                    json={"value": 6.5, "justification": "Test: new bylaws ask for 6.5."})
    assert r.status_code == 200 and r.json()["status"] == "PENDING"
    assert um(client, "SELECT value FROM parameters WHERE key = 'MINIMUM_GRADE'") == 6
    proposal = r.json()["proposal_id"]
    d = client.post(f"/api/v1/parameters/proposals/{proposal}/decision", headers=coord, json={"approve": True})
    assert d.status_code == 200 and d.json()["version"] == version_before + 1
    assert float(um(client, "SELECT value FROM parameters WHERE key = 'MINIMUM_GRADE'")) == 6.5
    calculate_everything(URLS["CALCULATION_DATABASE_URL"])
    assert um(client, "SELECT min(parameters_version) FROM vw_current_score") == version_before + 1
    assert um(client, "SELECT count(*) FROM risk_scores WHERE parameters_version = :v", v=version_before) > 0


def test_value_out_of_range_is_refused(client):
    r = client.put("/api/v1/parameters/SERVICE_INTERVAL", headers=enter(client, "coord.ai"),
                    json={"value": 999, "justification": "Absurd value to test the range."})
    assert r.status_code == 422


def test_dpo_answers_request(client):
    client.post("/api/v1/privacy/requests", headers=enter(client, "ALU0001"),
                 json={"kind": "PORTABILITY", "description": "I want my data."})
    payload = um(client, "SELECT subject_request_id FROM data_subject_requests WHERE kind = 'PORTABILITY' "
                         "ORDER BY subject_request_id DESC LIMIT 1")
    r = client.patch(f"/api/v1/privacy/requests/{payload}", headers=enter(client, "dpo"),
                      json={"status": "HANDLED"})
    assert r.status_code == 200
    assert um(client, "SELECT status FROM data_subject_requests WHERE subject_request_id = :p", p=payload) == "HANDLED"
    assert client.patch(f"/api/v1/privacy/requests/{payload}", headers=enter(client, "coord.ai"),
                         json={"status": "DENIED"}).status_code == 403


def test_health_answers_503_when_database_goes_down():
    from fastapi.testclient import TestClient

    from app.factory import create_service

    def broken_engine():
        raise ConnectionError("database down")

    app = create_service("api", "Test", (), broken_engine, life_signal=False)
    with TestClient(app) as tc:
        r = tc.get("/health")
    assert r.status_code == 503 and r.json()["database"] == "unavailable" and "version" in r.json()


def test_chat_and_api_are_separate_services(client, chat_client):
    header = enter(client, "coord.ai")
    assert chat_client.get("/api/v1/students", headers=header).status_code == 404
    assert client.post("/api/v1/chat/queries", headers=header, json={"text": "oi"}).status_code == 404


def test_registered_migrations(client):
    assert um(client, "SELECT count(*) FROM schema_migrations WHERE file LIKE '001_%'") == 1


def test_csv_export_protects_against_formula():
    import sys
    from pathlib import Path
    sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "dashboard"))
    import ui
    text = ui.export_csv([{"name": "=HYPERLINK(\"x\")", "n": 1}], ["name", "n"], "Test", "COORDINATION").decode("utf-8-sig")
    assert "'=HYPERLINK" in text and ("CONFIDENTIAL" in text or "LGPD" in text)
