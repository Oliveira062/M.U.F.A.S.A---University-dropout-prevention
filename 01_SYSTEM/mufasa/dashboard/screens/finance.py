import html

import streamlit as st

import client
import ui


def hub():
    left, dir_ = st.columns([3, 1.4], vertical_alignment="top")
    with left:
        ui.header("Students with a financial factor", "Students whose open alert has the financial situation among the "
                     "main factors", "Finance office")
    dir_.markdown(f'<div style="text-align:right;margin-top:18px">{ui.decision_badge()}</div>', unsafe_allow_html=True)
    ui.notice("You see pending items and eligibility for aid", "Health and detailed performance do not appear for the finance "
             "office (Annex E).", "wallet")

    @st.fragment(run_every="30s")
    def _list():
        with ui.section():
            items = client.get("/api/v1/finance/students", limit=100)
            if not items:
                st.info("No student with a financial factor in an open alert.")
                return
            rows = [(i["alert_id"], [
                ui.person(i["name"], i["enrollment"]), ui.badge(i["level"]), ui.br_date(i["deadline_at"])[:10],
                "no data" if i["per_capita_income_mw"] is None else f'{ui.br_number(i["per_capita_income_mw"], 2)} MW',
                {True: ui.pill("Yes", ui.COLOR["okBg"], ui.COLOR["okFg"], "check"),
                 False: ui.pill("No", ui.COLOR["errBg"], ui.COLOR["errFg"], "x")}.get(i["active_aid"], ui.txt(None, "no data")),
                html.escape(" / ".join(i["recommendations"]) or "—")]) for i in items]
            clicked = ui.table_name("finance", ["Student", "Risk", "Deadline", "Income per person", "Active aid",
                                               "Recommendation"], [2.2, 1.1, 1, 1.1, 0.9, 2.2], rows, "Open",
                                primary=True, footer=f"<span>Showing {len(items)} students</span>")
            if clicked is not None:
                ui.ir("alerts", open_alert=clicked)

    _list()
