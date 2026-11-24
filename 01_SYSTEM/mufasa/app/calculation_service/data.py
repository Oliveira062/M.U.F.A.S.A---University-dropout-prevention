import math
from datetime import date
from decimal import Decimal

from sqlalchemy.engine import Connection

from app.calculation.indicators import calculate_weighted_average
from app.calculation.parameters import Parameters
from app.calculation.score import risk_by_grade
from app.calculation_service import calculation_queries as sql

WEEKDAYS = 5
ADULTHOOD = 18


def _number(value, minimum: float, maximum: float) -> float | None:
    if value is None:
        return None
    try:
        number = float(value)
    except (TypeError, ValueError):
        return None
    if not math.isfinite(number) or number < minimum or number > maximum:
        return None
    return number


def _does_not_work(value) -> bool | None:
    if value is None:
        return None
    text = str(value).strip().lower()
    return text in ("", "n", "false", "0") or text.startswith(("no", "no"))


def _yes(value) -> bool:
    return value is not None and str(value).strip().lower() in ("yes", "s", "true", "1")


def _period_in_progress(start, end_date, today: date) -> bool:
    if start is None:
        return True
    start = start if isinstance(start, date) else date.fromisoformat(str(start))
    end_date = None if end_date is None else end_date if isinstance(end_date, date) else date.fromisoformat(str(end_date))
    return start <= today and (end_date is None or today <= end_date)


def build_data(connection: Connection, student_id: str, p: Parameters, today: date) -> tuple[dict, dict]:
    student = connection.execute(sql.STUDENT, {"student_id": student_id}).mappings().first()
    if student is None:
        raise LookupError("nonexistent student")
    rows = connection.execute(sql.PERIOD_SUBJECTS, {"student_id": student_id}).mappings().all()
    ind = connection.execute(sql.INDICATORS, {"student_id": student_id}).mappings().first() or {}
    soc = connection.execute(sql.SOCIOECONOMIC, {"student_id": student_id}).mappings().first() or {}

    period = rows[0]["academic_period"] if rows else None
    current = [l for l in rows if l["academic_period"] == period]
    subjects = []
    for l in current:
        grade = _number(l["final_grade"], 0, 10)
        subjects.append({
            "name": l["name"], "workload": _number(l["workload_h"], 1, 2000),
            "grade": grade, "attendance_pct": _number(l["attendance_pct"], 0, 100), "status": l["status"],
            "i1": risk_by_grade(grade, p),
        })

    with_ch = [d for d in subjects if d["workload"]]
    average = calculate_weighted_average([(d["grade"], d["workload"]) for d in with_ch if d["grade"] is not None])
    att = calculate_weighted_average([(d["attendance_pct"], d["workload"]) for d in with_ch
                                      if d["attendance_pct"] is not None])

    completed = [l for l in rows if l["status"] in ("Approved", "Failed")]
    failed = sum(1 for l in completed if l["status"] == "Failed")
    rate = 100.0 * failed / len(completed) if completed else None

    previous = _number(ind.get("previous_semester_average"), 0, 10)
    variation = round(average - previous, 2) if average is not None and previous is not None else None

    income = _number(soc.get("per_capita_income"), 0, 10_000_000)
    income_mw = float(Decimal(str(income)) / Decimal(str(p["MINIMUM_WAGE"]))) if income is not None else None

    does_not_work = _does_not_work(soc.get("works"))
    hours_per_day = _number(soc.get("daily_work_hours"), 0, 24)
    if does_not_work:
        hours_per_week = 0.0
    elif hours_per_day is not None:
        hours_per_week = hours_per_day * WEEKDAYS
    else:
        hours_per_week = None

    in_progress = any(_period_in_progress(l["start"], l["end_date"], today) for l in current) if current else True

    data = {
        "enrollment": student_id,
        "academic_period": period,
        "subjects": subjects,
        "weighted_average": average,
        "attendance_percentage": att,
        "average_variation": variation,
        "periods_last_averages": [m for m in (previous, average) if m is not None],
        "failure_rate_pct": rate,
        "taken_subjects": len(completed),
        "failed_subjects": failed,
        "per_capita_income_mw": income_mw,
        "active_aid": _yes(soc.get("scholarship_aid")),
        "weekly_work_hours": hours_per_week,
        "commute_minutes": _number(soc.get("commute_time_min"), 0, 1440),
        "current_period": _number(student["current_semester"], 1, 30),
        "evening_shift": any((l["shift"] or "").lower() == "evening" for l in current),
        "period_in_progress": in_progress,
    }
    age = _number(student["age"], 0, 150)
    context = {"course_id": student["course_id"], "underage": age is not None and age < ADULTHOOD}
    return data, context
