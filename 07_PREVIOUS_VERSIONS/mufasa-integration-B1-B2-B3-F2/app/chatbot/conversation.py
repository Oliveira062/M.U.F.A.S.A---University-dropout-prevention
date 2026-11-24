"""
Conversation and history (RN13 and Annex D.2 audit).

- One open conversation per user. With no message for 2 hours, it closes
  on the next interaction, the user is warned and the history stays saved.
- Each message records: user, question WITHOUT personal data, intent,
  query run, number of records, answer, whether the AI wrote it and
  whether it was a bypass attempt. Password, token and CPF are never recorded.
"""

from datetime import datetime, timedelta, timezone

from sqlalchemy.engine import Connection

from app.chatbot import chat_queries as sql
from app.chatbot.config_chat import get_chat_configuration

CLOSING_NOTICE = ("Your previous conversation was closed after 2 hours without messages. The messages "
                      "are still saved in your history; this is a new conversation.")


def now() -> datetime:
    return datetime.now(timezone.utc)


def _as_datetime(value) -> datetime | None:
    if value is None:
        return None
    if isinstance(value, datetime):
        return value if value.tzinfo else value.replace(tzinfo=timezone.utc)
    converted = datetime.fromisoformat(str(value))
    return converted if converted.tzinfo else converted.replace(tzinfo=timezone.utc)


def get_or_open(connection: Connection, user_id: int) -> tuple[int, str | None]:
    """Returns (conversation id, inactivity closing notice or None)."""
    moment = now()
    limit = timedelta(minutes=get_chat_configuration().chat_inactivity_minutes)
    notice = None
    opened = connection.execute(sql.OPEN_CONVERSATION, {"user_id": user_id}).mappings().first()
    if opened is not None:
        last = _as_datetime(opened["last_interaction"])
        if last is not None and moment - last <= limit:
            connection.execute(sql.PLAY_CONVERSATION, {"now": moment, "conversation_id": opened["conversation_id"],
                                                 "user_id": user_id})
            return opened["conversation_id"], None
        connection.execute(sql.CLOSE_CONVERSATION, {"now": moment, "reason": "INACTIVITY",
                                                "conversation_id": opened["conversation_id"], "user_id": user_id})
        notice = CLOSING_NOTICE
    new = connection.execute(sql.NEW_CONVERSATION, {"user_id": user_id, "now": moment}).scalar_one()
    return new, notice


def close(connection: Connection, user_id: int) -> bool:
    opened = connection.execute(sql.OPEN_CONVERSATION, {"user_id": user_id}).mappings().first()
    if opened is None:
        return False
    connection.execute(sql.CLOSE_CONVERSATION, {"now": now(), "reason": "USER",
                                            "conversation_id": opened["conversation_id"], "user_id": user_id})
    return True


def register(connection: Connection, *, conversation_id: int, user_id: int, redacted_question: str,
              intent: str, query: str | None, records: int, answer: str, redacted_by_ai: bool,
              bypass_attempt: bool) -> None:
    connection.execute(sql.REGISTER_MESSAGE, {
        "conversation_id": conversation_id, "user_id": user_id, "moment": now(),
        "redacted_question": redacted_question[:600], "intent": intent,
        "executed_query": query, "records": records, "answer": answer[:4000],
        "redacted_by_ai": redacted_by_ai, "bypass_attempt": bypass_attempt,
    })
