# B3 — API and Security

MUFASA API module. Folders of this module in the `mufasa-backend` repository: **`app/api/`** and **`app/main.py`**. Nobody outside B3 changes these folders without a pull request reviewed by B3.

> Responsibility in the build guide: B3. In the build plan v1.1, the API layer corresponds to tasks T10, T11, T13 and T20 (Dérik Sousa Silva).

---

## 1. What B3 does

| Responsibility | Deliverable |
|---|---|
| Endpoints | REST routes that serve the dashboard (F1) and the chatbot (F2) |
| Authentication | JWT, profiles and role-based permissions |
| Isolation | Ensure RN17: a student never sees another student's data |
| Living documentation | FastAPI's `/docs` is the contract with F1 and F2 |
| Orchestration | Connects ingestion → calculation → persistence → answer |

**What B3 does not do:** calculation rules inside the endpoint. The endpoint **calls** B2's module (`app/calculation/`) and **reads** B1's database (`app/database/`). If a calculation, a weight or a threshold shows up inside `app/api/`, it is in the wrong place.

Flow between the layers:

```
B1 (database and data) → B2 (calculation) → B3 (API) → Interface (F1 dashboard, F2 chatbot)
```

---

## 2. How to run

Prerequisites: Python 3.12, PostgreSQL 16 and the virtual environment created (Steps 1 to 5 of the guide).

```bash
# 1. Activate the virtual environment
venv\Scripts\activate          # Windows
source venv/bin/activate       # Mac / Linux

# 2. Install dependencies
pip install -r requirements.txt

# 3. Create the .env file from the template (see section 8)
cp .env.example .env

# 4. Start the API
uvicorn app.main:app --reload
```

Check:

- http://127.0.0.1:8000/health → `{"status": "up", "system": "MUFASA"}`
- http://127.0.0.1:8000/docs → automatically generated documentation

Port 8000 busy? Close the old server with `Ctrl + C` or run with `--port 8001`.

---

## 3. Module structure

```
app/
├── main.py                 # creates the app, registers the routers and the error handler
└── api/
    ├── __init__.py
    ├── routes.py           # endpoints (starts with fake data)
    ├── auth.py             # login, JWT issuing and reading, password hash
    ├── permissions.py      # profiles and access checks (SRS Annex E)
    ├── schemas.py          # Pydantic input and output models (the contracts)
    ├── errors.py           # standardized error format
    └── audit.py            # record of sensitive data reads
tests/
└── test_api.py
```

---

## 4. API standards (SRS, Annex D.1)

- Base prefix: **`/api/v1`**
- JSON in UTF-8
- **Every endpoint requires JWT authentication**, except `/health` and `/auth/token`
- Pagination: default of 25 records, maximum of 200
- Request identifier in every response, to cross-reference with the audit
- Limit: 120 requests per minute per user; 20 per minute in the chat
- The student ID is always **text** with exactly 7 digits (`"0012345"`, never `12345`)
- Risk level always in uppercase: `LOW`, `MODERATE`, `HIGH`, `CRITICAL`, `UNDETERMINED`

### Standardized error

No error returns a stack trace, table name or SQL query.

```json
{
  "title": "Insufficient permission",
  "status": 403,
  "detail": "The TEACHER profile does not have access to this student's socioeconomic data.",
  "request": "3f9a-b21"
}
```

Access denied to another student **does not reveal whether the student exists** (RN07).

---

## 5. Endpoints

| Method | Endpoint | Profiles | Function | Sprint |
|---|---|---|---|---|
| GET | `/health` | Public | Availability check | 1 ✅ |
| POST | `/auth/token` | All | Authenticates and returns the token | 2 |
| GET | `/students` | Teacher, Coordination, Support center | List with filters | 2 |
| GET | `/students/{enrollment}` | Same | Profile, with fields hidden according to the profile | 2 |
| GET | `/students/{enrollment}/score` | Same + the student themselves | Score with factors and modifiers | 2 |
| GET | `/students/{enrollment}/history` | Same | Historical series (RN09) | 2 |
| GET | `/students/{enrollment}/recommendations` | Coordination, Support center | Recommendations with the source factor | 3 |
| POST | `/imports` | Administration | Sends a file and starts the load | 3 |
| GET | `/imports/{id}` | Administration | Load status and rejection report | 3 |
| POST | `/calculations` | Administration | Triggers a full or filtered recalculation | 3 |
| GET · PATCH | `/alerts`, `/alerts/{id}` | Coordination, Support center | Prioritized queue and status change | 3 |
| POST | `/alerts/{id}/actions` | Coordination, Support center | Records action, cause and outcome | 3 |
| POST | `/alerts/{id}/divergence` | Teacher, Coordination | Flags a wrong classification | 3 |
| GET · POST | `/appointments` | Student, Coordination, Support center | Queries and requests an appointment (RN14) | 4 |
| GET | `/indicators/aggregates` | Coordination, Board | Aggregates with suppression of groups < 5 | 4 |
| POST | `/chat/queries` | Authenticated | Natural language question | 4 |
| GET · PUT | `/parameters` | Administration | Versioned reading and change | 4 |
| GET | `/audit` | Data protection officer | Access trail | 4 |

The Sprint column is a suggested order; adjust it in the planning.

> **Mind the divergence:** the guide uses `/students/{enrollment}/risk` as an example; the SRS defines `/api/v1/students/{enrollment}/score`. This README follows the SRS. Tell F1 and F2 before changing it.

---

## 6. Profiles and permissions (SRS, Annex E)

Authorization is checked **on the server, in every endpoint**. Hiding a button on the screen is not access control.

| Profile | Reach | Restriction |
|---|---|---|
| `STUDENT` | Only their own profile | Never sees another student's data (RN17) |
| `TEACHER` | Students in their classes | Does not see income, work, housing or health; sees "factor referred to the support center" |
| `COORDINATION` | Students in their program | Vulnerability only as a qualitative range; does not see the nature of health data |
| `SUPPORT_CENTER` | Students with an assigned alert | The only one with socioeconomic values and the nature of health data |
| `FINANCE` | Students with a financial factor in the alert | Does not see health or detailed performance |
| `BOARD` | Aggregates only | Never sees name or student ID; groups < 5 suppressed |
| `ADMIN` | Configuration, loads, users | No reading of the data content |
| `DPO` | Audit trail | Does not see the data itself |

### Student login (RN12)

- The student ID is an **identifier, not a password**. Login requires a second element: password, code sent to the institutional email or the university's single sign-on.
- Lockout after **5 failed** attempts.
- The session expires after inactivity.
- An attempt to log in with another student's ID is blocked and recorded.

---

## 7. Security checklist (SRS, Section 4.1 and RN18)

- [ ] Passwords with **bcrypt cost ≥ 12** (or Argon2id). Never plain text, MD5 or SHA-1
- [ ] CPF never readable: only a hash with an institutional salt
- [ ] No secret in the repository: database password, JWT key and salt stay in the `.env`, which is in the `.gitignore`
- [ ] Only parameterized queries or SQLAlchemy. Building SQL by concatenating text is **forbidden**
- [ ] Every read of sensitive data and of an individual profile recorded in the audit (author, date, student, field, operation, origin)
- [ ] Errors without stack trace, table name or SQL
- [ ] In production: HTTPS with TLS 1.2+; plain HTTP is redirected
- [ ] Chatbot (RN06): no free SQL; only intents from a closed list with approved queries; read-only database user; scope applied on the server; row limit in every query
- [ ] During the sprints, **only simulated data**. Real data never goes to GitHub

---

## 8. Environment variables

`.env.example` file (this one does go to the repository, without real values):

```env
DATABASE_URL=postgresql://postgres:YOUR_PASSWORD@localhost:5432/mufasa
JWT_SECRET=change-to-a-long-random-key
JWT_ALGORITHM=HS256
JWT_EXPIRES_MINUTES=30
CPF_SALT=change-to-a-random-salt
```

To generate a key: `python -c "import secrets; print(secrets.token_hex(32))"`

---

## 9. Contracts

### Contract 2 — what B2 delivers to B3

Minimum format agreed in the guide:

```json
{
  "enrollment": "2024001",
  "score": 63,
  "level": "HIGH",
  "main_factors": ["attendance", "grades", "work"],
  "remaining_absences": 0,
  "recommendation": "contact within 5 working days"
}
```

The full format, to be frozen at the end of Sprint 2, is in the SRS (Annex A, item B.7): it includes the model and parameter versions, completeness, level origin (`RANGE` or `OVERLAP`), factors with value, weight, contribution and explanation in plain language, modifiers, history, trend and the methodological notice. **The API returns the explanation together with the score** (RN04), always.

### What B3 delivers to the Interface

The API URL and the `/docs` page. F1 and F2 find out what they can request through it, without having to ask. Every new endpoint is only ready when it shows up in `/docs` with a response example.

The full contracts are in `CONTRACTS.md` at the root of the repository.

---

## 10. B3 work order

1. **Skeleton** (Step 7 of the guide): `app/main.py` with `/health`. ✅
2. **Routes with fake data** in `app/api/routes.py`, so F1 and F2 can start today:

   ```python
   # app/api/routes.py
   from fastapi import APIRouter

   router = APIRouter(prefix="/api/v1")

   @router.get("/students/{enrollment}/score")
   def student_score(enrollment: str):
       # Fake data until B2's module is ready
       return {"enrollment": enrollment, "score": 63, "level": "HIGH"}
   ```

   ```python
   # app/main.py
   from fastapi import FastAPI
   from app.api.routes import router

   app = FastAPI(title="MUFASA", version="0.1.0")
   app.include_router(router)

   @app.get("/health")
   def check_health():
       return {"status": "up", "system": "MUFASA"}
   ```

   Later the content is swapped from the inside and nothing breaks on the Interface side.
3. **JWT authentication** with the profiles and the RN17 isolation.
4. **Swap the fake data** for the real calls to B2's module and B1's database.
5. Upload, alerts, appointments, chat and audit, in the order of the table in section 5.

Git flow: never code on `main`.

```bash
git checkout main
git pull
git checkout -b feat/score-endpoint
# ... work ...
git add .
git commit -m "Score endpoint with fake data"
git push -u origin feat/score-endpoint
```

Open a pull request and ask another member for a review.

---

## 11. Tests

```bash
pytest tests/test_api.py
```

Minimum tests B3 must have (linked to the SRS acceptance criteria):

| Test | Criterion |
|---|---|
| Student ID with 6 or 8 digits, letters or spaces is rejected | CA04 |
| Login with the student ID only, without a second factor, fails | CA04 |
| Student A asking for student B's score gets 403 and generates an audit record | CA14 |
| Teacher does not receive income, work, housing or health | RN07 |
| Board does not receive name or student ID; groups < 5 disappear | CA19 |
| Score answer always brings factors with a concrete number | CA08 |
| 500 error does not expose a stack trace or SQL | SRS Section 3.3 |
| Chatbot refuses a change request and "ignore your rules", and records it | CA15 |

Before the integration, also validate the endpoints in **Postman** (RF05).

---

## 12. Definition of done

An endpoint is only done when:

- it is on `main` through a pull request reviewed by another person;
- it shows up in `/docs` with an input and output example;
- it requires authentication and checks the profile on the server;
- it has an automated permission test;
- it has no secret in the code;
- F3 validated it against the acceptance criterion.

---

## 13. Pending items that affect B3

- [ ] Which second factor for the student: password, email code or the university's single sign-on?
- [ ] Dashboard in Streamlit or React (changes how F1 consumes the API and whether CORS is needed)
- [ ] Final field names (Contract 3): `enrollment` or `ra`; attendance `68.0` or `0.68`
- [ ] Risk route: `/risk` (guide) or `/score` (SRS)
- [ ] Versions in `requirements.txt`: `passlib` is unmaintained and usually gives a warning or error with new versions of `bcrypt`; consider using `bcrypt` directly (and `PyJWT` instead of `python-jose`) before writing `auth.py`

---

## 14. Common errors

| Symptom | Cause | Solution |
|---|---|---|
| `ModuleNotFoundError: fastapi` | Virtual environment not activated | Activate it and check the `(venv)` |
| `ImportError` between folders | Missing `__init__.py` | Create the empty file in the folder |
| Database connection error | PostgreSQL stopped or wrong password in the `.env` | Check the service and `DATABASE_URL` |
| `401` on everything | Missing or expired token | Get a new token at `/api/v1/auth/token` and send it in the `Authorization: Bearer ...` header |
| Works on your machine and not on your classmate's | Library missing from `requirements.txt` | Add it and tell the group |

---

References: *MUFASA — Backend Build Guide*; *SRS v1.1* (Sections 3.3, 4.1, RN06, RN07, RN12, RN17, RN18, Annexes D and E); *Build Plan v1.1* (T10, T11, T13, T20).
