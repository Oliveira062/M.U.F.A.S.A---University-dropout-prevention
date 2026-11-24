"""
Connection to the B1 PostgreSQL.

THIS PROJECT'S RULE AGAINST SQL INJECTION: every SQL is a constant with
named parameters (:name), run with sqlalchemy.text() and a dictionary
of values. The driver sends the values separately from the command, so no
user input becomes SQL code.

Forbidden in any file, with any value coming from outside:
    text(f"... {value} ...")        # f-string
    text("... " + value)            # concatenation
    text("... %s" % value)          # formatting
The only text joined to the SQL are CONSTANT fragments from queries.py.
Variable ordering only through an allowlist (see queries.ORDERINGS).
"""

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
            # Does not log SQL or parameters: the parameters contain personal data.
            echo=False,
            hide_parameters=True,
        )
    return _engine


def get_connection() -> Iterator[Connection]:
    """
    FastAPI dependency: one connection per request.

    Reading does not need a commit. An endpoint that writes calls connection.commit();
    if there is an error before that, the connection closes and PostgreSQL rolls back the transaction.
    """
    with get_engine().connect() as connection:
        yield connection
