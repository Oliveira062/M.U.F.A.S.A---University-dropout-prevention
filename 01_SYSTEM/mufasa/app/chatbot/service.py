from dataclasses import dataclass, field

from fastapi import HTTPException, Request
from sqlalchemy.engine import Connection

from app.api.auth import User
from app.api.schemas import METHODOLOGICAL_NOTICE
from app.api.permissions import (STUDENT, COORDINATION, TEACHER, SUPPORT_CENTER, check_student_scope)
from app.api.visibility import main_visible
from app.calculation.score import LABELS as FACTOR_LABELS
from app.chatbot import chat_queries as sql
from app.chatbot import intents as it
from app.chatbot.filters import FIELDS, describe, interpret
from app.chatbot.config_chat import get_chat_configuration
from datetime import date, timedelta

from app.chatbot.text import br_date, normalize, br_number

DATABASE_LEVEL = {"Low": "LOW", "Moderate": "MODERATE", "High": "HIGH", "Critical": "CRITICAL"}

SUBJECT_GRADES_SCALE = "0 to 10"
GENERAL_AVERAGE_SCALE = "0 to 10"

CRITICAL_LEVEL = "Critical"
HIGH_LEVEL = "High"
ORDER_LEVELS = ("Critical", "High", "Moderate", "Low")

SHORTCUTS = {
    it.ACADEMIC_SUMMARY: "/dashboard/my-performance",
    it.GRADES: "/dashboard/my-performance#grades",
    it.ATTENDANCE: "/dashboard/my-performance#attendance",
    it.AVERAGE: "/dashboard/my-performance",
    it.STATUS: "/dashboard/my-performance#grades",
    it.PENDING_ITEMS: "/dashboard/my-performance",
    it.MY_RISK: "/dashboard/my-performance#risk",
    it.RISK_SUMMARY: "/dashboard/general-view",
    it.HIGHEST_RISK: "/dashboard/alerts?level=CRITICAL,HIGH",
    it.SPECIFIC_STUDENT: "/dashboard/students/{enrollment}",
    it.PRIVACY: "/dashboard/privacy",
}

TEAM_PROFILES = (TEACHER, COORDINATION, SUPPORT_CENTER)

STUDENT_OPTIONS = ["My grades", "My attendance", "What is due this week?", "My risk level",
                   "Talk to a person"]
TEAM_OPTIONS = ["Risk summary", "Highest-risk students", "Students with attendance below 70%",
                "How the risk is calculated"]
SSC_OPTIONS = ["Risk summary", "Highest-risk students", "Students more than 20 km away with attendance below 70%",
               "How the risk is calculated"]

_EMPTY_WORDS = {"de", "da", "do", "", "", "e", "em", "a", "o", "as", "os", "for_value", "with_values", "ao"}
_ROMAN = {"i": "1", "ii": "2", "iii": "3", "iv": "4", "v": "5", "vi": "6"}


@dataclass
class Result:
    intent: str
    draft: str
    footer: str = ""
    values: dict[str, str] = field(default_factory=dict)
    details: str = ""
    signals: dict = field(default_factory=dict)
    data: list[dict] = field(default_factory=list)
    query: str | None = None
    records: int = 0
    reference: str | None = None
    filters: dict = field(default_factory=dict)
    shortcut: str | None = None
    options: list[str] = field(default_factory=list)
    refusal: bool = False
    bypass_attempt: bool = False
    can_humanize: bool = False
    free: bool = False
    target_student_id: str | None = None


def _window() -> str:
    return get_chat_configuration().chat_service_window


def opening_text(profile: str = STUDENT) -> str:
    offer = ("I can show your grades, your attendance, what is due in the next few days and your risk level, "
             "always with the data recorded in the system." if profile == STUDENT else
             "I can search for students combining attendance, average, absences and pending items, summarize the risk of your "
             "classes and show the status of a student by student ID, always within what your profile can see.")
    return ("Hi! I'm Mufa, the MUFASA assistant. " + offer + "\n\nI'm available 24 hours; "
            f"service with a person from the team happens {_window()}.\n\n"
            "For safety, do not write your password, CPF or health information here.")


def _fixed(intent: str, user: User) -> Result | None:
    is_student = user.profile == STUDENT
    options = STUDENT_OPTIONS if is_student else SSC_OPTIONS if user.profile == SUPPORT_CENTER else TEAM_OPTIONS
    texts = {
        it.BYPASS: ("I can't do that. I always follow the same security rules and only show the data "
                    "your profile can see. This attempt was recorded.\n\nCan I help with your grades, "
                    "attendance or risk level?"),
        it.CHANGE: ("I only look up information; I do not change grades, absences or records. To ask for a "
                    "correction, contact the academic registrar's office.\n\nIf it is your own personal data, you can also "
                    "ask for the correction on the Privacy page of the dashboard."),
        it.OTHER_STUDENT: ("I'm not allowed to show information about other students. "
                           "I can show yours, if you want."),
        it.JUDGMENT: ("I don't judge people. The system only describes indicators, such as grades and "
                      "attendance, and says nothing about anyone's effort or ability."),
        it.METHODOLOGY: ("The risk level is calculated from recorded indicators, such as attendance, "
                         "grades and some context factors, each one with a weight set by the team. "
                         "Factors without data are left out of the calculation, instead of being filled in.\n\n" + METHODOLOGICAL_NOTICE),
        it.SERVICE: ("I can record your question here at any time, but service with a person from the "
                     f"team happens {_window()}.\n\nIf you are going through a difficult moment, "
                     "contact the university's support center. No one needs to go through this without support.\n\nIn an emergency, call CVV "
                     "at 188 (24 hours, free) or SAMU at 192."),
        it.PRIVACY: ("On the Privacy page of the dashboard you can see all the data MUFASA keeps about "
                     "you, export it and ask for correction, deletion or review of an automated "
                     "decision (LGPD, arts. 18 and 20).\n\nThe answer arrives within 15 days."),
        it.ACCESS: ("For safety, never type your password in the chat.\n\nIf you forgot your password or your access was "
                    "blocked after wrong attempts, wait 15 minutes or contact the academic registrar's office "
                    "to reset it."),
        it.GREETING: opening_text(user.profile),
        it.THANKS: "You're welcome! If you need anything else, just ask.",
        it.HELP: ("You can ask me, for example:\n\n• \"What are my grades?\"\n"
                  "• \"How is my attendance in Calculus I?\"\n• \"What is my risk level?\"" if is_student else
                  "You can ask me, for example:\n\n• \"How many students are at high risk?\"\n"
                  "• \"Which students have the highest risk?\"\n• The status of a student, giving the student ID"),
        it.STUDIES: ("Good question! Some ideas that usually help:\n\n"
                     "• Study in short blocks, with breaks, instead of a marathon the night before\n"
                     "• Start with the content that needs the most attention, when your mind is rested\n"
                     "• Redo exercises without looking at the answer and note where you got stuck\n"
                     "• Take your questions to the teacher or to the tutoring sessions before the exam\n\n"
                     "If you want, I can show your grades to see where to start."),
        it.OUT_OF_SCOPE: ("That topic is a bit outside what I can do.\n\nI help with grades, "
                          "attendance, risk and with using MUFASA. Want to try one of those?"),
        it.NOT_UNDERSTOOD: ("Sorry, I didn't quite understand the question.\n\nYou can write it another way or choose one of the "
                        "suggestions below."),
    }
    if intent not in texts:
        return None
    r = Result(intent=intent, draft=texts[intent], options=options)
    r.free = intent in it.CONVERSATION_INTENTS
    r.refusal = intent in it.REFUSALS
    r.bypass_attempt = intent == it.BYPASS
    if intent == it.PRIVACY:
        r.shortcut = SHORTCUTS[it.PRIVACY]
    return r


def _without_permission(intent: str, message: str) -> Result:
    return Result(intent=intent, draft=message, refusal=True)


def _tokens(name: str) -> tuple[set[str], str | None]:
    parts = [_ROMAN.get(p, p) for p in normalize(name).split()]
    numeral = next((p for p in parts if p.isdigit()), None)
    main = {p for p in parts if p not in _EMPTY_WORDS and not p.isdigit() and len(p) >= 4}
    return main, numeral


def cited_subjects(question: str, names: list[str]) -> list[str]:
    words = [_ROMAN.get(p, p) for p in normalize(question).split()]
    item_set = set(words)
    numerals = {p for p in words if p.isdigit() and len(p) == 1}
    best, best_points = [], 0
    for name in names:
        main, numeral = _tokens(name)
        points = len(main & item_set)
        if points == 0:
            continue
        if numeral and numerals and numeral not in numerals:
            continue
        if points > best_points:
            best, best_points = [name], points
        elif points == best_points:
            best.append(name)
    return best


def _rows(connection: Connection, query, params: dict) -> list[dict]:
    return [dict(l) for l in connection.execute(query, params).mappings().all()]


def _student_profile(chat_connection: Connection, student_id: str) -> dict | None:
    row = chat_connection.execute(sql.STUDENT_PROFILE, {"student_id": student_id}).mappings().first()
    return None if row is None else dict(row)


def _first_name(profile: dict | None) -> str | None:
    name = (profile or {}).get("fictitious_name") or ""
    return name.split()[0] if name.strip() else None


def _with_name(r: Result, profile: dict | None, sentence_with_name: str, sentence_without_name: str) -> str:
    name = _first_name(profile)
    if name:
        r.values["NAME"] = name
        return sentence_with_name
    return sentence_without_name


def _pl(n: int, singular: str, plural: str) -> str:
    return singular if n == 1 else plural


def _readable_list(items: list[str]) -> str:
    return items[0] if len(items) == 1 else ", ".join(items[:-1]) + " and " + items[-1]


def _factors_names(factors) -> list[str]:
    import json
    if isinstance(factors, str):
        factors = json.loads(factors)
    return [FACTOR_LABELS.get(f, f) for f in (factors or [])]


def _student_subjects(chat_connection: Connection, student_id: str, question: str):
    rows = _rows(chat_connection, sql.STUDENT_SUBJECTS, {"student_id": student_id, "limit": sql.ROWS_LIMIT})
    my = [l["subject"] for l in rows]
    cited = cited_subjects(question, my)
    if cited:
        return [l for l in rows if l["subject"] in cited], cited, None
    catalog = [l["name"] for l in chat_connection.execute(sql.SUBJECT_NAMES).mappings().all()]
    outside = cited_subjects(question, catalog)
    if outside:
        return [], outside, outside
    return rows, [], None


def _minimum_below(row: dict) -> bool:
    att, minimum = row.get("attendance_pct"), row.get("minimum_attendance_pct")
    return att is not None and minimum is not None and float(att) < float(minimum)


def _text_status(value) -> str:
    return str(value) if value not in (None, "") else "no status recorded"


def _value(v, suffix: str = "") -> str:
    text = br_number(v)
    return "no record" if text is None else text + suffix


def _subjects_intent(intent: str, chat_connection: Connection, student_id: str, question: str) -> Result:
    rows, filter_value, outside = _student_subjects(chat_connection, student_id, question)
    r = Result(intent=intent, draft="", query="STUDENT_SUBJECTS", records=len(rows),
               shortcut=SHORTCUTS[intent], filters={"subject": filter_value} if filter_value else {},
               options=STUDENT_OPTIONS, can_humanize=True)

    if outside:
        r.draft = ("I didn't find an enrollment of yours in " + ", ".join(outside) + " in the recorded period. "
                   "I can show the subjects you are enrolled in.")
        r.can_humanize = False
        return r
    if not rows:
        r.draft = "I didn't find subjects recorded for you in the system."
        r.can_humanize = False
        return r

    r.reference = rows[0].get("academic_period")
    details = []
    for l in rows:
        item = {
            "subject": l["subject"], "academic_period": l["academic_period"],
            "exam1": br_number(l["exam1"]), "exam2": br_number(l["exam2"]), "exam3": br_number(l["exam3"]),
            "final_grade": br_number(l["final_grade"]), "attendance_pct": br_number(l["attendance_pct"]),
            "minimum_attendance_pct": br_number(l["minimum_attendance_pct"]),
            "status": l["status"], "minimum_attendance_below": _minimum_below(l),
        }
        r.data.append(item)
        if intent == it.ATTENDANCE:
            row = f"• {l['subject']}: {_value(l['attendance_pct'], '%')} presence"
            if l["minimum_attendance_pct"] is not None:
                row += f"\n  minimum {_value(l['minimum_attendance_pct'], '%')}"
                if item["minimum_attendance_below"]:
                    row += " · below the minimum"
        elif intent == it.STATUS:
            row = f"• {l['subject']}: {_text_status(l['status'])}"
        else:
            row = (f"• {l['subject']}: final grade {_value(l['final_grade'])} · {_text_status(l['status'])}"
                   f"\n  EXAM1 {_value(l['exam1'])} · EXAM2 {_value(l['exam2'])} · EXAM3 {_value(l['exam3'])}")
            if intent == it.ACADEMIC_SUMMARY:
                row += f" · attendance {_value(l['attendance_pct'], '%')}"
        details.append(row)

    r.details = "\n".join(details)
    failed = sum(1 for d in r.data if str(d["status"]).lower().startswith("reprov"))
    below = sum(1 for d in r.data if d["minimum_attendance_below"])
    r.values = {"SUBJECTS_COUNT": str(len(rows)), "FAILED_COUNT": str(failed),
                "BELOW_MINIMUM_COUNT": str(below)}
    r.signals = {"has_registered_failure": failed > 0, "has_minimum_below_attendance": below > 0,
                 "one_subject_query": bool(filter_value)}

    profile = _student_profile(chat_connection, student_id)
    if intent == it.ATTENDANCE:
        opening = _with_name(r, profile, "Sure, [[NAME]]! This is your attendance", "Sure! This is your attendance")
        if below:
            names = [d["subject"] for d in r.data if d["minimum_attendance_below"]]
            r.values["BELOW"] = _readable_list(names)
            closing = ("Keep an eye on [[BELOW]]: there, presence is below the required minimum. It is worth talking "
                       "to the teacher or to the coordination as soon as possible, to see what can still be done.")
        else:
            closing = "Everything within the required minimum. Keep it up!"
    elif intent == it.STATUS:
        opening = _with_name(r, profile, "Sure, [[NAME]]! This is the status of your subjects",
                             "Sure! This is the status of your subjects")
        closing = (f"In [[FAILED_COUNT]] {_pl(failed, 'subject', 'subjects')} the status ended up as failed. If you want, the support "
                   "center can help you build a study plan." if failed else
                   "No failures recorded. Good job!")
    else:
        opening = (_with_name(r, profile, "Sure, [[NAME]]! These are your grades", "Sure! These are your grades")
                   if intent != it.ACADEMIC_SUMMARY else
                   _with_name(r, profile, "Sure, [[NAME]]! This is the summary of your performance",
                              "Sure! This is the summary of your performance"))
        closing = ""
        with_grade = [d for d, l in zip(r.data, rows) if l["final_grade"] is not None]
        if len(with_grade) >= 2 and not filter_value:
            grades = {d["subject"]: float(l["final_grade"]) for d, l in zip(r.data, rows)
                      if l["final_grade"] is not None}
            best, worst = max(grades, key=grades.get), min(grades, key=grades.get)
            if grades[best] != grades[worst]:
                r.values.update({"BEST": best, "WORST": worst})
                r.signals["has_best_and_worst_subject"] = True
                closing = ("Your best result is in [[BEST]], and the subject that needs the most attention now is "
                           "[[WORST]].\n\n")
        if (not filter_value and profile and profile.get("current_average") is not None
                and profile.get("previous_semester_average") is not None):
            current, previous = float(profile["current_average"]), float(profile["previous_semester_average"])
            r.values.update({"CURRENT_AVERAGE": _value(profile["current_average"]),
                             "PREVIOUS_AVERAGE": _value(profile["previous_semester_average"])})
            comparison = "above" if current > previous else "below" if current < previous else "equal"
            r.signals["general_average_in_relation_to_previous_semester"] = comparison
            closing += ("Your overall average is [[CURRENT_AVERAGE]], " +
                        ("the same as last semester." if comparison == "equal" else
                         f"{comparison} last semester's ([[PREVIOUS_AVERAGE]]).") + " ")
        closing += f"Grades go from {SUBJECT_GRADES_SCALE}, exactly as they are in the academic system."
        if failed:
            closing += (f"\n\nIn [[FAILED_COUNT]] {_pl(failed, 'subject', 'subjects')} the status ended up as failed. If you want, the "
                        "support center can help you build a study plan.")
    if filter_value:
        r.values["SUBJECTS"] = _readable_list(filter_value)
        opening = (opening.replace("These are your grades", "These are your grades in [[SUBJECTS]]")
                   .replace("This is your attendance", "This is your attendance in [[SUBJECTS]]")
                   .replace("This is the status of your subjects", "This is your status in [[SUBJECTS]]"))
    period = f" in {r.reference}" if r.reference else ""
    r.draft = f"{opening}{period}:\n\n[[DETAILS]]\n\n{closing}"
    return r


def _indicators_intent(intent: str, chat_connection: Connection, student_id: str) -> Result:
    ind = chat_connection.execute(sql.STUDENT_INDICATORS, {"student_id": student_id}).mappings().first()
    r = Result(intent=intent, draft="", query="STUDENT_INDICATORS",
               records=0 if ind is None else 1, shortcut=SHORTCUTS[intent], options=STUDENT_OPTIONS)
    if ind is None:
        r.draft = "There are no indicators recorded for you in the system yet."
        return r
    r.reference = ind["academic_period"]
    r.can_humanize = True
    r.data = [{k: (br_number(v) if k != "academic_period" else v) for k, v in dict(ind).items()}]

    if intent == it.AVERAGE:
        trend = ind["average_trend"]
        r.values = {"CURRENT_AVERAGE": _value(ind["current_average"]),
                    "PREVIOUS_AVERAGE": _value(ind["previous_semester_average"])}
        if trend is None:
            meaning = "stable_or_without_data"
            closing = ""
        elif float(trend) > 0:
            meaning, closing = "went_up", "\n\nYour average went up compared to last semester. Great!"
        elif float(trend) < 0:
            meaning, closing = "dropped", ("\n\nYour average dropped a little compared to last semester. If you want "
                                           "to understand what changed, the support center can help.")
        else:
            meaning, closing = "stable_or_without_data", "\n\nYour average stayed the same as last semester."
        r.signals = {"average_trend": meaning}
        opening = _with_name(r, _student_profile(chat_connection, student_id), "[[NAME]], your", "Your")
        r.draft = (f"{opening} current average in {r.reference} is [[CURRENT_AVERAGE]]. Last semester, it was "
                   f"[[PREVIOUS_AVERAGE]].{closing}\n\nAverages go from {GENERAL_AVERAGE_SCALE}.")
    else:
        r.values = {"PENDING": _value(ind["pending_activities"])}
        pending = ind["pending_activities"]
        r.signals = {"has_pending_items": bool(pending)}
        r.draft = (f"In {r.reference}, you have [[PENDING]] {_pl(pending or 0, 'pending activity', 'pending activities')}.\n\n"
                   + ("How about setting aside a time in the week to catch up on them? If you need, the support "
                      "center can help organize your routine." if pending else
                      "Everything up to date here. Keep it up!"))
    return r


def _when(deadline: date, today: date) -> str:
    days = (deadline - today).days
    if days < -1:
        return f"late since {br_date(deadline)}"
    if days == -1:
        return "was due yesterday"
    if days == 0:
        return "is due today"
    if days == 1:
        return "is due tomorrow"
    if days <= 6:
        return f"is due in {days} days ({br_date(deadline)})"
    return f"is due on {br_date(deadline)}"


def _activities_intent(chat_connection: Connection, student_id: str, question: str,
                       today: date | None = None) -> Result:
    today = today or date.today()
    rows = _rows(chat_connection, sql.STUDENT_PENDING_ACTIVITIES, {"student_id": student_id, "limit": sql.ROWS_LIMIT})
    r = Result(intent=it.PENDING_ITEMS, draft="", query="STUDENT_PENDING_ACTIVITIES", records=len(rows),
               shortcut=SHORTCUTS[it.PENDING_ITEMS], options=STUDENT_OPTIONS, can_humanize=True)
    profile = _student_profile(chat_connection, student_id)
    t = normalize(question)
    if "today" in t.split() or "tomorrow" in t.split():
        window, cropped = 1, "by tomorrow"
    elif "week" in t:
        window, cropped = 6, "this week"
    elif "month" in t.split():
        window, cropped = 30, "this month"
    else:
        window, cropped = None, ""
    only_late = "atrasad" in t

    late = [l for l in rows if l["deadline_at"] < today]
    upcoming = [l for l in rows if l["deadline_at"] >= today and (window is None or (l["deadline_at"] - today).days <= window)]
    after = [l for l in rows if l["deadline_at"] >= today and l not in upcoming]
    r.data = [{"subject": l["subject"], "title": l["title"], "kind": l["kind"],
               "deadline_at": br_date(l["deadline_at"]), "late": l["deadline_at"] < today} for l in rows]
    r.values = {"PENDING_COUNT": str(len(rows)), "LATE_COUNT": str(len(late)),
                "NEXT_COUNT": str(len(upcoming))}
    r.signals = {"has_late": bool(late), "has_expiring_soon": bool(upcoming),
                 "only_late_asked": only_late, "time_slice": cropped or "all"}
    r.filters = {"cropped": cropped or "all pending ones"}

    if not rows:
        r.draft = _with_name(r, profile, "Good news, [[NAME]]: ", "Good news: ") + \
            "you have no pending activities at the moment. Everything up to date!"
        return r

    def item(l):
        return f"• {l['title']}: {_when(l['deadline_at'], today)}\n  {l['subject']}"

    blocks, parts = [], []
    if late:
        blocks.append("\n".join(item(l) for l in late))
    show = [] if only_late and late else upcoming
    if show:
        blocks.append("\n".join(item(l) for l in show))
    r.details = "\n\n".join(blocks)

    opening = (_with_name(r, profile, "[[NAME]], you", "You") + " have [[PENDING_COUNT]] "
               + _pl(len(rows), "activity", "activities") + " to hand in.")
    if only_late and not late:
        parts.append("none is late, great")
    if late:
        parts.append("[[LATE_COUNT]] " + _pl(len(late), "is already past the deadline, so it is worth starting with it",
                                             "are already past the deadline, so it is worth starting with them"))
    if not only_late:
        if upcoming and cropped and len(upcoming) == len(rows):
            parts.append(_pl(len(upcoming), "it is due ", "all are due ") + cropped)
        elif upcoming:
            parts.append(f"[[NEXT_COUNT]] {_pl(len(upcoming), 'is due', 'are due')} {cropped}" if cropped else
                         ("the other one has" if len(upcoming) == 1 else "the others have") + " a deadline in the next few weeks"
                         if late else "none is late")
        elif cropped:
            parts.append(f"none is due {cropped}")
    summary = (" " + parts[0][0].upper() + parts[0][1:] + (", and " + parts[1] if len(parts) > 1 else "") + ".") \
        if parts else ""
    closing = ("If it helps, set aside a fixed time in the week for each one. When the deadline gets tight, talking to the "
               "teacher beforehand usually opens more doors than afterwards.")
    if after and window is not None and not only_late:
        r.values["AFTER_COUNT"] = str(len(after))
        closing = (f"After that, {_pl(len(after), 'there is still [[AFTER_COUNT]] activity', 'there are still [[AFTER_COUNT]] activities')} "
                   "with a later deadline. " + closing)
    if r.details:
        r.draft = f"{opening}{summary}\n\n[[DETAILS]]\n\n{closing}"
    else:
        r.draft = f"{opening}{summary}\n\n{closing}"
    return r


def _attendance_intent(chat_connection: Connection, student_id: str, question: str) -> Result:
    r = _subjects_intent(it.ATTENDANCE, chat_connection, student_id, question)
    if r.filters or not r.data:
        return r
    ind = chat_connection.execute(sql.STUDENT_INDICATORS, {"student_id": student_id}).mappings().first()
    if ind is not None:
        r.query = "STUDENT_SUBJECTS, STUDENT_INDICATORS"
        r.values["OVERALL_ATTENDANCE"] = _value(ind["attendance_pct"], "%")
        r.values["TOTAL_ABSENCES"] = _value(ind["total_absences"])
        r.draft = r.draft.replace(
            ":\n\n[[DETAILS]]", ". Overall, you have [[OVERALL_ATTENDANCE]] presence and [[TOTAL_ABSENCES]] "
            + _pl(ind["total_absences"] or 0, "absence", "absences") + ". See it by subject:\n\n[[DETAILS]]", 1)
        r.draft += ("\n\nI can't tell yet how many absences are left, because the system does not have the total of "
                    "expected classes.")
    return r


def _my_risk_intent(chat_connection: Connection, student_id: str) -> Result:
    row = chat_connection.execute(sql.STUDENT_RISK, {"student_id": student_id}).mappings().first()
    r = Result(intent=it.MY_RISK, draft="", query="STUDENT_RISK",
               records=0 if row is None else 1, shortcut=SHORTCUTS[it.MY_RISK], options=STUDENT_OPTIONS)
    if row is None or row["risk_level"] is None:
        r.draft = "There is no risk assessment recorded for you yet."
        return r
    level = row["risk_level"]
    r.reference = br_date(row["assessment_date"])
    r.data = [{"level": DATABASE_LEVEL.get(level, level), "assessment_date": r.reference,
               "academic_period": row["academic_period"]}]
    r.values = {"LEVEL": level, "DATE": r.reference or "date not recorded"}
    r.signals = {"high_level_or_critical": level in (HIGH_LEVEL, CRITICAL_LEVEL)}
    r.can_humanize = True
    profile = _student_profile(chat_connection, student_id)
    opening = _with_name(r, profile, "[[NAME]], in your", "In your")
    change = ""
    previous = (profile or {}).get("previous_level")
    if previous and previous != level:
        r.values["PREVIOUS_LEVEL"] = previous
        worsened = ORDER_LEVELS.index(level) < ORDER_LEVELS.index(previous)
        r.signals["level_in_previous_assessment_relation"] = "worsened" if worsened else "improved"
        change = (" In the previous assessment it was [[PREVIOUS_LEVEL]]" +
                  (", so it is worth looking carefully at what changed." if worsened else ". Great to see this improvement!"))
    factors = _factors_names((profile or {}).get("main_factors"))[:3]
    if factors:
        r.values["FACTORS"] = _readable_list(factors)
        explanation = ("The points that weighed the most were [[FACTORS]]. On the My indicators page you can see the "
                       "explanation of each one and what can help.")
    else:
        explanation = "The factors that weighed the most appear on the My indicators page, with an explanation of each one."
    support = ("This is not a judgment about you. It is a sign that extra support now can make a "
               "difference, and the pedagogical team follows these cases to help.\n\n"
               if level in (HIGH_LEVEL, CRITICAL_LEVEL) else "")
    r.draft = (f"{opening} last assessment, done on [[DATE]], the risk level was [[LEVEL]].{change}\n\n"
               f"{support}{explanation}")
    r.footer = METHODOLOGICAL_NOTICE
    return r


def _team_scope(user: User) -> tuple[str, dict] | None:
    if user.profile == TEACHER and user.id_professor:
        return "TEACHER", {"id_professor": user.id_professor}
    if user.profile in (COORDINATION, SUPPORT_CENTER) and user.course_id:
        return "COURSE", {"course_id": user.course_id}
    return None


def _risk_summary_intent(chat_connection: Connection, user: User) -> Result:
    scope = _team_scope(user)
    if scope is None:
        return _without_permission(it.RISK_SUMMARY, "Your user is not linked to classes or to a course.")
    kind, params = scope
    query = sql.TEACHER_RISK_SUMMARY if kind == "TEACHER" else sql.COURSE_RISK_SUMMARY
    rows = _rows(chat_connection, query, params)
    if user.profile == SUPPORT_CENTER:
        rows = [l for l in rows if l["risk_level"] in (CRITICAL_LEVEL, HIGH_LEVEL)]
    by_level = {l["risk_level"]: int(l["total"]) for l in rows if l["risk_level"]}
    r = Result(intent=it.RISK_SUMMARY, draft="", records=sum(by_level.values()),
               query="TEACHER_RISK_SUMMARY" if kind == "TEACHER" else "COURSE_RISK_SUMMARY",
               filters={"scope": "your classes" if kind == "TEACHER" else "your course"},
               shortcut=SHORTCUTS[it.RISK_SUMMARY], options=TEAM_OPTIONS)
    if not by_level:
        r.draft = "There are no risk assessments recorded in your scope."
        return r
    r.data = [{"level": DATABASE_LEVEL.get(n, n), "total": by_level[n]} for n in ORDER_LEVELS if n in by_level]
    r.details = "\n".join(f"• {n}: {by_level[n]} {_pl(by_level[n], 'student', 'students')}" for n in ORDER_LEVELS
                          if n in by_level)
    r.values = {"TOTAL": str(r.records)}
    r.signals = {"has_critical_students": CRITICAL_LEVEL in by_level}
    r.can_humanize = True
    r.draft = (f"This is the risk picture of {r.filters['scope']}, from the last assessment of each student "
               f"([[TOTAL]] {_pl(r.records, 'student', 'students')} in total):\n\n[[DETAILS]]")
    if CRITICAL_LEVEL in by_level:
        r.draft += "\n\nCritical cases appear first in the dashboard alerts."
    r.footer = METHODOLOGICAL_NOTICE
    return r


def _highest_risk_intent(chat_connection: Connection, user: User, intent: str) -> Result:
    scope = _team_scope(user)
    if scope is None:
        return _without_permission(intent, "Your user is not linked to classes or to a course.")
    kind, params = scope
    query = sql.TEACHER_LARGEST_RISK if kind == "TEACHER" else sql.COURSE_LARGEST_RISK
    rows = _rows(chat_connection, query, {**params, "critical": CRITICAL_LEVEL, "high": HIGH_LEVEL,
                                          "limit": sql.RISK_LIST_LIMIT})
    r = Result(intent=intent, draft="", records=len(rows),
               query="TEACHER_LARGEST_RISK" if kind == "TEACHER" else "COURSE_LARGEST_RISK",
               filters={"scope": "your classes" if kind == "TEACHER" else "your course",
                        "level": ["CRITICAL", "HIGH"], "limit": sql.RISK_LIST_LIMIT},
               shortcut=SHORTCUTS[it.HIGHEST_RISK], options=TEAM_OPTIONS)
    prefix = ""
    if intent == it.INDIVIDUAL_FORECAST:
        prefix = ("The system does not predict who will give up: it points out patterns of indicators similar to the ones "
                  "that usually come before dropout. With that caveat, these are the students with the highest current risk.\n\n")
    if not rows:
        r.draft = prefix + f"There are no students with High or Critical risk in {r.filters['scope']}."
        return r
    r.reference = br_date(max(str(l["assessment_date"]) for l in rows))
    r.data = [{"enrollment": l["student_id"], "name": l["fictitious_name"], "semester": l["current_semester"],
               "level": DATABASE_LEVEL.get(l["risk_level"], l["risk_level"]),
               "assessment_date": br_date(l["assessment_date"])} for l in rows]
    r.details = "\n".join(f"• {l['fictitious_name']} ({l['student_id']}): {l['risk_level']}\n"
                          f"  semester {_value(l['current_semester'])}" for l in rows)
    r.values = {"COUNT": str(len(rows))}
    r.can_humanize = True
    r.draft = (prefix + f"I found [[COUNT]] {_pl(len(rows), 'student', 'students')} with Critical or High risk in {r.filters['scope']}, "
               f"starting with the critical ones (I show up to {sql.RISK_LIST_LIMIT}):\n\n[[DETAILS]]\n\n"
               "To see the details and record an action, open each student's record in the dashboard.")
    r.footer = METHODOLOGICAL_NOTICE
    return r


def _search_intent(chat_connection: Connection, user: User, question: str) -> Result:
    scope = _team_scope(user)
    options = SSC_OPTIONS if user.profile == SUPPORT_CENTER else TEAM_OPTIONS
    if scope is None:
        return _without_permission(it.STUDENT_SEARCH, "Your user is not linked to classes or to a course.")
    kind, params = scope
    search = interpret(question)
    notices = []
    if any(f.field == "distance" for f in search.filters) and user.profile != SUPPORT_CENTER:
        search.filters = [f for f in search.filters if f.field != "distance"]
        notices.append("Home distance is socioeconomic data that only the support center looks up, so "
                       "I left that filter out.")
    if search.discarded:
        notices.append("I ignored the value for " + _readable_list(search.discarded) + " because it was outside the scale "
                       "(attendance goes from 0 to 100% and average from 0 to 10).")
    levels = list(search.levels)
    if user.profile == SUPPORT_CENTER:
        levels = [n for n in (levels or [CRITICAL_LEVEL, HIGH_LEVEL]) if n in (CRITICAL_LEVEL, HIGH_LEVEL)]
        if not levels:
            levels = [CRITICAL_LEVEL, HIGH_LEVEL]
    r = Result(intent=it.STUDENT_SEARCH, draft="", query="STUDENT_SEARCH", options=options,
               shortcut=SHORTCUTS[it.HIGHEST_RISK], can_humanize=True)
    descriptions = [describe(f) for f in search.filters]
    if search.levels:
        descriptions.append("risk " + _readable_list(search.levels).replace(" and ", " or "))
    if search.average_dropped:
        descriptions.append("falling average")
    r.filters = {"scope": "in your classes" if kind == "TEACHER" else "in your course", "criteria": descriptions,
                 "fields": [f.field for f in search.filters]}
    if not descriptions and notices:
        r.draft = " ".join(notices) + ("\n\nI can search by attendance, average, absences, pending activities, "
                                       "semester and risk level. For example: \"students with attendance below "
                                       "70% and average below 5\".")
        r.can_humanize = False
        return r
    if not descriptions:
        r.draft = ("I couldn't understand the search filter. You can write, for example: \"students with "
                   "attendance below 70% and average below 5\"." + ("\n\n" + " ".join(notices) if notices else ""))
        r.can_humanize = False
        return r

    with_distance = user.profile == SUPPORT_CENTER
    all_items = sql.search_parameters(search.filters, levels, search.average_dropped, with_distance,
                                      id_professor=params.get("id_professor"), course_id=params.get("course_id"))
    rows = _rows(chat_connection, sql.STUDENT_SEARCH, {**all_items, "limit": sql.SEARCH_LIMIT})
    account = chat_connection.execute(sql.STUDENT_SEARCH_COUNT, all_items).mappings().first()
    total = int(account["total"]) if account else 0
    r.records = total
    housing = [d for d in descriptions if d.startswith(("living", "in semester", "after semester", "from semester", "before semester", "up to semester"))]
    others = [d for d in descriptions if d not in housing]
    criteria = ", ".join(housing + (["with " + _readable_list(others)] if others else []))
    r.values = {"COUNT": str(total), "SHOWN": str(len(rows)), "CRITERIA": criteria}
    r.signals = {"students_found": total > 0, "cut_list": total > len(rows),
                 "approximate_value_used": any(f.approximate for f in search.filters)}
    txt_scope = r.filters["scope"]
    if not total:
        r.draft = (f"I searched for students {txt_scope} [[CRITERIA]] and found no one. If you want, "
                   "I can try with a slightly broader criterion.")
        if notices:
            r.draft += "\n\n" + " ".join(notices)
        return r

    fields = [f.field for f in search.filters]

    def main(l) -> str:
        values = []
        mapping = {"attendance": ("attendance", l["attendance_pct"], "%"), "average": ("average", l["current_average"], ""),
                   "absences": ("absences", l["total_absences"], ""), "pending_items": ("pending items", l["pending_activities"], ""),
                   "semester": ("semester", l["current_semester"], ""), "distance": ("", l["distance_km"], " km")}
        order = fields + [c for c in ("attendance", "average") if c not in fields]
        for c in order[:3]:
            name, v, un = mapping[c]
            values.append((f"{name} " if name else "") + _value(v, un))
        return " · ".join(values)

    r.data = [{"enrollment": l["student_id"], "name": l["fictitious_name"], "level": DATABASE_LEVEL.get(l["risk_level"]),
               "attendance_pct": br_number(l["attendance_pct"]), "current_average": br_number(l["current_average"]),
               "total_absences": l["total_absences"], "pending_activities": l["pending_activities"],
               "semester": l["current_semester"],
               **({"distance_km": br_number(l["distance_km"])} if with_distance else {})} for l in rows]
    r.details = "\n".join(f"• {l['fictitious_name']} ({l['student_id']}): {main(l)}\n"
                          f"  risk {l['risk_level'] or 'not assessed'}"
                          + ("" if "semester" in fields else f" · semester {_value(l['current_semester'])}")
                          for l in rows)
    cutoff = (f" I show the [[SHOWN]] that need the most attention first (highest risk and lowest attendance)."
              if total > len(rows) else "")
    critical = int(account["critical"] or 0)
    analysis = []
    if critical and user.profile != SUPPORT_CENTER:
        r.values["CRITICAL_COUNT"] = str(critical)
        analysis.append(f"Of these, [[CRITICAL_COUNT]] {_pl(critical, 'is', 'are')} at Critical risk, so I "
                        f"would start {_pl(critical, 'with that one', 'with them')}.")
    if any(f.approximate for f in search.filters):
        analysis.append("For \"close to\", I considered a small margin up and down.")
    analysis.extend(notices)
    analysis.append("To see the factors and record an action, open each student's record in the dashboard.")
    r.draft = (f"I found [[COUNT]] {_pl(total, 'student', 'students')} {txt_scope} [[CRITERIA]].{cutoff}"
               "\n\n[[DETAILS]]\n\n" + " ".join(analysis))
    return r


def _specific_student_intent(request: Request, api_connection: Connection, chat_connection: Connection,
                             user: User, enrollment: str) -> Result:
    try:
        check_student_scope(request, api_connection, user, enrollment, "CHAT_READ_STUDENT")
    except HTTPException:
        r = _without_permission(it.SPECIFIC_STUDENT, "You do not have permission to access this student's data, "
                                                "or the student does not exist.")
        r.target_student_id = enrollment
        return r
    risk = chat_connection.execute(sql.STUDENT_RISK, {"student_id": enrollment}).mappings().first()
    ind = chat_connection.execute(sql.STUDENT_INDICATORS, {"student_id": enrollment}).mappings().first()
    r = Result(intent=it.SPECIFIC_STUDENT, draft="", query="STUDENT_RISK, STUDENT_INDICATORS",
               records=int(risk is not None) + int(ind is not None), target_student_id=enrollment,
               shortcut=SHORTCUTS[it.SPECIFIC_STUDENT].format(enrollment=enrollment), options=TEAM_OPTIONS,
               filters={"enrollment": enrollment})
    if risk is None and ind is None:
        r.draft = "There are no indicators or risk assessment recorded for this student."
        return r
    name = risk["fictitious_name"] if risk else enrollment
    parts = []
    if risk is not None and risk["risk_level"]:
        r.values["LEVEL"] = risk["risk_level"]
        r.values["DATE"] = br_date(risk["assessment_date"]) or "date not recorded"
        r.reference = r.values["DATE"]
        parts.append(f"• Risk level: {r.values['LEVEL']}\n  assessment of {r.values['DATE']}")
    if ind is not None:
        r.values.update({"ATTENDANCE": _value(ind["attendance_pct"], "%"), "ABSENCES": _value(ind["total_absences"]),
                         "AVERAGE": _value(ind["current_average"]), "PENDING": _value(ind["pending_activities"])})
        v = r.values
        parts.append(f"• Attendance in {ind['academic_period']}: {v['ATTENDANCE']}\n  {v['ABSENCES']} {_pl(ind['total_absences'] or 0, 'absence', 'absences')}")
        parts.append(f"• Current average: {v['AVERAGE']}\n  scale from {GENERAL_AVERAGE_SCALE}")
        parts.append(f"• Pending activities: {v['PENDING']}")
    r.values["STUDENT"] = f"{name} ({enrollment})"
    r.data = [{"enrollment": enrollment, "name": name,
               "level": DATABASE_LEVEL.get(risk["risk_level"], risk["risk_level"]) if risk else None,
               "indicators": None if ind is None else
               {k: (br_number(v) if k != "academic_period" else v) for k, v in dict(ind).items()}}]
    r.signals = {"high_level_or_critical": bool(risk and risk["risk_level"] in (HIGH_LEVEL, CRITICAL_LEVEL))}
    r.can_humanize = True
    profile = _student_profile(chat_connection, enrollment)
    if profile and profile.get("previous_level") and risk is not None and profile["previous_level"] != risk["risk_level"]:
        parts[0] += f" · before {profile['previous_level']}"
    factors = main_visible(user.profile, (profile or {}).get("main_factors"))
    if factors:
        parts.append("• Factors that weighed the most: " + _readable_list([FACTOR_LABELS.get(f, f) for f in factors[:3]]))
    pending = _rows(chat_connection, sql.STUDENT_PENDING_ACTIVITIES, {"student_id": enrollment, "limit": sql.ROWS_LIMIT})
    late = [l for l in pending if l["deadline_at"] < date.today()]
    if late:
        parts = [p if not p.startswith("• Pending activities") else
                 p + f"\n  {len(late)} {_pl(len(late), 'already late', 'already late')}" for p in parts]
    r.details = "\n".join(parts)
    r.draft = "This is the summary of [[STUDENT]]:\n\n[[DETAILS]]"
    if r.signals["high_level_or_critical"]:
        r.draft += "\n\nIn the student's record you can see the factors that weighed the most and record an action."
    r.footer = METHODOLOGICAL_NOTICE
    return r


def run(intent: str, enrollments: list[str], question: str, user: User, request: Request,
        api_connection: Connection, chat_connection: Connection) -> Result:
    fixed = _fixed(intent, user)
    if fixed is not None:
        return fixed

    if user.profile == STUDENT:
        student_id = user.student_id
        if not student_id:
            return _without_permission(intent, "Your user is not linked to a student ID.")
        if intent == it.INDIVIDUAL_FORECAST:
            return Result(intent=intent, options=STUDENT_OPTIONS, draft=(
                "The system does not predict anyone's future. It only compares indicators, such as attendance and grades, "
                "with patterns that usually come before dropout. I can show your current risk level."))
        if intent in (it.GRADES, it.STATUS, it.ACADEMIC_SUMMARY):
            return _subjects_intent(intent, chat_connection, student_id, question)
        if intent == it.ATTENDANCE:
            return _attendance_intent(chat_connection, student_id, question)
        if intent == it.PENDING_ITEMS:
            return _activities_intent(chat_connection, student_id, question)
        if intent == it.AVERAGE:
            return _indicators_intent(intent, chat_connection, student_id)
        if intent == it.MY_RISK:
            return _my_risk_intent(chat_connection, student_id)
        return _fixed(it.NOT_UNDERSTOOD, user)

    if user.profile in TEAM_PROFILES:
        if intent == it.SPECIFIC_STUDENT and enrollments:
            return _specific_student_intent(request, api_connection, chat_connection, user, enrollments[0])
        if intent == it.STUDENT_SEARCH:
            return _search_intent(chat_connection, user, question)
        if intent == it.RISK_SUMMARY:
            return _risk_summary_intent(chat_connection, user)
        if intent in (it.HIGHEST_RISK, it.INDIVIDUAL_FORECAST):
            return _highest_risk_intent(chat_connection, user, intent)
        if intent in it.STUDENT_INTENTS:
            return Result(intent=intent, options=TEAM_OPTIONS, draft=(
                "To see a student's status, give their student ID in the question."))
        return _fixed(it.NOT_UNDERSTOOD, user)

    return _without_permission(intent, "Your profile does not look up student data through the chat. Use the aggregated "
                                    "reports in the dashboard.")
