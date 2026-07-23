from __future__ import annotations

def period_powersum(n: int) -> int:
    a, b = 2, 1  # L0, L1
    for _ in range(n):
        a, b = b, a + b
    return ((-1) ** n) * a

def period_diffsq(n: int) -> int:
    a, b = 0, 1  # F0, F1
    for _ in range(n):
        a, b = b, a + b
    return 5 * a * a
