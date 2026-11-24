# MUFASA Privacy Policy

Version 1.0 · 27/10/2026 · **Draft for review by the data protection officer and the university's legal office before publishing.**

The parts in brackets, such as [university name], must be filled in by the institution. Nothing here should be published with open brackets.

---

## 1. In a few words

- MUFASA helps the pedagogical team notice early when a student may need support to continue the course.
- The system shows a **risk level with the reasons**. It decides nothing on its own: whoever decides whether and how to act is always a person from the team.
- Each profile sees only what it needs. Teachers do not see income, work, housing or health.
- Health data only comes in with your specific consent, which you can withdraw whenever you want, without harm.
- You can see, correct and ask for a review of your data at any time.

## 2. Who is responsible for your data

| Role | Who |
|---|---|
| Controller (decides how the data is used) | [university name], CNPJ [number], [address] |
| Data protection officer (your channel for any privacy matter) | [name], [data protection officer's institutional email] |

MUFASA was developed by students of the institution itself, under faculty guidance. During development only **simulated data** is used.

## 3. What data we use, for what and with which legal basis

We use only the data necessary for the purpose of student retention support (LGPD, art. 6, III).

| Category | Examples | What it is for | Legal basis (LGPD) | Who can see it |
|---|---|---|---|---|
| Academic identification | student ID, name, course, semester | Identify you in the follow-up | [art. 7, V or art. 7, IX, to be defined by the data protection officer] | You and the teams in your scope |
| Academic performance | average, attendance, absences, pending activities | Calculate the risk level | Same | You, teachers of your classes, course coordination, support center |
| Socioeconomic context | per capita income, whether you work and how many hours, commute time, aid received | Calculate the risk level and guide support | [art. 7, IX, with a recorded balancing test, or art. 7, I] | You and the support center (values); coordination (only the band: low, medium or high); finance office (income and aid) |
| Health data (sensitive) | declared physical and mental health | Calculate the risk level, **only if you consent** | Art. 11, I (specific and highlighted consent) | You and the support center |
| Support and accessibility (sensitive) | whether you asked for psychosocial support, whether you have an accessibility need | Refer the appropriate support | [art. 11, I or II, to be defined by the data protection officer] | You and the support center |
| Access records | who accessed, when, what, IP address | Security and accountability | Art. 7, II and IX; Marco Civil da Internet, art. 15 | Data protection officer |

### What we do not use

- Race, color, ethnicity, gender, religion, nationality, disability, quota-based admission and neighborhood **do not enter the calculation** of the risk level (SRS, RN21; LGPD, art. 6, IX).
- Neighborhood and age are in the academic record. Age is used only to apply the protection rules for students under 18. Neighborhood is not used in the calculation or shown to the teams.
- We do not use your data for advertising, sale or any commercial purpose.

## 4. How the risk level works

The system turns each factor (grades, attendance, work etc.) into a score from 0 to 100 and takes a weighted average. Factors without data are left out of the calculation, instead of receiving an invented value. Every score comes with the factors that weighed the most.

> The risk level shows that this student's pattern of indicators resembles patterns that tend to come before dropout. It is not a prediction about the person, not a judgment of effort or ability, and it cannot be used in any assessment, selection or benefit decision.

It is forbidden to use the result for selection, merit assessment, granting or denying a benefit, dismissal or ranking. You can ask for a **review** of any result (LGPD, art. 20) through the system itself or with the data protection officer.

## 5. Who we share it with

The data stays inside the university and is only seen by the profiles in the table above. There is no sharing with companies or third parties. [If the university uses a hosting provider, give its name and the country where the data is kept here.]

## 6. How long we keep it

| Data | Period |
|---|---|
| History of risk levels, recommendations and services | During the academic link and 5 more years; after that, irreversible anonymization, keeping only aggregated statistics |
| IP address in access records | 6 months (Marco Civil da Internet, art. 15) |
| Other access records | [period to be defined by the data protection officer] |
| Consents and revocations | While the processing lasts and for the period needed to prove its regularity |

## 7. How we protect it

Measures implemented in the MUFASA back-end:

- passwords kept only as a bcrypt digest; the student ID alone never gives access;
- temporary block after 5 wrong login attempts and a session that expires in 30 minutes;
- permission check on the server on every request, with a record of each access to individual data;
- parameterized database queries, to prevent SQL injection;
- database connection with a least-privilege user and an audit trail that cannot be changed;
- mandatory redirection to HTTPS in production.

No system is immune to incidents. If an incident occurs that may bring relevant risk or damage, the university will notify the National Data Protection Authority (ANPD) and the affected data subjects (LGPD, art. 48).

## 8. Your rights

You can, at any time and at no cost (LGPD, art. 18):

1. confirm whether we process your data and access it;
2. correct incomplete, inaccurate or outdated data;
3. ask for anonymization, blocking or deletion of unnecessary or excessive data;
4. receive your data in a structured format (portability);
5. know who your data is shared with;
6. withdraw consent, when it is the legal basis;
7. ask for a review of results generated automatically (art. 20);
8. object to a processing activity that does not comply with the law.

**How to ask:** in MUFASA itself, in "My data" and "Privacy requests", or through the data protection officer's email. The full answer comes within 15 days (art. 19, II). You can also complain to the ANPD.

## 9. Students under 18

Health and socioeconomic data of students under 18 is processed in the best interest of the student. Consent for health data is given by at least one of the parents or legal guardian (LGPD, art. 14, §1), through a signed form delivered to the registrar's office. Without this consent, health data is not collected and the system works without this factor.

## 10. Cookies

MUFASA uses only storage that is strictly necessary to work. Details in the [Cookie Policy](COOKIE_POLICY.md).

## 11. Changes to this policy

When this policy changes, the new version will have a new number and date and will be shown on the next first access. If the change affects a purpose that depends on consent, we will ask for consent again.
