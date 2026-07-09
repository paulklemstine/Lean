from __future__ import annotations
from math import gcd
from typing import Dict, List, Optional, Tuple


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


def order_of_two(p: int) -> int:
    m, v = 1, 2 % p
    while v != 1:
        v = (v * 2) % p
        m += 1
    return m


def synthesize_certificate(
    k: int, period: int, prime_bound: int = 200
) -> Optional[List[Tuple[int, int, int]]]:
    """Greedy synthesizer: try to build a covering certificate of given period.

    For each still-uncovered residue r mod `period`, search small primes p with
    ord_p(2) | period and p | k*2^r + 1; assign p to the whole arithmetic
    progression r mod ord_p(2). The output (if any) is intended to be passed to
    `verify_certificate`, realizing the find/check separation.
    """
    small_primes: List[int] = [p for p in range(3, prime_bound + 1) if is_prime(p)]
    covered: List[bool] = [False] * period
    cert: List[Tuple[int, int, int]] = []
    for r in range(period):
        if covered[r]:
            continue
        chosen: Optional[Tuple[int, int]] = None
        for p in small_primes:
            if period % order_of_two(p) != 0:
                continue
            if (k * pow(2, r, p) + 1) % p == 0:
                chosen = (order_of_two(p), p)
                break
        if chosen is None:
            return None
        m, p = chosen
        cert.append((r % m, m, p))
        for j in range(r % m, period, m):
            covered[j] = True
    return cert if all(covered) else None
