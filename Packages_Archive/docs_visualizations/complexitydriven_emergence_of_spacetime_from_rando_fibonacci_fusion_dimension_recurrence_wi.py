from typing import Tuple

def fusion_dimension_with_gap(n: int) -> Tuple[int, int]:
    """Return (fc(n), 2**n - fc(n)); fc(n) == fib(n+2)."""
    if n == 0:
        return 1, 2 ** 0 - 1
    if n == 1:
        return 2, 2 ** 1 - 2
    a, b = 1, 2
    for _ in range(n - 1):
        a, b = b, a + b
    return b, 2 ** n - b
