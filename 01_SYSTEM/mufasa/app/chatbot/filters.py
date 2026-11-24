import re
from dataclasses import dataclass

from app.chatbot.text import without_accents

FIELDS = {
    "attendance": ("attendance", "%", 5, 0, 100),
    "average": ("average", "", 0.5, 0, 10),
    "absences": ("absences", "", 2, 0, 500),
    "pending_items": ("pending activities", "", 1, 0, 100),
    "semester": ("semester", "", 0, 1, 20),
    "distance": ("distance", " km", 3, 0, 1000),
}
OPERATORS = {">", ">=", "<", "<=", "=", "between"}
LEVELS = {"critical": "Critical", "high": "High", "moderate": "Moderate", "low": "Low"}


@dataclass(frozen=True)
class Filter:
    field: str
    operator: str
    value: float
    value2: float | None = None
    approximate: bool = False
    center: float | None = None


@dataclass
class Search:
    filters: list[Filter]
    levels: list[str]
    average_dropped: bool = False
    discarded: list[str] = None

    @property
    def empty(self) -> bool:
        return not self.filters and not self.levels and not self.average_dropped


_FIELD_BY_WORD = (
    ("distance", r"distance|lives?|living|resid\w*|far|near (?:the )?(?:university|college|campus)|commut\w*|km\b|kilometer"),
    ("attendance", r"attendance|presence"),
    ("absences", r"absences?"),
    ("pending_items", r"pending|activit(?:y|ies)|tasks?|assignments?|deliverables?"),
    ("average", r"averages?|gpa\b|coefficient"),
    ("semester", r"semesters?|period"),
)
_COMPARATORS = (
    ("between", r"between"),
    ("~", r"close to|near|around|about|approximately|roughly|~"),
    (">=", r"at least|a minimum of|starting at|from|>="),
    ("<=", r"at most|a maximum of|up to|<="),
    (">", r"above|more than|over|greater than|higher than|exceed\w*|>"),
    ("<", r"below|less than|under|lower than|fewer than|<"),
)
_NUMBER = re.compile(
    r"(?P<between>between\s+)?(?P<n1>\d+(?:[.,]\d+)?)(?:\s*(?:st|nd|rd|th)\b)?"
    r"(?:\s*(?:%|km|kilometers?))?(?(between)\s*(?:and|to|-)\s*(?P<n2>\d+(?:[.,]\d+)?))"
    r"\s*(?P<un>%|km\b|kilometers?|absences?|activit(?:y|ies)|pending|tasks?|semesters?|periods?)?")
_SEMESTER_ORDINAL = re.compile(r"\b(\d{1,2})\s*(?:st|nd|rd|th)?\s+(?:semester|period)")


def _prepare(text: str) -> str:
    t = without_accents(text).lower()
    t = re.sub(r"(\d)\s*%", r"\1 %", t)
    t = re.sub(r"[^\w%,.<>=~\s]", " ", t)
    return re.sub(r"\s+", " ", t).strip()


def _number(v: str) -> float:
    return float(v.replace(",", "."))


def _last(patterns, excerpt: str):
    best, pos = None, -1
    for name, default in patterns:
        for m in re.finditer(r"(?:^|\b|\s)(?:" + default + r")(?:\b|\s|$)", excerpt):
            if m.end() > pos:
                best, pos = name, m.end()
    return best


def _field(unit: str | None, before: str, after: str) -> str | None:
    if unit:
        if unit.startswith(("km", "kilometer")):
            return "distance"
        if unit.startswith("absence"):
            return "absences"
        if unit.startswith(("activity", "pending_item", "task")):
            return "pending_items"
        if unit.startswith(("semester", "period")):
            return "semester"
        if unit == "%":
            return "average" if _last((("average", r"averages?"),), before[-25:]) else "attendance"
    if re.match(r"\s*(?:st|nd|rd|th)?\s*(?:semester|period)", after):
        return "semester"
    return _last(_FIELD_BY_WORD, before)


def interpret(text: str) -> Search:
    t = _prepare(text)
    filters, discarded, used = [], [], set()
    previous_end = 0
    for m in _NUMBER.finditer(t):
        if m.group("n1") is None:
            continue
        before = t[max(previous_end, m.start() - 60):m.start()]
        after = t[m.end():m.end() + 20]
        field = _field(m.group("un"), before + (m.group("between") or ""), after)
        previous_end = m.end()
        if field is None or field in used:
            continue
        v1 = _number(m.group("n1"))
        v2 = _number(m.group("n2")) if m.group("n2") else None
        if m.group("between"):
            operator = "between"
        else:
            operator = _last(_COMPARATORS, before[-30:]) or ("=" if field == "semester" else "~")
        name, _, margin, minimum, maximum = FIELDS[field]
        if not all(minimum <= v <= maximum for v in (v1, v2) if v is not None):
            discarded.append(name)
            continue
        approximate, center = operator == "~", v1
        if approximate:
            operator, v1, v2 = "between", max(minimum, v1 - margin), min(maximum, v1 + margin)
        elif operator == "between" and v2 is not None and v2 < v1:
            v1, v2 = v2, v1
        if operator == "between" and v2 is None:
            continue
        filters.append(Filter(field, operator, v1, v2, approximate, center if approximate else None))
        used.add(field)

    levels = []
    for m in re.finditer(r"((?:(?:critical|high|moderate|low)(?: or | and |, ?| )?)+)\s*risk", t):
        for word in re.findall(r"critical|high|moderate|low", m.group(1)):
            if LEVELS[word] not in levels:
                levels.append(LEVELS[word])
    for word in re.findall(r"\b(critical)\b", t):
        if "Critical" not in levels:
            levels.append("Critical")
    average_dropped = bool(re.search(r"average (?:dropped|dropping|falling|fell|declin\w*|went down|decreased|worsened)|(?:drop|decline|fall) in (?:the |their )?average", t))
    return Search(filters, levels, average_dropped, discarded)


def looks_search(text: str) -> bool:
    b = interpret(text)
    return bool(b.filters or b.average_dropped or b.discarded)


def describe(f: Filter) -> str:
    name, unit, *_ = FIELDS[f.field]

    def v(x: float) -> str:
        text = (f"{x:.1f}".rstrip("0").rstrip(".") if x != int(x) else str(int(x)))
        return text + unit

    if f.field == "semester":
        if f.operator == "=":
            return f"in semester {v(f.value)}"
        limits = {">": "after", ">=": "from", "<": "before", "<=": "up to"}
        if f.operator == "between":
            return f"from semester {v(f.value)} to {v(f.value2)}"
        return f"{limits[f.operator]} semester {v(f.value)}"
    if f.field in ("absences", "pending_items"):
        quantity = {">": "more than", ">=": "at least", "<": "fewer than", "<=": "up to", "=": ""}
        if f.approximate:
            return f"about {v(f.center)} {name} ({v(f.value)} to {v(f.value2)})"
        if f.operator == "between":
            return f"between {v(f.value)} and {v(f.value2)} {name}"
        return f"{quantity[f.operator]} {v(f.value)} {name}".strip()
    if f.field == "distance":
        prefix = {">": "more than ", ">=": "at least ", "<": "less than ", "<=": "up to ", "=": ""}
        if f.approximate:
            return f"living about {v(f.center)} away ({v(f.value)[:-3]} to {v(f.value2)})"
        if f.operator == "between":
            return f"living between {v(f.value)[:-3]} and {v(f.value2)} away"
        return f"living {prefix[f.operator]}{v(f.value)} away"
    label = {">": "above", ">=": "from", "<": "below", "<=": "up to", "=": "equal to"}
    if f.approximate:
        return f"{name} close to {v(f.center)} ({v(f.value)} to {v(f.value2)})"
    if f.operator == "between":
        return f"{name} between {v(f.value)} and {v(f.value2)}"
    return f"{name} {label[f.operator]} {v(f.value)}"
