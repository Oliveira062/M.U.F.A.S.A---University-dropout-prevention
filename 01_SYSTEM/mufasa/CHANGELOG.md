# Change log

Version in the MAJOR.MINOR.PATCH format (see `docs/05_EVOLUTION_AND_DIAGNOSTICS.md`, section 5.5). The version in use appears at `/health` and in Administration → Services.

## 1.1.0 — 28/10/2026

**Dashboard and colors**
- All screens follow the Figma visual pattern: Inter font, logo, side menu with icons and an alert counter, top bar with path, notifications and account, page headers, cards with icon, white panels, tables with a cream header, deadline and status pills, timeline and shortcuts. Critical and High keep the red and the brown chosen by the group.
- Spacing review for wide screens and laptops: login with the cream background following the column and the form centered, icons in the fields even with autofill, font with hinting for Windows, default space between header and content and a maximum width of 1480 px.
- Two-column login; alert queue, student record (score scale and factors with points), teacher classes and student home redone in the Figma layout. Comparisons in `figma-comparison/`, next to the delivery.
- Critical becomes `#9A4A1E` and High `#523E1D` in the badges and in all charts, at João's request. The badges keep icon and text.
- A freer and more personal assistant: the AI writes in its own style, talks about studies and routine and understands follow-ups ("and in Calculus II?"). It receives the question only anonymized; health topics do not leave the server. Answers mention the first name, the best and the worst subject, the average compared to the previous semester and the risk factors.
- Combined searches for the team: "students with attendance close to 60% and average below 5", "more than 3 pending activities in the 2nd semester". Home distance only for the support center.
- Activities with a deadline: migration 002 with the `student_activities` table and simulated activities consistent with the B1 pending items. The student asks what is due this week and what is late. On Docker, `docker compose up -d --build` applies the migration by itself.
- Assistant: questions stay on the right and answers on the left, always inside the conversation box. Mufa's opening becomes the first message.
- Assistant answers reorganized and more welcoming: an opening sentence, one item per line (for example, the subject with the final grade and, below it, EXAM1, EXAM2 and EXAM3), separate paragraphs and a next step at the end. The methodological notice appears as a smaller note. The text is still escaped before it becomes HTML. The AI, when on, receives the rule to keep paragraphs short and the list in its own block.
- Automatic sweep of the 8 profiles at 1366 and 1900 px: long names in the side menu now wrap, the user name at the top is no longer cut and the "suppressed" band shows the whole text.
- Tables with suppressed groups become text, which removes the Streamlit conversion warning. `use_container_width` (deprecated) replaced by `width="stretch"`.

- Floating accessibility button on every screen, including login. Options:
  - text size;
  - high contrast, dark mode and grayscale;
  - more readable font and more space in the text;
  - highlight of links and buttons;
  - reading guide, large cursor and paused animations;
  - read aloud, with the browser's voice.

  The Libras translator (VLibras) starts off and only loads after a notice and the person's confirmation (LGPD). The choices are saved in the browser. See `docs/ACCESSIBILITY_AUDIT.md`.

- Data with a new look on every screen: custom tables instead of the Streamlit spreadsheets. Grades with one decimal place (6.0 and 7.8), grade and attendance below the minimum in red, attendance with a bar, status and result in badges with icon, a summary band above the student's subjects. Risk factors in cards with icon. Applies to the student portal, record, teacher class, finance, management, administration and data protection officer.
- Assistant: Mufa header, conversation with its own scroll that follows the last message, a larger writing box with a sample question, the Enter tip and a visible send button, highlighted suggestions.
- `START_MUFASA.bat` always updates the image with the folder's code before starting. Before, `docker compose up -d` reused the old image and the new screens (including the accessibility button) did not appear.
- Groq key in the `groq.env` file, next to `.env` and ignored by Git and Docker. `python -m scripts.configure --keys` copies only the GROQ_* lines to `.env`, and `START_MUFASA.bat` does this at every start.

**Finding errors**
- `START_MUFASA.bat` and `STOP_MUFASA.bat` shortcuts (and `start_mufasa.sh` / `stop_mufasa.sh`) to start and stop the system with a double click. The start one opens Docker Desktop if needed, creates the `.env` the first time, waits for the dashboard and opens the browser.
- Logs in `logs/<service>.log` with rotation (5 MB × 5) and a request code on every line.
- Code for support in every error shown on the screen.
- `scripts/diagnostics.py`: checks the whole system and searches for an error by its code (`--request`).
- Error 500 responses now carry the code and the security headers.

**Evolving**
- Versioned migrations (`sql/migrations/`, `scripts/migrate.py`, with `--new` and `--list-items`).
- System version number in `app/__init__.py`, shown at `/health` and in the heartbeat.

**Running locally**
- `scripts/configure.py` generates the `.env`.
- `scripts/build_database.py` builds the database without `psql`, with the initial accounts (`database/initial_accounts.sql`).
- `scripts/start.py` starts and restarts each part.
- Docker: `Dockerfile` and `docker-compose.yml` with automatic restart and health check.
- `requirements.lock` with the exact versions tested.
- Removed `scripts/build_database.sh`, replaced by `build_database.py`.

**Tests**
- Tests now run on a test PostgreSQL (`mufasa_test`).
- New `test_flows.py` and `test_dashboard.py`: 201 tests in total.

**Documentation**
- Documents 01 to 05 and the review of the metrics against SRS v1.1.
- Document 06: step by step for local use with Docker.

## 1.0.0 — 28/10/2026

- Integration of B1, B2, B3, F2 and F1.
- Score rewritten from Annex A of SRS v1.1, with versioned parameters.
- Streamlit dashboard with a hub per profile.
- Logins for the 1,000 students and one demo account per profile.
- Separate services (API, chat, calculation, dashboard) with failure isolation.
