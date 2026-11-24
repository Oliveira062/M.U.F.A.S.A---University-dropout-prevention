import html

import pandas as pd
import plotly.graph_objects as go
import streamlit as st

import shell
import client
import ui

TREND_LABEL = {"IMPROVEMENT": "↘ improving", "STABLE": "→ stable", "DECLINE": "↗ worsening",
                    "SUSTAINED_DECLINE": "⇈ sustained worsening", None: "not enough history"}


def _choose_enrollment() -> str | None:
    current = st.session_state.get("enrollment_record") or st.query_params.get("m")
    typed = st.text_input("Student ID", value=current or "", max_chars=7,
                             help="Open it from the alert queue, from the student list or type the student ID.")
    enrollment = (typed or "").strip().upper()
    if enrollment:
        st.session_state["enrollment_record"] = enrollment
        st.query_params["m"] = enrollment
    return enrollment or None


def history_chart(series: list[dict], cutoffs=(25, 50, 75)):
    if not series:
        st.caption("No calculation history.")
        return
    df = pd.DataFrame(series)
    df["when"] = pd.to_datetime(df["calculated_at"])
    fig = go.Figure()
    for cutoff, name in zip(cutoffs, ("Low | Moderate", "Moderate | High", "High | Critical")):
        fig.add_hline(y=cutoff, line_width=1, line_dash="dot", line_color=ui.COLOR["text3"],
                      annotation_text=name, annotation_position="top left",
                      annotation_font_color=ui.COLOR["text3"], annotation_font_size=11)
    fig.add_trace(go.Scatter(x=df["when"], y=df["score"], mode="lines+markers", name="Score",
                             line=dict(color=ui.COLOR["deep"], width=2), marker=dict(size=9, color=ui.COLOR["deep"],
                                                                                   line=dict(width=2, color="#FFFFFF")),
                             customdata=df[["level", "parameters_version"]].fillna("").values,
                             hovertemplate="%{x|%d/%m/%Y %H:%M}<br>Score %{y}<br>Level %{customdata[0]}"
                                           "<br>Parameters %{customdata[1]}<extra></extra>"))
    fig.update_layout(height=260, margin=dict(l=10, r=10, t=10, b=10), showlegend=False,
                      paper_bgcolor="rgba(0,0,0,0)", plot_bgcolor="rgba(0,0,0,0)",
                      yaxis=dict(range=[0, 100], gridcolor="#F0E5C8",
                                 title=None), xaxis=dict(title=None, showgrid=False),
                      font=dict(color=ui.COLOR["text"]), hoverlabel=dict(bgcolor="#FFFFFF"))
    st.plotly_chart(fig, use_container_width=True, config={"displayModeBar": False})
    with st.expander("View as table"):
        ui.grade(["Calculated at", ("Score", "c"), "Level", "Level source", "Parameter version"],
                 [[ui.txt(ui.br_date(l["calculated_at"])), ui.grade_cell(l["score"], None, 0), ui.badge(l["level"]),
                   ui.txt((l.get("origin_level") or "").replace("_", " ").lower() or None),
                   ui.txt(l.get("parameters_version"))] for l in series], label="Score history")


FACTOR_CATEGORY = {"grades": "Academic", "attendance": "Academic", "failure": "Academic",
                   "lms_engagement": "Academic", "finance": "Socioeconomic", "work": "Socioeconomic",
                   "dependents": "Socioeconomic", "commute": "Context", "housing": "Context",
                   "mental_health": "Health", "physical_health": "Health"}
CUTOFFS = (25, 50, 75)


def score_scale(score):
    limits = (0,) + CUTOFFS + (100,)
    bands = "".join(f'<div style="flex:{limits[i + 1] - limits[i]};background:{ui.BADGE[n][0]}"></div>'
                     for i, n in enumerate(("LOW", "MODERATE", "HIGH", "CRITICAL")))
    brand = "" if score is None else f'<div class="mf-mk-scale"><i style="left:calc({min(max(score, 0), 100)}% - {3 if score >= 100 else 1}px)"></i></div>'
    return (f'<div class="mf-scale">{bands}</div>{brand}<div class="mf-num-scale">'
            + "".join(f"<span>{v}</span>" for v in limits) + "</div>")


def score_block(score: dict):
    value = score.get("score")
    c1, c2 = st.columns([1, 2.4], vertical_alignment="center")
    c1.markdown(f'<div class="mf-score">{"—" if value is None else value}<small>/100</small></div>'
                f'<div style="color:{ui.COLOR["deep"]};font-weight:600;font-size:14px;margin-top:4px">Classification: '
                f'{ui.LEVEL_NAME.get(score.get("level") or "PENDING")}</div>', unsafe_allow_html=True)
    parts = [f"Updated on {ui.br_date(score.get('calculated_at'))}",
              f"model {score.get('model_version', '—')}", f"parameters {score.get('parameters_version', '—')}",
              f"completeness {ui.br_number((score.get('completeness') or 0) * 100, 0)}%",
              f"trend {TREND_LABEL.get(score.get('trend'), score.get('trend'))}"]
    c2.markdown(score_scale(value) + f'<div class="mf-h3sub" style="margin-top:10px">{" · ".join(parts)}</div>',
                unsafe_allow_html=True)
    if score.get("explanation"):
        st.markdown(f'<div style="font-size:14px;color:{ui.COLOR["text"]}">{html.escape(score["explanation"])}</div>',
                    unsafe_allow_html=True)
    if score.get("origin_level") == "OVERLAP":
        st.info(f"Level raised by overlap rule: {score.get('overlap_reason')}")
    if score.get("partial"):
        st.warning("Partial score: less than 70% of the data available.")
    if score.get("notice"):
        st.caption(score["notice"])


def factors_list(factors: list[dict]):
    if not factors:
        st.caption("No factor to show.")
        return
    maximum = max([f.get("points_contribution") or 0 for f in factors] + [1])

    def _weight(f):
        points = f.get("points_contribution")
        category = FACTOR_CATEGORY.get(f.get("factor"))
        cat = ui.pill(category) if category else ""
        if points is not None:
            return (f'{ui.bar(points, maximum, ui.COLOR["mustard"], "96px")}'
                    f'<span>+{ui.br_number(points)} pts</span>{cat}')
        return (ui.pill(f"band {f['band']}") if f.get("band") else "") + cat

    ui.factor_cards([f for f in factors if f.get("factor") != "referred"], _weight)
    if any(f.get("factor") == "referred" for f in factors):
        ui.restricted("Context factor referred to the support center (restricted details, LGPD). "
                    "Its contribution is included in the score.")


def timeline(series: list[dict], limit: int = 6):
    if not series:
        st.caption("No calculation history.")
        return
    recent = list(reversed(series))[:limit]
    st.markdown("".join(
        f'<div class="mf-time{" current" if n == 0 else ""}"><div style="display:flex;justify-content:space-between;'
        f'gap:8px;align-items:center"><div><b>{ui.br_date(h["calculated_at"])[:10]}</b><small>Score {h["score"]}'
        f'</small></div>{ui.badge(h["level"])}</div></div>' for n, h in enumerate(recent)), unsafe_allow_html=True)
    st.caption("Old classifications are never overwritten.")


def record():
    profile = st.session_state.get("profile")
    top, _ = st.columns([1, 3])
    with top:
        enrollment = _choose_enrollment()
    if not enrollment:
        ui.header("Student record", "Open it from the alert queue, from the student list or type the student ID.",
                     "Followup")
        return

    data = None
    with ui.section():
        data = client.get(f"/api/v1/students/{enrollment}")
        a = data.get("alert")
        meta = [("id-card", f"Student ID {data['enrollment']}"),
                ("graduation-cap", f"{data.get('course') or ''} · semester {data.get('semester') or '—'}")]
        if a:
            meta.append(("bell-ring", f"Alert {a['status'].replace('_', ' ').lower()} · deadline "
                                      f"{ui.br_date(a['deadline_at'])}"))
        actions = ui.hero(data["name"], ui.badge(a["level"]) if a else "", meta)
        with actions:
            if a and st.button("Open the alert", key="open_record_alert", type="primary"):
                ui.ir("alerts", open_alert=a["alert_id"])
    if data is None:
        return

    sidebar = profile != "FINANCE"
    ui.css("[data-testid='stLayoutWrapper']:has(> .st-key-pn_s_classification_history),"
           " .st-key-pn_s_classification_history { height:auto !important; }")
    if sidebar:
        main, side = st.columns([1.7, 1], gap="medium")
    else:
        main, side = st.container(), None

    with main:
        @st.fragment(run_every="30s")
        def _live_score():
            with ui.section("Risk score", key="score"):
                score = client.get(f"/api/v1/students/{enrollment}/score")
                st.markdown(f'<div style="margin:-6px 0 8px 0">{ui.decision_badge()}</div>', unsafe_allow_html=True)
                score_block(score)
            with ui.section("Factors that explain the classification",
                          "Contribution of each factor to the score", key="factors"):
                factors_list(score.get("factors", []))
                if score.get("modifiers"):
                    st.caption("Modifiers: " + "; ".join(
                        f"{m['id']} {m['description']} ({'+' if m['delta'] >= 0 else ''}{ui.br_number(m['delta'], 0)})"
                        for m in score["modifiers"]))

        _live_score()

    if side is not None:
        with side:
            if profile in ("COORDINATION", "SUPPORT_CENTER"):
                with ui.section("Action recommendations"):
                    rec = client.get(f"/api/v1/students/{enrollment}/recommendations")
                    st.markdown(
                        "".join(f'<div class="mf-card" style="height:auto;margin-bottom:10px;padding:14px 16px">'
                                f'<b style="font-size:14px;color:{ui.COLOR["text"]}">{html.escape(r["text"])}</b>'
                                f'<div class="leg" style="display:flex;justify-content:space-between;gap:8px">'
                                f'<span>{ui.icon("link-2", 12)} Factor: {html.escape(r.get("label_factor") or "—")}</span>'
                                f'<span>{html.escape(r["service_profile"])}</span></div></div>'
                                for r in rec["recommendations"]), unsafe_allow_html=True)
                    if not rec["recommendations"]:
                        st.caption(rec.get("note", ""))
                    st.caption("The recommendation is a support: the team decides and records the action.")
            with ui.section("Classification history"):
                series = client.get(f"/api/v1/students/{enrollment}/history")
                timeline(series)
                with st.expander("View evolution chart"):
                    history_chart(series)

    if profile != "FINANCE":
        with ui.section("Academic indicators"):
            ac = (data or {}).get("academic")
            if ac:
                a1, a2 = st.columns(2)
                with a1:
                    ui.card("Period average", ui.br_number(ac["current_average"], 2), "weighted by workload",
                            "book-open")
                with a2:
                    ui.card("Attendance", f"{ui.br_number(ac['attendance_pct'])}%", "minimum of 75%", "calendar-check")
            else:
                st.caption("No academic indicators.")

        with ui.section("Subjects"):
            subj = client.get(f"/api/v1/students/{enrollment}/subjects")
            ui.grade(["Subject", ("Final grade", "c"), "Attendance", "Status"],
                     [[ui.double_cell(d["subject"], d["academic_period"]), ui.grade_cell(d["final_grade"], 6.0),
                       ui.attendance_cell(d["attendance_pct"], 75.0), ui.status_cell(d["status"])]
                      for d in subj["subjects"]],
                     "In red, below the minimum grade (6.0) or the minimum attendance (75%). Remaining absences (RF17): "
                     "no data, because the database does not record expected classes or absences per subject.",
                     "Student subjects")

    if profile in ("COORDINATION", "SUPPORT_CENTER", "FINANCE") and data:
        with ui.section("Socioeconomic context"):
            if profile == "COORDINATION":
                st.write(f"Socioeconomic vulnerability: **{data.get('socioeconomic_vulnerability') or 'no data'}**")
                ui.restricted("Income, work and health values stay with the SSC (Annex E).")
            elif profile == "FINANCE":
                fin = data.get("finance") or {}
                st.write(f"Income per person: **{ui.br_number(fin.get('per_capita_income_mw'), 2)} minimum wage(s)** · "
                         f"aid: **{fin.get('scholarship_aid') or 'no data'}**")
                ui.restricted("Health and detailed performance do not appear for the finance office.")
            else:
                soc = data.get("socioeconomic") or {}
                st.write(f"Income per person: R$ {ui.br_number(soc.get('per_capita_income'), 2)} · "
                         f"work: {soc.get('works') or 'no data'} ({soc.get('daily_work_hours') or 0} h/day) · "
                         f"commute: {soc.get('commute_time_min') or 'no data'} min · "
                         f"aid: {soc.get('scholarship_aid') or 'no data'}")
                support = data.get("support") or {}
                if support.get("available") is False:
                    st.warning(support.get("reason"))
                else:
                    st.write(f"Psychosocial support requested: {support.get('requested_psychosocial_support') or 'no data'} · "
                             f"accessibility need: {support.get('accessibility_need') or 'no data'}")
                    st.caption("Sensitive data (LGPD, art. 11): this reading was recorded in the audit trail.")

    with ui.section("Followup"):
        hist = client.get(f"/api/v1/students/{enrollment}/followup")
        if not hist["alerts"]:
            st.caption("No alert recorded.")
        for a in hist["alerts"]:
            with st.expander(f"Alert {a['alert_id']} · {ui.LEVEL_NAME.get(a['level'], a['level'])} · "
                             f"{a['status'].replace('_', ' ').lower()} · created {ui.br_date(a['created_at'])}"):
                st.markdown("".join(
                    f'<div class="mf-time"><b>{e["kind"].replace("_", " ").capitalize()}'
                    f'{" · " + e["action_type"].replace("_", " ").lower() if e.get("action_type") else ""}</b>'
                    f'<small>{ui.br_date(e["moment"])} · {html.escape(e["author"])}</small>'
                    f'{"<p>" + html.escape(e["description"]) + "</p>" if e.get("description") else ""}</div>'
                    for e in a["events"]), unsafe_allow_html=True)
        for g in hist.get("appointments", []):
            st.markdown(f'<div class="mf-row"><div><b>{ui.icon("calendar", 14)} {ui.br_date(g["start"])}</b>'
                        f'<small>{html.escape(g["status"].lower())}'
                        f'{" · exception: " + html.escape(g["exception_reason"]) if g.get("exception_reason") else ""}'
                        '</small></div></div>', unsafe_allow_html=True)

    if profile == "TEACHER":
        ui.restricted("You see academic indicators. Income, work, health and housing stay with the SSC.")


def notifications():
    ui.header("Notifications", "Notices of alerts, deadlines and parameters · refreshes every 20 s")

    @st.fragment(run_every="20s")
    def _list():
        with ui.section():
            items = client.get("/api/v1/account/notifications", limit=50)
            with ui.dashboard("notifications"):
                e, d = st.columns([3, 1], vertical_alignment="center")
                e.markdown('<div class="mf-h3">Notifications</div>', unsafe_allow_html=True)
                if not items:
                    st.caption("Nothing here. Notices of alerts, deadlines and parameters appear on this screen.")
                    return
                with d:
                    if ui.link_text("Mark all as read", "read_all"):
                        client.post("/api/v1/account/notifications/reading")
                        st.rerun()
                for n in items:
                    new = not n["read_at"]
                    icon = "clock" if "deadline" in n["title"].lower() else (
                        "sliders-horizontal" if "parameter" in n["title"].lower() else "bell")
                    with st.container(key=f"lin_not_{n['notification_id']}"):
                        st.markdown(
                            f'<div style="display:flex;gap:14px;align-items:flex-start">'
                            f'<span class="mf-icbox" style="width:36px;height:36px;border-radius:10px">{ui.icon(icon, 18)}</span>'
                            f'<div style="flex:1"><b style="font-size:14px">{html.escape(n["title"])}</b>'
                            f'<div style="font-size:13px;color:{ui.COLOR["text"]};margin-top:4px">{html.escape(n["text"])}</div>'
                            f'<small style="font-size:12px;color:{ui.COLOR["text2"]}">{ui.br_date(n["created_at"])}</small></div>'
                            + (f'<span style="width:8px;height:8px;border-radius:999px;background:{ui.COLOR["gold"]};'
                               'margin-top:6px" aria-label="unread"></span>' if new else "")
                            + "</div>", unsafe_allow_html=True)
                        if n.get("alert_id") and st.session_state.get("profile") in ("COORDINATION", "SUPPORT_CENTER",
                                                                                     "TEACHER", "FINANCE"):
                            if ui.link_text("Open alert", f"n{n['notification_id']}"):
                                client.post(f"/api/v1/account/notifications/{n['notification_id']}/reading")
                                ui.ir("alerts", open_alert=n["alert_id"])
                    if new:
                        ui.css(f".st-key-lin_not_{n['notification_id']} {{ background:{ui.COLOR['creamSoft']}; }}")

    _list()


def my_account():
    account = st.session_state.get("account", {})
    ui.header("My account", "Your access data and password change")
    ui.hero(account.get("name") or account.get("login") or "", ui.pill(shell.PROFILE_NAME.get(account.get("profile"), "")),
             [("user", f"Login {account.get('login')}"),
              ("shield-check", f"Terms accepted on {ui.br_date(account.get('accepted_term_at'))}"),
              ("clock", f"Last access {ui.br_date(account.get('last_login'))}")])
    left, _ = st.columns([1.4, 1])
    with left:
        with st.form("change"):
            ui.dashboard_title("Change password", "At least 10 characters, with letters and numbers, without your login")
            current = st.text_input("Current password", type="password", max_chars=72)
            new = st.text_input("New password", type="password", max_chars=72)
            repeat = st.text_input("Repeat the new password", type="password", max_chars=72)
            if st.form_submit_button("Save", type="primary"):
                if new != repeat:
                    st.error("The new passwords do not match.")
                else:
                    try:
                        client.post("/api/v1/account/password", {"current_password": current, "new_password": new})
                        st.success("Password changed.")
                    except client.ApiError as e:
                        st.error(e.message + " " + "; ".join(c["message"] for c in e.fields or []))


def _css_chat():
    c = ui.COLOR
    ui.css(f"""
  .st-key-pn_chat {{ background:#FFFFFF; border:1px solid {c['line']}; border-radius:16px; padding:16px 18px; }}
  .st-key-pn_chat [data-testid="stVerticalBlock"] {{ gap:14px; }}
  [data-testid="stChatMessage"] {{ background:#FFFFFF; border:1px solid {c['line']}; border-radius:16px;
      box-shadow:0 1px 3px rgba(61,43,31,.06); padding:14px 18px; gap:12px; box-sizing:border-box; width:auto; max-width:92%; min-width:0;
      align-self:flex-start; }}
  [data-testid="stChatMessage"] > div:last-child {{ min-width:0; }}
  [data-testid="stChatMessage"]:has([data-testid="stChatMessageAvatarUser"]) {{ background:{c['text']};
      border-color:{c['text']}; flex-direction:row-reverse; max-width:78%; margin-left:auto;
      align-self:flex-end; border-bottom-right-radius:4px; }}
  [data-testid="stChatMessage"]:has([data-testid="stChatMessageAvatarAssistant"]) {{ border-bottom-left-radius:4px; }}
  [data-testid="stChatMessage"]:has([data-testid="stChatMessageAvatarUser"]) * {{ color:#FFFFFF; }}
  .mf-msg {{ font-size:14.5px; line-height:1.6; color:{c['text']}; overflow-wrap:anywhere; }}
  .mf-msg p {{ margin:0 0 10px 0; }}
  .mf-msg p:last-child, .mf-msg ul:last-child {{ margin-bottom:0; }}
  .mf-msg ul {{ list-style:none; margin:2px 0 12px 0; padding:0; display:flex; flex-direction:column; gap:6px; }}
  .mf-msg li {{ background:#FFFFFF; border:1px solid {c['lineSoft']}; border-radius:10px; padding:8px 12px; }}
  .mf-msg li b {{ font-weight:600; }}
  .mf-msg li small {{ display:block; color:{c['text2']}; font-size:12.5px; margin-top:1px; }}
  .mf-msg .mf-grade-msg {{ font-size:12.5px; color:{c['text3']}; border-top:1px solid {c['line']}; padding-top:8px;
      margin-top:4px; }}
  [data-testid="stChatMessageAvatarUser"], [data-testid="stChatMessageAvatarAssistant"] {{
      background:{c['goldSoft']}; color:{c['deep']}; }}
  .mf-chat-header {{ display:flex; align-items:center; gap:12px; padding:2px 2px 14px 2px; border-bottom:1px solid {c['lineSoft']};
      margin-bottom:4px; }}
  .mf-chat-header .av {{ width:40px; height:40px; border-radius:12px; background:{c['gold']}; color:{c['text']};
      display:flex; align-items:center; justify-content:center; flex:none; }}
  .mf-chat-header b {{ display:block; font-size:15px; font-weight:700; color:{c['text']}; }}
  .mf-chat-header small {{ display:flex; align-items:center; gap:6px; font-size:12.5px; color:{c['text2']}; }}
  .mf-chat-header small i {{ width:8px; height:8px; border-radius:999px; background:{c['okFg']}; display:inline-block; }}
  .mf-chat-label {{ display:flex; justify-content:space-between; align-items:baseline; gap:12px; margin:6px 2px 6px 2px; }}
  .mf-chat-label b {{ font-size:14px; font-weight:600; color:{c['text']}; }}
  .mf-chat-label small {{ font-size:12px; color:{c['text3']}; }}
  [data-testid="stChatInput"] {{ border:2px solid {c['gold']} !important; border-radius:16px !important;
      background:#FFFFFF !important; box-shadow:0 4px 14px rgba(140,100,16,.12); padding:6px 8px 6px 12px; }}
  [data-testid="stChatInput"] > div {{ background:transparent !important; border:none !important; height:auto !important;
      min-height:64px; align-items:flex-end !important; }}
  [data-testid="stChatInput"] > div > div:first-child, [data-testid="stChatInput"] > div > div:first-child div {{
      background:transparent !important; }}
  [data-testid="stChatInput"]:focus-within {{ border-color:{c['deep']} !important;
      box-shadow:0 0 0 4px rgba(201,151,32,.25); }}
  [data-testid="stChatInput"] textarea {{ font-size:15.5px !important; line-height:1.5 !important; min-height:64px !important;
      padding:10px 6px !important; color:{c['text']} !important; }}
  [data-testid="stChatInput"] textarea::placeholder {{ color:{c['text3']} !important; }}
  [data-testid="stChatInputSubmitButton"] {{ background:{c['gold']} !important; border-radius:12px !important;
      width:44px !important; height:44px !important; color:{c['text']} !important; align-self:flex-end; }}
  [data-testid="stChatInputSubmitButton"]:hover {{ background:{c['mustard']} !important; }}
  [data-testid="stChatInputSubmitButton"] svg {{ width:20px; height:20px; }}
  [data-testid="stChatInputSubmitButton"]:disabled {{ opacity:.45; }}
  .mf-sug-lbl {{ font-size:12px; font-weight:700; color:{c['deep']}; letter-spacing:.02em; margin:8px 2px 2px 2px; }}
  [class*="st-key-sug_"] {{ gap:8px !important; }}
  [class*="st-key-sug_"] button {{ border-radius:999px; border:1px solid {c['line']}; background:{c['creamSoft']};
      min-height:34px; padding:4px 14px; }}
  [class*="st-key-sug_"] button:hover {{ border-color:{c['gold']}; background:{c['goldSoft']}; }}
  [class*="st-key-sug_"] button p {{ font-size:13px; }}
  .mf-can div {{ display:flex; gap:8px; align-items:center; font-size:13px; color:{c['text']}; margin:8px 0; }}
""")


_METHODOLOGICAL_NOTICE_START = "The risk level shows that this student's pattern"


def _item_html(row: str, underlines: list[str]) -> str:
    text = row[2:].strip()
    label, sep, rest = text.partition(": ")
    body = (f"<b>{html.escape(label)}</b>: {html.escape(rest)}" if sep and len(label) <= 60
             else html.escape(text))
    body += "".join(f"<small>{html.escape(s.strip())}</small>" for s in underlines)
    return f"<li>{body}</li>"


def format_answer(text: str) -> str:
    blocks = []
    for block in (b for b in text.strip().split("\n\n") if b.strip()):
        rows = block.split("\n")
        if rows[0].lstrip().startswith("• "):
            items, current, subs = [], None, []
            for l in rows:
                if l.lstrip().startswith("• "):
                    if current is not None:
                        items.append(_item_html(current, subs))
                    current, subs = l.lstrip(), []
                elif current is not None and l.strip():
                    subs.append(l)
            if current is not None:
                items.append(_item_html(current, subs))
            blocks.append("<ul>" + "".join(items) + "</ul>")
        elif block.startswith(_METHODOLOGICAL_NOTICE_START):
            blocks.append(f'<p class="mf-grade-msg">{html.escape(block)}</p>')
        else:
            blocks.append("<p>" + "<br>".join(html.escape(l) for l in rows) + "</p>")
    return '<div class="mf-msg">' + "".join(blocks) + "</div>"


def assistant():
    _css_chat()
    main, side = st.columns([2.3, 1], gap="medium")
    with side:
        with ui.dashboard("chat_can"):
            ui.dashboard_title("The assistant can")
            can = (("Show your grades, attendance and risk", "Tell you what is due and what is late",
                     "Talk about routine and study tips") if st.session_state.get("profile") == "STUDENT" else
                    ("Search for students combining attendance, average, absences and pending items", "Summarize the risk of the classes",
                     "Show a student's status by student ID"))
            st.markdown('<div class="mf-can">' + "".join(
                f'<div>{ui.icon("check", 14, ui.COLOR["deep"])}{t}</div>' for t in can)
                + "</div>", unsafe_allow_html=True)
            ui.dashboard_title("The assistant cannot")
            st.markdown('<div class="mf-can">' + "".join(
                f'<div>{ui.icon("x", 14, ui.COLOR["errFg"])}{t}</div>' for t in
                ("Show data restricted to another profile", "Make decisions or change records")) + "</div>",
                unsafe_allow_html=True)
    with main:
        ui.header("Assistant", "Ask in natural language about the data your profile can see.")
        if not client.available_service("chat"):
            st.warning("The assistant is down at the moment. The rest of the dashboard keeps working.")
            return
        with ui.section():
            if "chat_opening" not in st.session_state:
                st.session_state["chat_opening"] = client.call("GET", "/api/v1/chat/opening", service="chat")
                st.session_state["chat_msgs"] = []
            ab = st.session_state["chat_opening"]
            ui.notice("Answers only with the data your profile can see and does not change anything in the system",
                     f"{ab['availability']} {ab['human_service']}", "info")
            st.markdown(f'<div class="mf-chat-header"><span class="av">{ui.icon("sparkles", 20)}</span><div>'
                        '<b>Mufa</b><small><i></i>MUFASA assistant · answers right away</small></div></div>',
                        unsafe_allow_html=True)
            with st.container(key="pn_chat", height=520, border=False):
                for role, text in [("assistant", ab["message"])] + st.session_state["chat_msgs"]:
                    with st.chat_message(role):
                        st.markdown(format_answer(text), unsafe_allow_html=True)
            suggestion = None
            if ab.get("options"):
                st.markdown('<div class="mf-sug-lbl">SUGGESTIONS TO START</div>', unsafe_allow_html=True)
                with st.container(horizontal=True, key="sug_options"):
                    for i, op in enumerate(ab["options"][:5]):
                        if st.button(op, key=f"op{i}"):
                            suggestion = op
            example = ("E.g.: what is due this week? How are my grades?" if st.session_state.get("profile") == "STUDENT"
                       else "E.g.: students with attendance below 70% and average below 5")
            st.markdown('<div class="mf-chat-label"><b>Write your question</b>'
                        '<small>Enter sends · Shift + Enter adds a line</small></div>', unsafe_allow_html=True)
            question = st.chat_input(example, max_chars=500) or suggestion
            if question:
                st.session_state["chat_msgs"].append(("user", question))
                try:
                    r = client.call("POST", "/api/v1/chat/queries", service="chat", json={"text": question})
                    answer = r["answer"] + (f"\n\n{r['notice']}" if r.get("notice") else "")
                except client.ApiError as e:
                    answer = e.message
                st.session_state["chat_msgs"].append(("assistant", answer))
                st.rerun()
