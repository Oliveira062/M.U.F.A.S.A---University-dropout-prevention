"""
CLOSED catalog of chatbot intents (RN06, Annex D.2 and E.2).

The question is classified into one of these intents by fixed rules. If the
rules do not recognize it and the AI is on, the AI can suggest an intent,
but only from the INTENTS_THE_AI_CAN_SUGGEST list, and the server checks it.
The AI never decides scope, never picks a query and never lifts a refusal.

Check order: first the refusals (bypass, change, another student,
judgment), then the data queries, last the informational ones.
"""

import re
from dataclasses import dataclass, field

from app.chatbot.text import cited_enrollments, normalize

# Mandatory refusals (E.2)
BYPASS = "BYPASS_ATTEMPT"
CHANGE = "CHANGE_REQUEST"
OTHER_STUDENT = "OTHER_STUDENT_DATA"
JUDGMENT = "JUDGMENT_ABOUT_PERSON"
INDIVIDUAL_FORECAST = "WHO_WILL_GIVE_UP"

# Student's own data
ACADEMIC_SUMMARY = "ACADEMIC_SUMMARY"
GRADES = "GRADES"
ATTENDANCE = "ATTENDANCE_AND_ABSENCES"
AVERAGE = "AVERAGE"
STATUS = "STATUS_IN_SUBJECTS"
PENDING_ITEMS = "PENDING_ACTIVITIES"
MY_RISK = "MY_RISK_LEVEL"

# Staff (teacher, coordination, support center)
RISK_SUMMARY = "RISK_SUMMARY"
HIGHEST_RISK = "HIGHEST_RISK_STUDENTS"
SPECIFIC_STUDENT = "STATUS_OF_ONE_STUDENT"

# Informational
GREETING = "GREETING"
THANKS = "THANKS"
HELP = "HELP"
METHODOLOGY = "METHODOLOGY"
SERVICE = "HUMAN_SERVICE"
PRIVACY = "PRIVACY"
ACCESS = "ACCESS_AND_PASSWORD"
OUT_OF_SCOPE = "OUT_OF_SCOPE"
NOT_UNDERSTOOD = "NOT_UNDERSTOOD"

REFUSALS = {BYPASS, CHANGE, OTHER_STUDENT, JUDGMENT}
STUDENT_INTENTS = {ACADEMIC_SUMMARY, GRADES, ATTENDANCE, AVERAGE, STATUS, PENDING_ITEMS, MY_RISK}
TEAM_INTENTS = {RISK_SUMMARY, HIGHEST_RISK, SPECIFIC_STUDENT}

INTENTS_THE_AI_CAN_SUGGEST = (
    STUDENT_INTENTS | TEAM_INTENTS
    | {GREETING, THANKS, HELP, METHODOLOGY, SERVICE, PRIVACY, ACCESS, OUT_OF_SCOPE}
)


def _re(*terms: str) -> re.Pattern:
    return re.compile(r"\b(?:" + "|".join(terms) + r")")


# Everything here is compared with the normalized text (lowercase, no accents).
_BYPASS = _re(
    r"ignor\w*\s+(?:\w+\s+){0,3}(?:rule|instruction|restriction|limit|order|command)",
    r"forget\w*\s+(?:\w+\s+){0,3}(?:rule|instruction|restriction)", r"disregard\w*\s+(?:\w+\s+){0,3}rule",
    r"pretend\w*", r"act as", r"act like", r"behave as", r"play the role", r"make believe",
    r"you are now", r"from now on you", r"(?:developer|dev|god|admin|unrestricted) mode",
    r"jailbreak", r"dan\b", r"without (?:restriction|filter|rule|limit)", r"no (?:restrictions|filters|rules|limits)",
    r"system prompt", r"your (?:instructions|internal rules)",
    r"reveal\w* (?:\w+\s+){0,3}(?:prompt|instruction|code|rule|password|key)", r"source code",
    r"password (?:of|for) (?:the )?(?:admin|administrator|system|database|teacher|coordinator|other)", r"api key",
    r"\bsql\b", r"select\s+(?:\w+\s+)?from",
    r"drop\s+table", r"union\s+select", r"i (?:am|m) (?:the |an? )?(?:admin|administrator|coordinator|teacher|director)",
    r"my profile is (?:admin|administrator|coordination|teacher)", r"base64",
)

_CHANGE_VERB = _re(
    r"change", r"alter\b", r"modify", r"edit", r"fix", r"correct\b", r"update", r"delete", r"erase", r"remove",
    r"increase", r"decrease", r"reset", r"waive", r"excuse", r"post (?:a|my|the)", r"register", r"swap\b",
)
_CHANGE_OBJECT = _re(r"grade", r"absence", r"attendance", r"presence", r"registration", r"data", r"average",
                     r"score", r"risk", r"enrollment", r"history", r"status", r"record")

_OTHER_PERSON = _re(
    r"classmate", r"other students?", r"another student", r"of everyone", r"of the class", r"my classmates",
    r"my friend", r"boyfriend", r"girlfriend", r"ranking", r"list of students", r"who got",
    r"who has the highest", r"who has the lowest", r"grade of (?:so and so|someone else|john doe)",
    r"data of (?:so and so|someone else|other)",
)
_JUDGMENT = _re(r"lazy", r"slacker", r"stupid", r"dumb", r"incompetent", r"irresponsible",
                r"(?:does not|doesn ?t) (?:try|make an effort)", r"uninterested", r"(?:his|her|their) fault")
_FORECAST = _re(r"who (?:will|is going to) (?:give up|drop out|quit|abandon|leave|lock)",
                r"(?:will|going to) (?:give up|drop out|quit|abandon|lock)")

_METHODOLOGY = _re(r"how (?:is|was) (?:it )?calculated", r"how do (?:you )?calculate",
                   r"how does the (?:risk|score|level|calculation) work",
                   r"methodology", r"what does (?:the |my )?(?:risk|score|level|alert) mean",
                   r"where does it come from", r"why am i (?:at|in|on|with) (?:risk|alert)")
_SERVICE = _re(r"talk to (?:someone|a person|a human|an attendant|the registrar|the support center|a psycholog)",
               r"attendant", r"human service", r"\bhuman\b", r"psycholog", r"emotional support", r"support center",
               r"i need help", r"i feel (?:bad|awful|terrible)", r"anxi", r"depress")
_PRIVACY = _re(r"lgpd", r"privacy", r"my personal data", r"what data", r"what do you (?:keep|store)",
               r"export my data", r"consent")

_ACCESS = _re(r"password", r"login", r"(?:can ?t|cannot) (?:log|sign) in", r"access blocked", r"blocked")

_RISK = _re(r"risk", r"dropout", r"drop out", r"score", r"alert", r"level of")
_ATTENDANCE = _re(r"attendance", r"presence", r"absence", r"absent", r"missed", r"miss\b", r"missing")
_GRADES = _re(r"grade", r"exam ?[123]\b", r"exam", r"assessment", r"report card", r"i got")
_AVERAGE = _re(r"average", r"coefficient", r"\bgpa\b", r"performance")
_STATUS = _re(r"approved", r"passed", r"failed", r"did i pass", r"will i pass", r"status", r"retake", r"\bdp\b")
_PENDING_ITEMS = _re(r"pending", r"activit", r"deliverable", r"assignment", r"task")
_SUMMARY = _re(r"how (?:am i|is my|are my|s my)", r"my performance", r"my overall situation",
               r"summary", r"panorama", r"overview", r"how (?:is|are) my")

_RISK_SUMMARY = _re(r"how many", r"distribution", r"summary", r"panorama", r"overview", r"total")
_RISK_LIST = _re(r"which students", r"what students", r"\blist\b", r"highest risk", r"most risk", r"critic",
                 r"high risk", r"at risk", r"priority", r"queue")

_GREETING = _re(r"hi\b", r"hello\b", r"good morning", r"good afternoon", r"good evening", r"what s up", r"hey",
                r"howdy", r"yo\b")
_THANKS = _re(r"thank", r"thx", r"appreciate", r"cheers")
_HELP = _re(r"menu", r"help", r"what (?:do you do|can you do|do you know)", r"options",
            r"how (?:do i )?use (?:you|this)", r"commands")
_OUTSIDE = _re(r"recipe", r"soccer", r"joke", r"movie", r"series\b", r"dating", r"politic", r"election",
               r"weather forecast", r"weather today", r"write\w* (?:a|an|some) (?:code|essay|poem|text)",
               r"code in", r"program in python", r"do my homework", r"solve (?:the|my) (?:exam|test|worksheet)",
               r"horoscope", r"\bbet\b")


@dataclass
class Classification:
    intent: str
    enrollments: list[str] = field(default_factory=list)
    by_rule: bool = True


def classify(text: str, profile: str, own_student_id: str | None) -> Classification:
    t = normalize(text)
    enrollments = cited_enrollments(text)

    if _BYPASS.search(t):
        return Classification(BYPASS, enrollments)
    if _CHANGE_VERB.search(t) and _CHANGE_OBJECT.search(t):
        return Classification(CHANGE, enrollments)
    if _JUDGMENT.search(t):
        return Classification(JUDGMENT, enrollments)

    is_student = profile == "STUDENT"
    if is_student:
        other_enrollment = any(m != (own_student_id or "").upper() for m in enrollments)
        if other_enrollment or _OTHER_PERSON.search(t):
            return Classification(OTHER_STUDENT, enrollments)

    if _FORECAST.search(t):
        return Classification(INDIVIDUAL_FORECAST, enrollments)
    if _METHODOLOGY.search(t):
        return Classification(METHODOLOGY, enrollments)
    if _SERVICE.search(t):
        return Classification(SERVICE, enrollments)
    if _PRIVACY.search(t):
        return Classification(PRIVACY, enrollments)
    if _ACCESS.search(t):
        return Classification(ACCESS, enrollments)

    if not is_student:
        if enrollments:
            return Classification(SPECIFIC_STUDENT, enrollments)
        if _RISK.search(t) or _RISK_LIST.search(t):
            if _RISK_LIST.search(t) and not _RISK_SUMMARY.search(t):
                return Classification(HIGHEST_RISK, enrollments)
            return Classification(RISK_SUMMARY, enrollments)

    if _RISK.search(t):
        return Classification(MY_RISK, enrollments)
    if _SUMMARY.search(t) and not (_ATTENDANCE.search(t) or _GRADES.search(t) or _AVERAGE.search(t)):
        return Classification(ACADEMIC_SUMMARY, enrollments)
    if _ATTENDANCE.search(t):
        return Classification(ATTENDANCE, enrollments)
    if _GRADES.search(t):
        return Classification(GRADES, enrollments)
    if _AVERAGE.search(t):
        return Classification(AVERAGE, enrollments)
    if _STATUS.search(t):
        return Classification(STATUS, enrollments)
    if _PENDING_ITEMS.search(t):
        return Classification(PENDING_ITEMS, enrollments)
    if _SUMMARY.search(t):
        return Classification(ACADEMIC_SUMMARY, enrollments)

    if _OUTSIDE.search(t):
        return Classification(OUT_OF_SCOPE, enrollments)
    if _THANKS.search(t):
        return Classification(THANKS, enrollments)
    if _HELP.search(t):
        return Classification(HELP, enrollments)
    if _GREETING.search(t):
        return Classification(GREETING, enrollments)
    return Classification(NOT_UNDERSTOOD, enrollments)
