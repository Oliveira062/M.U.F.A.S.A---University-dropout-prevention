import streamlit as st

import client
import charts
import ui
from screens.alerts import CAUSES

CAUSE_NAME = {v: k for k, v in CAUSES.items()}

SHIFTS = ["All", "Morning", "Afternoon", "Evening"]
TRENDS = {"All": None, "Sustained worsening": "SUSTAINED_DECLINE", "Decline": "DECLINE", "Stable": "STABLE",
              "Improvement": "IMPROVEMENT"}
FACTORS = {"All": None, "Academic performance": "grades", "Attendance": "attendance",
           "Failure history": "failure", "Financial situation": "finance", "Work": "work",
           "Commute": "commute"}
ALERT_LABEL = {"open_count": "Active alerts", "overdue": "Deadline passed", "without_owner": "No owner",
                 "in_service": "In service", "data_tasks": "Data tasks", "closed": "Closed"}


def _pct(value) -> str:
    return "no data" if value is None else f"{ui.br_number(value)}%"


def filters() -> dict:
    qp = st.query_params
    active = sum(k in qp for k in ("semester", "shift", "trend", "factor"))
    with st.container(key="filters"):
        with st.popover("Filters" + (f" · {active}" if active else ""), width="stretch"):
            semester = st.selectbox("Current semester", ["All"] + list(range(1, 11)),
                                    index=int(qp["semester"]) if qp.get("semester", "").isdigit() else 0)
            shift = st.selectbox("Shift", SHIFTS, index=SHIFTS.index(qp["shift"]) if qp.get("shift") in SHIFTS else 0)
            trend = st.selectbox("Trend", list(TRENDS),
                                     index=list(TRENDS).index(qp["trend"]) if qp.get("trend") in TRENDS
                                     else 0)
            factor = st.selectbox("Predominant factor", list(FACTORS),
                                 index=list(FACTORS).index(qp["factor"]) if qp.get("factor") in FACTORS else 0)
    for key, value in (("semester", semester), ("shift", shift), ("trend", trend), ("factor", factor)):
        if value in ("All", "All"):
            st.query_params.pop(key, None)
        else:
            st.query_params[key] = str(value)
    return {"semester": None if semester == "All" else semester, "shift": shift,
            "trend": TRENDS[trend], "factor": FACTORS[factor]}


def dashboard_css():
    c = ui.COLOR
    rules = [f"""
  .st-key-filters {{ margin-top:18px; }}
  .st-key-filters button {{ height:44px; border:1px solid {c['gold']} !important; color:{c['deep']} !important;
      padding-left:40px; position:relative; }}
  .st-key-filters button::before {{ content:""; position:absolute; left:16px; top:13px; width:16px; height:16px;
      background-color:{c['deep']}; -webkit-mask:{ui.icon_url('sliders-horizontal', '#000')} no-repeat center/contain;
      mask:{ui.icon_url('sliders-horizontal', '#000')} no-repeat center/contain; }}
  .mf-course {{ margin-top:18px; display:flex; gap:10px; align-items:center; height:44px; padding:0 16px; border:1px solid {c['line']};
              border-radius:10px; font-size:14px; font-weight:500; color:{c['text']}; white-space:nowrap; overflow:hidden; }}
  [class*="st-key-chip_"] button {{ border-radius:10px; min-height:44px; padding:4px 12px 4px 6px; justify-content:flex-start;
      gap:10px; font-weight:600; white-space:nowrap; }}
  [class*="st-key-chip_"] button p {{ white-space:nowrap; }}
  [class*="st-key-chip_"] button:disabled {{ opacity:1; cursor:default; background:#FFFFFF; color:{c['text']}; }}
  [class*="st-key-chip_"] button::before {{ border-radius:999px; padding:3px 12px 3px 30px; font-size:13px; font-weight:600;
      background-repeat:no-repeat; background-position:10px center; background-size:14px; }}
  [class*="st-key-chip_"] button::after {{ content:""; width:14px; height:14px; margin-left:auto; background-color:{c['text2']};
      -webkit-mask:{ui.icon_url('chevron-right', '#000')} no-repeat center/contain;
      mask:{ui.icon_url('chevron-right', '#000')} no-repeat center/contain; flex:none; }}
  [class*="st-key-open_"] button {{ border:none; background:transparent; width:36px; min-height:36px; padding:0; }}
  [class*="st-key-open_"] button p {{ font-size:0 !important; }}
  [class*="st-key-open_"] button::before {{ content:""; width:16px; height:16px; background-color:{c['text2']};
      -webkit-mask:{ui.icon_url('chevron-right', '#000')} no-repeat center/contain;
      mask:{ui.icon_url('chevron-right', '#000')} no-repeat center/contain; }}
  .st-key-critical_link {{ align-items:flex-end; margin-top:2px; }}
  .st-key-all_link button, .st-key-critical_link button {{ border:none; background:transparent; color:{c['deep']};
      padding:0; min-height:24px; font-weight:600; }}
"""]
    for n in ("LOW", "MODERATE", "HIGH", "CRITICAL"):
        background, text, _, name = ui.BADGE[n]
        rules.append(f".st-key-chip_{n} button::before {{ content:'{name}'; background-color:{background}; color:{text};"
                      f" background-image:{ui.icon_url(ui.LEVEL_ICON[n], text)}; }}")
    ui.css("".join(rules))


def level_chips(distribution: list[dict], profile: str):
    by = {d["level"]: d for d in distribution}
    row = st.container(horizontal=True, gap="small")
    for n in ("LOW", "MODERATE", "HIGH", "CRITICAL"):
        v = (by.get(n) or {}).get("total")
        label = "suppressed" if v is None and n in by else f"{v or 0} students"
        with row:
            clicked = st.button(label, key=f"chip_{n}", disabled=profile != "COORDINATION")
        if clicked:
            if n in ("HIGH", "CRITICAL"):
                ui.ir("alerts", open_alert=None, level_queue_filter=ui.LEVEL_NAME[n])
            else:
                ui.ir("students", level_students_filter=ui.LEVEL_NAME[n])


def calculation_header(calculation: dict):
    text = f"Updated on {ui.br_date(calculation.get('last_calculation'))}"
    if calculation.get("students_in_queue"):
        text += f" · {calculation['students_in_queue']} student(s) being recalculated"
    st.caption(text + " · automatic refresh every 20 s")
    if calculation.get("notice"):
        st.warning(calculation["notice"])


def kpis(view: dict, profile: str):
    al = view["alerts"]
    critical = next((d["total"] for d in view["distribution"] if d["level"] == "CRITICAL"), None)
    c = st.columns(4)
    with c[0]:
        ui.card("Total students", view["students"] if view["students"] is not None else "—",
                "in the slice" if view["students"] is not None else "hidden: there is a suppressed group", "users")
    with c[1]:
        ui.card("Active alerts", al["open_count"], f"{critical if critical is not None else 'suppressed'} at critical level",
                "bell-ring")
    with c[2]:
        ui.card("Deadline passed", al["overdue"], "alerts without a first action on time", "clock")
    with c[3]:
        ui.card("No owner", al["without_owner"], "waiting for assignment", "user-x")
    v = view.get("days_7_variation")
    st.caption(("Change in 7 days (students at High or Critical): " + (f"{v['difference']:+d}" if v else
                "no data (there is no calculation from 7 days ago yet)")) + " · " + view["previous_period_note"])


def dashboard(profile: str, course: str | None = None, f: dict | None = None, attention=None):
    dashboard_css()
    f = dict(f if f is not None else filters())
    if profile == "BOARD":
        f["course"] = course

    @st.fragment(run_every="30s")
    def _view():
        with ui.section():
            view = client.get("/api/v1/dashboards/general-view", **f)
            an = client.get("/api/v1/dashboards/analyses", **f)
            calculation_header(view["calculation"])
            if view.get("there_was_suppression"):
                ui.restricted("There is a group with fewer than 5 students in this slice: the small values, the total and the "
                            "percentages were suppressed to prevent re-identification (RN07, CA19).")
            kpis(view, profile)
            by = {d["level"]: d.get("total") for d in view["distribution"]}
            at_risk = None if by.get("HIGH") is None or by.get("CRITICAL") is None else by["HIGH"] + by["CRITICAL"]
            col1, col2 = st.columns([1.6, 1], gap="medium")
            with col1:
                with ui.dashboard("distribution"):
                    t, l = st.columns([1.6, 1], vertical_alignment="top")
                    with t:
                        ui.dashboard_title("Distribution by risk level",
                                         "Click a level to open the alert queue already filtered"
                                         if profile == "COORDINATION" else "Students in the slice by risk level")
                    if profile == "COORDINATION":
                        with l:
                            with st.container(key="critical_link"):
                                if st.button(f"See critical alerts ({by.get('CRITICAL') or 0})  →"):
                                    ui.ir("alerts", open_alert=None, level_queue_filter="Critical")
                    charts.distribution_band(view["distribution"])
                    level_chips(view["distribution"], profile)
            with col2:
                with ui.dashboard("factors"):
                    ui.dashboard_title("Most frequent factors", "Percentage of students at High or Critical with the factor")
                    charts.frequent_factors(an["frequent_factors"][:5], at_risk)
            col3, col4 = st.columns([1.1, 1] if attention else [1, 1], gap="medium")
            with col3:
                with ui.dashboard("evolution"):
                    ui.dashboard_title("Evolution of alerts by period", "Students at High or Critical per day, by level")
                    charts.stacked_evolution(an["evolution"])
            with col4:
                if attention:
                    with ui.dashboard("attention"):
                        attention()
                else:
                    with ui.dashboard("bands"):
                        ui.dashboard_title("Score bands", "Current cutoffs: Low up to {low:g}, Moderate up to "
                                         "{moderate:g}, High up to {high:g} (RN02)".format(**view["cutoffs"]))
                        charts.simple_bars([fx["band"] for fx in view["score_bands"]],
                                                [fx["total"] for fx in view["score_bands"]], color=ui.COLOR["mustard"])
            _complements(an, view, attention is not None)

    _view()


def _complements(an: dict, view: dict, show_bands: bool):
    if show_bands:
        col1, col2 = st.columns(2, gap="medium")
        with col1:
            with ui.dashboard("bands"):
                ui.dashboard_title("Score bands", "Current cutoffs: Low up to {low:g}, Moderate up to {moderate:g}, "
                                 "High up to {high:g} (RN02)".format(**view["cutoffs"]))
                charts.simple_bars([fx["band"] for fx in view["score_bands"]],
                                        [fx["total"] for fx in view["score_bands"]], color=ui.COLOR["mustard"])
        with col2:
            with ui.dashboard("service"):
                _first_service(an)
    with ui.dashboard("comparison"):
        ui.dashboard_title("Comparison between courses" if an["comparison_type"] == "course" else "Comparison by semester",
                         "Students by level in each group; groups with fewer than 5 students appear suppressed")
        charts.stacked_by_group(an["comparison"])
    col3, col4 = st.columns(2, gap="medium")
    with col3:
        with ui.dashboard("effectiveness"):
            ui.dashboard_title("Effectiveness of interventions", "Retention of those who did or did not get contact (RF25)")
            ef = an["effectiveness"]
            if not ef["available"]:
                st.caption(ef["reason"])
            else:
                a, b = st.columns(2)
                with a:
                    ui.card("With contact", _pct(ef['with_intervention']['retention_pct']),
                            f"{ef['with_intervention']['alerts'] or 'few'} closed alerts", "hand-heart")
                with b:
                    ui.card("Without contact", _pct(ef['without_intervention']['retention_pct']),
                            f"{ef['without_intervention']['alerts'] or 'few'} closed alerts", "user-x")
                st.caption(ef["grade"])
    with col4:
        if show_bands:
            with ui.dashboard("causes"):
                _causes(an)
        else:
            with ui.dashboard("service"):
                _first_service(an)
    if not show_bands and an["identified_causes"]:
        with ui.dashboard("causes"):
            _causes(an)


def _first_service(an: dict):
    ui.dashboard_title("First service", "Alerts with a first action within the deadline, by level")
    if not an["first_service"]:
        st.caption("No data: no alert has had an action recorded yet.")
    for p in an["first_service"]:
        st.write(f"{ui.LEVEL_NAME.get(p['level'], p['level'])}: "
                 + ("suppressed" if p["total"] is None else
                    f"{p['in_deadline_pct']}% on time, average of {ui.br_number(p['average_hours'])} h"))
    st.caption(f"Classifications marked as wrong (RF20): "
               f"{'suppressed' if an['registered_divergences'] is None else an['registered_divergences']}")


def _causes(an: dict):
    ui.dashboard_title("Causes identified in closings")
    if not an["identified_causes"]:
        st.caption("No data: no alert closed with a recorded cause yet.")
        return
    charts.simple_bars([CAUSE_NAME.get(c["cause"], c["cause"]) for c in an["identified_causes"]],
                            [c["alerts"] for c in an["identified_causes"]], suffix=" alerts")
