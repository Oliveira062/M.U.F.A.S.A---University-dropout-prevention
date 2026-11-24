import csv
import io
import math
import re
from dataclasses import dataclass, field

MAXIMUM_SIZE = 20 * 1024 * 1024
MAXIMUM_ROWS = 200_000
STUDENT_PATTERN = re.compile(r"^(?:\d{7}|ALU\d{4})$")
CLASS_PATTERN = re.compile(r"^[A-Za-z0-9_-]{2,40}$")
TERM_PATTERN = re.compile(r"^\d{4}/[12]$")

COLUMNS = {
    "GRADES": ["student_id", "class_id", "exam1", "exam2", "exam3", "final_grade", "attendance_pct", "status"],
    "INDICATORS": ["student_id", "academic_period", "total_absences", "pending_activities",
                   "failed_subjects_history", "previous_semester_average"],
}
STATUSES = {"Approved", "Failed", "Enrolled"}


class InvalidFile(ValueError):
    pass


@dataclass
class Result:
    valid: list = field(default_factory=list)
    errors: list = field(default_factory=list)
    total: int = 0


def _decimal(text: str, minimum: float, maximum: float, required: bool):
    text = (text or "").strip()
    if text == "":
        if required:
            raise ValueError("required field empty")
        return None
    try:
        value = float(text.replace(",", "."))
    except ValueError:
        raise ValueError("not a number")
    if not math.isfinite(value) or value < minimum or value > maximum:
        raise ValueError(f"outside the range {minimum:g} to {maximum:g}")
    return round(value, 2)


def _integer(text: str, minimum: int, maximum: int):
    text = (text or "").strip()
    if text == "":
        return None
    if not re.fullmatch(r"\d{1,6}", text):
        raise ValueError("not a non-negative integer")
    value = int(text)
    if value < minimum or value > maximum:
        raise ValueError(f"outside the range {minimum} to {maximum}")
    return value


def read_csv(content: bytes, kind: str) -> list[dict]:
    if len(content) == 0:
        raise InvalidFile("Empty file.")
    if len(content) > MAXIMUM_SIZE:
        raise InvalidFile("File larger than 20 MB.")
    try:
        text = content.decode("utf-8-sig")
    except UnicodeDecodeError:
        raise InvalidFile("The file must be in UTF-8.")
    sample = text[:4096]
    separator = ";" if sample.count(";") > sample.count(",") else ","
    reader = csv.DictReader(io.StringIO(text, newline=""), delimiter=separator)
    header = [c.strip() for c in (reader.fieldnames or [])]
    if header != COLUMNS[kind]:
        raise InvalidFile("Header different from the template. Expected: " + separator.join(COLUMNS[kind]))
    reader.fieldnames = header
    rows = []
    for row in reader:
        if len(rows) >= MAXIMUM_ROWS:
            raise InvalidFile(f"More than {MAXIMUM_ROWS} rows.")
        if None in row:
            row["__leftover__"] = True
        rows.append(row)
    if not rows:
        raise InvalidFile("The file has no data rows.")
    return rows


def validate(rows: list[dict], kind: str, students: set, enrollments: dict) -> Result:
    r = Result(total=len(rows))
    seen = {}
    for index, raw in enumerate(rows, start=2):
        errors = []

        def field(name, converter):
            try:
                return converter(raw.get(name))
            except ValueError as exc:
                errors.append({"field": name, "value": str(raw.get(name) or "")[:60], "reason": str(exc)})
                return None

        if raw.get("__leftover__"):
            errors.append({"field": "-", "value": "", "reason": "row with more columns than the header"})
        student = (raw.get("student_id") or "").strip()
        if not STUDENT_PATTERN.fullmatch(student):
            errors.append({"field": "student_id", "value": student[:60], "reason": "student ID in invalid format"})
        elif student not in students:
            errors.append({"field": "student_id", "value": student, "reason": "student not registered"})

        if kind == "GRADES":
            class_value = (raw.get("class_id") or "").strip()
            enrollment_id = None
            if not CLASS_PATTERN.fullmatch(class_value):
                errors.append({"field": "class_id", "value": class_value[:60], "reason": "class in invalid format"})
            else:
                enrollment_id = enrollments.get((student, class_value))
                if enrollment_id is None and student in students:
                    errors.append({"field": "class_id", "value": class_value, "reason": "student not enrolled in this class"})
            key = (student, class_value)
            data = {
                "exam1": field("exam1", lambda v: _decimal(v, 0, 10, False)),
                "exam2": field("exam2", lambda v: _decimal(v, 0, 10, False)),
                "exam3": field("exam3", lambda v: _decimal(v, 0, 10, False)),
                "final_grade": field("final_grade", lambda v: _decimal(v, 0, 10, True)),
                "attendance_pct": field("attendance_pct", lambda v: _decimal(v, 0, 100, True)),
                "status": (raw.get("status") or "").strip() or None,
                "enrollment_id": enrollment_id,
            }
            if data["status"] not in STATUSES:
                errors.append({"field": "status", "value": str(data["status"] or "")[:60],
                               "reason": "use Approved, Failed or Enrolled"})
        else:
            period = (raw.get("academic_period") or "").strip()
            if not TERM_PATTERN.fullmatch(period):
                errors.append({"field": "academic_period", "value": period[:60], "reason": "use the format YYYY/1 or YYYY/2"})
            key = (student, period)
            data = {
                "student_id": student, "academic_period": period,
                "total_absences": field("total_absences", lambda v: _integer(v, 0, 10_000)),
                "pending_activities": field("pending_activities", lambda v: _integer(v, 0, 1_000)),
                "failed_subjects_history": field("failed_subjects_history",
                                                 lambda v: _integer(v, 0, 100)),
                "previous_semester_average": field("previous_semester_average", lambda v: _decimal(v, 0, 10, False)),
            }

        if key in seen:
            errors.append({"field": "student_id", "value": student, "reason": f"duplicate of row {seen[key]}"})
        else:
            seen[key] = index

        if errors:
            r.errors.extend((index, e) for e in errors)
        else:
            r.valid.append((index, data))
    return r
