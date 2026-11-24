from collections.abc import Iterator

from sqlalchemy import create_engine
from sqlalchemy.engine import Connection, Engine

from app.api import database
from app.chatbot.config_chat import get_chat_configuration
from app.config import get_configuration

_engine_chat: Engine | None = None


def get_chat_engine() -> Engine:
    global _engine_chat
    url = get_chat_configuration().chat_database_url
    if url is None:
        if get_configuration().in_production:
            raise RuntimeError("CHAT_DATABASE_URL is required in production (mufasa_chat profile)")
        return database.get_engine()
    if _engine_chat is None:
        _engine_chat = create_engine(url.get_secret_value(), pool_pre_ping=True, pool_size=3,
                                     max_overflow=2, echo=False, hide_parameters=True)
    return _engine_chat


def get_chat_connection() -> Iterator[Connection]:
    with get_chat_engine().connect() as connection:
        yield connection
