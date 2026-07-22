from __future__ import annotations


def radical_generator(n: int) -> int:
    """Galois closure c = vanishingIdeal . zeroLocus on a PID generator.

    Returns the squarefree part of n, which generates the radical sqrt((n)).
    Complexity: O(sqrt(n)) trial division (polynomial in the value; for big
    inputs replace by a factorization oracle).
    """
    n = abs(n)
    if n in (0, 1):
        return n
    result, d, m, seen = 1, 2, n, set()
    while d * d <= m:
        while m % d == 0:
            if d not in seen:
                result *= d
                seen.add(d)
            m //= d
        d += 1
    if m > 1 and m not in seen:
        result *= m
    return result


def is_radical_ideal(n: int) -> bool:
    """Fixed-point test: (n) is radical iff radical_generator(n) == n."""
    return radical_generator(n) == n
