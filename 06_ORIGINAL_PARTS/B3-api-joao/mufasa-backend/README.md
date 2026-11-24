# MUFASA — Integrated back end (B1 + B2 + B3)

API of the early dropout warning system. This package brings together B2's calculation module (unchanged), B1's database (read, not changed) and the B3 API and security layer.

## How to run

```bash
python -m venv venv && source venv/bin/activate      # Windows: venv\Scripts\activate
pip install -r requirements.txt

# Database: B1 dump and then the B3 complement, as the database owner
psql -d mufasa -f "Samuel Part BackEnd B1.sql"
psql -d mufasa -f sql/b3_complement.sql
psql -d mufasa -c "ALTER ROLE mufasa_api PASSWORD 'choose-a-strong-password'"

cp .env.example .env        # fill in JWT_SECRET, DATABASE_URL and MINIMUM_WAGE
DATABASE_URL_ADMIN=postgresql+psycopg://postgres:...@localhost/mufasa \
  python -m scripts.create_user --login ALU0001 --profile STUDENT --student ALU0001

uvicorn app.main:app --reload
```

Tests (they do not need PostgreSQL): `pytest tests/test_api.py -v` → 38 tests.

## Structure

```
app/
├── main.py              creates the app; HTTPS, allowed hosts, CORS, headers
├── config.py            configuration only through environment variables; no default secret
├── calculation/         B2 module v2.2, copied unchanged
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
scripts/create_user.py   creates a user with a password typed without echo
tests/test_api.py        38 tests
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
| `docs/ACCESSIBILITY_AUDIT.md` | WCAG 2.1 AA in the API texts and in the notice; checklist for F1 and F2 |
| `docs/CONTENT_REVIEW.md` | Fake reviews and unsupported claims |
| `docs/PRIVACY_POLICY.md` | Draft privacy policy |
| `docs/TERMS_OF_USE.md` | Draft terms of use |
| `docs/COOKIE_POLICY.md` | Cookie policy and guidance for F1 |
| `docs/HEALTH_DATA_CONSENT.md` | Text and flow of the health consent |
| `docs/storage-notice.html` | Accessible storage notice component |

## Pending items

- [ ] B1: apply the audit suggestions 1.1-C, 2.3-A, 4.5-D, L-1 and L-2
- [ ] B2: apply 4.4-A, 4.5-A, 4.5-B, 4.5-C, A-1 to A-3 and C-1 to C-6
- [ ] B3: `POST /auth/renew` (session notice, WCAG 2.2.1), Redis limiter for production, routes from Sprint 3 on (imports, alerts, appointments, chat)
- [ ] Data protection officer: define the legal bases marked in brackets in the privacy policy
- [ ] Confirm the current minimum wage value for `MINIMUM_WAGE`
