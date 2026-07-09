from __future__ import annotations

from fractions import Fraction
from typing import Iterator


def convergent_integer_forms(x_exact: Fraction, n_terms: int
                             ) -> Iterator[tuple[int, int, Fraction]]:
    """Construct integer linear forms a_n + b_n*x from continued-fraction
    convergents p_n/q_n of x, via a_n = -p_n, b_n = q_n.

    Each form equals q_n*(x - p_n/q_n); since convergents satisfy the Dirichlet
    bound |x - p_n/q_n| < 1/q_n^2, the form has |a_n + b_n*x| < 1/q_n -> 0, and
    it is nonzero whenever x is irrational.  This realizes the witness used in
    the (=>) direction of the characterization theorem.

    Complexity: O(n_terms) big-integer Euclidean-style steps; the n-th
    convergent's denominator grows at least like the Fibonacci numbers, so the
    forms decay at least geometrically.
    """
    p2, p1, q2, q1 = 0, 1, 1, 0   # p_{-2},p_{-1},q_{-2},q_{-1}
    frac = x_exact
    for _ in range(n_terms):
        a = frac.numerator // frac.denominator
        p2, p1 = p1, a * p1 + p2
        q2, q1 = q1, a * q1 + q2
        form = -p1 + q1 * x_exact
        yield -p1, q1, form
        rem = frac - a
        if rem == 0:
            break
        frac = 1 / rem
