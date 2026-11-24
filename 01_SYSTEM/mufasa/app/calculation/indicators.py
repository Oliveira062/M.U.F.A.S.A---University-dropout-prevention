def calculate_remaining_absences(expected_classes: int, absences: int):
    if expected_classes is None or expected_classes <= 0 or absences is None:
        return None
    absences_limit = int(expected_classes * 0.25)
    return max(0, absences_limit - int(absences))


def calculate_attendance_percentage(held_classes: int, absences: int):
    if held_classes is None or held_classes <= 0:
        return None
    if absences is None:
        return None
    percentage = (1 - (absences / held_classes)) * 100.0
    return round(max(0.0, min(100.0, percentage)), 2)


def calculate_weighted_average(grades: list[tuple[float, float]]):
    if not grades:
        return None
    weights_sum = sum(weight for _, weight in grades)
    if weights_sum == 0:
        return None
    total_sum = sum(grade * weight for grade, weight in grades)
    return round(total_sum / weights_sum, 3)


def calculate_failure_rate(taken_subjects: int, failures: int):
    if taken_subjects is None or taken_subjects <= 0:
        return None
    if failures is None:
        return None
    return round(failures / taken_subjects, 3)


def calculate_registration_completeness(filled_fields: int, total_fields: int) -> float:
    if total_fields is None or total_fields <= 0:
        return 0.0
    return round(filled_fields / total_fields, 4)
