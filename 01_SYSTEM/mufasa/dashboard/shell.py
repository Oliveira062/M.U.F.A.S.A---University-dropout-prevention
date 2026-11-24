import html

import streamlit as st

import client
import ui

PROFILE_NAME = {"STUDENT": "Student", "TEACHER": "Teacher", "COORDINATION": "Coordination", "SUPPORT_CENTER": "SSC",
                "FINANCE": "Finance office", "BOARD": "Management", "ADMIN": "Technical administration",
                "DPO": "Data protection officer"}
AREA = {"COORDINATION": "Coordination", "SUPPORT_CENTER": "SSC", "TEACHER": "Teacher", "FINANCE": "Finance office",
        "BOARD": "Management", "ADMIN": "Technical administration", "DPO": "Data protection officer",
        "STUDENT": "Student portal"}
COUNT_ALERTS = {"COORDINATION": "alerts", "SUPPORT_CENTER": "start"}
NO_DECISION = ("STUDENT", "BOARD", "ADMIN", "DPO")


def _shell_css():
    c = ui.COLOR
    ui.css(f"""
  section[data-testid="stSidebar"] [data-testid="stSidebarContent"] {{ padding:0 !important; }}
  section[data-testid="stSidebar"] [data-testid="stSidebarUserContent"] {{ padding:16px !important; }}
  section[data-testid="stSidebar"] [data-testid="stSidebarUserContent"] > div {{ width:100% !important; max-width:100% !important; }}
  .mf-brand {{ display:flex; gap:12px; align-items:center; margin:0 0 18px 4px; }}
  .mf-brand img {{ width:44px; height:44px; border-radius:10px; }}
  .mf-brand b {{ display:block; font-size:15px; color:{c['text']}; }}
  .mf-brand span {{ font-size:13px; color:{c['text2']}; white-space:nowrap; }}
  .mf-profile {{ background:{c['creamSoft']}; border:1px solid {c['line']}; border-radius:12px; padding:10px 14px;
               display:flex; gap:12px; align-items:center; margin-bottom:22px; }}
  .mf-profile small {{ display:block; font-size:12px; color:{c['text2']}; }}
  .mf-profile b {{ font-size:13px; color:{c['text']}; font-weight:600; }}
  .mf-nav-lbl {{ font-size:12px; font-weight:600; color:{c['text2']}; margin:0 0 4px 12px; padding-bottom:6px; }}
  [data-testid="stSidebarUserContent"] > div > [data-testid="stVerticalBlock"] {{ min-height: calc(100vh - 44px); }}
  [data-testid="stLayoutWrapper"]:has(> .st-key-menu_footer), .st-key-menu_footer {{ margin-top:auto; }}
  .st-key-menu_footer {{ padding-top:24px; }}
  .mf-lgpd {{ display:flex; gap:8px; align-items:center; font-size:12px; color:{c['text3']}; margin:12px 0 0 8px; }}
  [class*="st-key-nav_"] [data-testid="stPageLink"] a {{ padding:9px 12px 9px 42px; border-radius:10px; min-height:40px;
      position:relative; border-left:3px solid transparent; width:100%; box-sizing:border-box; }}
  [class*="st-key-nav_"] [data-testid="stPageLink"] a span, [class*="st-key-nav_"] [data-testid="stPageLink"] a p {{
      font-size:14px; font-weight:500; color:{c['text']}; white-space:normal; overflow:visible;
      text-overflow:clip; line-height:1.3; }}
  [class*="st-key-nav_"] [data-testid="stPageLink"] a:hover {{ background:{c['creamSoft']}; }}
  [class*="st-key-nav_"] [data-testid="stPageLink"] a::before {{ content:""; position:absolute; left:14px; top:50%;
      width:18px; height:18px; margin-top:-9px; background-color:{c['text2']}; -webkit-mask-size:contain; mask-size:contain;
      -webkit-mask-repeat:no-repeat; mask-repeat:no-repeat; }}
  [class*="st-key-nav_"] [data-testid="stPageLink"] a::after {{ position:absolute; right:12px; top:50%; margin-top:-11px;
      min-width:22px; height:22px; border-radius:999px; background:{c['gold']}; color:{c['text']}; font-size:12px;
      font-weight:700; display:flex; align-items:center; justify-content:center; padding:0 6px; }}
  [class*="st-key-nav_"] [data-testid="stPageLink"] a [data-testid="stIconMaterial"],
  [class*="st-key-nav_"] [data-testid="stPageLink"] a > span:first-child:empty {{ display:none; }}
  .st-key-top {{ border-bottom:1px solid {c['lineSoft']}; padding-bottom:12px; margin-bottom:12px; }}
  .mf-breadcrumb {{ display:flex; gap:10px; align-items:center; font-size:14px; color:{c['text2']}; min-height:40px; }}
  .mf-breadcrumb b {{ color:{c['text']}; font-weight:600; }}
  .st-key-user {{ border-left:1px solid {c['line']}; padding-left:14px; }}
  .st-key-user [data-testid="stPageLink"] a {{ position:relative; padding:0 0 16px 46px; min-height:40px;
      display:flex; align-items:flex-start; }}
  .st-key-user [data-testid="stPageLink"] a span, .st-key-user [data-testid="stPageLink"] a p {{
      font-size:14px !important; font-weight:600; color:{c['text']}; white-space:nowrap; overflow:hidden;
      text-overflow:ellipsis; }}
  .st-key-user [data-testid="stPageLink"] a::before {{ position:absolute; left:0; top:2px; width:36px; height:36px;
      border-radius:999px; background:{c['goldSoft']}; color:{c['deep']}; font-size:12px; font-weight:700;
      display:flex; align-items:center; justify-content:center; }}
  .st-key-user [data-testid="stPageLink"] a::after {{ position:absolute; left:46px; top:21px; font-size:12px;
      color:{c['text2']}; }}
  .st-key-user [data-testid="stPageLink"] a:hover {{ background:transparent; }}
  .st-key-bell [data-testid="stPageLink"] a, .st-key-logout button {{ width:40px; height:40px; min-height:40px; padding:0;
      justify-content:center; position:relative; border:none; background:transparent; }}
  .st-key-bell [data-testid="stPageLink"] a span, .st-key-bell [data-testid="stPageLink"] a p,
  .st-key-logout button p {{ font-size:0 !important; }}
  .st-key-bell [data-testid="stPageLink"] a::before, .st-key-logout button::before {{ content:""; width:20px; height:20px;
      background-color:{c['text']}; -webkit-mask-size:contain; mask-size:contain; -webkit-mask-repeat:no-repeat;
      mask-repeat:no-repeat; }}
  .st-key-bell [data-testid="stPageLink"] a::before {{ -webkit-mask-image:{ui.icon_url('bell', '#000')};
      mask-image:{ui.icon_url('bell', '#000')}; }}
  .st-key-logout button::before {{ -webkit-mask-image:{ui.icon_url('log-out', '#000')};
      mask-image:{ui.icon_url('log-out', '#000')}; }}
  .st-key-bell [data-testid="stPageLink"] a::after {{ position:absolute; top:2px; right:2px; min-width:16px; height:16px;
      border-radius:999px; background:{c['gold']}; color:{c['text']}; font-size:10px; font-weight:700; display:flex;
      align-items:center; justify-content:center; padding:0 3px; }}
""")


def _css_item(key: str, icon: str, counter, active: bool):
    c = ui.COLOR
    rules = (f".st-key-{key} [data-testid='stPageLink'] a::before {{ -webkit-mask-image:{ui.icon_url(icon, '#000')};"
             f" mask-image:{ui.icon_url(icon, '#000')}; }}")
    if counter:
        rules += f".st-key-{key} [data-testid='stPageLink'] a::after {{ content:'{int(counter)}'; }}"
    if active:
        rules += (f".st-key-{key} [data-testid='stPageLink'] a {{ background:{c['goldSoft']} !important;"
                  f" border-left-color:{c['gold']}; }}"
                  f".st-key-{key} [data-testid='stPageLink'] a span, .st-key-{key} [data-testid='stPageLink'] a p"
                  f" {{ font-weight:600 !important; }}"
                  f".st-key-{key} [data-testid='stPageLink'] a::before {{ background-color:{c['deep']}; }}")
    return rules


def _alerts_counter(profile: str):
    if profile not in COUNT_ALERTS or not client.available_service("api"):
        return None
    try:
        return client.get("/api/v1/alerts", limit=1).get("total") or None
    except client.ApiError:
        return None


def sidebar_menu(account: dict, menu: list, current):
    profile = account["profile"]
    _shell_css()
    counter = _alerts_counter(profile)
    rules = []
    with st.sidebar:
        st.markdown(f'<div class="mf-brand"><img src="app/static/logo.png" alt="MUFASA logo">'
                    f'<div><b>MUFASA</b><span>Dropout prevention</span></div></div>'
                    f'<div class="mf-profile">{ui.icon("badge-check", 18, ui.COLOR["deep"])}'
                    f'<div><small>Active profile</small><b>{html.escape(PROFILE_NAME.get(profile, profile))}</b></div></div>'
                    f'<div class="mf-nav-lbl">Navigation</div>', unsafe_allow_html=True)
        for page, icon in menu:
            key = "nav_" + page.url_path
            n = counter if COUNT_ALERTS.get(profile) == page.url_path else None
            rules.append(_css_item(key, icon, n, current is not None and page.url_path == current.url_path))
            with st.container(key=key):
                st.page_link(page, label=page.title)
        with st.container(key="menu_footer"):
            if not client.available_service("api"):
                st.warning("Unstable data server: showing what could be loaded.")
            if profile not in NO_DECISION:
                ui.human_decision()
            st.markdown(f'<div class="mf-lgpd">{ui.icon("lock", 13)}Restricted access · LGPD</div>',
                        unsafe_allow_html=True)
    ui.css("".join(rules))


def upper_bar(account: dict, title: str, notifications_page, account_page):
    profile = account["profile"]
    unread = account.get("not_read_notifications") or 0
    if unread:
        ui.css(f".st-key-bell [data-testid='stPageLink'] a::after {{ content:'{min(int(unread), 99)}'; }}")
    name = account.get("name") or account["login"]
    with st.container(key="top"):
        left, bell, user, logout = st.columns([5, 0.45, 3.6, 0.45], vertical_alignment="center")
        left.markdown(f'<div class="mf-breadcrumb">{html.escape(AREA.get(profile, ""))}{ui.icon("chevron-right", 14)}'
                      f'<b>{html.escape(title)}</b></div>', unsafe_allow_html=True)
        with bell:
            with st.container(key="bell"):
                st.page_link(notifications_page, label=f"Notifications ({unread} new)")
        ui.css(f".st-key-user [data-testid='stPageLink'] a::before {{ content:'{ui.initial(name)}'; }}"
               f".st-key-user [data-testid='stPageLink'] a::after {{ content:'{PROFILE_NAME.get(profile, profile)}'; }}")
        with user:
            with st.container(key="user"):
                st.page_link(account_page, label=name)
        with logout:
            with st.container(key="logout"):
                if st.button("Exit", help="Sign out of MUFASA"):
                    client.logout()
                    st.rerun()
