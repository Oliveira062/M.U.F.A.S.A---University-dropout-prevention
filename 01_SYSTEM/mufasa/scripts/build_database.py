import argparse
import os
import subprocess
import sys
from pathlib import Path

import psycopg
from psycopg import sql
from sqlalchemy.engine import make_url

from scripts._environment import ROOT, load_env

SQL_FILES = ["b1_corrections", "b3_complement", "dashboard", "b1_indicators_recalculation", "chatbot"]
DEFAULT_DUMP = ROOT / "database" / "Samuel Part BackEnd B1 - clean.sql"
PROFILES = {"mufasa_api": "DATABASE_URL", "mufasa_chat": "CHAT_DATABASE_URL", "mufasa_calculation": "CALCULATION_DATABASE_URL"}


class BuildError(RuntimeError):
    pass


def fail(msg: str) -> None:
    raise BuildError(msg)


class Executor:

    def __init__(self, url_admin: str):
        u = make_url(url_admin)
        self.params = {"host": u.host or "localhost", "port": u.port or 5432, "user": u.username or "postgres",
                       "password": u.password or "", "connect_timeout": 10}

    def _connect(self, database: str):
        try:
            return psycopg.connect(dbname=database, autocommit=True, **self.params)
        except psycopg.OperationalError as exc:
            fail(f"could not connect to PostgreSQL at {self.params['host']}:{self.params['port']} "
                   f"as {self.params['user']}: {str(exc).strip().splitlines()[-1]}")

    def command(self, database: str, query) -> None:
        with self._connect(database) as c:
            self._run(c, query)

    def file(self, database: str, path: Path) -> None:
        self.script(database, path.read_text(encoding="utf-8"), path.name)

    def script(self, database: str, text: str, name: str = "script") -> None:
        with self._connect(database) as c:
            pending: list[str] = []
            rows = iter(text.splitlines(keepends=True))
            for l in rows:
                if l.startswith("\\"):
                    continue
                if l.startswith("COPY ") and l.rstrip().endswith("FROM stdin;"):
                    self._run(c, "".join(pending), name)
                    pending = []
                    try:
                        with c.cursor().copy(l.rstrip().rstrip(";")) as copy:
                            for data in rows:
                                if data.startswith("\\."):
                                    break
                                copy.write(data)
                    except psycopg.Error as exc:
                        fail(f"{name}: error loading data ({l[:60].strip()}...): {exc}")
                    continue
                pending.append(l)
            self._run(c, "".join(pending), name)

    @staticmethod
    def _run(connection, query, name: str = "command") -> None:
        if isinstance(query, str) and not query.strip():
            return
        try:
            connection.execute(query)
        except psycopg.Error as exc:
            fail(f"{name}: {str(exc).strip()}")


def read_dump(dump: Path, only_schema: bool = False) -> str:
    output, in_data = [], False
    for l in dump.read_text(encoding="utf-8").splitlines(keepends=True):
        if l.startswith(("\\restrict", "\\unrestrict")):
            continue
        if only_schema:
            if in_data:
                in_data = not l.startswith("\\.")
                continue
            if l.startswith("COPY ") and l.rstrip().endswith("FROM stdin;"):
                in_data = True
                continue
        output.append(l)
    return "".join(output)


def construct(url_admin: str, dump: Path, only_schema: bool = False, speak=print) -> None:
    database = make_url(url_admin).database or "mufasa"
    if not database.replace("_", "").isalnum():
        fail("Invalid database name in DATABASE_URL_ADMIN.")
    ex = Executor(url_admin)

    speak(f"1/7 recreating the database {database}")
    ex.command("postgres", sql.SQL("DROP DATABASE IF EXISTS {} WITH (FORCE)").format(sql.Identifier(database)))
    ex.command("postgres", sql.SQL("CREATE DATABASE {} ENCODING 'UTF8' TEMPLATE template0")
               .format(sql.Identifier(database)))

    speak("2/7 loading the B1 dump" + (" (structure only)" if only_schema else ""))
    ex.script(database, read_dump(dump, only_schema), dump.name)

    speak("3/7 applying the system scripts")
    for name in SQL_FILES:
        speak(f"    sql/{name}.sql")
        ex.file(database, ROOT / "sql" / f"{name}.sql")

    speak("4/7 setting the database profile passwords")
    for profile, var in PROFILES.items():
        ex.command(database, sql.SQL("ALTER ROLE {} PASSWORD {}").format(
            sql.Identifier(profile), sql.Literal(make_url(os.environ[var]).password)))

    speak("5/7 encrypting the support data")
    environment = {**os.environ, "DATABASE_URL": url_admin}
    subprocess.run([sys.executable, "-m", "scripts.migrate_support"], cwd=ROOT, env=environment, check=True,
                   capture_output=not only_schema)

    speak("6/7 applying migrations")
    from scripts.migrate import migrate
    if migrate(url_admin) != 0:
        fail("migrations not applied")
    if not only_schema:
        speak("    simulated activities (scripts/simulate_activities)")
        from scripts.simulate_activities import simulate
        simulate(url_admin, speak=lambda m: speak("    " + m))


def check_configuration(url_admin: str | None) -> None:
    if not url_admin:
        fail("Set DATABASE_URL_ADMIN in .env (e.g.: postgresql+psycopg://postgres:PASSWORD@localhost:5432/mufasa).")
    for profile, var in PROFILES.items():
        u = os.environ.get(var)
        if not u or not make_url(u).password or "CHANGE" in u:
            fail(f"Set {var} in .env with the password of the {profile} profile.")
    if not os.environ.get("SUPPORT_KEY"):
        fail("Set SUPPORT_KEY in .env (see .env.example).")


def _already_built(url_admin: str) -> bool:
    from sqlalchemy import create_engine, text
    try:
        with create_engine(url_admin).connect() as c:
            if not c.execute(text("SELECT to_regclass('public.users') IS NOT NULL")).scalar():
                return False
            return bool(c.execute(text("SELECT EXISTS (SELECT 1 FROM users)")).scalar())
    except Exception:
        return False


def build(args) -> None:
    url_admin = os.environ.get("DATABASE_URL_ADMIN")
    check_configuration(url_admin)
    database = make_url(url_admin).database or "mufasa"
    dump = Path(args.dump or os.environ.get("MUFASA_DUMP") or DEFAULT_DUMP)
    if not dump.exists():
        fail(f"B1 dump not found at {dump}. Give it with --dump.")
    if args.if_not_exist and _already_built(url_admin):
        print(f"Database {database} already built: applying only the pending migrations.")
        from scripts.migrate import migrate
        from scripts.simulate_activities import simulate
        if migrate(url_admin) != 0:
            fail("migrations not applied")
        simulate(url_admin)
        return
    if not args.yes:
        resp = input(f"This ERASES the database '{database}' and builds it again. Continue? [y/N] ")
        if resp.strip().lower() not in ("y", "yes"):
            print("Nothing was done.")
            return
    construct(url_admin, dump)

    print("7/7 creating the accounts")
    accounts = ROOT / "database" / "initial_accounts.sql"
    if accounts.exists() and not args.new_accounts:
        Executor(url_admin).file(database, accounts)
        print("    delivery accounts loaded: passwords in database/initial_credentials.csv")
    else:
        output = os.environ.get("MUFASA_CREDENTIALS", "credentials.csv")
        subprocess.run([sys.executable, "-m", "scripts.generate_accounts", "--output", output], cwd=ROOT,
                       env={**os.environ, "DATABASE_URL_ADMIN": url_admin}, check=True)
        print(f"    new passwords in {output} (keep them and delete them afterwards)")
    print(f"\nDatabase {database} ready. Next step: python -m scripts.start")


def main() -> int:
    load_env()
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--dump", help="path of the B1 dump")
    ap.add_argument("--yes", action="store_true", help="do not ask for confirmation")
    ap.add_argument("--new-accounts", action="store_true", help="generate new passwords (credentials.csv)")
    ap.add_argument("--if-not-exist", action="store_true", help="only builds if the database does not exist yet (docker)")
    try:
        build(ap.parse_args())
    except BuildError as exc:
        print(f"\nERROR: {exc}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
