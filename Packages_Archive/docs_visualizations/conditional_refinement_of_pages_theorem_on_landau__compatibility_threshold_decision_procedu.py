from __future__ import annotations
from math import log


def compatibility_threshold(eps: float, q0: int, m: int) -> float:
    """Return tau = 2 * Q0^(-eps) * log(M), the barrier the repulsion constant must beat."""
    return 2.0 * (float(q0) ** (-eps)) * log(float(m))


def uniqueness_guaranteed(eps: float, c: float, q0: int, m: int) -> bool:
    """Decide in O(1) whether repulsion constant C forces uniqueness on [Q0, M].

    Returns True iff C > 2 * Q0^(-eps) * log(M) (the hypothesis of the main theorem)."""
    if not (eps > 0.0 and 2 <= q0 <= m):
        raise ValueError("require eps > 0 and 2 <= Q0 <= M")
    return c > compatibility_threshold(eps, q0, m)
