from math import sqrt, log, exp

def gen_gap(rad: float, n: int, delta: float) -> float:
    """Rademacher uniform-deviation bound: 2R + 3 sqrt(log(2/delta)/(2n))."""
    return 2.0 * rad + 3.0 * sqrt(log(2.0 / delta) / (2.0 * n))

def mcallester_bound(emp_risk: float, kl: float, n: int, delta: float) -> float:
    """McAllester PAC-Bayes bound."""
    return emp_risk + sqrt((kl + log(2.0 * sqrt(n) / delta)) / (2.0 * (n - 1)))

def catoni_bound(emp_risk: float, kl: float, n: int, delta: float,
                 lam: float) -> float:
    """Catoni PAC-Bayes bound with inverse temperature lam > 0."""
    denom = 1.0 - exp(-lam)
    return (1.0 / denom) * (1.0 - exp(-lam * emp_risk - (kl + log(1.0 / delta)) / n))
