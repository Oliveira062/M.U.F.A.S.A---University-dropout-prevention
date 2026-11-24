import contextlib
import csv
import html
import io
import json
import re
import unicodedata
import uuid
from pathlib import Path
from urllib.parse import quote
from datetime import datetime

import streamlit as st
import streamlit.components.v1 as components

from client import ApiError, UnavailableService
from dashboard_logging import log

COLOR = {
    "bg": "#FFFFFF", "cream": "#F5EBD3", "creamSoft": "#FBF6EA", "creamDeep": "#EEDFB8", "line": "#E6D5AC",
    "text": "#3D2B1F", "text2": "#6B5432", "text3": "#94805C", "gold": "#C99720", "goldSoft": "#F3E2B3",
    "deep": "#8C6410", "mustard": "#B8860B", "lineSoft": "#F0E5C8", "okBg": "#E6EFDF", "okFg": "#3F6B2E", "errBg": "#F6E1D3", "errFg": "#9A4A1E",
    "infoBg": "#EAE6DC", "infoFg": "#5B5141",
}
BADGE = {
    "LOW": ("#F7E9BF", "#5C4410", "○", "Low"),
    "MODERATE": ("#E9C35C", "#3D2B1F", "◐", "Moderate"),
    "HIGH": ("#523E1D", "#FFFFFF", "▲", "High"),
    "CRITICAL": ("#9A4A1E", "#FFFFFF", "◆", "Critical"),
    "UNDETERMINED": ("#EAE6DC", "#5B5141", "?", "Undetermined"),
    "PENDING": ("#EAE6DC", "#5B5141", "…", "Pending"),
}
CHART_COLOR = {"LOW": "#EBD79B", "MODERATE": "#C99720", "HIGH": "#523E1D", "CRITICAL": "#9A4A1E",
               "UNDETERMINED": "#B8B2A4", "PENDING": "#D8D3C8"}
LEVEL_NAME = {k: v[3] for k, v in BADGE.items()}
LEVELS_ORDER = ["CRITICAL", "HIGH", "MODERATE", "LOW", "UNDETERMINED", "PENDING"]

WEIGHTS_NOTICE = ("Score calculated by a deterministic model of heuristic weights, version 1.1. It is not "
               "result of a statistical analysis of the institution's data.")
DECISION_NOTICE = "The system recommends; the team decides and records each action."


_ICONS = json.loads((Path(__file__).with_name("icons.json")).read_text(encoding="utf-8"))
LEVEL_ICON = {"LOW": "circle-check", "MODERATE": "info", "HIGH": "circle-alert", "CRITICAL": "triangle-alert",
               "UNDETERMINED": "circle-question-mark", "PENDING": "hourglass"}


def icon(name: str, size: int = 16, color: str = "currentColor") -> str:
    svg = _ICONS.get(name, "").replace('width="1em" height="1em"', f'width="{size}" height="{size}"')
    return f'<span class="mf-ic" style="width:{size}px;height:{size}px;color:{color}">{svg}</span>'


def icon_url(name: str, color: str) -> str:
    svg = _ICONS.get(name, "").replace("currentColor", color)
    return "url(\"data:image/svg+xml;utf8," + quote(svg) + "\")"


def css(rules: str):
    st.markdown(f"<style>{rules}</style>", unsafe_allow_html=True)


_JS_ACCESSIBILITY = (Path(__file__).parent / "accessibility.js").read_text(encoding="utf-8")


def accessibility():
    components.html(_accessibility_loader(), height=0)


def _accessibility_loader() -> str:
    code = json.dumps(_JS_ACCESSIBILITY).replace("</", "<\\/")
    return ("<script>(function(){var p=window.parent;if(p.__mufasaAccessibility)return;"
            "var s=p.document.createElement('script');s.id='mf-a11y-script';s.textContent=" + code + ";"
            "p.document.head.appendChild(s);})();</script>")


def apply_theme():
    css(f"""
  html, body, .stApp, button, input, textarea, select {{ font-family: Inter, system-ui, sans-serif; }}
  [data-testid="stHeader"] {{ background: transparent; height: 0; }}
  [data-testid="stToolbar"], [data-testid="stDecoration"], [data-testid="stStatusWidget"] {{ display: none; }}
  [data-testid="stMainBlockContainer"], .block-container {{ padding: 16px 32px 40px 32px !important; max-width: 1480px; }}
  [data-testid="stMarkdownContainer"]:not(:has(> p:last-child)) {{ margin-bottom:0; }}
  [class*="st-key-lk_"], [data-testid="stLayoutWrapper"]:has(> [class*="st-key-lk_"]) {{ width:auto !important;
      flex:0 0 auto !important; }}
  .mf-est b {{ display:block; font-size:14px; font-weight:600; color:{COLOR['text']}; }}
  .mf-est small {{ display:block; font-size:12px; color:{COLOR['text2']}; margin-top:2px; }}
  .mf-risk {{ display:flex; flex-direction:column; gap:6px; align-items:flex-start; }}
  .mf-risk > div {{ display:flex; gap:8px; align-items:center; line-height:16px; font-size:12px; color:{COLOR['text']}; font-weight:600; }}
  .mf-deadline small {{ display:block; font-size:12px; color:{COLOR['text2']}; margin-top:4px; }}
  .mf-resp {{ display:flex; gap:10px; align-items:center; font-size:13px; font-weight:500; color:{COLOR['text']}; }}
  .mf-resp.empty {{ color:{COLOR['text3']}; }}
  [class*="st-key-at_"] [data-testid="stElementContainer"], [class*="st-key-at_"] [data-testid="stPageLink"],
  [class*="st-key-at_"] [data-testid="stPageLink"] > div {{ width:100% !important; }}
  [data-testid="InputInstructions"] {{ display:none; }}
  button p {{ font-weight:inherit !important; }}
  [data-testid="stElementContainer"]:has(style) {{ display:none; }}
  [data-testid="stElementContainer"]:has(> iframe[height="0"]), [data-testid="stElementContainer"]:has(iframe[height="0"]) {{ display:none; }}
  [data-testid="stSidebarHeader"] {{ height: 0; min-height: 0; padding: 0; margin: 0; }}
  [data-testid="stSidebarUserContent"] {{ padding-top: 20px !important; }}
  section[data-testid="stSidebar"] [data-testid="stVerticalBlock"] {{ gap: 4px; }}
  section[data-testid="stSidebar"] {{ width: 264px !important; min-width: 264px !important; }}
  section[data-testid="stSidebar"] > div {{ padding-top: 8px; }}
  h1, h2, h3, h4 {{ color: {COLOR['text']}; letter-spacing: 0; }}
  [data-baseweb="input"], [data-baseweb="input"] > div, [data-baseweb="select"] > div, [data-baseweb="textarea"] {{
      background-color:#FFFFFF !important; }}
  [data-baseweb="input"] input {{ background-color:transparent; }}
  .mf-ic {{ display:inline-flex; align-items:center; justify-content:center; vertical-align:middle; flex:none; }}
  .mf-ic svg {{ display:block; }}
  button[kind="primary"], button[data-testid="stBaseButton-primary"], [data-testid="stFormSubmitButton"] button[kind="primaryFormSubmit"] {{
      background:{COLOR['gold']} !important; border-color:{COLOR['gold']} !important; color:{COLOR['text']} !important;
      font-weight:600; }}
  button[kind="primary"]:hover, button[data-testid="stBaseButton-primary"]:hover {{ background:{COLOR['mustard']} !important; }}
  button[kind="secondary"], button[data-testid="stBaseButton-secondary"] {{ border-color:{COLOR['line']}; color:{COLOR['text']};
      font-weight:600; background:#FFFFFF; }}
  button[kind="secondary"]:hover {{ border-color:{COLOR['gold']}; color:{COLOR['deep']}; }}
  [data-testid="stVerticalBlockBorderWrapper"]:has(> div > [data-testid="stVerticalBlock"]) {{ border-radius:16px; }}
  .mf-header {{ padding-bottom:10px; }}
  .mf-about {{ color:{COLOR['deep']}; font-size:12px; font-weight:700; letter-spacing:.02em; margin:0 0 6px 0; }}
  .mf-title {{ font-size:28px; line-height:36px; font-weight:700; color:{COLOR['text']}; margin:0; padding:0 !important; }}
  .mf-sub {{ color:{COLOR['text2']}; font-size:14px; margin:6px 0 0 0; }}
  .mf-h3 {{ font-size:18px; line-height:26px; font-weight:600; color:{COLOR['text']}; margin:0; }}
  .mf-h3sub {{ color:{COLOR['text2']}; font-size:13px; line-height:19px; margin:2px 0 6px 0; }}
  .mf-badge {{ display:inline-flex; align-items:center; gap:6px; padding:3px 12px; border-radius:999px; font-weight:600;
             font-size:13px; line-height:19px; white-space:nowrap; }}
  .mf-card {{ background:{COLOR['creamSoft']}; border:1px solid {COLOR['line']}; border-radius:12px; padding:18px 20px;
             height:100%; }}
  .mf-card .top {{ display:flex; justify-content:space-between; align-items:center; }}
  .mf-card .lbl {{ color:{COLOR['text']}; font-size:12px; font-weight:600; }}
  .mf-card .val {{ color:{COLOR['text']}; font-size:30px; font-weight:700; line-height:36px; margin-top:10px; }}
  .mf-card .leg {{ color:{COLOR['text2']}; font-size:12px; margin-top:6px; }}
  .mf-restricted {{ background:{COLOR['infoBg']}; color:{COLOR['infoFg']}; border-radius:12px; padding:12px 16px;
                  border:1px dashed {COLOR['text3']}; display:flex; gap:10px; align-items:flex-start; font-size:13px; }}
  .mf-decision {{ background:{COLOR['creamSoft']}; color:{COLOR['text']}; border:1px solid {COLOR['line']}; border-radius:12px;
                 padding:14px 16px; font-size:13px; }}
  .mf-decision b {{ display:flex; align-items:center; gap:8px; font-weight:600; margin-bottom:4px; }}
  .mf-footer {{ color:{COLOR['text3']}; font-size:12px; margin-top:24px; border-top:1px solid {COLOR['line']};
                padding-top:8px; }}
  .mf-factor {{ border-left:4px solid {COLOR['gold']}; padding:6px 12px; margin:6px 0; background:{COLOR['creamSoft']};
               border-radius:0 8px 8px 0; }}
  [data-testid="stColumn"] [data-testid="stLayoutWrapper"]:has(> [class*="st-key-pn_"]):only-child,
  [data-testid="stColumn"] [data-testid="stLayoutWrapper"]:has(> [class*="st-key-pn_"]):only-child > [class*="st-key-pn_"] {{ height:100%; }}
  [class*="st-key-pn_"] {{ background:#FFFFFF; border:1px solid {COLOR['line']}; border-radius:16px; padding:24px; }}
  .st-key-banner {{ background:{COLOR['cream']}; border-radius:16px; padding:18px 20px; }}
  .mf-banner {{ display:flex; gap:16px; align-items:center; }}
  .mf-banner b {{ display:block; font-size:14px; font-weight:600; color:{COLOR['text']}; }}
  .mf-banner span {{ font-size:13px; color:{COLOR['text2']}; }}
  .mf-band {{ display:flex; height:44px; border-radius:8px; overflow:hidden; font-size:13px; font-weight:600; }}
  .mf-band > div {{ display:flex; align-items:center; justify-content:center; white-space:nowrap; overflow:hidden; }}
  .mf-fx-sup {{ flex:0 0 auto; padding:0 12px; background:repeating-linear-gradient(45deg,{COLOR['creamSoft']} 0 6px,{COLOR['line']} 6px 8px);
               color:{COLOR['text2']}; }}
  .mf-l-factor {{ display:grid; grid-template-columns: minmax(150px, 1.5fr) 1fr 48px; gap:16px; align-items:center; margin:0 0 16px 0; }}
  .mf-l-factor .n {{ font-size:14px; font-weight:500; color:{COLOR['text']}; }}
  .mf-l-factor .t {{ height:8px; border-radius:999px; background:{COLOR['lineSoft']}; overflow:hidden; }}
  .mf-l-factor .t i {{ display:block; height:100%; border-radius:999px; background:{COLOR['mustard']}; }}
  .mf-l-factor .v {{ font-size:14px; font-weight:600; color:{COLOR['text']}; text-align:right; }}
  .mf-l-list {{ display:flex; gap:14px; align-items:center; min-height:56px; }}
  .mf-l-list b {{ display:block; font-size:14px; font-weight:600; color:{COLOR['text']}; }}
  .mf-l-list small {{ font-size:12px; color:{COLOR['text2']}; }}
  [data-baseweb="tab-list"] {{ background:{COLOR['cream']}; border-radius:12px; padding:4px; gap:4px; width:fit-content;
      max-width:100%; flex-wrap:wrap; }}
  [data-baseweb="tab"] {{ border-radius:9px; padding:6px 14px !important; height:auto; background:transparent; }}
  [data-baseweb="tab"] p {{ font-size:14px; font-weight:500; color:{COLOR['text']}; }}
  [data-baseweb="tab"][aria-selected="true"] {{ background:#FFFFFF; box-shadow:0 1px 2px rgba(61,43,31,.12); }}
  [data-baseweb="tab"][aria-selected="true"] p {{ font-weight:600; }}
  [data-baseweb="tab-highlight"], [data-baseweb="tab-border"] {{ display:none; }}
  [data-testid="stForm"] {{ background:#FFFFFF; border:1px solid {COLOR['line']}; border-radius:16px; padding:24px; }}
  [class*="st-key-pn_"] [data-testid="stForm"] {{ border:none; padding:0; }}
  [data-testid="stExpander"] details {{ border:1px solid {COLOR['line']}; border-radius:12px; background:#FFFFFF; }}
  [data-testid="stExpander"] summary p {{ font-weight:500; }}
  [data-testid="stDataFrame"] {{ border:1px solid {COLOR['lineSoft']}; border-radius:12px; overflow:hidden; }}
  [data-testid="stAlert"] > div {{ border-radius:12px; }}
  [data-testid="stCaptionContainer"] {{ color:{COLOR['text2']}; }}
  [class*="st-key-lk_"] button {{ gap:8px; }}
  [class*="st-key-lk_"] button::before, [class*="st-key-vt_"] button::before {{ width:16px; height:16px;
      background-color:{COLOR['deep']}; -webkit-mask-size:contain; mask-size:contain; -webkit-mask-repeat:no-repeat;
      mask-repeat:no-repeat; flex:none; }}
  [class*="st-key-vt_"] button {{ border:none; background:transparent; padding:0; min-height:32px; gap:8px; }}
  [class*="st-key-vt_"] button p {{ color:{COLOR['deep']}; font-weight:600; }}
  [class*="st-key-vt_"] button::before {{ content:""; -webkit-mask-image:{icon_url('arrow-left', '#000')};
      mask-image:{icon_url('arrow-left', '#000')}; }}
  .mf-pill {{ display:inline-flex; align-items:center; gap:6px; padding:2px 10px; border-radius:999px; font-size:12px;
               font-weight:600; line-height:18px; white-space:nowrap; }}
  .mf-pill.outline {{ background:#FFFFFF; border:1px solid {COLOR['gold']}; color:{COLOR['text']}; }}
  .mf-pill.outline::before {{ content:""; width:6px; height:6px; border-radius:999px; background:{COLOR['deep']}; }}
  .mf-table-header {{ display:grid; background:{COLOR['cream']}; border-radius:10px; padding:10px 16px; font-size:12px;
                   font-weight:600; color:{COLOR['text']}; margin-bottom:4px; }}
  .st-key-hero {{ background:{COLOR['creamSoft']}; border:1px solid {COLOR['line']}; border-radius:16px; padding:22px 24px; }}
  .st-key-hero [data-testid="stColumn"]:last-child [data-testid="stVerticalBlock"] {{ align-items:flex-end; }}
  [class*="st-key-pn_tb_"] {{ background:#FFFFFF; border:1px solid {COLOR['line']}; border-radius:16px;
      padding:12px 8px 16px 8px; }}
  [class*="st-key-lin_"] {{ border-bottom:1px solid {COLOR['lineSoft']}; padding:10px 16px; border-radius:0; }}
  [class*="st-key-lin_"]:hover {{ background:{COLOR['creamSoft']}; }}
  [class*="st-key-lin_"] [data-testid="stMarkdownContainer"] {{ font-size:14px; color:{COLOR['text']}; }}
  .mf-table-footer {{ display:flex; justify-content:space-between; gap:12px; flex-wrap:wrap; font-size:12px;
      color:{COLOR['text2']}; padding:12px 16px 0 16px; }}
  .mf-table-footer span {{ display:inline-flex; gap:6px; align-items:center; }}
  .mf-notice {{ background:{COLOR['creamSoft']}; border:1px solid {COLOR['line']}; border-radius:16px; padding:16px 20px;
      display:flex; gap:14px; align-items:flex-start; }}
  .mf-notice b {{ display:block; font-size:14px; font-weight:600; color:{COLOR['text']}; }}
  .mf-notice span {{ font-size:13px; color:{COLOR['text2']}; }}
  [class*="st-key-tx_"] button {{ border:none; background:transparent; padding:0; min-height:28px; gap:6px; }}
  [class*="st-key-tx_"] button p {{ color:{COLOR['deep']}; font-weight:600; font-size:13px; }}
  [class*="st-key-tx_"] button::after {{ content:""; width:14px; height:14px; background-color:{COLOR['deep']};
      -webkit-mask:{icon_url('arrow-right', '#000')} no-repeat center/contain;
      mask:{icon_url('arrow-right', '#000')} no-repeat center/contain; }}
  [class*="st-key-tx_"] button:hover p {{ text-decoration:underline; }}
  .mf-icbox {{ width:44px; height:44px; border-radius:12px; background:{COLOR['cream']}; display:inline-flex;
      align-items:center; justify-content:center; color:{COLOR['deep']}; flex:none; }}
  .mf-chips {{ display:flex; gap:8px; flex-wrap:wrap; margin:10px 0 6px 0; }}
  .mf-chip {{ display:inline-flex; gap:8px; align-items:center; background:{COLOR['creamSoft']}; border-radius:10px;
      padding:4px 10px 4px 4px; font-size:14px; font-weight:600; color:{COLOR['text']}; }}
  [class*="st-key-at_"] [data-testid="stPageLink"] a {{ position:relative; display:flex; align-items:flex-start;
      min-height:80px; padding:18px 44px 18px 78px; border:1px solid {COLOR['line']}; border-radius:16px;
      background:#FFFFFF {icon_url('chevron-right', COLOR['text2'])} no-repeat right 18px center / 16px; width:100%;
      box-sizing:border-box; }}
  [class*="st-key-at_"] [data-testid="stPageLink"] a:hover {{ border-color:{COLOR['gold']}; background-color:{COLOR['creamSoft']}; }}
  [class*="st-key-at_"] [data-testid="stPageLink"] a span, [class*="st-key-at_"] [data-testid="stPageLink"] a p {{
      font-size:14px; font-weight:600; color:{COLOR['text']}; }}
  [class*="st-key-at_"] [data-testid="stPageLink"] a::before {{ content:""; position:absolute; left:18px; top:18px;
      width:44px; height:44px; border-radius:12px; background-color:{COLOR['cream']}; background-repeat:no-repeat;
      background-position:center; background-size:22px; }}
  [class*="st-key-at_"] [data-testid="stPageLink"] a::after {{ position:absolute; left:78px; top:42px; right:44px;
      font-size:12px; color:{COLOR['text2']}; }}
  .mf-hero {{ display:flex; gap:20px; align-items:center; }}
  .mf-hero .mf-avatar {{ width:64px; height:64px; font-size:18px; }}
  .mf-hero h1 {{ font-size:22px; line-height:30px; font-weight:700; color:{COLOR['text']}; margin:0; padding:0;
               display:flex; gap:12px; align-items:center; flex-wrap:wrap; }}
  .mf-hero .meta {{ display:flex; gap:18px; flex-wrap:wrap; margin-top:6px; font-size:13px; color:{COLOR['text2']}; }}
  .mf-hero .meta span {{ display:inline-flex; gap:6px; align-items:center; }}
  .mf-row {{ display:flex; justify-content:space-between; gap:16px; align-items:flex-start; padding:12px 0;
              border-bottom:1px solid {COLOR['lineSoft']}; }}
  .mf-row:last-child {{ border-bottom:none; }}
  .mf-row b {{ font-size:14px; font-weight:600; color:{COLOR['text']}; }}
  .mf-row small {{ display:block; font-size:12px; color:{COLOR['text2']}; margin-top:2px; }}
  .mf-box-grade {{ overflow-x:auto; border:1px solid {COLOR['line']}; border-radius:14px; background:#FFFFFF; }}
  .mf-box-grade:focus-visible {{ outline:3px solid {COLOR['gold']}; outline-offset:2px; }}
  .mf-grade {{ width:100%; border-collapse:separate; border-spacing:0; font-size:14px; color:{COLOR['text']};
      font-variant-numeric:tabular-nums; margin:0 !important; border:none !important; }}
  .mf-grade th, .mf-grade td {{ border-top:none !important; border-left:none !important; border-right:none !important; }}
  .mf-grade caption {{ position:absolute; width:1px; height:1px; overflow:hidden; clip:rect(0 0 0 0); }}
  .mf-grade th {{ background:{COLOR['creamSoft']}; color:{COLOR['text2']}; font-size:12px; font-weight:600;
      text-transform:uppercase; letter-spacing:.04em; padding:12px 16px; border-bottom:1px solid {COLOR['line']};
      white-space:nowrap; text-align:left; }}
  .mf-grade td {{ padding:14px 16px; border-bottom:1px solid {COLOR['lineSoft']}; vertical-align:middle; }}
  .mf-grade tbody tr:last-child td {{ border-bottom:none; }}
  .mf-grade tbody tr:hover td {{ background:#FFFCF4; }}
  .mf-grade td:first-child {{ font-weight:600; }}
  .mf-grade td b {{ display:block; font-weight:600; }}
  .mf-grade td small {{ display:block; font-size:12px; color:{COLOR['text2']}; font-weight:400; margin-top:2px; }}
  .mf-grade .al-c {{ text-align:center; }} .mf-grade .al-d {{ text-align:right; }}
  .mf-grade .mf-badge, .mf-grade [class*="mf-pil"] {{ white-space:nowrap; }}
  .mf-empty {{ color:{COLOR['text3']}; }}
  .mf-grade-pill {{ display:inline-block; min-width:40px; padding:3px 8px; border-radius:8px; font-weight:600;
      text-align:center; background:{COLOR['creamSoft']}; }}
  .mf-num {{ color:{COLOR['text2']}; font-weight:500; }}
  .mf-grade-pill.changed {{ background:{COLOR['goldSoft']}; color:{COLOR['deep']}; }}
  .mf-grade-pill.low {{ background:{COLOR['errBg']}; color:{COLOR['errFg']}; }}
  .mf-att {{ display:inline-flex; align-items:center; gap:10px; }}
  .mf-att .track {{ display:inline-block; width:72px; height:6px; border-radius:999px; background:{COLOR['lineSoft']};
      overflow:hidden; }}
  .mf-att .track span {{ display:block; height:100%; border-radius:999px; }}
  .mf-att .num {{ min-width:40px; text-align:right; font-weight:600; }}
  .mf-att.low .num {{ color:{COLOR['errFg']}; }}
  .mf-grade-leg {{ display:flex; gap:8px; align-items:flex-start; font-size:12.5px; color:{COLOR['text2']};
      margin:12px 2px 0 2px; }}
  .mf-grade-leg .mf-ic {{ margin-top:2px; }}
  .mf-summary {{ display:grid; grid-template-columns:repeat(auto-fit, minmax(150px, 1fr)); gap:12px; margin:0 0 16px 0; }}
  .mf-summary > div {{ border-radius:12px; padding:14px 16px; display:flex; flex-direction:column; gap:2px; }}
  .mf-summary .v {{ font-size:24px; font-weight:700; line-height:30px; }}
  .mf-summary .r {{ font-size:12.5px; color:{COLOR['text2']}; }}
  .mf-factors {{ display:grid; grid-template-columns:repeat(auto-fill, minmax(280px, 1fr)); gap:12px; }}
  .mf-factor {{ display:flex; gap:12px; background:#FFFFFF; border:1px solid {COLOR['line']};
      border-left:4px solid {COLOR['mustard']}; border-radius:12px; padding:14px 16px; }}
  .mf-factor .ico {{ width:34px; height:34px; border-radius:10px; background:{COLOR['goldSoft']}; color:{COLOR['deep']};
      display:flex; align-items:center; justify-content:center; flex:none; }}
  .mf-factor b {{ display:block; font-size:14.5px; font-weight:600; color:{COLOR['text']}; }}
  .mf-factor p {{ margin:4px 0 0 0; font-size:13px; line-height:1.5; color:{COLOR['text2']}; }}
  .mf-factor .pts {{ margin-top:8px; display:flex; flex-wrap:wrap; align-items:center; gap:8px 10px; font-size:12.5px;
      font-weight:600; color:{COLOR['text']}; }}
  .mf-factor .pts > span {{ white-space:nowrap; }}
  .mf-factor > div {{ min-width:0; flex:1; }}
  .mf-method-grade {{ display:flex; gap:10px; background:{COLOR['infoBg']}; color:{COLOR['infoFg']}; border-radius:12px;
      padding:12px 14px; font-size:12.5px; line-height:1.55; margin:0 0 14px 0; }}
  .mf-time {{ position:relative; padding:0 0 18px 26px; }}
  .mf-time::before {{ content:""; position:absolute; left:5px; top:6px; bottom:-6px; width:2px; background:{COLOR['lineSoft']}; }}
  .mf-time:last-child::before {{ display:none; }}
  .mf-time::after {{ content:""; position:absolute; left:0; top:4px; width:8px; height:8px; border-radius:999px;
                     border:2px solid {COLOR['gold']}; background:#FFFFFF; }}
  .mf-time.current::after {{ background:{COLOR['gold']}; }}
  .mf-time b {{ font-size:14px; font-weight:600; color:{COLOR['text']}; }}
  .mf-time small {{ display:block; font-size:12px; color:{COLOR['text2']}; }}
  .mf-time p {{ font-size:13px; color:{COLOR['text']}; margin:4px 0 0 0; }}
  .mf-scale {{ position:relative; height:14px; border-radius:4px; overflow:hidden; display:flex; }}
  .mf-mk-scale {{ position:relative; height:0; }}
  .mf-mk-scale i {{ position:absolute; top:-18px; width:3px; height:22px; background:{COLOR['text']}; border-radius:2px;
                    box-shadow:0 0 0 2px #FFFFFF; }}
  .mf-num-scale {{ display:flex; justify-content:space-between; font-size:12px; color:{COLOR['text2']}; margin-top:8px; }}
  .mf-score {{ font-size:56px; line-height:60px; font-weight:700; color:{COLOR['text']}; }}
  .mf-score small {{ font-size:16px; color:{COLOR['text2']}; font-weight:500; }}
  .mf-bar {{ height:8px; border-radius:999px; background:{COLOR['lineSoft']}; overflow:hidden; }}
  .mf-bar i {{ display:block; height:100%; border-radius:999px; }}
  .mf-avatar {{ width:36px; height:36px; border-radius:999px; background:{COLOR['goldSoft']}; color:{COLOR['deep']};
               display:inline-flex; align-items:center; justify-content:center; font-size:12px; font-weight:700; flex:none; }}
""")


def badge(level: str | None) -> str:
    background, text, _, name = BADGE.get(level or "PENDING", BADGE["PENDING"])
    return (f'<span class="mf-badge" style="background:{background};color:{text}" aria-label="Level {name}">'
            f'{icon(LEVEL_ICON.get(level or "PENDING", "info"), 14)}{name}</span>')


def show_badge(level):
    st.markdown(badge(level), unsafe_allow_html=True)


def card(label: str, value, legend: str = "", icon_name: str | None = None):
    txt_value = "suppressed" if value is None else value
    ic = icon(icon_name, 18, COLOR["deep"]) if icon_name else ""
    style = ' style="font-size:20px;line-height:28px"' if len(str(txt_value)) > 12 else ""
    st.markdown(f'<div class="mf-card"><div class="top"><span class="lbl">{html.escape(label)}</span>{ic}</div>'
                f'<div class="val"{style}>'
                f'{html.escape(str(txt_value))}</div>'
                f'<div class="leg">{html.escape(legend)}</div></div>', unsafe_allow_html=True)


def header(title: str, subtitle: str = "", overline: str = ""):
    st.markdown('<div class="mf-header">' + (f'<div class="mf-about">{html.escape(overline)}</div>' if overline else "")
                + f'<h1 class="mf-title">{html.escape(title)}</h1>'
                + (f'<div class="mf-sub">{html.escape(subtitle)}</div>' if subtitle else "") + "</div>",
                unsafe_allow_html=True)


def dashboard_title(title: str, subtitle: str = ""):
    st.markdown(f'<div class="mf-h3">{html.escape(title)}</div>'
                + (f'<div class="mf-h3sub">{html.escape(subtitle)}</div>' if subtitle else '<div style="height:10px"></div>'),
                unsafe_allow_html=True)


@contextlib.contextmanager
def dashboard(key: str):
    with st.container(key="pn_" + key):
        yield


def banner(title: str, text: str, icon_name: str = "zap"):
    st.markdown(f'<div class="mf-banner">{icon(icon_name, 20, COLOR["deep"])}<div><b>{html.escape(title)}</b>'
                f'<span>{html.escape(text)}</span></div></div>', unsafe_allow_html=True)


def initial(name: str | None) -> str:
    parts = [p for p in (name or "?").replace(".", " ").split() if p[:1].isalpha()]
    return ((parts[0][0] + (parts[-1][0] if len(parts) > 1 else "")) if parts else "?").upper()


def restricted(text="Information restricted to another profile, according to the access matrix and the LGPD."):
    st.markdown(f'<div class="mf-restricted">{icon("lock", 16)}<span>{html.escape(text)}</span></div>',
                unsafe_allow_html=True)


def human_decision():
    st.markdown(f'<div class="mf-decision"><b>{icon("shield-check", 15, COLOR["deep"])}Human decision</b>'
                f'<span style="color:{COLOR["text2"]}">{DECISION_NOTICE}</span></div>', unsafe_allow_html=True)


def footer(extra: str = ""):
    st.markdown(f'<div class="mf-footer">{html.escape(WEIGHTS_NOTICE)} {html.escape(extra)}<br>'
                'Restricted to the authorized team. Personal data processed according to the LGPD.</div>',
                unsafe_allow_html=True)


def txt(value, empty: str = "—") -> str:
    if value is None or value == "":
        return f'<span class="mf-empty">{empty}</span>'
    return html.escape(str(value))


def double_cell(main, detail=None) -> str:
    return f'<b>{txt(main)}</b>' + (f'<small>{txt(detail)}</small>' if detail not in (None, "") else "")


def grade_cell(value, minimum: float | None = 6.0, places: int = 1) -> str:
    if value is None:
        return '<span class="mf-empty">—</span>'
    if minimum is None:
        return f'<span class="mf-num">{br_number(value, places)}</span>'
    below = float(value) < minimum
    return f'<span class="mf-grade-pill{" low" if below else ""}">{br_number(value, places)}</span>'


def attendance_cell(value, minimum: float | None = 75.0) -> str:
    if value is None:
        return '<span class="mf-empty">no data</span>'
    v = max(0.0, min(100.0, float(value)))
    below = minimum is not None and v < minimum
    color = COLOR["errFg"] if below else COLOR["okFg"]
    return (f'<span class="mf-att{" low" if below else ""}"><span class="track"><span style="width:{v:.0f}%;'
            f'background:{color}"></span></span><span class="num">{br_number(v, 0)}%</span></span>')


STYLE_STATUS = {"aprovad": ("okBg", "okFg", "check"), "reprovad": ("errBg", "errFg", "x"),
                   "enrolled": ("infoBg", "infoFg", "clock"), "trancad": ("infoBg", "infoFg", "minus")}


def status_cell(text) -> str:
    if not text:
        return '<span class="mf-empty">—</span>'
    label = str(text).replace("_", " ").lower()
    label = label[:1].upper() + label[1:]
    key = next((k for k in STYLE_STATUS if k in label.lower()), None)
    background, color, ic = STYLE_STATUS.get(key, ("creamSoft", "text2", None))
    return pill(label, COLOR[background], COLOR[color], ic)


def alerts_cell(items: list[str], ok: str = "Up to date") -> str:
    if not items:
        return pill(ok, COLOR["okBg"], COLOR["okFg"], "check")
    return " ".join(pill(i, COLOR["errBg"], COLOR["errFg"], "triangle-alert") for i in items)


def grade(columns: list, rows: list[list[str]], legend: str = "", label: str = "Table"):
    cols = [(c, "e") if isinstance(c, str) else c for c in columns]
    header = "".join(f'<th scope="col" class="al-{a}">{html.escape(n)}</th>' for n, a in cols)
    body = "".join("<tr>" + "".join(f'<td class="al-{cols[i][1]}">{cell}</td>' for i, cell in enumerate(l)) + "</tr>"
                    for l in rows)
    st.markdown(f'<div class="mf-box-grade" role="region" aria-label="{html.escape(label)}" tabindex="0">'
                f'<table class="mf-grade"><caption>{html.escape(label)}</caption><thead><tr>{header}</tr></thead>'
                f'<tbody>{body}</tbody></table></div>'
                + (f'<p class="mf-grade-leg">{icon("info", 13)}<span>{html.escape(legend)}</span></p>' if legend else ""),
                unsafe_allow_html=True)


def simple_grade(rows: list[dict], label: str, legend: str = "", right: tuple = (), highlight: dict | None = None):
    if not rows:
        return
    columns = list(rows[0])
    highlight = highlight or {}
    grade([(c, "d" if c in right else "e") for c in columns],
          [[highlight[c](l.get(c)) if c in highlight else txt(l.get(c)) for c in columns] for l in rows],
          legend, label)


def summary(items: list[tuple]):
    tones = {"ok": (COLOR["okBg"], COLOR["okFg"]), "alert": (COLOR["errBg"], COLOR["errFg"]),
            "neutral": (COLOR["creamSoft"], COLOR["text"])}
    st.markdown('<div class="mf-summary">' + "".join(
        f'<div style="background:{tones[t][0]}"><span class="v" style="color:{tones[t][1]}">{html.escape(str(v))}</span>'
        f'<span class="r">{html.escape(r)}</span></div>' for r, v, t in items) + "</div>", unsafe_allow_html=True)


FACTOR_ICON = {"grades": "book-open", "attendance": "calendar-check", "failure": "circle-x",
               "lms_engagement": "monitor", "finance": "wallet", "work": "clock", "dependents": "users",
               "commute": "map-pin", "housing": "house", "mental_health": "heart-pulse",
               "physical_health": "heart-pulse", "referred": "lock"}


def factor_cards(factors: list[dict], right=None):
    st.markdown('<div class="mf-factors">' + "".join(
        f'<div class="mf-factor"><span class="ico">{icon(FACTOR_ICON.get(f.get("factor"), "info"), 18)}</span>'
        f'<div><b>{html.escape((f.get("name") or "").capitalize())}</b>'
        f'<p>{html.escape(f.get("explanation") or "")}</p>'
        + (f'<div class="pts">{right(f)}</div>' if right and right(f) else "") + "</div></div>"
        for f in factors) + "</div>", unsafe_allow_html=True)


def methodological_note(text: str):
    st.markdown(f'<div class="mf-method-grade">{icon("info", 16)}<span>{html.escape(text)}</span></div>',
                unsafe_allow_html=True)


def br_number(value, places=1) -> str:
    if value is None:
        return "no data"
    text = f"{float(value):,.{places}f}"
    return text


def br_date(text) -> str:
    if not text:
        return "—"
    try:
        return datetime.fromisoformat(str(text)).astimezone().strftime("%d/%m/%Y %H:%M")
    except ValueError:
        return str(text)


def _slug(text: str) -> str:
    text = unicodedata.normalize("NFKD", text).encode("ascii", "ignore").decode().lower()
    return re.sub(r"[^a-z0-9]+", "_", text).strip("_")


@contextlib.contextmanager
def section(title: str | None = None, subtitle: str = "", key: str | None = None):
    box = st.container(key="pn_s_" + (key or _slug(title))) if title else st.container()
    with box:
        if title:
            dashboard_title(title, subtitle)
        try:
            yield
        except UnavailableService as e:
            st.warning(e.message)
        except ApiError as e:
            if e.status == 403 and e.pending_item:
                st.session_state["pending_item"] = e.pending_item
                st.rerun()
            if e.status in (403, 404, 409, 422):
                st.info(e.message)
            else:
                st.error(e.message + (f" Code for support: {e.request}." if e.request else ""))
        except Exception:
            code = "P-" + uuid.uuid4().hex[:8]
            log.exception("failed to build section %r (code %s)", title or "-", code)
            st.error("Could not show this part right now. The rest of the screen keeps working. "
                     f"Code for support: {code}.")


def _spreadsheet_safe(value):
    if isinstance(value, str) and value[:1] in ("=", "+", "-", "@", "\t", "\r"):
        return "'" + value
    return value


def export_csv(rows: list[dict], columns: list[str], title: str, profile: str) -> bytes:
    output = io.StringIO()
    writer = csv.writer(output, delimiter=";")
    writer.writerow([_spreadsheet_safe(c) for c in columns])
    for l in rows:
        writer.writerow([_spreadsheet_safe(l.get(c)) for c in columns])
    writer.writerow([])
    writer.writerow([f"# {title} · generated on {datetime.now():%d/%m/%Y %H:%M} · profile {profile}"])
    writer.writerow([f"# {WEIGHTS_NOTICE}"])
    writer.writerow(["# CONFIDENTIAL: restricted to the authorized team (LGPD). Do not share outside the institution."])
    return ("﻿" + output.getvalue()).encode("utf-8")


def _button_icon(container_key: str, icon_name: str):
    css(f".st-key-{container_key} button::before {{ content:''; -webkit-mask-image:{icon_url(icon_name, '#000')};"
        f" mask-image:{icon_url(icon_name, '#000')}; }}")


def export_button(rows, columns, title, file_name):
    key = "lk_exp_" + _slug(file_name)
    _button_icon(key, "download")
    with st.container(key=key):
        _download_button(rows, columns, title, file_name)


def _download_button(rows, columns, title, file_name):
    st.download_button("Export CSV", export_csv(rows, columns, title, st.session_state.get("profile", "")),
                       file_name=file_name, mime="text/csv", help="The file carries the version and "
                       "confidentiality footer (RF21, RN23).")


def ir(url_path: str, **state):
    st.session_state.update(state)
    page = st.session_state.get("_pages", {}).get(url_path)
    if page is not None:
        st.switch_page(page)


def link(label: str, url_path: str, key: str, icon_name: str | None = None, **state):
    if icon_name:
        _button_icon("lk_" + key, icon_name)
    with st.container(key="lk_" + key):
        if st.button(label, key=key):
            ir(url_path, **state)


def go_back(label: str, key: str) -> bool:
    with st.container(key="vt_" + key):
        return st.button(label, key=key)


def pill(text: str, background: str | None = None, color: str | None = None, icon_name: str | None = None,
           outline: bool = False) -> str:
    ic = icon(icon_name, 12) if icon_name else ""
    if outline:
        return f'<span class="mf-pill outline">{html.escape(text)}</span>'
    return (f'<span class="mf-pill" style="background:{background or COLOR["goldSoft"]};color:{color or COLOR["text"]}">'
            f'{ic}{html.escape(text)}</span>')


def bar(value, maximum=100, color: str | None = None, width: str = "100%") -> str:
    pct = 0 if value is None or not maximum else max(0, min(100, float(value) / maximum * 100))
    return (f'<div class="mf-bar" style="width:{width}"><i style="width:{pct:.0f}%;'
            f'background:{color or COLOR["mustard"]}"></i></div>')


def person(name: str, detail: str = "", size: int = 32) -> str:
    return (f'<div class="mf-l-list" style="min-height:0">{avatar(name, size)}<div><b>{html.escape(name)}</b>'
            f'<small>{html.escape(detail)}</small></div></div>')


def table_name(key: str, header: list[str], weights: list[float], rows: list[tuple], action_label: str | None = None,
           primary: bool = False, footer: str = ""):
    clicked = None
    all_weights = weights + ([0.9] if action_label else [])
    with st.container(key="pn_tb_" + key):
        grade = " ".join(f"{p}fr" for p in all_weights)
        st.markdown(f'<div class="mf-table-header" style="grid-template-columns:{grade}">'
                    + "".join(f"<span>{html.escape(c)}</span>" for c in header + ([""] if action_label else []))
                    + "</div>", unsafe_allow_html=True)
        for ident, cells in rows:
            with st.container(key=f"lin_{key}_{_slug(str(ident))}"):
                cols = st.columns(all_weights, vertical_alignment="center")
                for col, content in zip(cols, cells):
                    col.markdown(content, unsafe_allow_html=True)
                if action_label and cols[-1].button(action_label, key=f"bt_{key}_{_slug(str(ident))}",
                                                   type="primary" if primary else "secondary"):
                    clicked = ident
        if footer:
            st.markdown(f'<div class="mf-table-footer">{footer}</div>', unsafe_allow_html=True)
    return clicked


def hero(name: str, html_badge: str, meta: list[tuple[str, str]], proportion=(3, 1)):
    with st.container(key="hero"):
        left, dir_ = st.columns(proportion, vertical_alignment="center")
        left.markdown(f'<div class="mf-hero">{avatar(name, 64)}<div><h1>{html.escape(name)} {html_badge}</h1>'
                     '<div class="meta">' + "".join(f"<span>{icon(i, 14)}{html.escape(t)}</span>" for i, t in meta)
                     + '</div></div></div>', unsafe_allow_html=True)
    return dir_


def notice(title: str, text: str, icon_name: str = "info"):
    st.markdown(f'<div class="mf-notice">{icon(icon_name, 20, COLOR["deep"])}<div><b>{html.escape(title)}</b>'
                f'<span>{html.escape(text)}</span></div></div>', unsafe_allow_html=True)


def shortcut(key: str, url_path: str, title: str, text: str, icon_name: str):
    page = st.session_state.get("_pages", {}).get(url_path)
    if page is None:
        return
    css_text = text.replace("\\", "").replace("'", "’")
    css(f".st-key-at_{key} [data-testid='stPageLink'] a::before {{ background-image:{icon_url(icon_name, COLOR['deep'])}; }}"
        f".st-key-at_{key} [data-testid='stPageLink'] a::after {{ content:'{css_text}'; }}")
    with st.container(key="at_" + key):
        st.page_link(page, label=title)


def link_text(label: str, key: str) -> bool:
    with st.container(key="tx_" + key):
        return st.button(label, key=key)


def decision_badge() -> str:
    return pill("System recommendation — human decision", COLOR["text"], "#FFFFFF", "shield-check")


def avatar(name: str | None, size: int = 36) -> str:
    return (f'<span class="mf-avatar" style="width:{size}px;height:{size}px">'
            f'{html.escape(initial(name))}</span>')
