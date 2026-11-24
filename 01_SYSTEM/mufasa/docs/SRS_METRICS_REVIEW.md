# Review of the metrics against SRS v1.1 and Build Plan v1.1

Date: 28/10/2026. Base checked: database built from zero from the delivery seed (1,000 students, parameters version 1).

The reference documents are SRS v1.1 ("Print .docx") and Build Plan v1.1 ("Print 2.docx"). When the code and the document diverged, the code was fixed to follow the document.

## 1. Parameter table (SRS, Annex C.2)

The SRS says that "none of these values can be a fixed constant in the code". All of them are in the `parameters` table, with version, author, date and justification in `parameter_versions` (RN22). The **Administration → Parameters** screen changes the values; grade and risk cutoffs become a proposal and only apply after coordination approval.

| Parameter (SRS) | SRS default | In the system (`parameters`) | Status |
|---|---|---|---|
| Minimum passing grade | 6.0 | `MINIMUM_GRADE` = 6.0 | Same. A change requires coordination approval |
| Comfortable zone grade | 8.0 | `COMFORTABLE_GRADE` = 8.0 | Same |
| Critical zone grade | 4.0 | `CRITICAL_GRADE` = 4.0 | Same |
| Legal minimum attendance | 75% | `MINIMUM_ATTENDANCE` = 75 | Same |
| Comfortable / critical attendance | 90 / 60% | `COMFORTABLE_ATTENDANCE` = 90, `CRITICAL_ATTENDANCE` = 60 | Same |
| High vulnerability income | 0.5 MW per person | `INCOME_VULNERABLE` = 0.5 | Same |
| Aid eligibility income | 1.5 MW per person | `INCOME_AID` = 1.5 | Same |
| Working hours limit | 20 h/week | `WORK_HOURS_LIMIT` = 20 | Same |
| Commute limit | 60 min/trip | `COMMUTE_LIMIT` = 60 | Same |
| LMS inactivity window | 21 days | `LMS_DAYS_WITHOUT_ACCESS` = 21 | Same (B1 has no LMS data; see section 5) |
| Risk cutoffs | 25 / 50 / 75 | `LOW_CUTOFF` 25, `MODERATE_CUTOFF` 50, `HIGH_CUTOFF` 75 | Same. A change requires coordination approval |
| Minimum completeness to calculate | 40% of the weights | `MINIMUM_COMPLETENESS` = 40 | Same. Between 40% and 70% the score comes out "partial" (`FULL_COMPLETENESS` = 70), as in Annex A |
| Interval between services | 15 days | `SERVICE_INTERVAL` = 15 | Same (RN14; Critical is an exception) |
| Chat closing | 2 hours | `CHAT_INACTIVITY_MINUTES` = 120 in `.env` | Same value, but it lives in the chat `.env` and not in the table. See section 6 |
| Maximum loading time | 3 s | Not a parameter; it is a performance goal | Still without formal measurement; see the time of each request in `logs/api.log` (requests above 2 s become a warning) |
| Student ID size | 7 digits | Validation accepts 7 digits or the B1 `ALU0000` format | The B1 database uses `ALU0001` to `ALU1000` (7 characters, not 7 digits) |
| Limit of open alerts per owner | 30 (to be confirmed in Sprint 1) | `OWNER_ALERT_CEILING` = 30 | Same; still marked as "to be confirmed" |

Parameters the system has in addition, all taken from other parts of the SRS: `INCOME_EXTREME` 0.25 and `INCOME_ONE_MW` 1.0 (I5 bands, Annex A), `MINIMUM_WAGE` R$ 1,621.00, `SLA_CRITICAL_HOURS` 48, `SLA_HIGH_BUSINESS_DAYS` 5, `SLA_DATA_BUSINESS_DAYS` 10 and `GROUP_MINIMUM` 5 (RN07, CA19).

**To be confirmed with the group:** the 2026 minimum wage was entered as R$ 1,621.00. If the decree of the year has another value, just change it in Administration → Parameters; recalculation is automatic.

## 2. Indicator weights (Annex A)

| Indicator | SRS weight | In the system |
|---|---|---|
| I1 Academic performance | 0.20 | 0.20 |
| I2 Attendance | 0.18 | 0.18 |
| I5 Financial situation | 0.11 | 0.11 |
| I3 Accumulated failure | 0.09 | 0.09 |
| I4 LMS engagement | 0.08 | 0.08 |
| I8 Mental health | 0.08 | 0.08 |
| I6 Work | 0.07 | 0.07 |
| I7 Commute | 0.05 | 0.05 |
| I9 Physical health | 0.05 | 0.05 |
| I10 Housing | 0.05 | 0.05 |
| I11 Dependents | 0.04 | 0.04 |
| **Sum** | **1.00** | **1.00** |

The weights cannot be edited on the screen (`editable = false`), because the SRS only allows changing them with a new version of the model.

## 3. Formulas

- **Average (M):** weighted by workload, `sum(grade × WL) / sum(WL)` (SRS B.2.1). It is in `app/calculation/indicators.py` (`calculate_weighted_average`) and in `sql/b1_indicators_recalculation.sql`, which recalculates `academic_indicators.current_average` from the subjects. The student portal uses the same rule.
- **Attendance:** the SRS (B.2.2) defines absences ÷ expected classes. B1 only brings the percentage per subject, so the system weights that percentage by workload, which is the proportion of classes. It is documented as an approximation until the expected classes data arrives.
- **Grade scale:** 0 to 10 (the B1 dump came from 0 to 100; `sql/b1_corrections.sql` converts it).
- **Score:** weighted sum of the indicators present, renormalized by completeness, with the modifiers M1 to M5 and the overlaps of Annex A (`app/calculation/score.py`, code version 3.0, model `deterministic-v1.1`). Each score keeps the parameter version used.
- **Levels:** 0–25 Low, 26–50 Moderate, 51–75 High, 76–100 Critical. Completeness below 40% gives Undetermined and opens a data correction task with a deadline of 10 business days.
- **Deadlines:** Critical 48 hours, High 5 business days (Saturday and Sunday do not count; holidays are not registered yet).
- **Alert queue:** Critical before High, then deadline, then descending score and trend (SRS, RF07).

## 4. Result on the current base

With the B1 base recalculated, the distribution is: High 506, Critical 493, Moderate 1 (overall average 3.46; average attendance 66.6%). The high number of students at risk comes from the data, not from the formula: in B1, 5,400 of the 6,000 enrollments are "Failed". When the real base arrives, the distribution changes by itself.

## 5. What the SRS asks for and the base does not have

The system shows "no data" in these cases and never invents a number:

- LMS access (I4), delivered activities and weekly evolution.
- Remaining absences per subject (RF17): the total of expected classes is missing.
- Effectiveness of interventions and real dropout: they depend on outcomes recorded throughout the semester.

## 6. Pending items

- **XLSX and PDF export:** the dashboard exports CSV (with protection against formulas). XLSX and PDF were not done.
- **Student "My level" screen (Figma):** left out pending a group decision; the student sees the status, never the score number on the screen (RN17).
- **Chat closing:** the 2-hour value lives in the chat service `.env` (`CHAT_INACTIVITY_MINUTES`), not in the parameter table. It works, but the change is not versioned like the others. Moving it to the table is a simple migration (see `docs/05_EVOLUTION_AND_DIAGNOSTICS.md`).
- **Email notification (T24):** notifications are internal, inside the system. Sending by email needs an email server from the institution.
- **Daily backup (T27):** there is no automatic routine; the manual step by step is in `docs/04_LOCAL_USE_AND_TESTS.md`.
