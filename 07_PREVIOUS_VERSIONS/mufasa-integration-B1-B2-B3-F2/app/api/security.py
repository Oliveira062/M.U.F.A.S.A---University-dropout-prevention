"""
HTTP security layers: request identifier, security
headers, request limit and body size limit.
"""

import threading
import time
import uuid
from collections import defaultdict, deque

from starlette.middleware.base import BaseHTTPMiddleware
from starlette.requests import Request
from starlette.responses import JSONResponse, Response

# API CSP: it only returns JSON, so nothing can be loaded or embedded.
CSP_API = "default-src 'none'; frame-ancestors 'none'; base-uri 'none'; form-action 'none'"

# /docs CSP (development only): Swagger UI comes from jsDelivr.
CSP_DOCS = (
    "default-src 'none'; script-src 'self' https://cdn.jsdelivr.net 'unsafe-inline'; "
    "style-src 'self' https://cdn.jsdelivr.net 'unsafe-inline'; img-src 'self' data: https://fastapi.tiangolo.com; "
    "connect-src 'self'; frame-ancestors 'none'; base-uri 'none'"
)

BODY_MAXIMUM_SIZE = 64 * 1024  # 64 KB: no current endpoint receives a file.


class SecurityHeaders(BaseHTTPMiddleware):
    def __init__(self, app, hsts: bool):
        super().__init__(app)
        self.hsts = hsts

    async def dispatch(self, request: Request, call_next) -> Response:
        request.state.request_id = uuid.uuid4().hex[:12]

        size = request.headers.get("content-length")
        if size is not None and (not size.isdigit() or int(size) > BODY_MAXIMUM_SIZE):
            return JSONResponse(
                {"title": "Content too large", "status": 413,
                 "detail": "The request body exceeds the limit.", "request": request.state.request_id},
                status_code=413,
            )

        answer = await call_next(request)

        path = request.url.path
        is_docs = path in ("/docs", "/redoc", "/openapi.json") or path.startswith("/docs/")
        answer.headers["X-Request-ID"] = request.state.request_id
        answer.headers["X-Content-Type-Options"] = "nosniff"
        answer.headers["X-Frame-Options"] = "DENY"
        answer.headers["Referrer-Policy"] = "no-referrer"
        answer.headers["Permissions-Policy"] = "camera=(), microphone=(), geolocation=(), interest-cohort=()"
        answer.headers["Cross-Origin-Opener-Policy"] = "same-origin"
        answer.headers["Content-Security-Policy"] = CSP_DOCS if is_docs else CSP_API
        # Personal data does not stay in the browser or proxy cache.
        answer.headers["Cache-Control"] = "no-store"
        if self.hsts:
            answer.headers["Strict-Transport-Security"] = "max-age=31536000; includeSubDomains"
        if "server" in answer.headers:
            del answer.headers["server"]
        return answer


class WindowLimiter:
    """
    Sliding window limit of 60 seconds, in memory.

    Works for a single process (sprints and presentation). With more than one
    worker, each one counts separately: in production, swap for Redis.
    """

    def __init__(self):
        self._events: dict[str, deque] = defaultdict(deque)
        self._lock = threading.Lock()

    def allow(self, key: str, limit: int, window: float = 60.0) -> tuple[bool, int]:
        now = time.monotonic()
        with self._lock:
            queue = self._events[key]
            while queue and now - queue[0] > window:
                queue.popleft()
            if len(queue) >= limit:
                wait = int(window - (now - queue[0])) + 1
                return False, wait
            queue.append(now)
            return True, 0

    def clear(self) -> None:
        with self._lock:
            self._events.clear()


limiter = WindowLimiter()


def client_ip(request: Request) -> str:
    # Behind a reverse proxy, run uvicorn with --proxy-headers and
    # --forwarded-allow-ips=<proxy ip>. Never read X-Forwarded-For by hand:
    # the client chooses the value of this header.
    return request.client.host if request.client else "unknown"
