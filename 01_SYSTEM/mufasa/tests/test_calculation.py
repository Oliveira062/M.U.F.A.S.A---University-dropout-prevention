import pytest

from app.calculation.indicators import (
    calculate_remaining_absences,
    calculate_weighted_average,
    calculate_attendance_percentage,
    calculate_failure_rate,
)
from app.calculation.parameters import CATALOG, DEFAULT, WEIGHTS_BY_FACTOR, consistency_problems
from app.calculation.score import (
    round_off,
    calculate_student_score,
    calculate_trend,
    classify_risk_level,
    explain_score,
    risk_by_category,
    risk_by_dependents,
    risk_by_commute,
    risk_by_lms_engagement,
    risk_by_attendance,
    risk_by_grade,
    risk_by_per_capita_income,
    risk_by_failure,
    risk_by_work,
    PHYSICAL_HEALTH,
    MENTAL_HEALTH,
    HOUSING,
)


def test_remaining_absences():
    assert calculate_remaining_absences(80, 12) == 8
    assert calculate_remaining_absences(80, 25) == 0
    assert calculate_remaining_absences(80, 10) == 10
    assert calculate_remaining_absences(40, 0) == 10


def test_remaining_absences_never_negative():
    assert calculate_remaining_absences(80, 50) == 0


def test_attendance():
    assert calculate_attendance_percentage(80, 20) == 75.0
    assert calculate_attendance_percentage(80, 0) == 100.0
    assert calculate_attendance_percentage(50, 16) == 68.0


def test_attendance_without_recorded_class_returns_none():
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
    assert calculate_failure_rate(0, 0) is None
    assert calculate_failure_rate(None, 0) is None


def test_bands_at_exact_limits_ca09():
    assert [classify_risk_level(s) for s in (0, 25, 26, 50, 51, 75, 76, 100)] == [
        "LOW", "LOW", "MODERATE", "MODERATE", "HIGH", "HIGH", "CRITICAL", "CRITICAL"]


def test_empty_score_is_undetermined():
    assert classify_risk_level(None) == "UNDETERMINED"


def test_internal_value_063_becomes_63_high():
    assert round_off(0.63 * 100) == 63
    assert classify_risk_level(63) == "HIGH"
    assert round_off(62.5) == 63


@pytest.mark.parametrize("average,expected", [(7.0, 20.0), (5.0, 60.0), (3.0, 85.0), (8.0, 0.0), (10.0, 0.0),
                                            (6.0, 40.0), (4.0, 80.0), (0.0, 100.0)])
def test_ct02_to_ct04_i1(average, expected):
    assert risk_by_grade(average) == pytest.approx(expected, abs=0.01)


def test_rf02_average_weighted_by_workload():
    average = calculate_weighted_average([(7.0, 60), (5.0, 30)])
    assert average == pytest.approx(6.333, abs=0.001)
    assert risk_by_grade(average) == pytest.approx(33.3, abs=0.1)


@pytest.mark.parametrize("att,expected", [(82.0, 21.3), (68.0, 58.7), (90.0, 0.0), (75.0, 40.0),
                                           (60.0, 80.0), (50.0, 83.3), (0.0, 100.0)])
def test_ct05_ct06_i2(att, expected):
    assert risk_by_attendance(att) == pytest.approx(expected, abs=0.1)


def test_ct06_attendance_68_forces_high_by_s1():
    r = calculate_student_score({"weighted_average": 9.0, "attendance_percentage": 68.0, "failure_rate_pct": 0,
                              "per_capita_income_mw": 3.0, "weekly_work_hours": 0, "commute_minutes": 10})
    assert r["score"] < 51
    assert r["level"] == "HIGH"
    assert r["origin_level"] == "OVERLAP"
    assert r["overlap_reason"].startswith("S1: attendance of 68%")


def test_s1_applies_to_any_subject_ca11():
    r = calculate_student_score({"weighted_average": 9.0, "attendance_percentage": 88.0, "failure_rate_pct": 0,
                              "per_capita_income_mw": 3.0, "weekly_work_hours": 0, "commute_minutes": 10,
                              "subjects": [{"name": "Calculus I", "attendance_pct": 70},
                                              {"name": "Algorithms", "attendance_pct": 100}]})
    assert r["level"] == "HIGH"
    assert "Calculus I" in r["overlap_reason"]


def test_s1_does_not_apply_with_closed_period():
    r = calculate_student_score({"weighted_average": 9.0, "attendance_percentage": 70.0, "failure_rate_pct": 0,
                              "per_capita_income_mw": 3.0, "weekly_work_hours": 0, "commute_minutes": 10,
                              "period_in_progress": False})
    assert r["origin_level"] == "BAND"


@pytest.mark.parametrize("tr,expected", [(0, 0), (10, 25), (15, 25), (20, 50), (30, 50), (40, 75), (50, 75),
                                         (51, 100)])
def test_i3_steps(tr, expected):
    assert risk_by_failure(tr) == expected


def test_ct07_i3_with_prerequisite():
    assert risk_by_failure(35.0, failed_prerequisite=True) == 90.0
    assert risk_by_failure(60.0, failed_prerequisite=True, third_attempt=True) == 100.0


def test_i3_without_taken_subjects_is_missing():
    assert calculate_failure_rate(0, 0) is None
    assert risk_by_failure(None) is None


def test_ct08_ct09_i5():
    assert risk_by_per_capita_income(0.40) == 85.0
    assert risk_by_per_capita_income(0.40, active_aid=True) == 65.0


@pytest.mark.parametrize("income,expected", [(0.25, 100), (0.3, 85), (0.5, 85), (0.7, 60), (1.0, 30), (1.5, 30),
                                            (1.6, 0)])
def test_i5_steps(income, expected):
    assert risk_by_per_capita_income(income) == expected


def test_i5_delays_and_cadunico():
    assert risk_by_per_capita_income(1.2, late_tuition=1) == 50.0
    assert risk_by_per_capita_income(1.2, late_tuition=2) == 65.0
    assert risk_by_per_capita_income(None, cadunico_without_income=True) == 85.0
    assert risk_by_per_capita_income(None) is None


def test_ct10_ct11_i6():
    assert risk_by_work(15, same_shift=True) == 100.0
    assert risk_by_work(20, internship_in_area=True) == 5.0


@pytest.mark.parametrize("hours,expected", [(0, 0), (1, 20), (20, 20), (21, 50), (30, 50), (31, 75), (40, 75),
                                            (44, 100)])
def test_i6_steps(hours, expected):
    assert risk_by_work(hours) == expected


def test_i6_informal():
    assert risk_by_work(25, informal=True) == 60.0


@pytest.mark.parametrize("minutes,expected", [(20, 0), (21, 25), (40, 25), (41, 50), (60, 50), (61, 75), (90, 75),
                                              (91, 100)])
def test_i7_steps(minutes, expected):
    assert risk_by_commute(minutes) == expected


def test_i7_two_buses():
    assert risk_by_commute(50, two_or_more_buses=True) == 65.0


def test_ct12_i8_with_followup():
    assert risk_by_category(MENTAL_HEALTH, "WITH_FOLLOWUP") == 40.0
    assert risk_by_category(MENTAL_HEALTH, None) is None


def test_i9_i10_i11():
    assert [PHYSICAL_HEALTH[k] for k in ("NONE", "CONTROLLED", "CERTIFICATES", "LEAVE")] == [0, 30, 70, 90]
    assert [HOUSING[k] for k in ("STABLE", "COMMITTED_RENT", "CHANGED_WITHOUT_NETWORK", "CHANGE_IN_PERIOD",
                                 "PRECARIOUS")] == [0, 35, 55, 60, 100]
    assert [risk_by_dependents(n) for n in (0, 1, 2, 5)] == [0, 40, 70, 70]
    assert risk_by_dependents(1, continuous_care=True) == 100


def test_i4_engagement():
    assert risk_by_lms_engagement() is None
    assert risk_by_lms_engagement(0.8, 0.95) == 0
    assert risk_by_lms_engagement(0.5, 0.95) == 35
    assert risk_by_lms_engagement(0.2, 0.95) == 65
    assert risk_by_lms_engagement(0.8, 0.95, days_without_access=22) == 100
    assert risk_by_lms_engagement(0.8, 0.30) == 100


@pytest.mark.parametrize("function", [risk_by_grade, risk_by_attendance, risk_by_per_capita_income,
                                    risk_by_work, risk_by_commute])
def test_invalid_value_becomes_missing(function):
    for invalid in (float("nan"), float("inf"), -1, "abc", True):
        assert function(invalid) is None


def test_monotonicity():
    grades = [risk_by_grade(m / 10) for m in range(0, 101)]
    assert all(a >= b for a, b in zip(grades, grades[1:]))
    atts = [risk_by_attendance(f) for f in range(0, 101)]
    assert all(a >= b for a, b in zip(atts, atts[1:]))


def test_srs_weights_add_up_to_one():
    expected = {"grades": .20, "attendance": .18, "failure": .09, "lms_engagement": .08, "finance": .11,
                 "work": .07, "commute": .05, "mental_health": .08, "physical_health": .05,
                 "housing": .05, "dependents": .04}
    assert {f: DEFAULT.weight(f) for f in WEIGHTS_BY_FACTOR} == pytest.approx(expected)
    assert consistency_problems(DEFAULT.values) == []


def test_ct01_student_without_risk():
    r = calculate_student_score({"weighted_average": 9.0, "attendance_percentage": 95.0, "failure_rate_pct": 0})
    assert (r["score"], r["level"]) == (0, "LOW")


def test_ct13_only_i1_and_i2_is_undetermined():
    r = calculate_student_score({"weighted_average": 7.0, "attendance_percentage": 80.0})
    assert round(r["completeness"] * 100) == 38
    assert r["level"] == "UNDETERMINED"
    assert r["score"] is None


def test_ct14_partial_only_reaches_critical_by_overlap():
    data = {"weighted_average": 2.0, "attendance_percentage": 76.0, "failure_rate_pct": 60,
             "per_capita_income_mw": 0.2, "current_period": 1}
    r = calculate_student_score(data)
    assert round(r["completeness"] * 100) == 58
    assert r["partial"] is True
    assert r["score"] > 75
    assert (r["level"], r["origin_level"]) == ("HIGH", "PARTIAL_BAND")
    r = calculate_student_score({**data, "enrollment_lock_requested": True})
    assert (r["level"], r["origin_level"]) == ("CRITICAL", "OVERLAP")


def test_ct15_fifteen_days_without_presence_is_critical():
    r = calculate_student_score({"weighted_average": 9.0, "attendance_percentage": 95.0, "failure_rate_pct": 0,
                              "per_capita_income_mw": 3, "days_without_presence": 15})
    assert r["level"] == "CRITICAL"
    assert r["overlap_reason"].startswith("S2")


def test_ct16_sorted_factors_and_sum_of_contributions():
    r = calculate_student_score({"weighted_average": 5.4, "attendance_percentage": 80.0, "weekly_work_hours": 44,
                              "per_capita_income_mw": 0.8, "failure_rate_pct": 20, "commute_minutes": 70})
    points = [f["points_contribution"] for f in r["factors"]]
    assert points == sorted(points, reverse=True)
    assert sum(points) == pytest.approx(r["score"], abs=0.5)
    assert sum(f["contribution_pct"] for f in r["factors"]) == pytest.approx(100, abs=0.5)


def test_rn04_main_has_three_largest_and_all_above_50():
    r = calculate_student_score({"weighted_average": 3.0, "attendance_percentage": 50.0, "weekly_work_hours": 44,
                              "per_capita_income_mw": 0.2, "failure_rate_pct": 60, "commute_minutes": 100})
    above_50 = {f["factor"] for f in r["factors"] if f["points"] >= 50}
    assert set(r["main_factors"]) >= above_50
    assert len(r["main_factors"]) >= 3


def test_rn04_every_explanation_has_number():
    r = calculate_student_score({"weighted_average": 5.4, "attendance_percentage": 68.0, "weekly_work_hours": 44,
                              "per_capita_income_mw": 0.8, "failure_rate_pct": 20, "commute_minutes": 70})
    for factor in r["factors"]:
        assert any(ch.isdigit() for ch in factor["explanation"]), factor
    assert "68%" in next(f["explanation"] for f in r["factors"] if f["factor"] == "attendance")
    assert "5.4" in next(f["explanation"] for f in r["factors"] if f["factor"] == "grades")


def test_ct17_minimum_grade_7_generates_score_with_new_version():
    data = {"weighted_average": 6.5, "attendance_percentage": 95.0, "failure_rate_pct": 0}
    before = calculate_student_score(data)
    new = DEFAULT.with_values(MINIMUM_GRADE=7.0)
    new = type(new)(new.values, version=2)
    after = calculate_student_score(data, new)
    assert after["score"] > before["score"]
    assert (before["parameters_version"], after["parameters_version"]) == ("srs-default-param-1.1", "param-v2")


def test_missing_factor_does_not_become_average_value_rn20():
    with_values = calculate_student_score({"weighted_average": 5.0, "attendance_percentage": 80.0, "failure_rate_pct": 20,
                                "per_capita_income_mw": 2.0})
    without = calculate_student_score({"weighted_average": 5.0, "attendance_percentage": 80.0, "failure_rate_pct": 20})
    assert "finance" not in without["breakdown"]
    assert without["completeness"] == pytest.approx(with_values["completeness"] - 0.11)


def test_modifiers_m1_m2_m3():
    base = {"weighted_average": 5.0, "attendance_percentage": 80.0, "failure_rate_pct": 20,
            "per_capita_income_mw": 0.7, "commute_minutes": 80, "weekly_work_hours": 0}
    without = calculate_student_score(base)
    with_values = calculate_student_score({**base, "average_variation": -1.5, "current_period": 1, "evening_shift": True})
    assert [m["id"] for m in with_values["modifiers"]] == ["M1", "M2", "M3"]
    assert with_values["score"] == min(100, without["score"] + 25)


def test_modifiers_m4_m5_need_three_periods():
    base = {"weighted_average": 6.5, "attendance_percentage": 90.0, "failure_rate_pct": 0}
    assert calculate_student_score({**base, "periods_last_averages": [8, 7]})["modifiers"] == []
    drop = calculate_student_score({**base, "periods_last_averages": [8, 7, 6.5]})
    assert [m["id"] for m in drop["modifiers"]] == ["M4"]
    improvement = calculate_student_score({**base, "periods_last_averages": [5, 6, 6.5]})
    assert [m["id"] for m in improvement["modifiers"]] == ["M5"]


def test_score_always_between_0_and_100():
    worst = calculate_student_score({"weighted_average": 0, "attendance_percentage": 0, "failure_rate_pct": 100,
                                 "per_capita_income_mw": 0.1, "commute_minutes": 200, "weekly_work_hours": 60,
                                 "average_variation": -5, "current_period": 1, "evening_shift": True})
    assert worst["score"] == 100
    best = calculate_student_score({"weighted_average": 10, "attendance_percentage": 100, "failure_rate_pct": 0,
                                   "periods_last_averages": [7, 8, 9]})
    assert best["score"] == 0


def test_trend_rn09():
    assert calculate_trend([32, 47, 63]) == "SUSTAINED_DECLINE"
    assert calculate_trend([47, 63]) == "DECLINE"
    assert calculate_trend([63, 47]) == "IMPROVEMENT"
    assert calculate_trend([47, 47]) == "STABLE"
    assert calculate_trend([47]) is None


def test_summary_explanation():
    r = calculate_student_score({"weighted_average": 9.0, "attendance_percentage": 68.0, "failure_rate_pct": 0,
                              "per_capita_income_mw": 3.0})
    text = explain_score(r)
    assert text.startswith(f"Risk score: {r['score']} out of 100")
    assert "overlap" in text
    assert "Could not" in explain_score(calculate_student_score({"weighted_average": 7}))


def test_no_threshold_outside_parameters():
    for key in ("MINIMUM_GRADE", "COMFORTABLE_GRADE", "CRITICAL_GRADE", "MINIMUM_ATTENDANCE", "COMFORTABLE_ATTENDANCE",
                  "CRITICAL_ATTENDANCE", "INCOME_VULNERABLE", "INCOME_AID", "WORK_HOURS_LIMIT", "COMMUTE_LIMIT",
                  "LMS_DAYS_WITHOUT_ACCESS", "LOW_CUTOFF", "MODERATE_CUTOFF", "HIGH_CUTOFF", "MINIMUM_COMPLETENESS",
                  "SERVICE_INTERVAL", "OWNER_ALERT_CEILING"):
        assert key in CATALOG


def test_inconsistent_parameters_are_refused():
    assert consistency_problems({**DEFAULT.values, "MINIMUM_GRADE": 9.0})
    assert consistency_problems({**DEFAULT.values, "WEIGHT_I1_PERFORMANCE": 0.3})
