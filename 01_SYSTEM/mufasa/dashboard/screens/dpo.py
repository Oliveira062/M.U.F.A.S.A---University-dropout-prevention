from datetime import datetime, time
from zoneinfo import ZoneInfo

import streamlit as st

import client
import ui

TIMEZONE = ZoneInfo("America/Sao_Paulo")
PROFILES = ["All", "STUDENT", "TEACHER", "COORDINATION", "SUPPORT_CENTER", "FINANCE", "BOARD", "ADMIN",
          "DPO"]
ANSWERS = {"Under analysis": "IN_ANALYSIS", "Handled": "HANDLED", "Denied": "DENIED"}


def hub():
    ui.header("LGPD audit trail", "Who accessed what and when · read only · reading this trail is also "
                 "recorded", "Data protection officer")
    c1, c2, c3 = st.columns(3)
    enrollment = c1.text_input("Student ID", max_chars=7).strip().upper() or None
    profile = c2.selectbox("Profile of who accessed", PROFILES)
    result = c3.selectbox("Result", ["All", "ALLOWED", "DENIED", "BLOCKED"])
    c4, c5, c6, c7 = st.columns(4)
    operation = c4.text_input("Operation (e.g.: LOGIN)", max_chars=40).strip().upper() or None
    de = c5.date_input("De", value=None, format="DD/MM/YYYY")
    until = c6.date_input("Until", value=None, format="DD/MM/YYYY")
    page = c7.number_input("Page", 1, 10_000, 1)
    with ui.section():
        rows = client.get("/api/v1/audit", enrollment=enrollment, profile=profile, result=result,
                             operation=operation, limit=100, page=int(page),
                             de=datetime.combine(de, time.min, TIMEZONE).isoformat() if de else None,
                             until=datetime.combine(until, time.max, TIMEZONE).isoformat() if until else None)
        if not rows:
            st.caption("No record in this slice.")
            return
        denied = sum(1 for l in rows if l["result"] != "ALLOWED")
        a, b = st.columns(2)
        with a:
            ui.card("Records on this page", len(rows), "up to 100 per page", "files")
        with b:
            ui.card("Denied or blocked", denied, "on this page", "shield-x")
        table_name = [{"Moment": ui.br_date(l["moment"]), "User": l["user_id"], "Profile": l["profile"],
                   "Operation": l["operation"], "Resource": l["resource"], "Student": l["target_student_id"] or "—",
                   "Result": l["result"], "Request": l["request_id"]} for l in rows]
        with ui.dashboard("audit"):
            ui.dashboard_title("Records", "Moment, who accessed, operation, resource and result")
            tone = {"ALLOWED": ("okBg", "okFg", "check"), "DENIED": ("errBg", "errFg", "shield-x"),
                   "BLOCKED": ("errBg", "errFg", "lock"), "ERROR": ("errBg", "errFg", "circle-x")}
            ui.grade(["Moment", "Who", "Operation", "Student", "Result"],
                     [[ui.double_cell(ui.br_date(l["moment"]), l["request_id"]),
                       ui.double_cell(f'User {l["user_id"]}', (l["profile"] or "").replace("_", " ").capitalize()),
                       ui.double_cell((l["operation"] or "").replace("_", " ").capitalize(), l["resource"]),
                       ui.txt(l["target_student_id"]),
                       ui.pill((l["result"] or "—").capitalize(), *[ui.COLOR[k] for k in tone.get(l["result"], ("infoBg", "infoFg"))[:2]],
                                 tone.get(l["result"], (None, None, "info"))[2])]
                      for l in rows], label="Audit trail")
        ui.export_button(table_name, list(table_name[0]), "Audit trail", "audit.csv")


def requests():
    ui.header("Data subject requests", "Answer deadline: 15 days (LGPD, art. 19, II)", "Data protection officer")
    with ui.section():
        requests = client.get("/api/v1/privacy/requests", limit=100)
        if not requests:
            st.caption("No request recorded.")
            return
        open_count = [p for p in requests if p["status"] in ("OPENED", "IN_ANALYSIS")]
        k, _ = st.columns([1, 2])
        with k:
            ui.card("Open requests", len(open_count), "on this page", "inbox")
        weights = [0.6, 2.2, 1.4, 1.2, 1.6, 0.9]
        with ui.dashboard("requests"):
            st.markdown('<div class="mf-table-header" style="grid-template-columns:' + " ".join(f"{p}fr" for p in weights)
                        + '"><span>No.</span><span>Request</span><span>Recorded on</span><span>Status</span>'
                        '<span>Answer</span><span></span></div>', unsafe_allow_html=True)
            for p in requests:
                with st.container(key=f"lin_ped_{p['subject_request_id']}"):
                    col = st.columns(weights, vertical_alignment="center")
                    col[0].markdown(f"#{p['subject_request_id']}")
                    col[1].markdown(f'<div class="mf-est"><b>{p["kind"].replace("_", " ").capitalize()}</b>'
                                    f'<small>student {p["student_id"]}</small></div>', unsafe_allow_html=True)
                    col[2].markdown(ui.br_date(p["registered_at"]))
                    col[3].markdown(ui.pill(p["status"].replace("_", " ").capitalize(), outline=True),
                                    unsafe_allow_html=True)
                    if p["status"] in ("HANDLED", "DENIED"):
                        continue
                    new = col[4].selectbox("Answer", list(ANSWERS), key=f"sr{p['subject_request_id']}",
                                            label_visibility="collapsed")
                    if col[5].button("Save", key=f"ss{p['subject_request_id']}", type="primary"):
                        client.patch(f"/api/v1/privacy/requests/{p['subject_request_id']}",
                                      {"status": ANSWERS[new]})
                        st.rerun()
