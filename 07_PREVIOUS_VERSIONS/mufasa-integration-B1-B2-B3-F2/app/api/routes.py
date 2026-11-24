"""
MUFASA endpoints (prefix /api/v1, SRS Annex D).

Every endpoint follows the same sequence:
1. require_profiles(...)        can the profile use the resource?
2. check_student_scope(...)     can it see THIS student? (records in the audit)
3. parameterized query          only the columns the profile can receive
4. answer                       without fields the profile cannot see
"""

from datetime import date, datetime, timedelta, timezone
from decimal import Decimal

from fastapi import APIRouter, Depends, Request
from sqlalchemy.engine import Connection

from app.api import audit, queries as sql
from app.api.auth import (User, check_password, issue_token, require_profiles,
                          get_load_token, get_current_user)
from app.api.database import get_connection
from app.api.errors import DENIED_ACCESS_MSG, http_error
from app.api.schemas import (StudentSummary, HistoricalAssessment, Consent, ScoreFactor,
                              PageFilter, ListFilters, AggregateGroup, Enrollment, StudentsPage,
                              ConsentRequest, LoginRequest, RequestRequest, AuditRecord,
                              AggregatesAnswer, ScoreAnswer, TokenAnswer, SubjectRequest,
                              RegisteredRequest, convert_date, page_filter, list_filters)
from app.api.integration import DATABASE_LEVEL, missing_factors, build_score_data
from app.api.permissions import (STUDENT, COORDINATION, BOARD, TEACHER, DPO, FINANCE,
                                SUPPORT_CENTER, REFERRED_LABEL, qualitative_band, visible_factor,
                                visible_factor_value, check_student_scope)
from app.api.security import client_ip, limiter
from app.calculation.score import calculate_student_score, explain_score, risk_by_per_capita_income
from app.config import get_configuration

router = APIRouter(prefix="/api/v1")

AGGREGATE_GROUP_MINIMUM = 5
ADULTHOOD = 18


def _now() -> datetime:
    return datetime.now(timezone.utc)


def _as_datetime(value) -> datetime | None:
    if value is None:
        return None
    if isinstance(value, datetime):
        return value if value.tzinfo else value.replace(tzinfo=timezone.utc)
    converted = datetime.fromisoformat(str(value))
    return converted if converted.tzinfo else converted.replace(tzinfo=timezone.utc)


def _yes_no(value) -> bool | None:
    if value is None:
        return None
    if isinstance(value, bool):
        return value
    return str(value).strip().lower() in ("yes", "s", "true", "1")


def _float(value) -> float | None:
    return None if value is None else float(value)


def _json_value(value):
    if isinstance(value, Decimal):
        return float(value)
    if isinstance(value, (date, datetime)):
        return value.isoformat()
    return value


def _json_row(row) -> dict | None:
    return None if row is None else {k: _json_value(v) for k, v in dict(row).items()}


def _level(value) -> str | None:
    return DATABASE_LEVEL.get(value, value) if value is not None else None


# ---------------------------------------------------------------------------
# Authentication
# ---------------------------------------------------------------------------

class _AuditUser:
    """Identifies in the audit who tried to log in, before a session exists."""

    def __init__(self, row):
        self.user_id = row["user_id"] if row else None
        self.profile = row["profile"] if row else None


LOGIN_MSG_FAILED = ("Wrong login or password. After 5 wrong attempts, access is blocked "
                    "for 15 minutes.")


@router.post("/auth/token", response_model=TokenAnswer, tags=["authentication"])
def enter(payload: LoginRequest, request: Request, connection: Connection = Depends(get_connection)):
    """The student logs in with student ID + password (RN12: the student ID alone is never enough)."""
    cfg = get_configuration()

    for key in (f"login-ip:{client_ip(request)}", f"account-login:{payload.login.lower()}"):
        allowed, wait = limiter.allow(key, cfg.login_limit_minute)
        if not allowed:
            raise http_error(429, "Too many login attempts. Wait and try again.",
                            {"Retry-After": str(wait)})

    row = connection.execute(sql.USER_BY_LOGIN, {"login": payload.login}).mappings().first()
    now = _now()

    blocked = row is not None and (_as_datetime(row["blocked_until"]) or now) > now
    password_ok = check_password(payload.password, row["password_hash"] if row else None)

    if row is None or blocked or not row["active"] or not password_ok:
        if row is not None and not blocked:
            connection.execute(sql.REGISTER_LOGIN_FAILURE, {
                "user_id": row["user_id"], "failures_max": cfg.login_max_failures,
                "block_until": now + timedelta(minutes=cfg.login_block_minutes),
            })
            connection.commit()
        audit.register(request, "LOGIN", "BLOCKED" if blocked else "DENIED",
                            user=_AuditUser(row))
        raise http_error(401, LOGIN_MSG_FAILED)

    connection.execute(sql.RESET_LOGIN_FAILURES, {"user_id": row["user_id"], "now": now})
    connection.commit()
    token, seconds = issue_token(row["user_id"], row["profile"])
    audit.register(request, "LOGIN", "ALLOWED", user=_AuditUser(row))
    return TokenAnswer(access_token=token, expires_in_seconds=seconds, profile=row["profile"])


@router.post("/auth/logout", status_code=204, tags=["authentication"])
def logout(request: Request, user: User = Depends(get_current_user),
         load: dict = Depends(get_load_token), connection: Connection = Depends(get_connection)):
    """Ends the session: the token stops being valid before it expires."""
    expires = datetime.fromtimestamp(load["exp"], tz=timezone.utc)
    connection.execute(sql.REVOKE_TOKEN, {"jti": load["jti"], "expires_at": expires})
    connection.commit()
    audit.register(request, "LOGOUT", "ALLOWED", user=user)


# ---------------------------------------------------------------------------
# Students
# ---------------------------------------------------------------------------

@router.get("/students", response_model=StudentsPage, tags=["students"])
def list_students(request: Request, filters: ListFilters = Depends(list_filters),
                  user: User = Depends(require_profiles(TEACHER, COORDINATION, SUPPORT_CENTER)),
                  connection: Connection = Depends(get_connection)):
    """Lists only the students in the profile's scope: the teacher's classes, the coordination's program."""
    query = sql.students_list_query(user.profile, filters.order.value)
    rows = connection.execute(query, {
        "semester": filters.semester,
        "id_professor": user.id_professor,
        "course_id": user.course_id,
        "limit": filters.limit,
        "commute": (filters.page - 1) * filters.limit,
    }).mappings().all()
    audit.register(request, "LIST_STUDENTS", "ALLOWED", user=user)
    return StudentsPage(page=filters.page, limit=filters.limit, items=[
        StudentSummary(enrollment=l["student_id"], name=l["fictitious_name"], semester=l["current_semester"],
                    risk_level=_level(l["risk_level"]))
        for l in rows
    ])


@router.get("/students/{enrollment}", tags=["students"])
def student_profile(enrollment: Enrollment, request: Request,
                    user: User = Depends(require_profiles(STUDENT, TEACHER, COORDINATION, SUPPORT_CENTER, FINANCE)),
                    connection: Connection = Depends(get_connection)):
    """Profile with fields hidden according to the profile (SRS Annex E)."""
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
            "attendance_pct": _float(ind["attendance_pct"]), "current_average": _float(ind["current_average"]),
            "average_trend": _float(ind["average_trend"]), "pending_activities": ind["pending_activities"],
        }

    if user.profile in (COORDINATION, SUPPORT_CENTER, FINANCE):
        soc = connection.execute(sql.RESTRICTED_SOCIOECONOMIC, {"student_id": enrollment}).mappings().first()
        cfg = get_configuration()
        if user.profile == COORDINATION:
            # Coordination sees only the qualitative range (RN07).
            band = None
            if soc and soc["per_capita_income"] is not None and cfg.minimum_wage:
                risk = risk_by_per_capita_income(float(soc["per_capita_income"]) / float(cfg.minimum_wage))
                band = qualitative_band(risk)
            answer["socioeconomic_vulnerability"] = band
        elif user.profile == FINANCE:
            answer["finance"] = None if soc is None else {
                "per_capita_income": _float(soc["per_capita_income"]), "scholarship_aid": soc["scholarship_aid"]}
        else:
            answer["socioeconomic"] = None if soc is None else {
                "per_capita_income": _float(soc["per_capita_income"]), "works": soc["works"],
                "daily_work_hours": soc["daily_work_hours"],
                "commute_time_min": soc["commute_time_min"], "scholarship_aid": soc["scholarship_aid"]}

    if user.profile == SUPPORT_CENTER:
        sens = connection.execute(sql.SUPPORT_SENSITIVE_DATA, {"student_id": enrollment}).mappings().first()
        answer["support"] = {
            "requested_psychosocial_support": _yes_no(sens["requested_psychosocial_support"]),
            "accessibility_need": _yes_no(sens["accessibility_need"]),
        }
        audit.register(request, "READ_SENSITIVE_DATA", "ALLOWED", user=user, target_student_id=enrollment)

    return answer


@router.get("/students/{enrollment}/score", response_model=ScoreAnswer, tags=["students"])
def student_score(enrollment: Enrollment, request: Request,
                   user: User = Depends(require_profiles(STUDENT, TEACHER, COORDINATION, SUPPORT_CENTER)),
                   connection: Connection = Depends(get_connection)):
    """B2 score with explanation (RN04) and the mandatory notice (RN05)."""
    check_student_scope(request, connection, user, enrollment, "READ_SCORE")

    data = build_score_data(connection, enrollment, get_configuration())
    result = calculate_student_score(data)
    missing = missing_factors(result)
    # With no expected classes in the database, B2's "0" would be read as the limit exceeded.
    result["remaining_absences"] = None

    profile = user.profile
    main = []
    for factor in result["main_factors"]:
        name = factor if visible_factor(profile, factor) else REFERRED_LABEL
        if name not in main:
            main.append(name)

    breakdown = []
    for factor, risk in result["breakdown"].items():
        if not visible_factor(profile, factor):
            continue
        if visible_factor_value(profile, factor):
            breakdown.append(ScoreFactor(factor=factor, risk=risk))
        else:
            breakdown.append(ScoreFactor(factor=factor, risk=None, band=qualitative_band(risk)))

    explanation = explain_score({**result, "main_factors": main})

    return ScoreAnswer(
        enrollment=enrollment, score=result["score"], level=result["level"],
        completeness=result["completeness"], main_factors=main, breakdown=breakdown,
        remaining_absences=None, attendance_overlap=result["attendance_overlap"],
        recommendation=result["recommendation"], explanation=explanation, missing_data=missing,
    )


@router.get("/students/{enrollment}/history", response_model=list[HistoricalAssessment], tags=["students"])
def student_history(enrollment: Enrollment, request: Request,
                       user: User = Depends(require_profiles(STUDENT, TEACHER, COORDINATION, SUPPORT_CENTER)),
                       connection: Connection = Depends(get_connection)):
    """Historical series of risk assessments (RN09)."""
    check_student_scope(request, connection, user, enrollment, "READ_HISTORY")
    rows = connection.execute(sql.RISK_HISTORY, {"student_id": enrollment, "limit": 200}).mappings().all()
    return [HistoricalAssessment(
        academic_period=l["academic_period"], kind=l["kind"], assessment_date=convert_date(l["assessment_date"]),
        dropout_risk_pct=_float(l["dropout_risk_pct"]), risk_level=_level(l["risk_level"]),
    ) for l in rows]


@router.get("/indicators/aggregates", response_model=AggregatesAnswer, tags=["indicators"])
def aggregated_indicators(request: Request, user: User = Depends(require_profiles(COORDINATION, BOARD)),
                          connection: Connection = Depends(get_connection)):
    """Count by term and level, without name or student ID; groups < 5 suppressed (CA19)."""
    course_id = user.course_id if user.profile == COORDINATION else None
    if user.profile == COORDINATION and course_id is None:
        raise http_error(403, "Your user is not linked to a course.")
    rows = connection.execute(sql.AGGREGATES_BY_SEMESTER, {
        "course_id": course_id, "group_minimum": AGGREGATE_GROUP_MINIMUM}).mappings().all()
    audit.register(request, "READ_AGGREGATES", "ALLOWED", user=user)
    return AggregatesAnswer(minimum_by_group=AGGREGATE_GROUP_MINIMUM, groups=[
        AggregateGroup(semester=l["semester"], risk_level=_level(l["risk_level"]), total=l["total"])
        for l in rows])


# ---------------------------------------------------------------------------
# Privacy: data subject rights (LGPD arts. 8, 11, 14, 18, 20)
# ---------------------------------------------------------------------------

@router.get("/privacy/my-data", tags=["privacy"])
def my_data(request: Request, user: User = Depends(require_profiles(STUDENT)),
               connection: Connection = Depends(get_connection)):
    """Access and portability: everything the system keeps about the student themselves (art. 18, II and V)."""
    student_id = user.student_id
    registration = connection.execute(sql.MY_DATA_REGISTRATION, {"student_id": student_id}).mappings().first()
    socio = connection.execute(sql.MY_DATA_SOCIOECONOMIC, {"student_id": student_id}).mappings().first()
    enrollments = connection.execute(sql.MY_DATA_ENROLLMENTS, {"student_id": student_id}).mappings().all()
    assessments = connection.execute(sql.RISK_HISTORY, {"student_id": student_id, "limit": 200}).mappings().all()
    consent = connection.execute(sql.STUDENT_CONSENTS, {"student_id": student_id}).mappings().all()
    audit.register(request, "EXPORT_MY_DATA", "ALLOWED", user=user, target_student_id=student_id)

    return {
        "generated_at": _now().isoformat(),
        "controller": "University (data controller). Contact: the institution's data protection officer.",
        "registration": _json_row(registration),
        "socioeconomic": _json_row(socio),
        "enrollments": [_json_row(m) for m in enrollments],
        "risk_assessments": [_json_row(a) for a in assessments],
        "consents": [_json_row(c) for c in consent],
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
    """
    Grants or revokes consent for health data (art. 11, I).
    Revoking is always possible and brings no harm to the student (art. 8, par. 5).
    """
    if payload.granted:
        age = connection.execute(sql.STUDENT_AGE, {"student_id": user.student_id}).scalar()
        if age is None or int(age) < ADULTHOOD:
            raise http_error(422, "For students under 18, consent is given by the legal guardian, "
                                 "with a signed form delivered to the registrar's office (LGPD, art. 14).")
    connection.execute(sql.REGISTER_CONSENT, {
        "student_id": user.student_id, "purpose": payload.purpose.value, "granted": payload.granted,
        "granted_by": "DATA_SUBJECT", "term_version": payload.term_version, "registered_at": _now(),
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
    """Correction, deletion, review of an automated decision and the other art. 18 rights."""
    connection.execute(sql.REGISTER_DATA_SUBJECT_REQUEST, {
        "student_id": user.student_id, "kind": payload.kind.value, "description": payload.description,
        "registered_at": _now()})
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
def read_audit(request: Request, page: PageFilter = Depends(page_filter),
                  user: User = Depends(require_profiles(DPO)),
                  connection: Connection = Depends(get_connection)):
    """Access trail for the data protection officer. Reading the trail is also recorded."""
    rows = connection.execute(sql.LIST_AUDIT, {
        "student_id": None, "limit": page.limit,
        "commute": (page.page - 1) * page.limit}).mappings().all()
    audit.register(request, "READ_AUDIT", "ALLOWED", user=user)
    return [AuditRecord(**l) for l in rows]
