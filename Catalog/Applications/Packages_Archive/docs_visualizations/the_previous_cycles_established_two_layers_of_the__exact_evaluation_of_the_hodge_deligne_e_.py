from __future__ import annotations
from fractions import Fraction
from typing import Dict, Tuple

Diamond = Tuple[int, Dict[Tuple[int, int], int]]  # (n, h[(p,q)])

def epoly(diamond: Diamond, u: Fraction, v: Fraction) -> Fraction:
    """Evaluate E(X; u, v) = sum_{p,q<=n} (-1)^{p+q} h^{p,q} u^p v^q exactly."""
    n, h = diamond
    total: Fraction = Fraction(0)
    for p in range(n + 1):
        for q in range(n + 1):
            c = h.get((p, q), 0)
            if c == 0:
                continue
            sign = -1 if (p + q) % 2 else 1
            total += sign * c * (u ** p) * (v ** q)
    return total

def euler_char(diamond: Diamond) -> int:
    """chi(X) = E(X; 1, 1), computed sign-by-sign over the integers."""
    n, h = diamond
    return sum((-1) ** (p + q) * h.get((p, q), 0)
               for p in range(n + 1) for q in range(n + 1))
