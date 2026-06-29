from fractions import Fraction
from typing import Callable


def epoly(n: int, h: Callable[[int, int], int], u: Fraction, v: Fraction) -> Fraction:
    """Evaluate E(X; u, v) = sum_{0<=p,q<=n} (-1)^{p+q} h(p,q) u^p v^q."""
    total = Fraction(0)
    for p in range(n + 1):
        for q in range(n + 1):
            total += Fraction((-1) ** (p + q) * h(p, q)) * u ** p * v ** q
    return total
