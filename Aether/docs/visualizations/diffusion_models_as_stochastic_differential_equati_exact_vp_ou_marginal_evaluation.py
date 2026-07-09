from typing import List
import math


def vp_marginals(m0: float, v0: float, times: List[float]) -> List[tuple[float, float, float]]:
    """Evaluate the exact VP-OU marginal (mean, variance) on a time grid.

    Returns a list of (t, m(t), v(t)) with
        m(t) = m0 * exp(-t/2),    v(t) = 1 + (v0 - 1) * exp(-t).
    Complexity: O(N) for N grid points (two exponentials each).
    """
    out: List[tuple[float, float, float]] = []
    for t in times:
        m = m0 * math.exp(-t / 2.0)
        v = 1.0 + (v0 - 1.0) * math.exp(-t)
        out.append((t, m, v))
    return out
