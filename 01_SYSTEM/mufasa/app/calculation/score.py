import math
from dataclasses import dataclass

from app.calculation.parameters import DEFAULT, WEIGHTS_BY_FACTOR, Parameters

MODEL_VERSION = "v1-deterministic.1"
CODE_VERSION = "3.0"

FACTORS = tuple(WEIGHTS_BY_FACTOR)
FACTOR_ID = {f: f"I{i}" for i, f in enumerate(FACTORS, start=1)}

LABELS = {
    "grades": "academic performance",
    "attendance": "attendance",
    "failure": "failure history",
    "lms_engagement": "participation in the virtual environment",
    "finance": "financial situation",
    "work": "working hours",
    "commute": "commute time",
    "mental_health": "mental health",
    "physical_health": "physical health",
    "housing": "housing situation",
    "dependents": "dependents under care",
}

LEVEL_NAMES = {"LOW": "low", "MODERATE": "moderate", "HIGH": "high", "CRITICAL": "critical",
               "UNDETERMINED": "undetermined"}
LEVEL_ORDER = {"UNDETERMINED": -1, "LOW": 0, "MODERATE": 1, "HIGH": 2, "CRITICAL": 3}

ACTIONABLE = {"grades": True, "attendance": True, "failure": True, "lms_engagement": True,
              "finance": True, "work": False, "commute": True, "mental_health": True,
              "physical_health": False, "housing": True, "dependents": True}

LEVEL_RECOMMENDATION = {
    "LOW": "Regular follow-up.",
    "MODERATE": "Preventive alert: watch list, with the teacher notified.",
    "HIGH": "Intervention recommended: alert in the queue, with an assigned owner, within 5 business days.",
    "CRITICAL": "Immediate active outreach, with the support center called in, within 48 hours.",
    "UNDETERMINED": "Data correction task: complete the record before classifying.",
}

WEIGHTS_NOTICE = ("Score calculated by a deterministic model of heuristic weights, version 1.1. It is not "
                  "an individual prediction or an automated decision.")


def _valid(value, minimum: float, maximum: float):
    if value is None or isinstance(value, bool):
        return None
    try:
        number = float(value)
    except (TypeError, ValueError):
        return None
    if not math.isfinite(number) or number < minimum or number > maximum:
        return None
    return number


def round_off(value: float) -> int:
    return int(math.floor(value + 0.5))


def _num(value: float, places: int = 1, fixed: bool = False) -> str:
    text = f"{value:.{places}f}"
    if places and not fixed and text.endswith("." + "0" * places):
        text = text[:-(places + 1)]
    return text


def _straight(excerpts, x):
    for start, end_date, p0, p1 in excerpts:
        if start <= x < end_date:
            return p0 + (p1 - p0) * (x - start) / (end_date - start)
    return None


def classify_risk_level(score, p: Parameters = DEFAULT) -> str:
    if score is None:
        return "UNDETERMINED"
    if score <= p["LOW_CUTOFF"]:
        return "LOW"
    if score <= p["MODERATE_CUTOFF"]:
        return "MODERATE"
    if score <= p["HIGH_CUTOFF"]:
        return "HIGH"
    return "CRITICAL"


def risk_by_grade(average, p: Parameters = DEFAULT):
    m = _valid(average, 0.0, 10.0)
    if m is None:
        return None
    conf, minimum, crit = p["COMFORTABLE_GRADE"], p["MINIMUM_GRADE"], p["CRITICAL_GRADE"]
    if m >= conf:
        return 0.0
    return round(_straight(((minimum, conf, 40.0, 0.0), (crit, minimum, 80.0, 40.0), (0.0, crit, 100.0, 80.0)), m), 2)


def risk_by_attendance(attendance, p: Parameters = DEFAULT):
    f = _valid(attendance, 0.0, 100.0)
    if f is None:
        return None
    conf, minimum, crit = p["COMFORTABLE_ATTENDANCE"], p["MINIMUM_ATTENDANCE"], p["CRITICAL_ATTENDANCE"]
    if f >= conf:
        return 0.0
    return round(_straight(((minimum, conf, 40.0, 0.0), (crit, minimum, 80.0, 40.0), (0.0, crit, 100.0, 80.0)), f), 2)


def risk_by_failure(rate_pct, failed_prerequisite: bool = False, third_attempt: bool = False):
    tr = _valid(rate_pct, 0.0, 100.0)
    if tr is None:
        return None
    if tr == 0:
        base = 0.0
    elif tr <= 15:
        base = 25.0
    elif tr <= 30:
        base = 50.0
    elif tr <= 50:
        base = 75.0
    else:
        base = 100.0
    base += 15.0 if failed_prerequisite else 0.0
    base += 20.0 if third_attempt else 0.0
    return min(100.0, base)


def risk_by_lms_engagement(engagement=None, delivery_rate=None, days_without_access=None,
                           p: Parameters = DEFAULT):
    eng = _valid(engagement, 0.0, 1000.0)
    ent = _valid(delivery_rate, 0.0, 1.0)
    days = _valid(days_without_access, 0.0, 10_000.0)
    if eng is None and ent is None and days is None:
        return None
    if (days is not None and days > p["LMS_DAYS_WITHOUT_ACCESS"]) or (ent is not None and ent < 0.40):
        return 100.0
    if (eng is not None and eng < 0.3) or (ent is not None and ent < 0.70):
        return 65.0
    if (eng is not None and eng < 0.7) or (ent is not None and ent < 0.90):
        return 35.0
    return 0.0


def risk_by_per_capita_income(income_mw, active_aid: bool = False, late_tuition: int = 0,
                              cadunico_without_income: bool = False, p: Parameters = DEFAULT):
    r = _valid(income_mw, 0.0, 1000.0)
    if r is None:
        if not cadunico_without_income:
            return None
        base = 85.0
    elif r <= p["INCOME_EXTREME"]:
        base = 100.0
    elif r <= p["INCOME_VULNERABLE"]:
        base = 85.0
    elif r < p["INCOME_ONE_MW"]:
        base = 60.0
    elif r <= p["INCOME_AID"]:
        base = 30.0
    else:
        base = 0.0
    delays = int(_valid(late_tuition, 0, 1000) or 0)
    base += 35.0 if delays >= 2 else 20.0 if delays == 1 else 0.0
    base -= 20.0 if active_aid else 0.0
    return max(0.0, min(100.0, base))


def risk_by_work(hours_per_week, same_shift: bool = False, internship_in_area: bool = False,
                 informal: bool = False, p: Parameters = DEFAULT):
    h = _valid(hours_per_week, 0.0, 168.0)
    if h is None:
        return None
    if h <= 0:
        return 0.0
    if same_shift:
        return 100.0
    if h <= p["WORK_HOURS_LIMIT"]:
        base = 20.0
    elif h <= 30:
        base = 50.0
    elif h <= 40:
        base = 75.0
    else:
        base = 100.0
    base -= 15.0 if internship_in_area else 0.0
    base += 10.0 if informal else 0.0
    return max(0.0, min(100.0, base))


def risk_by_commute(minutes, two_or_more_buses: bool = False, p: Parameters = DEFAULT):
    m = _valid(minutes, 0.0, 1440.0)
    if m is None:
        return None
    if m <= 20:
        base = 0.0
    elif m <= 40:
        base = 25.0
    elif m <= p["COMMUTE_LIMIT"]:
        base = 50.0
    elif m <= 90:
        base = 75.0
    else:
        base = 100.0
    return min(100.0, base + (15.0 if two_or_more_buses else 0.0))


MENTAL_HEALTH = {"NONE": 0.0, "WITH_FOLLOWUP": 40.0, "WITHOUT_FOLLOWUP": 70.0, "LEAVE": 90.0}
PHYSICAL_HEALTH = {"NONE": 0.0, "CONTROLLED": 30.0, "CERTIFICATES": 70.0, "LEAVE": 90.0}
HOUSING = {"STABLE": 0.0, "COMMITTED_RENT": 35.0, "CHANGED_WITHOUT_NETWORK": 55.0,
           "CHANGE_IN_PERIOD": 60.0, "PRECARIOUS": 100.0}
CATEGORY_DESCRIPTION = {
    "NONE": "no declared difficulty", "WITH_FOLLOWUP": "declared difficulty, with follow-up",
    "WITHOUT_FOLLOWUP": "declared difficulty without follow-up or support request not handled",
    "LEAVE": "formal leave in the period", "CONTROLLED": "controlled condition, with follow-up",
    "CERTIFICATES": "condition that generated 3 or more medical certificates in the period", "STABLE": "stable housing",
    "COMMITTED_RENT": "rent taking up a large share of income", "CHANGED_WITHOUT_NETWORK": "moved city without a support network",
    "CHANGE_IN_PERIOD": "change of residence in the period", "PRECARIOUS": "precarious or unsafe housing",
}


def risk_by_category(table_name: dict, category):
    return table_name.get(category) if isinstance(category, str) else None


def risk_by_dependents(quantity, continuous_care: bool = False):
    q = _valid(quantity, 0.0, 50.0)
    if q is None:
        return None
    if q <= 0:
        return 0.0
    if continuous_care:
        return 100.0
    return 40.0 if q < 2 else 70.0


@dataclass
class Factor:
    factor: str
    raw_value: float | None
    unit: str
    points: float
    weight: float
    explanation: str


def _factors(d: dict, p: Parameters) -> dict[str, Factor]:
    factors: dict[str, Factor] = {}

    def add(name, raw, unit, points, sentence):
        if points is not None:
            factors[name] = Factor(name, raw, unit, round(points, 2), p.weight(name), sentence)

    average = _valid(d.get("weighted_average"), 0, 10)
    points = risk_by_grade(average, p)
    if points is not None:
        minimum = p["MINIMUM_GRADE"]
        if average < minimum:
            sentence = (f"The weighted average of {_num(average, fixed=True)} is {_num(minimum - average, fixed=True)} "
                        f"point(s) below the minimum grade ({_num(minimum, fixed=True)}).")
        elif average < p["COMFORTABLE_GRADE"]:
            sentence = (f"The weighted average of {_num(average, fixed=True)} is above the minimum grade "
                        f"({_num(minimum, fixed=True)}), but below {_num(p['COMFORTABLE_GRADE'], fixed=True)}.")
        else:
            sentence = f"The weighted average of {_num(average, fixed=True)} does not indicate risk."
        variation = _valid(d.get("average_variation"), -10, 10)
        if variation is not None and variation < 0:
            sentence = sentence[:-1] + f", with a drop of {_num(-variation, fixed=True)} point(s) compared to the previous period."
        add("grades", average, "average 0-10", points, sentence)

    att = _valid(d.get("attendance_percentage"), 0, 100)
    points = risk_by_attendance(att, p)
    if points is not None:
        minimum = p["MINIMUM_ATTENDANCE"]
        if att < minimum:
            sentence = f"Attendance of {_num(att)}% is below the minimum of {_num(minimum, 0)}%."
        elif att < p["COMFORTABLE_ATTENDANCE"]:
            sentence = (f"Attendance of {_num(att)}% is above the minimum of {_num(minimum, 0)}%, but below "
                        f"{_num(p['COMFORTABLE_ATTENDANCE'], 0)}%.")
        else:
            sentence = f"Attendance of {_num(att)}% does not indicate risk."
        add("attendance", att, "%", points, sentence)

    tr = _valid(d.get("failure_rate_pct"), 0, 100)
    points = risk_by_failure(tr, bool(d.get("failed_prerequisite")), bool(d.get("third_attempt")))
    if points is not None:
        taken, failed = d.get("taken_subjects"), d.get("failed_subjects")
        detail = f" ({failed} of {taken} subjects taken)" if taken and failed is not None else ""
        add("failure", tr, "%", points, f"Failure rate of {_num(tr)}%{detail}.")

    points = risk_by_lms_engagement(d.get("lms_engagement"), d.get("lms_delivery_rate"),
                                    d.get("days_without_lms_access"), p)
    if points is not None:
        days = _valid(d.get("days_without_lms_access"), 0, 10_000)
        if days is not None and days > p["LMS_DAYS_WITHOUT_ACCESS"]:
            sentence = f"No access to the virtual environment for {int(days)} days."
        elif points:
            sentence = "Participation in the virtual environment below what is expected."
        else:
            sentence = "Participation in the virtual environment within what is expected."
        add("lms_engagement", d.get("lms_engagement"), "accesses per school day", points, sentence)

    income = _valid(d.get("per_capita_income_mw"), 0, 1000)
    points = risk_by_per_capita_income(income, bool(d.get("active_aid")), d.get("late_tuition") or 0,
                                       bool(d.get("cadunico_without_income")), p)
    if points is not None:
        sentence = (f"Income of {_num(income, 2)} minimum wage per person" if income is not None
                    else "CadÚnico registration without reported income")
        sentence += "; there is active retention aid." if d.get("active_aid") else "."
        add("finance", income, "minimum wage per person", points, sentence)

    hours = _valid(d.get("weekly_work_hours"), 0, 168)
    points = risk_by_work(hours, bool(d.get("same_shift_work")), bool(d.get("internship_in_area")),
                          bool(d.get("informal_work")), p)
    if points is not None:
        limit = p["WORK_HOURS_LIMIT"]
        if hours == 0:
            sentence = "Does not work."
        elif d.get("same_shift_work"):
            sentence = f"Working hours of {_num(hours, 0)} hours a week in the same shift as classes."
        elif hours > limit:
            sentence = (f"Working hours of {_num(hours, 0)} hours a week, above the limit of {_num(limit, 0)} hours "
                        "considered compatible with a study routine.")
        else:
            sentence = f"Working hours of {_num(hours, 0)} hours a week, within the limit of {_num(limit, 0)} hours."
        add("work", hours, "h/week", points, sentence)

    minutes = _valid(d.get("commute_minutes"), 0, 1440)
    points = risk_by_commute(minutes, bool(d.get("two_or_more_buses")), p)
    if points is not None:
        limit = p["COMMUTE_LIMIT"]
        comparison = "above" if minutes > limit else "inside"
        add("commute", minutes, "minutes per trip", points,
            f"Commute of {_num(minutes, 0)} minutes per trip, {comparison} the limit of "
            f"{_num(limit, 0)} minutes.")

    for name, table_name, label in (("mental_health", MENTAL_HEALTH, "Mental health"),
                                    ("physical_health", PHYSICAL_HEALTH, "Physical health"),
                                    ("housing", HOUSING, "Housing")):
        category = d.get(name)
        add(name, None, "declared category", risk_by_category(table_name, category),
            f"{label}: {CATEGORY_DESCRIPTION.get(category, '')}.")

    deps = _valid(d.get("dependents_count"), 0, 50)
    points = risk_by_dependents(deps, bool(d.get("continuous_care_dependent")))
    if points is not None:
        add("dependents", deps, "dependents", points,
            "No dependents under care." if deps == 0 else f"{_num(deps, 0)} dependent(s) under care.")

    return factors


def _modifiers(d: dict, factors: dict[str, Factor]) -> list[dict]:
    mods = []
    variation = _valid(d.get("average_variation"), -10, 10)
    finance = factors.get("finance")
    if finance and finance.points >= 60 and variation is not None and variation <= -1.5:
        mods.append({"id": "M1", "description": f"Financial situation scoring {_num(finance.points, 0)} "
                     f"and a drop of {_num(-variation)} point(s) in the average", "delta": 10})
    period = _valid(d.get("current_period"), 1, 30)
    if period is not None and period <= 2:
        mods.append({"id": "M2", "description": f"Student in period {int(period)}", "delta": 8})
    commute = factors.get("commute")
    if d.get("evening_shift") and commute and commute.points >= 75:
        mods.append({"id": "M3", "description": "Evening shift with a commute of "
                     f"{_num(commute.raw_value, 0)} minutes per trip", "delta": 7})
    averages = [float(m) for m in (d.get("periods_last_averages") or []) if _valid(m, 0, 10) is not None]
    if len(averages) >= 3:
        a, b, c = averages[-3:]
        if a > b > c:
            mods.append({"id": "M4", "description": "Average falling for two periods in a row", "delta": 10})
        att = _valid(d.get("attendance_percentage"), 0, 100)
        if a < b < c and att is not None and att >= 85:
            mods.append({"id": "M5", "description": "Average improving for two periods in a row, with attendance "
                         f"of {_num(att)}%", "delta": -8})
    return mods


def _overlaps(d: dict, p: Parameters) -> list[dict]:
    rules = []
    minimum = p["MINIMUM_ATTENDANCE"]
    if d.get("period_in_progress", True):
        subjects = d.get("subjects") or []
        below = [x for x in subjects
                 if _valid(x.get("attendance_pct"), 0, 100) is not None and float(x["attendance_pct"]) < minimum]
        if below:
            worst = min(below, key=lambda x: float(x["attendance_pct"]))
            extra = f" and in {len(below) - 1} more subject(s)" if len(below) > 1 else ""
            rules.append({"id": "S1", "level": "HIGH", "reason": (
                f"S1: attendance of {_num(float(worst['attendance_pct']), 0)}% in "
                f"{worst.get('name') or 'one subject'}{extra}, below the minimum of {_num(minimum, 0)}%")})
        elif not subjects:
            att = _valid(d.get("attendance_percentage"), 0, 100)
            if att is not None and att < minimum:
                rules.append({"id": "S1", "level": "HIGH", "reason": (
                    f"S1: attendance of {_num(att, 0)}%, below the minimum of {_num(minimum, 0)}%")})
    days = _valid(d.get("days_without_presence"), 0, 10_000)
    if days is not None and days >= 15:
        rules.append({"id": "S2", "level": "CRITICAL", "reason": (
            f"S2: {int(days)} calendar days without presence in all subjects")})
    if d.get("without_days_30_posting"):
        rules.append({"id": "S3", "level": "CRITICAL", "reason": (
            "S3: period started more than 30 days ago without any grade or attendance posted")})
    if d.get("enrollment_lock_requested"):
        rules.append({"id": "S4", "level": "CRITICAL", "reason": "S4: enrollment lock request recorded"})
    return rules


def _sort(factors) -> list[Factor]:
    return sorted(factors, key=lambda f: (-(f.weight * f.points), FACTORS.index(f.factor)))


def _json_factor(f: Factor, available_weight: float, points_sum: float) -> dict:
    points = f.weight * f.points / available_weight if available_weight else 0.0
    return {
        "id": FACTOR_ID[f.factor], "factor": f.factor, "name": LABELS[f.factor],
        "raw_value": f.raw_value, "unit": f.unit, "points": f.points,
        "weight": f.weight, "points_contribution": round(points, 1),
        "contribution_pct": round(100 * points / points_sum, 1) if points_sum else 0.0,
        "actionable": ACTIONABLE[f.factor], "explanation": f.explanation,
    }


def calculate_student_score(student_data: dict, parameters: Parameters = DEFAULT) -> dict:
    p = parameters
    factors = _factors(student_data, p)
    available_weight = sum(f.weight for f in factors.values())
    completeness = round(available_weight, 4)
    overlaps = _overlaps(student_data, p)
    ordered = _sort(factors.values())
    total_sum = sum(f.weight * f.points for f in ordered) / available_weight if available_weight else 0.0

    result = {
        "enrollment": student_data.get("enrollment"),
        "completeness": completeness,
        "partial": False,
        "model_version": MODEL_VERSION,
        "parameters_version": p.version_label,
        "weights_notice": WEIGHTS_NOTICE,
        "factors": [_json_factor(f, available_weight, total_sum) for f in ordered],
        "breakdown": {f.factor: f.points for f in ordered},
        "attendance_overlap": any(s["id"] == "S1" for s in overlaps),
        "overlap_reason": "; ".join(s["reason"] for s in overlaps) or None,
    }

    if completeness * 100 < p["MINIMUM_COMPLETENESS"] - 1e-9:
        level, origin = "UNDETERMINED", "COMPLETENESS"
        if overlaps:
            level, origin = max((s["level"] for s in overlaps), key=LEVEL_ORDER.get), "OVERLAP"
        return {**result, "score": None, "level": level, "origin_level": origin, "main_factors": [],
                "modifiers": [], "contributions": {}, "recommendation": LEVEL_RECOMMENDATION[level]}

    modifiers = _modifiers(student_data, factors)
    score = round_off(max(0.0, min(100.0, total_sum + sum(m["delta"] for m in modifiers))))

    level = classify_risk_level(score, p)
    partial = completeness * 100 < p["FULL_COMPLETENESS"] - 1e-9
    origin = "BAND"
    if partial and level == "CRITICAL":
        level, origin = "HIGH", "PARTIAL_BAND"
    for rule in overlaps:
        if LEVEL_ORDER[rule["level"]] > LEVEL_ORDER[level]:
            level, origin = rule["level"], "OVERLAP"

    main = [f.factor for i, f in enumerate(ordered) if (i < 3 and f.points > 0) or f.points >= 50]

    return {
        **result,
        "score": score,
        "level": level,
        "origin_level": origin,
        "partial": partial,
        "main_factors": main,
        "modifiers": modifiers,
        "contributions": {f.factor: round(f.weight * f.points / available_weight, 1) for f in ordered},
        "recommendation": LEVEL_RECOMMENDATION[level],
    }


def calculate_trend(scores: list) -> str | None:
    series = [s for s in scores if s is not None]
    if len(series) < 2:
        return None
    if len(series) >= 3 and series[-3] < series[-2] < series[-1]:
        return "SUSTAINED_DECLINE"
    if series[-1] > series[-2]:
        return "DECLINE"
    if series[-1] < series[-2]:
        return "IMPROVEMENT"
    return "STABLE"


def explain_score(result: dict) -> str:
    level = result.get("level")
    if result.get("score") is None:
        if level == "UNDETERMINED":
            return (f"Could not calculate: only {round_off(result.get('completeness', 0) * 100)}% of the required data "
                    "is available, and the minimum is 40%. A data correction task was opened.")
        return (f"{LEVEL_NAMES.get(level, level)} level by overlap rule "
                f"({result.get('overlap_reason')}). The available data is not enough for the score.")

    names = [LABELS.get(f, f) for f in result.get("main_factors", [])]
    text = f"Risk score: {result['score']} out of 100, {LEVEL_NAMES.get(level, level)} level."
    if result.get("partial"):
        text += f" Partial score: {round_off(result['completeness'] * 100)}% of the data available."
    if names:
        items = ", ".join(names[:-1]) + " and " + names[-1] if len(names) > 1 else names[0]
        text += f" The factors that weighed the most were: {items}."
    else:
        text += " No factor showed relevant risk."
    if result.get("origin_level") == "OVERLAP":
        text += f" The level was raised by overlap rule: {result['overlap_reason']}."
    elif result.get("origin_level") == "PARTIAL_BAND":
        text += " With partial data, the Critical level is only assigned by overlap rule."
    return text
