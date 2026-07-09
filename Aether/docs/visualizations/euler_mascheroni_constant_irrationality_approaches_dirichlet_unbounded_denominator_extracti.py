from __future__ import annotations

from fractions import Fraction
from typing import Iterator


def dirichlet_unbounded_denominator(x_exact: Fraction, threshold: int,
                                    max_terms: int = 200) -> Fraction:
    """Extract a good rational approximation q = c/d of x with d >= threshold and
    |x - q| < 1/d^2, by walking the continued-fraction convergents until the
    denominator exceeds the threshold.

    This realizes EMR.exists_rat_mem_den_ge: for an irrational x the set of such
    good approximations is infinite, hence denominators are unbounded, so a
    convergent with d >= threshold always exists.

    Complexity: O(max_terms) big-integer steps; terminates well before max_terms
    because denominators grow at least geometrically.
    """
    p2, p1, q2, q1 = 0, 1, 1, 0
    frac = x_exact
    for _ in range(max_terms):
        a = frac.numerator // frac.denominator
        p2, p1 = p1, a * p1 + p2
        q2, q1 = q1, a * q1 + q2
        cand = Fraction(p1, q1)
        d = cand.denominator
        if d >= threshold and abs(x_exact - cand) < Fraction(1, d ** 2):
            return cand
        rem = frac - a
        if rem == 0:
            break
        frac = 1 / rem
    raise RuntimeError("no convergent with sufficiently large denominator found")


def chained_forms_to_zero(x_exact: Fraction, n_terms: int
                          ) -> Iterator[tuple[int, int, Fraction]]:
    """Chain dirichlet_unbounded_denominator at thresholds N = n+1 to produce
    forms with |a_n + b_n*x| < 1/(n+1), the explicit squeeze used in the
    converse direction of the characterization theorem."""
    for n in range(n_terms):
        q = dirichlet_unbounded_denominator(x_exact, n + 1)
        a, b = -q.numerator, q.denominator
        yield a, b, a + b * x_exact
