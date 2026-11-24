# MUFASA — how to run it locally and test it

There are two paths. Choose one:

- **Path A: direct installation.** Python and PostgreSQL installed on the machine. Good for development and for running the tests.
- **Path B: Docker.** Only Docker Desktop installed. Good for just using the system.

The commands work on Windows (PowerShell), Linux and macOS. When there is a difference, Windows is marked. Run everything **inside the `mufasa/` folder**.

---

## 1. What to install

### Path A

1. **Python 3.13** (python.org). On Windows, check "Add python.exe to PATH" during installation.
2. **PostgreSQL 16** (postgresql.org/download). Write down the password of the `postgres` user set during installation; it will be asked once. The default port is 5432.
3. Check in the terminal:
   ```
   python --version      # Python 3.13.x  (on Linux/macOS it may be python3)
   ```

`psql` is not needed, because the database is built by Python itself.

### Path B

1. **Docker Desktop** (Windows/macOS) or Docker Engine with the Compose plugin (Linux).
2. Python 3, only to generate the `.env` (step 2 below). If you do not want to install Python, copy `.env.example` to `.env` and fill it in by hand.

---

## 2. Path A: direct installation, step by step

```bash
# 1. Virtual environment and packages (once)
python -m venv venv
venv\Scripts\activate            # Windows
source venv/bin/activate         # Linux/macOS
pip install -r requirements.lock

# 2. Configuration: creates the .env with new passwords and keys (once)
python -m scripts.configure
#    it asks: PostgreSQL address [localhost], port [5432] and the postgres password

# 3. Database: creates the "mufasa" database, loads B1, applies the corrections, creates the accounts
python -m scripts.build_database
#    it asks for confirmation because it ERASES and recreates the "mufasa" database. It takes about 1 minute.

# 4. Start the system (leave this terminal open)
python -m scripts.start

# 5. Open in the browser
#    http://127.0.0.1:8501
```

To stop: `Ctrl+C` in the terminal of step 4. To start it again another day, just activate the virtual environment and run step 4.

**`start` options:**

| Command | What it does |
|---|---|
| `python -m scripts.start` | Starts API, chat, calculation and dashboard |
| `python -m scripts.start --without-chat` | Starts everything except the assistant |
| `python -m scripts.start --only api,dashboard` | Starts only the chosen parts |

If a part goes down, `start` brings it back up by itself (it waits 2 s, then 4 s, up to 60 s) and the others keep working.

---

## 3. Path B: Docker, step by step

The full guide, with Docker Desktop installation, backup and update, is in `docs/06_LOCAL_DOCKER_USE.md`. Below is only the summary.

```bash
python -m scripts.configure --docker      # once: creates the .env for the containers
docker compose up -d --build              # starts everything; the 1st time it builds the database (a few minutes)
docker compose ps                         # all must become "healthy"; "build_database" ends as "exited (0)"
#  open http://127.0.0.1:8501
```

| Command | What it does |
|---|---|
| `docker compose logs -f api` | See the API logs live (Ctrl+C to exit) |
| `docker compose restart dashboard` | Restart one part |
| `docker compose down` | Stop everything (the data is kept) |
| `docker compose down -v` | Stop and **erase the database**. On the next start it is built from zero |

The containers restart by themselves if they go down (`restart: unless-stopped`).

---

## 4. Logins

The initial accounts are in `database/initial_credentials.csv` (separator `;`). **It is a sensitive file:** do not send it by email or upload it to GitHub.

| Profile | Login | Note |
|---|---|---|
| Coordination | `coordination.demo` | |
| Support center (SSC) | `ssc.demo` and `ssc2.demo` | |
| Teacher | `teacher.demo` | |
| Finance | `finance.demo` | |
| Management / Board | `management.demo` | |
| Technical administration | `admin.demo` | |
| Data protection officer | `dpo.demo` | |
| Student | `ALU0001` to `ALU1000` | Changes the password on first access |

Each account's password is in the `temporary_password` column of the CSV. On the login screen, choose the profile, enter login and password and accept the terms on first access.

- **New passwords for everyone:** `python -m scripts.build_database --new-accounts`. They are saved in `credentials.csv`.
- **Create a single user:** through the Administration → Users screen, or with `python -m scripts.create_user --login X --profile TEACHER --professor PROF001`.

The `*.demo` accounts are for demonstration and do not get in when `ENVIRONMENT=production`.

---

## 5. Tests to check that everything is working

### 5.1 Diagnostics (1 minute, with the system running)

```bash
python -m scripts.diagnostics
```

It checks Python and packages, `.env`, the connection of each database user, tables, parameters, migrations, the four services, the calculation queue and recent errors. **It must end with "0 failure(s)".** Each failure comes with a tip on what to do.

### 5.2 Automatic tests (less than 1 minute)

They run on a separate database, `mufasa_test`, created and erased by the tests themselves. The `mufasa` database is not touched and the system does not need to be running.

```bash
pytest                       # everything: it must show 201 passed
pytest -m "not database"     # only the calculation tests, without PostgreSQL
pytest tests/test_flows.py -v    # one file, showing each test
```

| File | Tests | What it covers |
|---|---|---|
| `test_calculation.py` | 94 | Indicators, curves, modifiers, levels, completeness (Annex A) |
| `test_api.py` | 39 | Login, profiles, scope, audit, errors, headers, SQL only with parameters |
| `test_chatbot.py` | 41 | Intents, scope, real data, nothing sensitive to the AI |
| `test_flows.py` | 24 | Alert cycle, appointments (RN14), loads, parameters, LGPD, `/health` |
| `test_dashboard.py` | 3 | Profile selector, API down without breaking the screen, safe CSV |

### 5.3 Manual script in the browser (15 minutes)

| # | Sign in as | Do | Expected |
|---|---|---|---|
| 1 | any account | Get the password wrong 5 times | Account blocked for 15 minutes |
| 2 | `coordination.demo` | Open the dashboard and the alert queue | Critical in brick red, High in brown; Critical at the top |
| 3 | `coordination.demo` | Open an alert, assign it to the SSC and record an action | The action appears in the alert history |
| 4 | `ssc.demo` | See the alerts | Only the ones assigned to it |
| 5 | `ssc.demo` | Close an alert without a cause | Refused (CA20) |
| 6 | `teacher.demo` | See the classes | Only the students of their own classes, without health data |
| 7 | `management.demo` | See the dashboards | Only aggregated numbers; groups with fewer than 5 students appear suppressed |
| 8 | `ALU0001` | First access | Asks for a new password and terms acceptance; shows the status, never the score number |
| 9 | `ALU0001` | Book two services less than 15 days apart | The second one is refused (RN14), unless the level is Critical |
| 10 | `admin.demo` | Administration → Services | API, chat, calculation and dashboard "up", with the version |
| 11 | `admin.demo` | Change the minimum grade | It becomes a proposal; it only applies after coordination approves it |
| 12 | `dpo.demo` | Audit, filter by student ID and export CSV | List of who accessed each piece of data |
| 13 | — | Close the chat terminal (or `docker compose stop chat`) | The rest of the dashboard keeps working; the assistant shows "unavailable" |

---

## 6. Common problems

| Symptom | Likely cause | What to do |
|---|---|---|
| `build_database` fails to connect as postgres | Wrong postgres password in `.env` or PostgreSQL stopped | `python -m scripts.configure --overwrite` and build again |
| Port 8501 (or 8000) "in use" | Another program or a previous `start` open | Close the other terminal; on Windows, `netstat -ano \| findstr 8501` shows the process |
| Screen with "Code for support: …" | Error in a part of the system | `python -m scripts.diagnostics --request <code>` (see document 05) |
| Login refuses the right password | Account blocked or wrong profile in the selector | Wait 15 minutes or unblock it in Administration → Users |
| Dashboard says "API unavailable" | API stopped | See `logs/api.console.log`; `start` tries to bring it back up by itself |
| `pytest` shows "skipped … not configured" | The `.env` is missing | Run `configure` first |

---

## 7. Backup

**Always keep the two together**: the database and the `.env`. Without the `SUPPORT_KEY` from the `.env`, the encrypted support data cannot be read.

```bash
# Path A (pg_dump comes with PostgreSQL; on Windows it is in C:\Program Files\PostgreSQL\16\bin)
pg_dump -U postgres -h localhost -Fc -f backup_mufasa.dump mufasa
# restore into an empty database:
pg_restore -U postgres -h localhost -d mufasa --clean backup_mufasa.dump

# Path B
docker compose exec db pg_dump -U postgres -Fc -f /tmp/backup.dump mufasa
docker compose cp db:/tmp/backup.dump ./backup_mufasa.dump
```

Test the restore now and then on a separate database; a backup that was never restored guarantees nothing.

---

## 8. Access from other computers on the network (optional)

By default everything listens only on `127.0.0.1`. To open the dashboard on the local network:

1. Path A: in `dashboard/.streamlit/config.toml`, change `address = "127.0.0.1"` to `address = "0.0.0.0"`. Path B: in `docker-compose.yml`, change `127.0.0.1:8501:8501` to `8501:8501`. Open port 8501 in the machine's firewall.
2. The API and the chat can stay local only, because the dashboard talks to them inside the machine.
3. Outside a test network, use HTTPS (`FORCE_HTTPS=true` behind a proxy with a certificate) and `ENVIRONMENT=production`.
