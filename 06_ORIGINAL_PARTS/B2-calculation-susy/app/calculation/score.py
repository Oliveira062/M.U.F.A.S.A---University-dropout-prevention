"""
MUFASA dropout risk score.

SCALE: 0 = safe student, 100 = maximum dropout risk.

MIND THE DIRECTION OF THE SCALE. This is the inversion fixed in v2.2: the
score measures RISK, not performance. A student with grade 10 and 100%
attendance has risk close to ZERO, not 100. In almost every school
context a high number is a good thing; here it is the opposite.

Every risk function in this module follows this convention: it receives the raw
value of the factor and returns from 0 (no risk) to 100 (maximum risk), or None
when the data does not exist.

Compliance: RN01 (auditable and explainable score), RN05 (no automated
decision - the output is a recommendation to a human), LGPD art. 20.
"""

from app.calculation.indicators import calculate_remaining_absences

# Weights of the 11 factors, according to SRS v1.1. They add up to 1.00.
WEIGHTS = {
    "grades": 0.20,
    "attendance": 0.18,
    "finance": 0.11,
    "failure": 0.09,
    "lms_engagement": 0.08,
    "mental_health": 0.08,
    "work": 0.07,
    "commute": 0.05,
    "physical_health": 0.05,
    "housing": 0.05,
    "dependents": 0.04,
}

# Below this percentage of available weight, the score is not calculated.
MINIMUM_COMPLETENESS = 0.40

# Legal minimum attendance (LDB art. 47 par. 3). Configurable parameter.
LEGAL_MINIMUM_ATTENDANCE = 75.0

# Minimum passing grade. NO LEGAL BASIS in higher education: it comes from
# university autonomy (CF art. 207, LDB art. 53). Confirm in the bylaws.
MINIMUM_PASSING_GRADE = 6.0

BANDS = (
    (25, "LOW"),
    (50, "MODERATE"),
    (75, "HIGH"),
    (100, "CRITICAL"),
)

RECOMMENDATIONS = {
    "LOW": "Periodic monitoring.",
    "MODERATE": "Preventive attention from tutoring.",
    "HIGH": "Contact within 5 working days.",
    "CRITICAL": "Immediate active outreach by the coordination and support center, within 48 hours.",
    "UNDETERMINED": "Not enough data to assess. Complete the record before classifying.",
}

LABELS = {
    "grades": "academic performance",
    "attendance": "attendance",
    "finance": "financial situation",
    "failure": "failure history",
    "lms_engagement": "engagement in the virtual environment",
    "mental_health": "mental health",
    "work": "working hours",
    "commute": "commute time",
    "physical_health": "physical health",
    "housing": "housing situation",
    "dependents": "dependents under care",
}


# ---------------------------------------------------------------------------
# Classification
# ---------------------------------------------------------------------------

def classify_risk_level(score: int) -> str:
    """
    Converts the risk score into the corresponding range.

    SRS ranges: 0-25 LOW, 26-50 MODERATE, 51-75 HIGH, 76-100 CRITICAL.

    >>> classify_risk_level(63)
    'HIGH'
    """
    if score is None:
        return "UNDETERMINED"
    for limit, name in BANDS:
        if score <= limit:
            return name
    return "CRITICAL"


# ---------------------------------------------------------------------------
# Risk functions per factor
#
# All return 0 (no risk) to 100 (maximum risk), or None without data.
# The piecewise lines are deliberate: the coordinator must be able to redo
# the calculation by hand and reach the same number.
# ---------------------------------------------------------------------------

def risk_by_grade(average):
    """
    Risk derived from the weighted average. A HIGH average produces LOW risk.

    Average >= 8.0             -> 0   (no risk)
    Average between 6.0 and 8.0 -> 0 to 40, linear
    Average between 4.0 and 6.0 -> 40 to 80, linear
    Average < 4.0              -> 100

    >>> round(risk_by_grade(5.4), 1)
    52.0
    """
    if average is None:
        return None
    if average >= 8.0:
        return 0.0
    if average >= 6.0:
        return round(40 * (8.0 - average) / 2.0, 2)
    if average >= 4.0:
        return round(40 + 40 * (6.0 - average) / 2.0, 2)
    return 100.0


def risk_by_attendance(attendance):
    """
    Risk derived from the attendance percentage. HIGH attendance produces LOW risk.

    Att >= 90%          -> 0
    Att 75% to 90%      -> 0 to 40, linear
    Att 60% to 75%      -> 40 to 80, linear
    Att < 60%           -> 100

    >>> round(risk_by_attendance(68.0), 1)
    58.7
    """
    if attendance is None:
        return None
    if attendance >= 90.0:
        return 0.0
    if attendance >= 75.0:
        return round(40 * (90.0 - attendance) / 15.0, 2)
    if attendance >= 60.0:
        return round(40 + 40 * (75.0 - attendance) / 15.0, 2)
    return 100.0


def risk_by_work(hours_per_week):
    """
    Risk derived from the weekly work hours.

    The 20h threshold comes from Law 11,788/2008 (internships), which treats 20
    weekly hours as a workload compatible with academic life.

    0h          -> 0
    1 to 20h    -> 25
    21 to 30h   -> 50
    31 to 40h   -> 75
    above 40h   -> 100
    """
    if hours_per_week is None:
        return None
    if hours_per_week <= 0:
        return 0.0
    if hours_per_week <= 20:
        return 25.0
    if hours_per_week <= 30:
        return 50.0
    if hours_per_week <= 40:
        return 75.0
    return 100.0


def risk_by_failure(rate):
    """
    Risk derived from the failure rate in the history (0.0 to 1.0).

    A rate of 50% or more saturates at 100: half of the history failed
    is already the maximum risk scenario for this factor.

    >>> risk_by_failure(0.333)
    66.6
    """
    if rate is None:
        return None
    return round(min(100.0, rate * 200.0), 2)


def risk_by_per_capita_income(per_capita_income_mw):
    """
    Risk derived from family income per person, in minimum wages.

    Thresholds with a legal basis:
    - 0.5 MW per person: Decree 6,135/2007 (CadUnico criterion)
    - 1.5 MW per person: Decree 7,234/2010 (PNAES) and Law 12,711/2012

    <= 0.5 MW       -> 100
    0.5 to 1.5 MW   -> 100 to 40, linear
    1.5 to 3.0 MW   -> 40 to 0, linear
    > 3.0 MW        -> 0
    """
    if per_capita_income_mw is None:
        return None
    if per_capita_income_mw <= 0.5:
        return 100.0
    if per_capita_income_mw <= 1.5:
        return round(100 - 60 * (per_capita_income_mw - 0.5) / 1.0, 2)
    if per_capita_income_mw <= 3.0:
        return round(40 - 40 * (per_capita_income_mw - 1.5) / 1.5, 2)
    return 0.0


def risk_by_lms_engagement(week_accesses):
    """
    Risk derived from engagement in the virtual learning environment.

    No access in the week is a strong sign of disengagement.

    0 accesses      -> 100
    1 to 2 accesses -> 60
    3 to 5 accesses -> 30
    6 or more       -> 0
    """
    if week_accesses is None:
        return None
    if week_accesses <= 0:
        return 100.0
    if week_accesses <= 2:
        return 60.0
    if week_accesses <= 5:
        return 30.0
    return 0.0


def risk_by_commute(minutes):
    """
    Risk derived from the commute time to campus, in minutes.

    The 60-minute threshold follows the IBGE commute ranges.

    <= 30 min       -> 0
    31 to 60 min    -> 30
    61 to 90 min    -> 60
    > 90 min        -> 100
    """
    if minutes is None:
        return None
    if minutes <= 30:
        return 0.0
    if minutes <= 60:
        return 30.0
    if minutes <= 90:
        return 60.0
    return 100.0


def risk_by_dependents(quantity):
    """
    Risk derived from the number of dependents under the student's care.

    0 dependents    -> 0
    1               -> 40
    2               -> 70
    3 or more       -> 100
    """
    if quantity is None:
        return None
    if quantity <= 0:
        return 0.0
    if quantity == 1:
        return 40.0
    if quantity == 2:
        return 70.0
    return 100.0


def risk_by_declared_scale(level):
    """
    Converts a declared scale from 1 to 5 into a risk from 0 to 100.

    Used for the self-declared questionnaire factors: mental health,
    physical health and housing situation. Level 1 = great situation,
    level 5 = critical situation.

    SENSITIVE DATA: mental health and physical health are health data
    (LGPD art. 11). They require specific consent and stay in a separate,
    encrypted table, under B1's responsibility.
    """
    if level is None:
        return None
    if level < 1 or level > 5:
        return None
    return round((level - 1) * 25.0, 2)


# ---------------------------------------------------------------------------
# Consolidated score
# ---------------------------------------------------------------------------

def _risks_collect(student_data: dict) -> dict:
    """
    Builds the factor -> risk dictionary, accepting raw data or a ready risk.

    For each factor, if the "risk_<factor>" key comes filled in it is used
    directly; otherwise the risk is derived from the raw data. This
    lets B1 deliver raw data and B3 inject calculated values,
    without changing the interface.
    """
    def choose(factor_name, derived_value):
        ready = student_data.get(f"risk_{factor_name}")
        return ready if ready is not None else derived_value

    return {
        "grades": choose("grades", risk_by_grade(student_data.get("weighted_average"))),
        "attendance": choose("attendance", risk_by_attendance(student_data.get("attendance_percentage"))),
        "finance": choose("finance", risk_by_per_capita_income(student_data.get("per_capita_income_mw"))),
        "failure": choose("failure", risk_by_failure(student_data.get("failure_rate"))),
        "lms_engagement": choose("lms_engagement", risk_by_lms_engagement(student_data.get("week_lms_accesses"))),
        "mental_health": choose("mental_health", risk_by_declared_scale(student_data.get("mental_health_scale"))),
        "work": choose("work", risk_by_work(student_data.get("weekly_work_hours"))),
        "commute": choose("commute", risk_by_commute(student_data.get("commute_minutes"))),
        "physical_health": choose("physical_health", risk_by_declared_scale(student_data.get("physical_health_scale"))),
        "housing": choose("housing", risk_by_declared_scale(student_data.get("housing_scale"))),
        "dependents": choose("dependents", risk_by_dependents(student_data.get("dependents_count"))),
    }


def calculate_student_score(student_data: dict) -> dict:
    """
    Calculates a student's dropout risk score.

    Formula: score = sum(weight_i * risk_i) / sum(available weight_i)

    Missing factors are EXCLUDED from the numerator and the denominator, instead
    of receiving a made-up neutral value. The sum of the available weights is the
    completeness: below 40% the score is not calculated and the level comes out as
    UNDETERMINED (RN01).

    Overlap: attendance below the legal minimum forces level HIGH,
    whatever the weighted result. A student close to failing for
    absences needs contact even if the other factors are good.

    Returns a dictionary according to Contract 2 agreed between B2 and B3.
    """
    enrollment = student_data.get("enrollment")

    risks = _risks_collect(student_data)
    disponiveis = {k: v for k, v in risks.items() if v is not None}

    available_weight = sum(WEIGHTS[k] for k in disponiveis)
    completeness = round(available_weight, 4)

    remaining_absences = calculate_remaining_absences(
        student_data.get("expected_classes", 0),
        student_data.get("absences", 0),
    )

    if completeness < MINIMUM_COMPLETENESS:
        return {
            "enrollment": enrollment,
            "score": None,
            "level": "UNDETERMINED",
            "completeness": completeness,
            "main_factors": [],
            "breakdown": {k: round(v, 2) for k, v in disponiveis.items()},
            "remaining_absences": remaining_absences,
            "attendance_overlap": False,
            "recommendation": RECOMMENDATIONS["UNDETERMINED"],
        }

    weighted_sum = sum(WEIGHTS[k] * v for k, v in disponiveis.items())
    score = int(round(weighted_sum / available_weight))
    score = max(0, min(100, score))

    level = classify_risk_level(score)

    attendance = student_data.get("attendance_percentage")
    overlap = False
    if (
        attendance is not None
        and attendance < LEGAL_MINIMUM_ATTENDANCE
        and level in ("LOW", "MODERATE")
    ):
        level = "HIGH"
        overlap = True

    contributions = sorted(
        ((k, WEIGHTS[k] * v) for k, v in disponiveis.items()),
        key=lambda par: par[1],
        reverse=True,
    )
    main_factors = [name for name, contrib in contributions[:3] if contrib > 0]

    return {
        "enrollment": enrollment,
        "score": score,
        "level": level,
        "completeness": completeness,
        "main_factors": main_factors,
        "breakdown": {k: round(v, 2) for k, v in disponiveis.items()},
        "remaining_absences": remaining_absences,
        "attendance_overlap": overlap,
        "recommendation": RECOMMENDATIONS[level],
    }


def explain_score(result: dict) -> str:
    """
    Generates the natural language explanation of the score, for the dashboard and the chatbot.

    Meets business rule 8 (every score comes with the factors that
    produced it) and RN01.
    """
    if result.get("level") == "UNDETERMINED":
        return (
            "Could not assess: only "
            f"{int(result.get('completeness', 0) * 100)}% of the required data "
            "are filled in. Minimum required: 40%."
        )

    factors = result.get("main_factors", [])
    names = [LABELS.get(f, f) for f in factors]

    if names:
        items = ", ".join(names[:-1]) + " and " + names[-1] if len(names) > 1 else names[0]
        text = (
            f"Score {result['score']} of 100, level {result['level']}. "
            f"The factors that weighed the most were: {items}."
        )
    else:
        text = (
            f"Score {result['score']} of 100, level {result['level']}. "
            "No factor showed relevant risk."
        )

    if result.get("attendance_overlap"):
        text += (
            " The level was raised to HIGH because attendance is below "
            f"the minimum of {int(LEGAL_MINIMUM_ATTENDANCE)}%, "
            "regardless of the other factors."
        )

    remaining = result.get("remaining_absences")
    if remaining is not None:
        if remaining == 0:
            text += " The absence limit has already been reached."
        else:
            text += f" {remaining} absences left before the limit."

    return text
