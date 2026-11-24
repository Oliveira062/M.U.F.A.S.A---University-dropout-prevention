import os
import threading
import time
from dataclasses import dataclass

import httpx
import streamlit as st

from dashboard_logging import log

URL_API = os.environ.get("MUFASA_API_URL", "http://127.0.0.1:8000").rstrip("/")
URL_CHAT = os.environ.get("MUFASA_CHAT_URL", "http://127.0.0.1:8001").rstrip("/")
LIMIT_TIME = httpx.Timeout(10.0, connect=3.0)
FAILURES_TO_OPEN = 3
OPEN_TIME_S = 20
RENEW_REMAINING_S = 600


class ApiError(Exception):
    def __init__(self, status: int, message: str, fields=None, pending_item=None, request=None):
        super().__init__(message)
        self.status, self.message, self.fields, self.pending_item = status, message, fields or [], pending_item
        self.request = request


class UnavailableService(ApiError):
    pass


@dataclass
class _Breaker:
    failures: int = 0
    open_until: float = 0.0


_breakers = {"api": _Breaker(), "chat": _Breaker()}
_lock = threading.Lock()


def _before(service: str):
    with _lock:
        d = _breakers[service]
        if d.open_until > time.monotonic():
            raise UnavailableService(503, f"The {'assistant' if service == 'chat' else 'data'} service "
                                           "is unavailable. Trying again in a moment.")


def _result(service: str, ok: bool):
    with _lock:
        d = _breakers[service]
        if ok:
            d.failures, d.open_until = 0, 0.0
        else:
            d.failures += 1
            if d.failures >= FAILURES_TO_OPEN:
                d.open_until = time.monotonic() + OPEN_TIME_S


def available_service(service: str) -> bool:
    return _breakers[service].open_until <= time.monotonic()


def _headers() -> dict:
    token = st.session_state.get("token")
    return {"Authorization": f"Bearer {token}"} if token else {}


def call(method: str, path: str, *, service: str = "api", json=None, params=None, data=None, files=None,
         authenticated: bool = True):
    _before(service)
    base = URL_CHAT if service == "chat" else URL_API
    if authenticated:
        _renew_if_needed()
    try:
        r = httpx.request(method, base + path, json=json, params=_clear(params), data=data, files=files,
                          headers=_headers() if authenticated else {}, timeout=LIMIT_TIME)
    except httpx.HTTPError as exc:
        log.warning("no answer from service %s at %s: %s", service, method, type(exc).__name__)
        _result(service, False)
        raise UnavailableService(503, "Could not reach the server. Try again in a moment.")
    _result(service, r.status_code < 500)
    if r.status_code == 204:
        return None
    try:
        body = r.json()
    except ValueError:
        body = {}
    if r.status_code >= 400:
        detail = body.get("detail") if isinstance(body, dict) else None
        if r.status_code == 401 and authenticated:
            close_local_session("Your session expired. Sign in again.")
        if r.status_code >= 500:
            log.warning("API answered %s at %s %s (req=%s)", r.status_code, method, path.split("?")[0],
                        r.headers.get("X-Request-ID") or (body.get("request") if isinstance(body, dict) else None))
        raise ApiError(r.status_code, detail or "Could not complete the operation.",
                       body.get("fields") if isinstance(body, dict) else None, r.headers.get("X-Pending"),
                       r.headers.get("X-Request-ID") or (body.get("request") if isinstance(body, dict) else None))
    return body


def _clear(params):
    if not params:
        return None
    return {k: v for k, v in params.items() if v not in (None, "", "All", "All")}


def get(path, **params):
    return call("GET", path, params=params)


def post(path, json=None, **kw):
    return call("POST", path, json=json, **kw)


def patch(path, json=None):
    return call("PATCH", path, json=json)


def put(path, json=None):
    return call("PUT", path, json=json)


def enter(login: str, password: str, profile: str) -> dict:
    t = call("POST", "/api/v1/auth/token", json={"login": login, "password": password, "profile": profile},
             authenticated=False)
    store_token(t)
    return t


def store_token(t: dict):
    st.session_state["token"] = t["access_token"]
    st.session_state["expires_token"] = time.time() + int(t["expires_in_seconds"])
    st.session_state["profile"] = t["profile"]


def _renew_if_needed():
    expires = st.session_state.get("expires_token")
    if not expires or st.session_state.get("_renewing"):
        return
    if expires - time.time() < RENEW_REMAINING_S:
        st.session_state["_renewing"] = True
        try:
            store_token(call("POST", "/api/v1/auth/renew"))
        except ApiError:
            pass
        finally:
            st.session_state["_renewing"] = False


def close_local_session(reason: str | None = None):
    for key in list(st.session_state.keys()):
        del st.session_state[key]
    if reason:
        st.session_state["login_notice"] = reason


def logout():
    try:
        call("POST", "/api/v1/auth/logout")
    except ApiError:
        pass
    close_local_session("You signed out of the system.")
