import logging
import threading
import time
import uuid
from collections import defaultdict, deque

from starlette.middleware.base import BaseHTTPMiddleware
from starlette.requests import Request
from starlette.responses import JSONResponse, Response

CSP_API = "default-src 'none'; frame-ancestors 'none'; base-uri 'none'; form-action 'none'"

CSP_DOCS = (
    "default-src 'none'; script-src 'self' https://cdn.jsdelivr.net 'unsafe-inline'; "
    "style-src 'self' https://cdn.jsdelivr.net 'unsafe-inline'; img-src 'self' data: https://fastapi.tiangolo.with_values; "
    "connect-src 'self'; frame-ancestors 'none'; base-uri 'none'"
)

BODY_MAXIMUM_SIZE = 64 * 1024
LOAD_MAXIMUM_SIZE = 20 * 1024 * 1024 + 64 * 1024
LOAD_PATH = "/api/v1/imports"

log_req = logging.getLogger("mufasa.requests")
SLOW_MS = 2000


class SecurityHeaders(BaseHTTPMiddleware):
    def __init__(self, app, hsts: bool):
        super().__init__(app)
        self.hsts = hsts

    async def dispatch(self, request: Request, call_next) -> Response:
        request.state.request_id = uuid.uuid4().hex[:12]

        size = request.headers.get("content-length")
        limit = LOAD_MAXIMUM_SIZE if request.url.path == LOAD_PATH else BODY_MAXIMUM_SIZE
        if size is None and "chunked" in request.headers.get("transfer-encoding", "").lower():
            return JSONResponse(
                {"title": "Size required", "status": 411,
                 "detail": "Send the Content-Length header.", "request": request.state.request_id},
                status_code=411,
            )
        if size is not None and (not size.isdigit() or int(size) > limit):
            return JSONResponse(
                {"title": "Content too large", "status": 413,
                 "detail": "The request body exceeds the limit.", "request": request.state.request_id},
                status_code=413,
            )

        start = time.perf_counter()
        answer = await call_next(request)
        duration_ms = (time.perf_counter() - start) * 1000
        route = getattr(request.scope.get("route"), "path", "unknown-route")
        level = logging.WARNING if answer.status_code >= 500 or duration_ms > SLOW_MS else logging.INFO
        log_req.log(level, "req=%s %s %s -> %s in %.0f ms", request.state.request_id, request.method, route,
                    answer.status_code, duration_ms)

        path = request.url.path
        is_docs = path in ("/docs", "/redoc", "/openapi.json") or path.startswith("/docs/")
        answer.headers["X-Request-ID"] = request.state.request_id
        answer.headers["X-Content-Type-Options"] = "nosniff"
        answer.headers["X-Frame-Options"] = "DENY"
        answer.headers["Referrer-Policy"] = "no-referrer"
        answer.headers["Permissions-Policy"] = "camera=(), microphone=(), geolocation=(), interest-cohort=()"
        answer.headers["Cross-Origin-Opener-Policy"] = "same-origin"
        answer.headers["Content-Security-Policy"] = CSP_DOCS if is_docs else CSP_API
        answer.headers["Cache-Control"] = "no-store"
        if self.hsts:
            answer.headers["Strict-Transport-Security"] = "max-age=31536000; includeSubDomains"
        if "server" in answer.headers:
            del answer.headers["server"]
        return answer


class WindowLimiter:

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
    return request.client.host if request.client else "unknown"
