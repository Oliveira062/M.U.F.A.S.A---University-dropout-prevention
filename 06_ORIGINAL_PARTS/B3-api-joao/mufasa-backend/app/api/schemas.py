"""
Input and output contracts (Pydantic).

Every input has a closed type, size and format, and unknown fields
are refused (extra="forbid"): FastAPI rejects with 422 before the data
gets near the database (SRS RN08, RN11).
"""

from datetime import date, datetime
from enum import Enum
from typing import Annotated

from fastapi import Path, Query
from pydantic import BaseModel, ConfigDict, Field, field_validator

# SRS RN12: the student ID is text with exactly 7 digits. The simulated database of
# B1 uses the ALU0000 format; the second alternative goes away when B1 migrates
# for the official student ID.
ENROLLMENT_PATTERN = r"^(?:\d{7}|ALU\d{4})$"

Enrollment = Annotated[str, Path(pattern=ENROLLMENT_PATTERN, description="Student ID (7 digits)")]


class Closed(BaseModel):
    model_config = ConfigDict(extra="forbid", str_strip_whitespace=True)


# ---------------------------------------------------------------------------
# Authentication
# ---------------------------------------------------------------------------

class LoginRequest(Closed):
    login: str = Field(min_length=3, max_length=64, pattern=r"^[A-Za-z0-9._@-]+$",
                       description="Student ID, for students; institutional login, for the other profiles")
    password: str = Field(min_length=1, max_length=72)

    @field_validator("password")
    @classmethod
    def _bcrypt_limit(cls, v: str) -> str:
        if len(v.encode("utf-8")) > 72:
            raise ValueError("password longer than the 72-byte limit")
        return v


class TokenAnswer(BaseModel):
    access_token: str
    token_type: str = "bearer"
    expires_in_seconds: int
    profile: str


# ---------------------------------------------------------------------------
# Students and score
# ---------------------------------------------------------------------------

class Order(str, Enum):
    name = "name"
    semester = "semester"
    enrollment = "enrollment"


class ListFilters(Closed):
    semester: int | None = Field(default=None, ge=1, le=12)
    order: Order = Order.name
    limit: int = Field(default=25, ge=1, le=200)
    page: int = Field(default=1, ge=1, le=10_000)


def list_filters(
    semester: Annotated[int | None, Query(ge=1, le=12)] = None,
    order: Order = Order.name,
    limit: Annotated[int, Query(ge=1, le=200)] = 25,
    page: Annotated[int, Query(ge=1, le=10_000)] = 1,
) -> ListFilters:
    return ListFilters(semester=semester, order=order, limit=limit, page=page)


class StudentSummary(BaseModel):
    enrollment: str
    name: str
    semester: int | None
    risk_level: str | None


class StudentsPage(BaseModel):
    page: int
    limit: int
    items: list[StudentSummary]


class ScoreFactor(BaseModel):
    factor: str
    risk: float | None = Field(description="0 = no risk, 100 = maximum risk; empty when the profile sees only the range")
    band: str | None = None


METHODOLOGICAL_NOTICE = (
    "The risk level shows that this student's pattern of indicators resembles patterns that "
    "tend to come before dropout. It is not a prediction about the person, not a judgment of effort or "
    "ability, and it cannot be used in any assessment, selection or benefit decision."
)


class ScoreAnswer(BaseModel):
    enrollment: str
    score: int | None
    level: str
    completeness: float
    main_factors: list[str]
    breakdown: list[ScoreFactor]
    remaining_absences: int | None
    attendance_overlap: bool
    recommendation: str
    explanation: str
    notice: str = METHODOLOGICAL_NOTICE
    missing_data: list[str] = Field(description="Factors without data in the database; they do not enter the calculation")


class HistoricalAssessment(BaseModel):
    academic_period: str | None
    kind: str | None
    assessment_date: str | None
    dropout_risk_pct: float | None
    risk_level: str | None


class AggregateGroup(BaseModel):
    semester: int | None
    risk_level: str | None
    total: int


class AggregatesAnswer(BaseModel):
    minimum_by_group: int
    groups: list[AggregateGroup]
    note: str = "Groups with fewer students than the minimum were suppressed to prevent re-identification."


# ---------------------------------------------------------------------------
# LGPD: consent and data subject rights
# ---------------------------------------------------------------------------

class Purpose(str, Enum):
    HEALTH_DATA = "HEALTH_DATA"  # art. 11, I: specific and highlighted consent


class ConsentRequest(Closed):
    purpose: Purpose
    granted: bool
    term_version: str = Field(pattern=r"^\d+\.\d+$", max_length=10)


class Consent(BaseModel):
    purpose: str
    granted: bool
    granted_by: str
    term_version: str
    registered_at: datetime | str


class RequestType(str, Enum):
    ACCESS_CONFIRMATION = "ACCESS_CONFIRMATION"      # art. 18, I and II
    CORRECTION = "CORRECTION"                          # art. 18, III
    ELIMINATION_ANONYMIZATION = "ELIMINATION_ANONYMIZATION"  # art. 18, IV and VI
    PORTABILITY = "PORTABILITY"                # art. 18, V
    SHARING_INFORMATION = "SHARING_INFORMATION"  # art. 18, VII
    CONSENT_REVOCATION = "CONSENT_REVOCATION"  # art. 18, IX
    AUTOMATED_DECISION_REVIEW = "AUTOMATED_DECISION_REVIEW"  # art. 20
    OBJECTION = "OBJECTION"                          # art. 18, par. 2


class RequestRequest(Closed):
    kind: RequestType
    description: str = Field(default="", max_length=1000)


class RegisteredRequest(BaseModel):
    registered_protocol: bool = True
    deadline: str = "Answer within 15 days (LGPD, art. 19, II)."


class SubjectRequest(BaseModel):
    subject_request_id: int
    student_id: str
    kind: str
    status: str
    registered_at: datetime | str


class AuditRecord(BaseModel):
    moment: datetime | str
    request_id: str | None
    user_id: int | None
    profile: str | None
    operation: str
    resource: str
    target_student_id: str | None
    result: str


class PageFilter(Closed):
    limit: int = Field(default=25, ge=1, le=200)
    page: int = Field(default=1, ge=1, le=10_000)


def page_filter(
    limit: Annotated[int, Query(ge=1, le=200)] = 25,
    page: Annotated[int, Query(ge=1, le=10_000)] = 1,
) -> PageFilter:
    return PageFilter(limit=limit, page=page)


def convert_date(value) -> str | None:
    if value is None:
        return None
    if isinstance(value, (date, datetime)):
        return value.isoformat()
    return str(value)
