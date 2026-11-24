from fastapi import Request
from sqlalchemy.engine import Connection

from app.api import audit
from app.api.auth import User
import json

from app.api.queries import STUDENT_OPEN_ALERT, STUDENT_OF_TEACHER_CLASSES, COURSE_STUDENT
from app.api.errors import DENIED_ACCESS_MSG, http_error

STUDENT = "STUDENT"
TEACHER = "TEACHER"
COORDINATION = "COORDINATION"
SUPPORT_CENTER = "SUPPORT_CENTER"
FINANCE = "FINANCE"
BOARD = "BOARD"
ADMIN = "ADMIN"
DPO = "DPO"

PROFILES = (STUDENT, TEACHER, COORDINATION, SUPPORT_CENTER, FINANCE, BOARD, ADMIN, DPO)

INDIVIDUAL_READING = (STUDENT, TEACHER, COORDINATION, SUPPORT_CENTER, FINANCE)

ALERT_LEVELS = ("HIGH", "CRITICAL")

SOCIOECONOMIC_FACTORS = {"finance", "work", "commute", "housing", "dependents"}
HEALTH_FACTORS = {"mental_health", "physical_health"}
REFERRED_LABEL = "factor referred to the support center"


def _in_scope(connection: Connection, user: User, student_id: str) -> bool:
    if user.profile == STUDENT:
        return user.student_id is not None and user.student_id == student_id

    if user.profile == TEACHER:
        return user.id_professor is not None and connection.execute(
            STUDENT_OF_TEACHER_CLASSES, {"student_id": student_id, "id_professor": user.id_professor}
        ).first() is not None

    if user.profile == COORDINATION:
        return user.course_id is not None and connection.execute(
            COURSE_STUDENT, {"student_id": student_id, "course_id": user.course_id}
        ).first() is not None

    if user.profile in (SUPPORT_CENTER, FINANCE):
        alert = connection.execute(STUDENT_OPEN_ALERT, {"student_id": student_id}).mappings().first()
        if alert is None:
            return False
        if user.profile == SUPPORT_CENTER:
            return alert["owner_id"] == user.user_id
        return "finance" in row_factors(alert["main_factors"])

    return False


def row_factors(value) -> list[str]:
    if not value:
        return []
    return json.loads(value) if isinstance(value, str) else list(value)


def check_student_scope(request: Request, connection: Connection, user: User,
                        student_id: str, operation: str) -> None:
    if user.profile not in INDIVIDUAL_READING or not _in_scope(connection, user, student_id):
        audit.register(request, operation, "DENIED", user=user, target_student_id=student_id)
        raise http_error(403, DENIED_ACCESS_MSG)
    audit.register(request, operation, "ALLOWED", user=user, target_student_id=student_id)


def visible_factor(profile: str, factor: str) -> bool:
    if profile in (STUDENT, SUPPORT_CENTER):
        return True
    if factor in HEALTH_FACTORS:
        return False
    if profile == TEACHER and factor in SOCIOECONOMIC_FACTORS:
        return False
    return True


def visible_factor_value(profile: str, factor: str) -> bool:
    if profile in (STUDENT, SUPPORT_CENTER):
        return True
    if profile == COORDINATION and factor in SOCIOECONOMIC_FACTORS:
        return False
    return visible_factor(profile, factor)


def qualitative_band(risk: float) -> str:
    if risk <= 33:
        return "low"
    if risk <= 66:
        return "average"
    return "high"
