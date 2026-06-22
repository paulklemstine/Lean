from __future__ import annotations

def rank_of_apparition(m: int) -> int:
    a, b, k = 0, 1, 0
    while True:
        k += 1
        a, b = b % m, (a + b) % m
        if a == 0:
            return k

def lucas_divisible(p: int, n: int) -> bool:
    """For an odd prime p: does p | L(n)?  Uses only r = alpha(p)."""
    r = rank_of_apparition(p)
    return (2 * n) % r == 0 and n % r != 0
