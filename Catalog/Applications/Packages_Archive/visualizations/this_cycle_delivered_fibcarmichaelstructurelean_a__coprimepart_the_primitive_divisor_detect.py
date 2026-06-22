from __future__ import annotations

from math import gcd
from typing import Callable, List, Optional


def remove_primes_of(a: int, b: int) -> int:
    """Strip from `a` every prime it shares with `b` by repeatedly dividing out
    gcd(a, b). Returns the largest divisor of `a` coprime to `b` (for a > 0)."""
    if a == 0:
        return 0
    while True:
        g: int = gcd(a, b)
        if g <= 1:
            return a
        a //= g


def coprime_part(u: Callable[[int], int], n: int) -> int:
    """The part of u(n) built only from primitive primes: start from u(n) and strip
    the primes shared with u(d) for every proper divisor d | n. A result > 1
    certifies a primitive prime divisor (Theorem primitive_of_coprimePart_pos)."""
    acc: int = u(n)
    for d in range(1, n):
        if n % d == 0:
            acc = remove_primes_of(acc, u(d))
    return acc


def smallest_prime_factor(m: int) -> int:
    d: int = 2
    while d * d <= m:
        if m % d == 0:
            return d
        d += 1
    return m


def primitive_witness(u: Callable[[int], int], n: int) -> Optional[int]:
    """Return an explicit primitive prime divisor of u(n), or None if the engine
    does not fire (u(n) is barren at this index)."""
    cp: int = coprime_part(u, n)
    return None if cp <= 1 else smallest_prime_factor(cp)


def find_exceptions(u: Callable[[int], int], lo: int, hi: int) -> List[int]:
    """Indices in [lo, hi] where the engine finds no primitive divisor."""
    return [n for n in range(lo, hi + 1) if coprime_part(u, n) <= 1]
