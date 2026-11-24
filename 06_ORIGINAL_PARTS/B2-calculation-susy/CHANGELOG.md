# Backend B2 — Version history

## v2.2 — Scale fix and full implementation of the 11 factors

### Critical fix

**The score scale was inverted.** In v2.1, attendance and grade were converted into a performance score (100% attendance → 100 points) and the result was delivered as if it were risk. Since the SRS defines the score as dropout risk (0 = safe, 100 = critical), the system did the opposite of what was intended.

Proof by execution:

| Case | v2.1 | v2.2 |
|---|---|---|
| Model student (average 9.5 · att. 98% · does not work) | score 90 — CRITICAL | **score 0 — LOW** |
| Student dropping out (average 2.0 · att. 40% · 48h of work) | score 0 — LOW | **score 98 — CRITICAL** |
| Canonical SRS case (average 5.4 · att. 68% · 44h) | score 51 | **score 63 — HIGH** |

The fix is in the `risk_by_*` functions, which receive the raw value of the factor and return a risk from 0 to 100: a high grade produces low risk.

### Specific fixes

| Item | v2.1 | v2.2 |
|---|---|---|
| `classify_risk_level` | Declared twice; the first without a body, with an orphan docstring | Single declaration, with the docstring in place |
| Name of the second level | `"MEDIUM"`, differing from the SRS and from the recommendations dictionary itself | `"MODERATE"` throughout the module |
| Level `"VERY LOW"` | Recommendation for a nonexistent level | Removed |
| `import calculate_remaining_absences` | Inside the function, on line 54 | At the top of the file |
| Attendance with 0 classes recorded | Returned `100.0` | Returns `None` — missing records are not perfect attendance |
| `calculate_attendance_percentage` | Signature `(expected_classes, attendances)` | Signature `(held_classes, absences)`, according to the SRS |

### Missing implementations

- **The 11 SRS factors**, against 3 in v2.1. Added: financial situation, failure rate, VLE engagement, mental health, commute, physical health, housing and dependents.
- **SRS weights** in the `WEIGHTS` dictionary (20/18/11/9/8/8/7/5/5/5/4), instead of the improvised 45/45/10. Sum checked in a test.
- **Completeness handling** (RN01): missing factors are excluded from the numerator and the denominator; below 40% of available weight the level comes out as `UNDETERMINED` and the score as `None`.
- **Overlap rule**: attendance below 75% forces level HIGH, whatever the weighted result.
- **Explainability by real contribution** to the score (`weight × risk` sorted), instead of v2.1's fixed thresholds — meets RN01 and business rule 8.
- **`explain_score()`**: generates the natural language explanation for the dashboard and the chatbot.
- **`calculate_failure_rate()`** and **`calculate_registration_completeness()`** in `indicators.py`.
- **`breakdown` field** in the return: the risk of each available factor, for auditing.

### Tests

From 5 tests to **41**, all passing.

The scale bug got through v2.1 because `test_canonical_srs_case` only checked `assert "score" in result` and `assert level in ["CRITICAL","HIGH","LOW"]` — assertions that pass with almost any result. The new tests require an exact value or a verifiable order relation.

Tests that did not exist and now protect the module:

- `test_scale_direction` — compares a model student and a student dropping out. It is the test that fails any reintroduction of the inversion.
- `test_grade_monotonicity` and `test_attendance_monotonicity` — worsening a factor can never lower the risk.
- `test_insufficient_completeness_becomes_undetermined` and `test_missing_factor_does_not_enter_the_average`.
- `test_attendance_overlap_forces_high` and `test_overlap_does_not_downgrade_critical`.
- `test_attendance_without_recorded_class_returns_none` — the error the SRS forbids.
- `test_weights_add_up_to_one`, `test_weights_match_srs`, `test_eleven_factors`.
- `test_srs_canonical_case` with asserts on the numeric values (52.0 · 58.7 · 100.0 · score 63).
- `test_output_contract_has_all_keys` — validates Contract 2 with B3.

### Structure

- Removed the duplicated copies `Teste/score.py` and `Teste/indicadores.py`, identical to those in `app/calculation/`.
- Folder `Teste/` renamed to `tests/`.
- Created the `__init__.py` files in `app/`, `app/calculation/` and `tests/` — without them the imports failed.
- Created a `.gitignore` covering `__pycache__/`, `.pytest_cache/`, `venv/`, `.env` and real student data.
- Removed the versioned caches.

---

## v2.1 — Initial version (delivered by B2)

First implementation of the indicators and the score. Three correct indicators: remaining absences, attendance percentage and weighted average. Folder structure, type hints, docstrings and separation between indicators and score according to the agreed architecture. Return format compliant with Contract 2.
