from __future__ import annotations
from typing import List


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


def prime_contribution(x: int, y: int) -> int:
    return sum(x // p for p in large_primes(x, y))


def certify_density_floor(x: int, y: int, alpha: float) -> bool:
    """Certify L(x, y) >= alpha * x by verifying Hypothesis U.

    Sets the target c = ceil(alpha * x) and checks Hypothesis U,
        prime_contribution(x, y) + c <= x.
    If it holds, Theorem (L_lower_under_U) guarantees c <= L(x, y), hence the
    density floor L(x, y)/x >= alpha is certified WITHOUT enumerating the
    smooth integers themselves -- only the primes in (y, x] are needed.

    Returns True iff the density floor is certified by Hypothesis U.
    Complexity: O(pi(x) - pi(y)) once the large primes are listed.
    """
    import math
    c = math.ceil(alpha * x)
    return prime_contribution(x, y) + c <= x
