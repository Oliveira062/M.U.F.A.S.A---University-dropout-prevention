"""
Authentication: password hash, JWT issuing and reading, current user.

- Password: bcrypt cost 12 (SRS RN18). The bcrypt library directly, without passlib,
  which is unmaintained.
- JWT: PyJWT, fixed algorithm when reading (prevents the "alg: none" attack and
  algorithm switching), exp/iat/sub/jti required, issuer and audience
  checked, 30-minute validity (closing on inactivity, RN12).
- Token only in the Authorization: Bearer header. The API does not use a session
  cookie, which eliminates CSRF by design.
- Profile and scope are read from the DATABASE on every request, not from the token: a
  deactivated user loses access immediately.
"""

import uuid
from dataclasses import dataclass
from datetime import datetime, timedelta, timezone

import bcrypt
import jwt
from fastapi import Depends, Request
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.engine import Connection

from app.api import audit
from app.api.database import get_connection
from app.api.queries import REVOKED_TOKEN, USER_BY_ID
from app.api.errors import http_error
from app.api.security import limiter
from app.config import get_configuration

BCRYPT_COST = 12
BCRYPT_BYTES_LIMIT = 72

# Valid hash of a random password, used when the login does not exist, so
# that the response time does not reveal which logins are registered.
_FICTITIOUS_HASH = bcrypt.hashpw(uuid.uuid4().bytes, bcrypt.gensalt(BCRYPT_COST))

_bearer = HTTPBearer(auto_error=False)


@dataclass(frozen=True)
class User:
    user_id: int
    login: str
    profile: str
    student_id: str | None
    id_professor: str | None
    course_id: str | None


def generate_password_hash(password: str) -> str:
    data = password.encode("utf-8")
    if len(data) > BCRYPT_BYTES_LIMIT:
        raise ValueError("Password longer than 72 bytes")
    return bcrypt.hashpw(data, bcrypt.gensalt(BCRYPT_COST)).decode("ascii")


def check_password(password: str, password_hash: str | None) -> bool:
    data = password.encode("utf-8")
    if len(data) > BCRYPT_BYTES_LIMIT:
        return False
    if not password_hash:
        bcrypt.checkpw(data, _FICTITIOUS_HASH)
        return False
    try:
        return bcrypt.checkpw(data, password_hash.encode("ascii"))
    except ValueError:
        return False


def issue_token(user_id: int, profile: str) -> tuple[str, int]:
    cfg = get_configuration()
    now = datetime.now(timezone.utc)
    validity = timedelta(minutes=cfg.jwt_expires_minutes)
    load = {
        "sub": str(user_id),
        "profile": profile,  # informational for the interface; the API checks in the database
        "iat": now,
        "nbf": now,
        "exp": now + validity,
        "jti": uuid.uuid4().hex,
        "iss": cfg.jwt_issuer,
        "aud": cfg.jwt_audience,
    }
    token = jwt.encode(load, cfg.jwt_secret.get_secret_value(), algorithm=cfg.jwt_algorithm)
    return token, int(validity.total_seconds())


def read_token(token: str) -> dict:
    cfg = get_configuration()
    return jwt.decode(
        token,
        cfg.jwt_secret.get_secret_value(),
        algorithms=[cfg.jwt_algorithm],
        audience=cfg.jwt_audience,
        issuer=cfg.jwt_issuer,
        options={"require": ["exp", "iat", "nbf", "sub", "jti", "iss", "aud"]},
        leeway=10,
    )


_NOT_AUTHENTICATED = {"WWW-Authenticate": "Bearer"}


def get_load_token(credentials: HTTPAuthorizationCredentials | None = Depends(_bearer)) -> dict:
    if credentials is None or credentials.scheme.lower() != "bearer":
        raise http_error(401, "Send the token in the Authorization: Bearer header.", _NOT_AUTHENTICATED)
    try:
        return read_token(credentials.credentials)
    except jwt.ExpiredSignatureError:
        raise http_error(401, "Session expired. Sign in again.", _NOT_AUTHENTICATED)
    except jwt.PyJWTError:
        raise http_error(401, "Invalid token.", _NOT_AUTHENTICATED)


def get_current_user(
    request: Request,
    load: dict = Depends(get_load_token),
    connection: Connection = Depends(get_connection),
) -> User:
    if connection.execute(REVOKED_TOKEN, {"jti": load["jti"]}).first():
        raise http_error(401, "Session ended. Sign in again.", _NOT_AUTHENTICATED)

    try:
        user_id = int(load["sub"])
    except (TypeError, ValueError):
        raise http_error(401, "Invalid token.", _NOT_AUTHENTICATED)

    row = connection.execute(USER_BY_ID, {"user_id": user_id}).mappings().first()
    if row is None or not row["active"]:
        raise http_error(401, "Inactive or nonexistent user.", _NOT_AUTHENTICATED)

    user = User(
        user_id=row["user_id"], login=row["login"], profile=row["profile"],
        student_id=row["student_id"], id_professor=row["id_professor"], course_id=row["course_id"],
    )

    # 120 requests per minute per user (SRS Annex D.1).
    allowed, wait = limiter.allow(f"user:{user.user_id}", get_configuration().request_limit_minute)
    if not allowed:
        audit.register(request, "EXCEEDED_LIMIT", "DENIED", user=user)
        raise http_error(429, "Request limit exceeded. Wait and try again.",
                        {"Retry-After": str(wait)})

    request.state.load_token = load
    return user


def require_profiles(*profiles: str):
    """Dependency that blocks, ON THE SERVER, any profile outside the list."""

    def _check(request: Request, user: User = Depends(get_current_user)) -> User:
        if user.profile not in profiles:
            audit.register(request, "NOT_AUTHORIZED_PROFILE", "DENIED", user=user)
            raise http_error(403, "Your profile does not have access to this resource.")
        return user

    return _check
