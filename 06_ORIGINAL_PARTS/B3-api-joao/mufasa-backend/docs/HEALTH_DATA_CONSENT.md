# Consent for health data

Text and flow for the dashboard (F1). Basis: LGPD, arts. 8, 11, I and 14, §1; SRS, Section 4.1 and RN16.

---

## Screen text

> **Do you want to include information about your health in the follow-up?**
>
> If you agree, the support center may consider your answers about your physical and mental health when calculating your risk level and when planning the support that can be offered to you.
>
> - Only you and the support center will see this information. Teachers, coordination and the board will not.
> - This information will never be used to assess, select, grant or deny a benefit.
> - **Refusing causes no harm.** The system works normally without this data.
> - You can change your mind whenever you want, in "Privacy preferences".
>
> ( ) Yes, I agree to include health information
> ( ) I do not agree
>
> [Confirm choice]
>
> Form version: 1.0 · [Privacy Policy]

## Flow rules

1. No option comes checked. The "Confirm" button is only enabled after a choice.
2. The screen is separate from any other acceptance (terms of use, storage notice). Consent "embedded" in another text is not valid (art. 8, §4).
3. The choice is sent to `POST /api/v1/privacy/consents` with `purpose = HEALTH_DATA`, `granted` and `term_version`.
4. Student under 18: the API refuses consent given by the student themselves and explains that the legal guardian's form is delivered to the registrar's office (art. 14, §1).
5. If the text changes, the version changes and consent is asked again.
6. Revoking is always possible, through the same path, with one click.

## Screen accessibility

- Use `<fieldset>` with `<legend>` for the question and `<label>` for each option.
- Error message linked to the group through `aria-describedby` and announced with `role="alert"`.
- Tab order: question, options, confirm, policy link.
- Minimum contrast of 4.5:1 for the text and 3:1 for the border of the controls.
