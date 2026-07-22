from __future__ import annotations

def anti_fib_value(n: int) -> int:
    """A(n) = 1 + n(n-1)/2 evaluated in O(1)."""
    return 1 + n * (n - 1) // 2

def anti_fib_partial_sum(n: int) -> int:
    """sum_{k=0}^{n} A(k) = (n^3 + 5n + 6)/6 evaluated in O(1)."""
    return (n ** 3 + 5 * n + 6) // 6
