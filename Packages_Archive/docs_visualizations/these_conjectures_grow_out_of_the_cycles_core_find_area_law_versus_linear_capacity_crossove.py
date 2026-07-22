from __future__ import annotations
from math import inf


def crossover_analysis(c: float, ell: float, m: float) -> dict:
    """Analyze area-law capacity c*m^2 against a linear budget L*m at mass m.

    By the crossover theorem, L*m <= c*m^2 iff m == 0 or m >= L/c.  The crossover
    mass m* = L/c is the sharp phase boundary between the budget-limited regime
    (m < m*) and the enumeration-limited regime (m > m*).  Above it the linear
    budget is a vanishing fraction (L/c)/m of the quadratic capacity.

    Complexity: O(1).
    """
    if c <= 0:
        raise ValueError("c must be positive")
    if m < 0:
        raise ValueError("mass must be nonnegative")
    m_star = ell / c
    dominates = ell * m <= c * m * m
    ratio = (ell * m) / (c * m * m) if m > 0 else inf
    regime = "enumeration-limited" if (m > m_star) else "budget-limited"
    return {
        "crossover_mass": m_star,
        "area_law_dominates": dominates,
        "linear_over_quadratic": ratio,
        "regime": regime,
    }
