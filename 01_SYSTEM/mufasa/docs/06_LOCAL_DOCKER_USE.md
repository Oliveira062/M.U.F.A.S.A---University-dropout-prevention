# MUFASA — step by step for local use with Docker

This guide goes from an empty computer to the first login, using only Docker. There is no need to install Python or PostgreSQL. All commands were tested on 28/10/2026 from `mufasa-1.1.0.zip`, in a new folder.

The commands are written for **Windows PowerShell**. The differences for macOS and Linux appear as a note right below each step.

---

## Overview

Docker starts 6 containers:

| Container | What it is | Stays |
|---|---|---|
| `db` | PostgreSQL 16 database | always on |
| `build_database` | Builds the database the first time | runs once and stops ("Exited (0)") |
| `api` | API, port 8000 | always on |
| `chat` | Assistant, port 8001 | always on |
| `calculation` | Recalculates scores and alerts | always on |
| `dashboard` | System screens, port 8501 | always on |

If a container goes down, Docker brings it back up by itself, and the others keep working. The database data is kept in a Docker volume and is not lost when the computer is turned off.

---

## Step 1 — Install Docker Desktop (once)

1. Requirements:
   - 64-bit Windows 10 or 11;
   - 8 GB of RAM or more;
   - about 3 GB free on disk.
2. Download Docker Desktop at **docker.com/products/docker-desktop** and install it.
   - When the installer asks, leave the **"Use WSL 2"** option checked.
   - If Windows asks to install or update WSL, accept and restart the computer.
3. Open Docker Desktop and wait until **"Engine running"** appears in the lower left corner.
4. Open **PowerShell** (Start menu → type "PowerShell") and check the installation:
   ```powershell
   docker --version
   docker compose version
   ```
   Both commands must show a version number.

> **macOS:** install Docker Desktop for Mac and use the Terminal app.
> **Linux:** install Docker Engine and the Compose plugin (`docker-compose-plugin`). To use `docker` without `sudo`, add your user to the `docker` group.

---

## Step 2 — Unzip the project (once)

1. Unzip `mufasa-1.1.0.zip` into a short folder without accents, for example `C:\mufasa`.
2. In PowerShell, go into the project folder. It is the folder that contains `docker-compose.yml`:
   ```powershell
   cd C:\mufasa\mufasa
   dir docker-compose.yml
   ```
   `dir` must list the file. All the commands in the next steps run in this folder.

**If `cd` gives an error:**

- **Path with a space** (for example, "My Projects"): put the path in quotes, as in `cd "C:\Users\you\My Projects\mufasa"`.
- **Folder inside a folder:** if `dir` does not find the file, the zip created one folder inside the other. Run `cd mufasa` and repeat `dir`.
- **Shortcut:** in File Explorer, open the folder where `docker-compose.yml` appears, click the address bar, type `powershell` and press Enter. PowerShell already opens in the right folder.
- **Avoid OneDrive:** syncing can lock the log and backup files while Docker uses the folder. Prefer `C:\mufasa`.

---

## Step 3 — Build the system image (once, and at each update)

```powershell
docker build -t mufasa:1.1.0 .
```

- **What it does:** downloads Python 3.13 and installs the packages from `requirements.lock`.
- **Time:** 2 to 5 minutes the first time, depending on the internet.
- **Expected:** the last line shows `naming to docker.io/library/mufasa:1.1.0` or `DONE`.

**If you get `429 Too Many Requests`:** Docker Hub limits anonymous downloads. Sign in to your account with `docker login` (the free account is enough) and repeat the command.

---

## Step 4 — Generate the `.env` configuration file (once)

The `.env` keeps the database passwords and the system keys. The command below generates all of them on the spot, at random:

```powershell
docker run --rm -u root -v "${PWD}:/app" mufasa:1.1.0 python -m scripts.configure --docker
```

- **Expected:** `.env created at /app/.env`. The message also suggests `python -m scripts.build_database` as the next step; ignore that part, because on Docker the database is built in step 5.
- **Check:** `dir .env` must list the file.

> **Command Prompt (cmd):** replace `"${PWD}:/app"` with `"%cd%:/app"`.
> **macOS:** same as Windows.
> **Linux:** replace `-u root` with `-u "$(id -u):$(id -g)"`, so the file belongs to your user.

**Keep a copy of the `.env` in a safe place.** Without it, the encrypted support data cannot be read. Do not send this file by email or upload it to GitHub.

---

## Step 5 — Start the system

```powershell
docker compose up -d
```

The first time, the `build_database` container creates the database and loads the 1,000 students, the corrections, the scores and the accounts. This takes less than 1 minute. To follow it:

```powershell
docker compose ps -a
```

**Expected after 1 to 2 minutes:**

```
SERVICE          STATUS
api              Up ... (healthy)
build_database   Exited (0) ...
calculation      Up ...
chat             Up ... (healthy)
dashboard        Up ... (healthy)
db               Up ... (healthy)
```

- `build_database` with **Exited (0)** is right: it finished its job.
- If `Exited (1)` appears, see the reason with `docker compose logs build_database`.
- The last expected line of that log is `Database mufasa ready.`

---

## Step 6 — Sign in to the system

1. Open the browser at **http://127.0.0.1:8501**.
2. Open the `database\initial_credentials.csv` file. In Excel, use Data → From Text/CSV with the `;` separator; you can also open it in Notepad.
3. Choose an account. The password is in the `temporary_password` column.

| Profile on the login screen | Login |
|---|---|
| Coordination | `coordination.demo` |
| SSC — Student Support Center | `ssc.demo` |
| Teacher | `teacher.demo` |
| Finance office | `finance.demo` |
| Management | `management.demo` |
| Technical administration | `admin.demo` |
| Data protection officer | `dpo.demo` |
| Student | `ALU0001` to `ALU1000` |

4. On the login screen, choose the **profile**, type the login and the password and click **Sign in**.
5. On first access, accept the terms. The student also creates a new password.

The credentials file is sensitive: do not share it.

---

## Step 7 — Check that everything is working

### 7.1 Diagnostics (30 seconds)

```powershell
docker compose exec dashboard sh -c "cd /app && python -m scripts.diagnostics"
```

- All items must come out `ok`, **except one**: `[ FAIL  ] .env file`.
- This failure is expected on Docker, because the file stays outside the container and the variables arrive through Compose. The following lines confirm that each variable was set.
- **Expected at the end:** `Summary: 1 failure(s)`.

### 7.2 Automatic tests (less than 1 minute)

The tests run on a separate database (`mufasa_test`) inside the same PostgreSQL. The system database is not touched.

```powershell
docker compose run --rm -e ALLOWED_HOSTS='["testserver","localhost","127.0.0.1"]' build_database python -m pytest -q -p no:cacheprovider
```

- **Expected:** `201 passed`.
- The `ALLOWED_HOSTS` variable allows the internal address the tests use.

### 7.3 Browser script

Follow the table in section 5.3 of `docs/04_LOCAL_USE_AND_TESTS.md`: 13 checks, one per profile.

### 7.4 Failure isolation

```powershell
docker compose exec chat sh -c "kill 1"
docker compose ps
```

- `chat` comes back by itself in a few seconds ("Up ... seconds").
- During the outage, the dashboard and the API keep working.

---

## Step 8 — Day-to-day use

### Start and stop with a double click

There are two shortcuts in the project folder. Use them whenever you shut down and turn on the computer:

| File | What it does |
|---|---|
| `START_MUFASA.bat` | Opens Docker Desktop if it is closed, creates the `.env` the first time, starts all the parts, waits for the dashboard to be ready and opens `http://127.0.0.1:8501` in the browser |
| `STOP_MUFASA.bat` | Stops all the parts. The database data is kept |

On macOS or Linux, the equivalents are `./start_mufasa.sh` and `./stop_mufasa.sh`.

**To start by itself when signing in to Windows:** in Docker Desktop, open *Settings → General* and check *Start Docker Desktop when you sign in to your computer*. Since each part of MUFASA has automatic restart, the system works again by itself after Docker opens, unless you stopped it with `STOP_MUFASA.bat`. In that case, start it again with `START_MUFASA.bat`.

**Desktop shortcut:** right-click `START_MUFASA.bat` → *Send to* → *Desktop (create shortcut)*.

### Groq key (assistant with AI)

The key is in the `groq.env` file, in the project folder, in a `GROQ_API_KEY=...` line. `START_MUFASA.bat` copies the key to the `.env` every time it starts the system. To change the key, edit only `groq.env` and start again. In PowerShell, the equivalent command is:

```powershell
docker run --rm -u root -v "${PWD}:/app" mufasa:1.1.0 python -m scripts.configure --keys
docker compose up -d
```

`groq.env` is a secret: do not send it to GitHub or outside the group. Git and Docker already ignore this file. Without it, the assistant works with the ready answers.

### Through the commands


| To… | Command |
|---|---|
| Start (after restarting the computer) | Double-click `START_MUFASA.bat`, or open Docker Desktop and run `docker compose up -d --build` in the project folder (`--build` makes sure the newest version of the code is used) |
| See if everything is up | `docker compose ps` |
| Stop (the data is kept) | Double-click `STOP_MUFASA.bat`, or `docker compose down` |
| Restart one part | `docker compose restart dashboard` (or `api`, `chat`, `calculation`) |
| See the logs of one part live | `docker compose logs -f --tail 50 api` (Ctrl+C to exit) |
| Open the log files | The project's `logs\` folder (`api.log`, `chat.log`, `calculation.log`, `dashboard.log`) |
| Find an error by the code on the screen | `docker compose exec dashboard sh -c "cd /app && python -m scripts.diagnostics --request CODE"` |
| Open the database in the terminal | `docker compose exec db psql -U postgres -d mufasa` (exit with `\q`) |

Docker Desktop also shows all this through the interface: **Containers** tab → `mufasa`.

---

## Step 9 — Backup

**Make the backup.** It generates the `backup_mufasa.dump` file in the project folder:

```powershell
docker compose exec db pg_dump -U postgres -Fc -f /tmp/backup.dump mufasa
docker compose cp db:/tmp/backup.dump ./backup_mufasa.dump
```

**Restore a backup.** The current database is replaced:

```powershell
docker compose stop api chat calculation dashboard
docker compose cp ./backup_mufasa.dump db:/tmp/restore.dump
docker compose exec db pg_restore -U postgres -d mufasa --clean --if-exists /tmp/restore.dump
docker compose start api chat calculation dashboard
```

Keep `backup_mufasa.dump` together with a copy of the `.env`. One is useless without the other.

---

## Step 10 — Update to a new version

1. Make the backup (step 9).
2. Unzip the new version over the folder, **keeping the `.env`**.
3. Rebuild the image and start the system again. Replace the number with the new version, which appears in `docker-compose.yml`:
   ```powershell
   docker build -t mufasa:1.1.0 .
   docker compose up -d
   ```
   Or just double-click `START_MUFASA.bat`, which already does both.
4. The database changes of the new version (migrations) are applied by `build_database` by itself on start. To check or apply them by hand:
   ```powershell
   docker compose run --rm build_database python -m scripts.migrate
   ```
5. Check with the diagnostics (step 7.1).

---

## Start over from zero

This command **erases the database**, including changed passwords, alerts and services. On the next start, the database is built again from the delivery seed:

```powershell
docker compose down -v
docker compose up -d
```

**Generate new passwords for all accounts:**

```powershell
docker compose run --rm build_database python -m scripts.build_database --yes --new-accounts
```

The new passwords are in `credentials\credentials.csv`. This command also recreates the database. After it, run `docker compose restart api chat calculation dashboard`.

---

## Common problems

| Symptom | What to do |
|---|---|
| `docker` is not recognized | Docker Desktop is not installed or not open. Open it and wait for "Engine running" |
| `error during connect` / `cannot find the file specified` | Docker Desktop is closed or still starting. Wait and repeat |
| `required variable POSTGRES_PASSWORD is missing a value: run python -m scripts.configure --docker` | The `.env` is missing, or you are outside the project folder. Go back to step 2 or step 4 |
| `port is already allocated` (8000, 8001 or 8501) | Another program uses the port. Close the other program, or the `scripts.start` of the direct installation |
| `build_database` with `Exited (1)` | See the reason with `docker compose logs build_database`, then run `docker compose down -v` and `docker compose up -d` |
| The page does not open at 127.0.0.1:8501 | `docker compose ps`: the dashboard must be "healthy". See `docker compose logs dashboard` |
| Screen with "Code for support: …" | Use the search-by-code command (step 8) and see `docs/05_EVOLUTION_AND_DIAGNOSTICS.md` |
| `429 Too Many Requests` in step 3 | `docker login` and repeat |
| Slow computer | In Docker Desktop, Settings → Resources: reserve at least 4 GB of memory |
