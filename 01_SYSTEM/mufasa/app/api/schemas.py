from datetime import date, datetime
from enum import Enum
from typing import Annotated

from fastapi import Path, Query
from pydantic import BaseModel, ConfigDict, Field, field_validator

ENROLLMENT_PATTERN = r"^(?:\d{7}|ALU\d{4})$"

Enrollment = Annotated[str, Path(pattern=ENROLLMENT_PATTERN, description="Student ID (7 digits)")]


class Closed(BaseModel):
    model_config = ConfigDict(extra="forbid", str_strip_whitespace=True)


class Profile(str, Enum):
    STUDENT = "STUDENT"
    TEACHER = "TEACHER"
    COORDINATION = "COORDINATION"
    SUPPORT_CENTER = "SUPPORT_CENTER"
    FINANCE = "FINANCE"
    BOARD = "BOARD"
    ADMIN = "ADMIN"
    DPO = "DPO"


class LoginRequest(Closed):
    login: str = Field(min_length=3, max_length=64, pattern=r"^[A-Za-z0-9._@-]+$",
                       description="Student ID, for students; institutional login, for the other profiles")
    password: str = Field(min_length=1, max_length=72)
    profile: Profile = Field(description="Profile chosen on the login screen; it must be the account's profile")

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
    must_change_password: bool = False
    pending_term: bool = False


class Order(str, Enum):
    name = "name"
    semester = "semester"
    enrollment = "enrollment"
    risk = "risk"


class Level(str, Enum):
    LOW = "LOW"
    MODERATE = "MODERATE"
    HIGH = "HIGH"
    CRITICAL = "CRITICAL"
    UNDETERMINED = "UNDETERMINED"


class ListFilters(Closed):
    semester: int | None = Field(default=None, ge=1, le=12)
    level: Level | None = None
    search: str | None = Field(default=None, max_length=60)
    order: Order = Order.name
    limit: int = Field(default=25, ge=1, le=200)
    page: int = Field(default=1, ge=1, le=10_000)


def list_filters(
    semester: Annotated[int | None, Query(ge=1, le=12)] = None,
    level: Level | None = None,
    search: Annotated[str | None, Query(max_length=60, pattern=r"^[\w .'-]*$")] = None,
    order: Order = Order.name,
    limit: Annotated[int, Query(ge=1, le=200)] = 25,
    page: Annotated[int, Query(ge=1, le=10_000)] = 1,
) -> ListFilters:
    return ListFilters(semester=semester, level=level, search=search, order=order, limit=limit, page=page)


class StudentSummary(BaseModel):
    enrollment: str
    name: str
    semester: int | None
    risk_level: str | None
    score: int | None = None


class StudentsPage(BaseModel):
    page: int
    limit: int
    total: int | None = None
    items: list[StudentSummary]


METHODOLOGICAL_NOTICE = (
    "The risk level shows that this student's pattern of indicators resembles patterns that "
    "tend to come before dropout. It is not a prediction about the person, not a judgment of effort or "
    "ability, and it cannot be used in any assessment, selection or benefit decision."
)


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


class Purpose(str, Enum):
    HEALTH_DATA = "HEALTH_DATA"


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
    ACCESS_CONFIRMATION = "ACCESS_CONFIRMATION"
    CORRECTION = "CORRECTION"
    ELIMINATION_ANONYMIZATION = "ELIMINATION_ANONYMIZATION"
    PORTABILITY = "PORTABILITY"
    SHARING_INFORMATION = "SHARING_INFORMATION"
    CONSENT_REVOCATION = "CONSENT_REVOCATION"
    AUTOMATED_DECISION_REVIEW = "AUTOMATED_DECISION_REVIEW"
    OBJECTION = "OBJECTION"


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


class AuditResult(str, Enum):
    ALLOWED = "ALLOWED"
    DENIED = "DENIED"
    BLOCKED = "BLOCKED"


class AuditFilter(Closed):
    enrollment: str | None = Field(default=None, pattern=ENROLLMENT_PATTERN)
    profile: Profile | None = None
    result: AuditResult | None = None
    operation: str | None = Field(default=None, pattern=r"^[A-Z_]{3,40}$")
    de: datetime | None = None
    until: datetime | None = None
    limit: int = Field(default=50, ge=1, le=500)
    page: int = Field(default=1, ge=1, le=10_000)


def audit_filter(
    enrollment: Annotated[str | None, Query(pattern=ENROLLMENT_PATTERN)] = None,
    profile: Profile | None = None,
    result: AuditResult | None = None,
    operation: Annotated[str | None, Query(pattern=r"^[A-Z_]{3,40}$")] = None,
    de: datetime | None = None,
    until: datetime | None = None,
    limit: Annotated[int, Query(ge=1, le=500)] = 50,
    page: Annotated[int, Query(ge=1, le=10_000)] = 1,
) -> AuditFilter:
    return AuditFilter(enrollment=enrollment, profile=profile, result=result, operation=operation,
                       de=de, until=until, limit=limit, page=page)


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
