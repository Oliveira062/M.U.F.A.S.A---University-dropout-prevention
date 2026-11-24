import streamlit as st

import client
import shell
import ui
from screens import access, admin, student, alerts, common, coordination, teacher, dpo, finance, management, ssc

st.set_page_config(page_title="MUFASA", page_icon="static/logo.png", layout="wide", initial_sidebar_state="expanded")
ui.apply_theme()
ui.accessibility()

def profile_pages(profile: str):
    P = st.Page
    notifications = P(common.notifications, title="Notifications", url_path="notifications")
    account = P(common.my_account, title="My account", url_path="account")
    assistant = P(common.assistant, title="Assistant", url_path="assistant")
    record = P(common.record, title="Student record", url_path="record")
    menu, extras = [], [notifications, account]
    if profile == "COORDINATION":
        menu = [(P(coordination.hub, title="Course dashboard", url_path="dashboard", default=True), "layout-dashboard"),
                (P(alerts.queue, title="Alerts", url_path="alerts"), "bell-ring"),
                (P(coordination.students, title="Students", url_path="students"), "users"),
                (assistant, "sparkles"),
                (P(coordination.parameters, title="Parameters", url_path="parameters"), "sliders-horizontal")]
        extras.append(record)
    elif profile == "SUPPORT_CENTER":
        menu = [(P(ssc.hub, title="My alerts", url_path="start", default=True), "bell-ring"),
                (P(ssc.students, title="Assigned students", url_path="students"), "users"),
                (assistant, "sparkles"),
                (P(alerts.queue, title="Full queue", url_path="alerts"), "list")]
        extras.append(record)
    elif profile == "TEACHER":
        menu = [(P(teacher.hub, title="My classes", url_path="classes", default=True), "book-open"),
                (P(alerts.queue, title="Students", url_path="alerts"), "users"),
                (assistant, "sparkles")]
        extras += [record, P(teacher.class_value, title="Class", url_path="class_value")]
    elif profile == "FINANCE":
        menu = [(P(finance.hub, title="Financial factor", url_path="start", default=True), "wallet"),
                (P(alerts.queue, title="Alerts", url_path="alerts"), "bell-ring")]
        extras.append(record)
    elif profile == "BOARD":
        menu = [(P(management.hub, title="Institutional dashboard", url_path="dashboard", default=True), "landmark"),
                (P(management.reports, title="Reports", url_path="reports"), "file-chart-column")]
    elif profile == "ADMIN":
        menu = [(P(admin.hub, title="Technical view", url_path="start", default=True), "monitor"),
                (P(admin.loads, title="Data loads", url_path="loads"), "database"),
                (P(admin.users, title="Users", url_path="users"), "users"),
                (P(admin.parameters, title="Parameters", url_path="parameters"), "sliders-horizontal"),
                (P(admin.records, title="Technical logs", url_path="records"), "terminal")]
    elif profile == "DPO":
        menu = [(P(dpo.hub, title="Audit trail", url_path="audit", default=True), "shield-check"),
                (P(dpo.requests, title="Data subject requests", url_path="requests"), "inbox")]
    elif profile == "STUDENT":
        menu = [(P(student.hub, title="Home", url_path="start", default=True), "house"),
                (P(student.indicators, title="My indicators", url_path="indicators"), "chart-line"),
                (P(student.support, title="Support", url_path="support"), "hand-heart"),
                (assistant, "sparkles"),
                (P(student.privacy, title="My profile and privacy", url_path="privacy"), "shield")]
    return [p for p, _ in menu] + extras, menu, notifications, account


def main():
    if "token" not in st.session_state:
        access.login_screen()
        return
    try:
        account = client.get("/api/v1/account/eu")
    except client.ApiError as e:
        if "token" not in st.session_state:
            st.rerun()
        st.error(e.message)
        if st.button("Back to login"):
            client.close_local_session()
            st.rerun()
        return
    st.session_state["account"] = account
    if account["pending_term"] or account["must_change_password"]:
        access.first_access(account)
        return
    pages, menu, notifications, account_page = profile_pages(account["profile"])
    st.session_state["_pages"] = {p.url_path: p for p in pages}
    navigation = st.navigation(pages, position="hidden")
    shell.sidebar_menu(account, menu, navigation)
    shell.upper_bar(account, navigation.title, notifications, account_page)
    navigation.run()
    ui.footer()


main()
