import html

import streamlit as st

import client
import ui

SERVICE_NAME = {"api": "Data API", "chat": "Assistant", "calculation": "Calculation service", "dashboard": "Dashboard"}
PROFILES = {"Student": "STUDENT", "Teacher": "TEACHER", "Coordination": "COORDINATION", "SSC": "SUPPORT_CENTER",
          "Finance office": "FINANCE", "Management": "BOARD", "Technical administration": "ADMIN",
          "Data protection officer": "DPO"}


def hub():
    ui.header("Technical view", "Service health, calculation queue and administration shortcuts · no student data",
                 "Technical administration")

    @st.fragment(run_every="15s")
    def _services():
        with ui.section("Services"):
            r = client.get("/api/v1/admin/services")
            cols = st.columns(max(len(r["services"]), 1) + 1)
            for col, s in zip(cols, r["services"]):
                with col:
                    ui.card(SERVICE_NAME.get(s["service"], s["service"]), "up" if s["in_ar"] else "no signal",
                            f"last signal {s['seconds_since_signal']} s ago",
                            "circle-check" if s["in_ar"] else "circle-x")
            with cols[-1]:
                ui.card("Recalculation queue", r["students_in_calculation_queue"], "students waiting", "hourglass")
            st.caption("Each service runs in a separate process: if one goes down, the others keep going.")
    _services()

    with st.container(horizontal=True):
        ui.link("Data loads", "loads", "loads_h", "database")
        ui.link("Users", "users", "h_usu", "users")
        ui.link("Technical logs", "records", "h_reg", "terminal")
    with ui.section("Recalculate scores"):
        with st.form("recalculation"):
            course = st.text_input("Course (optional, code)", max_chars=12).strip().upper() or None
            semester = st.number_input("Semester (0 = all)", 0, 20, 0)
            if st.form_submit_button("Queue recalculation"):
                r = client.post("/api/v1/calculations", {"course": course, "semester": int(semester) or None})
                st.success(f"{r['queued_students']} student(s) queued. The calculation service processes them next.")


def _report(r: dict):
    rej = r.get("rejections") or []
    st.markdown(f"Load {r['load_id']} {ui.pill(r['status'].replace('_', ' ').capitalize(), outline=True)} · "
                f"{r.get('total_rows')} rows, {r.get('valid_rows')} valid", unsafe_allow_html=True)
    if rej:
        st.error("No row was applied. Fix it and send it again (RN08: no partial load).")
        ui.simple_grade(rej, "Rejected rows")


def loads():
    ui.header("Data loads", "CSV separated by semicolon or comma, in UTF-8, up to 20 MB. The load is only "
                 "applied if all rows are valid and after your confirmation.", "Technical administration")
    with ui.section("Send file"):
        with st.form("load", clear_on_submit=True):
            kind = st.radio("Type", ["GRADES", "INDICATORS"], horizontal=True,
                            captions=["student_id;class_id;exam1;exam2;exam3;final_grade;attendance_pct;status",
                                      "student_id;academic_period;total_absences;pending_activities;"
                                      "failed_subjects_history;previous_semester_average"])
            file = st.file_uploader("CSV file", type=["csv"])
            if st.form_submit_button("Validate", type="primary") and file is not None:
                r = client.post("/api/v1/imports", data={"kind": kind},
                                 files={"file": (file.name, file.getvalue(), "text/csv")})
                st.session_state["open_load"] = r["load_id"]
    with ui.section("Load history"):
        items = client.get("/api/v1/imports")
        if not items:
            st.caption("No load sent.")
        weights = [0.6, 1, 2.4, 1.2, 1.4, 1, 1]
        if items:
            st.markdown('<div class="mf-table-header" style="grid-template-columns:' + " ".join(f"{p}fr" for p in weights)
                        + '"><span>No.</span><span>Type</span><span>File</span><span>Rows</span><span>Status</span>'
                        '<span></span><span></span></div>', unsafe_allow_html=True)
        for c in items:
            with st.container(key=f"lin_loads_{c['load_id']}"):
                col = st.columns(weights, vertical_alignment="center")
                col[0].markdown(f"#{c['load_id']}")
                col[1].markdown(c["kind"].capitalize())
                col[2].markdown(f'<div class="mf-est"><b>{html.escape(c["file_name"])}</b><small>'
                                f'{ui.br_date(c["sent_at"])} · {html.escape(c.get("sent_by") or "—")}</small></div>',
                                unsafe_allow_html=True)
                col[3].markdown(f"{c['valid_rows']}/{c['total_rows']} valid")
                col[4].markdown(ui.pill(c["status"].replace("_", " ").capitalize(), outline=True), unsafe_allow_html=True)
                if col[5].button("Details", key=f"cd{c['load_id']}"):
                    st.session_state["open_load"] = c["load_id"]
                if c["status"] == "VALIDATED" and col[6].button("Confirm", key=f"cc{c['load_id']}", type="primary"):
                    r = client.post(f"/api/v1/imports/{c['load_id']}/confirmation")
                    st.success(r["note"])
                    st.rerun()
    if opened := st.session_state.get("open_load"):
        with ui.section(f"Report of load {opened}"):
            r = client.get(f"/api/v1/imports/{opened}")
            _report(r)
            st.caption(f"SHA-256: {r.get('hash_sha256')}" + (f" · result: {r['result']}" if r.get("result") else ""))
            if r["status"] == "VALIDATED" and st.button("Cancel this load"):
                client.post(f"/api/v1/imports/{opened}/cancellation")
                st.rerun()


def users():
    ui.header("Users and access profiles", "Accounts, profiles and temporary passwords · every change goes into the audit "
                 "trail", "Technical administration")
    with ui.section("Create account"):
        with st.form("new", clear_on_submit=True):
            c1, c2, c3 = st.columns(3)
            name = c1.text_input("Name", max_chars=120)
            login = c2.text_input("Login", max_chars=64)
            profile = c3.selectbox("Profile", list(PROFILES))
            c4, c5, c6 = st.columns(3)
            course_id = c4.text_input("Course (coordination/SSC)", max_chars=12).strip().upper() or None
            id_prof = c5.text_input("Professor code (teacher)", max_chars=40).strip() or None
            student_id = c6.text_input("Student ID (student)", max_chars=7).strip().upper() or None
            if st.form_submit_button("Create", type="primary"):
                try:
                    r = client.post("/api/v1/admin/users", {"name": name, "login": login, "profile": PROFILES[profile],
                                                                "course_id": course_id, "id_professor": id_prof,
                                                                "student_id": student_id})
                    st.success(f"Account {r['login']} created. Temporary password: `{r['temporary_password']}`. {r['notice']}")
                except client.ApiError as e:
                    st.error(e.message + (" " + "; ".join(c["message"] for c in e.fields) if e.fields else ""))
    with ui.section("Accounts"):
        c1, c2, c3 = st.columns([1, 2, 1])
        filter_value = c1.selectbox("Profile", ["All"] + list(PROFILES))
        search = c2.text_input("Search by login or name", max_chars=60)
        page = c3.number_input("Page", 1, 10_000, 1)
        r = client.get("/api/v1/admin/users", profile=PROFILES.get(filter_value), search=search.strip() or None,
                        limit=50, page=int(page))
        st.caption(" · ".join(f"{x['profile'].lower()}: {x['active']}/{x['total']} active, {x['first_access']} without "
                              "first access" for x in r["summary"]))
        weights = [2.6, 1.4, 1.6, 1, 1, 1]
        st.markdown('<div class="mf-table-header" style="grid-template-columns:' + " ".join(f"{p}fr" for p in weights)
                    + '"><span>Account</span><span>Profile</span><span>Status</span><span></span><span></span>'
                    '<span></span></div>', unsafe_allow_html=True)
        for u in r["items"]:
            with st.container(key=f"lin_usu_{u['user_id']}"):
                col = st.columns(weights, vertical_alignment="center")
                col[0].markdown(ui.person(u.get("name") or u["login"], u["login"] + (" · demo" if u.get("demo")
                                                                                      else "")), unsafe_allow_html=True)
                col[1].markdown(ui.pill(u["profile"].replace("_", " ").capitalize()), unsafe_allow_html=True)
                col[2].markdown(f'<div class="mf-est">{ui.pill("Active" if u["active"] else "Disabled", outline=True)}'
                                f'{" " + ui.pill("Blocked", ui.COLOR["errBg"], ui.COLOR["errFg"], "lock") if u["blocked"] else ""}'
                                f'<small>last access {ui.br_date(u.get("last_login"))}</small></div>',
                                unsafe_allow_html=True)
                if col[3].button("Disable" if u["active"] else "Enable", key=f"at{u['user_id']}"):
                    client.patch(f"/api/v1/admin/users/{u['user_id']}", {"active": not u["active"]})
                    st.rerun()
                if col[4].button("New password", key=f"rs{u['user_id']}"):
                    s = client.patch(f"/api/v1/admin/users/{u['user_id']}", {"reset_password": True})
                    st.success(f"Temporary password for {u['login']}: `{s['temporary_password']}` (shown only now).")
                if u["blocked"] and col[5].button("Unlock", key=f"db{u['user_id']}"):
                    client.patch(f"/api/v1/admin/users/{u['user_id']}", {"unlock": True})
                    st.rerun()


def parameters_table(data: dict):
    def _value(p):
        changed = p["srs_default"] is not None and p["value"] != p["srs_default"]
        unit = f' <small>{ui.txt(p["unit"])}</small>' if p.get("unit") else ""
        return f'<span class="mf-grade-pill{" changed" if changed else ""}">{ui.txt(format(p["value"], "g"))}</span>{unit}'

    ui.grade(["Parameter", ("Value", "c"), ("SRS default", "c"), ("Allowed range", "c"), "Who changes it"],
             [[ui.double_cell(p["key"], p["description"]), _value(p),
               ui.txt(None if p["srs_default"] is None else f"{p['srs_default']:g}"),
               ui.txt(f"{p['minimum']:g} to {p['maximum']:g}"), ui.txt(p["who_changes"])] for p in data["parameters"]],
             "Value in gold: different from the SRS default.", "Parameters")
    with st.expander("Versions"):
        ui.grade(["Version", "Created at", "Author", "Approver", "Justification"],
                 [[ui.txt(v["version"]), ui.txt(ui.br_date(v["created_at"])), ui.txt(v["author"]),
                   ui.txt(v["approver"]), ui.txt(v["justification"])] for v in data["versions"]],
                 label="Parameter versions")


def parameters():
    ui.header("Configurable parameters", "Every change creates a new version; old scores keep the version "
                 "that generated them (RN22). Minimum grade and risk cutoffs need coordination approval.",
                 "Technical administration")
    with ui.section("Current parameters"):
        data = client.get("/api/v1/parameters")
        parameters_table(data)
        editable = {p["key"]: p for p in data["parameters"] if p["who_changes"].startswith("Administration")}
        with st.form("parameter"):
            key = st.selectbox("Parameter", list(editable),
                                 format_func=lambda k: f"{k} · {editable[k]['description']}")
            value = st.number_input("New value", value=float(editable[key]["value"]) if key else 0.0, step=0.1)
            just = st.text_input("Justification (minimum 10 characters)", max_chars=500)
            if st.form_submit_button("Save", type="primary"):
                try:
                    r = client.put(f"/api/v1/parameters/{key}", {"value": value, "justification": just})
                    st.success(("Proposal sent to coordination. " if r["status"] == "PENDING"
                                else f"Version {r['version']} created. ") + r["note"])
                except client.ApiError as e:
                    st.error(e.message + (" " + "; ".join(c["message"] for c in e.fields) if e.fields else ""))
        ui.dashboard_title("Proposals")
        if not data["proposals"]:
            st.caption("No proposals.")
        else:
            ui.grade(["Parameter", ("De", "c"), ("For", "c"), "Status", "Proposed by", "Decided by", "Em"],
                     [[ui.txt(p["key"]), ui.txt(p["previous_value"]), ui.txt(p["new_value"]),
                       ui.status_cell(p["status"]), ui.txt(p["proposed_by"]), ui.txt(p.get("decided_by")),
                       ui.txt(ui.br_date(p["proposed_at"]))] for p in data["proposals"]], label="Proposals")


def records():
    ui.header("Technical logs", "Service errors and events · contains no student data",
                 "Technical administration")
    c1, c2, c3 = st.columns(3)
    service = c1.selectbox("Service", ["All"] + list(SERVICE_NAME), format_func=lambda s: SERVICE_NAME.get(s, s))
    level = c2.selectbox("Level", ["All", "ERROR", "NOTICE", "INFO"])
    page = c3.number_input("Page", 1, 10_000, 1)

    @st.fragment(run_every="30s")
    def _list():
        with ui.section():
            rows = client.get("/api/v1/admin/records", service=service, level=level, limit=100, page=int(page))
            if not rows:
                st.caption("No record in this slice.")
                return
            tone = {"ERROR": ("errBg", "errFg", "circle-x"), "NOTICE": ("goldSoft", "text", "triangle-alert"),
                   "INFO": ("infoBg", "infoFg", "info")}
            ui.grade(["Moment", "Service", "Level", "Event and message", "Request"],
                     [[ui.txt(ui.br_date(l["moment"])), ui.txt(l["service"]),
                       ui.pill(l["level"] or "—", ui.COLOR[tone.get(l["level"], tone["INFO"])[0]],
                                 ui.COLOR[tone.get(l["level"], tone["INFO"])[1]], tone.get(l["level"], tone["INFO"])[2]),
                       ui.double_cell(l["event"], l["message"]), (f'<code>{ui.txt(l["request_id"])}</code>' if l["request_id"] else ui.txt(None))]
                      for l in rows], label="Technical logs")
    _list()
