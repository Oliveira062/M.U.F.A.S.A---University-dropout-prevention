import asyncio
import contextlib
import logging
from datetime import datetime, timezone

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.httpsredirect import HTTPSRedirectMiddleware
from fastapi.middleware.trustedhost import TrustedHostMiddleware
from fastapi.responses import JSONResponse
from sqlalchemy import text

from app import __version__
from app.api.errors import register_handlers
from app.api.security import SecurityHeaders
from app.config import get_configuration

log = logging.getLogger("mufasa.service")

_PING = text("SELECT 1")
_LOG = text("""
    INSERT INTO technical_logs (moment, service, level, event, message, request_id)
    VALUES (:now, :service, 'ERROR', :event, '', :request_id)
""")
_SIGNAL = text("""
    INSERT INTO service_status (service, last_signal, detail) VALUES (:service, :now, :detail)
    ON CONFLICT (service) DO UPDATE SET last_signal = EXCLUDED.last_signal, detail = EXCLUDED.detail
""")
SIGNAL_INTERVAL_S = 15


def create_service(name: str, title: str, routers, get_engine, life_signal: bool) -> FastAPI:
    cfg = get_configuration()
    docs = cfg.docs_enabled and not cfg.in_production

    def save_signal():
        with get_engine().begin() as connection:
            connection.execute(_SIGNAL, {"service": name, "now": datetime.now(timezone.utc),
                                         "detail": f"{title} v{__version__}"})

    async def loop_signal():
        while True:
            try:
                await asyncio.to_thread(save_signal)
            except Exception:
                log.warning("heartbeat of %s not saved (database unavailable?)", name)
            await asyncio.sleep(SIGNAL_INTERVAL_S)

    @contextlib.asynccontextmanager
    async def cycle(_app):
        task = asyncio.create_task(loop_signal()) if life_signal else None
        yield
        if task:
            task.cancel()

    app = FastAPI(title=title, version=__version__, lifespan=cycle,
                  description="Every endpoint requires a token, except /health and /api/v1/auth/token.",
                  docs_url="/docs" if docs else None, redoc_url=None, openapi_url="/openapi.json" if docs else None)

    def register_error(event: str, request_id: str):
        with get_engine().begin() as connection:
            connection.execute(_LOG, {"now": datetime.now(timezone.utc), "service": name, "event": event[:60],
                                      "request_id": request_id[:32]})

    register_handlers(app, register_error)

    app.add_middleware(SecurityHeaders, hsts=cfg.force_https)
    if cfg.cors_origins:
        app.add_middleware(CORSMiddleware, allow_origins=cfg.cors_origins, allow_credentials=False,
                           allow_methods=["GET", "POST", "PATCH", "PUT"],
                           allow_headers=["Authorization", "Content-Type"], max_age=600)
    app.add_middleware(TrustedHostMiddleware, allowed_hosts=cfg.allowed_hosts)
    if cfg.force_https:
        app.add_middleware(HTTPSRedirectMiddleware)

    for router in routers:
        app.include_router(router)

    @app.get("/health", tags=["health"])
    def check_health():
        try:
            with get_engine().connect() as connection:
                connection.execute(_PING)
            return {"status": "up", "service": name, "version": __version__, "database": "ok"}
        except Exception:
            return JSONResponse({"status": "degraded", "service": name, "version": __version__, "database": "unavailable"},
                                status_code=503)

    return app
