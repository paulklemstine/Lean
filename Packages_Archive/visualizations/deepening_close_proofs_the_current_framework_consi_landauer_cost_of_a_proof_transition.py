from __future__ import annotations
import math
from typing import Sequence

def neg_mul_log(x: float) -> float:
    return 0.0 if x <= 0.0 else -x * math.log(x)

def entropy(p: Sequence[float]) -> float:
    return sum(neg_mul_log(px) for px in p)

def landauer_cost(T: float, p: Sequence[float], q: Sequence[float]) -> float:
    """Thermodynamic cost of the proof p ~> q at temperature T: T*(H(p)-H(q)). O(n)."""
    return T * (entropy(p) - entropy(q))

def point_mass(n: int, a: int) -> list[float]:
    """Determined (proven) belief state concentrated on answer a."""
    return [1.0 if x == a else 0.0 for x in range(n)]
