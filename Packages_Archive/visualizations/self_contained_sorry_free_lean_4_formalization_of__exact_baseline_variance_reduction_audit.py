from typing import List

def variance_reduction_audit(pi: List[float], R: List[float], s: List[float], b: float) -> float:
    """Report the exact excess second moment of a baseline b above the optimum:
    M(b) - M(b*) = A (b - b*)^2, with A = E_pi[s^2], b* = E_pi[R s^2]/E_pi[s^2].

    This is the variance an operator is leaving on the table by using b instead
    of the optimal baseline. Returns a nonnegative number; 0 iff b == b*."""
    A = sum(p * si * si for p, si in zip(pi, s))
    B = sum(p * Ri * si * si for p, Ri, si in zip(pi, R, s))
    b_star = B / A
    return A * (b - b_star) ** 2
