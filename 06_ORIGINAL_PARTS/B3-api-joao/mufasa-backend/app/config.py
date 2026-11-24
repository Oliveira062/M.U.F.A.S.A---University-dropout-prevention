"""
MUFASA configuration, read ONLY from environment variables (.env).

No secret has a default value in the code. If JWT_SECRET or DATABASE_URL
are missing, the API does not start: failing early is better than starting with a
predictable key (OWASP A02/A05, SRS RN18).
"""

from decimal import Decimal
from functools import lru_cache

from pydantic import Field, SecretStr, field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Configuration(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")

    # Database. The API connects with the mufasa_api user (sql/b3_complement.sql),
    # never with the postgres superuser.
    database_url: SecretStr

    # JWT. HS256 with a key of at least 32 random bytes.
    jwt_secret: SecretStr
    jwt_algorithm: str = "HS256"
    jwt_expires_minutes: int = Field(default=30, ge=5, le=120)
    jwt_issuer: str = "mufasa-api"
    jwt_audience: str = "mufasa-interface"

    # Environment: "development" or "production".
    environment: str = "development"
    force_https: bool = False
    allowed_hosts: list[str] = ["localhost", "127.0.0.1", "testserver"]
    cors_origins: list[str] = []
    docs_enabled: bool = True

    # Login (RN12): lockout after 5 failures.
    login_max_failures: int = 5
    login_block_minutes: int = 15

    # Request limits (SRS Annex D.1).
    request_limit_minute: int = 120
    login_limit_minute: int = 10

    # Current minimum wage, to convert per capita income into MW.
    # With no configured value, the financial factor stays missing (never made up).
    minimum_wage: Decimal | None = None

    @field_validator("jwt_secret")
    @classmethod
    def _strong_key(cls, v: SecretStr) -> SecretStr:
        if len(v.get_secret_value().encode()) < 32:
            raise ValueError("JWT_SECRET needs at least 32 random bytes")
        return v

    @field_validator("jwt_algorithm")
    @classmethod
    def _allowed_algorithm(cls, v: str) -> str:
        # "none" and asymmetric algorithms without a configured public key are left out.
        if v not in ("HS256", "HS384", "HS512"):
            raise ValueError("JWT_ALGORITHM must be HS256, HS384 or HS512")
        return v

    @property
    def in_production(self) -> bool:
        return self.environment == "production"


@lru_cache
def get_configuration() -> Configuration:
    return Configuration()
