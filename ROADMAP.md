# MUFASA Roadmap

## Done

### 1.0.0 (28/10/2026)
- Integration of the parts B1 (database), B2 (calculation), B3 (API and security), F1 (dashboard) and F2 (chatbot).
- Score rewritten according to Annex A of SRS v1.1, with versioned parameters.
- Streamlit dashboard with a hub per profile and one demo account for each of the 8 profiles.
- Logins for the 1,000 students.
- Separate services (API, chat, calculation, dashboard) with failure isolation.

### 1.1.0 (28/10/2026)
- All screens following the Figma visual standard. Critical `#9A4A1E` and High `#523E1D`.
- Freer Mufa assistant, with data anonymized before reaching the AI and health topics kept on the server.
- Combined searches for the staff and activities with deadlines for the student.
- Accessibility button on every screen, with VLibras only after consent.
- Shortcuts to start and stop, logs with request code and a diagnostics script.
- LGPD documentation (privacy, terms, cookies, health data consent) and security, accessibility and chatbot audits.
- 217 automated tests.

## Next steps

### Security
- [ ] Define the second authentication factor for the student login.


### Data and metrics
- [ ] Align `indicators.current_average` with the B1 enrollment grades.
- [ ] Unify the risk ranges (B1 uses 20/35/56, B2 uses 25/50/75), according to SRS v1.1.
- [ ] Review the 90% proportion of failed enrollments in B1.
- [ ] Standardize the grade scale (0 to 10 or 0 to 100).

### API and architecture
- [ ] Decide the name of the risk route: `/risk` (Guide) or `/score` (SRS, in use).
- [ ] Run batch 1 of the architecture audit (SRE).
- [ ] Include `testserver` in the default test configuration, so they run without adjusting the `.env`.
- [ ] Continuous integration on GitHub running the tests on every push.

## Future
- [ ] Publish the system on a server, with HTTPS and backups.
- [ ] Replace the simulated grades with the institution's real grades.
- [ ] Mobile app connected to the API.
