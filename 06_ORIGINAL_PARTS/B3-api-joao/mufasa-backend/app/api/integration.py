"""
B1 -> B2 bridge: reads the B1 tables and builds the dictionary that
B2's calculate_student_score() expects. No calculation rule here: only
reading, unit conversion and discarding impossible values.

Points that depend on B1 (see docs/SECURITY_AUDIT.md):
- B1 has no expected classes or subjects taken in the history, so
  remaining absences and failure rate come out as missing.
- B1 has no mental health, physical health, housing, dependents or VLE.
  These factors stay missing and B2 excludes them from the calculation.
- daily_work_hours becomes hours per week by multiplying by 5 working days.
  Confirm with B1 whether the column is per working day.
"""

import math
from decimal import Decimal

from sqlalchemy.engine import Connection

from app.api.queries import CURRENT_INDICATORS, RESTRICTED_SOCIOECONOMIC
from app.calculation.score import WEIGHTS
from app.config import Configuration

# B2 returns CRITICAL; the B1 database stores "Critical". The API always returns the
# SRS format (uppercase, no accents).
DATABASE_LEVEL = {"Low": "LOW", "Moderate": "MODERATE", "High": "HIGH", "Critical": "CRITICAL"}
LEVEL_FOR_DATABASE = {v: k for k, v in DATABASE_LEVEL.items()}

WEEKDAYS = 5


def _number(value, minimum: float, maximum: float) -> float | None:
    """Converts to float and discards NaN, infinity and out-of-range values."""
    if value is None:
        return None
    try:
        number = float(value)
    except (TypeError, ValueError):
        return None
    if not math.isfinite(number) or number < minimum or number > maximum:
        return None
    return number


def _works(value) -> bool | None:
    if value is None:
        return None
    text = str(value).strip().lower()
    if text in ("no", "no", "n", "false", "0", ""):
        return False
    return True


def build_score_data(connection: Connection, student_id: str, cfg: Configuration) -> dict:
    ind = connection.execute(CURRENT_INDICATORS, {"student_id": student_id}).mappings().first() or {}
    soc = connection.execute(RESTRICTED_SOCIOECONOMIC, {"student_id": student_id}).mappings().first() or {}

    hours_per_day = _number(soc.get("daily_work_hours"), 0, 24)
    works = _works(soc.get("works"))
    if works is False:
        hours_per_week = 0.0
    elif hours_per_day is not None:
        hours_per_week = hours_per_day * WEEKDAYS
    else:
        hours_per_week = None

    income_mw = None
    income = _number(soc.get("per_capita_income"), 0, 1_000_000)
    if income is not None and cfg.minimum_wage:
        income_mw = float(Decimal(str(income)) / cfg.minimum_wage)

    return {
        "enrollment": student_id,
        "weighted_average": _number(ind.get("current_average"), 0, 10),
        "attendance_percentage": _number(ind.get("attendance_pct"), 0, 100),
        "absences": _number(ind.get("total_absences"), 0, 10_000),
        "expected_classes": None,
        "failure_rate": None,
        "weekly_work_hours": hours_per_week,
        "per_capita_income_mw": income_mw,
        "commute_minutes": _number(soc.get("commute_time_min"), 0, 1_440),
    }


def missing_factors(result: dict) -> list[str]:
    present = set(result.get("breakdown", {}))
    return [f for f in WEIGHTS if f not in present]
