from __future__ import annotations
from fractions import Fraction
from typing import Dict, List, Tuple

Diamond = Tuple[int, Dict[Tuple[int, int], int]]

def mirror(diamond: Diamond) -> Diamond:
    """Mirror involution (p,q) -> (n-p, q) on Hodge numbers."""
    n, h = diamond
    return (n, {(p, q): h.get((n - p, q), 0)
                for p in range(n + 1) for q in range(n + 1)})

def epoly(diamond: Diamond, u: Fraction, v: Fraction) -> Fraction:
    n, h = diamond
    s = Fraction(0)
    for p in range(n + 1):
        for q in range(n + 1):
            c = h.get((p, q), 0)
            if c:
                s += (-1 if (p + q) % 2 else 1) * c * (u ** p) * (v ** q)
    return s

def verify_mirror_equation(diamond: Diamond,
                           pts: List[Tuple[Fraction, Fraction]]) -> bool:
    """Check E(mirror X; u, v) == (-1)^n u^n E(X; 1/u, v) at sample points."""
    n, _ = diamond
    mx = mirror(diamond)
    for u, v in pts:
        if u == 0:
            continue
        lhs = epoly(mx, u, v)
        rhs = ((-1) ** n) * (u ** n) * epoly(diamond, 1 / u, v)
        if lhs != rhs:
            return False
    return True
