import argparse
import importlib.metadata as md
import io
import os
import re
import sys
from contextlib import redirect_stdout
from datetime import datetime, timedelta, timezone
from pathlib import Path

from scripts._environment import ROOT, load_env

MINIMUM = {"fastapi": "0.115.6", "starlette": "0.40.0", "uvicorn": "0.32.0", "pydantic": "2.9",
           "pydantic-settings": "2.6", "SQLAlchemy": "2.0.36", "psycopg": "3.2.3", "PyJWT": "2.10.1",
           "bcrypt": "4.2.0", "httpx": "0.28", "cryptography": "43.0", "python-multipart": "0.0.18",
           "streamlit": "1.50.0", "plotly": "5.24", "pandas": "2.2", "pytest": "8.3"}
TABLES = ["students", "enrollments", "academic_indicators", "socioeconomic", "users", "risk_scores",
           "alerts", "alert_events", "parameters", "parameter_versions", "recalculation_queue", "service_status",
           "technical_logs", "access_audit", "appointments", "loads", "notifications"]

COUNTS = {t: f"SELECT count(*) FROM {t}" for t in ("students", "users", "risk_scores")}
CODE_SEARCH = {
    "technical_logs": "SELECT moment, service, level, event, message FROM technical_logs "
                     "WHERE request_id = :c ORDER BY moment LIMIT 20",
    "access_audit": "SELECT moment, profile, operation, resource, result FROM access_audit "
                         "WHERE request_id = :c ORDER BY moment LIMIT 20",
}

result = {"FAILURE": 0, "NOTICE": 0}


def row(state: str, text: str, tip: str = ""):
    if state in result:
        result[state] += 1
    brand = {"OK": "  ok   ", "NOTICE": " WARN  ", "FAILURE": " FAIL  ", "INFO": "  --   "}[state]
    print(f"[{brand}] {text}" + (f"\n          -> {tip}" if tip else ""))


def _version(text: str) -> tuple:
    return tuple(int(x) for x in re.findall(r"\d+", text)[:3])


def section(title: str):
    print(f"\n== {title} ==")


def check_python():
    section("Python and packages")
    v = sys.version_info
    row("OK" if v >= (3, 11) else "FAILURE", f"Python {v.major}.{v.minor}.{v.micro}",
          "" if v >= (3, 11) else "Install Python 3.11 or newer (tested with 3.13).")
    for package, minimum in MINIMUM.items():
        try:
            installed = md.version(package)
        except md.PackageNotFoundError:
            row("FAILURE", f"{package} not installed", "pip install -r requirements.txt")
            continue
        ok = _version(installed) >= _version(minimum)
        row("OK" if ok else "FAILURE", f"{package} {installed} (minimum {minimum})",
              "" if ok else "pip install -U -r requirements.txt")


def check_env():
    section("Configuration (.env)")
    row("OK" if (ROOT / ".env").exists() else "FAILURE", ".env file",
          "" if (ROOT / ".env").exists() else "Copy .env.example to .env and fill it in.")
    for name in ("DATABASE_URL", "CHAT_DATABASE_URL", "CALCULATION_DATABASE_URL", "DATABASE_URL_ADMIN", "JWT_SECRET",
                 "SUPPORT_KEY"):
        value = os.environ.get(name, "")
        if not value or "CHANGE" in value:
            row("FAILURE" if name != "DATABASE_URL_ADMIN" else "NOTICE", f"{name} not set",
                  "See .env.example; DATABASE_URL_ADMIN is only needed to build the database and migrate.")
        else:
            row("OK", f"{name} set")
    if len(os.environ.get("JWT_SECRET", "")) and len(os.environ["JWT_SECRET"]) < 32:
        row("FAILURE", "JWT_SECRET too short (minimum 32 characters)",
              'python -c "import secrets; print(secrets.token_hex(32))"')
    if os.environ.get("SUPPORT_KEY"):
        try:
            from cryptography.fernet import Fernet
            Fernet(os.environ["SUPPORT_KEY"].encode())
            row("OK", "SUPPORT_KEY is a valid Fernet key")
        except Exception:
            row("FAILURE", "SUPPORT_KEY invalid", "Generate it with the command in .env.example.")
    row("INFO", f"ENVIRONMENT={os.environ.get('ENVIRONMENT', 'development')}")


def _connect(var_name: str):
    from sqlalchemy import create_engine, text
    url = os.environ.get(var_name)
    if not url:
        return None
    engine = create_engine(url, hide_parameters=True, pool_pre_ping=True, connect_args={"connect_timeout": 5})
    try:
        with engine.connect() as c:
            c.execute(text("SELECT 1"))
        row("OK", f"connection {var_name}")
        return engine
    except Exception as exc:
        tip = "Database down? Profile password different from the one in .env? Run scripts.build_database."
        if "does not exist" in str(exc):
            tip = "The database does not exist: python -m scripts.build_database"
        elif "password authentication failed" in str(exc):
            tip = "Wrong password in .env for this profile (ALTER ROLE ... PASSWORD, or build the database again)."
        elif "Connection refused" in str(exc) or "could not connect" in str(exc).lower():
            tip = "PostgreSQL down or on another port/host."
        row("FAILURE", f"connection {var_name}: {type(exc).__name__}", tip)
        return None


def check_database():
    from sqlalchemy import text
    section("Database")
    api = _connect("DATABASE_URL")
    _connect("CHAT_DATABASE_URL")
    _connect("CALCULATION_DATABASE_URL")
    admin = _connect("DATABASE_URL_ADMIN") if os.environ.get("DATABASE_URL_ADMIN") else None
    main = admin or api
    if main is None:
        return None
    with main.connect() as c:
        existing = set(c.execute(text("SELECT table_name FROM information_schema.tables "
                                        "WHERE table_schema = 'public'")).scalars())
        missing = [t for t in TABLES if t not in existing]
        row("OK" if not missing else "FAILURE", f"{len(TABLES) - len(missing)}/{len(TABLES)} essential tables",
              f"Missing: {', '.join(missing)}. Build the database again." if missing else "")
        if admin is not None:
            for t, minimum in (("students", 1), ("users", 1), ("risk_scores", 1)):
                n = c.execute(text(COUNTS[t])).scalar()
                row("OK" if n >= minimum else "NOTICE", f"{t}: {n} row(s)",
                      "" if n >= minimum else ("Start the calculation service: it calculates on startup." if t == "risk_scores"
                                              else "Build the database (scripts.build_database)."))
            if "schema_migrations" in existing:
                from scripts.migrate import files
                done = set(c.execute(text("SELECT file FROM schema_migrations")).scalars())
                pend = [p.name for p in files() if p.name not in done]
                row("OK" if not pend else "NOTICE", f"migrations: {len(done)} applied, {len(pend)} pending",
                      "python -m scripts.migrate" if pend else "")
            else:
                row("NOTICE", "migrations table missing", "python -m scripts.migrate")
        try:
            version = c.execute(text("SELECT max(version) FROM parameter_versions")).scalar()
            row("OK", f"parameters: current version {version}")
        except Exception:
            row("NOTICE", "could not read the parameter version")
    return main


def check_services(engine):
    section("Services")
    import httpx
    for name, url in (("api", os.environ.get("MUFASA_API_URL", "http://127.0.0.1:8000")),
                      ("chat", os.environ.get("MUFASA_CHAT_URL", "http://127.0.0.1:8001"))):
        try:
            r = httpx.get(url.rstrip("/") + "/health", timeout=3)
            body = r.json()
            row("OK" if r.status_code == 200 else "FAILURE",
                  f"{name} at {url}: {body.get('status')} (version {body.get('version', '?')}, database {body.get('database')})")
        except Exception:
            row("FAILURE", f"{name} at {url} is not responding", "Start it with: python -m scripts.start "
                  f"(see logs/{name}.console.log)")
    try:
        r = httpx.get("http://127.0.0.1:8501/_stcore/health", timeout=3)
        row("OK" if r.status_code == 200 else "FAILURE", "dashboard at http://127.0.0.1:8501")
    except Exception:
        row("FAILURE", "dashboard not responding at http://127.0.0.1:8501", "see logs/dashboard.console.log")
    if engine is None:
        return
    from sqlalchemy import text
    with engine.connect() as c:
        now = datetime.now(timezone.utc)
        for s in c.execute(text("SELECT service, last_signal, detail FROM service_status ORDER BY service")).mappings():
            age = (now - s["last_signal"]).total_seconds()
            row("OK" if age <= 60 else "FAILURE", f"heartbeat of {s['service']}: {int(age)} s ago ({s['detail']})",
                  "" if age <= 60 else f"The {s['service']} service stopped. See logs/{s['service']}.log")
        queue = c.execute(text("SELECT count(*) FROM recalculation_queue")).scalar()
        row("OK" if queue < 200 else "NOTICE", f"recalculation queue: {queue} student(s)",
              "" if queue < 200 else "Large queue: is the calculation service running? (logs/calculation.log)")


def check_errors(engine, hours: int):
    section(f"Errors in the last {hours} h")
    if engine is not None:
        from sqlalchemy import text
        with engine.connect() as c:
            since = datetime.now(timezone.utc) - timedelta(hours=hours)
            errors = c.execute(text("SELECT moment, service, event, message, request_id FROM technical_logs "
                                   "WHERE level = 'ERROR' AND moment >= :since ORDER BY moment DESC LIMIT 15"),
                              {"since": since}).mappings().all()
        row("OK" if not errors else "NOTICE", f"{len(errors)} error(s) in the database technical logs")
        for e in errors:
            print(f"          {e['moment']:%d/%m %H:%M:%S} {e['service']:8} {e['event']} {e['message'] or ''} "
                  f"(code {e['request_id'] or '-'})")
    folder = Path(os.environ.get("MUFASA_LOG_DIR", ROOT / "logs"))
    for file in sorted(folder.glob("*.log")) if folder.exists() else []:
        last = [l.rstrip() for l in file.read_text(encoding="utf-8", errors="replace").splitlines()
                   if " ERROR " in l or "Traceback" in l][-5:]
        if last:
            row("NOTICE", f"{file.name}: last error lines")
            for l in last:
                print("          " + l[:220])


def find_request(code: str, engine):
    section(f"Search by code {code}")
    if not re.fullmatch(r"[0-9a-fA-FP-]{4,32}", code):
        row("FAILURE", "code in invalid format")
        return
    found = False
    folder = Path(os.environ.get("MUFASA_LOG_DIR", ROOT / "logs"))
    for file in sorted(folder.glob("*.log*")) if folder.exists() else []:
        rows = file.read_text(encoding="utf-8", errors="replace").splitlines()
        for i, l in enumerate(rows):
            if code in l:
                found = True
                print(f"  {file.name}:{i + 1}")
                for extra in rows[i:i + 25]:
                    if extra is not l and re.match(r"^\d{4}-\d{2}-\d{2} ", extra):
                        break
                    print("    " + extra[:300])
    if engine is not None:
        from sqlalchemy import text
        with engine.connect() as c:
            for table_name in CODE_SEARCH:
                for r in c.execute(text(CODE_SEARCH[table_name]), {"c": code}).mappings():
                    found = True
                    print(f"  {table_name}: " + " | ".join(str(v) for v in r.values()))
    if not found:
        row("NOTICE", "code not found", "Check the code; old logs may have been rotated (5 x 5 MB).")


def main() -> int:
    load_env()
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--request", help="code shown on the error screen")
    ap.add_argument("--hours", type=int, default=24, help="window of recent errors (default 24)")
    ap.add_argument("--output", help="also saves the report in this file")
    args = ap.parse_args()
    buffer = io.StringIO()

    class Double(io.TextIOBase):
        def write(self, s):
            sys.__stdout__.write(s)
            buffer.write(s)
            return len(s)

    with redirect_stdout(Double()):
        from app import __version__
        print(f"MUFASA {__version__} - diagnostics at {datetime.now():%d/%m/%Y %H:%M:%S}")
        if args.request:
            find_request(args.request.strip(), _connect("DATABASE_URL_ADMIN") or _connect("DATABASE_URL"))
        else:
            check_python()
            check_env()
            engine = check_database()
            check_services(engine)
            check_errors(engine, args.hours)
            print(f"\nSummary: {result['FAILURE']} failure(s), {result['NOTICE']} warning(s).")
    if args.output:
        Path(args.output).write_text(buffer.getvalue(), encoding="utf-8")
        print(f"Report saved to {args.output}")
    return 1 if result["FAILURE"] else 0


if __name__ == "__main__":
    raise SystemExit(main())
