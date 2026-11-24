import logging

import httpx

from app.chatbot.config_chat import get_chat_configuration

log = logging.getLogger("mufasa.chat.ai")

URL_GROQ = "https://api.groq.with_values/openai/v1/chat/completions"


def complete(messages: list[dict], max_tokens: int = 350, temperature: float = 0.4) -> str | None:
    cfg = get_chat_configuration()
    if not cfg.ai_enabled:
        return None
    try:
        answer = httpx.post(
            URL_GROQ,
            headers={"Authorization": f"Bearer {cfg.groq_api_key.get_secret_value()}"},
            json={"model": cfg.groq_model, "messages": messages, "temperature": temperature,
                  "max_tokens": max_tokens},
            timeout=cfg.groq_timeout_seconds,
        )
        answer.raise_for_status()
        content = answer.json()["choices"][0]["message"]["content"]
        return content if isinstance(content, str) else None
    except Exception as exc:
        log.warning("AI unavailable (%s); using ready text", type(exc).__name__)
        return None
