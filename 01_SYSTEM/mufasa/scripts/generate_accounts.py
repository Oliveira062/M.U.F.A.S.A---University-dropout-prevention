import argparse
import csv
import os
import sys
from concurrent.futures import ProcessPoolExecutor

from sqlalchemy import create_engine, text

from app.api.auth import generate_password_hash
from app.api.passwords import generate_temporary_password

STUDENTS_WITHOUT_ACCOUNT = text("""
    SELECT a.student_id, a.fictitious_name, a.course_id FROM students a
     WHERE NOT EXISTS (SELECT 1 FROM users u WHERE u.student_id = a.student_id OR lower(u.login) = lower(a.student_id))
     ORDER BY a.student_id
""")

LOGIN_EXISTS = text("SELECT 1 FROM users WHERE lower(login) = lower(:login)")

INSERT = text("""
    INSERT INTO users (login, password_hash, profile, student_id, id_professor, course_id, name, email,
                          must_change_password, demo)
    VALUES (:login, :password_hash, :profile, :student_id, :id_professor, :course_id, :name, :email,
            :must_change_password, :demo)
""")

PROFESSOR_WITH_MOST_STUDENTS = text("""
    SELECT t.id_professor FROM classes t JOIN enrollments m ON m.class_id = t.class_id
     GROUP BY t.id_professor ORDER BY count(*) DESC, t.id_professor LIMIT 1
""")

MAIN_COURSE = text("SELECT course_id FROM students GROUP BY course_id ORDER BY count(*) DESC LIMIT 1")


def demo_accounts(course_id: str, id_professor: str) -> list[dict]:
    base = {"student_id": None, "id_professor": None, "course_id": None, "email": None,
            "must_change_password": False, "demo": True}
    return [
        {**base, "login": "coordination.demo", "profile": "COORDINATION", "course_id": course_id,
         "name": "Coordination (demo)"},
        {**base, "login": "ssc.demo", "profile": "SUPPORT_CENTER", "course_id": course_id,
         "name": "Support center (demo)"},
        {**base, "login": "ssc2.demo", "profile": "SUPPORT_CENTER", "course_id": course_id,
         "name": "Support center 2 (demo)"},
        {**base, "login": "teacher.demo", "profile": "TEACHER", "id_professor": id_professor,
         "name": "Teacher (demo)"},
        {**base, "login": "finance.demo", "profile": "FINANCE", "name": "Finance office (demo)"},
        {**base, "login": "management.demo", "profile": "BOARD", "name": "Management / board (demo)"},
        {**base, "login": "admin.demo", "profile": "ADMIN", "name": "Technical administration (demo)"},
        {**base, "login": "dpo.demo", "profile": "DPO",
         "name": "Data protection officer (demo)"},
    ]


def _with_hash(account: dict) -> dict:
    password = generate_temporary_password()
    return {**account, "password": password, "password_hash": generate_password_hash(password)}


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("--output", required=True, help="CSV with login and temporary password")
    p.add_argument("--without-demo", action="store_true")
    args = p.parse_args()

    url = os.environ.get("DATABASE_URL_ADMIN")
    if not url:
        print("Set DATABASE_URL_ADMIN (database owner).", file=sys.stderr)
        return 1
    engine = create_engine(url, hide_parameters=True)

    with engine.connect() as connection:
        accounts = [{"login": a["student_id"], "profile": "STUDENT", "student_id": a["student_id"], "id_professor": None,
                   "course_id": a["course_id"], "name": a["fictitious_name"], "email": None, "must_change_password": True,
                   "demo": False} for a in connection.execute(STUDENTS_WITHOUT_ACCOUNT).mappings()]
        if not args.without_demo:
            course = connection.execute(MAIN_COURSE).scalar()
            professor = connection.execute(PROFESSOR_WITH_MOST_STUDENTS).scalar()
            accounts += [c for c in demo_accounts(course, professor)
                       if not connection.execute(LOGIN_EXISTS, {"login": c["login"]}).first()]

    if not accounts:
        print("No new account to create.")
        return 0
    print(f"Generating {len(accounts)} account(s) (bcrypt cost 12)...")
    with ProcessPoolExecutor() as group:
        ready = list(group.map(_with_hash, accounts, chunksize=20))

    with engine.begin() as connection:
        for c in ready:
            connection.execute(INSERT, {k: c[k] for k in ("login", "password_hash", "profile", "student_id", "id_professor",
                                                         "course_id", "name", "email", "must_change_password",
                                                         "demo")})

    new = not os.path.exists(args.output)
    descriptor = os.open(args.output, os.O_WRONLY | os.O_CREAT | os.O_APPEND, 0o600)
    with os.fdopen(descriptor, "a", newline="", encoding="utf-8") as file:
        writer = csv.writer(file, delimiter=";")
        if new:
            writer.writerow(["profile", "login", "temporary_password", "name", "demo", "swap_in_first_access"])
        for c in ready:
            writer.writerow([c["profile"], c["login"], c["password"], c["name"], "yes" if c["demo"] else "no",
                               "yes" if c["must_change_password"] else "no"])
    print(f"{len(ready)} account(s) created. Credentials in {args.output}.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
