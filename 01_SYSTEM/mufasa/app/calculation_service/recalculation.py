import json
import logging
from collections import defaultdict
from datetime import datetime, timedelta, timezone

from sqlalchemy.engine import Connection

from app.calculation.parameters import Parameters
from app.calculation.recommendations import generate_recommendations
from app.calculation.score import LEVEL_NAMES, calculate_student_score, calculate_trend
from app.calculation_service import calculation_queries as sql
from app.calculation_service.data import build_data

log = logging.getLogger("mufasa.calculation")

ALERT_LEVELS = ("HIGH", "CRITICAL")


def add_business_days(start: datetime, days: int) -> datetime:
    current = start
    remaining = int(days)
    while remaining > 0:
        current += timedelta(days=1)
        if current.weekday() < 5:
            remaining -= 1
    return current


def level_deadline(level: str, now: datetime, p: Parameters) -> datetime:
    if level == "CRITICAL":
        return now + timedelta(hours=p["SLA_CRITICAL_HOURS"])
    if level == "HIGH":
        return add_business_days(now, p["SLA_HIGH_BUSINESS_DAYS"])
    return add_business_days(now, p["SLA_DATA_BUSINESS_DAYS"])


def _json(value) -> str:
    return json.dumps(value, ensure_ascii=False, default=float)


def _as_list(value):
    if value is None:
        return []
    return json.loads(value) if isinstance(value, str) else value


def _changed(result: dict, last, version: int) -> bool:
    if last is None:
        return True
    return (result["score"], result["level"], result["origin_level"], version,
            result["overlap_reason"], _json(result["factors"]), _json(result["modifiers"])) != (
        last["score"], last["level"], last["origin_level"], last["parameters_version"],
        last["overlap_reason"], _json(_as_list(last["factors"])),
        _json(_as_list(last["modifiers"])))


class Notices:

    def __init__(self):
        self.new = defaultdict(lambda: defaultdict(int))
        self.personal = []
        self.data_tasks = 0

    def send(self, connection: Connection, now: datetime) -> None:
        for course_id, by_level in self.new.items():
            total = sum(by_level.values())
            parts = [f"{q} {LEVEL_NAMES[n]}" for n, q in sorted(by_level.items(), key=lambda x: x[0] != "CRITICAL")]
            text = f"{total} student(s) entered the alert queue: " + ", ".join(parts) + "."
            for person in connection.execute(sql.COURSE_TEAM, {"course_id": course_id}).mappings():
                connection.execute(sql.CREATE_NOTIFICATION, {"user_id": person["user_id"], "now": now,
                                                             "kind": "NEW_ALERT", "title": "New alerts",
                                                             "text": text[:300], "alert_id": None})
        for user_id, kind, title, text, alert_id in self.personal:
            connection.execute(sql.CREATE_NOTIFICATION, {"user_id": user_id, "now": now, "kind": kind,
                                                         "title": title, "text": text[:300], "alert_id": alert_id})
        if self.data_tasks:
            for admin in connection.execute(sql.ADMINISTRATION).mappings():
                connection.execute(sql.CREATE_NOTIFICATION, {
                    "user_id": admin["user_id"], "now": now, "kind": "DATA_TASK",
                    "title": "Data correction tasks",
                    "text": f"{self.data_tasks} student(s) without enough data for the score (below 40%).",
                    "alert_id": None})


def _update_alerts(connection, student_id, id_score, result, previous_level, context, p, now, notices):
    level = result["level"]

    task = connection.execute(sql.OPEN_ALERT, {"student_id": student_id, "kind": "DATA"}).mappings().first()
    if level == "UNDETERMINED" and task is None:
        task_id = connection.execute(sql.CREATE_ALERT, {
            "student_id": student_id, "id_score": id_score, "kind": "DATA", "level": "UNDETERMINED", "now": now,
            "deadline_at": level_deadline("UNDETERMINED", now, p), "owner_id": None}).scalar_one()
        connection.execute(sql.REGISTER_EVENT, {"alert_id": task_id, "now": now, "kind": "CREATED",
                                                "description": "Completeness below 40%: data correction task."})
        notices.data_tasks += 1
    elif level != "UNDETERMINED" and task is not None:
        connection.execute(sql.CLOSE_DATA_TASK, {"alert_id": task["alert_id"], "now": now})
        connection.execute(sql.REGISTER_EVENT, {"alert_id": task["alert_id"], "now": now, "kind": "CLOSED",
                                                "description": "Data completed; the score was calculated."})

    alert = connection.execute(sql.OPEN_ALERT, {"student_id": student_id, "kind": "PEDAGOGICAL"}).mappings().first()
    if alert is None:
        if level not in ALERT_LEVELS:
            return
        owner = None
        if level == "CRITICAL":
            owner = connection.execute(sql.AVAILABLE_SSC, {
                "course_id": context["course_id"], "ceiling": int(p["OWNER_ALERT_CEILING"])}).scalar()
        alert_id = connection.execute(sql.CREATE_ALERT, {
            "student_id": student_id, "id_score": id_score, "kind": "PEDAGOGICAL", "level": level, "now": now,
            "deadline_at": level_deadline(level, now, p), "owner_id": owner}).scalar_one()
        description = f"{LEVEL_NAMES[level]} level (score {result['score'] if result['score'] is not None else '—'})."
        if result.get("overlap_reason"):
            description += f" {result['overlap_reason']}."
        connection.execute(sql.REGISTER_EVENT, {"alert_id": alert_id, "now": now, "kind": "CREATED",
                                                "description": description[:1000]})
        if owner is not None:
            connection.execute(sql.REGISTER_EVENT, {
                "alert_id": alert_id, "now": now, "kind": "ASSIGNED",
                "description": "Critical alert automatically assigned to the support center (RN02)."})
            notices.personal.append((owner, "ASSIGNED_ALERT", "Alert assigned to you",
                                     "A Critical alert was assigned to you. Deadline of 48 hours.", alert_id))
        notices.new[context["course_id"]][level] += 1
        return

    if alert["level"] == level:
        return
    deadline = alert["deadline_at"]
    if level == "CRITICAL" and alert["status"] == "OPEN":
        deadline = min(deadline, level_deadline("CRITICAL", now, p))
    connection.execute(sql.UPDATE_ALERT_LEVEL, {"alert_id": alert["alert_id"], "level": level,
                                                "deadline_at": deadline, "now": now})
    connection.execute(sql.REGISTER_EVENT, {
        "alert_id": alert["alert_id"], "now": now, "kind": "CHANGED_LEVEL",
        "description": f"Level changed from {LEVEL_NAMES.get(alert['level'], alert['level'])} to "
                     f"{LEVEL_NAMES[level]} (score {result['score'] if result['score'] is not None else '—'})."})
    if alert["owner_id"]:
        notices.personal.append((alert["owner_id"], "LEVEL_ALERT", "Alert level changed",
                                 f"A student under your responsibility moved to the {LEVEL_NAMES[level]} level.",
                                 alert["alert_id"]))


def process_batch(connection: Connection, p: Parameters, batch: int = 200) -> int:
    now = datetime.now(timezone.utc)
    today = now.date()
    pending = connection.execute(sql.READ_QUEUE, {"batch": batch}).mappings().all()
    notices = Notices()
    for item in pending:
        student_id = item["student_id"]
        try:
            data, context = build_data(connection, student_id, p, today)
        except LookupError:
            connection.execute(sql.REMOVE_FROM_QUEUE, {"student_id": student_id, "read_at": item["queued_at"]})
            continue
        result = calculate_student_score(data, p)
        result["recommendations"] = generate_recommendations(result, data, context["underage"])

        recent = connection.execute(sql.RECENT_SCORES, {"student_id": student_id}).mappings().all()
        last = recent[0] if recent else None
        if _changed(result, last, p.version):
            series = [r["score"] for r in reversed(recent)] + [result["score"]]
            id_score = connection.execute(sql.SAVE_SCORE, {
                "student_id": student_id, "score": result["score"], "level": result["level"],
                "completeness": result["completeness"], "main_factors": _json(result["main_factors"]),
                "breakdown": _json(result["breakdown"]), "contributions": _json(result["contributions"]),
                "attendance_overlap": result["attendance_overlap"],
                "recommendation": result["recommendation"], "origin_level": result["origin_level"],
                "overlap_reason": (result["overlap_reason"] or None) and result["overlap_reason"][:400],
                "partial": result["partial"], "factors": _json(result["factors"]),
                "modifiers": _json(result["modifiers"]),
                "recommendations": _json(result["recommendations"]), "trend": calculate_trend(series),
                "previous_score": last["score"] if last else None,
                "previous_level": last["level"] if last else None, "parameters_version": p.version,
                "model_version": result["model_version"], "reason": item["reason"][:40], "calculated_at": now,
            }).scalar_one()
            _update_alerts(connection, student_id, id_score, result, last["level"] if last else None,
                           context, p, now, notices)
        connection.execute(sql.REMOVE_FROM_QUEUE, {"student_id": student_id, "read_at": item["queued_at"]})
    notices.send(connection, now)
    return len(pending)


def warn_overdue_deadlines(connection: Connection) -> int:
    now = datetime.now(timezone.utc)
    overdue = connection.execute(sql.OVERDUE_ALERTS_WITHOUT_NOTICE, {"now": now}).mappings().all()
    for a in overdue:
        connection.execute(sql.REGISTER_EVENT, {"alert_id": a["alert_id"], "now": now, "kind": "OVERDUE_DEADLINE",
                                                "description": "First service deadline passed with no action recorded."})
        destinations = {a["owner_id"]} if a["owner_id"] else set()
        destinations |= {p["user_id"] for p in connection.execute(sql.COURSE_TEAM, {"course_id": a["course_id"]})
                         .mappings() if p["profile"] == "COORDINATION"}
        for user_id in destinations:
            connection.execute(sql.CREATE_NOTIFICATION, {
                "user_id": user_id, "now": now, "kind": "OVERDUE_DEADLINE", "title": "Deadline passed",
                "text": f"A {LEVEL_NAMES[a['level']]} alert passed the deadline with no service recorded.",
                "alert_id": a["alert_id"]})
    return len(overdue)
