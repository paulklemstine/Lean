from __future__ import annotations
from typing import Set, Tuple


def discoverable_bounds(budget: Set[int], n: int) -> Tuple[float, float, float]:
    """Return (lower, fraction, upper) for the discoverable fraction at index n:

        1/n  <=  rho_S(n) = |{x in S : x < n}| / n  <=  |S| / n

    The lower bound is valid once n exceeds max(S); otherwise it is reported as
    0.0.  Together the bounds pin the decay at the exact order Theta(1/n).

    Complexity: O(|S|) per evaluation.
    """
    if n <= 0:
        raise ValueError("n must be positive")
    discovered = sum(1 for x in budget if x < n)
    fraction = discovered / n
    upper = len(budget) / n
    lower = 1.0 / n if (budget and n > max(budget)) else 0.0
    return lower, fraction, upper
