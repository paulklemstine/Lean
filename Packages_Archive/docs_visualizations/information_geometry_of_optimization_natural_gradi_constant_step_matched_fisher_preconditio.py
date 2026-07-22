from __future__ import annotations
from typing import Sequence, List, Tuple

def constant_matched_descent(weights: Sequence[float], x0: Sequence[float], eta: float, steps: int) -> Tuple[List[float], float]:
    if len(weights) != len(x0) or any(w <= 0 for w in weights): raise ValueError("positive matching weights required")
    x = list(x0)
    for _ in range(steps): x = [(1.0-eta)*v for v in x]
    energy = 0.5*sum(w*v*v for w, v in zip(weights, x))
    return x, energy
