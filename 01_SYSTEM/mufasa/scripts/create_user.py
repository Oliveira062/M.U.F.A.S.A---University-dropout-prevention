import argparse
import getpass
import os
import sys

from sqlalchemy import create_engine, text

from app.api.auth import generate_password_hash
from app.api.permissions import PROFILES

INSERT = text("""
    INSERT INTO users (login, password_hash, profile, student_id, id_professor, course_id)
    VALUES (:login, :password_hash, :profile, :student_id, :id_professor, :course_id)
""")

PASSWORD_MINIMUM_SIZE = 12


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("--login", required=True)
    p.add_argument("--profile", required=True, choices=PROFILES)
    p.add_argument("--student")
    p.add_argument("--professor")
    p.add_argument("--course")
    args = p.parse_args()

    url = os.environ.get("DATABASE_URL_ADMIN")
    if not url:
        print("Set DATABASE_URL_ADMIN in the environment.", file=sys.stderr)
        return 1

    password = getpass.getpass("Password: ")
    if password != getpass.getpass("Repeat the password: "):
        print("The passwords do not match.", file=sys.stderr)
        return 1
    if len(password) < PASSWORD_MINIMUM_SIZE or password.lower() == args.login.lower():
        print(f"Use at least {PASSWORD_MINIMUM_SIZE} characters, different from the login.", file=sys.stderr)
        return 1

    with create_engine(url, hide_parameters=True).begin() as connection:
        connection.execute(INSERT, {
            "login": args.login, "password_hash": generate_password_hash(password), "profile": args.profile,
            "student_id": args.student, "id_professor": args.professor, "course_id": args.course,
        })
    print("User created.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
