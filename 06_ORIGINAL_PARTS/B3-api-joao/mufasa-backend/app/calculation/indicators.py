"""
Basic MUFASA academic indicators.

Pure functions: numbers go in, numbers come out. None depends on a database
or an API, which lets the whole module be tested without infrastructure.

GENERAL RULE OF THIS MODULE: missing data returns None, never a made-up
neutral value. Filling a gap with an optimistic value turns the
strongest dropout signal into a signal of normality.
"""


def calculate_remaining_absences(expected_classes: int, absences: int) -> int:
    """
    How many absences the student can still accumulate before failing for absences.

    Limit of 25% of the expected classes (LDB art. 47 par. 3: minimum of 75%
    attendance). The floor at zero avoids a negative number when the limit
    has already been exceeded.

    >>> calculate_remaining_absences(80, 12)
    8
    """
    if expected_classes is None or expected_classes <= 0:
        return 0
    absences_limit = int(expected_classes * 0.25)
    return max(0, absences_limit - absences)


def calculate_attendance_percentage(held_classes: int, absences: int):
    """
    Attendance percentage over the classes ALREADY HELD.

    SIGNATURE CHANGED in v2.2: it used to receive (expected_classes, attendances).
    The SRS calculates attendance over classes held, not expected. Using the
    expected ones in the middle of the term makes every student look like they have
    very low attendance, because classes that have not happened yet count as absences.

    Returns None when no class has been recorded. Does NOT return 100.0:
    missing records are not perfect attendance.

    >>> calculate_attendance_percentage(80, 20)
    75.0
    """
    if held_classes is None or held_classes <= 0:
        return None
    if absences is None:
        return None
    percentage = (1 - (absences / held_classes)) * 100.0
    return round(max(0.0, min(100.0, percentage)), 2)


def calculate_weighted_average(grades: list[tuple[float, float]]):
    """
    Average weighted by workload: sum(grade * WL) / sum(WL).

    grades: list of tuples (grade, workload).
    Returns None when there is no grade recorded or the sum of the workloads is zero.

    >>> calculate_weighted_average([(5.0, 2.0), (6.0, 3.0)])
    5.6
    """
    if not grades:
        return None
    weights_sum = sum(weight for _, weight in grades)
    if weights_sum == 0:
        return None
    total_sum = sum(grade * weight for grade, weight in grades)
    return round(total_sum / weights_sum, 3)


def calculate_failure_rate(taken_subjects: int, failures: int):
    """
    Proportion of failures in the history, from 0.0 to 1.0.

    Returns None for a student with no history (first term), instead of
    0.0: never having failed anything and never having taken anything are different
    situations, and treating both the same hides the incoming student.

    >>> calculate_failure_rate(6, 2)
    0.333
    """
    if taken_subjects is None or taken_subjects <= 0:
        return None
    if failures is None:
        return None
    return round(failures / taken_subjects, 3)


def calculate_registration_completeness(filled_fields: int, total_fields: int) -> float:
    """
    Proportion of filled-in fields in the record, from 0.0 to 1.0.

    Useful for the dashboard to show "record 60% complete". The score uses the
    completeness weighted by the weights, calculated inside score.py.
    """
    if total_fields is None or total_fields <= 0:
        return 0.0
    return round(filled_fields / total_fields, 4)
