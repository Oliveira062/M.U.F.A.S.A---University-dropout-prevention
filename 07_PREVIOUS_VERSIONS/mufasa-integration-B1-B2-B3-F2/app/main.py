"""
MUFASA FastAPI application: registers routes, error handlers and the
HTTP security layers.
"""

import logging

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.httpsredirect import HTTPSRedirectMiddleware
from fastapi.middleware.trustedhost import TrustedHostMiddleware

from app.api.errors import register_handlers
from app.api.routes import router
from app.api.security import SecurityHeaders
from app.chatbot.chat_routes import router_chat
from app.config import get_configuration

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(name)s %(message)s")


def create_app() -> FastAPI:
    cfg = get_configuration()
    docs = cfg.docs_enabled and not cfg.in_production

    app = FastAPI(
        title="MUFASA",
        version="0.3.0",
        description="API of the early dropout warning system. Every endpoint requires a token, except /health and /api/v1/auth/token.",
        docs_url="/docs" if docs else None,
        redoc_url=None,
        openapi_url="/openapi.json" if docs else None,
    )

    register_handlers(app)

    # Order: the last one added is the first to run.
    app.add_middleware(SecurityHeaders, hsts=cfg.force_https)
    if cfg.cors_origins:
        app.add_middleware(
            CORSMiddleware,
            allow_origins=cfg.cors_origins,          # explicit list, never "*"
            allow_credentials=False,                 # token goes in the header, not in a cookie
            allow_methods=["GET", "POST", "PATCH", "PUT"],
            allow_headers=["Authorization", "Content-Type"],
            max_age=600,
        )
    app.add_middleware(TrustedHostMiddleware, allowed_hosts=cfg.allowed_hosts)
    if cfg.force_https:
        app.add_middleware(HTTPSRedirectMiddleware)

    app.include_router(router)
    app.include_router(router_chat)  # chatbot (F2): same authentication and scope as the API

    @app.get("/health", tags=["health"])
    def check_health():
        return {"status": "up", "system": "MUFASA"}

    return app


app = create_app()
