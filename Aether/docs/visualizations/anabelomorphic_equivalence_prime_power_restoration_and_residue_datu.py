from __future__ import annotations
from typing import Tuple


def prime_power_decompose(q: int) -> Tuple[int, int]:
    """Given a prime power q = p^f, recover the unique (p, f).

    Raises ValueError if q is not a prime power. This realises Lemma 4.1
    (prime-power rigidity): the base and exponent of a prime power are
    uniquely determined, which is the arithmetic engine of the Rigidity
    Theorem. Complexity O(sqrt(q)) for finding the smallest prime factor,
    then O(log q) for the exponent.
    """
    if q < 2:
        raise ValueError("q must be >= 2")
    # smallest prime factor is the base p
    d = 2
    p = None
    while d * d <= q:
        if q % d == 0:
            p = d
            break
        d += 1
    if p is None:
        p = q  # q itself is prime
    # extract exponent
    f = 0
    n = q
    while n % p == 0:
        n //= p
        f += 1
    if n != 1:
        raise ValueError(f"{q} is not a prime power")
    return p, f


def recover_residue_datum(torus_order: int) -> Tuple[int, int]:
    """Given the residue-torus order m = p^f - 1, recover (p, f) by
    restoring the prime power m + 1 = p^f and decomposing it."""
    return prime_power_decompose(torus_order + 1)
