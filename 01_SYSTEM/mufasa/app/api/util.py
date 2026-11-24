import json
from datetime import date, datetime, timezone
from decimal import Decimal


def now() -> datetime:
    return datetime.now(timezone.utc)


def as_datetime(value) -> datetime | None:
    if value is None:
        return None
    if isinstance(value, datetime):
        return value if value.tzinfo else value.replace(tzinfo=timezone.utc)
    converted = datetime.fromisoformat(str(value))
    return converted if converted.tzinfo else converted.replace(tzinfo=timezone.utc)


def yes_no(value) -> bool | None:
    if value is None:
        return None
    if isinstance(value, bool):
        return value
    return str(value).strip().lower() in ("yes", "s", "true", "1")


def number(value) -> float | None:
    return None if value is None else float(value)


def json_value(value):
    if isinstance(value, Decimal):
        return float(value)
    if isinstance(value, (date, datetime)):
        return value.isoformat()
    return value


def json_row(row) -> dict | None:
    return None if row is None else {k: json_value(v) for k, v in dict(row).items()}


def json_list(value) -> list:
    if not value:
        return []
    return json.loads(value) if isinstance(value, str) else list(value)
