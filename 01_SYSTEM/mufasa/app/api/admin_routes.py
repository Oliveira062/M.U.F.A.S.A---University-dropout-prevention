import hashlib
import json
from collections import defaultdict
from enum import Enum
from typing import Annotated

from fastapi import APIRouter, Depends, File, Form, Path, Query, Request, UploadFile
from pydantic import Field
from sqlalchemy.engine import Connection
from sqlalchemy.exc import IntegrityError

from app.api import audit, dashboard_queries as sqlp
from app.api.auth import User, require_profiles, generate_password_hash
from app.api.database import get_connection
from app.api.errors import http_error
from app.api.schemas import ENROLLMENT_PATTERN, Closed, Profile
from app.api.notify import notify, profile_users
from app.api.permissions import ADMIN, STUDENT, COORDINATION, TEACHER, DPO, SUPPORT_CENTER
from app.api.passwords import generate_temporary_password
from app.api.util import now, as_datetime, number, json_value
from app.api.load_validation import MAXIMUM_SIZE, InvalidFile, read_csv, validate
from app.calculation.parameters import CATALOG, consistency_problems

router_admin = APIRouter(prefix="/api/v1", tags=["administration"])

MAXIMUM_SIGNAL_S = 60

NEEDS_COORDINATION_APPROVAL = {"MINIMUM_GRADE", "COMFORTABLE_GRADE", "CRITICAL_GRADE",
                               "LOW_CUTOFF", "MODERATE_CUTOFF", "HIGH_CUTOFF"}
CHANGED_BY_COORDINATION = {"SERVICE_INTERVAL", "OWNER_ALERT_CEILING"}


def who_changes(key: str, editable: bool) -> str:
    if not editable:
        return "Only through formal recalibration (Annex A.9)"
    if key in CHANGED_BY_COORDINATION:
        return "Coordination"
    if key in NEEDS_COORDINATION_APPROVAL:
        return "Administration, with coordination approval"
    return "Administration"


class UserRequest(Closed):
    login: str = Field(min_length=3, max_length=64, pattern=r"^[A-Za-z0-9._@-]+$")
    name: str = Field(min_length=3, max_length=120)
    email: str | None = Field(default=None, max_length=160, pattern=r"^[^@\s]+@[^@\s]+\.[^@\s]+$")
    profile: Profile
    course_id: str | None = Field(default=None, pattern=r"^[A-Z0-9]{2,12}$")
    id_professor: str | None = Field(default=None, pattern=r"^[A-Za-z0-9_-]{2,40}$")
    student_id: str | None = Field(default=None, pattern=ENROLLMENT_PATTERN)


class UserChangeRequest(Closed):
    active: bool | None = None
    reset_password: bool = False
    unlock: bool = False


@router_admin.get("/admin/users")
def list_users(request: Request, profile: Profile | None = None,
               search: Annotated[str | None, Query(max_length=60, pattern=r"^[\w .@-]*$")] = None,
               limit: Annotated[int, Query(ge=1, le=200)] = 50,
               page: Annotated[int, Query(ge=1, le=10_000)] = 1,
               user: User = Depends(require_profiles(ADMIN)), connection: Connection = Depends(get_connection)):
    rows = connection.execute(sqlp.LIST_USERS, {
        "profile": profile.value if profile else None, "search": f"%{search.lower()}%" if search else None,
        "now": now(), "limit": limit, "commute": (page - 1) * limit}).mappings().all()
    summary = connection.execute(sqlp.COUNT_USERS).mappings().all()
    audit.register(request, "LIST_USERS", "ALLOWED", user=user)
    return {"summary": [dict(r) for r in summary],
            "items": [{k: json_value(v) for k, v in l.items()} for l in rows]}


@router_admin.post("/admin/users", status_code=201)
def create_user(payload: UserRequest, request: Request, user: User = Depends(require_profiles(ADMIN)),
                connection: Connection = Depends(get_connection)):
    profile = payload.profile.value
    if connection.execute(sqlp.LOGIN_EXISTS, {"login": payload.login}).first():
        raise http_error(409, "An account with this login already exists.")
    if profile == STUDENT and (not payload.student_id or not connection.execute(sqlp.STUDENT_EXISTS,
                                                                        {"student_id": payload.student_id}).first()):
        raise http_error(422, "A student account needs a registered student ID.")
    if profile == TEACHER and (not payload.id_professor or not connection.execute(
            sqlp.PROFESSOR_EXISTS, {"id_professor": payload.id_professor}).first()):
        raise http_error(422, "A teacher account needs a registered professor.")
    if profile in (COORDINATION, SUPPORT_CENTER) and (not payload.course_id or not connection.execute(
            sqlp.COURSE_EXISTS, {"course_id": payload.course_id}).first()):
        raise http_error(422, "Coordination and support center need a registered course.")
    password = generate_temporary_password()
    try:
        new = connection.execute(sqlp.CREATE_USER, {
            "login": payload.login, "password_hash": generate_password_hash(password), "profile": profile,
            "student_id": payload.student_id if profile == STUDENT else None,
            "id_professor": payload.id_professor if profile == TEACHER else None,
            "course_id": payload.course_id, "name": payload.name, "email": payload.email}).scalar()
        connection.commit()
    except IntegrityError:
        connection.rollback()
        raise http_error(409, "Account already exists for this student or login.")
    audit.register(request, "CREATE_USER", "ALLOWED", user=user)
    return {"user_id": new, "login": payload.login, "temporary_password": password,
            "notice": "Hand over the password through an institutional channel. It will not be shown again."}


@router_admin.patch("/admin/users/{user_id}")
def change_user(user_id: Annotated[int, Path(ge=1)], payload: UserChangeRequest, request: Request,
                user: User = Depends(require_profiles(ADMIN)), connection: Connection = Depends(get_connection)):
    target = connection.execute(sqlp.USER_FOR_ADMIN, {"user_id": user_id}).mappings().first()
    if target is None:
        raise http_error(404, "User not found.")
    if target["user_id"] == user.user_id and payload.active is False:
        raise http_error(409, "You cannot deactivate your own account.")
    answer = {"updated": True}
    if payload.active is not None:
        connection.execute(sqlp.ENABLE_USER, {"active": payload.active, "user_id": user_id})
    if payload.unlock:
        connection.execute(sqlp.UNLOCK, {"user_id": user_id})
    if payload.reset_password:
        password = generate_temporary_password()
        connection.execute(sqlp.RESET_PASSWORD, {"password_hash": generate_password_hash(password), "user_id": user_id})
        answer["temporary_password"] = password
    connection.commit()
    audit.register(request, "CHANGE_USER", "ALLOWED", user=user)
    return answer


class LoadType(str, Enum):
    GRADES = "GRADES"
    INDICATORS = "INDICATORS"


async def _read_until_limit(file: UploadFile) -> bytes:
    content = await file.read(MAXIMUM_SIZE + 1)
    if len(content) > MAXIMUM_SIZE:
        raise http_error(413, "File larger than 20 MB.")
    return content


@router_admin.post("/imports", status_code=201)
async def send_load(request: Request, kind: Annotated[LoadType, Form()], file: UploadFile = File(...),
                    user: User = Depends(require_profiles(ADMIN)), connection: Connection = Depends(get_connection)):
    content = await _read_until_limit(file)
    summary = hashlib.sha256(content).hexdigest()
    name = (file.filename or "file.csv").replace("\\", "/").split("/")[-1][:120]
    repeated = connection.execute(sqlp.LOAD_WITH_HASH, {"hash": summary}).mappings().first()
    if repeated:
        raise http_error(409, f"This same file is already in load {repeated['load_id']} "
                             f"({repeated['status'].lower()}).")
    try:
        rows = read_csv(content, kind.value)
    except InvalidFile as exc:
        audit.register(request, "REFUSED_LOAD", "DENIED", user=user)
        raise http_error(422, str(exc))

    students = set(connection.execute(sqlp.STUDENT_IDS).scalars())
    enrollments = {(m["student_id"], m["class_id"]): m["enrollment_id"]
                   for m in connection.execute(sqlp.CLASSES_AND_ENROLLMENTS).mappings()}
    result = validate(rows, kind.value, students, enrollments)
    status = "WITH_ERRORS" if result.errors else "VALIDATED"
    load_id = connection.execute(sqlp.CREATE_LOAD, {
        "kind": kind.value, "file_name": name, "bytes_size": len(content), "hash": summary,
        "sent_by": user.user_id, "now": now(), "status": status,
        "total_rows": result.total, "valid_rows": len(result.valid)}).scalar()

    if result.errors:
        by_row = defaultdict(list)
        for row_number, error in result.errors:
            by_row[row_number].append(error)
        for row_number, errors in by_row.items():
            connection.execute(sqlp.CREATE_LOAD_ROW, {"load_id": load_id, "number": row_number, "data": None,
                                                      "error": json.dumps(errors, ensure_ascii=False)[:300]})
    else:
        for row_number, data in result.valid:
            connection.execute(sqlp.CREATE_LOAD_ROW, {"load_id": load_id, "number": row_number,
                                                      "data": json.dumps(data), "error": None})
    connection.commit()
    audit.register(request, "SENT_LOAD", "ALLOWED", user=user)
    return {"load_id": load_id, "status": status, "total_rows": result.total,
            "valid_rows": len(result.valid), "rows_with_error": len({n for n, _ in result.errors}),
            "hash_sha256": summary,
            "rejections": [{"row": n, **e} for n, e in result.errors[:500]],
            "next_step": "Confirm the load to apply it." if status == "VALIDATED" else
            "Fix the rows and send the file again. No row was applied."}


@router_admin.get("/imports")
def list_loads(limit: Annotated[int, Query(ge=1, le=200)] = 30, page: Annotated[int, Query(ge=1)] = 1,
               user: User = Depends(require_profiles(ADMIN)), connection: Connection = Depends(get_connection)):
    rows = connection.execute(sqlp.LIST_LOADS, {"limit": limit, "commute": (page - 1) * limit}).mappings()
    return [{k: json_value(v) for k, v in l.items()} for l in rows]


@router_admin.get("/imports/{load_id}")
def load_status(load_id: Annotated[int, Path(ge=1)], user: User = Depends(require_profiles(ADMIN)),
                connection: Connection = Depends(get_connection)):
    load = connection.execute(sqlp.LOAD_BY_ID, {"load_id": load_id}).mappings().first()
    if load is None:
        raise http_error(404, "Load not found.")
    rejections = []
    for l in connection.execute(sqlp.LOAD_REJECTIONS, {"load_id": load_id}).mappings():
        try:
            rejections.extend({"row": l["number"], **e} for e in json.loads(l["error"]))
        except ValueError:
            rejections.append({"row": l["number"], "field": "-", "value": "", "reason": "several errors in this row"})
    return {**{k: json_value(v) for k, v in load.items() if k != "sent_by"}, "rejections": rejections}


class LoadAction(str, Enum):
    confirmation = "confirmation"
    cancellation = "cancellation"


@router_admin.post("/imports/{load_id}/{action}")
def decide_load(load_id: Annotated[int, Path(ge=1)], action: LoadAction, request: Request,
                user: User = Depends(require_profiles(ADMIN)), connection: Connection = Depends(get_connection)):
    new = "CONFIRMED" if action == LoadAction.confirmation else "CANCELED"
    changed = connection.execute(sqlp.CHANGE_LOAD, {"new": new, "user_id": user.user_id, "now": now(),
                                                    "load_id": load_id}).rowcount
    if not changed:
        connection.rollback()
        raise http_error(409, "Only a validated and not yet confirmed load can be confirmed or canceled.")
    if new == "CONFIRMED":
        connection.execute(sqlp.WAKE_CALCULATION)
    connection.commit()
    audit.register(request, "LOAD_" + new, "ALLOWED", user=user)
    return {"status": new, "note": "The calculation service applies the load and recalculates the affected students."
            if new == "CONFIRMED" else None}


class Service(str, Enum):
    api = "api"
    chat = "chat"
    calculation = "calculation"
    dashboard = "dashboard"


class LogLevel(str, Enum):
    INFO = "INFO"
    NOTICE = "NOTICE"
    ERROR = "ERROR"


@router_admin.get("/admin/services")
def services_status(user: User = Depends(require_profiles(ADMIN)),
                    connection: Connection = Depends(get_connection)):
    moment = now()
    services = []
    for l in connection.execute(sqlp.SERVICES).mappings():
        age = (moment - as_datetime(l["last_signal"])).total_seconds()
        services.append({"service": l["service"], "last_signal": json_value(l["last_signal"]),
                         "seconds_since_signal": int(age), "in_ar": age <= MAXIMUM_SIGNAL_S, "detail": l["detail"]})
    return {"services": services, "students_in_calculation_queue": int(connection.execute(sqlp.QUEUE_SIZE).scalar() or 0)}


@router_admin.get("/admin/records")
def technical_records(service: Service | None = None, level: LogLevel | None = None,
                      limit: Annotated[int, Query(ge=1, le=500)] = 100, page: Annotated[int, Query(ge=1)] = 1,
                      user: User = Depends(require_profiles(ADMIN)), connection: Connection = Depends(get_connection)):
    rows = connection.execute(sqlp.TECHNICAL_RECORDS, {
        "service": service.value if service else None, "level": level.value if level else None,
        "limit": limit, "commute": (page - 1) * limit}).mappings()
    return [{k: json_value(v) for k, v in l.items()} for l in rows]


class CalculationRequest(Closed):
    course: str | None = Field(default=None, pattern=r"^[A-Z0-9]{2,12}$")
    semester: int | None = Field(default=None, ge=1, le=20)


@router_admin.post("/calculations", status_code=202)
def trigger_recalculation(payload: CalculationRequest, request: Request, user: User = Depends(require_profiles(ADMIN)),
                          connection: Connection = Depends(get_connection)):
    total = connection.execute(sqlp.ENQUEUE_ALL, {"course_id": payload.course, "semester": payload.semester}).rowcount
    connection.execute(sqlp.WAKE_CALCULATION)
    connection.commit()
    audit.register(request, "TRIGGER_RECALCULATION", "ALLOWED", user=user)
    return {"queued_students": total}


class ParameterRequest(Closed):
    value: float
    justification: str = Field(min_length=10, max_length=500)


class DecisionRequest(Closed):
    approve: bool


def _current_values(connection: Connection) -> dict:
    return {l["key"]: float(l["value"]) for l in connection.execute(sqlp.PARAMETERS_VALUES).mappings()}


def _apply(connection: Connection, key: str, value: float, author: int, approver: int | None,
           justification: str) -> int:
    connection.execute(sqlp.LOCK_VERSIONS)
    problems = consistency_problems({**_current_values(connection), key: value})
    if problems:
        raise http_error(422, "Value inconsistent with the other parameters: " + " ".join(problems))
    version = connection.execute(sqlp.NEXT_VERSION).scalar()
    moment = now()
    connection.execute(sqlp.APPLY_PARAMETER, {"value": value, "now": moment, "key": key})
    connection.execute(sqlp.CREATE_VERSION, {"version": version, "now": moment, "author": author, "approver": approver,
                                             "justification": f"{key}: {justification}"[:500]})
    return version


@router_admin.get("/parameters", tags=["parameters"])
def list_parameters(user: User = Depends(require_profiles(ADMIN, COORDINATION)),
                    connection: Connection = Depends(get_connection)):
    rows = connection.execute(sqlp.LIST_PARAMETERS).mappings().all()
    return {
        "parameters": [{**{k: json_value(v) for k, v in l.items()},
                        "srs_default": CATALOG[l["key"]][0] if l["key"] in CATALOG else None,
                        "who_changes": who_changes(l["key"], l["editable"])} for l in rows],
        "versions": [{k: json_value(v) for k, v in l.items()} for l in connection.execute(sqlp.VERSIONS).mappings()],
        "proposals": [{k: json_value(v) for k, v in l.items()} for l in connection.execute(sqlp.PROPOSALS).mappings()],
    }


@router_admin.put("/parameters/{key}", tags=["parameters"])
def change_parameter(key: Annotated[str, Path(pattern=r"^[A-Z0-9_]{3,40}$")], payload: ParameterRequest,
                     request: Request, user: User = Depends(require_profiles(ADMIN, COORDINATION)),
                     connection: Connection = Depends(get_connection)):
    current = connection.execute(sqlp.PARAMETER, {"key": key}).mappings().first()
    if current is None:
        raise http_error(404, "Parameter not found.")
    if not current["editable"]:
        raise http_error(409, "This parameter only changes through formal recalibration of the model (Annex A.9).")
    from_coordination = key in CHANGED_BY_COORDINATION
    if from_coordination != (user.profile == COORDINATION):
        raise http_error(403, f"Who changes this parameter: {who_changes(key, True)}.")
    if not number(current["minimum"]) <= payload.value <= number(current["maximum"]):
        raise http_error(422, f"Value outside the allowed range ({number(current['minimum']):g} to "
                             f"{number(current['maximum']):g}).")
    if payload.value == number(current["value"]):
        raise http_error(409, "The value given is the current value.")

    if key in NEEDS_COORDINATION_APPROVAL:
        if connection.execute(sqlp.KEY_PENDING, {"key": key}).first():
            raise http_error(409, "There is already a pending proposal for this parameter.")
        problems = consistency_problems({**_current_values(connection), key: payload.value})
        if problems:
            raise http_error(422, "Value inconsistent with the other parameters: " + " ".join(problems))
        proposal_id = connection.execute(sqlp.CREATE_PROPOSAL, {
            "key": key, "previous_value": current["value"], "new_value": payload.value,
            "justification": payload.justification, "proposed_by": user.user_id, "now": now()}).scalar()
        notify(connection, profile_users(connection, COORDINATION), "PARAMETER", "Parameter awaiting approval",
               f"Proposal to change {key} from {number(current['value']):g} to {payload.value:g}.")
        connection.commit()
        audit.register(request, "PARAMETER_PROPOSE", "ALLOWED", user=user)
        return {"status": "PENDING", "proposal_id": proposal_id,
                "note": "The change takes effect after coordination approval."}

    version = _apply(connection, key, payload.value, user.user_id, None, payload.justification)
    connection.commit()
    audit.register(request, "CHANGE_PARAMETER", "ALLOWED", user=user)
    return {"status": "APPLIED", "version": version,
            "note": "Previous scores keep the version that generated them; the students will be recalculated."}


@router_admin.post("/parameters/proposals/{proposal_id}/decision", tags=["parameters"])
def decide_proposal(proposal_id: Annotated[int, Path(ge=1)], payload: DecisionRequest, request: Request,
                    user: User = Depends(require_profiles(COORDINATION)),
                    connection: Connection = Depends(get_connection)):
    proposal = connection.execute(sqlp.PENDING_PROPOSAL, {"proposal_id": proposal_id}).mappings().first()
    if proposal is None:
        raise http_error(404, "Proposal not found or already decided.")
    if proposal["proposed_by"] == user.user_id:
        raise http_error(403, "Whoever proposes cannot approve their own proposal.")
    version = None
    if payload.approve:
        version = _apply(connection, proposal["key"], float(proposal["new_value"]), proposal["proposed_by"],
                         user.user_id, proposal["justification"])
    connection.execute(sqlp.DECIDE_PROPOSAL, {"status": "APPROVED" if payload.approve else "REJECTED",
                                              "decided_by": user.user_id, "now": now(), "version": version,
                                              "proposal_id": proposal_id})
    notify(connection, [proposal["proposed_by"]], "PARAMETER",
           f"Proposal for {proposal['key']} {'approved' if payload.approve else 'rejected'}",
           f"Coordination {'approved' if payload.approve else 'rejected'} proposal {proposal_id}.")
    connection.commit()
    audit.register(request, "DECIDE_PARAMETER", "ALLOWED", user=user)
    return {"status": "APPROVED" if payload.approve else "REJECTED", "version": version}


class RequestStatus(str, Enum):
    IN_ANALYSIS = "IN_ANALYSIS"
    HANDLED = "HANDLED"
    DENIED = "DENIED"


class RequestAnswerRequest(Closed):
    status: RequestStatus


@router_admin.patch("/privacy/requests/{subject_request_id}", tags=["privacy"])
def answer_request(subject_request_id: Annotated[int, Path(ge=1)], payload: RequestAnswerRequest,
                   request: Request, user: User = Depends(require_profiles(DPO)),
                   connection: Connection = Depends(get_connection)):
    row = connection.execute(sqlp.REQUEST_BY_ID, {"id": subject_request_id}).mappings().first()
    if row is None:
        raise http_error(404, "Request not found.")
    if row["status"] in ("HANDLED", "DENIED"):
        raise http_error(409, "This request has already been answered.")
    connection.execute(sqlp.ANSWER_REQUEST, {"status": payload.status.value, "id": subject_request_id,
                                             "now": now() if payload.status != RequestStatus.IN_ANALYSIS
                                             else None})
    connection.commit()
    audit.register(request, "ANSWER_REQUEST", "ALLOWED", user=user)
    return {"status": payload.status.value}
