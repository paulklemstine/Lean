from __future__ import annotations


def pisano_period(m: int) -> int:
    """Least d > 0 with (F(d), F(d+1)) == (0, 1) mod m. Pure period; entry(m)|pi(m)."""
    if m <= 0:
        raise ValueError("Pisano period is defined for m > 0")
    if m == 1:
        return 1
    a, b = 0, 1
    for d in range(1, m * m + 2):
        a, b = b, (a + b) % m
        if a == 0 and b == 1:
            return d
    raise RuntimeError("unreachable")


def divides_fib(m: int, k: int) -> bool:
    """True iff m | F(k), decided via the entry point (law of apparition)."""
    def fib_entry(mm: int) -> int:
        if mm == 1:
            return 1
        a, b = 0 % mm, 1 % mm
        for j in range(1, mm * mm + 2):
            a, b = b, (a + b) % mm
            if a == 0:
                return j
        raise RuntimeError("unreachable")
    return k % fib_entry(m) == 0
