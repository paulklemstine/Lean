from __future__ import annotations


def anti_fib_closed(k: int) -> int:
    """Return A(k) = 1 + k(k-1)//2 in O(1) time (k >= 0)."""
    if k < 0:
        raise ValueError('k must be nonnegative')
    return 1 + k * (k - 1) // 2
