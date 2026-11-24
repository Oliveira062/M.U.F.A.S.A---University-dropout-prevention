"""
Chatbot configuration (F2), read only from environment variables (.env).

The Groq key is optional: without it the chatbot answers with the ready-made
texts from redaction.py, without calling any external service. No key
has a default value in the code.
"""

from functools import lru_cache

from pydantic import Field, SecretStr
from pydantic_settings import BaseSettings, SettingsConfigDict


class ChatConfiguration(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")

    # Connection with the mufasa_chat role (sql/chatbot.sql): reads only the views
    # vw_chat_* and writes only to the chat_* tables. Empty in development uses the
    # API connection; in production it is required.
    chat_database_url: SecretStr | None = None

    # Groq (optional). The AI only rewrites the text; it never receives student data.
    groq_api_key: SecretStr | None = None
    groq_model: str = "openai/gpt-oss-20b"
    # Classify with the AI the questions the rules do not recognize. Off
    # by default: it is the only case in which the typed (redacted) text leaves the server.
    chat_ai_classify: bool = False
    groq_timeout_seconds: float = Field(default=4.0, ge=1.0, le=10.0)  # SRS: chat within 5 s

    # SRS Annex D.1: 20 messages per minute per user in the chat.
    chat_minute_limit: int = Field(default=20, ge=1, le=120)
    # RN13: the conversation closes after 2 hours without interaction.
    chat_inactivity_minutes: int = Field(default=120, ge=1, le=1440)
    chat_maximum_size: int = Field(default=500, ge=50, le=2000)

    # RF13: the chat works 24 h; human support does not. Text defined by the institution.
    chat_service_window: str = "during the academic registrar's office hours"

    @property
    def ai_enabled(self) -> bool:
        return self.groq_api_key is not None and bool(self.groq_api_key.get_secret_value().strip())


@lru_cache
def get_chat_configuration() -> ChatConfiguration:
    return ChatConfiguration()
