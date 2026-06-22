from typing import Callable

def euler_char(n: int, h: Callable[[int, int], int]) -> int:
    """Alternating double sum  sum_{p,q=0}^{n} (-1)^{p+q} h(p,q).

    Complexity: O((n+1)^2) integer operations. For n = 4 this is 25 signed
    additions and is used as the exact oracle against the closed-form formula
    chi = 4 + 2h11 + 2h31 + h22 - 4h21.
    """
    total = 0
    for p in range(n + 1):
        for q in range(n + 1):
            total += (-1) ** (p + q) * h(p, q)
    return total

def mirror(n: int, h: Callable[[int, int], int]) -> Callable[[int, int], int]:
    """Mirror reflection of the first Hodge index: p -> n - p."""
    return lambda p, q: h(n - p, q) if n - p >= 0 else 0
