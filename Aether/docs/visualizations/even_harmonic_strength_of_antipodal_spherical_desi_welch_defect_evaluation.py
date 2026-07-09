from __future__ import annotations
from typing import List, Sequence, Tuple

Vector = Tuple[float, ...]

def dot(x: Sequence[float], y: Sequence[float]) -> float:
    return sum(a * b for a, b in zip(x, y))

def welch_defect(X: Sequence[Vector], n: int) -> float:
    """Return E(X) - |X|^2/n >= 0; zero iff 2 in Hst(X) (Theorem 4.4)."""
    E = sum(dot(x, y) ** 2 for x in X for y in X)
    return E - len(X) ** 2 / n
