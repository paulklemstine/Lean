from __future__ import annotations

def anti_fibonacci(n: int) -> int:
    """Evaluate A(n) exactly."""
    if n < 0:
        raise ValueError("n must be nonnegative")
    return 1 + n * (n - 1) // 2
