import html

import streamlit as st

import client
import ui

STATUSES = {"Active": None, "Open": "OPEN", "In service": "IN_SERVICE", "Closed": "CLOSED"}
LEVELS = {"All": None, "Critical": "CRITICAL", "High": "HIGH", "Moderate": "MODERATE",
          "Undetermined (data)": "UNDETERMINED"}
ACTION_TYPES = {"Conversation": "CONVERSATION", "Academic guidance": "ACADEMIC_GUIDANCE",
              "Referral to the SSC": "SSC_REFERRAL", "Referral to finance": "FINANCE_REFERRAL",
              "Contact without reply": "CONTACT_WITHOUT_RETURN", "Other": "OTHER"}
CAUSES = {"Financial": "FINANCIAL", "Academic": "ACADEMIC", "Work": "WORK", "Health": "HEALTH",
          "Family": "FAMILY", "Transport": "TRANSPORT", "Course choice": "COURSE_CHOICE",
          "Institutional": "INSTITUTIONAL", "Not identified": "NOT_IDENTIFIED"}
OUTCOMES = {"Remained": "REMAINED", "In follow-up": "IN_FOLLOWUP", "Locked": "LOCKED",
             "DroppedOut": "DROPPED_OUT", "Transferred": "TRANSFERRED", "Data fixed (data task)": "FIXED_DATA"}
FACTOR_LABEL = {"grades": "grades", "attendance": "attendance", "failure": "failures",
                "lms_engagement": "virtual environment", "finance": "finance", "work": "work",
                "commute": "commute", "mental_health": "health", "physical_health": "health",
                "housing": "housing", "dependents": "dependents", "referred": "referred to the SSC"}
CHANNELS = {"Virtual environment": "VIRTUAL_ENVIRONMENT", "InPerson": "IN_PERSON",
          "Institutional email": "INSTITUTIONAL_EMAIL", "Emergency (RN19)": "RN19_EMERGENCY"}


LABEL_STATUS = {"OPEN": "New", "IN_SERVICE": "In progress", "CLOSED": "Closed"}
QUEUE_COLUMNS = [2.6, 1.5, 1.4, 1.9, 1.3, 0.9]


def _deadline(item) -> str:
    if item["status"] == "CLOSED":
        return "closed"
    hours = item.get("hours_for_deadline")
    if hours is None:
        return "—"
    if hours < 0:
        return f"overdue by {ui.br_number(-hours / 24, 0)} d" if -hours >= 24 else f"overdue by {int(-hours)} h"
    return f"{ui.br_number(hours / 24, 0)} d" if hours >= 24 else f"{int(hours)} h"


def _deadline_pill(item) -> str:
    text = _deadline(item)
    if item.get("overdue") and item["status"] != "CLOSED":
        return ui.pill(text.capitalize(), ui.COLOR["text"], "#FFFFFF", "clock")
    return ui.pill(text.capitalize(), ui.COLOR["goldSoft"], ui.COLOR["text"], "clock")


def _status(item) -> str:
    label = LABEL_STATUS.get(item["status"], item["status"].replace("_", " ").lower())
    if item["status"] == "OPEN" and item.get("owner"):
        label = "Assigned"
    return ui.pill(label, outline=True)


def _queue_kpis(profile: str):
    def total(**filters):
        return client.get("/api/v1/alerts", limit=1, **filters)["total"]
    with ui.section():
        cols = st.columns(4)
        with cols[0]:
            ui.card("Total alerts", total(), "active in your slice", "bell-ring")
        with cols[1]:
            ui.card("Critical level", total(level="CRITICAL"), "handle within 48 hours", "triangle-alert")
        with cols[2]:
            if profile == "COORDINATION":
                ui.card("No owner", total(without_owner="true"), "waiting for assignment", "user-plus")
            else:
                ui.card("High level", total(level="HIGH"), "handle within 5 business days", "circle-alert")
        with cols[3]:
            ui.card("Deadline passed", total(only_overdue="true"), "first action overdue", "clock")


def queue_table(items: list[dict], total: int, key: str = "queue"):
    ui.css("".join(f".st-key-lin_{key}_{i['alert_id']} {{ border-left:3px solid {ui.COLOR['gold']}; }}"
                   for i in items if i["overdue"] and i["status"] != "CLOSED"))
    rows = []
    for i in items:
        notice = (ui.pill("Deadline passed", ui.COLOR["text"], "#FFFFFF", "triangle-alert") + "<br>"
                 if i["overdue"] and i["status"] != "CLOSED" else "")
        background = ui.BADGE.get(i["level"] or "PENDING", ui.BADGE["PENDING"])[0]
        resp = (f'<div class="mf-resp">{ui.avatar(i["owner"], 30)}{html.escape(i["owner"])}</div>'
                if i.get("owner") else
                f'<div class="mf-resp empty">{ui.icon("user-plus", 18)}Not assigned</div>')
        rows.append((i["alert_id"], [
            f'<div class="mf-est">{notice}<b>{html.escape(i["name"])}</b>'
            f'<small>{i["enrollment"]} · semester {i["semester"] or "—"}</small></div>',
            f'<div class="mf-risk">{ui.badge(i["level"])}<div>{ui.bar(i["score"], color=background, width="88px")}'
            f'{"" if i["score"] is None else i["score"]}</div></div>',
            f'<div class="mf-deadline">{_deadline_pill(i)}<small>{ui.br_date(i["deadline_at"])[:10]}</small></div>',
            resp, _status(i)]))
    clicked = ui.table_name(key, ["Student", "Risk", "Deadline", "Owner", "Status"], QUEUE_COLUMNS[:5], rows,
                        "Open", primary=True,
                        footer=f'<span>Showing {len(items)} of {total} alerts · sorted by risk and deadline · '
                               f'refreshes every 20 s</span><span>{ui.icon("lock", 13)}Every action is recorded '
                               'in the history</span>')
    if clicked is not None:
        ui.ir("alerts", open_alert=clicked)
        st.rerun()


def queue():
    profile = st.session_state.get("profile")
    if st.session_state.get("open_alert"):
        detail(st.session_state["open_alert"])
        return
    left, dir_ = st.columns([3, 1.4], vertical_alignment="top")
    with left:
        ui.header("Alert queue", "Prioritized list · Critical before High, then deadline, score, trend and "
                     "time without contact (RN03, RF18) · deadlines: Critical 48 hours, High 5 business days", "Followup")
    dir_.markdown(f'<div style="text-align:right;margin-top:18px">{ui.decision_badge()}</div>', unsafe_allow_html=True)
    _queue_kpis(profile)

    qp = st.query_params
    c1, c2, c3, c4, c5 = st.columns([1.2, 1.2, 1, 1, 0.8], vertical_alignment="bottom")
    status = c1.selectbox("Status", list(STATUSES), index=list(STATUSES).index(qp.get("status", "Active"))
                            if qp.get("status") in STATUSES else 0)
    initial_level = st.session_state.pop("level_queue_filter", None) or qp.get("level")
    level = c2.selectbox("Risk", list(LEVELS), index=list(LEVELS).index(initial_level) if initial_level in LEVELS else 0)
    overdue = c3.toggle("Overdue only", value=qp.get("overdue") == "1")
    without_resp = c4.toggle("No owner", value=qp.get("without_resp") == "1") if profile == "COORDINATION" else False
    st.query_params.update({"status": status, "level": level, "overdue": "1" if overdue else "0",
                            "without_resp": "1" if without_resp else "0"})
    page = c5.number_input("Page", min_value=1, value=1, step=1)

    @st.fragment(run_every="20s")
    def _table():
        with ui.section():
            r = client.get("/api/v1/alerts", status=STATUSES[status], level=LEVELS[level],
                            only_overdue=str(overdue).lower(), without_owner=str(without_resp).lower(),
                            limit=25, page=int(page))
            items = r["items"]
            if not items:
                with ui.dashboard("empty_queue"):
                    st.markdown(f'<div style="text-align:center;padding:24px 0">{ui.icon("inbox", 28, ui.COLOR["deep"])}'
                                '<div class="mf-h3" style="margin-top:8px">No alert in this slice</div>'
                                '<div class="mf-h3sub">Change the filters above to see other alerts.</div></div>',
                                unsafe_allow_html=True)
                return
            queue_table(items, r["total"])
            if profile in ("COORDINATION", "SUPPORT_CENTER"):
                ui.export_button(items, ["enrollment", "name", "level", "score", "status", "deadline_at", "owner"],
                                  "Alert queue", "alerts_queue.csv")

    _table()


def detail(alert_id: int):
    profile = st.session_state.get("profile")
    left, dir_ = st.columns([1, 1], vertical_alignment="center")
    with left:
        if ui.go_back("Back to the queue", "go_back_queue"):
            st.session_state.pop("open_alert", None)
            st.rerun()
    dir_.markdown(f'<div style="text-align:right">{ui.decision_badge()}</div>', unsafe_allow_html=True)
    a = None
    with ui.section():
        a = client.get(f"/api/v1/alerts/{alert_id}")
    if a is None:
        return
    overdue = ui.pill("Deadline passed", ui.COLOR["text"], "#FFFFFF", "clock") if a["overdue"] else ""
    actions = ui.hero(a["name"], ui.badge(a["level"]) + " " + overdue, [
        ("id-card", f"Student ID {a['enrollment']}"), ("clock", f"Deadline {ui.br_date(a['deadline_at'])}"),
        ("user", f"Owner: {a.get('owner') or 'not assigned'}"),
        ("list-checks", LABEL_STATUS.get(a["status"], a["status"]))])
    with actions:
        ui.link("Open student record", "record", "open_alert_record", "file-user", enrollment_record=a["enrollment"])
    if a.get("underage"):
        st.warning("Student under 18: contact follows the institutional protocol with the legal guardian (RN16).")

    tab = st.tabs(["History", "Record action", "Assign", "Close", "Wrong classification"])
    with tab[0]:
        events = list(reversed(a["events"]))
        st.markdown("".join(
            f'<div class="mf-time{" current" if n == 0 else ""}"><b>{e["kind"].replace("_", " ").capitalize()}'
            f'{" · " + e["action_type"].replace("_", " ").lower() if e.get("action_type") else ""}</b>'
            f'<small>{ui.br_date(e["moment"])} · {html.escape(e["author"])}</small>'
            f'{"<p>" + html.escape(e["description"]) + "</p>" if e.get("description") else ""}</div>'
            for n, e in enumerate(events)) or "<small>No events.</small>", unsafe_allow_html=True)
        if a.get("closing"):
            enc = a["closing"]
            st.success(f"Closed on {ui.br_date(enc['closed_at'])}: cause {enc['cause']}, outcome {enc['outcome']}.")

    with tab[1]:
        if a["status"] == "CLOSED":
            st.caption("Alert closed.")
        else:
            with st.form("action"):
                kind = st.selectbox("Action type", list(ACTION_TYPES))
                description = st.text_area("What was done", max_chars=1000)
                visible = st.checkbox("Show this record to the student")
                if st.form_submit_button("Record action", type="primary"):
                    with ui.section():
                        client.post(f"/api/v1/alerts/{alert_id}/actions",
                                     {"action_type": ACTION_TYPES[kind], "description": description, "visible_to_student": visible})
                        st.success("Record saved in the history.")
                        st.rerun()

    with tab[2]:
        if not a.get("can_assign"):
            if a.get("can_manage") and a["status"] == "OPEN" and st.button("Take over the service"):
                with ui.section():
                    client.patch(f"/api/v1/alerts/{alert_id}", {"assume": True})
                    st.rerun()
            st.caption("Only coordination assigns alerts.")
        else:
            with ui.section():
                resp = client.get("/api/v1/alerts/owners")
                options = {f"{r['name']} ({'SSC' if r['profile'] == 'SUPPORT_CENTER' else 'Coordination'}) · "
                          f"{r['open_alerts']}/{r['ceiling']} alerts": r["user_id"] for r in resp}
                choice = st.selectbox("Owner", list(options))
                if st.button("Assign", type="primary"):
                    client.patch(f"/api/v1/alerts/{alert_id}", {"owner_id": options[choice]})
                    st.success("Alert assigned.")
                    st.rerun()

    with tab[3]:
        if not a.get("can_manage"):
            st.caption("Closing belongs to coordination or to the SSC owner.")
        else:
            st.warning("Closing cannot be undone. Cause and outcome are required (CA20).")
            with st.form("close"):
                cause = st.selectbox("Identified cause", list(CAUSES))
                outcome = st.selectbox("Outcome", list(OUTCOMES))
                contact = st.radio("Was there contact with the student?", ["Yes", "No"], horizontal=True)
                channel = st.selectbox("Contact channel", list(CHANNELS))
                actions = st.text_area("Actions taken", max_chars=1000)
                if st.form_submit_button("Close alert", type="primary"):
                    with ui.section():
                        client.post(f"/api/v1/alerts/{alert_id}/closing", {
                            "cause": CAUSES[cause], "outcome": OUTCOMES[outcome], "there_was_contact": contact == "Yes",
                            "contact_channel": CHANNELS[channel] if contact == "Yes" else None, "executed_actions": actions})
                        st.success("Alert closed.")
                        st.rerun()

    with tab[4]:
        if profile not in ("TEACHER", "COORDINATION"):
            st.caption("Teacher and coordination can mark the classification as wrong.")
        else:
            with st.form("divergence"):
                just = st.text_area("Why does the classification seem wrong?", max_chars=1000)
                if st.form_submit_button("Record divergence"):
                    with ui.section():
                        client.post(f"/api/v1/alerts/{alert_id}/divergence", {"justification": just})
                        st.success("Recorded. The mark goes into the model quality report (RF20).")


def students_table(items: list[dict], total: int | None = None, key: str = "students"):
    rows = []
    for i in items:
        background = ui.BADGE.get(i["risk_level"] or "PENDING", ui.BADGE["PENDING"])[0]
        rows.append((i["enrollment"], [
            ui.person(i["name"], i["enrollment"]), f'semester {i["semester"] or "—"}', ui.badge(i["risk_level"]),
            f'<div class="mf-risk"><div>{ui.bar(i["score"], color=background, width="88px")}'
            f'{"—" if i["score"] is None else i["score"]}</div></div>']))
    if not rows:
        st.info("No student in this slice.")
        return
    clicked = ui.table_name(key, ["Student", "Semester", "Risk", "Score"], [2.6, 1, 1.2, 1.2], rows, "Open record",
                        footer=f"<span>Showing {len(items)}" + (f" of {total}" if total is not None else "")
                               + " students · vulnerability shown only as a qualitative band in the record</span>")
    if clicked is not None:
        ui.ir("record", enrollment_record=clicked)
