from fastapi import APIRouter, Depends, Request
from sqlalchemy.engine import Connection

from app.api import audit
from app.api.auth import User, get_released_user
from app.api.database import get_connection
from app.api.errors import http_error
from app.api.permissions import STUDENT, SUPPORT_CENTER
from app.api.security import limiter
from app.chatbot import conversation
from app.chatbot import chat_queries as sql
from app.chatbot import intents as it
from app.chatbot.chat_database import get_chat_connection
from app.chatbot.config_chat import get_chat_configuration
from app.chatbot.chat_schemas import (Opening, HistoryMessage, ChatRequest, ChatAnswer,
                                      history_limit)
from app.chatbot.redaction import classify_with_ai, redact
from app.chatbot.service import STUDENT_OPTIONS, TEAM_OPTIONS, SSC_OPTIONS, run, opening_text
from app.chatbot.text import clear_input, redact_personal_data

router_chat = APIRouter(prefix="/api/v1/chat", tags=["chatbot"])


def _limit(request: Request, user: User) -> None:
    cfg = get_chat_configuration()
    allowed, wait = limiter.allow(f"chat:{user.user_id}", cfg.chat_minute_limit)
    if not allowed:
        audit.register(request, "CHAT_EXCEEDED_LIMIT", "DENIED", user=user)
        raise http_error(429, "You sent too many messages in a row. Wait a minute and try again.",
                         {"Retry-After": str(wait)})


@router_chat.get("/opening", response_model=Opening)
def opening(user: User = Depends(get_released_user)):
    cfg = get_chat_configuration()
    return Opening(message=opening_text(user.profile), availability="Chat available 24 hours.",
                   human_service=f"Service with the team {cfg.chat_service_window}.",
                   options=STUDENT_OPTIONS if user.profile == STUDENT else
                   SSC_OPTIONS if user.profile == SUPPORT_CENTER else TEAM_OPTIONS)


@router_chat.post("/queries", response_model=ChatAnswer)
def query(payload: ChatRequest, request: Request,
          user: User = Depends(get_released_user),
          api_connection: Connection = Depends(get_connection),
          chat_connection: Connection = Depends(get_chat_connection)):
    _limit(request, user)

    text = clear_input(payload.text)
    if not text:
        raise http_error(422, "Write a question.")

    classification = it.classify(text, user.profile, user.student_id)
    intent = classification.intent
    previous = [a for a in conversation.last(chat_connection, user.user_id) if a["intent"] not in it.REFUSALS]
    intent = it.resume_topic(intent, text, [a["intent"] for a in previous])
    cfg = get_chat_configuration()
    if intent == it.NOT_UNDERSTOOD and cfg.ai_enabled and cfg.chat_ai_classify:
        intent = classify_with_ai(text, user.profile)

    result = run(intent, classification.enrollments, text, user, request, api_connection, chat_connection)
    history = [a["redacted_question"] for a in reversed(previous)]
    answer, by_ai = redact(result, user.profile, text, history)

    conversation_id, notice = conversation.get_or_open(chat_connection, user.user_id)
    conversation.register(chat_connection, conversation_id=conversation_id, user_id=user.user_id,
                          redacted_question=redact_personal_data(text), intent=result.intent,
                          query=result.query, records=result.records, answer=answer,
                          redacted_by_ai=by_ai, bypass_attempt=result.bypass_attempt)
    chat_connection.commit()

    if result.bypass_attempt:
        audit.register(request, "CHAT_BYPASS_ATTEMPT", "DENIED", user=user)
    elif result.intent != it.SPECIFIC_STUDENT:
        audit.register(request, "CHAT_" + result.intent[:35],
                       "DENIED" if result.refusal else "ALLOWED", user=user,
                       target_student_id=user.student_id if user.profile == STUDENT else result.target_student_id)

    return ChatAnswer(
        conversation=conversation_id, intent=result.intent, answer=answer, data=result.data,
        applied_filters=result.filters, considered_records=result.records,
        reference=result.reference, dashboard_shortcut=result.shortcut, options=result.options,
        notice=notice, redacted_by_ai=by_ai, refusal=result.refusal,
    )


@router_chat.get("/history", response_model=list[HistoryMessage])
def history(request: Request, limit: int = Depends(history_limit),
            user: User = Depends(get_released_user),
            chat_connection: Connection = Depends(get_chat_connection)):
    rows = chat_connection.execute(sql.USER_HISTORY,
                                   {"user_id": user.user_id, "limit": limit}).mappings().all()
    audit.register(request, "CHAT_READ_HISTORY", "ALLOWED", user=user)
    return [HistoryMessage(conversation=l["conversation_id"], moment=l["moment"], question=l["redacted_question"],
                           intent=l["intent"], answer=l["answer"]) for l in rows]


@router_chat.post("/close", status_code=204)
def close(request: Request, user: User = Depends(get_released_user),
          chat_connection: Connection = Depends(get_chat_connection)):
    if conversation.close(chat_connection, user.user_id):
        chat_connection.commit()
    audit.register(request, "CHAT_CLOSE", "ALLOWED", user=user)
