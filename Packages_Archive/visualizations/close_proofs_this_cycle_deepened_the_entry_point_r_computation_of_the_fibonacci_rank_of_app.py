from __future__ import annotations

def rank_of_apparition(m: int) -> int:
    """Least k > 0 with m | F(k). Exists for all m > 0 (pigeonhole)."""
    if m <= 0:
        raise ValueError('rank_of_apparition requires m > 0')
    a, b, k = 0, 1, 0
    while True:
        k += 1
        a, b = b % m, (a + b) % m
        if a == 0:
            return k
