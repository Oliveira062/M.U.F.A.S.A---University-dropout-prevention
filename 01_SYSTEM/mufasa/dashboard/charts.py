import html

import pandas as pd
import plotly.graph_objects as go
import streamlit as st

import ui

_BASE = dict(paper_bgcolor="rgba(0,0,0,0)", plot_bgcolor="rgba(0,0,0,0)", font=dict(color=ui.COLOR["text"], size=13),
             margin=dict(l=10, r=10, t=10, b=10), hoverlabel=dict(bgcolor="#FFFFFF", font_color=ui.COLOR["text"]))
_CONFIG = {"displayModeBar": False}


def levels_distribution(distribution: list[dict], height=240):
    rows = [d for d in distribution if d["level"] in ui.LEVELS_ORDER]
    rows.sort(key=lambda d: ui.LEVELS_ORDER.index(d["level"]), reverse=True)
    names = [ui.LEVEL_NAME[d["level"]] for d in rows]
    values = [d["total"] or 0 for d in rows]
    texts = ["suppressed (< 5)" if d["total"] is None else
             (f"{d['total']} · {ui.br_number(d['pct'])}%" if d.get("pct") is not None else str(d["total"]))
             for d in rows]
    fig = go.Figure(go.Bar(x=values, y=names, orientation="h", text=texts, textposition="outside",
                           cliponaxis=False, marker=dict(color=[ui.CHART_COLOR[d["level"]] for d in rows],
                                                         line=dict(color="#FFFFFF", width=2)),
                           hovertemplate="%{y}: %{text}<extra></extra>"))
    fig.update_layout(**_BASE, height=height, showlegend=False, bargap=0.35,
                      xaxis=dict(visible=False, range=[0, max(values + [1]) * 1.3]), yaxis=dict(title=None))
    st.plotly_chart(fig, use_container_width=True, config=_CONFIG)


def simple_bars(labels: list[str], values: list, color=None, height=None, suffix=""):
    height = height or 70 + 42 * max(len(labels), 1)
    text = ["suppressed (< 5)" if v is None else f"{v}{suffix}" for v in values]
    fig = go.Figure(go.Bar(x=[v or 0 for v in values], y=labels, orientation="h", text=text, textposition="outside",
                           cliponaxis=False, marker=dict(color=color or ui.COLOR["deep"]),
                           hovertemplate="%{y}: %{text}<extra></extra>"))
    fig.update_layout(**_BASE, height=height, showlegend=False, bargap=0.4,
                      xaxis=dict(visible=False, range=[0, max([v or 0 for v in values] + [1]) * 1.35]),
                      yaxis=dict(title=None, autorange="reversed"))
    st.plotly_chart(fig, use_container_width=True, config=_CONFIG)


def evolution(series: list[dict], height=260):
    if not series:
        st.caption("No data: there are no calculated scores yet.")
        return
    df = pd.DataFrame(series)
    df["day"] = pd.to_datetime(df["day"]).dt.strftime("%d/%m")
    fig = go.Figure()
    for column, name, color in (("at_risk", "High + Critical", ui.CHART_COLOR["HIGH"]),
                                ("critical", "Critical", ui.CHART_COLOR["CRITICAL"])):
        fig.add_trace(go.Scatter(x=df["day"], y=df[column], mode="lines+markers", name=name,
                                 line=dict(color=color, width=2), marker=dict(size=8, line=dict(width=2, color="#FFFFFF")),
                                 hovertemplate="%{x}<br>" + name + ": %{y}<extra></extra>"))
    fig.update_layout(**_BASE, height=height, legend=dict(orientation="h", y=1.15, x=0),
                      yaxis=dict(rangemode="tozero", gridcolor="#F0E5C8", title=None), xaxis=dict(title=None, type="category"),
                      hovermode="x unified")
    st.plotly_chart(fig, use_container_width=True, config=_CONFIG)
    if len(df) == 1:
        st.caption("There is only one day of calculation so far: the series grows with each day of use.")


def stacked_by_group(comparison: list[dict], height=300):
    if not comparison:
        st.caption("No data.")
        return
    groups = [c["group"] for c in comparison]
    fig = go.Figure()
    for level in ("LOW", "MODERATE", "HIGH", "CRITICAL"):
        values = [c["levels"].get(level) for c in comparison]
        fig.add_trace(go.Bar(name=ui.LEVEL_NAME[level], x=groups, y=[v or 0 for v in values],
                             marker=dict(color=ui.CHART_COLOR[level], line=dict(color="#FFFFFF", width=2)),
                             customdata=["suppressed (< 5)" if v is None else v for v in values],
                             hovertemplate="%{x} · " + ui.LEVEL_NAME[level] + ": %{customdata}<extra></extra>"))
    fig.update_layout(**_BASE, barmode="stack", height=height, legend=dict(orientation="h", y=1.12, x=0),
                      yaxis=dict(gridcolor="#F0E5C8", title="students"), xaxis=dict(title=None))
    st.plotly_chart(fig, use_container_width=True, config=_CONFIG)
    with st.expander("View as table"):
        levels = list(comparison[0]["levels"]) if comparison else []
        ui.grade(["Group"] + [(ui.LEVEL_NAME[n], "d") for n in levels],
                 [[ui.txt(c["group"])] + [ui.txt("suppressed" if c["levels"].get(n) is None else c["levels"][n])
                                          for n in levels] for c in comparison],
                 "Groups with fewer than 5 students appear as suppressed.", "Comparison between groups")


BAND_ORDER = ["LOW", "MODERATE", "HIGH", "CRITICAL"]


def distribution_band(distribution: list[dict]):
    by = {d["level"]: d for d in distribution}
    total = sum((by.get(n, {}).get("total") or 0) for n in BAND_ORDER)
    if not total:
        st.caption("No data: no student with a score in this slice.")
        return
    parts = []
    for n in BAND_ORDER:
        d = by.get(n) or {}
        background, text, _, name = ui.BADGE[n]
        if d.get("total") is None and n in by:
            parts.append(f'<div class="mf-fx-sup" title="{name}: suppressed (group smaller than 5)">suppressed</div>')
            continue
        v = d.get("total") or 0
        if not v:
            continue
        pct = 100 * v / total
        lbl = f"{ui.br_number(pct, 0)}% {name}" if pct >= 12 else f"{ui.br_number(pct, 0)}%"
        parts.append(f'<div style="flex:{v} 1 0;background:{background};color:{text}" title="{name}: {v} students">'
                     f'{html.escape(lbl) if pct >= 4 else ""}</div>')
    st.markdown(f'<div class="mf-band" role="img" aria-label="Distribution by level">{"".join(parts)}</div>',
                unsafe_allow_html=True)


def frequent_factors(factors: list[dict], base: int | None):
    if not factors:
        st.caption("No data.")
        return
    rows = []
    for f in factors:
        pct = (100 * f["students"] / base) if base else None
        width = pct if pct is not None else 0
        value = f"{ui.br_number(pct, 0)}%" if pct is not None else f'{f["students"]}'
        rows.append(f'<div class="mf-l-factor"><span class="n">{html.escape(f["factor"].capitalize())}</span>'
                    f'<span class="t"><i style="width:{width:.1f}%"></i></span><span class="v">{value}</span></div>')
    st.markdown("".join(rows), unsafe_allow_html=True)


def stacked_evolution(series: list[dict], height=280):
    if not series:
        st.caption("No data: there are no calculated scores yet.")
        return
    df = pd.DataFrame(series)
    df["day"] = pd.to_datetime(df["day"]).dt.strftime("%d/%m")
    df["high"] = df["at_risk"] - df["critical"]
    fig = go.Figure()
    for column, level in (("high", "HIGH"), ("critical", "CRITICAL")):
        fig.add_trace(go.Bar(x=df["day"], y=df[column], name=ui.LEVEL_NAME[level],
                             width=[0.5] * len(df) if len(df) >= 6 else [0.5 * len(df) / 6] * len(df),
                             marker=dict(color=ui.CHART_COLOR[level], line=dict(color="#FFFFFF", width=2)),
                             hovertemplate="%{x} · " + ui.LEVEL_NAME[level] + ": %{y}<extra></extra>"))
    fig.update_layout(**_BASE, barmode="stack", height=height, bargap=0.45,
                      legend=dict(orientation="h", y=-0.18, x=0, traceorder="reversed", font=dict(size=13)),
                      yaxis=dict(visible=False), xaxis=dict(title=None, type="category", tickfont=dict(size=12,
                      color=ui.COLOR["text2"])))
    st.plotly_chart(fig, use_container_width=True, config=_CONFIG)
    if len(df) == 1:
        st.caption("There is only one day of calculation so far: the series grows with each day of use.")
