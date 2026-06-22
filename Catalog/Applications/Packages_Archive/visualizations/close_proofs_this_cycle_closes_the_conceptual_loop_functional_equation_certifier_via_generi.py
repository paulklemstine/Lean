from fractions import Fraction
from typing import Dict, Tuple

HodgeNumbers = Dict[Tuple[int, int], int]

def _epoly(n: int, h: HodgeNumbers, u: Fraction, v: Fraction) -> Fraction:
    return sum((-1 if (p + q) % 2 else 1) * h.get((p, q), 0) * u ** p * v ** q
               for p in range(n + 1) for q in range(n + 1))

def _mirror(n: int, h: HodgeNumbers) -> HodgeNumbers:
    return {(p, q): h.get((n - p, q), 0)
            for p in range(n + 1) for q in range(n + 1)}

def certify_mirror(n: int, h: HodgeNumbers) -> bool:
    hm = _mirror(n, h)
    pts = [Fraction(k) for k in range(1, 2 * n + 2)]
    for u in pts:
        for v in pts:
            if _epoly(n, hm, u, v) != (-1) ** n * u ** n * _epoly(n, h, 1 / u, v):
                return False
    return True

def certify_serre(n: int, h: HodgeNumbers) -> bool:
    if any(h.get((p, q), 0) != h.get((n - p, n - q), 0)
           for p in range(n + 1) for q in range(n + 1)):
        return False
    pts = [Fraction(k) for k in range(1, 2 * n + 2)]
    for u in pts:
        for v in pts:
            if _epoly(n, h, u, v) != (u * v) ** n * _epoly(n, h, 1 / u, 1 / v):
                return False
    return True
