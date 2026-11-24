"""
Profiles and access scope (SRS Annex E, RN07, RN17).

Two questions, always on the server and always in this order:
1. Can the profile use this resource?         -> auth.require_profiles
2. Can this user see THIS student?            -> check_student_scope

The second is the defense against BOLA/IDOR: changing the student ID in the URL is not
enough to see another student.
"""

from fastapi import Request
from sqlalchemy.engine import Connection

from app.api import audit
from app.api.auth import User
from app.api.queries import STUDENT_OF_TEACHER_CLASSES, COURSE_STUDENT, MORE_RECENT_LEVEL
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

# Profiles that read individual student data. BOARD, ADMIN and DPO
# are left out by definition of Annex E.
INDIVIDUAL_READING = (STUDENT, TEACHER, COORDINATION, SUPPORT_CENTER, FINANCE)

ALERT_LEVELS = ("High", "Critical")

# Score factors by degree of restriction (RN07).
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
        # While the alerts module (Sprint 3) does not exist, "student with an alert"
        # is approximated by: same program and last assessment High or Critical.
        if user.course_id is None:
            return False
        if connection.execute(COURSE_STUDENT, {"student_id": student_id, "course_id": user.course_id}).first() is None:
            return False
        level = connection.execute(MORE_RECENT_LEVEL, {"student_id": student_id}).scalar()
        return level in ALERT_LEVELS

    return False


def check_student_scope(request: Request, connection: Connection, user: User,
                           student_id: str, operation: str) -> None:
    """Blocks and records; the message does not say whether the student exists."""
    if user.profile not in INDIVIDUAL_READING or not _in_scope(connection, user, student_id):
        audit.register(request, operation, "DENIED", user=user, target_student_id=student_id)
        raise http_error(403, DENIED_ACCESS_MSG)
    audit.register(request, operation, "ALLOWED", user=user, target_student_id=student_id)


def visible_factor(profile: str, factor: str) -> bool:
    """Can the profile see the NAME of this factor?"""
    if profile in (STUDENT, SUPPORT_CENTER):
        return True
    if factor in HEALTH_FACTORS:
        return False  # only the student and the support center see the nature of health data
    if profile == TEACHER and factor in SOCIOECONOMIC_FACTORS:
        return False
    return True


def visible_factor_value(profile: str, factor: str) -> bool:
    """Can the profile see the numeric VALUE of this factor's risk?"""
    if profile in (STUDENT, SUPPORT_CENTER):
        return True
    if profile == COORDINATION and factor in SOCIOECONOMIC_FACTORS:
        return False  # coordination sees the qualitative range, not the value
    return visible_factor(profile, factor)


def qualitative_band(risk: float) -> str:
    if risk <= 33:
        return "low"
    if risk <= 66:
        return "average"
    return "high"
