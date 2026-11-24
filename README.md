# MUFASA

The name Mufasa comes with the Lion mascot, and stands for University Monitoring of Attendance, Activities, Health and Learning (in Portuguese, Monitoramento Universitário de Frequência, Atividades, Saúde e Aprendizagem).

MUFASA calculates a dropout risk score for each student, generates alerts for the institution's staff and offers a dashboard per profile (student, teacher, coordination, support center, finance, management, data protection officer and administration), with a virtual assistant (Mufa) that answers only with real data from the database.

Next steps in [ROADMAP.md](ROADMAP.md).

## How to run

You need Docker Desktop installed (step by step in `03_SYSTEM_DOCUMENTS/06_LOCAL_DOCKER_USE.md`, step 1).

1. Download the repository and go into the `01_SYSTEM/mufasa` folder.
2. If you are going to use the assistant with AI, copy `groq.env.example` to `groq.env` and fill in `GROQ_API_KEY`. Without the key, the assistant answers by rules.
3. **To start:** on Windows, double-click `START_MUFASA.bat`. On macOS or Linux, run `./start_mufasa.sh`. The first time, it creates the `.env`, builds the database and generates the initial accounts in `database/initial_credentials.csv`. Then it opens the dashboard at http://127.0.0.1:8501.
4. **To stop:** `STOP_MUFASA.bat` or `./stop_mufasa.sh`. The data stays saved.

Use without Docker and tests: `03_SYSTEM_DOCUMENTS/04_LOCAL_USE_AND_TESTS.md`. To run the tests, `ALLOWED_HOSTS` in the `.env` needs to include `"testserver"`.

## Structure

| Folder | Content |
|---|---|
| `01_SYSTEM/mufasa/` | The system: API (FastAPI), chat, calculation service, dashboard (Streamlit), scripts, SQL, migrations, tests and documentation |
| `02_GROUP_DOCUMENTS/` | SRS v1.1 and Build Plan v1.1, which apply to all the metrics, and the Backend Build Guide |
| `03_SYSTEM_DOCUMENTS/` | Reading copy of the documents in `mufasa/docs`: build, member parts, tools, local and Docker use, evolution, audits, metrics review, privacy, terms, cookies and consent |
| `04_DATABASE/` | B1 dump (`Samuel Part BackEnd B1 - clean.sql`), spreadsheet `Dropout_Database_AI_Normalized.xlsx` and `schema.sql` |
| `05_IMAGES/` | System screens: comparison with Figma, assistant, accessibility and data visuals |
| `06_ORIGINAL_PARTS/` | Parts as they were received: B1 database, B2 calculation, B3 API, F1 dashboard (prototype `MUFASA.fig`) and F2 chatbot |
| `07_PREVIOUS_VERSIONS/` | Old deliveries, kept for reference only |

The system folder in use is always `01_SYSTEM/mufasa`. When changing a document, change the one in `mufasa/docs`.

## What is not in the repository

For security and LGPD reasons, these stay out of Git:

- `groq.env` and `.env` (system keys and passwords);
- `database/initial_credentials.csv` and `database/initial_accounts.sql` (account passwords). The system generates new accounts when it builds the database;
- `logs/`, local SQLite databases and `.zip` files.

The student data in the B1 database is fictitious, used in the testing phase.

## Team

| Part | Responsible |
|---|---|
| B1 Database | Samuel |
| B2 Score calculation | Susy |
| B3 API and Security | João |
| F1 Dashboard | Davi |
| F2 Chatbot | Eduardo |
