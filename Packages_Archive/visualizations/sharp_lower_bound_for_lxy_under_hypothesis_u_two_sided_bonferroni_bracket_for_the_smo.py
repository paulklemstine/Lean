from __future__ import annotations
from typing import List, Tuple


def is_prime(n: int) -> bool:
    if n < 2:
        return False
    if n % 2 == 0:
        return n == 2
    d = 3
    while d * d <= n:
        if n % d == 0:
            return False
        d += 2
    return True


def large_primes(x: int, y: int) -> List[int]:
    return [p for p in range(y + 1, x + 1) if is_prime(p)]


def bonferroni_bracket(x: int, y: int) -> Tuple[int, int]:
    """Two-sided Bonferroni bracket for L(x, y).

    Returns (lower, upper) with
        lower = x - sum_p floor(x/p),
        upper = lower + sum_{p<q} floor(x/(p*q)),
    sums over primes p, q in (y, x].  By the Bonferroni inequalities the true
    smooth count L(x, y) satisfies  lower <= L(x, y) <= upper.  When no
    integer <= x carries two distinct large primes the correction term is 0
    and the bracket collapses to the exact value.

    Complexity: O(m) for the lower bound and O(m^2) for the pair correction,
    where m = pi(x) - pi(y) is the number of large primes.
    """
    ps = large_primes(x, y)
    contribution = sum(x // p for p in ps)
    lower = max(0, x - contribution)
    correction = 0
    for i, p in enumerate(ps):
        for q in ps[i + 1:]:
            correction += x // (p * q)
    upper = x - contribution + correction
    return lower, upper
