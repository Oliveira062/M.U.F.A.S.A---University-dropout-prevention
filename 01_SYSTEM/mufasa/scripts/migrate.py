import argparse
import hashlib
import os
import sys
from pathlib import Path

from sqlalchemy import create_engine, text

from scripts._environment import ROOT, load_env

FOLDER = ROOT / "sql" / "migrations"

CREATE_TABLE = text("""
    CREATE TABLE IF NOT EXISTS schema_migrations (
        file     VARCHAR(120) PRIMARY KEY,
        sha256      CHAR(64)     NOT NULL,
        applied_at TIMESTAMPTZ  NOT NULL DEFAULT now()
    )
""")
READ = text("SELECT file, sha256, applied_at FROM schema_migrations ORDER BY file")
REGISTER = text("INSERT INTO schema_migrations (file, sha256) VALUES (:file, :sha256)")


def files() -> list[Path]:
    return sorted(p for p in FOLDER.glob("*.sql") if p.name[:3].isdigit())


MODEL = """-- Migration {number}: {description}
-- Created on {data}. After it is applied, this file is not edited.
-- Runs in a transaction (all or nothing). A new table needs a GRANT for the
-- service that uses it: mufasa_api, mufasa_chat and/or mufasa_calculation.

"""


def new(description: str) -> Path:
    import re
    from datetime import date
    number = max((int(p.name[:3]) for p in files()), default=0) + 1
    name = re.sub(r"[^a-z0-9]+", "_", description.lower()).strip("_")[:60] or "migration"
    destination = FOLDER / f"{number:03d}_{name}.sql"
    destination.write_text(MODEL.format(number=f"{number:03d}", description=description,
                                     data=date.today().strftime("%d/%m/%Y")), encoding="utf-8")
    return destination


def summary(p: Path) -> str:
    return hashlib.sha256(p.read_bytes()).hexdigest()


def migrate(url: str, list_items: bool = False) -> int:
    engine = create_engine(url, hide_parameters=True)
    with engine.begin() as c:
        c.execute(CREATE_TABLE)
        applied = {l["file"]: l for l in c.execute(READ).mappings()}
    pending = []
    for p in files():
        done = applied.get(p.name)
        if done is None:
            pending.append(p)
        elif done["sha256"] != summary(p):
            print(f"ERROR: {p.name} was changed after it was applied. Create a new migration instead of editing.")
            return 1
    if list_items:
        for name, l in applied.items():
            print(f"applied  {name}  on {l['applied_at']:%d/%m/%Y %H:%M}")
        for p in pending:
            print(f"pending  {p.name}")
        if not applied and not pending:
            print("no migration in sql/migrations/")
        return 0
    for p in pending:
        print(f"applying {p.name} ...", end=" ")
        with engine.begin() as c:
            c.exec_driver_sql(p.read_text(encoding="utf-8"))
            c.execute(REGISTER, {"file": p.name, "sha256": summary(p)})
        print("ok")
    print(f"{len(pending)} migration(s) applied.")
    return 0


def main() -> int:
    load_env()
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--list-items", action="store_true")
    ap.add_argument("--new", metavar="DESCRIPTION", help="creates the next migration file, empty")
    args = ap.parse_args()
    if args.new:
        print(f"created {new(args.new).relative_to(ROOT)}: write the SQL and run python -m scripts.migrate")
        return 0
    url = os.environ.get("DATABASE_URL_ADMIN")
    if not url:
        print("Set DATABASE_URL_ADMIN in .env (database owner connection).", file=sys.stderr)
        return 2
    return migrate(url, args.list_items)


if __name__ == "__main__":
    raise SystemExit(main())
