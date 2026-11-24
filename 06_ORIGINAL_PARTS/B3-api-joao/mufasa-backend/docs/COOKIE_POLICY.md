# MUFASA Cookie and Consent Policy

Version 1.0 · 27/10/2026 · Reference: ANPD Guidance on Cookies and Personal Data Protection (2022) and LGPD, arts. 7, 8 and 9.

---

## 1. What MUFASA keeps in your browser

| Name | Type | What it is for | Duration | Needs consent? |
|---|---|---|---|---|
| Session token | Tab memory (not a cookie) | Keep you signed in while you use the system | Up to 30 minutes or until the tab is closed | No: strictly necessary |
| `mufasa_storage_notice` | `localStorage` | Remember that you have already seen this notice | 12 months | No: strictly necessary |

**MUFASA does not use** advertising, tracking, social media or third-party analytics cookies. The API writes no cookie at all: the login travels in the `Authorization` header of each request.

## 2. Why there is no "accept all" button

Consent is only required for storage that is not necessary for operation. Since MUFASA uses only what is strictly necessary, the notice is informative, with a "Got it" button and the link to this policy. Asking to "accept" something that cannot be refused would give a false impression of choice.

## 3. If one day the dashboard includes something optional

Any analytics tool or third-party resource can only come in if:

1. it is listed in this policy, with name, purpose, duration and provider;
2. it stays **off by default**, loading only after consent;
3. the notice shows "Accept" and "Refuse" with the same prominence, with no pre-checked box;
4. the choice can be changed at any time in "Privacy preferences", as easily as it was given;
5. the consent is recorded with the date and version of this policy.

The `docs/storage-notice.html` component already follows these rules: just add the category to the `OPTIONAL_CATEGORIES` list.

## 4. Guidance for the dashboard (F1)

- Keep the token **in memory** (a JavaScript variable or Streamlit state), not in `localStorage` or in a cookie. This way an injected script cannot read a saved token, and there is no cookie for a CSRF attack to use.
- Do not load fonts, icons or scripts from third-party CDNs in production: each CDN receives the IP of whoever accesses. Serve everything from your own domain.
- Do not include a social media pixel or a heat map tool.

## 5. Consent for health data

This is another consent, unrelated to cookies. It is the specific and highlighted consent to use health data in the calculation (LGPD, art. 11, I). The text and the flow are in [HEALTH_DATA_CONSENT.md](HEALTH_DATA_CONSENT.md), and the API records each grant and revocation at `POST /api/v1/privacy/consents`.
