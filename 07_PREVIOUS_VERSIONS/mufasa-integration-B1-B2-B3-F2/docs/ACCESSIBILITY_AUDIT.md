# Accessibility Audit — MUFASA

27/10/2026 · Reference: WCAG 2.1 level AA (required by the SRS, Section 3.1) and RN10 (accessible language).

## Scope and limit

There is no dashboard (F1) or chatbot (F2) yet. This audit covers what already exists and reaches the end user: **the texts the API returns** (error messages, score explanation, recommendations, methodological notice) and the `docs/storage-notice.html` component. For the dashboard, there is a checklist at the end, to be applied by F1 and checked by F3.

## Findings

| # | Severity | Where | Problem | Criterion | Status |
|---|---|---|---|---|---|
| A-1 | High | B2, `score.py`: `RECOMMENDATIONS`, `LABELS` and `explain_score` | Texts without accents ("nivel", "frequencia", "saude", "ate"). A screen reader pronounces them wrong ("saúde" becomes "sáude"), and the text looks like a mistake to whoever reads it | WCAG 3.1 (readable), RN10 | **Suggestion for B2**, below |
| A-2 | Medium | B2, `score.py`, line 451 | "1 absences remain" | RN10 | Suggestion for B2 |
| A-3 | Medium | B2, `explain_score` | "Score 66 out of 100" uses an English term for people outside the technical area | WCAG 3.1.3 (unusual words), RN10 | Suggestion: "Risk score: 66 out of 100" |
| A-4 | Medium | API input validation | Raw technical Pydantic messages ("String should have at least 3 characters") | WCAG 3.3.1 and 3.3.3 | **Fixed in B3**: messages written for the user in `app/api/errors.py` |
| A-5 | Medium | B3 error messages | Written without accents in the first version | WCAG 3.1, RN10 | **Fixed in B3** |
| A-6 | Medium | 30-minute session | Expiring without warning takes away what the user was doing, which weighs more for people who use a screen reader or type slowly | WCAG 2.2.1 (timing adjustable) | Pending: the dashboard should warn at 25 minutes with an option to continue; B3 needs a `POST /auth/renew` |
| A-7 | Low | Risk level | The API returns the level as text (`HIGH`), never only as a color or a number, which allows the dashboard to follow the SRS rule "never by color alone" | WCAG 1.4.1 | Met in B3; F1 must show a label and an icon next to the color |
| A-8 | Low | Login block | The message says how many attempts lead to the block and how long it lasts, and the 429 response carries `Retry-After` | WCAG 3.3.1 and 3.3.3 | Met in B3 |

### Suggested fix for B2 (A-1, A-2, A-3)

```python
RECOMMENDATIONS = {
    "LOW": "Periodic monitoring.",
    "MODERATE": "Preventive attention from tutoring.",
    "HIGH": "Contact within 5 business days.",
    "CRITICAL": "Immediate active outreach by coordination and the support center, within 48 hours.",
    "UNDETERMINED": "Not enough data to assess. Complete the record before classifying.",
}

LABELS = {
    "grades": "academic performance", "attendance": "attendance", "finance": "financial situation",
    "failure": "failure history", "lms_engagement": "participation in the virtual environment",
    "mental_health": "mental health", "work": "working hours", "commute": "commute time",
    "physical_health": "physical health", "housing": "housing situation", "dependents": "dependents under care",
}

# in explain_score:
text = f"Risk score: {result['score']} out of 100. {LEVEL_NAMES[result['level']]} level. "
...
if remaining == 1:
    text += " 1 absence remains before the limit."
elif remaining:
    text += f" {remaining} absences remain before the limit."
```

The codes (`CRITICAL`, `mental_health`) stay without accents: they are identifiers. Only the text shown to people changes. B2's `test_output_contract_has_all_keys` test is not affected, because the keys do not change.

## `storage-notice.html` component

Checked against WCAG 2.1 AA:

| Criterion | How the component meets it |
|---|---|
| 1.3.1 Info and relationships | `role="region"` with `aria-labelledby`; future options in `fieldset`/`legend` with a `label` on each box |
| 1.4.3 Contrast (text) | Light theme: text 17.4:1, link and button 8.4:1. Dark theme: text 15.2:1, button 10.6:1 |
| 1.4.11 Contrast (non-text) | Borders 6.7:1 (light) and 7.0:1 (dark); focus ring 4.8:1 and 9.7:1 |
| 1.4.4 and 1.4.10 Zoom and reflow | Relative units, line wrapping on the buttons, works at 320 px |
| 2.1.1 Keyboard | Everything is a native `button` or link; Esc closes the informative notice |
| 2.4.3 Focus order | Focus goes to the first button on opening and back to the previous element on closing |
| 2.4.7 Focus visible | `:focus-visible` with a 3 px outline |
| 2.5.5 Target size (AAA, adopted) | Buttons of at least 44 × 44 px |
| 2.3.3 Motion | Respects `prefers-reduced-motion` |
| 3.1.1 Language | `lang="en"` |

## Checklist for the dashboard (F1) and the chatbot (F2)

Apply on each screen before considering the task done:

- [ ] `lang="en"` on the page; headings (`h1`, `h2`) in order, without skipping a level
- [ ] Every form field with a visible `<label>`; error linked to the field through `aria-describedby`
- [ ] Risk level with a text label and an icon, besides the color
- [ ] Contrast of 4.5:1 for text and 3:1 for borders, icons and charts (check with the Colour Contrast Analyser)
- [ ] Everything operable by keyboard only, with visible focus and no focus trap
- [ ] Charts with an equivalent table or alternative text that brings the numbers
- [ ] Student tables with `<th scope="col">` and `<caption>`
- [ ] Session expiring warning with at least 20 seconds to respond (WCAG 2.2.1)
- [ ] Chatbot answers in an `aria-live="polite"` region
- [ ] 200% zoom without losing content or creating horizontal scrolling
- [ ] Real test with NVDA (Windows) or VoiceOver (macOS/iOS), besides an automatic tool (axe DevTools or Lighthouse). An automatic tool alone finds only part of the problems.
- [ ] Plain language: short sentences, no acronym without explanation, no technical jargon for the student
