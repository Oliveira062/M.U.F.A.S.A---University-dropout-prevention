# MUFASA — early dropout warning system (version 1.1.0)

MUFASA brings together:

- the B1 database, corrected;
- the score calculated according to SRS v1.1 (Annex A);
- the B3 API and security;
- the F2 chatbot;
- the F1 dashboard in Streamlit, with a hub per profile.

Each part runs in a separate process. If one goes down, the others keep going.

## Start in 5 commands (direct installation)

First, install Python 3.13 and PostgreSQL 16.

```bash
python -m venv venv && venv\Scripts\activate        # Linux/macOS: source venv/bin/activate
pip install -r requirements.lock
python -m scripts.configure                          # creates the .env with new passwords
python -m scripts.build_database                     # builds the database with the 1,000 students and the accounts
python -m scripts.start                              # starts API, chat, calculation and dashboard
```

Open **http://127.0.0.1:8501**. The logins are in `database/initial_credentials.csv`. The file is sensitive: do not share it.

**With Docker:**

```bash
python -m scripts.configure --docker
docker compose up -d --build
```

## Starting and stopping day to day

With Docker installed, double-click `START_MUFASA.bat` to start it (it opens the dashboard in the browser) and `STOP_MUFASA.bat` to stop it. The data is kept. On macOS or Linux use `./start_mufasa.sh` and `./stop_mufasa.sh`. Details in `docs/06_LOCAL_DOCKER_USE.md`, step 8.

## Check

```bash
python -m scripts.diagnostics      # with the system running: it must show "0 failure(s)"
pytest                             # 201 tests in a separate test database
```

## Documentation

| Document | Content |
|---|---|
| [01 — Step-by-step build](docs/01_STEP_BY_STEP_BUILD.md) | From the first step to version 1.1.0 |
| [02 — Member parts](docs/02_MEMBER_PARTS.md) | What each member did, what they used and how they built it |
| [03 — Tools and versions](docs/03_TOOLS_AND_VERSIONS.md) | Programs, packages, versions and ports |
| [04 — Local use and tests](docs/04_LOCAL_USE_AND_TESTS.md) | Installation, logins, tests, common problems and backup |
| [06 — Local use with Docker](docs/06_LOCAL_DOCKER_USE.md) | Step by step with Docker only, from zero to the first login |
| [05 — Evolution and diagnostics](docs/05_EVOLUTION_AND_DIAGNOSTICS.md) | How to find errors by the code on the screen; logs, migrations and versions |
| [Metrics review](docs/SRS_METRICS_REVIEW.md) | Parameters and formulas compared to SRS v1.1 |
| [CHANGELOG](CHANGELOG.md) | What changed in each version |
| `docs/SECURITY_AUDIT.md`, `CHATBOT_AUDIT.md`, `ACCESSIBILITY_AUDIT.md` | Security, chatbot and accessibility audits |
| `docs/PRIVACY_POLICY.md`, `TERMS_OF_USE.md`, `COOKIE_POLICY.md`, `HEALTH_DATA_CONSENT.md` | Drafts of the LGPD documents |
| `docs/CONTENT_REVIEW.md` | Review of the texts |

## Structure

```
app/
  api/                  REST API /api/v1: login, profiles, alerts, dashboards, student, admin, LGPD
  calculation/          indicators and score (SRS Annex A, code 3.0)
  calculation_service/  service that recalculates scores and alerts from the queue
  chatbot/              assistant (closed intents; optional AI only for the tone)
  log_record.py         logs in logs/ with a request code
  main.py               API (port 8000)
  main_chat.py          chat (port 8001)
dashboard/              Streamlit interface (port 8501), hub per profile
scripts/                configure, build_database, start, diagnostics, migrate, accounts
sql/                    B1 corrections, B3 complement, dashboard, chatbot, migrations/
database/               clean B1 dump, initial accounts and initial credentials
tests/                  201 tests (pytest) on a test PostgreSQL
docs/                   documentation
```

The full list of API routes is at http://127.0.0.1:8000/docs, with the system running and outside production.

## Decisions that apply to the whole system

- **Score route:** `/score`, as in the SRS. The guide used `/risk`.
- **Student login:** student ID and password, with bcrypt cost 12 and a password change on first access. Switching later to an email code or single sign-on does not change the routes.
- **Student ID:** accepts 7 digits (SRS) or the `ALU0000` format of the simulated B1 database.
- **Grades:** scale from 0 to 10 in the whole system. The original B1 grades from 0 to 100 stay in `b1_original_grades`.
- **No data, no number:** when the base does not have the data (LMS, remaining absences, effectiveness), the screen shows "no data".
- **Chatbot:** the question is classified by rules, and the AI never chooses the query or the scope (RN06). Groq, optional, only receives a draft with markers, without name, student ID, grade or attendance. An answer with an invented number is discarded.
- **Student:** sees their own status, never the score number on the screen (RN17).

## Known pending items

Details in section 6 of `docs/SRS_METRICS_REVIEW.md` and in section 4 of `docs/02_MEMBER_PARTS.md`. The main ones:

- export to XLSX and PDF;
- email notification;
- automatic backup;
- "My level" screen;
- confirm the 2026 minimum wage;
- fill in the legal bases in brackets in the privacy policy;
- **revoke the Groq key that came in the shared file.**
