# MUFASA — building the software, from the first step to version 1.1.0

This document tells, in order, how MUFASA was built: what was done in each stage, why, and where the result is in the code. For each member's part, see `02_MEMBER_PARTS.md`. To run the system, see `04_LOCAL_USE_AND_TESTS.md`.

## What MUFASA is

An early dropout warning system for the university. It reads each student's grades, attendance and socioeconomic context, calculates an explainable risk score (0 to 100), classifies it as Low, Moderate, High or Critical, opens alerts with a deadline for the team to act and records the follow-up until the outcome. Each profile (coordination, support center, teacher, finance, management, technical administration, data protection officer and the student) sees only what they need to see, according to the LGPD.

## Overview of the final architecture

```
            browser
                │  http://127.0.0.1:8501
        ┌───────▼─────────┐
        │ dashboard (F1)  │  Streamlit; does not access the database, only the API
        └──┬───────────┬──┘
           │           │
   ┌───────▼──┐   ┌────▼─────┐
   │ API :8000│   │ chat:8001│   FastAPI; JWT login, profiles, audit
   └───────┬──┘   └────┬─────┘
           │           │            calculation service (no port):
           │           │            recalculates scores and alerts from the queue
   ┌───────▼───────────▼─────────────▼──────┐
   │ PostgreSQL 16  (one user per service:  │
   │ mufasa_api, mufasa_chat,               │
   │ mufasa_calculation)                    │
   └────────────────────────────────────────┘
```

Each part is a separate process. If one goes down, only it stops and is restarted; the others keep going (the dashboard shows "unavailable" only in the affected section).

## Stage 0 — Reading the documents and plan (22/10/2026)

1. Reading of the back-end build guide (`MUFASA_Backend_Build_Guide.pdf`), SRS v1.1 and Build Plan v1.1.
2. Split into blocks: B1 data and database, B2 calculation and score, B3 API and security, F1 dashboard, F2 chatbot.
3. Writing of the B3 README with the SRS endpoints (`/api/v1/...`). Decision: `/score` route (as in the SRS) instead of `/risk` (as in the guide).
4. Normalization of the base of 1,000 simulated students into tables (`dropout-database/`): Artificial Intelligence course, 24 professors, 48 subjects, 96 classes, 6,000 enrollments and socioeconomic data in a separate table.

## Stage 1 — B3: API and security, by João Victor (27/10/2026)

1. FastAPI project with configuration read only from `.env`, with no default secret in the code (`app/config.py`). If `JWT_SECRET` or `DATABASE_URL` is missing, the API does not start.
2. Login with a bcrypt password and a 30-minute JWT token (`app/api/auth.py`), block after 5 failures (RN12), token revocation on logout.
3. Profiles from Annex E of the SRS and a scope check on every student query, so a user never reads a student outside their reach (`app/api/permissions.py`).
4. All SQL in query files, only with named parameters (`app/api/queries.py`); an automatic test fails any SQL built with variable text.
5. Audit trail that cannot be deleted or changed (`access_audit`), security headers, request and size limits.
6. B3 tables and database users with the least privilege (`sql/b3_complement.sql`).
7. LGPD documents: privacy policy, terms of use, cookies, health data consent, and the security, accessibility and content audits (`docs/`).

## Stage 2 — Integration of parts B1, B2 and F2 (28/10/2026)

1. **B1 database, by Samuel** (PostgreSQL dump). 2,000 orphan rows were removed from `enrollments`, leftovers from the import, with João's approval (`sql/b1_leftovers_cleanup.sql`; the clean dump is in `database/`).
2. **B1 corrections** (`sql/b1_corrections.sql`): grades converted from 0–100 to 0–10, primary and foreign keys, correct types.
3. **B2 calculation, by Susyanne**, copied to `app/calculation/`.
4. **F2 chatbot** rewritten inside the system, with the same login and the same profiles. It only reads its own views (`vw_chat_*`, `sql/chatbot.sql`) with the `mufasa_chat` database user. Answers use 24 closed intents. When there is AI (Groq, optional), it only writes the text with markers; the server fills in the real numbers afterwards and removes CPF, student ID, email and phone before sending any text outside.
5. Chatbot audit with the problems found and the fixes (`docs/CHATBOT_AUDIT.md`).

## Stage 3 — Metrics according to SRS v1.1 (28/10/2026)

1. SRS v1.1 and Plan v1.1 became the mandatory reference for the metrics.
2. The score was rewritten according to Annex A (code version 3.0): 11 indicators with the document's curves, modifiers M1 to M5, partial completeness between 40% and 70%, overlaps and factors with RN04 sentences.
3. All values from Annex C.2 went into the versioned `parameters` table (nothing fixed in the code).
4. Indicator average and attendance recalculated from the subjects, weighted by workload (`sql/b1_indicators_recalculation.sql`). The original B1 values stay in `b1_original_indicators`.
5. Full check in `docs/SRS_METRICS_REVIEW.md`.

## Stage 4 — Dashboard (F1) and modular system (28/10/2026)

1. Starting point: the Streamlit `app.py` from the F1 repository and the Figma prototype with 82 screens (login, LGPD terms, dashboards, alert queue, student record, teacher, student portal, administration and data protection officer).
2. Problems of the original `app.py` fixed: it read CSV directly (without login), the export leaked health data to Management, there were invented fixed numbers, and the "dropout rate" was just the sum of High and Critical.
3. Dashboard rewritten (`dashboard/`): it does not touch the database and only consumes the API. It has login with a profile selector, password change and terms acceptance on first access, and a hub per profile (`dashboard/screens/`).
4. Real-time charts: the sections refresh by themselves (every 15 or 30 seconds), always with the data from the database.
5. API extended for the dashboard: alerts and actions (`alert_routes.py`), aggregated dashboards with suppression of groups smaller than 5 (`dashboard_routes.py`), student portal (`student_routes.py`), administration (`admin_routes.py`), account and notifications (`account_routes.py`), data loads with prior validation (`load_validation.py`) and parameters with proposal and approval.
6. **Separate calculation service** (`app/calculation_service/`): triggers in the database put the student in a queue when a piece of data changes, and the service recalculates score and alerts without locking the API (`sql/dashboard.sql`).
7. **Failure isolation:**
   - each service writes a heartbeat to `service_status`;
   - `/health` answers 503 when the database goes down;
   - the dashboard has a circuit breaker (it stops insisting on a service that is down);
   - each section of the screen is isolated (`ui.section`), so an error in one part does not bring the screen down.
8. **Accounts:** one login for each of the 1,000 students, with a password change on first access, and one demo account per profile (`scripts/generate_accounts.py`, `database/initial_accounts.sql`).
9. Psychosocial support and accessibility data encrypted in the database with a Fernet key (`app/api/cipher.py`, `scripts/migrate_support.py`).

## Stage 5 — Colors, evolution tools and local delivery (28/10/2026)

1. **Colors requested by João:** Critical in `#9A4A1E` (brick red) and High in `#523E1D` (brown), in the badges and in all charts (`dashboard/ui.py`). The badges also carry an icon and text, for people who cannot tell colors apart.
2. **Logs** in `logs/<service>.log`, with rotation, and a support code in every error shown on the screen (`app/log_record.py`, `dashboard/dashboard_logging.py`).
3. **Diagnostics:** `python -m scripts.diagnostics` checks everything and finds an error by the code on the screen.
4. **Versioned migrations** (`sql/migrations/`, `scripts/migrate.py`) and system version number (`app/__init__.py`, now 1.1.0).
5. **Simple installation:**
   - `scripts/configure.py` generates the `.env` with new passwords;
   - `scripts/build_database.py` builds the whole database without needing `psql`;
   - `scripts/start.py` starts everything and restarts whatever goes down;
   - it also runs via Docker (`docker-compose.yml`).
6. **Tests:** 201 automatic tests running on a separate test PostgreSQL database (`mufasa_test`), plus a browser test with all profiles.
7. Final documentation: this document and the ones numbered 02 to 05.

## How the stages connect in the code

| Stage | Main folders and files |
|---|---|
| Database (B1 + corrections) | `database/`, `sql/b1_*.sql`, `sql/dashboard.sql` |
| Calculation (B2 → SRS 3.0) | `app/calculation/`, `app/calculation_service/` |
| API and security (B3) | `app/api/`, `app/factory.py`, `app/main.py`, `sql/b3_complement.sql` |
| Chatbot (F2) | `app/chatbot/`, `app/main_chat.py`, `sql/chatbot.sql` |
| Dashboard (F1) | `dashboard/` |
| Operation and evolution | `scripts/`, `sql/migrations/`, `docker-compose.yml`, `Dockerfile` |
| Tests | `tests/` |
