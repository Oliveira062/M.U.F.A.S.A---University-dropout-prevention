"""
Audit trail (LGPD art. 37, SRS RN07 and CA14).

Each record is written in its OWN transaction: a denied access ends in an error
and rolls back the request's transaction, but the record of the attempt has to
stay. That is why the audit does not use the endpoint's connection.

What does NOT go into the record: password, token, personal data values. What goes in is
who, when, what, about which student, with what result and from where.
IP retention: 6 months (Marco Civil da Internet, art. 15).
"""

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
        # An audit failure cannot stay silent.
        log.exception("Failed to save audit for request %s", values["request_id"])
        raise
