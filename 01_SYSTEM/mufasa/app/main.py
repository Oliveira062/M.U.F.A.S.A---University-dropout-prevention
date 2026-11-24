from app.api.database import get_engine
from app.api.routes import router
from app.api.admin_routes import router_admin
from app.api.alert_routes import alert_router
from app.api.student_routes import student_router
from app.api.account_routes import account_router
from app.api.dashboard_routes import dashboard_router
from app.factory import create_service

from app.log_record import configure_logging

configure_logging("api")

ROUTERS = (router, account_router, alert_router, dashboard_router, student_router, router_admin)


def create_app():
    return create_service("api", "MUFASA API", ROUTERS, get_engine, life_signal=True)


app = create_app()
