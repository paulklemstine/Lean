from __future__ import annotations
from math import ceil


def shallow_width_lower_bound(k: int, eps: float, A: float) -> int:
    """Minimum shallow width forced by the separation theorem.

    Returns ceil(2^k (1 - 2 eps) / A): any shallow ReLU net approximating
    tent^[k] to accuracy eps < 1/2 under per-neuron weight cap A needs at
    least this many neurons. Constant time.
    """
    if not (0.0 <= eps < 0.5):
        raise ValueError("require 0 <= eps < 1/2")
    if A <= 0.0:
        raise ValueError("require A > 0")
    return max(0, ceil((2 ** k) * (1.0 - 2.0 * eps) / A))
