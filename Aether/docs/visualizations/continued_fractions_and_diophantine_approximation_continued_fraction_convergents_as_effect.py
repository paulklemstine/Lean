from fractions import Fraction
from typing import Iterator
import math


def continued_fraction_convergents(x: float, n_terms: int) -> Iterator[Fraction]:
    """Yield convergents p_k/q_k of x; each satisfies |x - p_k/q_k| < 1/q_k^2
    with strictly increasing denominators (effective `irrational_den_unbounded`)."""
    p_prev, p_cur = 0, 1
    q_prev, q_cur = 1, 0
    xk: float = x
    for _ in range(n_terms):
        a = math.floor(xk)
        p_prev, p_cur = p_cur, a * p_cur + p_prev
        q_prev, q_cur = q_cur, a * q_cur + q_prev
        yield Fraction(p_cur, q_cur)
        frac = xk - a
        if frac <= 1e-15:
            return
        xk = 1.0 / frac


def good_approx_with_denominator_at_least(x: float, N: int,
                                          max_terms: int = 80) -> Fraction:
    """Return a Dirichlet-good rational p/q with q >= N (Theorem: unbounded denominators)."""
    for c in continued_fraction_convergents(x, max_terms):
        if c.denominator >= N:
            return c
    raise ValueError("increase max_terms")
