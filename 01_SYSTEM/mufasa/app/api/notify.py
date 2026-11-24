from sqlalchemy.engine import Connection

from app.api import dashboard_queries as sqlp
from app.api.util import now


def notify(connection: Connection, user_ids, kind: str, title: str, text: str, alert_id=None) -> None:
    moment = now()
    for user_id in dict.fromkeys(user_ids):
        connection.execute(sqlp.CREATE_NOTIFICATION, {"user_id": user_id, "now": moment, "kind": kind,
                                                      "title": title[:120], "text": text[:300],
                                                      "alert_id": alert_id})


def profile_users(connection: Connection, profile: str, course_id: str | None = None) -> list[int]:
    return list(connection.execute(sqlp.PROFILE_ACTIVE_USERS, {"profile": profile, "course_id": course_id}).scalars())
