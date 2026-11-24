import json

from app.api.permissions import (STUDENT, COORDINATION, TEACHER, HEALTH_FACTORS, SOCIOECONOMIC_FACTORS,
                                 FINANCE, SUPPORT_CENTER, REFERRED_LABEL, qualitative_band)

ACADEMIC_FACTORS = {"grades", "attendance", "failure", "lms_engagement"}
CONTEXT_MODIFIERS = {"M1", "M3"}


def _list(value):
    if value is None:
        return []
    return json.loads(value) if isinstance(value, str) else value


def crop_factor(profile: str, factor: dict) -> dict | None:
    name = factor["factor"]
    if profile in (STUDENT, SUPPORT_CENTER):
        return factor
    if profile == FINANCE:
        return factor if name == "finance" else None
    if name in ACADEMIC_FACTORS:
        return factor
    if profile == COORDINATION and name in SOCIOECONOMIC_FACTORS:
        return {"id": factor["id"], "factor": name, "name": factor["name"], "band": qualitative_band(factor["points"]),
                "weight": factor["weight"], "actionable": factor["actionable"],
                "explanation": f"Vulnerability in band {qualitative_band(factor['points'])}; the details stay with the "
                              "support center."}
    return {"id": None, "factor": "referred", "name": REFERRED_LABEL, "explanation": REFERRED_LABEL}


def main_visible(profile: str, main_factors) -> list[str]:
    main = []
    for name in _list(main_factors):
        visible = crop_factor(profile, {"factor": name, "id": None, "name": name, "points": 0, "weight": 0,
                                        "actionable": False, "explanation": ""})
        if visible is None:
            continue
        label = REFERRED_LABEL if visible["factor"] == "referred" else name
        if label not in main:
            main.append(label)
    return main


def visible_recommendations(profile: str, recommendations) -> list[dict]:
    recommendations = _list(recommendations)
    if profile == TEACHER:
        return [r for r in recommendations if r["service_profile"] == "Academic"]
    if profile == FINANCE:
        return [r for r in recommendations if r["service_profile"] == "Finance"]
    if profile == COORDINATION:
        return [r for r in recommendations if r["factor"] not in HEALTH_FACTORS]
    return recommendations


def crop_score(profile: str, row) -> dict:
    factors = []
    referred_seen = False
    for factor in _list(row["factors"]):
        cropped = crop_factor(profile, factor)
        if cropped is None:
            continue
        if cropped["factor"] == "referred":
            if referred_seen:
                continue
            referred_seen = True
        factors.append(cropped)

    main = main_visible(profile, row["main_factors"])

    modifiers = _list(row["modifiers"])
    if profile not in (STUDENT, SUPPORT_CENTER):
        modifiers = [m if m["id"] not in CONTEXT_MODIFIERS else
                     {"id": m["id"], "description": "Context modifier (details with the support center)",
                      "delta": m["delta"]} for m in modifiers]
    if profile == FINANCE:
        modifiers = []

    recommendations = visible_recommendations(profile, row["recommendations"])

    reason = row["overlap_reason"]
    return {
        "score": row["score"],
        "level": row["level"],
        "origin_level": row["origin_level"],
        "overlap_reason": reason,
        "partial": bool(row["partial"]),
        "completeness": float(row["completeness"]),
        "factors": factors,
        "main_factors": main,
        "modifiers": modifiers,
        "recommendations": recommendations,
        "level_recommendation": row["recommendation"],
        "trend": row["trend"],
        "previous_score": row["previous_score"],
        "previous_level": row["previous_level"],
        "model_version": row["model_version"],
        "parameters_version": f"param-v{row['parameters_version']}",
        "calculated_at": row["calculated_at"],
    }
