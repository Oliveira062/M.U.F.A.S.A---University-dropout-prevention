"""
Standardized error format (SRS Section 3.3 and Annex D.1).

No error response carries a stack trace, table name,
SQL query or the value the user sent. The technical detail stays only
in the server log, linked by the request identifier.
"""

import logging

from fastapi import FastAPI, HTTPException, Request
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from starlette.exceptions import HTTPException as StarletteHTTPException

log = logging.getLogger("mufasa.errors")

TITLES = {
    400: "Invalid request",
    401: "Authentication required",
    403: "Insufficient permission",
    404: "Resource not found",
    405: "Method not allowed",
    409: "Conflict",
    413: "Content too large",
    422: "Invalid data",
    423: "Access temporarily blocked",
    429: "Too many requests",
    500: "Internal error",
}

# Single message for "does not exist" and "cannot see": whoever asks about another
# student does not find out whether the student ID exists (RN07).
DENIED_ACCESS_MSG = "You do not have permission to access this student's data, or the student does not exist."


# Validation messages in clear Portuguese (RN10). Pydantic answers in English.
VALIDATION_MESSAGES = {
    "missing": "Required field.",
    "extra_forbidden": "Field not allowed.",
    "string_too_short": "Text too short.",
    "string_too_long": "Text too long.",
    "string_pattern_mismatch": "Invalid format.",
    "string_type": "Must be text.",
    "int_parsing": "Must be an integer.",
    "int_type": "Must be an integer.",
    "greater_than_equal": "Value below the minimum allowed.",
    "less_than_equal": "Value above the maximum allowed.",
    "enum": "Value not in the allowed list.",
    "bool_parsing": "Must be true or false.",
    "json_invalid": "Invalid JSON.",
}


def _request_id(request: Request) -> str:
    return getattr(request.state, "request_id", "-")


def error_answer(request: Request, status: int, detail: str, extra: dict | None = None,
                  headers: dict | None = None) -> JSONResponse:
    body = {
        "title": TITLES.get(status, "Error"),
        "status": status,
        "detail": detail,
        "request": _request_id(request),
    }
    if extra:
        body.update(extra)
    return JSONResponse(body, status_code=status, headers=headers)


def register_handlers(app: FastAPI) -> None:
    @app.exception_handler(StarletteHTTPException)
    async def _http(request: Request, exc: StarletteHTTPException):
        detail = exc.detail if isinstance(exc.detail, str) else TITLES.get(exc.status_code, "Error")
        return error_answer(request, exc.status_code, detail, headers=getattr(exc, "headers", None))

    @app.exception_handler(RequestValidationError)
    async def _validation(request: Request, exc: RequestValidationError):
        # FastAPI's default handler returns the "input" field, which repeats the value
        # sent - including the password of a badly formatted login. Here only
        # the field name and the message go.
        fields = [
            {"field": ".".join(str(p) for p in error.get("loc", ()) if p != "body"),
             "message": VALIDATION_MESSAGES.get(error.get("type"), "Invalid value.")}
            for error in exc.errors()
        ]
        return error_answer(request, 422, "One or more fields are invalid.", {"fields": fields})

    @app.exception_handler(Exception)
    async def _unexpected(request: Request, exc: Exception):
        # Full stack only in the server log.
        log.exception("Unhandled error in request %s", _request_id(request))
        return error_answer(request, 500, "An unexpected error occurred. Give the request code to support.")


def http_error(status: int, detail: str, headers: dict | None = None) -> HTTPException:
    return HTTPException(status_code=status, detail=detail, headers=headers)
