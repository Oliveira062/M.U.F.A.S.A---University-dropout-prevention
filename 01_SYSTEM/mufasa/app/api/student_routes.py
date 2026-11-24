from datetime import datetime, timedelta
from enum import Enum
from typing import Annotated

from fastapi import APIRouter, Depends, Path, Query, Request
from pydantic import Field, field_validator
from sqlalchemy.engine import Connection

from app.api import audit, queries as sql, dashboard_queries as sqlp
from app.api.auth import User, require_profiles
from app.api.database import get_connection
from app.api.errors import DENIED_ACCESS_MSG, http_error
from app.api.schemas import METHODOLOGICAL_NOTICE, ENROLLMENT_PATTERN, Closed, Enrollment
from app.api.notify import notify, profile_users
from app.api.db_parameters import current_parameters
from app.api.permissions import (STUDENT, COORDINATION, TEACHER, FINANCE, SUPPORT_CENTER, check_student_scope)
from app.api.alert_routes import visible_event
from app.api.util import now, json_list, number, yes_no, json_value
from app.api.visibility import main_visible, visible_recommendations, crop_score
from app.calculation.score import WEIGHTS_NOTICE, FACTORS, LABELS

student_router = APIRouter(prefix="/api/v1", tags=["student"])

STATUS_FOR_STUDENT = {
    "LOW": ("No follow-up pending", "Your indicators are within what is expected."),
    "MODERATE": ("Preventive follow-up",
                 "Some factors deserve attention. The team is available if you want to talk."),
    "HIGH": ("Priority follow-up",
             "There are factors that usually make it harder to stay in the course. The team will reach out to you, "
             "and you can talk to them now."),
    "CRITICAL": ("Immediate follow-up",
                 "There are factors that need attention now. Talk to the team through the virtual learning environment or book a time."),
    "UNDETERMINED": ("Incomplete data",
                     "Data is missing to assess your situation. The registrar's office was notified to complete the record."),
}
IMMEDIATE_CHANNEL = {"text": "Talk to the team now through the virtual learning environment", "destination": "chat"}


def _student_enrollment(user: User) -> str:
    if not user.student_id:
        raise http_error(403, DENIED_ACCESS_MSG)
    return user.student_id


@student_router.get("/student/status")
def my_status(request: Request, user: User = Depends(require_profiles(STUDENT)),
              connection: Connection = Depends(get_connection)):
    enrollment = _student_enrollment(user)
    row = connection.execute(sql.CURRENT_SCORE, {"student_id": enrollment}).mappings().first()
    audit.register(request, "READ_STATUS_OWN", "ALLOWED", user=user, target_student_id=enrollment)
    if row is None:
        return {"status": "Processing", "message": "Your data is still being processed.",
                "factors": [], "supports": [], "immediate_channel": None, "notice": METHODOLOGICAL_NOTICE}
    cropped = crop_score(STUDENT, row)
    title, message = STATUS_FOR_STUDENT[cropped["level"]]
    return {
        "status": title,
        "message": message,
        "level": cropped["level"],
        "factors": [{"factor": f["factor"], "name": f["name"], "explanation": f["explanation"],
                     "actionable": f.get("actionable")} for f in cropped["factors"]
                    if f.get("points") is None or f["points"] > 0],
        "supports": [{"text": r["text"], "area": r["service_profile"], "factor": r.get("label_factor")}
                     for r in cropped["recommendations"]],
        "immediate_channel": IMMEDIATE_CHANNEL if cropped["level"] in ("HIGH", "CRITICAL") else None,
        "can_dispute": True,
        "updated_at": json_value(cropped["calculated_at"]),
        "notice": METHODOLOGICAL_NOTICE,
        "weights_notice": WEIGHTS_NOTICE,
    }


def _subjects(connection: Connection, enrollment: str) -> list[dict]:
    p = current_parameters(connection)
    output = []
    for d in connection.execute(sqlp.STUDENT_SUBJECTS, {"student_id": enrollment}).mappings():
        grade, att = number(d["final_grade"]), number(d["attendance_pct"])
        output.append({
            "class_id": d["class_id"], "subject": d["course_subject"], "academic_period": d["academic_period"],
            "shift": d["shift"], "workload_h": d["workload_h"], "professor": d["professor"],
            "exam1": number(d["exam1"]), "exam2": number(d["exam2"]), "exam3": number(d["exam3"]),
            "final_grade": grade, "attendance_pct": att, "status": d["status"],
            "minimum_below_grade": None if grade is None else grade < p["MINIMUM_GRADE"],
            "minimum_below_attendance": None if att is None else att < p["MINIMUM_ATTENDANCE"],
            "remaining_absences": None,
            "absences_note": "No data: the database does not record expected classes or absences per subject.",
        })
    return output


@student_router.get("/student/subjects")
def my_subjects(request: Request, user: User = Depends(require_profiles(STUDENT)),
                connection: Connection = Depends(get_connection)):
    enrollment = _student_enrollment(user)
    audit.register(request, "READ_SUBJECTS_OWN", "ALLOWED", user=user, target_student_id=enrollment)
    p = current_parameters(connection)
    return {"minimum_grade": p["MINIMUM_GRADE"], "minimum_attendance": p["MINIMUM_ATTENDANCE"],
            "subjects": _subjects(connection, enrollment)}


@student_router.get("/student/followup")
def my_followup(request: Request, user: User = Depends(require_profiles(STUDENT)),
                connection: Connection = Depends(get_connection)):
    enrollment = _student_enrollment(user)
    events = connection.execute(sqlp.EVENTS_VISIBLE_TO_STUDENT, {"student_id": enrollment}).mappings().all()
    appointments = connection.execute(sqlp.STUDENT_APPOINTMENTS, {"student_id": enrollment}).mappings().all()
    requests = connection.execute(sqlp.STUDENT_REQUESTS, {"student_id": enrollment}).mappings().all()
    audit.register(request, "READ_FOLLOWUP_OWN", "ALLOWED", user=user, target_student_id=enrollment)
    return {"records": [{k: json_value(v) for k, v in e.items()} for e in events],
            "appointments": [{k: json_value(v) for k, v in a.items()} for a in appointments],
            "requests": [{k: json_value(v) for k, v in s.items()} for s in requests]}


class DisputeRequest(Closed):
    factor: str = Field(max_length=30)
    description: str = Field(min_length=10, max_length=1000)

    @field_validator("factor")
    @classmethod
    def _known_factor(cls, v: str) -> str:
        if v not in FACTORS:
            raise ValueError("unknown factor")
        return v


@student_router.post("/student/disputes", status_code=201)
def dispute_factor(payload: DisputeRequest, request: Request, user: User = Depends(require_profiles(STUDENT)),
                   connection: Connection = Depends(get_connection)):
    enrollment = _student_enrollment(user)
    connection.execute(sql.REGISTER_DATA_SUBJECT_REQUEST, {
        "student_id": enrollment, "kind": "CORRECTION", "registered_at": now(),
        "description": f"Dispute of factor {LABELS.get(payload.factor, payload.factor)}: {payload.description}"[:1000]})
    course_id = connection.execute(sql.BASIC_STUDENT, {"student_id": enrollment}).mappings().first()["course_id"]
    notify(connection, profile_users(connection, COORDINATION, course_id), "DATA_TASK",
           "Data dispute by the student", f"Student ID {enrollment} asked for a check of a score factor.")
    connection.commit()
    audit.register(request, "DISPUTE_FACTOR", "ALLOWED", user=user, target_student_id=enrollment)
    return {"registered": True, "deadline": "The team checks the data and answers within 15 days."}


@student_router.get("/students/{enrollment}/subjects")
def student_subjects(enrollment: Enrollment, request: Request,
                     user: User = Depends(require_profiles(TEACHER, COORDINATION, SUPPORT_CENTER)),
                     connection: Connection = Depends(get_connection)):
    check_student_scope(request, connection, user, enrollment, "READ_SUBJECTS")
    p = current_parameters(connection)
    return {"minimum_grade": p["MINIMUM_GRADE"], "minimum_attendance": p["MINIMUM_ATTENDANCE"],
            "subjects": _subjects(connection, enrollment)}


@student_router.get("/students/{enrollment}/recommendations")
def student_recommendations(enrollment: Enrollment, request: Request,
                            user: User = Depends(require_profiles(COORDINATION, SUPPORT_CENTER)),
                            connection: Connection = Depends(get_connection)):
    check_student_scope(request, connection, user, enrollment, "READ_RECOMMENDATIONS")
    row = connection.execute(sql.CURRENT_SCORE, {"student_id": enrollment}).mappings().first()
    if row is None:
        return {"recommendations": [], "note": "This student's score has not been calculated yet."}
    return {"recommendations": visible_recommendations(user.profile, row["recommendations"]),
            "level_recommendation": row["recommendation"],
            "note": "A recommendation is a suggestion: the decision to act belongs to the team (RN05)."}


@student_router.get("/students/{enrollment}/followup")
def student_followup(enrollment: Enrollment, request: Request,
                     user: User = Depends(require_profiles(TEACHER, COORDINATION, SUPPORT_CENTER, FINANCE)),
                     connection: Connection = Depends(get_connection)):
    check_student_scope(request, connection, user, enrollment, "READ_FOLLOWUP")
    alerts = []
    for a in connection.execute(sqlp.STUDENT_ALERTS, {"student_id": enrollment}).mappings():
        if user.profile in (TEACHER, FINANCE) and a["kind"] != "PEDAGOGICAL":
            continue
        events = connection.execute(sqlp.ALERT_EVENTS, {"alert_id": a["alert_id"]}).mappings().all()
        alerts.append({**{k: json_value(v) for k, v in a.items()},
                       "events": [visible_event(user, e) for e in events]})
    appointments = []
    if user.profile in (COORDINATION, SUPPORT_CENTER):
        appointments = [{k: json_value(v) for k, v in g.items()}
                        for g in connection.execute(sqlp.STUDENT_APPOINTMENTS, {"student_id": enrollment}).mappings()]
    return {"alerts": alerts, "appointments": appointments}


@student_router.get("/classes", tags=["teacher"])
def my_classes(request: Request, user: User = Depends(require_profiles(TEACHER)),
               connection: Connection = Depends(get_connection)):
    rows = connection.execute(sqlp.TEACHER_CLASSES, {"id_professor": user.id_professor}).mappings().all()
    audit.register(request, "LIST_CLASSES", "ALLOWED", user=user)
    return [{"class_id": l["class_id"], "subject": l["course_subject"], "academic_period": l["academic_period"],
             "shift": l["shift"], "workload_h": l["workload_h"], "students": int(l["students"]),
             "critical": int(l["critical"]), "high": int(l["high"]),
             "class_average": None if l["class_average"] is None else round(float(l["class_average"]), 2),
             "class_attendance": None if l["class_attendance"] is None else round(float(l["class_attendance"]), 1)}
            for l in rows]


@student_router.get("/classes/{class_id}/students", tags=["teacher"])
def class_students(class_id: Annotated[str, Path(pattern=r"^[A-Za-z0-9_-]{2,40}$")], request: Request,
                   user: User = Depends(require_profiles(TEACHER)), connection: Connection = Depends(get_connection)):
    class_value = connection.execute(sqlp.TEACHER_CLASS, {"class_id": class_id,
                                                          "id_professor": user.id_professor}).mappings().first()
    if class_value is None:
        audit.register(request, "READ_CLASS", "DENIED", user=user)
        raise http_error(403, "You do not have access to this class, or it does not exist.")
    rows = connection.execute(sqlp.CLASS_STUDENTS, {"class_id": class_id}).mappings().all()
    audit.register(request, "READ_CLASS", "ALLOWED", user=user)
    return {"class_value": dict(class_value), "students": [{
        "enrollment": l["student_id"], "name": l["fictitious_name"], "semester": l["current_semester"],
        "final_grade": number(l["final_grade"]), "attendance_pct": number(l["attendance_pct"]),
        "status": l["status"], "level": l["level"], "score": l["score"],
        "main_factors": main_visible(TEACHER, l["main_factors"])} for l in rows]}


@student_router.get("/finance/students", tags=["finance"])
def finance_students(request: Request, limit: Annotated[int, Query(ge=1, le=200)] = 50,
                     page: Annotated[int, Query(ge=1, le=10_000)] = 1,
                     user: User = Depends(require_profiles(FINANCE)),
                     connection: Connection = Depends(get_connection)):
    salary = current_parameters(connection)["MINIMUM_WAGE"]
    rows = connection.execute(sqlp.FINANCE_STUDENTS, {"limit": limit,
                                                      "commute": (page - 1) * limit}).mappings().all()
    audit.register(request, "LIST_FINANCE", "ALLOWED", user=user)
    return [{"enrollment": l["student_id"], "name": l["fictitious_name"], "alert_id": l["alert_id"],
             "level": l["level"], "alert_status": l["status"], "deadline_at": json_value(l["deadline_at"]),
             "per_capita_income_mw": None if l["per_capita_income"] is None
             else round(float(l["per_capita_income"]) / salary, 2),
             "active_aid": yes_no(l["scholarship_aid"]),
             "recommendations": [r["text"] for r in json_list(l["recommendations"])
                                 if r["service_profile"] == "Finance"]} for l in rows]


class AppointmentRequest(Closed):
    enrollment: str | None = Field(default=None, pattern=ENROLLMENT_PATTERN, description="Team: student of the appointment")
    start: datetime
    exception_reason: str | None = Field(default=None, min_length=10, max_length=300)

    @field_validator("start")
    @classmethod
    def _time(cls, v: datetime) -> datetime:
        if v.tzinfo is None:
            raise ValueError("give the time zone")
        if v.minute not in (0, 30) or v.second or v.microsecond:
            raise ValueError("times every 30 minutes")
        return v


class AppointmentStatus(str, Enum):
    HELD = "HELD"
    CANCELED = "CANCELED"


class AppointmentChangeRequest(Closed):
    status: AppointmentStatus


def _request_student(request, connection, user: User, enrollment: str | None, operation: str) -> str:
    if user.profile == STUDENT:
        return _student_enrollment(user)
    if not enrollment:
        raise http_error(422, "Give the student ID.")
    check_student_scope(request, connection, user, enrollment, operation)
    return enrollment


@student_router.get("/appointments", tags=["appointments"])
def list_appointments(request: Request, enrollment: Annotated[str | None, Query(pattern=ENROLLMENT_PATTERN)] = None,
                      user: User = Depends(require_profiles(STUDENT, COORDINATION, SUPPORT_CENTER)),
                      connection: Connection = Depends(get_connection)):
    student = _request_student(request, connection, user, enrollment, "READ_APPOINTMENTS")
    p = current_parameters(connection)
    last = connection.execute(sqlp.ACTIVE_LAST_APPOINTMENT, {"student_id": student}).scalar()
    return {"days_minimum_interval": int(p["SERVICE_INTERVAL"]),
            "next_free_date": None if last is None
            else json_value(last + timedelta(days=int(p["SERVICE_INTERVAL"]))),
            "appointments": [{k: json_value(v) for k, v in g.items()}
                             for g in connection.execute(sqlp.STUDENT_APPOINTMENTS, {"student_id": student}).mappings()]}


@student_router.post("/appointments", status_code=201, tags=["appointments"])
def schedule(payload: AppointmentRequest, request: Request,
             user: User = Depends(require_profiles(STUDENT, COORDINATION, SUPPORT_CENTER)),
             connection: Connection = Depends(get_connection)):
    student = _request_student(request, connection, user, payload.enrollment, "SCHEDULE")
    moment = now()
    if payload.start <= moment + timedelta(hours=1):
        raise http_error(422, "Choose a time at least 1 hour ahead.")
    if payload.start > moment + timedelta(days=180):
        raise http_error(422, "Appointments only up to 180 days ahead.")

    interval = int(current_parameters(connection)["SERVICE_INTERVAL"])
    conflict = connection.execute(sqlp.NEXT_APPOINTMENT, {"student_id": student, "payload": payload.start,
                                                          "interval": interval}).scalar()
    alert = connection.execute(sql.STUDENT_OPEN_ALERT, {"student_id": student}).mappings().first()
    reason = None
    if conflict is not None:
        exception = alert is not None and alert["level"] == "CRITICAL"
        if not exception:
            next_date = conflict + timedelta(days=interval)
            connection.execute(sqlp.REGISTER_APPOINTMENT_REFUSAL, {"student_id": student, "request_for": payload.start,
                                                                   "next_date": next_date,
                                                                   "requested_by": user.user_id,
                                                                   "now": moment})
            connection.commit()
            audit.register(request, "REFUSED_APPOINTMENT", "DENIED", user=user, target_student_id=student)
            raise http_error(409, f"The minimum interval between services is {interval} days. "
                                 f"Next possible date: {next_date:%d/%m/%Y}.")
        reason = payload.exception_reason or ("Student at Critical level: service before the minimum interval "
                                              "(RN14, exception).")
        if user.profile != STUDENT and not payload.exception_reason:
            raise http_error(422, "A service before the minimum interval needs the reason for the exception.")
    new = connection.execute(sqlp.CREATE_APPOINTMENT, {
        "student_id": student, "start": payload.start, "requested_by": user.user_id, "now": moment,
        "exception_reason": reason, "alert_id": alert["alert_id"] if alert else None}).scalar()
    if alert is not None and alert["owner_id"] and alert["owner_id"] != user.user_id:
        notify(connection, [alert["owner_id"]], "ASSIGNED_ALERT", "New appointment",
               f"Student ID {student}: service booked for {payload.start:%d/%m/%Y %H:%M}.", alert["alert_id"])
    connection.commit()
    audit.register(request, "EXCEPTION_APPOINTMENT" if reason else "APPOINTMENT", "ALLOWED",
                   user=user, target_student_id=student)
    return {"appointment_id": new, "start": payload.start.isoformat(), "exception": reason}


@student_router.patch("/appointments/{appointment_id}", tags=["appointments"])
def change_appointment(appointment_id: Annotated[int, Path(ge=1)], payload: AppointmentChangeRequest,
                       request: Request, user: User = Depends(require_profiles(STUDENT, COORDINATION, SUPPORT_CENTER)),
                       connection: Connection = Depends(get_connection)):
    row = connection.execute(sqlp.APPOINTMENT_BY_ID, {"appointment_id": appointment_id}).mappings().first()
    if row is None:
        raise http_error(403, "You do not have access to this appointment, or it does not exist.")
    if user.profile == STUDENT:
        if row["student_id"] != user.student_id:
            audit.register(request, "CHANGE_APPOINTMENT", "DENIED", user=user)
            raise http_error(403, "You do not have access to this appointment, or it does not exist.")
        if payload.status != AppointmentStatus.CANCELED:
            raise http_error(403, "The student can only cancel their own appointment.")
    else:
        check_student_scope(request, connection, user, row["student_id"], "CHANGE_APPOINTMENT")
    if row["status"] != "SCHEDULED":
        raise http_error(409, "This appointment has already been completed or canceled.")
    connection.execute(sqlp.CHANGE_APPOINTMENT, {"status": payload.status.value, "now": now(),
                                                 "appointment_id": appointment_id})
    connection.commit()
    return {"updated": True}
