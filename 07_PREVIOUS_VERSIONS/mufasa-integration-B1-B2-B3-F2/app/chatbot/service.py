"""
Runs the classified intent and builds the result with the REAL data.

Flow of each data intent:
1. Checks whether the profile can use the intent (server, never the text).
2. Picks ONE query from chat_queries.py and fills in the parameters with
   the logged-in user's scope (the student only queries their own student_id).
3. Builds three things:
   - data:      the structured list the dashboard shows (database values);
   - draft:     the default text, with [[...]] markers in place of the values;
   - signals:   qualitative information, with no numbers and no identification,
                that the AI can use to make the text more welcoming.
4. If the query returns nothing, the answer says there is no data.
   No value is completed, estimated or made up (Annex E.2).
"""

from dataclasses import dataclass, field

from fastapi import HTTPException, Request
from sqlalchemy.engine import Connection

from app.api.auth import User
from app.api.schemas import METHODOLOGICAL_NOTICE
from app.api.integration import DATABASE_LEVEL
from app.api.permissions import (STUDENT, COORDINATION, TEACHER, SUPPORT_CENTER, check_student_scope)
from app.chatbot import chat_queries as sql
from app.chatbot import intents as it
from app.chatbot.config_chat import get_chat_configuration
from app.chatbot.text import br_date, normalize, br_number

# Audit 4.5-D: B1 stores subject grades from 0 to 100 and the average
# of the indicators from 0 to 10. The chatbot shows each value as it is in the database
# and states the scale, without converting.
SUBJECT_GRADES_SCALE = "0 to 100"
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

STUDENT_OPTIONS = ["My grades", "My attendance", "My risk level", "Talk to a person"]
TEAM_OPTIONS = ["Risk summary", "Highest-risk students", "How the risk is calculated"]

_EMPTY_WORDS = {"de", "da", "do", "", "", "e", "em", "a", "o", "as", "os", "for_value", "with_values", "ao"}
_ROMAN = {"i": "1", "ii": "2", "iii": "3", "iv": "4", "v": "5", "vi": "6"}


@dataclass
class Result:
    intent: str
    draft: str
    footer: str = ""  # mandatory text (methodological notice, RN05) that the AI does not rewrite
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
    target_student_id: str | None = None


# ---------------------------------------------------------------------------
# Fixed texts: refusals and informational answers do not go through the AI.
# ---------------------------------------------------------------------------

def _window() -> str:
    return get_chat_configuration().chat_service_window


def opening_text() -> str:
    return ("Hi! I am Mufa, the MUFASA assistant. I can show your grades, your attendance and "
            "your risk level, always with the data recorded in the system. I am available 24 hours a day; "
            f"support with a person from the staff happens {_window()}. "
            "Do not write passwords, CPF or health information here.")


def _fixed(intent: str, user: User) -> Result | None:
    is_student = user.profile == STUDENT
    options = STUDENT_OPTIONS if is_student else TEAM_OPTIONS
    texts = {
        it.BYPASS: ("I can't do that. I always follow the same security rules and only show the data "
                   "your profile can see. This attempt was recorded. Can I help with your grades, "
                   "attendance or risk level?"),
        it.CHANGE: ("I only look up information; I do not change grades, absences or records. To ask for a "
                       "correction, go to the registrar's office. If it is your own personal data, you can also "
                       "ask for the correction on the Privacy page of the dashboard."),
        it.OTHER_STUDENT: ("I'm not allowed to show information about other students. "
                         "I can show yours, if you want."),
        it.JUDGMENT: ("I don't judge people. The system only describes indicators, such as grades and "
                   "attendance, and says nothing about anyone's effort or ability."),
        it.METHODOLOGY: ("The risk level is calculated from recorded indicators, such as attendance, "
                         "grades and some context factors, each one with a weight set by the team. "
                         "Factors without data are left out of the calculation, instead of being filled in. " + METHODOLOGICAL_NOTICE),
        it.SERVICE: ("I can record your question here at any time, but service with a person from the "
                         f"staff happens {_window()}. If you are going through a hard time, "
                         "go to the university's support center. In an emergency, call CVV "
                         "at 188 (24 hours, free) or SAMU at 192."),
        it.PRIVACY: ("On the Privacy page of the dashboard you can see all the data MUFASA keeps about "
                         "you, export it and ask for correction, deletion or review of an automated "
                         "decision (LGPD, arts. 18 and 20). The answer arrives within 15 days."),
        it.ACCESS: ("For security, never type your password in the chat. If you forgot your password or your access was "
                    "blocked after wrong attempts, wait 15 minutes or contact the academic registrar's office "
                    "to reset it."),
        it.GREETING: opening_text(),
        it.THANKS: "You're welcome! If you need anything else, just ask.",
        it.HELP: ("You can ask me, for example: \"what are my grades?\", \"how is my "
                   "attendance in Calculus I?\" or \"what is my risk level?\"." if is_student else
                   "You can ask me, for example: \"how many students are at high risk?\", "
                   "\"which students have the highest risk?\" or a student's status by student ID."),
        it.OUT_OF_SCOPE: ("That topic is outside what I can do. I help with grades, attendance, risk "
                            "and with using MUFASA."),
        it.NOT_UNDERSTOOD: ("I did not quite understand the question. You can rephrase it or choose one of the options below."),
    }
    if intent not in texts:
        return None
    r = Result(intent=intent, draft=texts[intent], options=options)
    r.refusal = intent in it.REFUSALS
    r.bypass_attempt = intent == it.BYPASS
    if intent == it.PRIVACY:
        r.shortcut = SHORTCUTS[it.PRIVACY]
    return r


def _without_permission(intent: str, message: str) -> Result:
    return Result(intent=intent, draft=message, refusal=True)


# ---------------------------------------------------------------------------
# Subjects mentioned in the question
# ---------------------------------------------------------------------------

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


# ---------------------------------------------------------------------------
# Student intents
# ---------------------------------------------------------------------------

def _rows(connection: Connection, query, params: dict) -> list[dict]:
    return [dict(l) for l in connection.execute(query, params).mappings().all()]


def _student_subjects(chat_connection: Connection, student_id: str, question: str):
    """Returns (filtered rows, filter applied, subject mentioned without enrollment)."""
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
            row = f"• {l['subject']}: attendance {_value(l['attendance_pct'], '%')}"
            if l["minimum_attendance_pct"] is not None:
                row += f" (minimum {_value(l['minimum_attendance_pct'], '%')})"
        elif intent == it.STATUS:
            row = f"• {l['subject']}: {_text_status(l['status'])}"
        else:
            row = (f"• {l['subject']}: VA1 {_value(l['exam1'])}, VA2 {_value(l['exam2'])}, "
                     f"VA3 {_value(l['exam3'])}, final grade {_value(l['final_grade'])}"
                     f" ({_text_status(l['status'])})")
            if intent == it.ACADEMIC_SUMMARY:
                row += f", attendance {_value(l['attendance_pct'], '%')}"
        details.append(row)

    r.details = "\n".join(details)
    failed = sum(1 for d in r.data if str(d["status"]).lower().startswith("reprov"))
    below = sum(1 for d in r.data if d["minimum_attendance_below"])
    r.values = {"SUBJECTS_COUNT": str(len(rows)), "FAILED_COUNT": str(failed),
                 "BELOW_MINIMUM_COUNT": str(below)}
    r.signals = {"has_registered_failure": failed > 0, "has_minimum_below_attendance": below > 0,
                "one_subject_query": bool(filter_value)}

    if intent == it.ATTENDANCE:
        opening = "This is your recorded attendance"
        if below:
            closing = ("Attention: in [[BELOW_MINIMUM_COUNT]] subject(s) attendance is below the required minimum. "
                     "It is worth talking to the teacher or the coordination as soon as possible.")
        else:
            closing = "All of them are within the required minimum. Keep following along here!"
    elif intent == it.STATUS:
        opening = "This is the recorded status of your subjects"
        closing = ("In [[FAILED_COUNT]] subject(s) the recorded status is failing. If you want, the support "
                 "center can help put together a study plan." if failed else
                 "No failures recorded. Good job!")
    else:
        opening = "These are your recorded grades" if intent != it.ACADEMIC_SUMMARY else \
            "This is the summary of your recorded performance"
        closing = (f"Subject grades are on the scale of {SUBJECT_GRADES_SCALE}, as they are in the academic "
                 "system.")
        if failed:
            closing += (" In [[FAILED_COUNT]] subject(s) the status is failing; the support center can "
                      "help put together a study plan.")
    period = f" in the term {r.reference}" if r.reference else ""
    r.draft = f"{opening}{period}:\n[[DETAILS]]\n{closing}"
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
            meaning, closing = "went_up", " Your average went up compared with last term. Great!"
        elif float(trend) < 0:
            meaning, closing = "dropped", (" Your average dropped compared with last term; the support center "
                                      "can help understand what changed.")
        else:
            meaning, closing = "stable_or_without_data", " Your average stayed the same as last term."
        r.signals = {"average_trend": meaning}
        r.draft = (f"In the term {r.reference}, your current average is [[CURRENT_AVERAGE]] and last term's "
                      f"was [[PREVIOUS_AVERAGE]] (scale of {GENERAL_AVERAGE_SCALE}).{closing}")
    else:  # PENDING ITEMS
        r.values = {"PENDING": _value(ind["pending_activities"])}
        pending = ind["pending_activities"]
        r.signals = {"has_pending_items": bool(pending)}
        r.draft = (f"In the term {r.reference}, you have [[PENDING]] pending activit(ies) recorded."
                      + (" How about setting up a schedule to catch up on them?" if pending else
                         " All caught up!"))
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
            ":\n[[DETAILS]]", ". Overall, your attendance is [[OVERALL_ATTENDANCE]], with [[TOTAL_ABSENCES]] absence(s):\n[[DETAILS]]", 1)
        r.draft += (" The number of remaining absences does not show because the system does not have the total number of classes "
                       "expected.")
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
    support = (" The teaching staff already follows cases like this and may get in touch to help."
             if level in (HIGH_LEVEL, CRITICAL_LEVEL) else "")
    r.draft = (f"In the assessment of [[DATE]], your risk level was [[LEVEL]].{support} The factors that most "
                  "weighed the most show on the dashboard.")
    r.footer = METHODOLOGICAL_NOTICE
    return r


# ---------------------------------------------------------------------------
# Staff intents
# ---------------------------------------------------------------------------

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
    if user.profile == SUPPORT_CENTER:  # the support center sees only students with an alert (Annex E)
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
    r.details = "\n".join(f"• {n}: {by_level[n]} student(s)" for n in ORDER_LEVELS if n in by_level)
    r.values = {"TOTAL": str(r.records)}
    r.signals = {"has_critical_students": CRITICAL_LEVEL in by_level}
    r.can_humanize = True
    r.draft = (f"Distribution by the last assessment of each student in {r.filters['scope']} "
                  "([[TOTAL]] student(s) considered):\n[[DETAILS]]")
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
                   "that usually come before dropping out. With that caveat, these are the students with the highest current risk. ")
    if not rows:
        r.draft = prefix + f"There are no students with High or Critical risk in {r.filters['scope']}."
        return r
    r.reference = br_date(max(str(l["assessment_date"]) for l in rows))
    r.data = [{"enrollment": l["student_id"], "name": l["fictitious_name"], "semester": l["current_semester"],
                "level": DATABASE_LEVEL.get(l["risk_level"], l["risk_level"]),
                "assessment_date": br_date(l["assessment_date"])} for l in rows]
    r.details = "\n".join(f"• {l['fictitious_name']} ({l['student_id']}), semester {_value(l['current_semester'])}: "
                           f"{l['risk_level']}" for l in rows)
    r.values = {"COUNT": str(len(rows))}
    r.can_humanize = True
    r.draft = (prefix + f"Students with Critical or High risk in {r.filters['scope']}, Critical first "
                  f"(up to {sql.RISK_LIST_LIMIT}, [[COUNT]] found):\n[[DETAILS]]")
    r.footer = METHODOLOGICAL_NOTICE
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
        parts.append("• Risk level: [[LEVEL]] (assessment of [[DATE]])")
    if ind is not None:
        r.values.update({"ATTENDANCE": _value(ind["attendance_pct"], "%"), "ABSENCES": _value(ind["total_absences"]),
                          "AVERAGE": _value(ind["current_average"]), "PENDING": _value(ind["pending_activities"])})
        parts.append(f"• Term {ind['academic_period']}: attendance [[ATTENDANCE]], [[ABSENCES]] absence(s), average "
                      f"[[AVERAGE]] (scale of {GENERAL_AVERAGE_SCALE}), [[PENDING]] pending activit(ies)")
    r.values["STUDENT"] = f"{name} ({enrollment})"
    r.data = [{"enrollment": enrollment, "name": name,
                "level": DATABASE_LEVEL.get(risk["risk_level"], risk["risk_level"]) if risk else None,
                "indicators": None if ind is None else
                {k: (br_number(v) if k != "academic_period" else v) for k, v in dict(ind).items()}}]
    r.signals = {"high_level_or_critical": bool(risk and risk["risk_level"] in (HIGH_LEVEL, CRITICAL_LEVEL))}
    r.can_humanize = True
    r.draft = "Recorded status of [[STUDENT]]:\n" + "\n".join(parts)
    r.footer = METHODOLOGICAL_NOTICE
    return r


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

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
        if intent in (it.AVERAGE, it.PENDING_ITEMS):
            return _indicators_intent(intent, chat_connection, student_id)
        if intent == it.MY_RISK:
            return _my_risk_intent(chat_connection, student_id)
        return _fixed(it.NOT_UNDERSTOOD, user)

    if user.profile in TEAM_PROFILES:
        if intent == it.SPECIFIC_STUDENT and enrollments:
            return _specific_student_intent(request, api_connection, chat_connection, user, enrollments[0])
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
