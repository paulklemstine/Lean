from __future__ import annotations
from typing import Sequence, List, Tuple

def harmonic_matched_descent(weights: Sequence[float], x0: Sequence[float], steps: int) -> Tuple[List[float], float]:
    if len(weights) != len(x0) or any(w <= 0 for w in weights): raise ValueError("positive matching weights required")
    x = list(x0)
    for k in range(steps):
        eta = 1.0/(k+2.0)
        x = [(1.0-eta)*v for v in x]
    return x, 0.5*sum(w*v*v for w, v in zip(weights, x))
