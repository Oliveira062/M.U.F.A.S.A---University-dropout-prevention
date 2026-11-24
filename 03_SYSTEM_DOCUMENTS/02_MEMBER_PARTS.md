# MUFASA — each member's part

This document brings together two sources: what Build Plan v1.1 assigns to each member and what actually arrived for the integration. For each part there is what was done, what was used and how it was built.

> **Authorship confirmed by João on 28/10/2026:** B1 (database) is by Samuel, B2 (calculation and score) is by Susyanne and B3 (API and security) is by João Victor. This split differs from the one planned in Plan v1.1 (section 1). What was confirmed is what counts: section 2 shows who did each part.

## 1. Split planned in Plan v1.1

| Member | Scrum role | Front | Plan activities |
|---|---|---|---|
| Susyanne Sanne Souza Inácio | Product Owner | Group 2 — business rules and priorities | T03, T18, T22, T24, T25 |
| João Victor Lúcio Luna de Oliveira | Scrum Master | Group 1 — sprint pace and impediments | T01, T02, T19, T23, T27 |
| Gabriel Farinha de Bastos | Developer | Group 1 — database | T04, T07, T15 |
| Davi dos Santos Xavier Gomes | Developer | Group 1 — data analysis and risk score | T08, T09, T16, T26 |
| Dérik Sousa Silva | Developer | Group 1 — API and back-end | T10, T11, T13, T20 |
| Eduardo Borges Souza Rodovalho | Developer | Group 2 — dashboard and front-end | T05, T12, T14 |
| Samuel Sampaio Oliveira Lima | Developer | Group 2 — chatbot and integration | T06, T17, T21 |

## 2. What arrived for the integration

| Delivery | Content | Done by | Planned in the Plan |
|---|---|---|---|
| "Samuel Part BackEnd B1" | PostgreSQL dump with 1,000 students | **Samuel** (confirmed) | Gabriel (T04, T07) |
| "B2 Susy" | Calculation and score module v2.2, 41 tests | **Susyanne** (confirmed) | Davi (T08, T09) |
| B3 — João | API, login, profiles, audit, LGPD | **João Victor** (confirmed) | Dérik (T10, T11, T13, T20) and João (T19) |
| "Eduardo Part" | Chatbot in FastAPI with Groq | Eduardo (by the name of the delivery) | Samuel (T17, T21) |
| F1 — daviXvier/MUFASA repository and Figma | Dashboard in Streamlit and prototype with 82 screens | Davi's repository (daviXvier) | Eduardo (T05, T12, T14) |

The originals of each delivery are in `integrated/originals/`, unchanged.

## 3. Each part: what was done, used and built

### B1 Database — Samuel Sampaio Oliveira Lima

- **What was done:** base with 1,000 simulated students of the Artificial Intelligence course, with subjects, classes, enrollments, partial grades (EXAM1 to EXAM3), attendance, academic indicators and socioeconomic context.
- **What was used:** PostgreSQL, delivered as a `pg_dump` dump.
- **How it was built:** tables without keys, grades from 0 to 100, health data inside the students table.
- **What the integration added:**
  - removal of 2,000 orphan rows;
  - primary and foreign keys, dates as DATE and range constraints;
  - grades converted to 0 to 10;
  - health data moved to an encrypted table;
  - indicators recalculated from the subjects.
  
  Files: `sql/b1_leftovers_cleanup.sql`, `sql/b1_corrections.sql`, `sql/b1_indicators_recalculation.sql`.

### B2 Calculation and score — Susyanne Sanne Souza Inácio

- **What was done:** the 11 indicators, weights, bands, completeness, overlap by attendance and explanation of the factors.
- **What was used:** plain Python, without a database, with 41 tests in pytest.
- **How it was built:** pure functions in `indicators.py` and `score.py`. Version 2.2 fixed the inverted scale (0 = safe, 100 = maximum risk).
- **What the integration added:**
  - rewrite to follow Annex A of SRS v1.1 (curves, modifiers M1 to M5, partial completeness, RN04 sentences);
  - parameters read from the versioned table;
  - separate calculation service that recalculates from the queue.
  
  Files: `app/calculation/`, `app/calculation_service/`.

### B3 API and security — João Victor Lúcio Luna de Oliveira

- **What was done:**
  - REST API `/api/v1`;
  - login with JWT and bcrypt, block after 5 failures;
  - Annex E profiles and a scope check against improper access;
  - audit trail that cannot be changed;
  - request limit and security headers;
  - LGPD documents and security, accessibility and content audits.
- **What was used:** FastAPI, Pydantic, SQLAlchemy (only SQL with named parameters), PyJWT, bcrypt and PostgreSQL with one database user per service.
- **How it was built:**
  - configuration only through `.env`;
  - all the SQL in `*queries.py`;
  - standardized errors, with no stack or SQL in the response;
  - tests that fail SQL built with text.
  
  Files: `app/api/`, `sql/b3_complement.sql`, `docs/*_AUDIT.md` and `docs/*_POLICY.md`.

### Chatbot — "Eduardo Part" delivery

- **What was done:** natural language assistant that answers about grades, attendance and status.
- **What was used:** FastAPI, Groq (model `openai/gpt-oss-20b`) and its own SQLite.
- **How it was built:** the model generated the answer freely from the student's data.
- **What the integration changed:**
  - the chat started using the API login and profiles;
  - it only reads its own PostgreSQL views;
  - it answers through 24 closed intents;
  - the AI only writes text with markers and the server fills in the real numbers;
  - no personal data goes out to Groq.
  
  Files: `app/chatbot/`, `app/main_chat.py`, `sql/chatbot.sql`, `docs/CHATBOT_AUDIT.md`.
- **Security pending item:** the Groq key that came in the shared file must be revoked by the account owner.

### Dashboard — F1 (Streamlit and Figma)

- **What was done:**
  - dashboard in Streamlit (`app.py`) with charts and filters;
  - Figma prototype with 82 screens: login, LGPD terms, Coordination and Management dashboards, alert queue, student record, teacher, student portal and administration.
- **What was used:** Streamlit, Plotly and pandas, reading CSV files. Figma with the mustard palette (`#C99720`) and the Inter font.
- **How it was built:** `app.py` read CSVs directly, without login.
- **What the integration changed:**
  - dashboard rewritten to consume only the API;
  - hub per profile and a profile selector on login;
  - charts that refresh by themselves with the data from the database;
  - isolation of each section;
  - Critical and High colors set by João.
  
  Files: `dashboard/`.

### Integration, tests and operation

- **What was done:**
  - joining all the parts;
  - 201 tests on a test database;
  - browser test with all profiles;
  - local and Docker installation;
  - logs, diagnostics, migrations and this documentation.
- **Plan activities covered:** T01 (environment and container), T19 (encryption and audit), T23 (end-to-end tests) and part of T27 (controlled degradation; automatic backup is still missing).

## 4. Plan activities that do not have a delivery yet

| Activity | What is missing |
|---|---|
| T03 Closing the rules with coordination | Validate the Annex C parameters with coordination. The system already uses the SRS default values |
| T18 Writing the messages | Final review of the texts by the PO (the current texts are in `docs/CONTENT_REVIEW.md`) |
| T22 Validation CA01 to CA20 | Record the evidence for each criterion. The tests already cover several, for example CA19 and CA20 |
| T24 Email notification | Notifications are internal; email depends on the institution's server |
| T25 Presentation | — |
| T27 Daily backup | The manual step by step is in document 04 |
