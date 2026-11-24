# Security and LGPD Audit — MUFASA (B1, B2 and B3)

27/10/2026 · Static review of the delivered code, plus B3's automated tests.

## Scope

| Part | Material analyzed |
|---|---|
| B1 — Data and Database (Samuel) | `Samuel Part BackEnd B1.sql`: PostgreSQL 16 dump with 11 tables and data (1,000 students, 8,000 enrollments) |
| B2 — Calculation (Susy) | `app/calculation/score.py`, `app/calculation/indicators.py`, `tests/test_calculation.py`, README, CHANGELOG |
| B3 — API (this package) | `app/main.py`, `app/config.py`, `app/api/*.py`, `sql/b3_complement.sql`, `tests/test_api.py` |
| References | Back-end Build Guide, SRS v1.1, `b3/README.md` |

**Limits of this review.** B2's 41 tests were not run here (the analysis environment blocked running the code sent), and the B1 dump was not restored into a PostgreSQL. The B1 and B2 findings come from reading the code and the data. B3's 38 tests were run and pass, on a SQLite with the same tables and columns as B1.

**About the priority template.** The structure of the 5 priorities came from another project (Stripe webhook, ReviewLive, ETS, Tailwind). Items that do not exist in this code appear as **"Does not apply"**, with MUFASA's equivalent point when there is one. No finding was made up to fill the template.

## Summary by severity

| # | Severity | Finding | Status |
|---|---|---|---|
| 1.1-A | Critical | Score endpoint without authentication or owner check (BOLA) | Fixed in B3 |
| 1.2-A | High | No HTTPS enforcement or HSTS | Fixed in B3 (by configuration) |
| 1.1-B | High | Whole database owned by `postgres`, with no roles; API told to connect as superuser | Fixed for B3 in `sql/b3_complement.sql` |
| 1.1-C | High | Sensitive health and disability data in the main students table | Suggestion for B1 |
| 2.1-A | High | No request limit or login lockout | Fixed in B3 |
| 2.2-A | High | JWT library with known flaws and a predictable example key | Fixed in B3 |
| D-1 | High | Versions pinned in the guide with known vulnerabilities | Fixed in `requirements.txt` |
| 4.3-A | Medium | No access audit trail | Fixed in B3 |
| 4.4-A | Medium | B2 accepts a "ready" risk injected into the input dictionary | Suggestion for B2 |
| 4.5-A | Medium | B2 accepts NaN, infinity and out-of-range values | Suggestion for B2 (B3 already filters) |
| 4.5-B | Medium | B2 breaks with a 500 error when `absences` arrives empty | Suggestion for B2 |
| 4.5-C | Medium | B2 returns 0 remaining absences when the data does not exist | Worked around in B3; suggestion for B2 |
| 4.5-D | Medium | B1 stores grades from 0 to 100; B2 expects 0 to 10 | Suggestion for B1 |
| 2.3-A | Medium | B1 tables without primary key, foreign key, constraint or index | Suggestion for B1 (indexes in the complement) |
| L-1 | Medium | Socioeconomic collection beyond what the calculation uses | Suggestion for B1 |
| L-2 | Medium | 163 students under 18 with no record of guardian consent | B3 blocks; suggestion for B1 |
| 3.3-A | Medium | FastAPI validation error returns the value sent, including the password | Fixed in B3 |
| 4.1-A | Medium | No security headers (CSP and others) | Fixed in B3 |
| 4.4-B | Low | B1 student ID format (`ALU0001`) differs from the SRS (7 digits) | B3 accepts both for now |
| 4.5-E | Low | Level `CRITICAL` (B2) and `Critical` (B1) do not match | Worked around in B3 |
| 4.2-A | Low | `/docs` loads Swagger from an external CDN | Turned off in production |
| 5.3-A | Low | Listings without pagination in the original design | Fixed in B3 |
| 5.4-A | Informational | No secret found in the code; `.pyc` files sent reveal the author's local path | Remove the caches |

---

## Priority 1: Critical Security Issues (Today)

### 1.1 Fix Bypass in Webhook Signature Verification

**Does not apply.** MUFASA has no webhook or payment integration. The equivalent "bypass" in this project is access to student data without authentication, below.

#### 1.1-A Score endpoint without authentication and without owner check

1. **Severity:** Critical
2. **Location:** `MUFASA_Backend_Build_Guide.pdf`, page 10 (B3, step 2); `b3/README.md`, line 226
3. **Flaw Description:** B3's starting point is `@app.get("/students/{enrollment}/risk")` with no authentication dependency. When the fake data is replaced by the real data, anyone on the network reads the score and factors of any student by changing the student ID in the URL (OWASP A01, Broken Object Level Authorization / IDOR). The student ID is sequential and known to classmates, so enumeration is trivial. It violates RN07, RN17 and LGPD art. 46.
4. **Fix Suggestion:** implemented in `app/api/routes.py` and `app/api/permissions.py`:

```python
@router.get("/students/{enrollment}/score", response_model=ScoreAnswer)
def student_score(enrollment: Enrollment, request: Request,
                  user: User = Depends(require_profiles(STUDENT, TEACHER, COORDINATION, SUPPORT_CENTER)),
                  connection: Connection = Depends(get_connection)):
    # 1. authorized profile (require_profiles)  2. can this user see THIS student?
    check_student_scope(request, connection, user, enrollment, "READ_SCORE")
    ...

def _in_scope(connection, user, student_id) -> bool:
    if user.profile == STUDENT:
        return user.student_id is not None and user.student_id == student_id
    if user.profile == TEACHER:
        return connection.execute(STUDENT_OF_TEACHER_CLASSES,
                                  {"student_id": student_id, "id_professor": user.id_professor}).first() is not None
    ...
```

The denial response is the same for "does not exist" and "cannot see", and every attempt is recorded. Tests: `test_student_does_not_see_another_student_and_it_is_recorded`, `test_teacher_does_not_see_student_of_another_class`.

#### 1.1-B Database owned by `postgres` and API told to connect as superuser

1. **Severity:** High
2. **Location:** `Samuel Part BackEnd B1.sql`, lines 45, 63, 81, 101, 119, 139, 157, 173, 199, 216 and 231 (`OWNER TO postgres`); `b3/README.md`, line 176 (`DATABASE_URL=postgresql://postgres:...`)
3. **Flaw Description:** every table belongs to the superuser and there is no database role. If the API connects as `postgres`, as the example `.env` suggests, any future flaw (an SQL injection, a poorly protected endpoint) gives read and write access to everything, deletes the audit and can even run commands on the server (`COPY ... TO PROGRAM`). It violates the principle of least privilege (OWASP A01/A05) and LGPD art. 46.
4. **Fix Suggestion:** in `sql/b3_complement.sql`:

```sql
CREATE ROLE mufasa_api LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT;
REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC;
GRANT USAGE ON SCHEMA public TO mufasa_api;
GRANT SELECT ON students, courses, course_subjects, classes, enrollments, academic_indicators,
               socioeconomic, risk_assessments, professors TO mufasa_api;   -- read-only on B1
GRANT SELECT, INSERT ON access_audit TO mufasa_api;                         -- no UPDATE/DELETE
GRANT UPDATE (login_failures, blocked_until, last_login) ON users TO mufasa_api;
```

```env
DATABASE_URL=postgresql+psycopg://mufasa_api:CHANGE_HERE@localhost:5432/mufasa
```

#### 1.1-C Sensitive health and disability data in the main table

1. **Severity:** High
2. **Location:** `Samuel Part BackEnd B1.sql`, lines 40 and 41 (`requested_psychosocial_support`, `accessibility_need` in `students`)
3. **Flaw Description:** a request for psychosocial support and an accessibility need reveal health and disability, sensitive data under LGPD art. 5, II. They are in the same table as name and program, in plain text and without separation. Any query on `students` brings the sensitive data along, and there is no way to grant access to the record without granting access to health. The guide requires a "separate, encrypted table for health data (LGPD art. 11)". B3 already reads these columns in its own query, only for the support center, but the separation has to exist in the database.
4. **Fix Suggestion (for B1):**

```sql
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE support_sensitive_data (
    student_id                      VARCHAR(10) PRIMARY KEY REFERENCES students(student_id) ON DELETE CASCADE,
    requested_psychosocial_support  BYTEA,   -- pgp_sym_encrypt(value, key from the vault, not from SQL)
    accessibility_need              BYTEA,
    updated_at                      TIMESTAMPTZ NOT NULL DEFAULT now()
);
-- Migrate the values and then:
ALTER TABLE students DROP COLUMN requested_psychosocial_support, DROP COLUMN accessibility_need;
REVOKE ALL ON support_sensitive_data FROM PUBLIC;
```

The encryption key goes in the service's `.env`, never in the script. After the migration, change the `SUPPORT_SENSITIVE_DATA` query in `app/api/queries.py`.

### 1.2 Enable HTTPS Enforcement

#### 1.2-A No redirect to HTTPS and no HSTS

1. **Severity:** High (in production)
2. **Location:** `b3/README.md`, line 45 (`uvicorn app.main:app --reload`); `app/main.py` skeleton in the guide
3. **Flaw Description:** the API starts on plain HTTP, with no redirect and no `Strict-Transport-Security`. In production, the JWT token, the login password and student data travel readable to anyone on the same network (OWASP A02). RN18 requires TLS 1.2 or higher without serving plain HTTP.
4. **Fix Suggestion:** in `app/main.py` and `app/api/security.py`, turned on by `FORCE_HTTPS=true`:

```python
app.add_middleware(TrustedHostMiddleware, allowed_hosts=cfg.allowed_hosts)
if cfg.force_https:
    app.add_middleware(HTTPSRedirectMiddleware)
# in SecurityHeaders:
if self.hsts:
    answer.headers["Strict-Transport-Security"] = "max-age=31536000; includeSubDomains"
```

TLS itself terminates at the reverse proxy (Nginx, Caddy or the hosting's own), configured with `ssl_protocols TLSv1.2 TLSv1.3;`. Behind the proxy, run `uvicorn --proxy-headers --forwarded-allow-ips=<proxy ip>`.

---

## Priority 2: High Security Issues (This Week)

### 2.1 Implement Rate Limiting

#### 2.1-A No request limit and no login lockout

1. **Severity:** High
2. **Location:** B3 design (guide, page 10; `b3/README.md`, section 6); there was no `auth.py`
3. **Flaw Description:** without a limit, a script tries passwords nonstop (brute force) and sweeps student IDs in sequence. RN12 requires a lockout after 5 failures, and SRS Annex D.1 limits it to 120 requests per minute per user (OWASP A07).
4. **Fix Suggestion:** implemented in `app/api/security.py`, `app/api/auth.py` and `app/api/routes.py`:

```python
# 10 login attempts per minute per IP and per account
for key in (f"login-ip:{client_ip(request)}", f"login-account:{payload.login.lower()}"):
    allowed, wait = limiter.allow(key, cfg.login_limit_minute)
    if not allowed:
        raise http_error(429, "Too many login attempts. Wait and try again.", {"Retry-After": str(wait)})

# 5 failures lock the account for 15 minutes, in the database
UPDATE users SET login_failures = login_failures + 1,
       blocked_until = CASE WHEN login_failures + 1 >= :failures_max THEN :block_until ELSE blocked_until END
 WHERE user_id = :user_id
```

The failure message is the same for a nonexistent account, a wrong password and a locked account, and so is the response time (bcrypt against a dummy hash when the login does not exist). Tests: `test_block_after_five_failures`, `test_login_attempt_limit_per_ip`.

### 2.2 Add Session Cookie Encryption

**Does not apply as written:** the MUFASA API does not use a session cookie. The token goes in the `Authorization: Bearer` header, which also eliminates CSRF by design. The equivalent point is the security of the JWT token.

#### 2.2-A JWT with a vulnerable library and a predictable key

1. **Severity:** High
2. **Location:** `MUFASA_Backend_Build_Guide.pdf`, page 6 (`python-jose==3.3.0`, `passlib==1.7.4`); `b3/README.md`, line 177 (`JWT_SECRET=change-to-a-long-random-key`)
3. **Flaw Description:** `python-jose` 3.3.0 has published algorithm confusion (CVE-2024-33663) and compressed-token denial of service (CVE-2024-33664) flaws. `passlib` 1.7.4 is unmaintained and breaks with current versions of `bcrypt`. And the example key in `.env` is known text: if someone starts the system with it, anyone can forge a coordination or support center token.
4. **Fix Suggestion:** in `app/api/auth.py` and `app/config.py`, with PyJWT and bcrypt directly:

```python
def read_token(token: str) -> dict:
    cfg = get_configuration()
    return jwt.decode(
        token, cfg.jwt_secret.get_secret_value(),
        algorithms=[cfg.jwt_algorithm],          # fixed list: refuses "none" and algorithm switching
        audience=cfg.jwt_audience, issuer=cfg.jwt_issuer,
        options={"require": ["exp", "iat", "nbf", "sub", "jti", "iss", "aud"]},
    )

@field_validator("jwt_secret")
@classmethod
def _strong_key(cls, v: SecretStr) -> SecretStr:
    if len(v.get_secret_value().encode()) < 32:
        raise ValueError("JWT_SECRET needs at least 32 random bytes")
    return v
```

In addition: 30-minute validity, `jti` revocable at `POST /api/v1/auth/logout`, profile reread from the database on every request (a deactivated account loses access immediately) and passwords with bcrypt cost 12, limited to 72 bytes. Tests: `test_token_with_alg_none_is_refused`, `test_expired_token_is_refused`, `test_logout_revokes_the_token`.

### 2.3 Add Database Index for Stripe Customer ID

**Does not apply:** there is no Stripe. The equivalent is the lack of keys and indexes in the B1 database.

#### 2.3-A B1 tables without primary key, foreign key, constraint or index

1. **Severity:** Medium
2. **Location:** `Samuel Part BackEnd B1.sql`, lines 32 to 229 (the 11 `CREATE TABLE` statements)
3. **Flaw Description:** no table has a `PRIMARY KEY`, `FOREIGN KEY`, `NOT NULL`, `CHECK` or index; every text column is `varchar(255)`, and dates and "Yes/No" are stored as text. Consequences: duplicated students, enrollments pointing to nonexistent students, a grade of 150 accepted, queries by student reading the whole table, and no integrity guarantee on the data that feeds the score (LGPD, art. 6, V, data quality). The project's `dropout-database/schema.sql` already has the right model.
4. **Fix Suggestion (for B1):** recreate the database from `dropout-database/schema.sql` and only then load the data. For the current database, the minimum:

```sql
ALTER TABLE students    ADD PRIMARY KEY (student_id);
ALTER TABLE classes     ADD PRIMARY KEY (class_id);
ALTER TABLE enrollments ADD PRIMARY KEY (enrollment_id),
                        ADD FOREIGN KEY (student_id) REFERENCES students(student_id),
                        ADD FOREIGN KEY (class_id) REFERENCES classes(class_id);
ALTER TABLE risk_assessments ALTER COLUMN assessment_date TYPE DATE USING assessment_date::date;
ALTER TABLE students ALTER COLUMN accessibility_need TYPE BOOLEAN
      USING (accessibility_need = 'Yes');
```

The indexes the API uses are already in `sql/b3_complement.sql` (an index does not change data).

### 2.4 Minify JavaScript Bundle

**Does not apply:** the back end has no JavaScript. It is left for F1, if the dashboard is in React. The `docs/storage-notice.html` component does not depend on anything external.

### D-1 Dependencies with known vulnerabilities

1. **Severity:** High
2. **Location:** `MUFASA_Backend_Build_Guide.pdf`, pages 1 and 6 (`fastapi==0.110.0`, `python-jose==3.3.0`, `passlib==1.7.4`, `scikit-learn==1.4.0`)
3. **Flaw Description:** FastAPI 0.110.0 requires Starlette below 0.37, which has a denial of service in multipart form handling (CVE-2024-47874, fixed in Starlette 0.40.0). This directly affects the planned `POST /imports`, which receives a file. `python-jose` 3.3.0 is covered in item 2.2-A. `scikit-learn` 1.4.0 has CVE-2024-5206 (token leakage in `TfidfVectorizer`, fixed in 1.5.0), of low impact here (OWASP A06).
4. **Fix Suggestion:** this package's `requirements.txt`:

```text
fastapi>=0.115.6
starlette>=0.40.0
pydantic-settings>=2.6
SQLAlchemy>=2.0.36
psycopg[binary]>=3.2.3
PyJWT>=2.10.1
bcrypt>=4.2.0
# no python-jose and no passlib
```

After installing: `pip freeze > requirements.lock`, version the lock and run `pip-audit` on every dependency change.

---

## Priority 3: Critical Performance Issues (This Week)

### 3.1 Refactor `get_dates_with_content/1`

**Does not apply:** the function does not exist in this project.

### 3.2 Stop Refetching dates_with_content on Every Save

**Does not apply:** there is no journal or save flow of this kind.

### 3.3 Fix N+1 Queries in ReviewLive

**Does not apply:** there is no ReviewLive. The equivalent risk would be the student listing calculating the score student by student. B3 avoids this: `GET /api/v1/students` brings the level of the last stored assessment in a single query (`students_list_query` in `app/api/queries.py`), and B2's calculation only runs in a single student's detail.

#### 3.3-A Validation error returns the value sent, including the password

1. **Severity:** Medium
2. **Location:** FastAPI default behavior, which would be inherited by the guide's `app/main.py`
3. **Flaw Description:** when a field fails validation, FastAPI by default returns the `input` field with the value received. In a login with a badly formatted user name, the response repeats the password, which can end up in a proxy, browser or monitoring tool log (OWASP A04/A09; SRS, Section 3.3).
4. **Fix Suggestion:** in `app/api/errors.py`:

```python
@app.exception_handler(RequestValidationError)
async def _validation(request: Request, exc: RequestValidationError):
    fields = [{"field": ".".join(str(p) for p in e.get("loc", ()) if p != "body"),
               "message": VALIDATION_MESSAGES.get(e.get("type"), "Invalid value.")}
              for e in exc.errors()]
    return error_answer(request, 422, "One or more fields are invalid.", {"fields": fields})

@app.exception_handler(Exception)
async def _unexpected(request: Request, exc: Exception):
    log.exception("Unhandled error in request %s", _request_id(request))   # stack only in the log
    return error_answer(request, 500, "An unexpected error occurred. Give the request code to support.")
```

Tests: `test_validation_error_does_not_echo_the_password`, `test_error_500_does_not_expose_stack_or_sql`.

---

## Priority 4: Medium Issues (This Month)

### 4.1 Add Content Security Policy Headers

#### 4.1-A No CSP and other security headers

1. **Severity:** Medium
2. **Location:** `app/main.py` skeleton (guide and `b3/README.md`, section 10)
3. **Flaw Description:** without `Content-Security-Policy`, `X-Content-Type-Options`, `X-Frame-Options` and `Cache-Control: no-store`, a JSON response can be interpreted as HTML by the browser (XSS by *content sniffing*), the API can be embedded in another site's frame and personal data stays in the browser or proxy cache (OWASP A05).
4. **Fix Suggestion:** in `app/api/security.py`:

```python
CSP_API = "default-src 'none'; frame-ancestors 'none'; base-uri 'none'; form-action 'none'"
answer.headers["Content-Security-Policy"] = CSP_DOCS if is_docs else CSP_API
answer.headers["X-Content-Type-Options"] = "nosniff"
answer.headers["X-Frame-Options"] = "DENY"
answer.headers["Referrer-Policy"] = "no-referrer"
answer.headers["Cache-Control"] = "no-store"
```

Test: `test_health_and_security_headers`.

### 4.2 Remove Tailwind CDN from Production

**Does not apply:** there is no Tailwind. The equivalent is below.

#### 4.2-A `/docs` loads Swagger UI from an external CDN

1. **Severity:** Low
2. **Location:** FastAPI default behavior at `/docs`
3. **Flaw Description:** the `/docs` page downloads script and style from jsDelivr. In production, this exposes the full API documentation to any visitor and makes every user's browser contact a third party.
4. **Fix Suggestion:** in `app/main.py`, the documentation only exists outside production:

```python
docs = cfg.docs_enabled and not cfg.in_production
app = FastAPI(docs_url="/docs" if docs else None, redoc_url=None,
              openapi_url="/openapi.json" if docs else None)
```

### 4.3 Add Audit Logging

#### 4.3-A No access trail

1. **Severity:** Medium
2. **Location:** B1 (no audit table in the dump); B3 design (`audit.py` planned, not written)
3. **Flaw Description:** without a record, there is no way to know who saw a student's socioeconomic data, nor to prove that an improper attempt was blocked. LGPD requires a record of operations (art. 37), and the SRS requires an audit of every sensitive read (RN07, CA14) (OWASP A09).
4. **Fix Suggestion:** in `app/api/audit.py`, writing in its own transaction so that a denial does not erase its own record:

```python
def register(request, operation, result, *, user=None, target_student_id=None):
    with database.get_engine().begin() as connection:
        connection.execute(REGISTER_AUDIT, {
            "moment": datetime.now(timezone.utc), "request_id": request.state.request_id,
            "user_id": getattr(user, "user_id", None), "profile": getattr(user, "profile", None),
            "operation": operation, "resource": request.url.path[:200], "target_student_id": target_student_id,
            "result": result, "origin": client_ip(request)[:45]})
```

In the database, the table is insert-only: the `mufasa_api` role has no `UPDATE` or `DELETE`, and a trigger refuses changes (`sql/b3_complement.sql`). Passwords, tokens and personal data values do not go into the record.

### 4.4 Validate Project IDs in Preferences

**Does not apply literally:** there are no projects or preferences. The equivalent is the validation of the identifiers that reach the API and B2.

#### 4.4-A B2 accepts a "ready" risk injected into the input dictionary

1. **Severity:** Medium
2. **Location:** B2's `app/calculation/score.py`, lines 312 to 314 (`choose` / `student_data.get(f"risk_{factor_name}")`)
3. **Flaw Description:** if the input dictionary brings `risk_attendance`, `risk_grades` etc., the value replaces the calculation without any range check. If some future endpoint passes the request body on to B2 (in the chatbot or in a simulation, for example), the user chooses their own score: `{"risk_grades": -1000}` zeroes the result. Today B3 builds the dictionary only with database data, so there is no exploit in the current code.
4. **Fix Suggestion (for B2):**

```python
def choose(factor_name, derived_value):
    ready = student_data.get(f"risk_{factor_name}")
    if ready is None:
        return derived_value
    try:
        ready = float(ready)
    except (TypeError, ValueError):
        return derived_value
    if not math.isfinite(ready) or not 0.0 <= ready <= 100.0:
        raise ValueError(f"risk_{factor_name} outside 0 to 100")
    return ready
```

Rule for B3, already followed in `app/api/integration.py`: never pass B2 a dictionary coming from the user.

#### 4.4-B Student ID format differs between B1 and the SRS

1. **Severity:** Low
2. **Location:** `Samuel Part BackEnd B1.sql`, line 240 onward (`ALU0001`...); SRS v1.1, RN12 (7 digits)
3. **Flaw Description:** the SRS says to accept only 7 digits and refuse letters. The simulated database uses `ALU` + 4 digits. If B3 followed the SRS to the letter, no B1 student would be found; if it accepted any text, it would open room for malicious input.
4. **Fix Suggestion:** in `app/api/schemas.py`, a closed list with both formats until B1 migrates:

```python
ENROLLMENT_PATTERN = r"^(?:\d{7}|ALU\d{4})$"
Enrollment = Annotated[str, Path(pattern=ENROLLMENT_PATTERN)]
```

When B1 adopts the official student ID, remove `|ALU\d{4}`. Test: `test_malicious_or_malformed_enrollment_is_rejected`.

### 4.5 Safe Integer Parsing

#### 4.5-A B2 accepts NaN, infinity and out-of-range values

1. **Severity:** Medium
2. **Location:** B2's `app/calculation/score.py`, functions `risk_by_grade` (line 105), `risk_by_attendance`, `risk_by_work`, `risk_by_commute`, `risk_by_dependents`
3. **Flaw Description:** `float("nan")` fails every comparison and falls through to the last `return`, so `risk_by_grade(nan)` returns 100 (maximum risk) for corrupted data. Attendance of 150%, an average of 12 or negative hours also pass. With bad data from B1, the student gets a classification with no basis, which breaks RN08 and RN11.
4. **Fix Suggestion (for B2):**

```python
import math

def _valid(value, minimum, maximum):
    if value is None:
        return None
    try:
        number = float(value)
    except (TypeError, ValueError):
        return None
    return number if math.isfinite(number) and minimum <= number <= maximum else None

def risk_by_grade(average):
    average = _valid(average, 0.0, 10.0)
    if average is None:
        return None
    ...
```

B3 already applies this filter before calling B2 (`_number` in `app/api/integration.py`).

#### 4.5-B B2 breaks with a 500 error when `absences` arrives empty

1. **Severity:** Medium
2. **Location:** B2's `app/calculation/indicators.py`, line 27; call in `app/calculation/score.py`, lines 356 to 358
3. **Flaw Description:** `student_data.get("absences", 0)` returns `None` when the key exists with an empty value, and, when there are expected classes, `absences_limit - None` raises `TypeError`. For a student with expected classes and no absences recorded, the whole request answers 500. It contradicts the module's own rule ("missing data returns None").
4. **Fix Suggestion (for B2):**

```python
def calculate_remaining_absences(expected_classes, absences):
    if expected_classes is None or expected_classes <= 0 or absences is None:
        return None
    absences_limit = int(expected_classes * 0.25)
    return max(0, absences_limit - int(absences))
```

#### 4.5-C B2 reports "absence limit already reached" when the data does not exist

1. **Severity:** Medium
2. **Location:** B2's `app/calculation/indicators.py`, lines 24 and 25; `app/calculation/score.py`, lines 446 to 449
3. **Flaw Description:** without expected classes, `calculate_remaining_absences` returns `0`, and `explain_score` tells the student "The absence limit has already been reached". This is false information about the academic situation, delivered to someone who may drop out because of it. B1 has no expected classes today, so this would happen to every student.
4. **Fix Suggestion:** in B2, the fix from item 4.5-B (return `None`). B3 already works around it in `app/api/routes.py`:

```python
# With no expected classes in the database, B2's "0" would be read as the limit exceeded.
result["remaining_absences"] = None
```

#### 4.5-D B1 grades on a 0 to 100 scale; B2 expects 0 to 10

1. **Severity:** Medium
2. **Location:** `Samuel Part BackEnd B1.sql`, line 130 (`final_grade numeric`) and data from line 3339 (7,836 of 8,000 grades above 10, such as `74.67`)
3. **Flaw Description:** `enrollments.final_grade`, `exam1`, `exam2` and `exam3` go from 0 to 100, while `academic_indicators.current_average`, `courses.passing_average` (6) and B2 use 0 to 10. Whoever calculates the weighted average from `enrollments` will pass 74.67 to B2, which will read it as an excellent grade (risk 0). It is the same family as the scale inversion B2 fixed in v2.2. `dropout-database/schema.sql` limits the grade to `BETWEEN 0 AND 10`.
4. **Fix Suggestion (for B1):**

```sql
UPDATE enrollments SET final_grade = round(final_grade / 10, 1),
                       exam1 = round(exam1 / 10, 1), exam2 = round(exam2 / 10, 1), exam3 = round(exam3 / 10, 1);
ALTER TABLE enrollments ADD CHECK (final_grade BETWEEN 0 AND 10);
```

Until then, B3 uses only `academic_indicators.current_average` and discards any average outside 0 to 10.

#### 4.5-E Level `CRITICAL` (B2) and `Critical` (B1)

1. **Severity:** Low
2. **Location:** B2's `app/calculation/score.py`, line 50; `Samuel Part BackEnd B1.sql`, line 59 (data with `Critical`); `dropout-database/schema.sql` (`CHECK (risk_level IN ('Low','Moderate','High','Critical'))`)
3. **Flaw Description:** storing B2's output in the database violates the schema's `CHECK`, and comparing the two texts fails silently (a filter by `CRITICAL` finds no B1 student).
4. **Fix Suggestion:** a single conversion table in `app/api/integration.py`, used in every read and write:

```python
DATABASE_LEVEL = {"Low": "LOW", "Moderate": "MODERATE", "High": "HIGH", "Critical": "CRITICAL"}
LEVEL_FOR_DATABASE = {v: k for k, v in DATABASE_LEVEL.items()}
```

Better still: B1 adopting the SRS format (`CRITICAL`) in the `CHECK`.

---

## Priority 5: Long-Term Improvements

### 5.1 Implement ETS Cache Layer

**Does not apply:** ETS belongs to Erlang/Elixir. The equivalent point: B3's request limiter lives in a single process's memory. With more than one uvicorn worker, each one counts separately. For production, swap `WindowLimiter` for Redis (`INCR` with `EXPIRE`).

### 5.2 PostgreSQL Full-Text Search

**Does not apply today:** there is no search by name. If F1 asks for it, the search must stay parameterized and escape the `LIKE` wildcards:

```python
SEARCH_BY_NAME = text("""
    SELECT student_id, fictitious_name FROM students
     WHERE course_id = :course_id AND fictitious_name ILIKE :pattern ESCAPE '\\'
     LIMIT :limit
""")
term = term.replace("\\", "\\\\").replace("%", "\\%").replace("_", "\\_")
connection.execute(SEARCH_BY_NAME, {"course_id": user.course_id, "pattern": f"%{term}%", "limit": 25})
```

With a large volume, use the `pg_trgm` extension with a GIN index.

### 5.3 Paginating Journal Entries

#### 5.3-A Listings without pagination

1. **Severity:** Low
2. **Location:** B3 design (`b3/README.md`, section 4 plans it, but there was no code)
3. **Flaw Description:** a listing without a limit returns all 1,000 students at once: more exposure than necessary and a heavy, repeatable query (cheap denial of service).
4. **Fix Suggestion:** in `app/api/schemas.py`, a default limit of 25 and a maximum of 200, with a parameterized `LIMIT :limit OFFSET :offset`. Test: `test_malicious_filters_are_rejected` (`limit=1000` refused).

### 5.4 Move All Secrets to Environment Variables

#### 5.4-A Secrets and artifacts in the delivered material

1. **Severity:** Informational
2. **Location:** all of B1 and B2 (search for `password`, `senha`, `secret`, `token` and `api_key`); B2's `app/calculation/__pycache__/*.pyc` and `tests/__pycache__/*.pyc`
3. **Flaw Description:** no secret was found in the B1 or B2 code. The dump's `\restrict` is a security feature of `pg_dump` 16, not a password. Two concerns: (a) the `.pyc` files were sent, even though the CHANGELOG says the caches were removed, and they keep the full local path of the file on the author's machine, including the Windows user name; (b) the dump carries data for 1,000 students. The names are fictitious, but the same procedure with real data would violate the LGPD if it went to GitHub.
4. **Fix Suggestion:** configuration only through the environment, with no default for secrets, in `app/config.py`:

```python
class Configuration(BaseSettings):
    database_url: SecretStr      # required, no default value
    jwt_secret: SecretStr        # required, at least 32 bytes
```

And in the repository: `git rm -r --cached '**/__pycache__' .pytest_cache`, keep the `.gitignore` (which already covers `.env`, `*.dump` and `data/`) and never version a dump with data.

---

## LGPD: collecting only what is necessary

### L-1 Socioeconomic collection beyond what the calculation uses

1. **Severity:** Medium
2. **Location:** `Samuel Part BackEnd B1.sql`, lines 180 to 196 (`socioeconomic`) and 37 to 39 (`students`)
3. **Flaw Description:** from the socioeconomic table, B2's score uses only per capita income, work hours and commute time. The table also stores total family income, number of residents, study hours, family responsibility hours, distance in km, means of transport, ProUni, FIES and employee discount. In `students` there is the neighborhood and the type of high school, which RN21 forbids in the calculation. Keeping data without a defined purpose breaks necessity (art. 6, III) and increases the damage of a leak.
4. **Fix Suggestion:** B3 already selects only what is needed (`RESTRICTED_SOCIOECONOMIC` in `app/api/queries.py`) and does not show the neighborhood to any staff. For B1: for each column, record the purpose in the data inventory or remove it.

```sql
-- Example, if the group confirms there is no use:
ALTER TABLE socioeconomic DROP COLUMN employee_discount, DROP COLUMN distance_km;
```

### L-2 Students under 18 with no record of guardian consent

1. **Severity:** Medium
2. **Location:** `Samuel Part BackEnd B1.sql`, table `students` (163 students with `age` below 18)
3. **Flaw Description:** LGPD art. 14, §1 and RN16 require consent from one of the parents or the guardian for minors' health data. The database has nowhere to record this. In addition, only the age is stored: it changes without the database knowing, and before long the minor filter stops working.
4. **Fix Suggestion:** B3 refuses health consent given by the minor student themselves (`register_consent` in `app/api/routes.py`) and records each grant and revocation in `consents`, with `granted_by = 'GUARDIAN'` for the form delivered to the registrar's office. For B1: replace `age` with `birth_date DATE` (the SRS already plans it, Annex C) and calculate the age in the query.

---

## OWASP Top 10: what was checked and has no finding

| Category | Check | Result |
|---|---|---|
| A03 SQL injection | B1 is a dump with no dynamic SQL; B2 does not access the database; B3 only uses `text()` with named parameters | No finding. Tests with `' OR '1'='1`, `; DROP TABLE` and `1 OR 1=1` in the student ID, filters and login, plus an automated check that fails `text()` with an f-string, `+` or `%` |
| A03 XSS | The API only returns JSON, with `nosniff` and CSP `default-src 'none'` | No finding in the back end. F1 must not use `unsafe_allow_html=True` (Streamlit) or `dangerouslySetInnerHTML` (React) with text coming from the API |
| CSRF | The API does not use cookies | Does not apply. Keep the token in memory in the dashboard (see `COOKIE_POLICY.md`) |
| A02 Plain-text password or weak hash | B1 has no users table; B3 uses bcrypt cost 12 | No finding |
| A08 Insecure deserialization | No `pickle`, `eval` or `yaml.load` | No finding |
| A10 SSRF | No outbound request | Does not apply |

## How to validate

```bash
pip install -r requirements.txt
pytest tests/test_api.py -v     # B3's 38 tests
pip-audit -r requirements.txt   # dependencies
```
