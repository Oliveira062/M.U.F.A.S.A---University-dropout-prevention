from enum import Enum
from typing import Annotated

from fastapi import APIRouter, Depends, Path, Query, Request
from pydantic import Field, model_validator
from sqlalchemy.engine import Connection

from app.api import audit, dashboard_queries as sqlp
from app.api.auth import User, require_profiles
from app.api.database import get_connection
from app.api.errors import http_error
from app.api.schemas import Closed, Level
from app.api.notify import notify, profile_users
from app.api.db_parameters import current_parameters
from app.api.permissions import COORDINATION, TEACHER, FINANCE, SUPPORT_CENTER
from app.api.util import now, json_value
from app.api.visibility import main_visible

alert_router = APIRouter(prefix="/api/v1/alerts", tags=["alerts"])

DENIED_ALERT_MSG = "You do not have permission to access this alert, or it does not exist."
RESTRICTED_RECORD_LABEL = "Support center record (details restricted to the center)."

MANAGE = (COORDINATION, SUPPORT_CENTER)
RECORD = (COORDINATION, SUPPORT_CENTER, TEACHER, FINANCE)


class Status(str, Enum):
    OPEN = "OPEN"
    IN_SERVICE = "IN_SERVICE"
    CLOSED = "CLOSED"


class AlertType(str, Enum):
    PEDAGOGICAL = "PEDAGOGICAL"
    DATA = "DATA"


class ActionType(str, Enum):
    CONVERSATION = "CONVERSATION"
    ACADEMIC_GUIDANCE = "ACADEMIC_GUIDANCE"
    SSC_REFERRAL = "SSC_REFERRAL"
    FINANCE_REFERRAL = "FINANCE_REFERRAL"
    CONTACT_WITHOUT_RETURN = "CONTACT_WITHOUT_RETURN"
    OTHER = "OTHER"


class Cause(str, Enum):
    FINANCIAL = "FINANCIAL"
    ACADEMIC = "ACADEMIC"
    WORK = "WORK"
    HEALTH = "HEALTH"
    FAMILY = "FAMILY"
    TRANSPORT = "TRANSPORT"
    COURSE_CHOICE = "COURSE_CHOICE"
    INSTITUTIONAL = "INSTITUTIONAL"
    NOT_IDENTIFIED = "NOT_IDENTIFIED"


class Outcome(str, Enum):
    REMAINED = "REMAINED"
    LOCKED = "LOCKED"
    DROPPED_OUT = "DROPPED_OUT"
    TRANSFERRED = "TRANSFERRED"
    IN_FOLLOWUP = "IN_FOLLOWUP"
    FIXED_DATA = "FIXED_DATA"


class Channel(str, Enum):
    VIRTUAL_ENVIRONMENT = "VIRTUAL_ENVIRONMENT"
    IN_PERSON = "IN_PERSON"
    INSTITUTIONAL_EMAIL = "INSTITUTIONAL_EMAIL"
    RN19_EMERGENCY = "RN19_EMERGENCY"


class ChangeRequest(Closed):
    owner_id: int | None = Field(default=None, ge=1, description="Coordination only: assigns the alert")
    assume: bool = Field(default=False, description="Marks the alert as in service")

    @model_validator(mode="after")
    def _something(self):
        if self.owner_id is None and not self.assume:
            raise ValueError("give owner_id or assume")
        return self


class ActionRequest(Closed):
    action_type: ActionType
    description: str = Field(min_length=5, max_length=1000)
    visible_to_student: bool = Field(default=False, description="The student sees this record in their area")


class ClosingRequest(Closed):
    cause: Cause
    outcome: Outcome
    there_was_contact: bool
    contact_channel: Channel | None = None
    executed_actions: str = Field(min_length=10, max_length=1000)

    @model_validator(mode="after")
    def _channel(self):
        if self.there_was_contact and self.contact_channel is None:
            raise ValueError("give the contact channel")
        if not self.there_was_contact and self.contact_channel is not None:
            raise ValueError("channel given without contact")
        return self


class DivergenceRequest(Closed):
    justification: str = Field(min_length=10, max_length=1000)


def _scope_parameters(user: User) -> dict:
    return {"course_id": user.course_id, "user_id": user.user_id, "id_professor": user.id_professor}


def get_alert(connection: Connection, request: Request, user: User, alert_id: int, operation: str):
    row = connection.execute(sqlp.alert_query_in_scope(user.profile),
                             {"alert_id": alert_id, **_scope_parameters(user)}).mappings().first()
    if row is None:
        audit.register(request, operation, "DENIED", user=user)
        raise http_error(403, DENIED_ALERT_MSG)
    audit.register(request, operation, "ALLOWED", user=user, target_student_id=row["student_id"])
    return row


def _hours_for_deadline(deadline, moment) -> float | None:
    if deadline is None:
        return None
    return round((deadline - moment).total_seconds() / 3600, 1)


@alert_router.get("")
def alerts_queue(request: Request,
                 status: Status | None = None, kind: AlertType | None = None, level: Level | None = None,
                 owner: Annotated[int | None, Query(ge=1)] = None, without_owner: bool = False,
                 only_overdue: bool = False,
                 limit: Annotated[int, Query(ge=1, le=200)] = 50,
                 page: Annotated[int, Query(ge=1, le=10_000)] = 1,
                 user: User = Depends(require_profiles(*RECORD)),
                 connection: Connection = Depends(get_connection)):
    moment = now()
    filters = {"status": status.value if status else None, "kind": kind.value if kind else None,
               "level": level.value if level else None, "owner": owner,
               "without_owner": without_owner, "only_overdue": only_overdue, "now": moment,
               **_scope_parameters(user)}
    total = connection.execute(sqlp.queue_total_query(user.profile), filters).scalar()
    rows = connection.execute(sqlp.queue_query(user.profile), {
        **filters, "limit": limit, "commute": (page - 1) * limit}).mappings().all()
    audit.register(request, "LIST_ALERTS", "ALLOWED", user=user)
    return {"total": total, "page": page, "limit": limit, "items": [{
        "alert_id": l["alert_id"], "enrollment": l["student_id"], "name": l["fictitious_name"],
        "semester": l["current_semester"], "kind": l["kind"], "level": l["level"], "status": l["status"],
        "created_at": json_value(l["created_at"]), "deadline_at": json_value(l["deadline_at"]),
        "overdue": bool(l["overdue"]), "hours_for_deadline": _hours_for_deadline(l["deadline_at"], moment),
        "owner": l["owner"], "owner_id": l["owner_id"], "score": l["score"],
        "trend": l["trend"], "main_factors": main_visible(user.profile, l["main_factors"]),
        "last_action_at": json_value(l["last_action_at"]), "first_action_at": json_value(l["first_action_at"]),
        "cause": l["cause"], "outcome": l["outcome"],
    } for l in rows]}


@alert_router.get("/owners")
def owners(user: User = Depends(require_profiles(COORDINATION)), connection: Connection = Depends(get_connection)):
    ceiling = int(current_parameters(connection)["OWNER_ALERT_CEILING"])
    rows = connection.execute(sqlp.OWNERS, {"course_id": user.course_id}).mappings().all()
    return [{"user_id": l["user_id"], "name": l["name"], "profile": l["profile"],
             "open_alerts": int(l["open_alerts"]), "ceiling": ceiling,
             "in_ceiling": int(l["open_alerts"]) >= ceiling} for l in rows]


def visible_event(user: User, event) -> dict:
    description = event["description"]
    own = event["user_id"] == user.user_id
    if user.profile == SUPPORT_CENTER or own or event["user_id"] is None:
        pass
    elif event["author_profile"] == SUPPORT_CENTER:
        description = RESTRICTED_RECORD_LABEL
    elif user.profile in (TEACHER, FINANCE):
        description = "Record of another professional."
    return {"moment": json_value(event["moment"]), "kind": event["kind"], "action_type": event["action_type"],
            "description": description, "author": event["author"] or "System", "author_profile": event["author_profile"],
            "visible_to_student": bool(event["visible_to_student"])}


@alert_router.get("/{alert_id}")
def alert_detail(alert_id: Annotated[int, Path(ge=1)], request: Request,
                 user: User = Depends(require_profiles(*RECORD)),
                 connection: Connection = Depends(get_connection)):
    alert = get_alert(connection, request, user, alert_id, "READ_ALERT")
    events = connection.execute(sqlp.ALERT_EVENTS, {"alert_id": alert_id}).mappings().all()
    moment = now()
    connection.rollback()
    manages = user.profile == COORDINATION or (user.profile == SUPPORT_CENTER
                                               and alert["owner_id"] == user.user_id)
    return {
        "alert_id": alert["alert_id"], "enrollment": alert["student_id"], "name": alert["fictitious_name"],
        "kind": alert["kind"], "level": alert["level"], "status": alert["status"],
        "created_at": json_value(alert["created_at"]), "deadline_at": json_value(alert["deadline_at"]),
        "overdue": alert["status"] != "CLOSED" and alert["deadline_at"] < moment,
        "hours_for_deadline": _hours_for_deadline(alert["deadline_at"], moment),
        "owner": alert["owner"], "owner_id": alert["owner_id"],
        "assigned_at": json_value(alert["assigned_at"]), "first_action_at": json_value(alert["first_action_at"]),
        "closing": None if alert["status"] != "CLOSED" else {
            "closed_at": json_value(alert["closed_at"]), "cause": alert["cause"],
            "outcome": alert["outcome"], "there_was_contact": alert["there_was_contact"],
            "contact_channel": alert["contact_channel"],
            "executed_actions": alert["executed_actions"] if user.profile in MANAGE else None,
            "score_in_closing": alert["score_in_closing"]},
        "underage": alert["age"] is not None and alert["age"] < 18,
        "can_manage": manages and alert["status"] != "CLOSED",
        "can_assign": user.profile == COORDINATION and alert["status"] != "CLOSED",
        "events": [visible_event(user, e) for e in events],
    }


@alert_router.patch("/{alert_id}")
def change_alert(alert_id: Annotated[int, Path(ge=1)], payload: ChangeRequest, request: Request,
                 user: User = Depends(require_profiles(*MANAGE)),
                 connection: Connection = Depends(get_connection)):
    alert = get_alert(connection, request, user, alert_id, "CHANGE_ALERT")
    if alert["status"] == "CLOSED":
        raise http_error(409, "This alert has already been closed.")
    moment = now()

    if payload.owner_id is not None:
        if user.profile != COORDINATION:
            raise http_error(403, "Only coordination assigns alerts.")
        if alert["kind"] == "DATA":
            raise http_error(409, "A data correction task stays with the course coordination.")
        destination = connection.execute(sqlp.VALID_OWNER, {"user_id": payload.owner_id,
                                                             "course_id": alert["course_id"]}).mappings().first()
        if destination is None:
            raise http_error(422, "Invalid owner: choose someone from the support center or the course coordination.")
        ceiling = int(current_parameters(connection)["OWNER_ALERT_CEILING"])
        if destination["user_id"] != alert["owner_id"] and int(destination["open_alerts"]) >= ceiling:
            raise http_error(409, f"This owner already has {destination['open_alerts']} open alerts "
                                 f"(limit of {ceiling}). Choose another person.")
        connection.execute(sqlp.ASSIGN_ALERT, {"owner_id": destination["user_id"], "now": moment,
                                               "alert_id": alert_id})
        connection.execute(sqlp.REGISTER_EVENT, {"alert_id": alert_id, "now": moment,
                                                 "user_id": user.user_id, "kind": "ASSIGNED",
                                                 "action_type": None, "description": "Alert assigned.",
                                                 "visible_to_student": False})
        if destination["user_id"] != user.user_id:
            notify(connection, [destination["user_id"]], "ASSIGNED_ALERT", "Alert assigned to you",
                   f"{alert['level'].capitalize()} alert for student ID {alert['student_id']}. Deadline: "
                   f"{alert['deadline_at']:%d/%m/%Y %H:%M}.", alert_id)

    if payload.assume:
        if user.profile == SUPPORT_CENTER and alert["owner_id"] != user.user_id:
            raise http_error(403, DENIED_ALERT_MSG)
        connection.execute(sqlp.ASSUME_ALERT, {"now": moment, "alert_id": alert_id})
    connection.commit()
    return {"updated": True}


@alert_router.post("/{alert_id}/actions", status_code=201)
def register_action(alert_id: Annotated[int, Path(ge=1)], payload: ActionRequest, request: Request,
                    user: User = Depends(require_profiles(*RECORD)),
                    connection: Connection = Depends(get_connection)):
    alert = get_alert(connection, request, user, alert_id, "REGISTER_ACTION")
    if alert["status"] == "CLOSED":
        raise http_error(409, "This alert has already been closed.")
    moment = now()
    connection.execute(sqlp.REGISTER_EVENT, {"alert_id": alert_id, "now": moment,
                                             "user_id": user.user_id, "kind": "ACTION",
                                             "action_type": payload.action_type.value, "description": payload.description,
                                             "visible_to_student": payload.visible_to_student})
    connection.execute(sqlp.FIRST_ACTION, {"now": moment, "alert_id": alert_id})
    if payload.action_type in (ActionType.SSC_REFERRAL, ActionType.FINANCE_REFERRAL):
        destination_profile = SUPPORT_CENTER if payload.action_type == ActionType.SSC_REFERRAL else FINANCE
        destinations = (profile_users(connection, COORDINATION, alert["course_id"]) if destination_profile == SUPPORT_CENTER
                        else profile_users(connection, FINANCE))
        notify(connection, [d for d in destinations if d != user.user_id], "ASSIGNED_ALERT",
               "Referral recorded",
               f"Student ID {alert['student_id']} was referred to the "
               f"{'support center' if destination_profile == SUPPORT_CENTER else 'finance office'}.", alert_id)
    connection.commit()
    return {"registered": True}


@alert_router.post("/{alert_id}/closing")
def close_alert(alert_id: Annotated[int, Path(ge=1)], payload: ClosingRequest, request: Request,
                user: User = Depends(require_profiles(*MANAGE)),
                connection: Connection = Depends(get_connection)):
    alert = get_alert(connection, request, user, alert_id, "CLOSE_ALERT")
    if alert["status"] == "CLOSED":
        raise http_error(409, "This alert has already been closed.")
    if user.profile == SUPPORT_CENTER and alert["owner_id"] != user.user_id:
        raise http_error(403, DENIED_ALERT_MSG)
    if alert["kind"] == "DATA" and payload.outcome != Outcome.FIXED_DATA:
        raise http_error(422, "A data task closes with the FIXED_DATA outcome.")
    if alert["kind"] == "PEDAGOGICAL" and payload.outcome == Outcome.FIXED_DATA:
        raise http_error(422, "A pedagogical alert needs a follow-up outcome, not a data one.")

    score = connection.execute(sqlp.SCORE_AND_OVERLAP, {"student_id": alert["student_id"]}).mappings().first()
    if payload.contact_channel == Channel.RN19_EMERGENCY:
        reason = (score or {}).get("overlap_reason") or ""
        if alert["level"] != "CRITICAL" or "S2" not in reason:
            raise http_error(422, "The emergency contact (RN19) only applies to Critical for 15 days without presence.")

    if alert["kind"] == "PEDAGOGICAL":
        actions = [e for e in connection.execute(sqlp.ALERT_EVENTS, {"alert_id": alert_id}).mappings()
                   if e["kind"] == "ACTION"]
        if not actions:
            raise http_error(422, "Record at least one action before closing the alert.")

    moment = now()
    connection.execute(sqlp.CLOSE_ALERT, {
        "now": moment, "cause": payload.cause.value, "outcome": payload.outcome.value,
        "there_was_contact": payload.there_was_contact, "contact_channel": payload.contact_channel.value if payload.contact_channel else None,
        "executed_actions": payload.executed_actions, "score": score["score"] if score else None, "alert_id": alert_id})
    connection.execute(sqlp.REGISTER_EVENT, {"alert_id": alert_id, "now": moment,
                                             "user_id": user.user_id, "kind": "CLOSED", "action_type": None,
                                             "description": f"Closed: cause {payload.cause.value}, outcome "
                                                         f"{payload.outcome.value}.", "visible_to_student": False})
    connection.commit()
    return {"closed": True}


@alert_router.post("/{alert_id}/divergence", status_code=201)
def mark_divergence(alert_id: Annotated[int, Path(ge=1)], payload: DivergenceRequest, request: Request,
                    user: User = Depends(require_profiles(TEACHER, COORDINATION)),
                    connection: Connection = Depends(get_connection)):
    alert = get_alert(connection, request, user, alert_id, "MARK_DIVERGENCE")
    connection.execute(sqlp.REGISTER_EVENT, {"alert_id": alert_id, "now": now(),
                                             "user_id": user.user_id, "kind": "DIVERGENCE",
                                             "action_type": None, "description": payload.justification,
                                             "visible_to_student": False})
    if user.profile == TEACHER:
        notify(connection, profile_users(connection, COORDINATION, alert["course_id"]), "DIVERGENCE",
               "Classification disputed by teacher",
               f"A teacher marked the classification of student ID {alert['student_id']} as wrong.", alert_id)
    connection.commit()
    return {"registered": True}
