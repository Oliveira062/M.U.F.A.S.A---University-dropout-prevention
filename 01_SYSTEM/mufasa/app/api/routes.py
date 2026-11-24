from datetime import datetime, timedelta, timezone

from fastapi import APIRouter, Depends, Request
from sqlalchemy.engine import Connection

from app.api import audit, queries as sql
from app.api.auth import (TERM_VERSION, User, check_password, issue_token, require_profiles,
                          get_load_token, get_current_user)
from app.api.cipher import UnavailableKey, decrypt
from app.api.database import get_connection
from app.api.errors import DENIED_ACCESS_MSG, http_error
from app.api.schemas import (METHODOLOGICAL_NOTICE, StudentSummary, Consent, AuditFilter, PageFilter,
                             ListFilters, AggregateGroup, Enrollment, StudentsPage, ConsentRequest,
                             LoginRequest, RequestRequest, AuditRecord, AggregatesAnswer, TokenAnswer,
                             SubjectRequest, RegisteredRequest, audit_filter, page_filter, list_filters)
from app.api.db_parameters import current_parameters
from app.api.permissions import (STUDENT, COORDINATION, BOARD, TEACHER, DPO, FINANCE,
                                 SUPPORT_CENTER, qualitative_band, check_student_scope)
from app.api.security import client_ip, limiter
from app.api.util import now, as_datetime, json_row, number, yes_no, json_value
from app.api.visibility import crop_score
from app.calculation.score import WEIGHTS_NOTICE, explain_score, risk_by_per_capita_income
from app.config import get_configuration

router = APIRouter(prefix="/api/v1")

ADULTHOOD = 18


class _AuditUser:

    def __init__(self, row):
        self.user_id = row["user_id"] if row else None
        self.profile = row["profile"] if row else None


def _blocked_demo(row) -> bool:
    return bool(row and row["demo"]) and get_configuration().in_production


LOGIN_MSG_FAILED = ("Wrong login or password. After 5 wrong attempts, access is blocked "
                    "for 15 minutes.")


@router.post("/auth/token", response_model=TokenAnswer, tags=["authentication"])
def enter(payload: LoginRequest, request: Request, connection: Connection = Depends(get_connection)):
    cfg = get_configuration()

    for key in (f"login-ip:{client_ip(request)}", f"account-login:{payload.login.lower()}"):
        allowed, wait = limiter.allow(key, cfg.login_limit_minute)
        if not allowed:
            raise http_error(429, "Too many login attempts. Wait and try again.",
                             {"Retry-After": str(wait)})

    row = connection.execute(sql.USER_BY_LOGIN, {"login": payload.login}).mappings().first()
    moment = now()

    blocked = row is not None and (as_datetime(row["blocked_until"]) or moment) > moment
    password_ok = check_password(payload.password, row["password_hash"] if row else None)

    profile_ok = row is not None and row["profile"] == payload.profile.value
    if (row is None or blocked or not row["active"] or not password_ok or not profile_ok
            or _blocked_demo(row)):
        if row is not None and not blocked:
            connection.execute(sql.REGISTER_LOGIN_FAILURE, {
                "user_id": row["user_id"], "failures_max": cfg.login_max_failures,
                "block_until": moment + timedelta(minutes=cfg.login_block_minutes),
            })
            connection.commit()
        audit.register(request, "LOGIN", "BLOCKED" if blocked else "DENIED",
                       user=_AuditUser(row))
        raise http_error(401, LOGIN_MSG_FAILED)

    connection.execute(sql.RESET_LOGIN_FAILURES, {"user_id": row["user_id"], "now": moment})
    connection.commit()
    token, seconds = issue_token(row["user_id"], row["profile"])
    audit.register(request, "LOGIN", "ALLOWED", user=_AuditUser(row))
    state = connection.execute(sql.USER_BY_ID, {"user_id": row["user_id"]}).mappings().first()
    return TokenAnswer(access_token=token, expires_in_seconds=seconds, profile=row["profile"],
                       must_change_password=bool(state["must_change_password"]),
                       pending_term=state["version_term"] != TERM_VERSION)


@router.post("/auth/logout", status_code=204, tags=["authentication"])
def logout(request: Request, user: User = Depends(get_current_user),
           load: dict = Depends(get_load_token), connection: Connection = Depends(get_connection)):
    expires = datetime.fromtimestamp(load["exp"], tz=timezone.utc)
    connection.execute(sql.REVOKE_TOKEN, {"jti": load["jti"], "expires_at": expires})
    connection.commit()
    audit.register(request, "LOGOUT", "ALLOWED", user=user)


@router.get("/students", response_model=StudentsPage, tags=["students"])
def list_students(request: Request, filters: ListFilters = Depends(list_filters),
                  user: User = Depends(require_profiles(TEACHER, COORDINATION, SUPPORT_CENTER)),
                  connection: Connection = Depends(get_connection)):
    values = {
        "semester": filters.semester,
        "level": filters.level.value if filters.level else None,
        "search": f"%{filters.search.lower()}%" if filters.search else None,
        "user_id": user.user_id,
        "id_professor": user.id_professor,
        "course_id": user.course_id,
    }
    total = connection.execute(sql.students_total_query(user.profile), values).scalar()
    rows = connection.execute(sql.students_list_query(user.profile, filters.order.value), {
        **values, "limit": filters.limit, "commute": (filters.page - 1) * filters.limit,
    }).mappings().all()
    audit.register(request, "LIST_STUDENTS", "ALLOWED", user=user)
    return StudentsPage(page=filters.page, limit=filters.limit, total=total, items=[
        StudentSummary(enrollment=l["student_id"], name=l["fictitious_name"], semester=l["current_semester"],
                       risk_level=l["level"], score=l["score"])
        for l in rows
    ])


@router.get("/students/{enrollment}", tags=["students"])
def student_profile(enrollment: Enrollment, request: Request,
                    user: User = Depends(require_profiles(STUDENT, TEACHER, COORDINATION, SUPPORT_CENTER, FINANCE)),
                    connection: Connection = Depends(get_connection)):
    check_student_scope(request, connection, user, enrollment, "READ_PROFILE")

    base = connection.execute(sql.BASIC_STUDENT, {"student_id": enrollment}).mappings().first()
    if base is None:
        raise http_error(403, DENIED_ACCESS_MSG)
    answer = {"enrollment": base["student_id"], "name": base["fictitious_name"],
              "course": base["course"], "semester": base["current_semester"]}

    if user.profile in (STUDENT, TEACHER, COORDINATION, SUPPORT_CENTER):
        ind = connection.execute(sql.CURRENT_INDICATORS, {"student_id": enrollment}).mappings().first()
        answer["academic"] = None if ind is None else {
            "academic_period": ind["academic_period"], "total_absences": ind["total_absences"],
            "attendance_pct": number(ind["attendance_pct"]), "current_average": number(ind["current_average"]),
            "average_trend": number(ind["average_trend"]), "pending_activities": ind["pending_activities"],
        }

    if user.profile in (COORDINATION, SUPPORT_CENTER, FINANCE):
        soc = connection.execute(sql.RESTRICTED_SOCIOECONOMIC, {"student_id": enrollment}).mappings().first()
        p = current_parameters(connection)
        minimum_wage = p["MINIMUM_WAGE"]
        if user.profile == COORDINATION:
            band = None
            if soc and soc["per_capita_income"] is not None:
                risk = risk_by_per_capita_income(float(soc["per_capita_income"]) / minimum_wage,
                                                 active_aid=yes_no(soc["scholarship_aid"]) or False, p=p)
                band = qualitative_band(risk)
            answer["socioeconomic_vulnerability"] = band
        elif user.profile == FINANCE:
            answer["finance"] = None if soc is None else {
                "per_capita_income": number(soc["per_capita_income"]),
                "per_capita_income_mw": None if soc["per_capita_income"] is None
                else round(float(soc["per_capita_income"]) / minimum_wage, 2),
                "scholarship_aid": soc["scholarship_aid"]}
        else:
            answer["socioeconomic"] = None if soc is None else {
                "per_capita_income": number(soc["per_capita_income"]), "works": soc["works"],
                "daily_work_hours": soc["daily_work_hours"],
                "commute_time_min": soc["commute_time_min"], "scholarship_aid": soc["scholarship_aid"]}

    if user.profile == SUPPORT_CENTER:
        answer["support"] = read_support(connection, enrollment)
        audit.register(request, "READ_SENSITIVE_DATA", "ALLOWED", user=user, target_student_id=enrollment)

    if user.profile in (TEACHER, COORDINATION, SUPPORT_CENTER, FINANCE):
        alert = connection.execute(sql.STUDENT_OPEN_ALERT, {"student_id": enrollment}).mappings().first()
        answer["alert"] = None if alert is None else {
            "alert_id": alert["alert_id"], "level": alert["level"], "status": alert["status"],
            "deadline_at": json_value(alert["deadline_at"])}

    return answer


def read_support(connection: Connection, enrollment: str) -> dict:
    row = connection.execute(sql.SUPPORT_SENSITIVE_DATA, {"student_id": enrollment}).mappings().first()
    if row is None:
        return {"available": True, "requested_psychosocial_support": None, "accessibility_need": None}
    try:
        return {"available": True, **decrypt(row["encrypted_data"])}
    except UnavailableKey:
        return {"available": False, "reason": "Support data unavailable at the moment."}


@router.get("/students/{enrollment}/score", tags=["students"])
def student_score(enrollment: Enrollment, request: Request,
                  user: User = Depends(require_profiles(STUDENT, TEACHER, COORDINATION, SUPPORT_CENTER, FINANCE)),
                  connection: Connection = Depends(get_connection)):
    check_student_scope(request, connection, user, enrollment, "READ_SCORE")
    row = connection.execute(sql.CURRENT_SCORE, {"student_id": enrollment}).mappings().first()
    if row is None:
        return {"enrollment": enrollment, "score": None, "level": "PENDING", "factors": [],
                "explanation": "This student's score has not been calculated yet.", "notice": METHODOLOGICAL_NOTICE,
                "weights_notice": WEIGHTS_NOTICE}
    cropped = crop_score(user.profile, row)
    explanation = explain_score({**cropped, "overlap_reason": cropped["overlap_reason"]})
    if user.profile == FINANCE:
        cropped["modifiers"] = []
    return {"enrollment": enrollment, **{k: json_value(v) for k, v in cropped.items()},
            "explanation": explanation, "notice": METHODOLOGICAL_NOTICE, "weights_notice": WEIGHTS_NOTICE}


@router.get("/students/{enrollment}/history", tags=["students"])
def student_history(enrollment: Enrollment, request: Request,
                    user: User = Depends(require_profiles(STUDENT, TEACHER, COORDINATION, SUPPORT_CENTER)),
                    connection: Connection = Depends(get_connection)):
    check_student_scope(request, connection, user, enrollment, "READ_HISTORY")
    rows = connection.execute(sql.SCORE_HISTORY, {"student_id": enrollment, "limit": 500}).mappings().all()
    return [{"calculated_at": json_value(l["calculated_at"]), "score": l["score"], "level": l["level"],
             "origin_level": l["origin_level"], "completeness": number(l["completeness"]),
             "model_version": l["model_version"], "parameters_version": f"param-v{l['parameters_version']}"}
            for l in rows]


@router.get("/indicators/aggregates", response_model=AggregatesAnswer, tags=["indicators"])
def aggregated_indicators(request: Request, user: User = Depends(require_profiles(COORDINATION, BOARD)),
                          connection: Connection = Depends(get_connection)):
    course_id = user.course_id if user.profile == COORDINATION else None
    if user.profile == COORDINATION and course_id is None:
        raise http_error(403, "Your user is not linked to a course.")
    minimum = int(current_parameters(connection)["GROUP_MINIMUM"])
    rows = connection.execute(sql.AGGREGATES_BY_SEMESTER, {
        "course_id": course_id, "group_minimum": minimum}).mappings().all()
    audit.register(request, "READ_AGGREGATES", "ALLOWED", user=user)
    return AggregatesAnswer(minimum_by_group=minimum, groups=[
        AggregateGroup(semester=l["semester"], risk_level=l["risk_level"], total=l["total"])
        for l in rows])


@router.get("/privacy/my-data", tags=["privacy"])
def my_data(request: Request, user: User = Depends(require_profiles(STUDENT)),
            connection: Connection = Depends(get_connection)):
    student_id = user.student_id
    registration = connection.execute(sql.MY_DATA_REGISTRATION, {"student_id": student_id}).mappings().first()
    socio = connection.execute(sql.MY_DATA_SOCIOECONOMIC, {"student_id": student_id}).mappings().first()
    enrollments = connection.execute(sql.MY_DATA_ENROLLMENTS, {"student_id": student_id}).mappings().all()
    assessments = connection.execute(sql.RISK_HISTORY, {"student_id": student_id, "limit": 200}).mappings().all()
    scores = connection.execute(sql.SCORE_HISTORY, {"student_id": student_id, "limit": 500}).mappings().all()
    consent = connection.execute(sql.STUDENT_CONSENTS, {"student_id": student_id}).mappings().all()
    support = read_support(connection, student_id)
    audit.register(request, "EXPORT_MY_DATA", "ALLOWED", user=user, target_student_id=student_id)

    return {
        "generated_at": now().isoformat(),
        "controller": "University (data controller). Contact: the institution's data protection officer.",
        "registration": json_row(registration),
        "socioeconomic": json_row(socio),
        "support": support,
        "enrollments": [json_row(m) for m in enrollments],
        "calculated_scores": [json_row(a) for a in scores],
        "b1_risk_assessments": [json_row(a) for a in assessments],
        "consents": [json_row(c) for c in consent],
    }


@router.get("/privacy/consents", response_model=list[Consent], tags=["privacy"])
def list_consents(user: User = Depends(require_profiles(STUDENT)),
                  connection: Connection = Depends(get_connection)):
    rows = connection.execute(sql.STUDENT_CONSENTS, {"student_id": user.student_id}).mappings().all()
    return [Consent(**{**l, "granted": bool(l["granted"])}) for l in rows]


@router.post("/privacy/consents", status_code=201, tags=["privacy"])
def register_consent(payload: ConsentRequest, request: Request,
                     user: User = Depends(require_profiles(STUDENT)),
                     connection: Connection = Depends(get_connection)):
    if payload.granted:
        age = connection.execute(sql.STUDENT_AGE, {"student_id": user.student_id}).scalar()
        if age is None or int(age) < ADULTHOOD:
            raise http_error(422, "For students under 18, consent is given by the legal guardian, "
                                 "with a signed form delivered to the registrar's office (LGPD, art. 14).")
    connection.execute(sql.REGISTER_CONSENT, {
        "student_id": user.student_id, "purpose": payload.purpose.value, "granted": payload.granted,
        "granted_by": "DATA_SUBJECT", "term_version": payload.term_version, "registered_at": now(),
        "user_id": user.user_id,
    })
    connection.commit()
    audit.register(request, "CONSENT_" + ("GRANTED" if payload.granted else "REVOKED"),
                   "ALLOWED", user=user, target_student_id=user.student_id)
    return {"registered": True}


@router.post("/privacy/requests", status_code=201, response_model=RegisteredRequest, tags=["privacy"])
def request_right(payload: RequestRequest, request: Request,
                  user: User = Depends(require_profiles(STUDENT)),
                  connection: Connection = Depends(get_connection)):
    connection.execute(sql.REGISTER_DATA_SUBJECT_REQUEST, {
        "student_id": user.student_id, "kind": payload.kind.value, "description": payload.description,
        "registered_at": now()})
    connection.commit()
    audit.register(request, "DATA_SUBJECT_REQUEST", "ALLOWED", user=user, target_student_id=user.student_id)
    return RegisteredRequest()


@router.get("/privacy/requests", response_model=list[SubjectRequest], tags=["privacy"])
def list_requests(request: Request, page: PageFilter = Depends(page_filter),
                  user: User = Depends(require_profiles(DPO)),
                  connection: Connection = Depends(get_connection)):
    rows = connection.execute(sql.LIST_DATA_SUBJECT_REQUESTS, {
        "limit": page.limit, "commute": (page.page - 1) * page.limit}).mappings().all()
    audit.register(request, "LIST_REQUESTS", "ALLOWED", user=user)
    return [SubjectRequest(**l) for l in rows]


@router.get("/audit", response_model=list[AuditRecord], tags=["audit"])
def read_audit(request: Request, filter_value: AuditFilter = Depends(audit_filter),
               user: User = Depends(require_profiles(DPO)),
               connection: Connection = Depends(get_connection)):
    rows = connection.execute(sql.LIST_AUDIT, {
        "student_id": filter_value.enrollment, "profile": filter_value.profile.value if filter_value.profile else None,
        "result": filter_value.result.value if filter_value.result else None, "operation": filter_value.operation, "de": filter_value.de, "until": filter_value.until,
        "limit": filter_value.limit, "commute": (filter_value.page - 1) * filter_value.limit}).mappings().all()
    audit.register(request, "READ_AUDIT", "ALLOWED", user=user)
    return [AuditRecord(**l) for l in rows]
