from typing import Sequence

def max_plus_integral(phi: Sequence[float], w: Sequence[float]) -> float:
    """Idempotent free energy int^+ phi dP = max_x ( phi(x) + w(x) ).

    phi : observable values, one per outcome.
    w   : max-plus measure weights (log-likelihoods), one per outcome.
    Returns the single scalar max_x ( phi(x) + w(x) ).
    """
    best = float("-inf")
    for p, wx in zip(phi, w):
        val = p + wx
        if val > best:
            best = val
    return best
