import html

import streamlit as st

import client
import ui
from screens.alerts import FACTOR_LABEL


def _class_card(t: dict):
    total = t["students"] or 0
    others = max(total - t["critical"] - t["high"], 0)
    parts = [("CRITICAL", t["critical"]), ("HIGH", t["high"])]
    band = "".join(f'<div style="flex:{n};background:{ui.CHART_COLOR[nv]}"></div>' for nv, n in parts if n)
    band += f'<div style="flex:{others};background:{ui.COLOR["lineSoft"]}"></div>' if others else ""
    chips = "".join(f'<span class="mf-chip">{ui.badge(nv)}{n}</span>' for nv, n in parts)
    chips += f'<span class="mf-chip"><span class="mf-badge" style="background:{ui.COLOR["lineSoft"]}">Others</span>{others}</span>'
    with ui.dashboard("class_" + ui._slug(t["class_id"])):
        st.markdown(f'<div style="display:flex;justify-content:space-between;gap:12px"><div>'
                    f'<div class="mf-h3">{html.escape(t["subject"])} — {html.escape(t["class_id"])}</div>'
                    f'<div class="mf-h3sub">{html.escape(str(t["academic_period"]))} · {html.escape(str(t["shift"]))} · '
                    f'{total} students · {t["workload_h"]} h</div></div>'
                    f'<span class="mf-icbox">{ui.icon("presentation", 20)}</span></div>'
                    f'<div class="mf-scale" style="height:8px;border-radius:999px">{band or ""}</div>'
                    f'<div class="mf-chips">{chips}</div>', unsafe_allow_html=True)
        left, dir_ = st.columns([2, 1], vertical_alignment="center")
        left.caption(f"Average {ui.br_number(t['class_average'], 2)} · attendance {ui.br_number(t['class_attendance'])}%")
        with dir_:
            if ui.link_text("See students", f"t{t['class_id']}"):
                ui.ir("class_value", open_class=t["class_id"])


def hub():
    ui.header("My classes", "Count of students by risk level in each class", "Teacher")
    ui.notice("You see academic indicators", "Grades, attendance and failures. Income, work, health and "
             "housing data stay with the SSC.", "book-open")
    with st.container(horizontal=True):
        ui.link("Alerts for my students", "alerts", "queue_d", "bell-ring", open_alert=None)
        ui.link("Assistant", "assistant", "d_assist", "sparkles")

    @st.fragment(run_every="30s")
    def _classes():
        with ui.section():
            classes = client.get("/api/v1/classes")
            if not classes:
                st.info("No class linked to your record.")
            columns = st.columns(2)
            for n, t in enumerate(classes):
                with columns[n % 2]:
                    _class_card(t)

    _classes()


def class_value():
    class_id = st.session_state.get("open_class")
    if ui.go_back("Back to the classes", "go_back_classes"):
        ui.ir("classes")
    if not class_id:
        st.info("Choose a class in My classes.")
        return
    with ui.section():
        r = client.get(f"/api/v1/classes/{class_id}/students")
        t = r["class_value"]
        ui.header(f"{t['course_subject']} — {t['class_id']}",
                     f"{t['academic_period']} · {t['shift']} · {len(r['students'])} students · academic indicators",
                     "Teacher")
        if not r["students"]:
            ui.notice("No student enrolled yet", "When there are enrollments, the students appear here.", "user-x")
            return
        rows = [(a["enrollment"], [
            ui.person(a["name"], a["enrollment"]), ui.grade_cell(a["final_grade"], 6.0),
            ui.attendance_cell(a["attendance_pct"], 75.0), ui.status_cell(a["status"]), ui.badge(a["level"]),
            html.escape(", ".join(FACTOR_LABEL.get(f, f) for f in a["main_factors"][:3]) or "—")])
            for a in r["students"]]
        clicked = ui.table_name("class_value", ["Student", "Final grade", "Attendance", "Status", "Risk", "Factors"],
                            [2.2, 0.8, 1.3, 1.1, 1.1, 1.5], rows, "Open record")
        if clicked is not None:
            ui.ir("record", enrollment_record=clicked)
