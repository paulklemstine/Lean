from math import comb
from typing import List, Tuple

def rank_profile_and_width(n: int) -> Tuple[List[int], int, int, int]:
    """Compute the rank profile of the Boolean lattice B_{n+1}, its width,
    the total number of vertices, and the tropical (min-plus) aggregate.

    Returns (profile, width, total, tropical_min)."""
    m: int = n + 1
    profile: List[int] = [comb(m, k) for k in range(m + 1)]
    width: int = max(profile)          # = comb(m, m // 2), the central coefficient
    total: int = sum(profile)          # = 2 ** m, the group order
    tropical_min: int = min(profile)   # = 1, attained at the empty and full sets
    return profile, width, total, tropical_min
