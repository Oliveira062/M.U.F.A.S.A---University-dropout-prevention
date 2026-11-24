from dataclasses import dataclass, field

CATALOG = {
    "WEIGHT_I1_PERFORMANCE":   (0.20, "fraction", 0, 1, False, "Weight of academic performance (I1)."),
    "WEIGHT_I2_ATTENDANCE":   (0.18, "fraction", 0, 1, False, "Weight of attendance (I2)."),
    "WEIGHT_I3_FAILURE":   (0.09, "fraction", 0, 1, False, "Weight of the accumulated failure rate (I3)."),
    "WEIGHT_I4_LMS":          (0.08, "fraction", 0, 1, False, "Weight of engagement in the LMS (I4)."),
    "WEIGHT_I5_FINANCE":   (0.11, "fraction", 0, 1, False, "Weight of the financial situation (I5)."),
    "WEIGHT_I6_WORK":     (0.07, "fraction", 0, 1, False, "Weight of work (I6)."),
    "WEIGHT_I7_COMMUTE": (0.05, "fraction", 0, 1, False, "Weight of commute (I7)."),
    "WEIGHT_I8_MENTAL_HEALTH": (0.08, "fraction", 0, 1, False, "Weight of mental health (I8)."),
    "WEIGHT_I9_PHYSICAL_HEALTH": (0.05, "fraction", 0, 1, False, "Weight of physical health (I9)."),
    "WEIGHT_I10_HOUSING":     (0.05, "fraction", 0, 1, False, "Weight of housing (I10)."),
    "WEIGHT_I11_DEPENDENTS": (0.04, "fraction", 0, 1, False, "Weight of dependents under care (I11)."),
    "MINIMUM_GRADE":          (6.0, "grade 0 to 10", 0, 10, True, "Minimum passing grade. Institutional autonomy (CF art. 207; LDB art. 53)."),
    "COMFORTABLE_GRADE":     (8.0, "grade 0 to 10", 0, 10, True, "Grade from which performance does not generate risk."),
    "CRITICAL_GRADE":         (4.0, "grade 0 to 10", 0, 10, True, "Grade below which the I1 curve enters the last segment."),
    "MINIMUM_ATTENDANCE":    (75.0, "%", 0, 100, True, "Minimum attendance to pass (LDB art. 47, §3; regulatory practice of 75%)."),
    "COMFORTABLE_ATTENDANCE": (90.0, "%", 0, 100, True, "Attendance from which there is no risk."),
    "CRITICAL_ATTENDANCE":   (60.0, "%", 0, 100, True, "Attendance below which the I2 curve enters the last segment."),
    "INCOME_EXTREME":        (0.25, "MW per person", 0, 10, True, "Up to this value: extreme vulnerability (I5 = 100)."),
    "INCOME_VULNERABLE":     (0.5, "MW per person", 0, 10, True, "CadÚnico low-income cutoff (Decree No. 6,135/2007)."),
    "INCOME_ONE_MW":          (1.0, "MW per person", 0, 10, True, "Below one minimum wage per person."),
    "INCOME_AID":        (1.5, "MW per person", 0, 10, True, "PNAES priority ceiling (Decree No. 7,234/2010, art. 5)."),
    "MINIMUM_WAGE":       (1621.0, "reais", 1000, 10000, True, "Current national minimum wage (R$ 1,621.00 in 2026). Update with each annual decree."),
    "WORK_HOURS_LIMIT":       (20.0, "hours per week", 0, 80, True, "Working hours above which work competes with study (Law No. 11,788/2008 as reference)."),
    "COMMUTE_LIMIT":  (60.0, "minutes per trip", 0, 300, True, "Reference commute per trip (IBGE bands)."),
    "LMS_DAYS_WITHOUT_ACCESS":  (21.0, "days", 1, 90, True, "Days without LMS access that take I4 to 100 (Astin, 1984)."),
    "LOW_CUTOFF":          (25.0, "points", 0, 100, True, "Score up to this value: Low level."),
    "MODERATE_CUTOFF":       (50.0, "points", 0, 100, True, "Score up to this value: Moderate level."),
    "HIGH_CUTOFF":           (75.0, "points", 0, 100, True, "Score up to this value: High level; above it, Critical."),
    "MINIMUM_COMPLETENESS":    (40.0, "% of the weights", 0, 100, True, "Below this the level is Undetermined (RN01)."),
    "FULL_COMPLETENESS":     (70.0, "% of the weights", 0, 100, True, "Below this the score is partial and only reaches Critical by overlap."),
    "SLA_CRITICAL_HOURS":    (48.0, "hours", 12, 168, True, "Deadline for the first service of a Critical alert."),
    "SLA_HIGH_BUSINESS_DAYS":  (5.0, "business days", 1, 15, True, "Deadline for the first service of a High alert (Saturday and Sunday do not count; holidays are not registered)."),
    "SLA_DATA_BUSINESS_DAYS": (10.0, "business days", 1, 30, True, "Deadline for the data correction task of an Undetermined student."),
    "GROUP_MINIMUM":         (5.0, "students", 3, 50, True, "Smaller groups are suppressed in aggregates (RN07, CA19)."),
    "SERVICE_INTERVAL": (15.0, "days", 1, 60, True, "Minimum interval between services (RN14)."),
    "OWNER_ALERT_CEILING": (30.0, "alerts", 1, 500, True, "Limit of open alerts per owner (value to be confirmed in Sprint 1)."),
}

WEIGHTS_BY_FACTOR = {
    "grades": "WEIGHT_I1_PERFORMANCE", "attendance": "WEIGHT_I2_ATTENDANCE", "failure": "WEIGHT_I3_FAILURE",
    "lms_engagement": "WEIGHT_I4_LMS", "finance": "WEIGHT_I5_FINANCE", "work": "WEIGHT_I6_WORK",
    "commute": "WEIGHT_I7_COMMUTE", "mental_health": "WEIGHT_I8_MENTAL_HEALTH",
    "physical_health": "WEIGHT_I9_PHYSICAL_HEALTH", "housing": "WEIGHT_I10_HOUSING", "dependents": "WEIGHT_I11_DEPENDENTS",
}

CONSISTENCY_RULES = (
    ("CRITICAL_GRADE", "MINIMUM_GRADE", "COMFORTABLE_GRADE"),
    ("CRITICAL_ATTENDANCE", "MINIMUM_ATTENDANCE", "COMFORTABLE_ATTENDANCE"),
    ("INCOME_EXTREME", "INCOME_VULNERABLE", "INCOME_ONE_MW", "INCOME_AID"),
    ("LOW_CUTOFF", "MODERATE_CUTOFF", "HIGH_CUTOFF"),
    ("MINIMUM_COMPLETENESS", "FULL_COMPLETENESS"),
)


def consistency_problems(values: dict) -> list[str]:
    problems = []
    for sequence in CONSISTENCY_RULES:
        numbers = [float(values[c]) for c in sequence]
        if any(a >= b for a, b in zip(numbers, numbers[1:])):
            problems.append(" < ".join(sequence) + " must be strictly increasing.")
    total_sum = sum(float(values[c]) for c in WEIGHTS_BY_FACTOR.values())
    if abs(total_sum - 1.0) > 1e-6:
        problems.append(f"The weights must add up to 1.00 (they add up to {total_sum:.2f}).")
    return problems


@dataclass(frozen=True)
class Parameters:
    values: dict = field(default_factory=lambda: {k: v[0] for k, v in CATALOG.items()})
    version: int = 0

    def __getitem__(self, key: str) -> float:
        return float(self.values[key])

    @property
    def version_label(self) -> str:
        return f"param-v{self.version}" if self.version else "srs-default-param-1.1"

    def weight(self, factor: str) -> float:
        return self[WEIGHTS_BY_FACTOR[factor]]

    def with_values(self, **changes) -> "Parameters":
        return Parameters({**self.values, **changes}, self.version)


DEFAULT = Parameters()
