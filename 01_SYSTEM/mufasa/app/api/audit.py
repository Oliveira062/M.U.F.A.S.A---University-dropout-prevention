import logging
from datetime import datetime, timezone

from fastapi import Request

from app.api import database
from app.api.queries import REGISTER_AUDIT
from app.api.security import client_ip

log = logging.getLogger("mufasa.audit")


def register(request: Request, operation: str, result: str, *, user=None,
             target_student_id: str | None = None) -> None:
    values = {
        "moment": datetime.now(timezone.utc),
        "request_id": getattr(request.state, "request_id", None),
        "user_id": getattr(user, "user_id", None),
        "profile": getattr(user, "profile", None),
        "operation": operation,
        "resource": request.url.path[:200],
        "target_student_id": target_student_id,
        "result": result,
        "origin": client_ip(request)[:45],
    }
    try:
        with database.get_engine().begin() as connection:
            connection.execute(REGISTER_AUDIT, values)
    except Exception:
        log.exception("Failed to save audit for request %s", values["request_id"])
        raise
