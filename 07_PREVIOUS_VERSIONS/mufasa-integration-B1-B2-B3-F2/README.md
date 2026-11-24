# MUFASA — Integrated system (B1 + B2 + B3 + F2)

API of the early dropout warning system. This package brings together B2's calculation module (unchanged), B1's database (read, not changed), the B3 API and security layer and the F2 chatbot, rewritten to work inside the API.

The dashboard (F1) has not been delivered yet. It will consume this same API; the requirements are in `docs/CHATBOT_AUDIT.md`, section F1. The originals of each part are in `../originals/`, unchanged.

## How to run

```bash
python -m venv venv && source venv/bin/activate      # Windows: venv\Scripts\activate
pip install -r requirements.txt

# Database: B1 dump and then the B3 complement, as the database owner
psql -d mufasa -f "../database/Samuel Part BackEnd B1 - clean.sql"   # B1 dump without the import leftovers
psql -d mufasa -f sql/b3_complement.sql
psql -d mufasa -f sql/chatbot.sql
psql -d mufasa -c "ALTER ROLE mufasa_api PASSWORD 'choose-a-strong-password'"
psql -d mufasa -c "ALTER ROLE mufasa_chat PASSWORD 'another-strong-password'"

cp .env.example .env        # fill in JWT_SECRET, DATABASE_URL, CHAT_DATABASE_URL and MINIMUM_WAGE
                            # GROQ_API_KEY is optional: without it the chat uses the ready-made texts
DATABASE_URL_ADMIN=postgresql+psycopg://postgres:...@localhost/mufasa \
  python -m scripts.create_user --login ALU0001 --profile STUDENT --student ALU0001

uvicorn app.main:app --reload
```

Tests (they need neither PostgreSQL nor internet): `pytest -v` → 79 tests (38 for the API and 41 for the chatbot).

## Structure

```
app/
├── main.py              creates the app; HTTPS, allowed hosts, CORS, headers
├── config.py            configuration only through environment variables; no default secret
├── calculation/         B2 module v2.2, copied unchanged
├── chatbot/             F2, inside the API (same login, profiles and scope)
│   ├── chat_routes.py   /api/v1/chat/opening, /queries, /history, /close
│   ├── intents.py       closed catalog of 24 intents and rule-based classification
│   ├── service.py       runs the intent with the user's scope; builds data and draft
│   ├── redaction.py     text humanized by the AI with markers, no personal data; check
│   ├── ai.py            Groq HTTP client (optional)
│   ├── conversation.py  closing on inactivity (RN13) and history
│   ├── chat_queries.py  ALL the chatbot SQL, only on the vw_chat_* views
│   ├── text.py          normalization, removal of CPF/email/phone/student ID
│   ├── chat_database.py connection with the mufasa_chat role
│   ├── config_chat.py   configuration through environment variables
│   └── chat_schemas.py  input and output contracts
└── api/
    ├── routes.py        endpoints
    ├── auth.py          bcrypt, JWT, current user, require_profiles
    ├── permissions.py   Annex E profiles, per-student scope (anti-IDOR), hiding of factors
    ├── queries.py       ALL the SQL, only with named parameters
    ├── integration.py   B1 → B2 bridge (unit conversion and discarding impossible values)
    ├── schemas.py       Pydantic input and output contracts
    ├── errors.py        standardized error, no stack or SQL
    ├── audit.py         access trail in its own transaction
    ├── security.py      headers, request limit and size limit
    └── database.py      connection (mufasa_api user)
sql/b3_complement.sql    B3 tables, database roles, immutable audit
sql/chatbot.sql          chatbot views, history and mufasa_chat permissions
sql/b1_leftovers_cleanup.sql removes the 2,000 import leftovers for whoever already loaded the original dump
scripts/create_user.py   creates a user with a password typed without echo
tests/test_api.py        38 API tests
tests/test_chatbot.py    41 chatbot tests
docs/                    LGPD policies, storage notice, audits
```

## Endpoints

| Method | Route | Profiles |
|---|---|---|
| GET | `/health` | Public |
| POST | `/api/v1/auth/token` | Public (student ID or login + password) |
| POST | `/api/v1/auth/logout` | Authenticated |
| GET | `/api/v1/students` | Teacher, Coordination, Support center |
| GET | `/api/v1/students/{enrollment}` | Student (only their own), Teacher, Coordination, Support center, Finance, with fields according to the profile |
| GET | `/api/v1/students/{enrollment}/score` | Student (only their own), Teacher, Coordination, Support center |
| GET | `/api/v1/students/{enrollment}/history` | Same |
| GET | `/api/v1/indicators/aggregates` | Coordination (of the program), Board; groups < 5 suppressed |
| GET | `/api/v1/privacy/my-data` | Student |
| GET · POST | `/api/v1/privacy/consents` | Student |
| POST | `/api/v1/privacy/requests` | Student (art. 18 rights and art. 20 review) |
| GET | `/api/v1/privacy/requests` | Data protection officer |
| GET | `/api/v1/audit` | Data protection officer |
| GET | `/api/v1/chat/opening` | Authenticated (opening message and human support hours) |
| POST | `/api/v1/chat/queries` | Authenticated; the data respects each profile's scope |
| GET | `/api/v1/chat/history` | Authenticated (only their own history) |
| POST | `/api/v1/chat/close` | Authenticated |

The score route follows the SRS (`/score`), not the guide's `/risk` example.

## Decisions made in this package

- **Student's second factor:** student ID + password with bcrypt cost 12. It is the simplest mechanism provided for in RN12. Switching later to an email code or single sign-on does not change the routes.
- **Student ID:** accepts 7 digits (SRS) or `ALU0000` (B1 simulated database). Remove the second format when B1 migrates.
- **Support center and finance:** while the alerts module does not exist, "student with an alert" = student of the same program whose last assessment is High or Critical.
- **Factors missing in B1:** health, housing, dependents, VLE, failure rate and expected classes do not exist in the database. They stay missing (B2 excludes them from the calculation) and the answer lists which ones in `missing_data`.
- **Work hours:** `daily_work_hours × 5`. Confirm with B1.

## Documents

| File | Content |
|---|---|
| `docs/SECURITY_AUDIT.md` | Audit of B1, B2 and B3 (OWASP Top 10, authentication, validation, secrets, dependencies, LGPD) |
| `docs/CHATBOT_AUDIT.md` | Audit of F2 and of the integration (OWASP Top 10, OWASP LLM Top 10, LGPD, cookies, accessibility, content) and F1 dashboard requirements |
| `docs/ACCESSIBILITY_AUDIT.md` | WCAG 2.1 AA in the API texts and in the notice; checklist for F1 and F2 |
| `docs/CONTENT_REVIEW.md` | Fake reviews and unsupported claims |
| `docs/PRIVACY_POLICY.md` | Draft privacy policy |
| `docs/TERMS_OF_USE.md` | Draft terms of use |
| `docs/COOKIE_POLICY.md` | Cookie policy and guidance for F1 |
| `docs/HEALTH_DATA_CONSENT.md` | Text and flow of the health consent |
| `docs/storage-notice.html` | Accessible storage notice component |

## Chatbot decisions

- **Closed intents:** the question is classified by rules; the AI never picks the query or the scope (RN06).
- **AI only for the tone:** Groq receives a draft with markers (`[[LEVEL]]`) and signals without identification. It does not receive name, student ID, grade, attendance or the typed question. An answer with a made-up number or a missing marker is discarded.
- **Nothing made up:** without data in the database, the answer says there is no data. Grades show exactly as they are in B1, including zeros, with the scale (0 to 100 in the subjects, 0 to 10 in the overall average).
- **AI classification turned off** (`CHAT_AI_CLASSIFY=false`): it is the only case in which the typed (redacted) text would leave the server.

## Pending items

- [ ] B1: apply the audit suggestions 1.1-C, 2.3-A, 4.5-D, L-1 and L-2
- [ ] B2: apply 4.4-A, 4.5-A, 4.5-B, 4.5-C, A-1 to A-3 and C-1 to C-6
- [ ] B3: `POST /auth/renew` (session notice, WCAG 2.2.1), Redis limiter for production, routes from Sprint 3 on (imports, alerts, appointments)
- [ ] Data protection officer: define the legal bases marked in brackets in the privacy policy
- [ ] Confirm the current minimum wage value for `MINIMUM_WAGE`
- [ ] **Eduardo: revoke the Groq key that was in the `.env` (C-0) and generate a new one for the project**
- [x] Import leftovers: the 2,000 enrollments without a student were removed (approved by João on 28/10/2026)
- [ ] Samuel and João: decide on the indicators that do not follow the enrollments and on the B1 level cutoffs (C-B1)
- [ ] Data protection officer: AI provider and chat history retention period in the privacy policy
- [ ] Institution: fill in `CHAT_SERVICE_WINDOW` with the real human support hours
- [ ] F1: deliver the dashboard and go through the P-1 to P-12 list in `docs/CHATBOT_AUDIT.md`
