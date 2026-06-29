from __future__ import annotations


def clog(base: int, n: int) -> int:
    """Least k with n <= base**k; 0 if base <= 1 or n <= 1."""
    if base <= 1 or n <= 1:
        return 0
    k: int = 0
    power: int = 1
    while power < n:
        power *= base
        k += 1
    return k


def min_distinguishing_depth(card: int) -> int:
    """Exact number of Boolean observations to distinguish `card` elements."""
    return clog(2, card)
