from fractions import Fraction
from typing import Dict, List, Tuple

HodgeNumbers = Dict[Tuple[int, int], int]


def _epoly(n: int, h: HodgeNumbers, u: Fraction, v: Fraction) -> Fraction:
    total = Fraction(0)
    for p in range(n + 1):
        for q in range(n + 1):
            sign = -1 if (p + q) % 2 else 1
            total += sign * h.get((p, q), 0) * (u ** p) * (v ** q)
    return total


def _mirror(n: int, h: HodgeNumbers) -> HodgeNumbers:
    return {(p, q): h.get((n - p, q), 0)
            for p in range(n + 1) for q in range(n + 1)
            if h.get((n - p, q), 0)}


def certify_mirror_equation(n: int, h: HodgeNumbers,
                            points: List[Tuple[Fraction, Fraction]]) -> bool:
    """Certify E(mirror X;u,v) = (-1)^n u^n E(X;1/u,v) at sample points.

    A polynomial identity of bidegree <= (2n, 2n) is determined by its values
    at enough generic points.  Complexity O(n^2 * |points|).
    """
    m = _mirror(n, h)
    sign = -1 if n % 2 else 1
    for (u, v) in points:
        if u == 0:
            continue
        lhs = _epoly(n, m, u, v)
        rhs = sign * (u ** n) * _epoly(n, h, 1 / u, v)
        if lhs != rhs:
            return False
    return True


def certify_serre_equation(n: int, h: HodgeNumbers,
                           points: List[Tuple[Fraction, Fraction]]) -> bool:
    """Certify E(X;u,v) = (uv)^n E(X;1/u,1/v) at sample points (Serre dual)."""
    for (u, v) in points:
        if u == 0 or v == 0:
            continue
        if _epoly(n, h, u, v) != ((u * v) ** n) * _epoly(n, h, 1 / u, 1 / v):
            return False
    return True
