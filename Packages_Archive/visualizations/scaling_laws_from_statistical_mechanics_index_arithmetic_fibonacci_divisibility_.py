from __future__ import annotations

def fib_divides(m: int, n: int) -> bool:
    """Decide F_m | F_n for m >= 3 WITHOUT computing F_n, via fib_dvd_iff:
    F_m | F_n  <=>  m | n.  Cost O(log n) instead of computing an n-digit number."""
    if m < 3:
        raise ValueError("equivalence requires m >= 3")
    return n % m == 0
