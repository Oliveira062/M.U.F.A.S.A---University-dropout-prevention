import re
from datetime import datetime, timezone
from typing import Annotated

from fastapi import APIRouter, Depends, Path, Query, Request
from pydantic import Field, field_validator
from sqlalchemy.engine import Connection

from app.api import audit, queries as sql, dashboard_queries as sqlp
from app.api.auth import (TERM_VERSION, User, check_password, issue_token, generate_password_hash,
                          get_load_token, get_current_user)
from app.api.database import get_connection
from app.api.errors import http_error
from app.api.schemas import Closed, TokenAnswer
from app.api.util import now, json_value

account_router = APIRouter(prefix="/api/v1", tags=["account"])

PASSWORD_MINIMUM_SIZE = 10


class TermRequest(Closed):
    version: str = Field(pattern=r"^\d+\.\d+$", max_length=10)
    accepted: bool


class PasswordRequest(Closed):
    current_password: str = Field(min_length=1, max_length=72)
    new_password: str = Field(min_length=PASSWORD_MINIMUM_SIZE, max_length=72)

    @field_validator("new_password")
    @classmethod
    def _strength(cls, v: str) -> str:
        if len(v.encode("utf-8")) > 72:
            raise ValueError("password longer than 72 bytes")
        if not re.search(r"[A-Za-z]", v) or not re.search(r"\d", v):
            raise ValueError("the password must have letters and numbers")
        return v


def password_problem(new: str, login: str) -> str | None:
    if login.lower() in new.lower():
        return "The new password cannot contain your login."
    if len(set(new)) < 5:
        return "The new password repeats too many characters."
    return None


@account_router.get("/account/eu")
def my_account(user: User = Depends(get_current_user), connection: Connection = Depends(get_connection)):
    row = connection.execute(sqlp.ACCOUNT, {"user_id": user.user_id}).mappings().first()
    return {
        "user_id": row["user_id"], "login": row["login"], "name": row["name"], "profile": row["profile"],
        "enrollment": row["student_id"], "course": row["course"], "course_id": row["course_id"],
        "must_change_password": bool(row["must_change_password"]),
        "pending_term": row["version_term"] != TERM_VERSION, "current_term_version": TERM_VERSION,
        "accepted_term_at": json_value(row["accepted_term_at"]), "last_login": json_value(row["last_login"]),
        "not_read_notifications": int(row["not_read_notifications"]),
    }


@account_router.post("/account/term", status_code=204)
def accept_term(payload: TermRequest, request: Request, user: User = Depends(get_current_user),
                connection: Connection = Depends(get_connection)):
    if payload.version != TERM_VERSION:
        raise http_error(409, f"The current version of the terms is {TERM_VERSION}. Reload the page.")
    if not payload.accepted:
        audit.register(request, "REFUSED_TERM", "DENIED", user=user)
        raise http_error(403, "Without accepting the terms it is not possible to use the system. If in doubt, contact the "
                             "institution's data protection officer.")
    connection.execute(sqlp.ACCEPT_TERM, {"version": TERM_VERSION, "now": now(), "user_id": user.user_id})
    connection.commit()
    audit.register(request, "ACCEPTED_TERM", "ALLOWED", user=user)


@account_router.post("/account/password", status_code=204)
def change_password(payload: PasswordRequest, request: Request, user: User = Depends(get_current_user),
                    connection: Connection = Depends(get_connection)):
    row = connection.execute(sqlp.USER_PASSWORD, {"user_id": user.user_id}).mappings().first()
    if not check_password(payload.current_password, row["password_hash"]):
        audit.register(request, "PASSWORD_SWAP", "DENIED", user=user)
        raise http_error(403, "The current password does not match.")
    if check_password(payload.new_password, row["password_hash"]):
        raise http_error(422, "The new password must be different from the current one.")
    problem = password_problem(payload.new_password, row["login"])
    if problem:
        raise http_error(422, problem)
    connection.execute(sqlp.CHANGE_PASSWORD, {"password_hash": generate_password_hash(payload.new_password), "now": now(),
                                              "user_id": user.user_id})
    connection.commit()
    audit.register(request, "PASSWORD_SWAP", "ALLOWED", user=user)


@account_router.post("/auth/renew", response_model=TokenAnswer, tags=["authentication"])
def renew_session(request: Request, user: User = Depends(get_current_user),
                  load: dict = Depends(get_load_token), connection: Connection = Depends(get_connection)):
    connection.execute(sql.REVOKE_TOKEN, {"jti": load["jti"],
                                          "expires_at": datetime.fromtimestamp(load["exp"], tz=timezone.utc)})
    connection.commit()
    token, seconds = issue_token(user.user_id, user.profile)
    audit.register(request, "RENEW_SESSION", "ALLOWED", user=user)
    return TokenAnswer(access_token=token, expires_in_seconds=seconds, profile=user.profile,
                       must_change_password=user.must_change_password, pending_term=user.pending_term)


@account_router.get("/account/notifications")
def my_notifications(only_unread: bool = False,
                     limit: Annotated[int, Query(ge=1, le=100)] = 30,
                     page: Annotated[int, Query(ge=1, le=1000)] = 1,
                     user: User = Depends(get_current_user),
                     connection: Connection = Depends(get_connection)):
    rows = connection.execute(sqlp.NOTIFICATIONS, {
        "user_id": user.user_id, "only_unread": only_unread, "limit": limit,
        "commute": (page - 1) * limit}).mappings().all()
    return [{k: json_value(v) for k, v in l.items()} for l in rows]


@account_router.post("/account/notifications/{notification_id}/reading", status_code=204)
def mark_read(notification_id: Annotated[int, Path(ge=1)], user: User = Depends(get_current_user),
              connection: Connection = Depends(get_connection)):
    connection.execute(sqlp.MARK_READ, {"notification_id": notification_id, "user_id": user.user_id,
                                        "now": now()})
    connection.commit()


@account_router.post("/account/notifications/reading", status_code=204)
def mark_all_read(user: User = Depends(get_current_user), connection: Connection = Depends(get_connection)):
    connection.execute(sqlp.MARK_ALL_READ, {"user_id": user.user_id, "now": now()})
    connection.commit()
