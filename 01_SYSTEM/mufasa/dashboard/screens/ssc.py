import streamlit as st

import client
import ui
from screens import alerts


def hub():
    left, dir_ = st.columns([3, 1.4], vertical_alignment="top")
    with left:
        ui.header("My alerts", "Students with an alert assigned to you (Annex E) · Critical: first action within "
                     "48 hours", "Support center")
    dir_.markdown(f'<div style="text-align:right;margin-top:18px">{ui.decision_badge()}</div>', unsafe_allow_html=True)
    with st.container(horizontal=True):
        ui.link("Assigned students", "students", "students_n", "users")
        ui.link("Full queue", "alerts", "queue_n", "list", open_alert=None)
        ui.link("Assistant", "assistant", "n_assist", "sparkles")

    @st.fragment(run_every="20s")
    def _my():
        with ui.section():
            r = client.get("/api/v1/alerts", limit=50)
            k = st.columns(3)
            with k[0]:
                ui.card("Assigned to me", r["total"], "active alerts", "inbox")
            with k[1]:
                ui.card("Critical", sum(1 for i in r["items"] if i["level"] == "CRITICAL"), "handle within 48 hours",
                        "triangle-alert")
            with k[2]:
                ui.card("Deadline passed", sum(1 for i in r["items"] if i["overdue"]), "first action overdue", "clock")
            if not r["items"]:
                st.info("No alert assigned to you now.")
                return
            alerts.queue_table(r["items"], r["total"], key="my")

    _my()


def students():
    ui.header("Assigned students", "Students with an alert under your responsibility", "Support center")
    with ui.section():
        r = client.get("/api/v1/students", order="risk", limit=100)
        alerts.students_table(r["items"], r.get("total"))
