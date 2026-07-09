from __future__ import annotations
from fractions import Fraction
from typing import Callable, List


def divisors(n: int) -> List[int]:
    """All positive divisors of n (n >= 1), ascending."""
    return [d for d in range(1, n + 1) if n % d == 0]


def omega_weight(a: List[Fraction], m: int) -> Fraction:
    """Euler-transform log-derivative weight omega_m = sum_{d|m} d * a_d."""
    return sum((Fraction(d) * a[d] for d in divisors(m)), Fraction(0))


def polya_tree_recurrence(n_max: int) -> List[Fraction]:
    """Compute a_0 .. a_{n_max} of OEIS A000081 via

        a_1 = 1,
        a_k = (1/(k-1)) * sum_{j=1}^{k-1} a_j * omega_{k-j}   (k >= 2).

    Exact rational arithmetic; every output is an integer.
    Time O(n_max^2) operations; divisor weights cost O(n_max log n_max) overall.
    """
    a: List[Fraction] = [Fraction(0)] * (n_max + 1)
    if n_max >= 1:
        a[1] = Fraction(1)
    for k in range(2, n_max + 1):
        conv = sum(
            (a[j] * omega_weight(a, k - j) for j in range(1, k)),
            Fraction(0),
        )
        a[k] = conv / Fraction(k - 1)
    return a
