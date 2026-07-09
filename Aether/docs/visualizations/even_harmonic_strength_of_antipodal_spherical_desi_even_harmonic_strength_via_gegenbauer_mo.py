from __future__ import annotations
from typing import List, Sequence, Tuple

Vector = Tuple[float, ...]

def gegenbauer(k: int, t: float, n: int) -> float:
    lam = (n - 2) / 2.0
    if k == 0:
        return 1.0
    if k == 1:
        return 2.0 * lam * t
    c0, c1 = 1.0, 2.0 * lam * t
    for m in range(2, k + 1):
        c2 = (2.0 * (m - 1 + lam) * t * c1 - (m - 2 + 2 * lam) * c0) / m
        c0, c1 = c1, c2
    return c1

def dot(x: Sequence[float], y: Sequence[float]) -> float:
    return sum(a * b for a, b in zip(x, y))

def even_harmonic_strength(X: Sequence[Vector], n: int, kmax: int,
                           tol: float = 1e-6) -> List[int]:
    """Return the even degrees k <= kmax with vanishing Gegenbauer moment."""
    out: List[int] = []
    for k in range(2, kmax + 1, 2):
        q = sum(gegenbauer(k, dot(x, y), n) for x in X for y in X)
        if abs(q) <= tol:
            out.append(k)
    return out
