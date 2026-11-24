import argparse
import os
import random
import sys
from datetime import date, timedelta

from sqlalchemy import create_engine, text

from scripts._environment import load_env

TYPES = (("Exercise list", "items"), ("Practical assignment", "work"), ("Questionnaire", "questionnaire"),
         ("Report", "report"), ("Seminar", "seminar"))

STUDENT_CLASSES = text("""
    SELECT m.student_id, m.class_id
      FROM enrollments m
     WHERE m.student_id IS NOT NULL
     ORDER BY m.student_id, m.class_id
""")
PENDING = text("""
    SELECT DISTINCT ON (student_id) student_id, COALESCE(pending_activities, 0) AS pending
      FROM academic_indicators
     ORDER BY student_id, academic_period DESC
""")
INSERT = text("""
    INSERT INTO student_activities (student_id, class_id, title, kind, deadline_at, delivered_at, simulated)
    VALUES (:student_id, :class_id, :title, :kind, :deadline_at, :delivered_at, TRUE)
""")


def generate(student_id: str, classes: list[str], pending: int, today: date) -> list[dict]:
    draw = random.Random(student_id)
    rows, number = [], {}

    def new(class_value: str, deadline: date, delivered: date | None) -> dict:
        title, kind = draw.choice(TYPES)
        number[(class_value, title)] = number.get((class_value, title), 0) + 1
        if kind in ("items", "questionnaire"):
            title = f"{title} {number[(class_value, title)]}"
        return {"student_id": student_id, "class_id": class_value, "title": title, "kind": kind,
                "deadline_at": deadline, "delivered_at": delivered}

    for class_value in classes:
        for _ in range(2):
            deadline = today - timedelta(days=draw.randint(8, 60))
            rows.append(new(class_value, deadline, deadline - timedelta(days=draw.randint(0, 3))))
    for i in range(pending):
        class_value = draw.choice(classes)
        days = -draw.randint(1, 10) if i % 3 == 2 else draw.randint(0, 21)
        rows.append(new(class_value, today + timedelta(days=days), None))
    return rows


def simulate(url: str, redo: bool = False, today: date | None = None, speak=print) -> int:
    today = today or date.today()
    engine = create_engine(url, hide_parameters=True)
    with engine.begin() as c:
        if c.execute(text("SELECT to_regclass('public.student_activities')")).scalar() is None:
            speak("student_activities table missing: run python -m scripts.migrate first")
            return 1
        if redo:
            c.execute(text("DELETE FROM student_activities WHERE simulated"))
        elif c.execute(text("SELECT EXISTS (SELECT 1 FROM student_activities)")).scalar():
            speak("activities already exist: nothing to do (use --redo to generate them again)")
            return 0
        classes: dict[str, list[str]] = {}
        for l in c.execute(STUDENT_CLASSES).mappings():
            classes.setdefault(l["student_id"], []).append(l["class_id"])
        pending = {l["student_id"]: int(l["pending"]) for l in c.execute(PENDING).mappings()}
        rows = [a for student, ts in classes.items() for a in generate(student, ts, pending.get(student, 0), today)]
        if rows:
            c.execute(INSERT, rows)
    engine.dispose()
    speak(f"{len(rows)} simulated activities created for {len(classes)} students")
    return 0


def main() -> int:
    load_env()
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--redo", action="store_true", help="erases the simulated ones and generates them again")
    args = ap.parse_args()
    url = os.environ.get("DATABASE_URL_ADMIN")
    if not url:
        print("Set DATABASE_URL_ADMIN in .env (database owner connection).", file=sys.stderr)
        return 2
    return simulate(url, args.redo)


if __name__ == "__main__":
    raise SystemExit(main())
