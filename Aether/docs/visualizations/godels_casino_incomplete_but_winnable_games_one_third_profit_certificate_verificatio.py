from typing import Sequence

def one_third_profit_certificate(ps: Sequence[float], tol: float = 1e-12) -> bool:
    """Return True iff the One-Third Theorem guarantees positive expected profit.

    Requires: the deck is nonempty, every p_i >= 1/2, and at least n/3 of the
    cards satisfy p_i > 1/2.
    """
    n = len(ps)
    if n == 0:
        return False
    if not all(p >= 0.5 - tol for p in ps):
        return False
    winners = sum(1 for p in ps if p > 0.5 + tol)
    return winners >= n / 3.0
