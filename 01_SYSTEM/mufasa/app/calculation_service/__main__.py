import logging
import os
import signal
import sys
import time
from datetime import datetime, timezone

import psycopg
from sqlalchemy import create_engine
from sqlalchemy.engine import Engine, make_url

from app import __version__
from app.calculation.parameters import CATALOG, Parameters, consistency_problems
from app.log_record import configure_logging
from app.calculation_service import calculation_queries as sql
from app.calculation_service.loads import apply_next_load
from app.calculation_service.recalculation import warn_overdue_deadlines, process_batch

log = logging.getLogger("mufasa.calculation")

NOTIFY_WAIT_S = 5
DEADLINES_INTERVAL_S = 60
SIGNAL_INTERVAL_S = 15
MAX_ERROR_WAIT_S = 60

_stop = False


def _stop_signal(*_):
    global _stop
    _stop = True


def load_parameters(engine: Engine) -> Parameters:
    with engine.connect() as connection:
        values = {l["key"]: float(l["value"]) for l in connection.execute(sql.CURRENT_PARAMETERS).mappings()}
        version = connection.execute(sql.CURRENT_VERSION).scalar() or 0
    missing = sorted(set(CATALOG) - set(values))
    if missing:
        raise RuntimeError("parameters missing in the database: " + ", ".join(missing))
    problems = consistency_problems(values)
    if problems:
        raise RuntimeError("inconsistent parameters: " + " ".join(problems))
    return Parameters(values, version=int(version))


def _register(engine: Engine, level: str, event: str, message: str = "") -> None:
    try:
        with engine.begin() as connection:
            connection.execute(sql.REGISTER_LOG, {"now": datetime.now(timezone.utc), "level": level,
                                                  "event": event[:60], "message": message[:500]})
    except Exception:
        log.exception("could not save the technical log")


def _listen(url_sqlalchemy: str):
    url = make_url(url_sqlalchemy).set(drivername="postgresql")
    connection = psycopg.connect(url.render_as_string(hide_password=False), autocommit=True)
    connection.execute("LISTEN mufasa_recalculation")
    return connection


def run() -> int:
    configure_logging("calculation")
    url = os.environ.get("CALCULATION_DATABASE_URL")
    if not url:
        print("Set CALCULATION_DATABASE_URL (mufasa_calculation profile).", file=sys.stderr)
        return 2
    signal.signal(signal.SIGTERM, _stop_signal)
    signal.signal(signal.SIGINT, _stop_signal)

    engine = create_engine(url, pool_pre_ping=True, pool_size=2, max_overflow=0, hide_parameters=True)
    listening = None
    error_wait = 1
    last_deadline = last_signal = 0.0
    version_in_use = None
    _register(engine, "INFO", "started_service", f"version {__version__}")

    while not _stop:
        try:
            p = load_parameters(engine)
            with engine.begin() as connection:
                if version_in_use != p.version:
                    connection.execute(sql.ENQUEUE_WITHOUT_SCORE)
                    connection.execute(sql.ENQUEUE_OLD_VERSION, {"version": p.version})
                    version_in_use = p.version
            processed = 1
            while processed and not _stop:
                with engine.begin() as connection:
                    processed = process_batch(connection, p)
                if processed:
                    log.info("recalculated %s student(s)", processed)
            while apply_next_load(engine) is not None:
                pass
            now = time.monotonic()
            if now - last_deadline >= DEADLINES_INTERVAL_S:
                with engine.begin() as connection:
                    warn_overdue_deadlines(connection)
                last_deadline = now
            if now - last_signal >= SIGNAL_INTERVAL_S:
                with engine.begin() as connection:
                    connection.execute(sql.LIFE_SIGNAL, {"now": datetime.now(timezone.utc),
                                                         "detail": f"v{__version__}, parameters v{p.version}"})
                last_signal = now
            if listening is None or listening.closed:
                listening = _listen(url)
            for _ in listening.notifies(timeout=NOTIFY_WAIT_S, stop_after=1):
                pass
            error_wait = 1
        except Exception as exc:
            log.exception("failure in the calculation loop; new attempt in %ss", error_wait)
            _register(engine, "ERROR", "failure_in_loop", type(exc).__name__)
            if listening is not None:
                try:
                    listening.close()
                except Exception:
                    pass
                listening = None
            time.sleep(error_wait)
            error_wait = min(MAX_ERROR_WAIT_S, error_wait * 2)

    _register(engine, "INFO", "closed_service")
    return 0


if __name__ == "__main__":
    raise SystemExit(run())
