from __future__ import annotations
from math import isclose
from typing import Sequence

def observationally_equivalent(left: Sequence[float], right: Sequence[float], tolerance: float = 1e-12) -> bool:
    if len(left) != len(right):
        return False
    def weights(xs: Sequence[float]) -> list[float]:
        n = sum(x * x for x in xs)
        if n == 0.0:
            raise ValueError("zero state")
        return [x * x / n for x in xs]
    return all(isclose(a, b, abs_tol=tolerance, rel_tol=tolerance) for a, b in zip(weights(left), weights(right)))
