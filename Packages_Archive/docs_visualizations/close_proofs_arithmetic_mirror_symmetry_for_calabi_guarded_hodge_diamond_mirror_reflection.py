from typing import Callable, Dict, Tuple

Diamond = Callable[[int, int], int]

def mirror(h: Diamond, d: int) -> Diamond:
    """Guarded vertical reflection p -> d - p of a Hodge diamond."""
    def mh(p: int, q: int) -> int:
        if 0 <= p <= d and 0 <= q <= d:
            return h(d - p, q)
        return 0
    return mh

def picard_rank(h: Diamond) -> int:
    """Picard rank h^{1,1}."""
    return h(1, 1)
