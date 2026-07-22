from __future__ import annotations
from math import log, exp


def max_admissible_window(eps: float, c: float, q0: int) -> float:
    """Largest conductor M for which repulsion constant C guarantees uniqueness.

    Solving C > 2 * Q0^(-eps) * log(M) for M gives M < exp(C / (2 * Q0^(-eps))).
    Returns that supremum. Complexity O(1)."""
    if not (eps > 0.0 and q0 >= 2 and c > 0.0):
        raise ValueError("require eps > 0, Q0 >= 2, C > 0")
    return exp(c / (2.0 * (float(q0) ** (-eps))))


def required_constant(eps: float, q0: int, m: int) -> float:
    """Smallest repulsion constant C guaranteeing uniqueness on [Q0, M]."""
    return 2.0 * (float(q0) ** (-eps)) * log(float(m))
