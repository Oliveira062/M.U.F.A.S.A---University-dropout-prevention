from collections.abc import Iterator

from sqlalchemy import create_engine
from sqlalchemy.engine import Connection, Engine

from app.config import get_configuration

_engine: Engine | None = None


def get_engine() -> Engine:
    global _engine
    if _engine is None:
        cfg = get_configuration()
        _engine = create_engine(
            cfg.database_url.get_secret_value(),
            pool_pre_ping=True,
            pool_size=5,
            max_overflow=5,
            echo=False,
            hide_parameters=True,
        )
    return _engine


def get_connection() -> Iterator[Connection]:
    with get_engine().connect() as connection:
        yield connection
