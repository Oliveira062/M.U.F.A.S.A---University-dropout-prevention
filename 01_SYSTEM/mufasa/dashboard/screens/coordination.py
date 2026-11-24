import html

import streamlit as st

import client
import ui
from screens import alerts, dashboards
from screens.admin import parameters_table


def _attention():
    ui.dashboard_title("Need attention now", "Only Coordination and the responsible SSC see names in this view")
    r = client.get("/api/v1/alerts", limit=4)
    if not r["items"]:
        st.caption("No active alert in the course.")
    for i in r["items"]:
        deadline = "deadline passed" if i["overdue"] else f"deadline {ui.br_date(i['deadline_at'])[:5]}"
        a, b, c = st.columns([5, 1.7, 0.5], vertical_alignment="center")
        a.markdown(f'<div class="mf-l-list"><span class="mf-avatar">{html.escape(ui.initial(i["name"]))}</span>'
                   f'<div><b>{html.escape(i["name"])}</b><small>{i["enrollment"]} · semester {i["semester"]} · '
                   f'{deadline}</small></div></div>', unsafe_allow_html=True)
        b.markdown(f'<div style="text-align:right">{ui.badge(i["level"])}</div>', unsafe_allow_html=True)
        with c:
            with st.container(key=f"open_{i['alert_id']}"):
                if st.button("Open", key=f"h{i['alert_id']}", help=f"Open the alert for {i['name']}"):
                    ui.ir("alerts", open_alert=i["alert_id"])
    with st.container(key="all_link"):
        if st.button("See all students in the course  →"):
            ui.ir("students")


def hub():
    account = st.session_state.get("account", {})
    course = account.get("course") or "Course"
    left, half, dir_ = st.columns([2.4, 1.3, 0.6], vertical_alignment="top")
    with left:
        ui.header("Course dashboard", f"{course} · course indicators, updated automatically",
                     "Academic coordination")
    half.markdown(f'<div class="mf-course">{ui.icon("graduation-cap", 16, ui.COLOR["deep"])}{html.escape(course)}</div>',
                  unsafe_allow_html=True)
    with dir_:
        f = dashboards.filters()
    dashboards.dashboard("COORDINATION", f=f, attention=_attention)
    with st.container(key="banner"):
        a, b = st.columns([3, 1], vertical_alignment="center")
        with a:
            ui.banner("Shortcut to priority interventions",
                      "Critical alerts have a deadline of 48 hours; high ones, 5 business days.")
        with b:
            if st.button("See critical alerts  →", type="primary", width="stretch", key="critical_banner"):
                ui.ir("alerts", open_alert=None, level_queue_filter="Critical")


def students():
    left, dir_ = st.columns([3, 1.4], vertical_alignment="top")
    with left:
        ui.header("Students followed", "Course students with an active classification · vulnerability shown "
                     "only as a qualitative band", "Academic coordination")
    dir_.markdown(f'<div style="text-align:right;margin-top:18px">{ui.decision_badge()}</div>', unsafe_allow_html=True)
    c1, c2, c3, c4 = st.columns([2.2, 1, 1, 0.7], vertical_alignment="bottom")
    search = c1.text_input("Search by name or student ID", max_chars=60, placeholder="Search by name or student ID…")
    options = ["All", "Critical", "High", "Moderate", "Low", "Undetermined"]
    coming = st.session_state.pop("level_students_filter", None)
    level = c2.selectbox("Level", options, index=options.index(coming) if coming in options else 0)
    order = c3.selectbox("Sort by", ["risk", "name", "semester", "enrollment"])
    page = c4.number_input("Page", min_value=1, value=1)
    code = {"Critical": "CRITICAL", "High": "HIGH", "Moderate": "MODERATE", "Low": "LOW",
              "Undetermined": "UNDETERMINED"}.get(level)
    with ui.section():
        r = client.get("/api/v1/students", search=search or None, level=code, order=order, limit=50, page=int(page))
        alerts.students_table(r["items"], r["total"])
        ui.export_button([{"enrollment": i["enrollment"], "name": i["name"], "semester": i["semester"],
                            "level": i["risk_level"], "score": i["score"]} for i in r["items"]],
                          ["enrollment", "name", "semester", "level", "score"], "Course students", "course_students.csv")


def parameters():
    ui.header("Model parameters", "Minimum grade and risk cutoffs only change with coordination approval; "
                 "the interval between services and the alert limit are set by coordination (Annex B).",
                 "Academic coordination")
    with ui.section("Proposals awaiting approval"):
        data = client.get("/api/v1/parameters")
        pending = [p for p in data["proposals"] if p["status"] == "PENDING"]
        if not pending:
            st.caption("No pending proposal.")
        for p in pending:
            st.markdown(f'<div class="mf-row"><div><b>{html.escape(p["key"])}: {p["previous_value"]:g} → '
                        f'{p["new_value"]:g}</b><small>Proposed by {html.escape(p["proposed_by"])} on '
                        f'{ui.br_date(p["proposed_at"])} · justification: {html.escape(p["justification"])}</small></div>'
                        f'{ui.pill("Awaiting approval", outline=True)}</div>', unsafe_allow_html=True)
            a, b = st.columns(2)
            if a.button("Approve", key=f"ap{p['proposal_id']}", type="primary"):
                r = client.post(f"/api/v1/parameters/proposals/{p['proposal_id']}/decision", {"approve": True})
                st.success(f"Approved: version {r['version']} created. The students will be recalculated.")
            if b.button("Reject", key=f"rj{p['proposal_id']}"):
                client.post(f"/api/v1/parameters/proposals/{p['proposal_id']}/decision", {"approve": False})
                st.info("Proposal rejected.")
    with ui.section("Coordination parameters"):
        for key in ("SERVICE_INTERVAL", "OWNER_ALERT_CEILING"):
            current = next(p for p in data["parameters"] if p["key"] == key)
            with st.form(f"f{key}"):
                st.markdown(f"**{current['description']}** (current: {current['value']:g} {current['unit']})")
                value = st.number_input("New value", min_value=float(current["minimum"]), max_value=float(current["maximum"]),
                                        value=float(current["value"]), step=1.0)
                just = st.text_input("Justification", max_chars=500)
                if st.form_submit_button("Save new version"):
                    r = client.put(f"/api/v1/parameters/{key}", {"value": value, "justification": just})
                    st.success(f"Version {r.get('version')} created.")
    with ui.section("All current parameters"):
        parameters_table(data)
