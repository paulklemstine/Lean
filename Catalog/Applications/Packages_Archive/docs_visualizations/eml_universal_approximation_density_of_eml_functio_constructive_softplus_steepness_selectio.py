from math import log, ceil
from typing import List, Sequence, Tuple

LOG2: float = log(2.0)

def select_softplus_steepness(
    coeffs: Sequence[Tuple[float, float, float]],
    eps: float,
    margin: float = 1e-3,
) -> float:
    """Return a steepness beta certifying uniform error < eps for the softplus
    surrogate of a shallow ReLU network with output weights coeffs=[(c_i,a_i,b_i)].

    By shallow_eml_uniform_approx, any beta > (sum|c_i|) * log 2 / eps suffices.
    Complexity: O(N), a single pass over the N weights; no optimization needed.
    """
    if eps <= 0.0:
        raise ValueError("eps must be positive")
    s: float = sum(abs(c) for (c, _a, _b) in coeffs)
    if s == 0.0:
        return 1.0
    return (1.0 + margin) * s * LOG2 / eps
