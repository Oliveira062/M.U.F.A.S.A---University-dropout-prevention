"""
Handling of the typed text: normalization for classification, removal of
personal data before any external sending and formatting of the values.
"""

import re
import unicodedata
from decimal import Decimal, InvalidOperation

# Same format accepted by the API (app/api/schemas.ENROLLMENT_PATTERN).
RE_ENROLLMENT = re.compile(r"\b(?:\d{7}|ALU\d{4})\b", re.IGNORECASE)

# Order matters: CPF and phone before the student ID, so no piece is left over.
_REDACTIONS = (
    (re.compile(r"\b\d{3}\.?\d{3}\.?\d{3}-?\d{2}\b"), "[CPF removed]"),
    (re.compile(r"[\w.+-]+@[\w-]+(?:\.[\w-]+)+"), "[email removed]"),
    (re.compile(r"(?:\+?55\s?)?\(?\d{2}\)?\s?9?\d{4}[-\s]?\d{4}\b"), "[phone removed]"),
    (RE_ENROLLMENT, "[student ID removed]"),
)
_ANY_NUMBER = re.compile(r"\d+(?:[.,]\d+)?")


def without_accents(text: str) -> str:
    decomposed = unicodedata.normalize("NFKD", text)
    return "".join(c for c in decomposed if not unicodedata.combining(c))


def normalize(text: str) -> str:
    """Lowercase, no accents, no punctuation and with single spaces."""
    t = without_accents(text).lower()
    t = re.sub(r"[^a-z0-9\s]", " ", t)
    return re.sub(r"\s+", " ", t).strip()


def clear_input(text: str) -> str:
    """Removes control and invisible characters used to hide instructions."""
    text = unicodedata.normalize("NFKC", text)
    text = "".join(c for c in text if unicodedata.category(c)[0] != "C" or c in "\n\t")
    return re.sub(r"\s+", " ", text).strip()


def redact_personal_data(text: str) -> str:
    """Version of the question stored in the history: without CPF, email, phone and student ID."""
    for default, swap in _REDACTIONS:
        text = default.sub(swap, text)
    return text


_UPPERCASE_WORD = re.compile(r"(?<!^)(?<![.!?]\s)\b[A-Z][a-z]+")


def text_for_ai(text: str) -> str:
    """
    Version of the question that can leave the server (only in the optional
    classification): besides personal data, any number (grade, age,
    address) and any capitalized word outside the start of the
    sentence, which is usually a proper name, are removed.
    """
    t = _ANY_NUMBER.sub("#", redact_personal_data(text))
    return _UPPERCASE_WORD.sub("[name]", t)


def cited_enrollments(text: str) -> list[str]:
    return [m.upper() for m in RE_ENROLLMENT.findall(text)]


def br_number(value) -> str | None:
    """
    Formats the value EXACTLY as it is in the database, only swapping the point for
    a comma. Zero stays zero; empty stays empty (None).
    """
    if value is None:
        return None
    try:
        d = Decimal(str(value))
    except (InvalidOperation, ValueError):
        return str(value)
    if d == d.to_integral_value():
        return str(int(d))
    return format(d.normalize(), "f").replace(".", ",")


def br_date(value) -> str | None:
    if value is None:
        return None
    text = str(value)[:10]
    parts = text.split("-")
    if len(parts) == 3 and all(p.isdigit() for p in parts):
        return f"{parts[2]}/{parts[1]}/{parts[0]}"
    return text
