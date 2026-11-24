# Backend B2 — Calculation and Score Module (v2.2)

MUFASA dropout risk calculation module. Pure functions: it does not access a database
or expose endpoints, which lets everything be tested without infrastructure.

## Scale

**0 = safe student · 100 = maximum dropout risk.**

The score measures RISK, not performance. A student with grade 10 and 100% attendance
has risk close to zero. This inversion was the bug fixed in v2.2 —
see CHANGELOG.md.

## Structure

    app/calculation/indicators.py   Weighted average, attendance, remaining absences, failure rate
    app/calculation/score.py        The 11 factors, weights, ranges, completeness, overlap, explainability
    tests/test_calculation.py       41 tests

## How to run the tests

    pip install pytest
    pytest -v

## Usage

    from app.calculation.score import calculate_student_score, explain_score

    result = calculate_student_score({
        "enrollment": "2024001",
        "weighted_average": 5.4,
        "attendance_percentage": 68.0,
        "expected_classes": 80,
        "absences": 25,
        "weekly_work_hours": 44,
        "failure_rate": 0.33,
    })
    # {"score": 63, "level": "HIGH", ...}

    print(explain_score(result))

## Weights of the 11 factors (SRS v1.1)

| Factor | Weight |
|---|---|
| Grades | 20% |
| Attendance | 18% |
| Financial situation | 11% |
| Failure rate | 9% |
| VLE engagement | 8% |
| Mental health | 8% |
| Work | 7% |
| Commute | 5% |
| Physical health | 5% |
| Housing | 5% |
| Dependents | 4% |

## Ranges

| Score | Level | Action deadline |
|---|---|---|
| 0-25 | LOW | Periodic monitoring |
| 26-50 | MODERATE | Preventive attention |
| 51-75 | HIGH | Contact within 5 working days |
| 76-100 | CRITICAL | Active outreach within 48 hours |
| — | UNDETERMINED | Completeness below 40% |

## Notes for the other fronts

**B1:** `calculate_attendance_percentage` changed its signature in v2.2. It now receives
`(held_classes, absences)`, not `(expected_classes, attendances)`. Missing attendance
must arrive as `None`, never as 100.

**B1:** mental health and physical health are sensitive data (LGPD art. 11) — separate,
encrypted table, with specific consent.

**B3:** the return gained the keys `completeness`, `breakdown` and
`attendance_overlap`. The six keys of Contract 2 stay the same.

## Parameters to confirm in the bylaws

- The minimum passing grade (`MINIMUM_PASSING_GRADE = 6.0`) has no legal basis in
  higher education: it comes from university autonomy. Confirm with the coordination.
- The minimum attendance of 75% comes from LDB art. 47 §3.
