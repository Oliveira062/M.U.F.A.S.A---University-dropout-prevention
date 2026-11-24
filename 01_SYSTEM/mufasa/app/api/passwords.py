import secrets
import string

_LETTERS = "abcdefghijkmnpqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ"
_DIGITS = "23456789"


def generate_temporary_password(size: int = 12) -> str:
    while True:
        password = "".join(secrets.choice(_LETTERS + _DIGITS) for _ in range(size))
        if any(c in _DIGITS for c in password) and any(c in string.ascii_letters for c in password):
            return password
