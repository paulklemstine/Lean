from typing import Sequence, Tuple

def fraction_bound_floor(ps: Sequence[float], eps: float) -> Tuple[float, float]:
    """Certified lower bound on total expected payoff via the fraction bound.

    Let G = {i : p_i >= 1/2 + eps} and alpha = |G| / n. When every p_i >= 1/2,
    the total expected payoff is provably >= alpha * n * (2 eps) = 2 |G| eps.
    Returns (alpha, floor).
    """
    n = len(ps)
    if n == 0:
        return 0.0, 0.0
    good = sum(1 for p in ps if p >= 0.5 + eps)
    alpha = good / n
    floor = alpha * n * (2.0 * eps)
    return alpha, floor
