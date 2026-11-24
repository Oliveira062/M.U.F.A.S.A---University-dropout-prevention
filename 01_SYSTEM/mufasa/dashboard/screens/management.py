import streamlit as st

import client
import ui
from screens import dashboards


def hub():
    ui.header("Institutional dashboard", "Aggregated view of all courses, updated automatically", "Management")
    ui.notice("Aggregated view", "Management does not see names or student IDs. Groups with fewer than 5 students are suppressed "
             "(RN07, CA19).", "lock")
    course = None
    with ui.section():
        an = client.get("/api/v1/dashboards/analyses")
        courses = [c["group"] for c in an["comparison"]]
        if len(courses) > 1:
            st.caption("The course filters use the course code.")
    dashboards.dashboard("BOARD", course)


def reports():
    ui.header("Reports", "Aggregated export, with version and confidentiality footer (RF21, RN23)", "Management")
    with ui.section("Institutional distribution by level"):
        view = client.get("/api/v1/dashboards/general-view")
        rows = [{"level": ui.LEVEL_NAME.get(d["level"]), "students": "suppressed" if d["total"] is None else str(d["total"]),
                   "percentage": "" if d["pct"] is None else str(d["pct"])} for d in view["distribution"]]
        with_pct = any(d.get("pct") is not None for d in view["distribution"])
        ui.grade([("Level", "e"), ("Students", "d")] + ([("Percentage", "d")] if with_pct else []),
                 [[ui.badge(d["level"]), ui.txt("suppressed" if d["total"] is None else d["total"])]
                  + ([ui.txt(None if d.get("pct") is None else f'{ui.br_number(d["pct"])}%')] if with_pct else [])
                  for d in view["distribution"]],
                 "Groups with fewer than 5 students appear as suppressed (LGPD).", "Institutional distribution by level")
        ui.export_button(rows, ["level", "students", "percentage"], "Institutional distribution by level",
                          "mufasa_distribution.csv")
    with ui.section("Comparison between courses", "Groups with fewer than 5 students appear suppressed"):
        an = client.get("/api/v1/dashboards/analyses")
        rows = [{"course": c["group"], **{ui.LEVEL_NAME[n]: ("suppressed" if v is None else str(v))
                                          for n, v in c["levels"].items()}} for c in an["comparison"]]
        if rows:
            ui.simple_grade([{"Course": l["course"], **{k: v for k, v in l.items() if k != "course"}} for l in rows],
                             "Comparison between courses", right=tuple(ui.LEVEL_NAME.values()))
            ui.export_button(rows, list(rows[0].keys()), "Comparison between courses", "mufasa_courses.csv")
