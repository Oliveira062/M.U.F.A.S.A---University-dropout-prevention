from app.calculation.score import LABELS

MAXIMUM_BY_CYCLE = 4

_OVERLAP_SEVERITY = {"S2": 300, "S4": 290, "S3": 280, "S1": 270}


def _rec(code, text, factor, profile, severity):
    return {"code": code, "text": text, "factor": factor, "service_profile": profile,
            "severity": round(severity, 1)}


def generate_recommendations(result: dict, data: dict, underage: bool = False) -> list[dict]:
    points = result.get("breakdown", {})
    reasons = result.get("overlap_reason") or ""
    recs = []

    for code, text, profile in (
        ("S2", "Immediate contact through all registered channels, following the emergency protocol (RN19).",
         "Personal and Emotional"),
        ("S4", "Retention interview before the enrollment lock is granted.", "Personal"),
        ("S1", "Formal active outreach; check the cause and any legal justification for the absence.", "Academic"),
    ):
        if f"{code}:" in reasons:
            recs.append(_rec(code, text, "attendance" if code == "S1" else "overlap", profile,
                             _OVERLAP_SEVERITY[code]))

    subjects_at_risk = [d.get("name") for d in data.get("subjects") or [] if d.get("i1") is not None
                        and d["i1"] >= 50]
    if len(subjects_at_risk) >= 3:
        recs.append(_rec("THREE_I1", "Individualized study plan; consider a reduced course load "
                         f"({len(subjects_at_risk)} subjects with performance at risk).", "grades", "Academic",
                         points.get("grades", 0)))
    elif subjects_at_risk:
        recs.append(_rec("ONE_I1", "Monitoring or peer tutoring in " + ", ".join(subjects_at_risk) + ".",
                         "grades", "Academic", points.get("grades", 0)))

    i2 = points.get("attendance")
    if i2 is not None and 40 <= i2 <= 79:
        recs.append(_rec("I2", "Teacher contact reporting the projected attendance and the remaining absences.",
                         "attendance", "Academic", i2))
    if data.get("failed_prerequisite"):
        recs.append(_rec("I3_PRE", "Review of the course completion plan; offering in a special period.", "failure",
                         "Academic", points.get("failure", 0)))
    if data.get("third_attempt"):
        recs.append(_rec("THIRD_I3", "Individual pedagogical service; consider reorienting the academic path.",
                         "failure", "Academic", points.get("failure", 0)))
    lms_days = data.get("days_without_lms_access")
    if lms_days is not None and lms_days > 21:
        recs.append(_rec("I4", "Check internet and equipment access before assuming lack of interest.",
                         "lms_engagement", "Personal", points.get("lms_engagement", 0)))
    i5 = points.get("finance")
    if i5 is not None and i5 >= 60 and not data.get("active_aid"):
        recs.append(_rec("I5", "Refer for an eligibility check for retention, transport and "
                         "meal aid.", "finance", "Finance", i5))
    if (data.get("late_tuition") or 0) > 0:
        text = "Guidance on renegotiation and student loans."
        if underage:
            text = "Guidance on renegotiation, done with the legal guardian (RN16)."
        recs.append(_rec("DELAY_I5", text, "finance", "Finance", i5 or 0))
    i6 = points.get("work")
    if (i6 is not None and i6 >= 75) or data.get("same_shift_work"):
        recs.append(_rec("I6", "Guidance on a reduced load or a compatible shift.", "work", "Personal", i6 or 0))
    i7 = points.get("commute")
    if i7 is not None and i7 >= 75:
        recs.append(_rec("I7", "Check eligibility for transport aid; consider hybrid subjects, if available.",
                         "commute", "Finance", i7))
    i8 = points.get("mental_health")
    if i8 is not None and i8 >= 70:
        text = "Offer of institutional psychological service or referral to the public network."
        if underage:
            text = ("Offer of institutional psychological service or referral to the child and adolescent protection "
                    "network, with the legal guardian (RN16).")
        recs.append(_rec("I8", text, "mental_health", "Emotional", i8))
    i10 = points.get("housing")
    if i10 is not None and i10 >= 60:
        recs.append(_rec("I10", "Check eligibility for housing aid.", "housing", "Finance", i10))
    i11 = points.get("dependents")
    if i11 is not None and i11 >= 70:
        recs.append(_rec("I11", "Check eligibility for daycare aid; consider compatible schedules.",
                         "dependents", "Personal", i11))

    recs.sort(key=lambda r: -r["severity"])
    for rec in recs:
        rec["label_factor"] = LABELS.get(rec["factor"], "overlap rule")
    return recs[:MAXIMUM_BY_CYCLE]
