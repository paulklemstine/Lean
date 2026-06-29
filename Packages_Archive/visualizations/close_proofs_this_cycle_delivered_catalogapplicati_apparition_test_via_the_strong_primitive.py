from typing import Callable, Optional


def divides_by_criterion(u: Callable[[int], int], p: int, m: int,
                         search_bound: int = 10000) -> Optional[bool]:
    """Return whether p | u(m) using ONLY rank(u, p) and m (no computation of u(m)).

    Correct because p | u(m)  <=>  rank(u, p) | m for strong divisibility sequences."""
    r = rank_of_apparition(u, p, search_bound)
    if r is None:
        return None
    return m % r == 0
