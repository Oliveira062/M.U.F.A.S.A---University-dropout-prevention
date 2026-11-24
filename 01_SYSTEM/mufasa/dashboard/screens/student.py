import html
import json
from datetime import datetime, time, timedelta
from zoneinfo import ZoneInfo

import streamlit as st

import client
import ui

TIMEZONE = ZoneInfo("America/Sao_Paulo")
TERM_VERSION = "1.0"
REQUEST_TYPES = {"Confirm that my data is processed and see which data": "ACCESS_CONFIRMATION",
                "Correct a piece of data": "CORRECTION", "Anonymize or delete data": "ELIMINATION_ANONYMIZATION",
                "Portability of my data": "PORTABILITY",
                "Review of an automated decision (art. 20)": "AUTOMATED_DECISION_REVIEW",
                "Know who my data is shared with": "SHARING_INFORMATION",
                "Revoke consent": "CONSENT_REVOCATION", "Object to a processing activity": "OBJECTION"}


def _weighted(subjects: list[dict], field: str):
    pairs = [(d[field], d["workload_h"] or 0) for d in subjects if d[field] is not None]
    weight = sum(p for _, p in pairs)
    return None if not pairs or weight == 0 else sum(v * p for v, p in pairs) / weight


def hub():
    account = st.session_state.get("account", {})
    ui.header(f"Hello, {(account.get('name') or account.get('login') or '').split(' ')[0]}!",
                 "Good to see you here. This is the summary of your semester: only you see this data.")

    @st.fragment(run_every="30s")
    def _summary():
        status = subj = None
        with ui.section():
            status = client.get("/api/v1/student/status")
        with ui.section():
            subj = client.get("/api/v1/student/subjects")
        c = st.columns(3)
        if subj is not None:
            items = subj["subjects"]
            att, average = _weighted(items, "attendance_pct"), _weighted(items, "final_grade")
            with c[0]:
                ui.card("Attendance", "no data" if att is None else f"{ui.br_number(att)}%",
                        f"minimum of {subj['minimum_attendance']:g}%", "calendar-check")
            with c[1]:
                ui.card("Partial average", ui.br_number(average),
                        f"in {len(items)} subjects · minimum {subj['minimum_grade']:g}", "book-open")
        if status is not None:
            with c[2]:
                ui.card("Follow-up status", status["status"],
                        f"updated {ui.br_date(status.get('updated_at'))}", "heart-handshake")
            ui.notice("Your status", status["message"], "info")
            if status.get("immediate_channel"):
                if st.button(status["immediate_channel"]["text"], type="primary"):
                    ui.ir("assistant")
    _summary()

    ui.dashboard_title("Shortcuts")
    a, b, c = st.columns(3)
    with a:
        ui.shortcut("support", "support", "Support", "SSC, coordination and aid", "hand-heart")
    with b:
        ui.shortcut("assistant", "assistant", "Assistant", "Ask questions about your data", "message-circle")
    with c:
        ui.shortcut("indicators", "indicators", "My indicators", "Grades, attendance and follow-up", "chart-line")
    with ui.section():
        consent = client.get("/api/v1/privacy/consents")
        current = next((x for x in consent if x["purpose"] == "HEALTH_DATA"), None)
        e, d = st.columns([5, 1], vertical_alignment="center")
        with e:
            ui.notice("Consent for health data: " + ("authorized" if current and current["granted"]
                                                             else "not authorized"),
                     "It is optional and you can revoke it whenever you want.", "heart-pulse")
        with d:
            if ui.link_text("Manage", "manage_consent"):
                ui.ir("privacy")
    with ui.section("Team records for you"):
        followup = client.get("/api/v1/student/followup")
        if not followup["records"]:
            st.caption("No record shared with you yet.")
        st.markdown("".join(
            f'<div class="mf-time"><b>{html.escape((r.get("action_type") or "record").replace("_", " ").capitalize())}'
            f'</b><small>{ui.br_date(r["moment"])}</small><p>{html.escape(r.get("description") or "")}</p></div>'
            for r in followup["records"][:5]), unsafe_allow_html=True)


def indicators():
    ui.header("My indicators", "Grades, attendance and what influences your status", "Student portal")
    with ui.section("Semester subjects"):
        subj = client.get("/api/v1/student/subjects")
        rows = subj["subjects"]
        if not rows:
            st.caption("No subject recorded.")
        else:
            nmin, fmin = subj["minimum_grade"], subj["minimum_attendance"]
            approved = sum(1 for d in rows if "APROVAD" in (d["status"] or "").upper())
            ui.summary([("subjects in the semester", len(rows), "neutral"),
                       ("approved", approved, "ok" if approved else "neutral"),
                       ("below the minimum grade", sum(1 for d in rows if d["minimum_below_grade"]),
                        "alert" if any(d["minimum_below_grade"] for d in rows) else "ok"),
                       ("below the minimum attendance", sum(1 for d in rows if d["minimum_below_attendance"]),
                        "alert" if any(d["minimum_below_attendance"] for d in rows) else "ok")])
            ui.grade([("Subject", "e"), ("EXAM1", "c"), ("EXAM2", "c"), ("EXAM3", "c"), ("Final grade", "c"),
                      ("Attendance", "e"), ("Status", "e"), ("Attention", "e")],
                     [[ui.double_cell(d["subject"], d["professor"]),
                       ui.grade_cell(d["exam1"], None), ui.grade_cell(d["exam2"], None), ui.grade_cell(d["exam3"], None),
                       ui.grade_cell(d["final_grade"], nmin), ui.attendance_cell(d["attendance_pct"], fmin),
                       ui.status_cell(d["status"]),
                       ui.alerts_cell([x for x, ok in (("Grade", d["minimum_below_grade"]),
                                                       ("Attendance", d["minimum_below_attendance"])) if ok])]
                      for d in rows],
                     legend=f"Minimum grade {ui.br_number(nmin)} and minimum attendance {ui.br_number(fmin, 0)}%. "
                             "In red, what is below the minimum. " + rows[0]["absences_note"],
                     label="Semester subjects")
    with ui.section("What influences your status"):
        stat = client.get("/api/v1/student/status")
        ui.methodological_note(stat["notice"])
        if not stat["factors"]:
            st.caption("No factor needing attention.")
        ui.factor_cards(stat["factors"])
        if stat.get("can_dispute") and stat["factors"]:
            with st.form("dispute"):
                ui.dashboard_title("Is any data wrong?", "Ask for a check (RN17)")
                options = {f["name"].capitalize(): f["factor"] for f in stat["factors"]}
                factor = st.selectbox("Factor", list(options))
                desc = st.text_area("What is wrong", max_chars=1000)
                if st.form_submit_button("Send dispute"):
                    try:
                        r = client.post("/api/v1/student/disputes", {"factor": options[factor], "description": desc})
                        st.success(f"Dispute recorded. {r['deadline']}")
                    except client.ApiError as e:
                        st.error(e.message + (" " + "; ".join(c["message"] for c in e.fields) if e.fields else ""))


def support():
    ui.header("Support and appointments", "Institution channels and a conversation with the support center", "Student portal")
    with ui.section("Support suggested for you"):
        stat = client.get("/api/v1/student/status")
        st.markdown(f"Status: {ui.pill(stat['status'])}", unsafe_allow_html=True)
        if not stat["supports"]:
            st.caption("No suggestion at the moment. You can book a conversation whenever you want.")
        st.markdown("".join(f'<div class="mf-row"><div><b>{ui.icon("hand-heart", 14, ui.COLOR["deep"])} '
                            f'{html.escape(a["text"])}</b></div></div>' for a in stat["supports"]),
                    unsafe_allow_html=True)
    with ui.section("Book a service"):
        ag = client.get("/api/v1/appointments")
        st.caption(f"Minimum interval between services: {ag['days_minimum_interval']} days (RN14)."
                   + (f" Next free date: {ui.br_date(ag['next_free_date'])[:10]}."
                      if ag.get("next_free_date") else ""))
        with st.form("schedule"):
            tomorrow = datetime.now(TIMEZONE).date() + timedelta(days=1)
            day = st.date_input("Day", value=tomorrow, min_value=tomorrow, max_value=tomorrow + timedelta(days=179),
                                format="DD/MM/YYYY")
            times = [time(h, m) for h in range(8, 21) for m in (0, 30)]
            at_time = st.selectbox("Time", times, format_func=lambda t: t.strftime("%H:%M"), index=4)
            if st.form_submit_button("Mark", type="primary"):
                start = datetime.combine(day, at_time, tzinfo=TIMEZONE)
                try:
                    r = client.post("/api/v1/appointments", {"start": start.isoformat()})
                    st.success("Service booked." + (f" {r['exception']}" if r.get("exception") else ""))
                except client.ApiError as e:
                    st.warning(e.message)
        for g in ag["appointments"]:
            col = st.columns([3, 2, 1], vertical_alignment="center")
            col[0].markdown(f'{ui.icon("calendar", 14, ui.COLOR["deep"])} {ui.br_date(g["start"])}',
                            unsafe_allow_html=True)
            col[1].markdown(ui.pill(g["status"].capitalize(), outline=True), unsafe_allow_html=True)
            if g["status"] == "SCHEDULED" and col[2].button("Cancel", key=f"cg{g['appointment_id']}"):
                with ui.section():
                    client.patch(f"/api/v1/appointments/{g['appointment_id']}", {"status": "CANCELED"})
                    st.rerun()


def privacy():
    ui.header("Privacy and my data", "Your rights under the LGPD (art. 18). Revoking consent never "
                 "harms you.", "Student portal")
    with ui.section("Consent for health data"):
        consent = client.get("/api/v1/privacy/consents")
        current = next((c for c in consent if c["purpose"] == "HEALTH_DATA"), None)
        granted = bool(current and current["granted"])
        st.markdown("Current status: " + ui.pill("Granted" if granted else "Not granted", outline=True)
                    + (f" on {ui.br_date(current['registered_at'])}" if current else ""), unsafe_allow_html=True)
        if st.button("Revoke consent" if granted else "Grant consent"):
            try:
                client.post("/api/v1/privacy/consents",
                             {"purpose": "HEALTH_DATA", "granted": not granted, "term_version": TERM_VERSION})
                st.rerun()
            except client.ApiError as e:
                st.warning(e.message)
    with ui.section("My data"):
        st.caption("A copy of everything MUFASA keeps about you, in an open format (JSON).")
        if st.button("Prepare a copy of my data"):
            data = client.get("/api/v1/privacy/my-data")
            st.download_button("Download (JSON)", json.dumps(data, ensure_ascii=False, indent=2).encode("utf-8"),
                               "my_mufasa_data.json", "application/json")
    with ui.section("Make a request to the data protection officer"):
        with st.form("payload"):
            kind = st.selectbox("Request", list(REQUEST_TYPES))
            desc = st.text_area("Details (optional)", max_chars=1000)
            if st.form_submit_button("Send request"):
                try:
                    r = client.post("/api/v1/privacy/requests", {"kind": REQUEST_TYPES[kind], "description": desc})
                    st.success(f"Request recorded. {r['deadline']}")
                except client.ApiError as e:
                    st.error(e.message)
        followup = client.get("/api/v1/student/followup")
        if followup["requests"]:
            ui.grade(["Request", "Status", "Registered", "Answered"],
                     [[ui.txt(p["kind"].replace("_", " ").capitalize()), ui.status_cell(p["status"]),
                       ui.txt(ui.br_date(p["registered_at"])), ui.txt(ui.br_date(p.get("answered_at")) or None)]
                      for p in followup["requests"]], label="My requests")
