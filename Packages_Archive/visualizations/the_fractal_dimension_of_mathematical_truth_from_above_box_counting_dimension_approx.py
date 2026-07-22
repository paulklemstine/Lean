from __future__ import annotations
import math
from typing import Callable, List

def dimension_from_above(
        covering_number: Callable[[int], int],
        depths: List[int]) -> List[float]:
    """Descending rational upper bounds bracketing the box dimension.
    r_n = log2(N_n)/n is computed for growing n; the running tail supremum
    yields a monotonically non-increasing sequence converging to dim_B."""
    raw: List[float] = [math.log2(covering_number(n)) / n for n in depths]
    tail: List[float] = []
    run: float = 0.0
    for v in reversed(raw):
        run = max(run, v)
        tail.append(run)
    return list(reversed(tail))
