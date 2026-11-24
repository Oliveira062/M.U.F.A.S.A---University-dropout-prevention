"""
Tests for the MUFASA calculation module.

PRINCIPLE: a test must be able to FAIL. Assertions such as
`assert "score" in result` or `assert level in ["HIGH","LOW","CRITICAL"]`
pass even with wrong code, and that is exactly why the inverted
scale got through v2.1 undetected. Every test here requires an
exact value or a verifiable order relation.
"""

import pytest

from app.calculation.indicators import (
    calculate_remaining_absences,
    calculate_attendance_percentage,
    calculate_weighted_average,
    calculate_failure_rate,
    calculate_registration_completeness,
)
from app.calculation.score import (
    WEIGHTS,
    MINIMUM_COMPLETENESS,
    calculate_student_score,
    classify_risk_level,
    explain_score,
    risk_by_grade,
    risk_by_attendance,
    risk_by_work,
    risk_by_failure,
    risk_by_per_capita_income,
    risk_by_lms_engagement,
    risk_by_commute,
    risk_by_dependents,
    risk_by_declared_scale,
)


# ---------------------------------------------------------------------------
# Indicators
# ---------------------------------------------------------------------------

def test_remaining_absences():
    assert calculate_remaining_absences(80, 12) == 8
    assert calculate_remaining_absences(80, 25) == 0
    assert calculate_remaining_absences(80, 10) == 10
    assert calculate_remaining_absences(40, 0) == 10


def test_remaining_absences_never_negative():
    """An exceeded limit returns 0, not a negative number."""
    assert calculate_remaining_absences(80, 50) == 0


def test_attendance():
    assert calculate_attendance_percentage(80, 20) == 75.0
    assert calculate_attendance_percentage(80, 0) == 100.0
    assert calculate_attendance_percentage(50, 16) == 68.0


def test_attendance_without_recorded_class_returns_none():
    """
    Missing records are NOT perfect attendance.

    This is the error the SRS explicitly forbids: imputing 100% to
    missing attendance turns the strongest dropout signal into a signal
    of normality.
    """
    assert calculate_attendance_percentage(0, 0) is None
    assert calculate_attendance_percentage(None, 5) is None
    assert calculate_attendance_percentage(80, None) is None


def test_weighted_average():
    assert calculate_weighted_average([(5.0, 2.0), (6.0, 3.0)]) == 5.6
    assert calculate_weighted_average([(8.0, 4.0)]) == 8.0


def test_weighted_average_without_grade_returns_none():
    assert calculate_weighted_average([]) is None
    assert calculate_weighted_average([(7.0, 0.0)]) is None


def test_failure_rate():
    assert calculate_failure_rate(6, 2) == 0.333
    assert calculate_failure_rate(10, 0) == 0.0


def test_failure_rate_without_history_returns_none():
    """An incoming student does not have a rate of 0: they have no rate."""
    assert calculate_failure_rate(0, 0) is None
    assert calculate_failure_rate(None, 0) is None


def test_registration_completeness():
    assert calculate_registration_completeness(6, 10) == 0.6
    assert calculate_registration_completeness(0, 10) == 0.0
    assert calculate_registration_completeness(5, 0) == 0.0


# ---------------------------------------------------------------------------
# Classification ranges
# ---------------------------------------------------------------------------

def test_ranges_at_exact_limits():
    """Tests the edges, where a <= vs < error shows up."""
    assert classify_risk_level(0) == "LOW"
    assert classify_risk_level(25) == "LOW"
    assert classify_risk_level(26) == "MODERATE"
    assert classify_risk_level(50) == "MODERATE"
    assert classify_risk_level(51) == "HIGH"
    assert classify_risk_level(75) == "HIGH"
    assert classify_risk_level(76) == "CRITICAL"
    assert classify_risk_level(100) == "CRITICAL"


def test_range_uses_moderate_not_medium():
    """SRS standardization: the level is called MODERATE."""
    assert classify_risk_level(40) == "MODERATE"


def test_none_score_becomes_undetermined():
    assert classify_risk_level(None) == "UNDETERMINED"


# ---------------------------------------------------------------------------
# THE TEST THAT CAUGHT THE v2.1 BUG
# ---------------------------------------------------------------------------

def test_scale_direction():
    """
    The scale is RISK, not performance.

    In v2.1 the model student got a score of 90 (CRITICAL) and the student
    dropping out got 0 (LOW). This test fails any reintroduction
    of that inversion.
    """
    exemplar_student = {
        "weighted_average": 9.5,
        "attendance_percentage": 98.0,
        "weekly_work_hours": 0,
        "failure_rate": 0.0,
        "per_capita_income_mw": 4.0,
        "week_lms_accesses": 10,
        "mental_health_scale": 1,
        "commute_minutes": 15,
        "physical_health_scale": 1,
        "housing_scale": 1,
        "dependents_count": 0,
        "expected_classes": 80,
        "absences": 2,
    }
    student_in_dropout = {
        "weighted_average": 2.0,
        "attendance_percentage": 40.0,
        "weekly_work_hours": 48,
        "failure_rate": 0.8,
        "per_capita_income_mw": 0.3,
        "week_lms_accesses": 0,
        "mental_health_scale": 5,
        "commute_minutes": 110,
        "physical_health_scale": 4,
        "housing_scale": 5,
        "dependents_count": 2,
        "expected_classes": 80,
        "absences": 48,
    }

    r_exemplar = calculate_student_score(exemplar_student)
    dropout_r = calculate_student_score(student_in_dropout)

    assert r_exemplar["score"] < dropout_r["score"]
    assert r_exemplar["score"] == 0
    assert r_exemplar["level"] == "LOW"
    assert dropout_r["score"] >= 76
    assert dropout_r["level"] == "CRITICAL"


def test_grade_monotonicity():
    """Worsening the grade can never lower the risk."""
    base = {
        "attendance_percentage": 85.0,
        "weekly_work_hours": 0,
        "failure_rate": 0.0,
        "per_capita_income_mw": 2.0,
        "week_lms_accesses": 6,
    }
    previous = -1
    for average in [10.0, 8.0, 7.0, 6.0, 5.0, 4.0, 2.0]:
        current = calculate_student_score({**base, "weighted_average": average})["score"]
        assert current >= previous, f"risk dropped when the grade got worse to {average}"
        previous = current


def test_attendance_monotonicity():
    """Worsening attendance can never lower the risk."""
    base = {
        "weighted_average": 7.0,
        "weekly_work_hours": 0,
        "failure_rate": 0.0,
        "per_capita_income_mw": 2.0,
        "week_lms_accesses": 6,
    }
    previous = -1
    for att in [100.0, 90.0, 85.0, 80.0, 75.0, 70.0, 50.0]:
        current = calculate_student_score({**base, "attendance_percentage": att})["score"]
        assert current >= previous, f"risk dropped when attendance got worse to {att}"
        previous = current


# ---------------------------------------------------------------------------
# Risk functions per factor, with SRS values
# ---------------------------------------------------------------------------

def test_risk_by_grade_srs_values():
    assert risk_by_grade(5.4) == pytest.approx(52.0, abs=0.5)
    assert risk_by_grade(9.0) == 0.0
    assert risk_by_grade(8.0) == 0.0
    assert risk_by_grade(7.0) == pytest.approx(20.0, abs=0.5)
    assert risk_by_grade(6.0) == pytest.approx(40.0, abs=0.5)
    assert risk_by_grade(3.0) == 100.0
    assert risk_by_grade(None) is None


def test_risk_by_attendance_srs_values():
    assert risk_by_attendance(68.0) == pytest.approx(58.7, abs=0.5)
    assert risk_by_attendance(95.0) == 0.0
    assert risk_by_attendance(90.0) == 0.0
    assert risk_by_attendance(75.0) == pytest.approx(40.0, abs=0.5)
    assert risk_by_attendance(55.0) == 100.0
    assert risk_by_attendance(None) is None


def test_risk_by_work_srs_values():
    assert risk_by_work(0) == 0.0
    assert risk_by_work(20) == 25.0
    assert risk_by_work(30) == 50.0
    assert risk_by_work(40) == 75.0
    assert risk_by_work(44) == 100.0
    assert risk_by_work(None) is None


def test_risk_by_failure():
    assert risk_by_failure(0.0) == 0.0
    assert risk_by_failure(0.25) == 50.0
    assert risk_by_failure(0.5) == 100.0
    assert risk_by_failure(0.9) == 100.0
    assert risk_by_failure(None) is None


def test_risk_by_income_legal_thresholds():
    """0,5 SM = CadUnico; 1,5 SM = PNAES."""
    assert risk_by_per_capita_income(0.5) == 100.0
    assert risk_by_per_capita_income(1.5) == pytest.approx(40.0, abs=0.5)
    assert risk_by_per_capita_income(3.0) == 0.0
    assert risk_by_per_capita_income(5.0) == 0.0
    assert risk_by_per_capita_income(None) is None


def test_risk_by_vle_engagement():
    assert risk_by_lms_engagement(0) == 100.0
    assert risk_by_lms_engagement(2) == 60.0
    assert risk_by_lms_engagement(5) == 30.0
    assert risk_by_lms_engagement(10) == 0.0
    assert risk_by_lms_engagement(None) is None


def test_risk_by_commute():
    assert risk_by_commute(20) == 0.0
    assert risk_by_commute(60) == 30.0
    assert risk_by_commute(90) == 60.0
    assert risk_by_commute(120) == 100.0
    assert risk_by_commute(None) is None


def test_risk_by_dependents():
    assert risk_by_dependents(0) == 0.0
    assert risk_by_dependents(1) == 40.0
    assert risk_by_dependents(2) == 70.0
    assert risk_by_dependents(4) == 100.0
    assert risk_by_dependents(None) is None


def test_risk_by_declared_scale():
    assert risk_by_declared_scale(1) == 0.0
    assert risk_by_declared_scale(3) == 50.0
    assert risk_by_declared_scale(5) == 100.0
    assert risk_by_declared_scale(None) is None
    assert risk_by_declared_scale(9) is None


# ---------------------------------------------------------------------------
# Weights
# ---------------------------------------------------------------------------

def test_weights_add_up_to_one():
    assert sum(WEIGHTS.values()) == pytest.approx(1.0, abs=0.001)


def test_weights_match_srs():
    assert WEIGHTS["grades"] == 0.20
    assert WEIGHTS["attendance"] == 0.18
    assert WEIGHTS["finance"] == 0.11
    assert WEIGHTS["failure"] == 0.09
    assert WEIGHTS["lms_engagement"] == 0.08
    assert WEIGHTS["mental_health"] == 0.08
    assert WEIGHTS["work"] == 0.07
    assert WEIGHTS["commute"] == 0.05
    assert WEIGHTS["physical_health"] == 0.05
    assert WEIGHTS["housing"] == 0.05
    assert WEIGHTS["dependents"] == 0.04


def test_eleven_factors():
    assert len(WEIGHTS) == 11


# ---------------------------------------------------------------------------
# Completeness
# ---------------------------------------------------------------------------

def test_insufficient_completeness_becomes_undetermined():
    """Below 40% of available weight, the score is not calculated."""
    result = calculate_student_score({
        "enrollment": "2024002",
        "weighted_average": 5.0,
        "expected_classes": 80,
        "absences": 5,
    })
    assert result["level"] == "UNDETERMINED"
    assert result["score"] is None
    assert result["completeness"] < MINIMUM_COMPLETENESS
    assert "not enough" in result["recommendation"].lower()


def test_undetermined_still_delivers_remaining_absences():
    """
    Even without a score, the most useful information for the student is still available.
    """
    result = calculate_student_score({
        "enrollment": "2024003",
        "weighted_average": 7.0,
        "expected_classes": 80,
        "absences": 12,
    })
    assert result["level"] == "UNDETERMINED"
    assert result["remaining_absences"] == 8


def test_missing_factor_does_not_enter_the_average():
    """
    A null factor is excluded from the numerator AND the denominator.

    Do two students identical in the known factors have the same score,
    even if one has more factors filled in with zero risk? No:
    what matters is that missing data is not treated as zero risk.
    """
    with_bad_data = calculate_student_score({
        "weighted_average": 5.0,
        "attendance_percentage": 80.0,
        "per_capita_income_mw": 0.4,
        "week_lms_accesses": 1,
    })
    without_data = calculate_student_score({
        "weighted_average": 5.0,
        "attendance_percentage": 80.0,
        "week_lms_accesses": 1,
    })
    assert with_bad_data["completeness"] > without_data["completeness"]
    assert "finance" in with_bad_data["breakdown"]
    assert "finance" not in without_data["breakdown"]


def test_completeness_reflects_available_weights():
    result = calculate_student_score({
        "weighted_average": 7.0,
        "attendance_percentage": 90.0,
        "weekly_work_hours": 0,
    })
    expected = WEIGHTS["grades"] + WEIGHTS["attendance"] + WEIGHTS["work"]
    assert result["completeness"] == pytest.approx(expected, abs=0.001)


# ---------------------------------------------------------------------------
# Attendance overlap
# ---------------------------------------------------------------------------

def test_attendance_overlap_forces_high():
    """
    Attendance below 75% raises the level to HIGH, whatever the
    weighted score. A student close to failing for absences needs
    contact even with the other factors good.
    """
    result = calculate_student_score({
        "weighted_average": 9.0,
        "attendance_percentage": 70.0,
        "weekly_work_hours": 0,
        "failure_rate": 0.0,
        "per_capita_income_mw": 4.0,
        "expected_classes": 80,
        "absences": 24,
    })
    assert result["level"] == "HIGH"
    assert result["attendance_overlap"] is True


def test_overlap_does_not_downgrade_critical():
    """The overlap raises the level, never lowers it."""
    result = calculate_student_score({
        "weighted_average": 2.0,
        "attendance_percentage": 50.0,
        "weekly_work_hours": 48,
        "failure_rate": 0.9,
        "per_capita_income_mw": 0.2,
        "week_lms_accesses": 0,
    })
    assert result["level"] == "CRITICAL"
    assert result["attendance_overlap"] is False


def test_no_overlap_when_attendance_ok():
    result = calculate_student_score({
        "weighted_average": 9.5,
        "attendance_percentage": 95.0,
        "weekly_work_hours": 0,
        "failure_rate": 0.0,
        "per_capita_income_mw": 4.0,
    })
    assert result["attendance_overlap"] is False
    assert result["level"] == "LOW"


# ---------------------------------------------------------------------------
# Canonical SRS case
# ---------------------------------------------------------------------------

def test_srs_canonical_case():
    """
    Canonical case: average 5.4 / attendance 68% / work 44h.

    Expected individual scores: grade 52, attendance 58.7, work 100.
    The final level must be HIGH, with attendance among the main
    factors and the overlap active.
    """
    student = {
        "enrollment": "2024001",
        "weighted_average": 5.4,
        "attendance_percentage": 68.0,
        "expected_classes": 80,
        "absences": 25,
        "weekly_work_hours": 44,
        "failure_rate": 0.33,
    }
    result = calculate_student_score(student)

    assert result["enrollment"] == "2024001"
    assert result["level"] == "HIGH"
    assert result["remaining_absences"] == 0
    assert "attendance" in result["main_factors"]
    assert "grades" in result["main_factors"]
    assert result["breakdown"]["grades"] == pytest.approx(52.0, abs=0.5)
    assert result["breakdown"]["attendance"] == pytest.approx(58.7, abs=0.5)
    assert result["breakdown"]["work"] == 100.0


def test_score_always_between_zero_and_hundred():
    extremes = [
        {"weighted_average": 0.0, "attendance_percentage": 0.0,
         "weekly_work_hours": 100, "failure_rate": 1.0,
         "per_capita_income_mw": 0.0, "week_lms_accesses": 0,
         "mental_health_scale": 5, "physical_health_scale": 5,
         "housing_scale": 5, "dependents_count": 10,
         "commute_minutes": 300},
        {"weighted_average": 10.0, "attendance_percentage": 100.0,
         "weekly_work_hours": 0, "failure_rate": 0.0,
         "per_capita_income_mw": 50.0, "week_lms_accesses": 100,
         "mental_health_scale": 1, "physical_health_scale": 1,
         "housing_scale": 1, "dependents_count": 0,
         "commute_minutes": 0},
    ]
    for data in extremes:
        score = calculate_student_score(data)["score"]
        assert 0 <= score <= 100


# ---------------------------------------------------------------------------
# Output contract and explainability
# ---------------------------------------------------------------------------

def test_output_contract_has_all_keys():
    """Contract 2, agreed between B2 and B3."""
    result = calculate_student_score({
        "enrollment": "2024001",
        "weighted_average": 5.4,
        "attendance_percentage": 68.0,
        "weekly_work_hours": 44,
        "expected_classes": 80,
        "absences": 25,
    })
    for key in (
        "enrollment", "score", "level", "completeness", "main_factors",
        "breakdown", "remaining_absences", "attendance_overlap",
        "recommendation",
    ):
        assert key in result, f"key missing from the contract: {key}"


def test_explainability_mentions_the_factors():
    """RN01 and business rule 8: every score comes with the factors that generated it."""
    result = calculate_student_score({
        "weighted_average": 5.4,
        "attendance_percentage": 68.0,
        "weekly_work_hours": 44,
        "expected_classes": 80,
        "absences": 25,
    })
    text = explain_score(result)
    assert "attendance" in text.lower()
    assert str(result["score"]) in text


def test_explainability_of_undetermined():
    result = calculate_student_score({"weighted_average": 5.0})
    text = explain_score(result)
    assert "40%" in text


def test_main_factors_are_at_most_three():
    result = calculate_student_score({
        "weighted_average": 2.0,
        "attendance_percentage": 40.0,
        "weekly_work_hours": 48,
        "failure_rate": 0.9,
        "per_capita_income_mw": 0.2,
        "week_lms_accesses": 0,
        "mental_health_scale": 5,
    })
    assert len(result["main_factors"]) <= 3


def test_main_factors_sorted_by_contribution():
    """The first factor listed is the one that weighed the most in the score."""
    result = calculate_student_score({
        "weighted_average": 2.0,
        "attendance_percentage": 95.0,
        "weekly_work_hours": 0,
        "per_capita_income_mw": 4.0,
        "week_lms_accesses": 10,
    })
    assert result["main_factors"][0] == "grades"
