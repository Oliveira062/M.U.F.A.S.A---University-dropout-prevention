import html
from pathlib import Path

import streamlit as st

import client
import ui

PROFILES = [("STUDENT", "Student"), ("TEACHER", "Teacher"), ("COORDINATION", "Coordination"),
          ("SUPPORT_CENTER", "SSC — Student Support Center"), ("FINANCE", "Finance office"), ("BOARD", "Management"),
          ("ADMIN", "Technical administration"), ("DPO", "Data protection officer")]
DOCS = Path(__file__).resolve().parents[2] / "docs"
TERM_VERSION = "1.0"


def _read_document(name: str) -> str:
    try:
        return (DOCS / name).read_text(encoding="utf-8")
    except OSError:
        return "Document unavailable in this installation. Ask the data protection officer for the text."


def _css_login():
    c = ui.COLOR
    ui.css(f"""
  .block-container {{ max-width:none !important; padding:0 !important; }}
  [data-testid="stHorizontalBlock"]:has(.st-key-brand_login) {{ gap:0; min-height:100vh; align-items:stretch; }}
  [data-testid="stColumn"]:has(> div > .st-key-brand_login),
  [data-testid="stColumn"]:has(.st-key-brand_login) {{ background:{c['cream']}; }}
  .st-key-brand_login {{ min-height:100vh; padding:56px clamp(32px, 4vw, 72px) 48px clamp(32px, 4vw, 72px);
      display:flex; flex-direction:column; box-sizing:border-box; }}
  .st-key-login_form {{ min-height:100vh; justify-content:center; box-sizing:border-box; width:100%; max-width:456px;
      margin:0 auto; padding:48px 24px; }}
  .mf-brand-lg {{ display:flex; gap:14px; align-items:flex-start; }}
  .mf-brand-lg img {{ width:52px; height:52px; border-radius:10px; }}
  .mf-brand-lg b {{ font-size:14px; color:{c['text']}; display:block; }}
  .mf-brand-lg b {{ line-height:20px; }}
  .mf-brand-lg span {{ font-size:13px; color:{c['text2']}; line-height:18px; display:block; max-width:340px; margin-top:2px; }}
  .st-key-brand_login > [data-testid="stElementContainer"]:has(.mf-headline-lg),
  .st-key-brand_login > [data-testid="stElementContainer"]:has(.mf-badges-lg) {{ margin-top:auto; }}
  .mf-headline-lg {{ padding-top:48px; }}
  .mf-headline-lg h1 {{ font-size:34px; line-height:42px; font-weight:700; color:{c['text']}; margin:0 0 14px 0;
                      padding:0; max-width:400px; }}
  .mf-headline-lg p {{ font-size:15px; line-height:24px; color:{c['text2']}; max-width:420px; margin:0; }}
  .mf-badges-lg {{ padding-top:48px; }}
  .mf-badges-lg div {{ display:flex; gap:10px; align-items:center; font-size:13px; color:{c['text2']}; margin-top:10px; }}
  .mf-title-lg {{ font-size:28px; line-height:36px; font-weight:700; color:{c['text']}; margin:0 0 6px 0; }}
  .mf-lg-sub {{ font-size:14px; line-height:21px; color:{c['text2']}; margin:0 0 8px 0; }}
  .st-key-login_form [data-testid="stForm"] {{ border:none; padding:0; }}
  .st-key-login_form label p {{ font-size:13px !important; font-weight:600; color:{c['text']}; letter-spacing:0; }}
  .st-key-login_form [data-baseweb="input"] {{ min-height:44px; }}
  .st-key-login_form input {{ height:42px; }}
  .st-key-login_field [data-baseweb="input"] {{ background:#FFFFFF {ui.icon_url('user', c['text2'])} no-repeat 14px center / 16px
      !important; padding-left:30px; }}
  .st-key-password_field [data-baseweb="input"] {{ background:#FFFFFF {ui.icon_url('lock', c['text2'])} no-repeat 14px center / 16px
      !important; padding-left:30px; }}
  .st-key-login_form input:-webkit-autofill, .st-key-login_form input:-webkit-autofill:focus {{
      -webkit-box-shadow:0 0 0 1000px #FFFFFF inset; -webkit-text-fill-color:{c['text']}; }}
  .st-key-login_form [data-testid="stFormSubmitButton"] button {{ height:46px; font-size:15px; margin-top:6px; }}
  .mf-help-lg {{ font-size:12px; color:{c['text2']}; margin:4px 0 0 0; line-height:18px; }}
""")


def login_screen():
    _css_login()
    left, right = st.columns([0.39, 0.61], gap=None, vertical_alignment="top")
    with left:
        with st.container(key="brand_login"):
            st.markdown('<div class="mf-brand-lg"><img src="app/static/logo.png" alt="MUFASA logo"><div><b>MUFASA</b>'
                        '<span>University Monitoring of Attendance, Activities, Health and Learning</span></div></div>',
                        unsafe_allow_html=True)
            st.markdown('<div class="mf-headline-lg"><h1>Every student seen in time.</h1><p>Dropout risk signals '
                        'gathered in one place, with explainable recommendations and decisions that are always human.</p></div>',
                        unsafe_allow_html=True)
            st.markdown(f'<div class="mf-badges-lg"><div>{ui.icon("shield-check", 16, ui.COLOR["deep"])}Data processed '
                        f'according to the LGPD</div><div>{ui.icon("lock", 16, ui.COLOR["deep"])}Access by profile, with an audit '
                        'trail</div></div>', unsafe_allow_html=True)
    with right:
        with st.container(key="login_form"):
            st.markdown('<div class="mf-title-lg">Sign in</div><div class="mf-lg-sub">Use your institutional login to '
                        'access MUFASA. Students sign in with their student ID.</div>', unsafe_allow_html=True)
            if notice := st.session_state.pop("login_notice", None):
                st.info(notice)
            with st.form("login", clear_on_submit=False, border=False):
                profile = st.selectbox("Access profile", PROFILES, format_func=lambda p: p[1],
                                      help="Choose your account's profile. A profile other than the registered one does not get in.")
                with st.container(key="login_field"):
                    login = st.text_input("Institutional login (student: student ID)", max_chars=64,
                                          autocomplete="username", placeholder="e.g.: coordination.demo or ALU0001")
                with st.container(key="password_field"):
                    password = st.text_input("Password", type="password", max_chars=72, autocomplete="current-password")
                send = st.form_submit_button("Sign in  →", type="primary", width="stretch")
            st.markdown('<div class="mf-help-lg">Forgot your password? Ask technical administration to reset it through the '
                        'institutional channel. After 5 wrong attempts, access is blocked for 15 minutes.</div>',
                        unsafe_allow_html=True)
            if send:
                if not login or not password:
                    st.error("Fill in login and password.")
                    return
                try:
                    client.enter(login.strip(), password, profile[0])
                except client.ApiError as e:
                    st.error(f"Could not sign in. {e.message}")
                    return
                st.rerun()


def first_access(account: dict):
    _, half, _ = st.columns([1, 2.2, 1])
    with half:
        _first_access(account)


def _first_access(account: dict):
    st.markdown(f'<div class="mf-brand" style="display:flex;gap:12px;align-items:center;margin:24px 0 20px 0">'
                f'<img src="app/static/logo.png" alt="MUFASA logo" style="width:44px;height:44px;border-radius:10px">'
                f'<div><b style="display:block;font-size:15px">MUFASA</b><span style="font-size:13px;color:'
                f'{ui.COLOR["text2"]}">First access · {html.escape(account.get("name") or account["login"])}</span></div></div>',
                unsafe_allow_html=True)
    if account["pending_term"]:
        with ui.dashboard("term"):
            ui.header("Privacy notice and terms of use", "Before using the system, read how your data and the data "
                         "of students are processed. The acceptance is recorded with date and version.", "Step 1 of 2")
            with st.expander("Terms of use (version 1.0)"):
                st.markdown(_read_document("TERMS_OF_USE.md"))
            with st.expander("Privacy policy"):
                st.markdown(_read_document("PRIVACY_POLICY.md"))
            li = st.checkbox("I have read and agree to the terms of use and the privacy policy.")
            with st.container(horizontal=True):
                if st.button("Accept and continue", type="primary", disabled=not li):
                    with ui.section():
                        client.post("/api/v1/account/term", {"version": TERM_VERSION, "accepted": True})
                        st.rerun()
                if st.button("Exit"):
                    client.logout()
                    st.rerun()
        return
    if account["must_change_password"]:
        with st.form("password"):
            ui.header("Change the temporary password", "The password you received is temporary. Create your own password: at least "
                         "10 characters, with letters and numbers, without your login.", "Step 2 of 2")
            current = st.text_input("Temporary password", type="password", max_chars=72)
            new = st.text_input("New password", type="password", max_chars=72, autocomplete="new-password")
            repeat = st.text_input("Repeat the new password", type="password", max_chars=72)
            ok = st.form_submit_button("Save new password", type="primary")
        if ok:
            if new != repeat:
                st.error("The new passwords do not match.")
                return
            try:
                client.post("/api/v1/account/password", {"current_password": current, "new_password": new})
            except client.ApiError as e:
                detail = "; ".join(c["message"] for c in e.fields) if e.fields else ""
                st.error(f"{e.message} {detail}")
                return
            st.success("Password changed.")
            st.rerun()
