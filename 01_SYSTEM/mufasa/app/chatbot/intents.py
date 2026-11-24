import re
from dataclasses import dataclass, field

from app.chatbot.filters import looks_search
from app.chatbot.text import cited_enrollments, normalize

BYPASS = "BYPASS_ATTEMPT"
CHANGE = "CHANGE_REQUEST"
OTHER_STUDENT = "OTHER_STUDENT_DATA"
JUDGMENT = "JUDGMENT_ABOUT_PERSON"
INDIVIDUAL_FORECAST = "WHO_WILL_GIVE_UP"

ACADEMIC_SUMMARY = "ACADEMIC_SUMMARY"
GRADES = "GRADES"
ATTENDANCE = "ATTENDANCE_AND_ABSENCES"
AVERAGE = "AVERAGE"
STATUS = "STATUS_IN_SUBJECTS"
PENDING_ITEMS = "PENDING_ACTIVITIES"
MY_RISK = "MY_RISK_LEVEL"

RISK_SUMMARY = "RISK_SUMMARY"
HIGHEST_RISK = "HIGHEST_RISK_STUDENTS"
SPECIFIC_STUDENT = "STATUS_OF_ONE_STUDENT"
STUDENT_SEARCH = "STUDENT_SEARCH_BY_FILTER"

GREETING = "GREETING"
THANKS = "THANKS"
HELP = "HELP"
STUDIES = "STUDY_TIPS"
METHODOLOGY = "METHODOLOGY"
SERVICE = "HUMAN_SERVICE"
PRIVACY = "PRIVACY"
ACCESS = "ACCESS_AND_PASSWORD"
OUT_OF_SCOPE = "OUT_OF_SCOPE"
NOT_UNDERSTOOD = "NOT_UNDERSTOOD"

REFUSALS = {BYPASS, CHANGE, OTHER_STUDENT, JUDGMENT}
STUDENT_INTENTS = {ACADEMIC_SUMMARY, GRADES, ATTENDANCE, AVERAGE, STATUS, PENDING_ITEMS, MY_RISK}
TEAM_INTENTS = {RISK_SUMMARY, HIGHEST_RISK, SPECIFIC_STUDENT, STUDENT_SEARCH}

CONVERSATION_INTENTS = {GREETING, THANKS, HELP, STUDIES, OUT_OF_SCOPE, NOT_UNDERSTOOD}

INTENTS_THE_AI_CAN_SUGGEST = (
    STUDENT_INTENTS | TEAM_INTENTS
    | {GREETING, THANKS, HELP, STUDIES, METHODOLOGY, SERVICE, PRIVACY, ACCESS, OUT_OF_SCOPE}
)


def _re(*terms: str) -> re.Pattern:
    return re.compile(r"\b(?:" + "|".join(terms) + r")")


_BYPASS = _re(
    r"ignor\w*\s+(?:\w+\s+){0,3}(?:rule|instruction|restriction|limit|order|command)",
    r"forget\w*\s+(?:\w+\s+){0,3}(?:rule|instruction|restriction)", r"disregard\w*\s+(?:\w+\s+){0,3}(?:rule|instruction)",
    r"pretend\w*", r"act as", r"act like", r"behave as", r"play the role", r"make believe",
    r"you are now", r"from now on you", r"(?:developer|dev|god|admin|unrestricted) mode",
    r"jailbreak", r"dan\b", r"without (?:restriction|filter|rule|limit)", r"no (?:restrictions|filters|rules|limits)",
    r"system prompt", r"your (?:instructions|internal rules)",
    r"reveal\w* (?:\w+\s+){0,3}(?:prompt|instruction|code|rule|password|key)", r"source code",
    r"(?:admin|administrator|system|database|teacher|professor|coordinator|other) s? password",
    r"password (?:of|for) (?:the )?(?:admin|administrator|system|database|teacher|professor|coordinator|other)",
    r"api key", r"\bsql\b", r"select\s+(?:\S+\s+)?from", r"drop\s+table", r"union\s+select",
    r"i (?:am|m) (?:the |an? )?(?:admin|administrator|coordinator|teacher|professor|director)",
    r"my profile is (?:admin|administrator|coordination|teacher)", r"base64",
)

_CHANGE_VERB = _re(
    r"change", r"alter", r"modify", r"edit", r"fix", r"correct\b", r"update", r"delete", r"erase", r"remove",
    r"increase", r"decrease", r"reset", r"waive", r"excuse", r"post (?:a|my|the)", r"register", r"bump",
)
_CHANGE_OBJECT = _re(r"grade", r"absence", r"attendance", r"presence", r"registration", r"data", r"average",
                     r"score", r"risk", r"enrollment", r"history", r"status", r"record")

_OTHER_PERSON = _re(
    r"classmate", r"other students?", r"another student", r"of everyone", r"everyone s", r"of all students",
    r"of the class", r"my friend", r"boyfriend", r"girlfriend", r"ranking", r"list of students", r"student list",
    r"who got", r"who has the highest", r"who has the lowest", r"(?:grade|data) of (?:so and so|someone else|other)",
)
_JUDGMENT = _re(r"lazy", r"slacker", r"stupid", r"dumb", r"incompetent", r"irresponsible",
                r"(?:does not|doesn t|do not|don t) (?:try|make an effort)", r"uninterested", r"not interested",
                r"(?:his|her|their) fault")
_FORECAST = _re(r"who (?:will|is going to|s going to) (?:give up|drop out|quit|abandon|leave|lock)",
                r"(?:will|going to) (?:give up|drop out|quit|abandon)")

_METHODOLOGY = _re(r"how (?:is|was) (?:it |the risk |the score |my risk |my score )?calculated",
                   r"how (?:the |my )?(?:risk|score|level) is calculated", r"how do (?:you )?calculate",
                   r"how does (?:the |my )?(?:risk|score|level|calculation) work", r"methodology",
                   r"what does (?:the |my )?(?:risk|score|level|alert) mean", r"where does (?:it|this|that) come from",
                   r"why am i (?:at|in|on|with) (?:risk|alert)")
_SERVICE = _re(r"talk to (?:someone|a person|a human|an attendant|the registrar|the support center|the center|a psycholog)",
               r"speak (?:to|with) (?:someone|a person|a human)", r"attendant", r"human service", r"\bhuman\b",
               r"psycholog", r"emotional support", r"support center", r"i need help", r"i feel (?:bad|awful|terrible)",
               r"anxi", r"depress", r"suicid", r"kill myself", r"take my (?:own )?life",
               r"(?:can t|cannot) take (?:it|this) anymore", r"want to die", r"hurt myself")
_PRIVACY = _re(r"lgpd", r"privacy", r"my personal data", r"what data", r"what do you (?:keep|store)",
               r"export my data", r"consent")

_ACCESS = _re(r"password", r"login", r"log in", r"(?:can t|cannot) (?:sign|log) in", r"access blocked",
              r"blocked access", r"locked out")

_RISK = _re(r"risk", r"dropout", r"drop out", r"score", r"alert", r"level of")
_ATTENDANCE = _re(r"attendance", r"presence", r"absence", r"absent", r"missed", r"miss\b", r"missing")
_GRADES = _re(r"grade", r"exam ?[123]\b", r"exam", r"test\b", r"assessment", r"report card", r"transcript",
              r"i got", r"marks?\b")
_AVERAGE = _re(r"average", r"coefficient", r"\bgpa\b", r"performance")
_STATUS = _re(r"approved", r"passed", r"failed", r"fail\b", r"did i pass", r"will i pass", r"status", r"retake",
              r"\bdp\b")
_PENDING_ITEMS = _re(r"pending", r"activit", r"assignment", r"deliverable", r"task", r"\bdue\b", r"deadline",
                     r"late\b", r"overdue", r"homework", r"exercise list", r"questionnaire", r"seminar", r"report\b")
_DEADLINE = _re(r"\bdue\b", r"deadline", r"late\b", r"overdue", r"hand in", r"to hand in", r"pending")
_SUMMARY = _re(r"how am i doing", r"how (?:am|are|is) (?:i|my|things)", r"how s (?:it|my)", r"my performance",
               r"my overall (?:situation|status)", r"summary", r"overview", r"panorama", r"how (?:is|are) my")

_RISK_SUMMARY = _re(r"how many", r"distribution", r"summary", r"overview", r"panorama", r"total")
_RISK_LIST = _re(r"which students", r"what students", r"\blist\b", r"highest risk", r"most risk", r"most at risk",
                 r"critic", r"high risk", r"at risk", r"priority", r"queue")

_GREETING = _re(r"hi\b", r"hello\b", r"hey\b", r"good morning", r"good afternoon", r"good evening", r"howdy",
                r"what s up", r"yo\b")
_THANKS = _re(r"thank", r"thx", r"appreciate", r"cheers")
_HELP = _re(r"menu", r"help", r"what (?:can|do) you (?:do|know)", r"options", r"how (?:do i|to) use (?:you|this|it)",
            r"commands")
_STUDIES = _re(r"how (?:can |do |should )?i (?:study|prepare|organize|get organized|improve)",
               r"how to (?:study|prepare|organize)", r"tips? (?:for|on|to)", r"study (?:technique|method|routine|tips?)",
               r"concentrat", r"focus", r"procrastinat", r"unmotivated", r"no motivation", r"lack of motivation",
               r"help me study")
_OUTSIDE = _re(r"recipe", r"soccer", r"football", r"joke", r"movie", r"series\b", r"tv show", r"dating", r"politic",
               r"election", r"weather", r"write (?:me )?(?:a|an) (?:code|essay|poem|text|program)", r"code in",
               r"program in python", r"do my (?:homework|assignment|work)", r"solve (?:the|my) (?:exam|test|list)",
               r"horoscope", r"\bbet\b", r"betting")


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

    if _STUDIES.search(t):
        return Classification(STUDIES, enrollments)

    if not is_student:
        if enrollments:
            return Classification(SPECIFIC_STUDENT, enrollments)
        if looks_search(text):
            return Classification(STUDENT_SEARCH, enrollments)
        if _RISK.search(t) or _RISK_LIST.search(t):
            if _RISK_LIST.search(t) and not _RISK_SUMMARY.search(t):
                return Classification(HIGHEST_RISK, enrollments)
            return Classification(RISK_SUMMARY, enrollments)

    if _RISK.search(t):
        return Classification(MY_RISK, enrollments)
    if is_student and _DEADLINE.search(t):
        return Classification(PENDING_ITEMS, enrollments)
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


_CONTINUATION = _re(r"and (?:in|on|for|about|of|the)\b", r"what about", r"how about", r"and that",
                    r"and this", r"and now")
_SUBJECTS_THAT_CONTINUE = {GRADES, ATTENDANCE, STATUS, ACADEMIC_SUMMARY}


def resume_topic(intent: str, text: str, previous: list[str]) -> str:
    if intent != NOT_UNDERSTOOD or not previous:
        return intent
    t = normalize(text)
    if previous[0] in _SUBJECTS_THAT_CONTINUE and _CONTINUATION.match(t):
        return previous[0]
    return intent
