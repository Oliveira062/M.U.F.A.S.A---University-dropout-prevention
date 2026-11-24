# Content Review: fake reviews and unproven promises

27/10/2026 · Material reviewed: B1 (dump), B2 (code, README, CHANGELOG), Build Guide, SRS v1.1, Build Plan v1.1 and `b3/README.md`.

## Reviews and testimonials

**No fake review, testimonial, user rating, badge or "approved by" was found** in any of the materials. There is nothing to remove.

The new B3 texts (privacy policy, terms of use, cookie policy) were written without absolute guarantees: they say what is implemented, admit that no system is immune to incidents and that availability is not uninterrupted.

## Unproven or inaccurate statements

| # | Where | Current text | Problem | Suggested text |
|---|---|---|---|---|
| C-1 | B2: `README.md` line 84; `indicators.py` line 17; `score.py` line 39 | "Minimum attendance of 75% comes from LDB art. 47 §3" | Art. 47, §3 of the LDB says attendance is mandatory, but it **does not set 75%**. The 75% percentage is in art. 24, VI, which deals with basic education. In higher education, the minimum comes from the bylaws and the rules of the education system | "Minimum attendance of 75%, according to the institution's bylaws (the LDB, art. 47, §3, makes attendance mandatory; the 75% percentage follows art. 24, VI, applied by analogy). Confirm in the bylaws." |
| C-2 | B2: `score.py` line 155 | "The 20h threshold comes from Law 11,788/2008 (internship), which treats 20 weekly hours as working hours compatible with academic life" | Art. 10 of Law 11,788/2008 sets 20 weekly hours for special education and the final years of elementary school. For **higher education**, the limit is 6 hours a day and **30 hours a week** (art. 10, II) | "Thresholds set by the group. Reference: Law 11,788/2008, art. 10, II, allows up to 30 weekly hours of internship in higher education." Assess whether the 20h cutoff still makes sense |
| C-3 | B2: `score.py` line 198 | "1.5 MW per person: Decree 7,234/2010 (PNAES) and Law 12,711/2012" | Law 14,723/2023 changed Law 12,711/2012 and reduced the income criterion for quotas to **1 minimum wage per capita**. The 1.5 MW of PNAES (Decree 7,234/2010, art. 5) remains | "1.5 MW per person: Decree 7,234/2010 (PNAES), art. 5." Remove Law 12,711/2012 from the justification or cite the updated value |
| C-4 | B2: `score.py` line 242 | "The 60-minute threshold follows the IBGE commute bands" | No exact reference (survey, year, table). Check: in the usual Census bands for commute time (up to 30 minutes, 30 minutes to 1 hour, 1 to 2 hours) there is no cutoff at 90 minutes, which the function uses | Cite the exact source, for example "IBGE, Demographic Census, usual commute time to work", and say that the 90-minute cutoff is the group's choice |
| C-5 | B2: `score.py`, header | "Compliance: RN01 (...), RN05 (...), LGPD art. 20" | A calculation module alone does not guarantee compliance. Art. 20 depends on recording the human review, which lives in the API and in the processes | "Contributes to RN01, RN05 and LGPD art. 20: the output is explainable and serves as a recommendation to a person." |
| C-6 | B2: `CHANGELOG.md` | "Versioned caches removed" | The package sent contains `__pycache__` and `.pytest_cache` | Actually remove the caches, or fix the sentence |
| C-7 | B2: `CHANGELOG.md` and `README.md` | "From 5 tests to 41, all passing" | There are indeed 41 test functions. The run could not be repeated in this review | Keep the sentence, adding the date and the command of the last run (`pytest -v`, 27/10/2026) |
| C-8 | SRS v1.1, Section 3.1 | "about a relevant share of the male population has some form of color blindness" | "About a share" is not a number, and there is no source | "about 8% of men have some deficiency in color perception (source: [reference])" |
| C-9 | SRS v1.1, Section 3.3 | "FastAPI (...) eliminates the dependence on verbal explanation" | Absolute promise: automatic documentation reduces, but does not eliminate, the need to agree on contracts | "reduces the dependence on verbal explanation" |

## What is good

- The mandatory methodological notice (RN05) makes it clear that the risk level **is not a prediction** or a judgment. The API returns this notice in every score response.
- The SRS and B2 treat missing data as missing, without inventing an optimistic value. This is the opposite of a baseless promise.
- The statistical model metrics in the SRS (minimum sensitivity of 0.70, minimum AUC of 0.75) appear as **acceptance criteria**, not as a result already achieved. So they are not a promise.
