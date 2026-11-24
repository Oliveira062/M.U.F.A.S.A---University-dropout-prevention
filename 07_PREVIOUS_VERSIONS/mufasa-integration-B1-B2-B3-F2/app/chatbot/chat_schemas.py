"""Chatbot contracts. Same pattern as B3: closed fields (extra="forbid")."""

from datetime import datetime
from typing import Annotated, Any

from fastapi import Query
from pydantic import BaseModel, Field

from app.api.schemas import Closed


class ChatRequest(Closed):
    # Only the text. Who is asking and the profile come from the token, never from the body:
    # a body with user_id or profile is refused with 422.
    text: str = Field(min_length=1, max_length=500, description="Question in English")


class ChatAnswer(BaseModel):
    conversation: int
    intent: str
    answer: str = Field(description="Text to display as TEXT (textContent), never as HTML")
    data: list[dict[str, Any]] = Field(description="The same values as in the answer, as they are in the database")
    applied_filters: dict[str, Any]
    considered_records: int
    reference: str | None = Field(description="Period or date of the calculation used")
    dashboard_shortcut: str | None
    options: list[str]
    notice: str | None = Field(default=None, description="Closed due to inactivity (RN13)")
    redacted_by_ai: bool
    refusal: bool


class Opening(BaseModel):
    message: str
    availability: str
    human_service: str
    options: list[str]


class HistoryMessage(BaseModel):
    conversation: int
    moment: datetime | str
    question: str
    intent: str
    answer: str


def history_limit(limit: Annotated[int, Query(ge=1, le=200)] = 50) -> int:
    return limit
