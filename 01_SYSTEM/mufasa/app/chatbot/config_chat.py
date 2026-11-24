from functools import lru_cache

from pydantic import Field, SecretStr
from pydantic_settings import BaseSettings, SettingsConfigDict


class ChatConfiguration(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")

    chat_database_url: SecretStr | None = None

    groq_api_key: SecretStr | None = None
    groq_model: str = "openai/gpt-oss-20b"
    chat_ai_classify: bool = False
    chat_ai_conversation: bool = True
    groq_timeout_seconds: float = Field(default=4.0, ge=1.0, le=10.0)
    groq_temperature: float = Field(default=0.7, ge=0.0, le=1.2)

    chat_minute_limit: int = Field(default=20, ge=1, le=120)
    chat_inactivity_minutes: int = Field(default=120, ge=1, le=1440)
    chat_maximum_size: int = Field(default=500, ge=50, le=2000)

    chat_service_window: str = "during the academic registrar's office hours"

    @property
    def ai_enabled(self) -> bool:
        return self.groq_api_key is not None and bool(self.groq_api_key.get_secret_value().strip())


@lru_cache
def get_chat_configuration() -> ChatConfiguration:
    return ChatConfiguration()
