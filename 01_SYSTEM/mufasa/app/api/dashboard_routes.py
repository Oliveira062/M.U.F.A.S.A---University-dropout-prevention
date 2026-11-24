from datetime import date, timedelta
from enum import Enum
from typing import Annotated

from fastapi import APIRouter, Depends, Query, Request
from sqlalchemy.engine import Connection

from app.api import audit, dashboard_queries as sqlp
from app.api.auth import User, require_profiles
from app.api.database import get_connection
from app.api.errors import http_error
from app.api.schemas import METHODOLOGICAL_NOTICE
from app.api.db_parameters import current_parameters
from app.api.permissions import COORDINATION, BOARD, HEALTH_FACTORS, REFERRED_LABEL
from app.api.util import now, as_datetime, json_value
from app.calculation.score import WEIGHTS_NOTICE, LABELS

dashboard_router = APIRouter(prefix="/api/v1/dashboards", tags=["dashboards"])

LEVELS = ("CRITICAL", "HIGH", "MODERATE", "LOW", "UNDETERMINED", "PENDING")
BANDS = ("0-25", "26-50", "51-75", "76-100")
MAXIMUM_CALCULATION_SIGNAL_S = 60
EVOLUTION_DAYS = 30


class Shift(str, Enum):
    Morning = "Morning"
    Afternoon = "Afternoon"
    Evening = "Evening"


class Trend(str, Enum):
    IMPROVEMENT = "IMPROVEMENT"
    STABLE = "STABLE"
    DECLINE = "DECLINE"
    SUSTAINED_DECLINE = "SUSTAINED_DECLINE"


class Factor(str, Enum):
    grades = "grades"
    attendance = "attendance"
    failure = "failure"
    lms_engagement = "lms_engagement"
    finance = "finance"
    work = "work"
    commute = "commute"
    housing = "housing"
    dependents = "dependents"


def suppress(values: dict, minimum: int | None) -> tuple[dict, bool]:
    if not minimum:
        return dict(values), False
    output = {k: (None if v is not None and 0 < v < minimum else v) for k, v in values.items()}
    return output, any(output[k] is None and values[k] is not None for k in values)


class Slice:

    def __init__(self, semester: Annotated[int | None, Query(ge=1, le=20)] = None, shift: Shift | None = None,
                 factor: Factor | None = None, trend: Trend | None = None,
                 course: Annotated[str | None, Query(pattern=r"^[A-Z0-9]{2,12}$")] = None):
        self.semester, self.shift, self.factor, self.trend, self.course = semester, shift, factor, trend, course

    def parameters(self, user: User) -> dict:
        if user.profile == COORDINATION:
            if user.course_id is None:
                raise http_error(403, "Your user is not linked to a course.")
            course_id = user.course_id
        else:
            course_id = self.course
        return {"course_id": course_id, "semester": self.semester, "shift": self.shift.value if self.shift else None,
                "factor": self.factor.value if self.factor else None,
                "trend": self.trend.value if self.trend else None}


def _calculation_status(connection: Connection) -> dict:
    last = connection.execute(sqlp.LAST_CALCULATION).mappings().first()
    signal = connection.execute(sqlp.CALCULATION_SIGNAL).mappings().first()
    queue = connection.execute(sqlp.QUEUE_SIZE).scalar()
    age = None if signal is None else (now() - as_datetime(signal["last_signal"])).total_seconds()
    return {"last_calculation": json_value(last["last"]) if last else None,
            "service_in_ar": age is not None and age <= MAXIMUM_CALCULATION_SIGNAL_S,
            "seconds_since_signal": None if age is None else int(age),
            "students_in_queue": int(queue or 0),
            "notice": None if age is not None and age <= MAXIMUM_CALCULATION_SIGNAL_S else
            "The calculation service is not responding: the numbers show the last saved calculation."}


def _distribution(rows, minimum: int | None) -> tuple[list, int, bool]:
    counts = {n: 0 for n in LEVELS}
    for l in rows:
        counts[l["level"]] = int(l["total"])
    total = sum(counts.values())
    shown, suppressed = suppress(counts, minimum)
    return [{"level": n, "total": shown[n],
             "pct": None if suppressed or shown[n] is None or not total else round(100 * shown[n] / total, 1)}
            for n in LEVELS if counts[n] or n not in ("UNDETERMINED", "PENDING")], total, suppressed


@dashboard_router.get("/general-view")
def general_view(request: Request, cropped: Slice = Depends(),
                 user: User = Depends(require_profiles(COORDINATION, BOARD)),
                 connection: Connection = Depends(get_connection)):
    filters = cropped.parameters(user)
    p = current_parameters(connection)
    minimum = int(p["GROUP_MINIMUM"]) if user.profile == BOARD else None
    moment = now()

    distribution, total, suppressed = _distribution(
        connection.execute(sqlp.DISTRIBUTION_DASHBOARD, filters).mappings().all(), minimum)
    bands = {f: 0 for f in BANDS}
    for l in connection.execute(sqlp.SCORE_BANDS_DASHBOARD, filters).mappings():
        bands[l["band"]] = int(l["total"])
    bands, suppressed_band = suppress(bands, minimum)

    alerts = dict(connection.execute(sqlp.ALERTS_DASHBOARD, {"course_id": filters["course_id"], "now": moment})
                  .mappings().first())
    alerts, _ = suppress({k: int(v or 0) for k, v in alerts.items()}, minimum)

    risk_now = connection.execute(sqlp.AT_RISK_IN, {"course_id": filters["course_id"], "moment": moment}).mappings().first()
    before = connection.execute(sqlp.AT_RISK_IN, {"course_id": filters["course_id"],
                                                  "moment": moment - timedelta(days=7)}).mappings().first()
    variation = None
    if before["with_score"]:
        variation = {"in_now_risk": int(risk_now["at_risk"]), "at_risk_for_7_days": int(before["at_risk"]),
                     "difference": int(risk_now["at_risk"]) - int(before["at_risk"])}

    audit.register(request, "READ_DASHBOARD", "ALLOWED", user=user)
    return {
        "scope": "course" if user.profile == COORDINATION else "institution",
        "filters": {k: v for k, v in filters.items() if v is not None},
        "students": None if suppressed or suppressed_band or (minimum and total < minimum) else total,
        "there_was_suppression": bool(suppressed or suppressed_band),
        "distribution": distribution,
        "score_bands": [{"band": f, "total": bands[f]} for f in BANDS],
        "cutoffs": {"low": p["LOW_CUTOFF"], "moderate": p["MODERATE_CUTOFF"], "high": p["HIGH_CUTOFF"]},
        "alerts": alerts,
        "days_7_variation": variation,
        "previous_period": None,
        "previous_period_note": "No data: the B1 database has no score for the previous period.",
        "calculation": _calculation_status(connection),
        "group_minimum": minimum,
        "weights_notice": WEIGHTS_NOTICE,
        "notice": METHODOLOGICAL_NOTICE,
    }


def _factor_label(factor: str, profile: str) -> str:
    if factor in HEALTH_FACTORS and profile == COORDINATION:
        return REFERRED_LABEL
    return LABELS.get(factor, factor)


@dashboard_router.get("/analyses")
def analyses(request: Request, cropped: Slice = Depends(),
             days: Annotated[int, Query(ge=7, le=365)] = EVOLUTION_DAYS,
             user: User = Depends(require_profiles(COORDINATION, BOARD)),
             connection: Connection = Depends(get_connection)):
    filters = cropped.parameters(user)
    p = current_parameters(connection)
    minimum = int(p["GROUP_MINIMUM"]) if user.profile == BOARD else None
    course_id = filters["course_id"]

    first, _ = connection.execute(sqlp.FIRST_CALCULATION).first()
    evolution = []
    if first is not None:
        end_date = date.today()
        start = max(as_datetime(first).date(), end_date - timedelta(days=days - 1))
        for l in connection.execute(sqlp.RISK_EVOLUTION, {"start": start, "end_date": end_date, "course_id": course_id}).mappings():
            point = {"day": json_value(l["day"]), "at_risk": int(l["at_risk"]), "critical": int(l["critical"]),
                     "with_score": int(l["with_score"])}
            counts, _ = suppress({k: v for k, v in point.items() if k != "day"}, minimum)
            evolution.append({"day": point["day"], **counts})

    factors: dict[str, int] = {}
    for l in connection.execute(sqlp.FREQUENT_FACTORS, filters).mappings():
        label = _factor_label(l["factor"], user.profile)
        factors[label] = factors.get(label, 0) + int(l["total"])
    factors, _ = suppress(factors, minimum)

    comparison = {}
    if user.profile == BOARD:
        for l in connection.execute(sqlp.BY_COURSE).mappings():
            comparison.setdefault(l["course"], {n: 0 for n in LEVELS})[l["level"]] = int(l["total"])
    else:
        for l in connection.execute(sqlp.BY_SEMESTER, filters).mappings():
            comparison.setdefault(f"Semester {l['semester']}", {n: 0 for n in LEVELS})[l["level"]] = int(l["total"])
    comparison = {k: suppress(v, minimum)[0] for k, v in comparison.items()}

    effectiveness = _effectiveness(connection.execute(sqlp.EFFECTIVENESS, {"course_id": course_id}).mappings().all(), minimum or 1)
    causes = {(l["cause"] or "NOT_INFORMED"): int(l["total"])
              for l in connection.execute(sqlp.CAUSES, {"course_id": course_id}).mappings()}
    causes, _ = suppress(causes, minimum)

    service = []
    for l in connection.execute(sqlp.FIRST_ACTION_TIME, {"course_id": course_id}).mappings():
        total = int(l["total"])
        if minimum and total < minimum:
            service.append({"level": l["level"], "total": None, "in_deadline_pct": None, "average_hours": None})
            continue
        service.append({"level": l["level"], "total": total, "in_deadline_pct": round(100 * l["in_deadline"] / total, 1),
                        "average_hours": round(float(l["average_hours"]), 1)})

    divergences = int(connection.execute(sqlp.DIVERGENCES, {"course_id": course_id}).scalar() or 0)
    audit.register(request, "READ_ANALYSES", "ALLOWED", user=user)
    return {
        "evolution": evolution,
        "evolution_note": None if evolution else "No data: there are no calculated scores yet.",
        "frequent_factors": [{"factor": k, "students": v} for k, v in
                             sorted(factors.items(), key=lambda x: -(x[1] or 0))],
        "comparison": [{"group": g, "levels": v} for g, v in comparison.items()],
        "comparison_type": "course" if user.profile == BOARD else "semester",
        "effectiveness": effectiveness,
        "identified_causes": [{"cause": k, "alerts": v} for k, v in causes.items()],
        "first_service": service,
        "registered_divergences": None if minimum and 0 < divergences < minimum else divergences,
        "group_minimum": minimum,
        "weights_notice": WEIGHTS_NOTICE,
    }


def _effectiveness(rows, minimum: int) -> dict:
    groups = {True: {"total": 0, "remained": 0}, False: {"total": 0, "remained": 0}}
    for l in rows:
        g = groups[bool(l["there_was_contact"])]
        g["total"] += int(l["total"])
        if l["outcome"] in ("REMAINED", "IN_FOLLOWUP"):
            g["remained"] += int(l["total"])

    def rate(g):
        if g["total"] == 0 or g["total"] < minimum:
            return None
        return round(100 * g["remained"] / g["total"], 1)

    with_values, without = groups[True], groups[False]
    if with_values["total"] + without["total"] == 0:
        return {"available": False, "reason": "No data: no alert has been closed with a recorded outcome yet."}
    return {"available": True,
            "with_intervention": {"alerts": with_values["total"] if with_values["total"] >= minimum else None,
                                  "retention_pct": rate(with_values)},
            "without_intervention": {"alerts": without["total"] if without["total"] >= minimum else None,
                                     "retention_pct": rate(without)},
            "grade": "Retention = outcome 'remained' or 'in follow-up'. Descriptive comparison, "
                    "does not prove cause."}
