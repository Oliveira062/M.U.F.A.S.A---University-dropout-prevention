import json

from cryptography.fernet import Fernet, InvalidToken

from app.config import get_configuration


class UnavailableKey(Exception):
    pass


def _fernet(key: str | None = None) -> Fernet:
    if key is None:
        configured = get_configuration().support_key
        if configured is None:
            raise UnavailableKey("SUPPORT_KEY not configured")
        key = configured.get_secret_value()
    try:
        return Fernet(key.encode("ascii"))
    except (ValueError, UnicodeEncodeError) as exc:
        raise UnavailableKey("SUPPORT_KEY invalid") from exc


def encrypt(data: dict, key: str | None = None) -> str:
    return _fernet(key).encrypt(json.dumps(data, ensure_ascii=False).encode("utf-8")).decode("ascii")


def decrypt(token: str) -> dict:
    try:
        return json.loads(_fernet().decrypt(token.encode("ascii")))
    except InvalidToken as exc:
        raise UnavailableKey("support data does not match the key") from exc
