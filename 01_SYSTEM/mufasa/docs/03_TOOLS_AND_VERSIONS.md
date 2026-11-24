# MUFASA — tools and versions

Versions with which the system was built and tested on 28/10/2026. The exact versions of the Python packages are in `requirements.lock`. The minimum accepted ones are in `requirements.txt`, which is used for updating.

## 1. Programs that must be on the machine

| Tool | Tested version | Minimum | What it is for |
|---|---|---|---|
| Python | 3.13.17 | 3.11 (tested only on 3.13; use 3.13) | Language of the whole system: API, chat, calculation, dashboard and scripts |
| PostgreSQL | 16.15 | 16 | Database. The B1 dump was generated on version 16 |
| pip | the one that comes with Python | — | Installs the packages |
| Browser | current Chrome, Edge or Firefox | — | Opens the dashboard at `http://127.0.0.1:8501` |

**Optional:**

| Tool | Tested version | What it is for |
|---|---|---|
| Docker Engine / Docker Desktop | 29.9.2 | Run everything in containers, without installing Python or PostgreSQL |
| Docker Compose | v5.6.1 (`docker compose` plugin) | Starts the 6 containers together |
| `postgres:16` image | 16 | Database inside Docker |
| `python:3.13-slim` image | 3.13 | Base of the `mufasa:1.1.0` image |
| Git | any | Version control of the code |
| Node.js + Playwright | 22.22.0 + 1.63.0 | Only to repeat the browser test. Not needed to use the system |
| pgAdmin or DBeaver | any | Look at the database with a graphical interface |

## 2. Python packages (`requirements.lock`)

| Package | Version | Where it is used | What it is for |
|---|---|---|---|
| fastapi | 0.162.0 | API and chat | Framework for the routes, validation and documentation at `/docs` |
| starlette | 1.7.0 | API and chat | Base of FastAPI (version 0.40 or newer fixes CVE-2024-47874) |
| uvicorn[standard] | 0.54.0 | API and chat | HTTP server that runs FastAPI |
| pydantic | 2.13.5 | API, chat and calculation | Input and output contracts, validation |
| pydantic-settings | 2.16.1 | Configuration | Reads the `.env` |
| python-multipart | 0.0.32 | API | Receives the upload of the data loads |
| SQLAlchemy | 2.1.6 | API, chat and calculation | Connection and SQL with named parameters (`text()`) |
| psycopg[binary] | 3.2.10 | All of them and the scripts | PostgreSQL driver; also builds the database without `psql` |
| PyJWT | 2.15.0 | API and chat | Login token (HS256) |
| bcrypt | 5.0.0 | API | Password hash (cost 12) |
| cryptography | 50.0.1 | API and scripts | Fernet encryption of the support data (LGPD art. 11) |
| httpx | 0.28.1 | Dashboard and chat | HTTP client from the dashboard to the API; optional call to Groq |
| streamlit | 1.50.0 | Dashboard | Web interface |
| plotly | 6.3.1 | Dashboard | Charts |
| pandas | 2.3.3 | Dashboard | Tables and CSV export |
| pytest | 9.2.0 | Tests | Runs the 201 tests |
| pip-audit | 2.7 or newer | Maintenance | Looks for known flaws in the packages |

Dependencies that come along, in the tested versions: numpy 2.5.3, pyarrow 26.0.0, altair 5.5.0, tornado 6.6, anyio 4.15.1, click 8.5.0, Jinja2 3.1.6, requests 2.34.2, protobuf 6.33.6 and pillow 11.3.0.

Visual resources of the dashboard, which come with the project (no download at the time of use):

| Resource | Version | Where | What for |
|---|---|---|---|
| Inter font | 4.0, Latin subset in WOFF2, converted to TrueType with hinting (ttfautohint) to look sharp on Windows (OFL 1.1 license) | `dashboard/static/fonts/` | Figma font on every screen |
| Lucide icons | exported from the Figma file | `dashboard/icons.json` | Icons of the menu, badges, cards and buttons |
| MUFASA logo | from the Figma file | `dashboard/static/logo.png` | Side menu, login and tab icon |

## 3. External service (optional)

| Service | Model | Use |
|---|---|---|
| Groq | `openai/gpt-oss-20b` | Writes the chat answers more naturally. Without the `GROQ_API_KEY` key, the chat uses ready answers and nothing leaves the machine. With the key, it talks more freely and receives the anonymized question. The text sent carries no name, CPF, student ID, email, phone or numbers, and questions about health do not leave the server |

## 4. Components of the system itself

| Component | Version | Where to see it |
|---|---|---|
| MUFASA system | 1.1.0 | `app/__init__.py`, at `/health` and on the Admin services screen |
| Score model | `deterministic-v1.1`, code 3.0 | `app/calculation/score.py`; each score keeps the version |
| Parameters | version 1 (goes up with each approved change) | Administration → Parameters; `parameter_versions` table |
| Database migrations | 002 | `sql/migrations/`, `python -m scripts.migrate --list-items` |
| Health data consent form | 1.0 | `docs/HEALTH_DATA_CONSENT.md` |

## 5. Ports used

| Port | Service | Access |
|---|---|---|
| 5432 | PostgreSQL | local machine only |
| 8000 | API (`/api/v1`, `/health`, `/docs`) | `127.0.0.1` |
| 8001 | Chat | `127.0.0.1` |
| 8501 | Dashboard | `127.0.0.1`. This is the address opened in the browser |

The services listen only on `127.0.0.1`, so other computers on the network cannot access them. To open them on the network, see `04_LOCAL_USE_AND_TESTS.md`, section 8.

## 6. How to update versions safely

1. Run `pip-audit -r requirements.txt` to see if any package has a known flaw.
2. In a separate environment, run `pip install -U -r requirements.txt`.
3. Run `pytest` (it must show 201 passed) and `python -m scripts.diagnostics`.
4. If everything passes, save the new versions: `pip freeze > requirements.lock`, or edit only the packages that changed.
5. Record the change in `CHANGELOG.md` and bump the version in `app/__init__.py`.
