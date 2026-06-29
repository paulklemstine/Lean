from functools import lru_cache
from math import comb

@lru_cache(maxsize=None)
def es_bound(s: int, t: int) -> int:
    """Verified Erdős–Szekeres upper bound for R(s, t)."""
    if s == 1 or t == 1:
        return 1
    return es_bound(s - 1, t) + es_bound(s, t - 1)

def es_bound_closed(s: int, t: int) -> int:
    """Closed form: C(s + t - 2, s - 1)."""
    return comb(s + t - 2, s - 1)

assert es_bound(3, 3) == es_bound_closed(3, 3) == 6
